import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:minio/models.dart';

class CloudObject extends StatefulWidget {
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
    this.borderRadius = const BorderRadius.all(Radius.zero),
  });

  @override
  // ignore: library_private_types_in_public_api
  State<CloudObject> createState() => _CloudObjectState();
}

class _CloudObjectState extends State<CloudObject> {
  bool _isTapped = false;
  bool _isDownloading = false;

  Future<void> _downloadFile() async { //TODO: Define this method in the HomePage, not here, move the logic from here there, and also implement the loading logic here.
    
    //Open file picker to select download location

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Select Download Directory",
      lockParentWindow: true // Works only for Windows
    );

    if (selectedDirectory == null) {
      // User canceled the picker
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try{
      //var fileData = await _b2service.downloadFile(widget.fileName);
    }
    catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download Failed: $e')));
    }
    finally {
      setState(() {
      _isDownloading = false;
    });
    }

    print(selectedDirectory);
  }

  void _onTap() {
    setState(() {
      _isTapped = !_isTapped; // Toggle the movement on tap
    });
    
    // Reset the position after a short delay
    Future.delayed(const Duration(milliseconds: 120), () {
      setState(() {
        _isTapped = false;
      });
      
    });

    _showFileDetails(context);
    
  }

  void _showFileDetails(BuildContext context) {
    int sizeNorm = 0;
    final size = widget.size;
    if(size != null){
      sizeNorm = size.toInt();
    }
    String fileExtension = widget.fileName.split('.').last;

    showDialog(context: context, 
    builder: (BuildContext context) {
      return AlertDialog(
          title: Text(widget.fileName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("eTag: ${widget.eTag ?? 'N/A'}"),
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
                                style: TextStyle(color: Colors.green),),
            ),
          ],
        );
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    Widget preview;
    String fileExtension = widget.fileName.split(".").last;

    if (['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension.toLowerCase())) {
      preview = Icon(Icons.photo, size: min(screenWidth * 0.15, 80), color: widget.iconColor ?? Colors.white70);
    } else if (['mp4', 'mov', 'avi'].contains(fileExtension.toLowerCase())) {
      preview = Icon(Icons.video_file, size: min(screenWidth * 0.15, 80), color: widget.iconColor ?? Colors.white70);
    } else {
      preview = Icon(Icons.insert_drive_file, size: min(screenWidth * 0.15, 80), color: widget.iconColor ?? Colors.white70);
    }

    return GestureDetector(
      onTap: _onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isTapped ? 20 : 0, 0), // Moves the card down slightly

        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: InkWell(
            onTap: () => _onTap(),
            splashColor: Colors.orangeAccent.withOpacity(0.4),
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(10), // Ensures ripple effect follows shape
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: preview),
                  SizedBox(height: min(screenWidth * 0.01, 8)),
                  Text(
                    widget.fileName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: min(screenWidth * 0.05, 20)),
                  ),
                  const Divider(),
                  SizedBox(height: min(screenWidth * 0.02, 6)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.green, width: 1.5)),
                        child: IconButton(
                          icon: Icon(Icons.download, color: Colors.green, size: min(screenWidth * 0.10, 60)),
                          onPressed: _isDownloading ? null : _downloadFile,
                          tooltip: "Download",
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.red, width: 1.5)),
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red, size: min(screenWidth * 0.10, 60)),
                          onPressed: widget.onDelete,
                          tooltip: "Delete",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
