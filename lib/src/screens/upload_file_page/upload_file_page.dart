import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:s3_client/src/widgets/file_item/file_item.dart';

class UploadFilePage extends StatefulWidget {
  const UploadFilePage({super.key});

  @override
  State<UploadFilePage> createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {

  bool _isLoading = false;

  String selectedPaths = "";
  List<PlatformFile> selectedFiles = List.empty();

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
        onPressed: _isLoading ? null : _pickMultipleFiles,
        icon: _isLoading 
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
                          _isLoading ? "Can't Select" : "Select Files",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isLoading ? theme.disabledColor : Colors.orangeAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      ElevatedButton.icon(
        onPressed: _isLoading ? null : () {
          setState(() { //TODO: Move this logic into the function that will be called (The upload function, also add a Linear progress bar for all the files selected and uploaded)
            _isLoading = true;
          });
        },
        icon: _isLoading 
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
                          _isLoading ? "Uploading" : "Upload Files",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isLoading ? theme.disabledColor : Colors.teal,
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
    );
  }
}