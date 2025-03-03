import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:s3_client/src/models/user.dart';
import 'package:s3_client/src/utils/backblaze_service.dart';
import 'package:s3_client/src/utils/list_of_colors.dart';
import 'package:s3_client/src/utils/snackbar_shower.dart';
import 'package:s3_client/src/widgets/cloud_object/cloud_object.dart';
import 'package:provider/provider.dart';
import 'package:minio/models.dart';
import 'package:path/path.dart' as path;

class SearchPageWidget extends StatefulWidget {
  final List<Object> objects;

    const SearchPageWidget({
    super.key,
    required this.objects
    });

  @override
  State<SearchPageWidget> createState() => _SearchPageWidgetState();
}

class _SearchPageWidgetState extends State<SearchPageWidget> {

  late List<Object> foundObjects = []; //for display which objects to show
  late List<Object> allObjects = []; // to keep in memory all the existing files
  late BackblazeService _b2service;
  late String userBucket;
  late User loggedUser;


  late Map<String, CloudObjectController> _controllers;

    @override
    void initState() {
    super.initState();
    
    _b2service = context.read<BackblazeService>();
    
    loggedUser = context.read<User>();
    userBucket = loggedUser.username.toLowerCase();
    _controllers = {};

    allObjects = widget.objects;
    allObjects.removeWhere((Object foundObject) {  // BackBlaze Specific Implementation that Will Omit the .bzEmpty File that is Created Automatically as a Mechanism for Creating Folders
      return foundObject.key!.endsWith(".bzEmpty") && foundObject.size == 0;
    });
    foundObjects = allObjects;
  }


  @override
  Widget build(BuildContext context) {

    List<Color> listOfIconColors = MyColorsList.listOfIconColors;

    return Scaffold(
      appBar: AppBar(
        shape: const Border(bottom: BorderSide()),
        title: TextField(
          decoration: InputDecoration.collapsed(hintText: "Search for an object..."),
          autofocus: true,
          onChanged: (value) => findObjects(value),
        ),
        
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
            child: foundObjects.isEmpty
                ? const Center(
                    child: Text("No files found.", style: TextStyle(fontSize: 20.0),),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:  MediaQuery.of(context).size.width <= 830 ? (MediaQuery.of(context).size.width <= 565 ? 1 : 2) : 3,
                      mainAxisSpacing: 5.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: MediaQuery.of(context).size.width <= 830 ? (MediaQuery.of(context).size.width <= 565 ? 1.5 : 0.9) : 0.7,
                    ),
                    itemCount: foundObjects.length,
                    itemBuilder: (context, index) {
                      String fileKey = foundObjects[index].key.toString();

                      // Ensure that the controller is created for this file if not already done
                      if (!_controllers.containsKey(fileKey)) {
                        _controllers[fileKey] = CloudObjectController();  // Initialize a new controller
                      }

                      CloudObjectController controller = _controllers[fileKey]!;
                      String thisFileName = foundObjects[index].key!;
                      return CloudObject(
                        controller: controller,
                        eTag: foundObjects[index].eTag,
                        size: foundObjects[index].size,
                        owner: foundObjects[index].owner,
                        lastModified: foundObjects[index].lastModified,
                        fileName: foundObjects[index].key!,
                        iconColor: listOfIconColors[foundObjects[index].hashCode % listOfIconColors.length],
                        onDownload: () => _downloadFile(thisFileName, controller),
                        onDelete: (){
                          setState(() {
                            foundObjects.removeAt(index);
                          });
                        },
                        border: Border.all(
                          color: const Color.fromARGB(125, 226, 158, 11),
                          width: 1.25,
                          ),
                        borderRadius: BorderRadius.circular(20.0),
                      );
                    },
                  ),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> findObjects(String searchString) async {
    List<Object> tempObjects = allObjects;
    tempObjects = tempObjects.where((object) => object.key!.contains(searchString)).toList();
    

    setState(() {
      foundObjects = tempObjects;
    });

  }

  Future<void> _downloadFile(String fileName, CloudObjectController controller) async {
  await requestPermission(); // Ensure permissions

  // Open file picker to select a directory
  String? directoryPath = await FilePicker.platform.getDirectoryPath(
    dialogTitle: "Select a Download Directory",
  );

  if (directoryPath != null) {
    // Ensure path is correctly joined
    String nameToSave = (fileName.contains('/') ? fileName.split("/").last : fileName);
    String savePath = path.join(directoryPath, nameToSave);

    

    try {
      bool success = await _b2service.downloadFileWithProgress(
        bucketName: userBucket,
        objectName: fileName,
        savePath: savePath,
        onProgress: (progress) {
          controller.updateProgress(progress);
        },
      );

      if (success) {
        SnackbarShower.showSnackbar(
          context: context,
          message: 'File downloaded successfully to $savePath',
          color: Colors.green,
        );
      } else {
        SnackbarShower.showSnackbar(
          context: context,
          message: 'Error downloading file',
          color: Colors.red,
        );
      }
    } catch (e) {
      print("Download error: $e");
      SnackbarShower.showSnackbar(
        context: context,
        message: 'Failed to download file: $e',
        color: Colors.red,
      );
    }
  } else {
    SnackbarShower.showSnackbar(
      context: context,
      message: 'No directory selected',
      color: Colors.red,
    );
  }
}

Future<void> requestPermission() async {
  if (Platform.isAndroid) {
      var storageStatus = await Permission.storage.status;

      if (!storageStatus.isGranted) {
        await Permission.storage.request();
        }

      if (await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
        }
      }
  }
}