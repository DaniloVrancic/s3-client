class ProxyStatObjectResult {
  final String? etag;
  final int size;
  final Map<String, dynamic> metaData;
  final DateTime lastModified;
  final String object;

  ProxyStatObjectResult({
    this.etag,
    required this.size,
    required this.metaData,
    required this.lastModified,
    required this.object,
  });

  factory ProxyStatObjectResult.fromJson(Map<String, dynamic> json) {
    return ProxyStatObjectResult(
      etag: json['etag'] as String?,
      size: json['size'] as int,
      metaData: json['metaData'] as Map<String, dynamic>,
      lastModified: DateTime.parse(json['lastModified'] as String),
      object: json['object'] as String,
    );
  }

  @override
  String toString() {
    return 'ProxyStatObjectResult(etag: $etag, size: $size, metaData: $metaData, lastModified: $lastModified, object: $object)';
  }
}