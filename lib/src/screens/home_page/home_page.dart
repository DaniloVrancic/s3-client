// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:minio/models.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:s3_client/src/models/change_follower.dart';
import 'package:s3_client/src/models/storage_item.dart';
import 'package:s3_client/src/models/user.dart';
import 'package:s3_client/src/screens/search_page/search_page.dart';
import 'package:s3_client/src/screens/settings_page/settings_page.dart';
import 'package:s3_client/src/screens/start_page/start_page_view.dart';
import 'package:s3_client/src/screens/upload_file_page/upload_file_page.dart';
import 'package:s3_client/src/utils/backblaze_service.dart';
import 'package:s3_client/src/utils/list_of_colors.dart';
import 'package:s3_client/src/utils/snackbar_shower.dart';
import 'package:s3_client/src/widgets/cloud_object/cloud_object.dart';
import 'package:path/path.dart' as path;

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});
  

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> with SingleTickerProviderStateMixin  {

  late BackblazeService _b2service;
  late List<StorageItem> foundFiles = [];
  late String userBucket;
  late User loggedUser;
  late ChangeFollower changeFollower;

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
    _reloadObjects(); // Initial loading of objects
    
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
void didChangeDependencies() {
  super.didChangeDependencies();
  changeFollower = context.watch<ChangeFollower>();
}

  Future<void> loadObjects() async {
    List<StorageItem> objects = await getAllBucketObjects(userBucket);
    
    setState(() {
      foundFiles = objects;
    });
  }

  Future<List<StorageItem>> getAllBucketObjects(String bucket) async{

      ListObjectsResult? list = await _b2service.fetchAllObjectsFromBucket(bucket);
      list ??= ListObjectsResult(objects: [], prefixes: []); 
      
      List<Object> objectsList =  list.objects;
      List<String> prefixList = list.prefixes;

      List<StorageItem> storageItemList = []; // A combination of objects and prefixes

      for(String prefix in prefixList){
        StorageItem newStorageItem = StorageItem(key: prefix, type: StorageItemType.directory);
        storageItemList.add(newStorageItem);
      }
      for(Object object in objectsList){
        StorageItem newStorageItem = StorageItem(key: object.key!, type: StorageItemType.file, fileObject: object);
        storageItemList.add(newStorageItem);
      }

      return storageItemList;
  }

/*
  Future<void> simulatedDownloadWithProgress(int seconds, CloudObjectController controller) async {
    for(int i = 0; i < seconds; i++){
      controller.updateProgress(i / seconds);
      await Future.delayed(Duration(seconds: 1));
    }
  } */

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


Future<void> _downloadFile(String fileName, CloudObjectController controller) async {
  await requestPermission(); // Ensure permissions

  // Open file picker to select a directory
  String? directoryPath = await FilePicker.platform.getDirectoryPath(
    dialogTitle: "Select a Download Directory",
  );

  if (directoryPath != null) {
    // Ensure path is correctly joined
    String savePath = path.join(directoryPath, fileName);

    print("FINAL SELECTED PATH: $savePath");

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

void _showDeleteDialog(BuildContext context, Object myObject) {
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
                _handleDelete(loggedUser.username.toLowerCase(), myObject);
                },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _handleDelete(String bucket, Object myObject) async{
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

    return true;
    }
    else{
      return false;
    }
  }

  // This method wraps loadObjects() with our loading logic.
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
  

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    List<Color> listOfIconColors = MyColorsList.listOfIconColors;


    if(changeFollower.needToGetObjects) {
      _reloadObjects();
      print("FETCHING OBJECTS NOW!");
      changeFollower.needToGetObjects = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(onPressed: () async { await _reloadObjects(); },
              
              icon: _isReloading 
                ? RotationTransition(
                    turns: _animationController,
                    child: const Icon(Icons.refresh),
                  )
                : const Icon(Icons.refresh),
              ),
          IconButton(onPressed: () => 
             Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=> SearchPageWidget(objects: foundFiles,))
                ),
              
              icon: const Icon(Icons.search)
              ),
              
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          //ScaffoldMessenger.of(context).showSnackBar(
          //const SnackBar(content: Text('File successfully uploaded')),
          //)

          
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=> const UploadFilePage())
                )
        },
        tooltip: "Upload File",
        backgroundColor: const Color.fromARGB(150, 210, 100, 10),
        child: const Icon(Icons.add)
      ),
      
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      gradient: LinearGradient(colors: [
                  Color.fromARGB(255, 228, 58, 11),
                              (theme.brightness == Brightness.light) ? Color.fromARGB(235, 245, 145, 30) : Color.fromARGB(174, 50, 20, 5),
                ])
                    ),
                    child: Text("Menu",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36
                    )),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text("Settings"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> const SettingsPageWidget())
                      );
                    },
                  ),
                  ListTile(
                      leading: const Icon(Icons.upload_file),
                    title: const Text("Upload File"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> const UploadFilePage())
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text("Log Out"),
                    onTap: () {
                      loggedUser.logout();
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> const StartPageWidget())
                      );
                    },
                  ),
                ],
              ),
            ),
          const Divider(), // Divider above the user info
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage('assets/images/default_user.png'), // Use a default profile picture
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loggedUser.username,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  loggedUser.email,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ],
                ),
                ],
              ),
            ),
          ],
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
            child: foundFiles.isEmpty
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
                    itemCount: foundFiles.length,
                    itemBuilder: (context, index) {
 
                      String thisFileName = foundFiles[index].key;

                      if(foundFiles[index].type == StorageItemType.file)
                      {
                        Object fileObject = foundFiles[index].fileObject!;
                        String fileKey = fileObject.key.toString();

                      // Ensure that the controller is created for this file if not already done
                      if (!_controllers.containsKey(fileKey)) {
                        _controllers[fileKey] = CloudObjectController();  // Initialize a new controller
                      }

                      CloudObjectController controller = _controllers[fileKey]!;
                        return CloudObject(
                        controller: controller,
                        eTag: fileObject.eTag,
                        size: fileObject.size,
                        owner: fileObject.owner,
                        lastModified: fileObject.lastModified,
                        fileName: fileObject.key.toString(),
                        iconColor: listOfIconColors[fileObject.key.hashCode % listOfIconColors.length],
                        onDownload: () => _downloadFile(thisFileName, controller),
                        onDelete: () async {
                          _showDeleteDialog(context, fileObject);
                        },
                        border: Border.all(
                          color: const Color.fromARGB(125, 226, 158, 11),
                          width: 1.25,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                      );
                      }
                      else{
                        //TODO: IMplement a widget for displaying directories and return it here
                      }
                      
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
