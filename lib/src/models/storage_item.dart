import 'package:minio/models.dart';

enum StorageItemType { file, directory }

class StorageItem {
  final StorageItemType type;
  final String key;
  final Object? fileObject; 

  StorageItem({
    required this.type,
    required this.key,
    this.fileObject
  });
}