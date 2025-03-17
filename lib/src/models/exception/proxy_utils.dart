bool isValidBucketName(String bucket) {
  if (bucket.length < 3 || bucket.length > 63) {
    return false;
  }
  if (bucket.contains('..')) {
    return false;
  }

  if (RegExp(r'[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+').hasMatch(bucket)) {
    return false;
  }

  if (RegExp(r'^[a-z0-9][a-z0-9.-]+[a-z0-9]$').hasMatch(bucket)) {
    return true;
  }

  return false;
}

bool isValidObjectName(String objectName) {
  if (!isValidPrefix(objectName)) return false;
  if (objectName.isEmpty) return false;
  return true;
}

bool isValidPrefix(String prefix) {
  if (prefix.length > 1024) return false;
  return true;
}