import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:minio/models.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:s3_client/src/models/change_follower.dart';
import 'package:s3_client/src/screens/home_page/home_page_item.dart';
import 'package:s3_client/src/screens/upload_file_page/upload_file_page.dart';
import 'package:s3_client/src/utils/app_utils.dart';
import 'package:s3_client/src/utils/backblaze_service.dart';
import 'package:s3_client/src/utils/list_of_colors.dart';
import 'package:s3_client/src/utils/snackbar_shower.dart';
import 'package:s3_client/src/widgets/cloud_directory/cloud_directory.dart';
import 'package:s3_client/src/widgets/cloud_object/cloud_object.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';

class DirectoryPageWidget extends StatefulWidget {

  final String prefix;
  final List<Object> foundFiles; 

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
  
  late ChangeFollower changeFollower;

  List<HomePageItem> itemsToDisplay = []; // Will Contain the List of All Top Level Entities to Print Out



  late Map<String, CloudObjectController> _controllers;
  bool _isReloading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    
    _b2service = context.read<BackblazeService>();
    
    
    userBucket = AppUtils.getBucketFromContext(context);
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

    Future<List<Object>> getAllBucketObjects(String bucket, {String prefix = ""}) async {

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

  void showDeleteDialog(BuildContext context, Object myObject) async {
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
                handleDelete(userBucket, myObject);
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

  Future<void> handlePresignedPutUrl(int hours, {String prefix = ""}) async {
  final String? selectedObjectName = await _showInputObjectNameDialog(context, prefix: prefix);

  if(selectedObjectName == null) return;

  try{
    final BackblazeService backblazeService = context.read<BackblazeService>();
     
    final String userBucket = AppUtils.getBucketFromContext(context);
    String link;

    link = await backblazeService.getPresignedPutUrl(bucket: userBucket, object: (prefix.isNotEmpty) ? "$prefix/$selectedObjectName" : selectedObjectName);

    Share.share(link, subject: "Upload your file here!");
  } 
  catch (e) {
      SnackbarShower.showSnackbar(
          message: "Failed to retrieve link! ($e)",
          context: context,
          color: Colors.red.shade300
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

  Future<void> downloadFile(String fileName, CloudObjectController controller) async {
  await requestPermission(); // Ensure permissions
  
  // Open file picker to select a directory
  String? directoryPath = await FilePicker.platform.getDirectoryPath(
    dialogTitle: "Select a Download Directory",
  );

  if (directoryPath != null) {
    // Ensure path is correctly joined
    String savePath = path.join(
      directoryPath, 
      fileName.split("/").last  //Gets only the file name (filters out the nested directory names (prefixes))
      );
    // print("SAVE PATH: $savePath" );

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

Future<void> _showAddDirectoryDialog() async {
  final TextEditingController directoryNameController = TextEditingController();
  
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Add Directory"),
        content: TextField(
          controller: directoryNameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Enter directory name",
          ),
          inputFormatters: [
            // Only allow alphanumeric characters
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cancel button: close the dialog.
            },
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () async {
              final String dirName = directoryNameController.text.trim();
              if (dirName.isNotEmpty) {
                await _createDirectory(widget.prefix + '/' + dirName + '/');
              }
              Navigator.of(context).pop(); // Close the dialog after confirming.
            },
            child: const Text(
              "Confirm",
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> _createDirectory(String directoryName) async {
    const String emptyFileName = ".bzEmpty";
    String fullFilePath = directoryName + emptyFileName;

    Uint8List emptyList = Uint8List.fromList([]);

    _b2service.uploadFileFromBytes(emptyList, userBucket, fullFilePath)
              .then((bool success) { 
                if(success){
                    _reloadObjects();
                    SnackbarShower.showSnackbar(
                      context: context, 
                      color: Colors.green.shade300, 
                      message: "Directory created.");
                    }
                  else{
                    SnackbarShower.showSnackbar(context: context,
                    color: Colors.red.shade400,
                    message: "Error establishing connection to the server.");
                  }
                  }
                );
}


    void showDeleteDirectoryDialog(BuildContext context, String myDir) async {
      String fullDirectory = "${widget.prefix}/$myDir/";
      List<Object> objectsFromDirectory = widget.foundFiles.where((Object myObject) { return myObject.key!.startsWith(fullDirectory);}).toList();
     showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Warning"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              const Text("Are you sure you wish to delete this directory from storage?"),
              const Text("(All subdirectories will also be deleted.)"),
              const SizedBox(height: 10.0,),
              Text("Name: $myDir")
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
                List<String> objectPaths = objectsFromDirectory.map((Object myObject) { return myObject.key!; }).toList();
                _b2service.deleteObjects(bucket: userBucket, objectPaths: objectPaths)
                          .then((bool success) 
                          { 
                            if(success){
                              _reloadObjects();
                              SnackbarShower.showSnackbar(context: context, color: Colors.green.shade300, message: "Successfully deleted objects.");
                            }
                            else{
                              SnackbarShower.showSnackbar(context: context, color: Colors.red.shade400, message: "Failed deleting objects.");
                            }
                           });
                },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showInputObjectNameDialog(
              BuildContext context, {
              String prefix = "",
          }) async {
          final TextEditingController _controller = TextEditingController();
          String? errorText;

          return showDialog<String>(
            context: context,
            barrierDismissible: false, // Prevents dismissing by tapping outside.
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text("Please input desired object name to Share for PUT:"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            labelText: "Object Name",
                            hintText: "Enter Object Name",
                            errorText: errorText,
                          ),
                          onChanged: (value) {
                            setState(() {
                              errorText = null;
                            });
                          },
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(null);
                        },
                        child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                      ),
                      TextButton(
                        onPressed: () {
                          try{

                          final input = _controller.text.trim();
                          // Validate input.
                          if (input.isEmpty) {
                            setState(() {
                              errorText = "Object name cannot be empty.";
                            });
                            return;
                          }
                          if (input.contains('/')) {
                            setState(() {
                              errorText = "Object name must not contain '/'.";
                            });
                            return;
                          }
                          // Return the validated input.
                          Navigator.of(context).pop(input);
                          }
                          catch(e){
                            SnackbarShower.showSnackbar(context: context, message: "Invalid object name", color: Colors.red);
                            return;
                          }
                          
                          
                        },
                        child: const Text("Share", style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  );
                },
              );
            },
          );
    }
    
    

String getNameWithoutPrefix(String name){
  return name.replaceFirst(RegExp("${widget.prefix}/"), "");
}

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    List<Color> listOfIconColors = MyColorsList.listOfIconColors;
    final int HOURS_FOR_PRESIGNED_URL = 72;


    if(changeFollower.needToGetObjects) {
      print("RELOADING OBJECTS!");  // FOR DEBUGGING PURPOSES
      _reloadObjects();
      changeFollower.needToGetObjects = false;
    }

    List<Object> topLevelObjects = [];
    Set<String> topLevelDirectories = {};

    for(Object foundObject in foundFiles) {
      String foundObjectString = foundObject.key!;
      String pathWithoutPrefix = getNameWithoutPrefix(foundObjectString);
      
      if(pathWithoutPrefix.contains("/"))
      {
         topLevelDirectories.add(pathWithoutPrefix.split("/").first);
      }
      else{
          topLevelObjects.add(foundObject);
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

    List<String> prefixTokens = widget.prefix.split("/");
    String titleToShow = widget.prefix;
    if(prefixTokens.length > 3){
      titleToShow = ".../${prefixTokens[prefixTokens.length - 2]}/${prefixTokens.last}";

      if(titleToShow.length > 23)
      {
        titleToShow = ".../${prefixTokens.last}";
      }
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(
            titleToShow,
            overflow: TextOverflow.ellipsis,
                ),
          actions: [
            IconButton(onPressed: () => {
            handlePresignedPutUrl(HOURS_FOR_PRESIGNED_URL, prefix: widget.prefix)
          },
              icon: const Icon(Icons.share_sharp)
            ),
          IconButton(onPressed: () async { await _reloadObjects(); },
              
              icon: _isReloading 
                ? RotationTransition(
                    turns: _animationController,
                    child: const Icon(Icons.refresh),
                  )
                : const Icon(Icons.refresh),
              ),]
            ),
            
          floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'addFile',
              onPressed: () {
                String prefixToInitialize = (widget.prefix.isNotEmpty) ? "${widget.prefix}/" : "";
                Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=> UploadFilePage(prefix: prefixToInitialize))
                          );
                        },
                      tooltip: 'Add File',
                      backgroundColor: const Color.fromARGB(150, 210, 100, 10),
                      child: const Icon(Icons.attach_file),
                    ),
                    const SizedBox(height: 16),
                    FloatingActionButton(
                      heroTag: 'addDirectory',
                      onPressed: () {
                      
                        _showAddDirectoryDialog();
                      },
                      tooltip: 'Add Directory',
                      backgroundColor: const Color.fromARGB(150, 210, 100, 10),
                      child: const Icon(Icons.create_new_folder),
                    ),
                  ],
        ),

       body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
            child: _isReloading 
             ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
             : (itemsToDisplay.isEmpty)
                ? const Center(
                    child: Text("No files found.", style: TextStyle(fontSize: 20.0),),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:  MediaQuery.of(context).size.width <= 830 ? (MediaQuery.of(context).size.width <= 506 ? 1 : 2) : 3,
                      mainAxisSpacing: 5.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: MediaQuery.of(context).size.width <= 830 ? (MediaQuery.of(context).size.width <= 506 ? 1.1 : 1.0) : 0.7,
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
                          prefix: widget.prefix,
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
                        onDelete: () // Cloud Directory on Delete function
                        {
                          showDeleteDirectoryDialog(context, directoryName);
                        },
                        iconColor: (theme.brightness == Brightness.dark) ? Colors.yellow.shade300 : Colors.yellow.shade800,
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