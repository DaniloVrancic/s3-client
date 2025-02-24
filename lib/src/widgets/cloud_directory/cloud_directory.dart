import 'package:flutter/material.dart';
import 'dart:math';

class CloudDirectory extends StatefulWidget {
  final String fileName;
  final Color? iconColor;
  final VoidCallback? onClick;
  final VoidCallback? onDelete;

  const CloudDirectory({
    super.key,
    required this.fileName,
    this.iconColor,
    this.onClick,
    this.onDelete,
  });

  @override
  State<CloudDirectory> createState() => _CloudDirectoryState();
}

class _CloudDirectoryState extends State<CloudDirectory> {
  bool _isTapped = false;

  void _onTap() {
    setState(() {
      _isTapped = true;
    });
    widget.onClick?.call();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isTapped = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Use the same border as CloudObject:
    final border = Border.all(
      color: const Color.fromARGB(125, 226, 158, 11),
      width: 1.25,
    );
    final borderRadius = BorderRadius.circular(20.0);

    return GestureDetector(
      onTap: _onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isTapped ? 8 : 0, 0),
        decoration: BoxDecoration(
          
          border: border,
          borderRadius: borderRadius,
          // Optionally, you can have a subtle shadow when tapped:
          boxShadow: _isTapped
              ? [
                  BoxShadow(
                    color: Colors.orangeAccent.withValues(alpha: 0.6),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder,
                size: min(screenWidth * 0.15, 80),
                color: widget.iconColor ?? Colors.orangeAccent,
              ),
              const SizedBox(height: 10),
              Text(
                widget.fileName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: min(screenWidth * 0.05, 24),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: widget.onDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
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
