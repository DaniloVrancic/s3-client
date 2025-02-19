import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:s3_client/src/models/user.dart';
import 'package:s3_client/src/utils/backblaze_service.dart';
import 'package:s3_client/src/utils/snackbar_shower.dart';
import 'package:s3_client/src/widgets/file_item/file_item.dart';

class UploadFilePage extends StatefulWidget {
  const UploadFilePage({super.key});


  @override
  State<UploadFilePage> createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {

  bool _isUploading = false;
  late BackblazeService _b2Service;
  late User loggedUser; 
  double? uploadProgress = null;

  String selectedPaths = "";
  List<PlatformFile> selectedFiles = List.empty();

  @override
  void initState() {
    super.initState();

    _b2Service = context.read<BackblazeService>();
    loggedUser = context.read<User>();
  }

  void _pickMultipleFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true
    );

    if(result != null){
      List<File> files = result.paths.map((path) => File(path!)).toList();
      setState(() {
        selectedFiles = result.files;
        selectedPaths = files.toString();
      }); 
    }
    else{
      //User cancelled the picker
    }
  }

  Future<bool> _uploadFiles(List<PlatformFile> filesToUpload) async {

    List<Future<bool>> listOfFutureUploads = [];
    int totalUploadSize = filesToUpload.fold(0, (sum, file) => sum + (file.size ?? 0));
    int uploadedBytes = 0;


    setState(() {
            uploadProgress = 0.0;
            _isUploading = true;
          });

    
    for(PlatformFile pFile in filesToUpload)
    {

      Future<bool> uploadTask = _b2Service.uploadFile(
        pFile.path!, 
        loggedUser.username.toLowerCase(), 
        pFile.name)
      .then(
        (bool success) {
          if(success){
            setState(() {
              uploadedBytes += pFile.size ?? 0;
              if(uploadProgress != null)
              {
                uploadProgress = uploadedBytes / totalUploadSize;
              }
            });
          }
          else{
              setState(() {
                uploadProgress = null;
              });
          }
          return success;}, 
        onError: (error) {
          print(error); 
          return false;
          });

        
      listOfFutureUploads.add(uploadTask);
    }

    List<bool> results = await Future.wait(listOfFutureUploads);

    bool allFilesUploaded = results.every((result) => result);


    setState(() {
          if(allFilesUploaded)
          {
            uploadProgress = 1.0;
          }
            _isUploading = false;
          });

    return allFilesUploaded;
  }

  Future <void> _startUploadProcess() async{
    bool success = await _uploadFiles(selectedFiles);

    if(success)
    {
      SnackbarShower.showSnackbar(
        context: context, 
        message: "File upload successful!", 
        color: Colors.green.shade300); 
    }
    else
    {
      SnackbarShower.showSnackbar(
        context: context, 
        message: "Failed to upload some files.", 
        color: Colors.red.shade400); 
    }
    uploadProgress = null;
  }

  

  @override
  Widget build(BuildContext context) {
     final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Upload File"),
      backgroundColor: Colors.orange[400],
      ),
      body: 
      SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Column(
            children: [
          Expanded(
            child: selectedFiles.isEmpty
                ? const Center(
                    child: Text("No files selected."),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 2.0,
                    ),
                    itemCount: selectedFiles.length,
                    itemBuilder: (context, index) {
                      return FileItem(
                        file: selectedFiles[index],
                        border: Border.all(
                          color: const Color.fromARGB(125, 226, 158, 11),
                          width: 1.25,
                          ),
                        borderRadius: BorderRadius.circular(20.0),
                        onRemove: () {
                          setState(() {
                            selectedFiles.removeAt(index);
                          });
                        },
                      );
                    },
                  ),
          ),
    Padding(
  padding: const EdgeInsets.all(16.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      ElevatedButton.icon(
        onPressed: _isUploading ? null : _pickMultipleFiles,
        icon: _isUploading 
        ? 
        const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
        :
        const Icon(Icons.attach_file, size: 20, color: Colors.white,),
        label: Text(
                          _isUploading ? "Can't Select" : "Select Files",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isUploading ? theme.disabledColor : Colors.orangeAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      ElevatedButton.icon(
        onPressed: _isUploading ? null : _startUploadProcess,
        icon: _isUploading 
        ?
        const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ) 
        :
        const Icon(Icons.cloud_upload, size: 20, color: Colors.white,),
        label: Text(
                          _isUploading ? "Uploading" : "Upload Files",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isUploading ? theme.disabledColor : Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ],
            ),
          )
          ],
          ),
        ),
      ),
      bottomSheet: _isUploading
          ? LinearProgressIndicator(
              // value: _uploadProgress, //  This value Controls the upload progress bar
              backgroundColor: Colors.grey[300],
              minHeight: 4.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              value: uploadProgress,
            )
          : const SizedBox.shrink(), // Hide bottom sheet when not uploading
    );
  }
}