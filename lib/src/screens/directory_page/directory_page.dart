import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:minio/models.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:s3_client/src/models/change_follower.dart';
import 'package:s3_client/src/models/user.dart';
import 'package:s3_client/src/screens/home_page/home_page_item.dart';
import 'package:s3_client/src/utils/backblaze_service.dart';
import 'package:s3_client/src/utils/list_of_colors.dart';
import 'package:s3_client/src/utils/snackbar_shower.dart';
import 'package:s3_client/src/widgets/cloud_directory/cloud_directory.dart';
import 'package:s3_client/src/widgets/cloud_object/cloud_object.dart';
import 'package:path/path.dart' as path;

class DirectoryPageWidget extends StatefulWidget {

  final String prefix;
  late List<Object> foundFiles; 

  DirectoryPageWidget({
    super.key,
    required this.prefix,
    required this.foundFiles
    });

  @override
  State<DirectoryPageWidget> createState() => _DirectoryPageWidgetState();
}

class _DirectoryPageWidgetState extends State<DirectoryPageWidget> with SingleTickerProviderStateMixin  {

  late BackblazeService _b2service;
  late List<Object> foundFiles = [];
  late String userBucket;
  late User loggedUser;
  late ChangeFollower changeFollower;

  List<HomePageItem> itemsToDisplay = []; // Will Contain the List of All Top Level Entities to Print Out

  void requestFileUpload() {
    
    return;
  }

  late Map<String, CloudObjectController> _controllers;
  bool _isReloading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    
    _b2service = context.read<BackblazeService>();
    
    loggedUser = context.read<User>();
    userBucket = loggedUser.username.toLowerCase();
    _controllers = {};
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    
     foundFiles = widget.foundFiles
      .where((object) => object.key != null && object.key!.startsWith(widget.prefix))
      .toList();  //  Filtered out only those who start with the given prefix
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    changeFollower = context.watch<ChangeFollower>();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

    Future<List<Object>> getAllBucketObjects(String bucket, {String prefix = ""}) async{

      ListObjectsResult? list = await _b2service.fetchAllObjectsFromBucket(bucket, prefix: prefix);
      list ??= ListObjectsResult(objects: [], prefixes: []); 
      
      List<Object> objectsList =  list.objects;

    
      return objectsList;
  }

    Future<void> loadObjects() async {
    List<Object> objects = await getAllBucketObjects(userBucket, prefix: widget.prefix);
    
    setState(() {
      foundFiles = objects;
    });
    
  }

    Future<void> _reloadObjects() async {
    if (_isReloading) return; // Guard against repeated presses.
    setState(() {
      _isReloading = true;
    });
    _animationController.repeat();
    
    try{
      await loadObjects();
    }
    finally{
      _animationController.stop();
      setState(() {
        _isReloading = false;
      });
    }
    
  }

  void showDeleteDialog(BuildContext context, Object myObject) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Warning"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              const Text("Are you sure you wish to delete this object from storage?"),
              const Text("(Deleted Storage items can't be retrieved)"),
              const SizedBox(height: 10.0,),
              Text("Name: ${myObject.key}")
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                handleDelete(loggedUser.username.toLowerCase(), myObject);
                },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<bool> handleDelete(String bucket, Object myObject) async{
    bool success = await _b2service.deleteObject(
      bucket: bucket,
      objectName: myObject.key!
      );

    if(success)
    {
      setState(()
    {
      foundFiles.removeWhere((o) {
        return o == myObject;
      });
    });
    SnackbarShower.showSnackbar(
      context: context, 
      message: "File ${myObject.key} deleted successfully!", 
      color: Colors.green.shade400);
    changeFollower.needToGetObjects = true;
    return true;
    }
    else{
      return false;
    }
  }

  Future<void> requestPermission() async {
  if (Platform.isAndroid) {
    var storageStatus = await Permission.storage.status;

    if (await Permission.manageExternalStorage.isDenied) {
      await Permission.manageExternalStorage.request();
    }
    /*
    if (!storageStatus.isGranted) {
      await Permission.storage.request(); //  Deprecated on newer OS
    }
    */
    
  }
}

  Future<void> downloadFile(String fileName, CloudObjectController controller) async {
  await requestPermission(); // Ensure permissions

  // Open file picker to select a directory
  String? directoryPath = await FilePicker.platform.getDirectoryPath(
    dialogTitle: "Select a Download Directory",
  );

  if (directoryPath != null) {
    // Ensure path is correctly joined
    String savePath = path.join(directoryPath, fileName);

    // print("FINAL SELECTED PATH: $savePath");

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
          color: Colors.green.shade300,
        );
      } else {
        SnackbarShower.showSnackbar(
          context: context,
          message: 'Error downloading file',
          color: Colors.red.shade400,
        );
      }
    } catch (e) {
      print("Download error: $e");
      SnackbarShower.showSnackbar(
        context: context,
        message: 'Failed to download file: $e',
        color: Colors.red.shade400,
      );
    }
  } else {
    SnackbarShower.showSnackbar(
      context: context,
      message: 'No directory selected',
      color: Colors.red.shade400,
    );
  }
}

String getNameWithoutPrefix(String name){
  return name.replaceFirst(RegExp("${widget.prefix}/"), "");
}



  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    List<Color> listOfIconColors = MyColorsList.listOfIconColors;


    if(changeFollower.needToGetObjects) {
      print("RELOADING OBJECTS!");  //FOR DEBUGGING PURPOSES
      _reloadObjects();
      changeFollower.needToGetObjects = false;
    }

    List<Object> topLevelObjects = [];
    Set<String> topLevelDirectories = {};
    int numOfDirectories = 0;
    int numOfFiles = 0;

    for(Object foundObject in foundFiles) {
      String foundObjectString = foundObject.key!;
      String pathWithoutPrefix = getNameWithoutPrefix(foundObjectString);
      
      if(pathWithoutPrefix.contains("/"))
      {
         topLevelDirectories.add(pathWithoutPrefix.split("/").first);
         numOfDirectories++;
      }
      else{
          topLevelObjects.add(foundObject);
          numOfFiles++;
      }
    }
    

    topLevelObjects.removeWhere((Object foundObject) {  // BackBlaze Specific Implementation that Will Omit the .bzEmpty File that is Created Automatically as a Mechanism for Creating Folders
      return foundObject.key!.endsWith(".bzEmpty") && foundObject.size == 0;
    });


      List<HomePageItem> itemsToDisplay = []; // Will Contain the List of All Top Level Entities to Print Out

      itemsToDisplay.addAll(
        topLevelDirectories
            .map((directory) => HomePageItem.directory(directory))
            .toList()
            ..sort((a, b) => a.directoryName!.compareTo(b.directoryName!))
      );

      itemsToDisplay.addAll(
        topLevelObjects
          .map((Object object) => HomePageItem.object(object))
          .toList()
          ..sort((HomePageItem a, HomePageItem b) => a.object!.key!.compareTo(b.object!.key!))
      );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Directory"),
      ),
       body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
            child: (itemsToDisplay.isEmpty)
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
                    itemCount: itemsToDisplay.length,
                    itemBuilder: (context, index) {
                      
                      if(itemsToDisplay[index].type == HomePageItemType.object)
                      {
                        String thisFileName = itemsToDisplay[index].object!.key!;

                        Object fileObject = itemsToDisplay[index].object!;
                        String fileKey = fileObject.key.toString();

                        // Ensure that the controller is created for this file if not already done
                        if (!_controllers.containsKey(fileKey)) {
                          _controllers[fileKey] = CloudObjectController();  // Initialize a new controller
                        }
                        CloudObjectController controller = _controllers[fileKey]!; // For measuring download progress

                        return CloudObject(
                          controller: controller,
                          eTag: fileObject.eTag,
                          size: fileObject.size,
                          owner: fileObject.owner,
                          lastModified: fileObject.lastModified,
                          fileName: getNameWithoutPrefix(fileObject.key!),
                          iconColor: listOfIconColors[fileObject.key.hashCode % listOfIconColors.length],
                          onDownload: () => downloadFile(thisFileName, controller),
                          onDelete: () async {
                            showDeleteDialog(context, fileObject);
                          },
                          border: Border.all(
                            color: const Color.fromARGB(125, 226, 158, 11),
                            width: 1.25,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        );
                      } // end of if(type is Object)
                      else{  //  In case the next item is a directory, do this segment
                        String directoryName = itemsToDisplay[index].directoryName!;

                        return CloudDirectory(fileName: directoryName, 
                        onClick: () {
                                       Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context)=> DirectoryPageWidget(prefix: widget.prefix + "/" +directoryName, foundFiles: widget.foundFiles,))
                                       );
                        },
                        onDelete: () {},
                        iconColor: Colors.yellow.shade300,
                        );
                      }   //  end of else
                      
                      
                    },
                  ),
              ),
            ],
          ),
        ),
      ),
    );
    
  }
}