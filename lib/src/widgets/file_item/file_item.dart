import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileItem extends StatelessWidget {
  final PlatformFile file;
  final VoidCallback onRemove;
  final Border border;
  final BorderRadius borderRadius;

  const FileItem({
    super.key, 
    required this.file, 
    required this.onRemove, 
    this.border = const Border.fromBorderSide(BorderSide.none),
    this.borderRadius = const BorderRadius.all(Radius.zero)
    });
    

  void _showFileDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(file.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("File Path: ${file.path ?? 'N/A'}"),
              const SizedBox(height: 10.0,),
              Text("Size: ${(file.size) > 1000 ? "${file.size.toDouble()/1000.00}KB" : "${file.size} bytes"}"),
              const SizedBox(height: 10.0,),
              Text("File Extension: ${file.extension ?? 'N/A'}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
            TextButton(
              onPressed: () {
                onRemove();
                Navigator.of(context).pop();
              },
              child: const Text("Remove", 
                                style: TextStyle(color: Colors.orangeAccent),),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the file is an image, video, or other file type for preview
    Widget preview;
    if (file.extension != null && ['jpg', 'jpeg', 'png', 'gif'].contains(file.extension!.toLowerCase())) {
      preview = Container(
        margin: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 5.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orangeAccent, width: 1.5),
          borderRadius: BorderRadius.circular(20),
                ),
          child: ClipRRect(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            borderRadius: BorderRadius.circular(20), // Must match the Container's radius
            child: Image.file(
              File(file.path!),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        );
    } else if (file.extension != null && ['mp4', 'mov', 'avi'].contains(file.extension!.toLowerCase())) {
      preview = Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 5.0),
        child: const Icon(Icons.video_file, size: 100, color: Colors.blue),
      );
    } else {
      preview = Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 5.0),
        child: Icon(Icons.insert_drive_file, size: 100, color: Colors.orange.shade300),
      );
    }

    return GestureDetector(
      onTap: () => _showFileDetails(context),
      child: Container(
        decoration: BoxDecoration(
          border: border,
          borderRadius: borderRadius
        ),
        child: Column(
        children: [
          preview,
          const SizedBox(height: 8.0),
          Text(
            file.name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontSize: 12.0),
          ),
        ],
      ),
      )
    );
  }
}