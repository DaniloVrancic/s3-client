import 'package:flutter/material.dart';
import 'package:minio/models.dart';

class BucketNotifier extends ChangeNotifier {
  Bucket _selectedBucket = Bucket(DateTime.now(), "");

  Bucket get selectedBucket => _selectedBucket;

  void setBucket(Bucket newBucket) {
    _selectedBucket = newBucket;
    notifyListeners(); 
  }
}