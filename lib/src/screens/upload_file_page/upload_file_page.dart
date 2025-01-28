import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:s3_client/src/widgets/file_item/file_item.dart';

class UploadFilePage extends StatefulWidget {
  const UploadFilePage({super.key});

  @override
  State<UploadFilePage> createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {

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
                ElevatedButton(
                  onPressed: _pickMultipleFiles,
                  
                  style: ElevatedButton.styleFrom(
                     side: const BorderSide(width: 1.25, color: Color.fromARGB(125, 0, 0, 0)),
                    backgroundColor: const Color.fromARGB(255, 250, 150, 20),
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 24.0),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                  child: const Text("Select Files"),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 24.0),
                    side: const BorderSide(width: 1.25, color: Color.fromARGB(125, 0, 0, 0)),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.0,
                    ),
                  ),
                  child: const Text("Upload Files"),
                ),
              ],
            ),
          ),
          ],
          ),
        ),
      ),
    );
  }
}