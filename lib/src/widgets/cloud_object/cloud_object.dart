import 'dart:math';

import 'package:flutter/material.dart';
import 'package:minio/models.dart';
import 'package:path/path.dart';

class CloudObject extends StatelessWidget {
  final String fileName;
  final Color? iconColor;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;
  final String? eTag;
  final Owner? owner;
  final int? size;
  final DateTime? lastModified;
  final Border border;
  
  final BorderRadius borderRadius;
  

  const CloudObject({
    super.key,
    required this.fileName,
    required this.eTag,
    required this.owner,
    required this.size,
    required this.lastModified,
    this.iconColor,
    this.onDownload,
    this.onDelete,
    this.border = const Border.fromBorderSide(BorderSide.none),
    this.borderRadius = const BorderRadius.all(Radius.zero)
  });

  void _showFileDetails(BuildContext context) {
    int sizeNorm = 0;
    final size = this.size;
    if(size != null){
      sizeNorm = size.toInt();
    }
    String fileExtension = fileName.split('.').last;

    showDialog(context: context, 
    builder: (BuildContext context) {
      return AlertDialog(
          title: Text(fileName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("eTag: ${eTag ?? 'N/A'}"),
              const SizedBox(height: 10.0,),
              size == null ? Text("N/A") : Text("Size: ${sizeNorm > 1000 ? "${sizeNorm/1000.00}KB" : "$sizeNorm bytes"}"),
              const SizedBox(height: 10.0,),
              Text("File Extension: ${fileExtension ?? 'N/A'}"),
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

                Navigator.of(context).pop();
              },
              child: const Text("Delete", 
                                style: TextStyle(color: Colors.red),),
            ),
            TextButton(
              onPressed: () {

                Navigator.of(context).pop();
              },
              child: const Text("Download", 
                                style: TextStyle(color: Colors.orangeAccent),),
            ),
          ],
        );
    }
    );
  }

 @override
Widget build(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;

  return GestureDetector(
    onTap: () => _showFileDetails(context),
    child: Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Ensures it doesn't take more space than needed
          children: [
            Flexible(child: Icon(Icons.insert_drive_file, size: min(screenWidth * 0.18, 80) , color: iconColor ?? Colors.white70),
            ),
            
            SizedBox(height: min(screenWidth * 0.01, 8)),
             
               Text(
                fileName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: min(screenWidth * 0.05, 20)),
              ),
            
            SizedBox(height: min(screenWidth * 0.02, 6)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.download, color: Colors.green, size: min(screenWidth * 0.12, 60)),
                  onPressed: onDownload,
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red, size: min(screenWidth * 0.12, 60)),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

}