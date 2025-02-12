import 'dart:math';
import 'package:flutter/material.dart';
import 'package:minio/models.dart';

class CloudObject extends StatefulWidget {
  final String fileName;
  final Color? iconColor;
  /// Change onDownload to a Future-returning function so CloudObject can await it.
  final Future<void> Function()? onDownload;
  final VoidCallback? onDelete;
  final String? eTag;
  final Owner? owner;
  final int? size;
  final DateTime? lastModified;
  final Border border;
  final BorderRadius borderRadius;
  final CloudObjectController? controller; // Optional controller

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
    this.controller,
    this.border = const Border.fromBorderSide(BorderSide.none),
    this.borderRadius = const BorderRadius.all(Radius.zero),
  });

  @override
  State<CloudObject> createState() => _CloudObjectState();
}

class _CloudObjectState extends State<CloudObject> {
  bool _isTapped = false;
  bool _isDownloading = false;

  double _downloadProgress = 0.0;               //These values are here if we want to control the linear progress bar (make it determinate)
  late final CloudObjectController _controller; //Controller for updating the progress bar

    @override
  void initState() {
    super.initState();
    // Use the passed controller or create a new one if null.
    _controller = widget.controller ?? CloudObjectController();
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    setState(() {
      _downloadProgress = _controller.progress;
    });
  }

   @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }


  /// This method wraps the download function passed from the parent.
  Future<void> _handleDownload() async {
    if (widget.onDownload == null) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      // Await the asynchronous download function.
      await widget.onDownload!();
    } catch (e) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    } finally {
      // Remove the spinner.
        if(mounted){
      setState(() {
          _isDownloading = false;
        _downloadProgress = 0.0;
        _controller.updateProgress(0.0);
      });
        }
    }
  }

  void _onTap() {
    setState(() {
      _isTapped = !_isTapped;
    });

    // Reset tap animation after a short delay.
    Future.delayed(const Duration(milliseconds: 120), () {
      setState(() {
        _isTapped = false;
      });
    });

    _showFileDetails(context);
  }

  void _showFileDetails(BuildContext context) {
    int sizeNorm = widget.size ?? 0;
    String fileExtension = widget.fileName.split('.').last;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.fileName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("eTag: ${widget.eTag ?? 'N/A'}"),
              const SizedBox(height: 10.0),
              widget.size == null
                  ? const Text("N/A")
                  : Text(
                      "Size: ${sizeNorm > 1000 ? "${(sizeNorm / 1000.0).toStringAsFixed(2)}KB" : "$sizeNorm bytes"}"),
              const SizedBox(height: 10.0),
              Text("File Extension: ${fileExtension.isNotEmpty ? fileExtension : "N/A"}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (widget.onDelete != null) {
                  widget.onDelete!();
                }
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (!_isDownloading) {
                  _handleDownload();
                }
              },
              child: const Text("Download", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Choose an icon based on the file extension.
    Widget preview;
    String fileExtension = widget.fileName.split(".").last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension)) {
      preview = Icon(Icons.photo,
          size: min(screenWidth * 0.15, 80),
          color: widget.iconColor ?? Colors.orangeAccent);
    } else if (['mp4', 'mov', 'avi'].contains(fileExtension)) {
      preview = Icon(Icons.video_file,
          size: min(screenWidth * 0.15, 80),
          color: widget.iconColor ?? Colors.orangeAccent);
    } else {
      preview = Icon(Icons.insert_drive_file,
          size: min(screenWidth * 0.15, 80),
          color: widget.iconColor ?? Colors.orangeAccent);
    }

    return GestureDetector(
      onTap: _onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isTapped ? 8 : 0, 0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: _onTap,
            splashColor: Colors.orangeAccent.withAlpha(60),
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Optionally, show a loading bar when downloading.
                  if (_isDownloading)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: LinearProgressIndicator(
                        value: _downloadProgress > 0.0 ? _downloadProgress : null,
                        minHeight: 4,
                        backgroundColor: Colors.grey,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                      ),
                    ),
                  Flexible(child: preview),
                  const SizedBox(height: 10),
                  Text(
                    widget.fileName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: min(screenWidth * 0.05, 18)),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        // Show spinner in button when downloading.
                        icon: _isDownloading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.download, color: Colors.white),
                        label: Text(
                          _isDownloading ? "Downloading" : "Download",
                          style: const TextStyle(color: Colors.white),
                        ),
                        onPressed: _isDownloading ? null : _handleDownload,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text("Delete", style: TextStyle(color: Colors.white)),
                        onPressed: widget.onDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

class CloudObjectController extends ChangeNotifier {
  double _progress = 0.0;
  
  /// The current download progress (from 0.0 to 1.0)
  double get progress => _progress;
  
  /// Call this method to update progress.  
  /// For a value of 0.0, the progress indicator will be indeterminate.
  void updateProgress(double progress) {
    _progress = progress;
    notifyListeners();
  }
}
