import 'package:flutter/material.dart';
import 'dart:math';

class CloudBucket extends StatefulWidget {
  final String bucketName;
  final DateTime? creationDate;
  final bool? isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CloudBucket({
    Key? key,
    required this.bucketName,
    this.creationDate,
    this.isSelected,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  _CloudBucketState createState() => _CloudBucketState();
}

class _CloudBucketState extends State<CloudBucket> {
  bool _isTapped = false;

  void _onTap() {
    setState(() {
      _isTapped = true;
    });
    widget.onTap();
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

    return GestureDetector(
      onTap: _onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _isTapped ? 8 : 0, 0),
        decoration: BoxDecoration(
          color: (widget.isSelected == true) ? Colors.orange[300] : Colors.transparent,
          border: Border.all(color: Colors.orange.shade600, width: 1.5),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.margin,
                size: min(screenWidth * 0.12, 60),
                color: Colors.orange.shade900,
              ),
              const SizedBox(height: 10),
              Text(
                widget.bucketName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: min(screenWidth * 0.05, 20),
                ),
              ),
              Text(
                (widget.creationDate != null) ? "Created At: ${widget.creationDate!.toString()}" : "",
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: min(screenWidth * 0.05, 20),
                ),
              ),
              const SizedBox(height: 10),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: "Delete Bucket",
                iconSize: 30.0,
                highlightColor: Colors.orange[300],
                onPressed: widget.onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}