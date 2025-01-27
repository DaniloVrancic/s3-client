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
              Text("Size: ${(file.size) > 1000 ? "${file.size.toDouble()/1000.00}kB" : "${file.size} bytes"}"),
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
              child: const Text("Remove"),
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
      preview = Image.file(
        File(file.path!),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } else if (file.extension != null && ['mp4', 'mov', 'avi'].contains(file.extension!.toLowerCase())) {
      preview = const Icon(Icons.video_file, size: 100, color: Colors.blue);
    } else {
      preview = const Icon(Icons.insert_drive_file, size: 100, color: Colors.grey);
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