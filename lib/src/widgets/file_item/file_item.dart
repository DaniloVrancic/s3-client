import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileItem extends StatefulWidget {
  final PlatformFile file;
  final VoidCallback onRemove;
  final Border border;
  final BorderRadius borderRadius;

  const FileItem({
    super.key,
    required this.file,
    required this.onRemove,
    this.border = const Border.fromBorderSide(BorderSide.none),
    this.borderRadius = const BorderRadius.all(Radius.zero),
  });

  @override
  State<FileItem> createState() => _FileItemState();
}

class _FileItemState extends State<FileItem> {
  bool _isPressed = false;


  void _showFileDetails(BuildContext context) {
  int sizeNorm = widget.file.size; 
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.file.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("File Path: ${widget.file.path ?? 'N/A'}"),
              const SizedBox(height: 10.0),
              Text("Size: ${sizeNorm > 1000000 ? "${(sizeNorm / 1000000.0).toStringAsFixed(2)}MB" : sizeNorm > 1000 ? "${(sizeNorm / 1000.0).toStringAsFixed(2)}KB" : "$sizeNorm bytes"}"),
              const SizedBox(height: 10.0),
              Text("File Extension: ${widget.file.extension ?? 'N/A'}"),
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
                widget.onRemove();
                Navigator.of(context).pop();
              },
              child: const Text(
                "Remove",
                style: TextStyle(color: Colors.orangeAccent),
              ),
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

    //Get theme
    ThemeData theme = Theme.of(context);
    if (widget.file.extension != null && ['jpg', 'jpeg', 'png', 'gif'].contains(widget.file.extension!.toLowerCase())) {
      preview = Container(
        margin: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 5.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orangeAccent, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          borderRadius: BorderRadius.circular(20), // Must match the Container's radius
          child: Image.file(
            File(widget.file.path!),
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (widget.file.extension != null && ['mp4', 'mov', 'avi'].contains(widget.file.extension!.toLowerCase())) {
      preview = const Padding(
        padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
        child: Icon(Icons.video_file, size: 100, color: Colors.blue),
      );
    } else {
      preview = Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
        child: Icon(Icons.insert_drive_file, size: 100, color: Colors.orange.shade300),
      );
    }

    return GestureDetector(
      onTap: () => _showFileDetails(context),
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: _isPressed ? Matrix4.translationValues(0, 10, 0) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: widget.border,
          borderRadius: widget.borderRadius,
          boxShadow: [
            BoxShadow(
              color: theme.dividerColor,
              blurRadius: _isPressed ? 4.0 : 10.0,
              offset: Offset(0, _isPressed ? 1.0 : 4.0),
            ),
          ],
        ),
        child: InkWell(
          splashColor: Colors.orangeAccent.withValues(alpha: 0.6),
          borderRadius: widget.borderRadius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              preview,
              const SizedBox(height: 8.0),
              Text(
                widget.file.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(fontSize: 12.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
