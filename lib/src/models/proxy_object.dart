import 'package:s3_client/src/models/proxy_object_owner.dart';

/// An object consists of data and its descriptive metadata.
class ProxyObject {

    /// The entity tag is an MD5 hash of the object. ETag reflects only changes to the contents of an object, not its metadata.
  String? eTag;

  /// The name that you assign to an object. You use the object key to retrieve the object.
  String? key;

  /// The date the Object was Last Modified
  DateTime? lastModified;

  /// The owner of the object
  Owner? owner;

  /// Size in bytes of the object
  int? size;

  /// The class of storage used to store the object.
  String? storageClass;

  //  The value that signifies if the selected entity is a Directory
  bool? isDir;

  ProxyObject({
    this.eTag,
    this.key,
    this.lastModified,
    this.owner,
    this.size,
    this.storageClass,
    this.isDir,
    }
  );

  factory ProxyObject.fromJSON(Map<String, dynamic> json) {
    return ProxyObject(
      eTag: json['eTag'] as String?,
      key: json['key'],
      storageClass: json['storageClass'],
      lastModified: DateTime.parse(json['lastModified']),
      size: json['size'],
      owner: Owner.fromJSON(json['owner']),
      isDir: json['isDir']
      
      
    );
  }


  @override
  String toString() {
    return 'Object{eTag: $eTag, key: $key, lastModified: $lastModified, owner: $owner, size: $size, storageClass: $storageClass, isDir: $isDir}';
  }
}