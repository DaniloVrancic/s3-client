import 'package:flutter/material.dart';

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
  bool _isSelected = false;

  void _onTap() {
    setState(() {
      _isSelected = !_isSelected;
    });
    widget.onClick?.call();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: _onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isSelected ? 4 : 0, 0),
        decoration: BoxDecoration(
          color: _isSelected ? Colors.orangeAccent.withValues(alpha: 0.6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (_isSelected)
              BoxShadow(
                color: Colors.orangeAccent.withValues(alpha: 0.6),
                blurRadius: 10,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: widget.onDelete,
                  ),
                ),
                Icon(
                  Icons.folder,
                  size: screenWidth * 0.15,
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
                    fontSize: screenWidth * 0.05,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}