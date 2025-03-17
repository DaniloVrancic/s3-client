import 'package:s3_client/src/models/exception/proxy_utils.dart';

class ProxyError implements Exception {
  ProxyError(this.message);

  final String? message;

  @override
  String toString() {
    return 'MinioError: $message';
  }
}

class MinioAnonymousRequestError extends ProxyError {
  MinioAnonymousRequestError(super.message);
}

class MinioInvalidArgumentError extends ProxyError {
  MinioInvalidArgumentError(super.message);
}

class MinioInvalidPortError extends ProxyError {
  MinioInvalidPortError(super.message);
}

class MinioInvalidEndpointError extends ProxyError {
  MinioInvalidEndpointError(super.message);
}

class MinioInvalidBucketNameError extends ProxyError {
  MinioInvalidBucketNameError(super.message);

  static void check(String bucket) {
    if (isValidBucketName(bucket)) return;
    throw MinioInvalidBucketNameError('Invalid bucket name: $bucket');
  }
}

class MinioInvalidObjectNameError extends ProxyError {
  MinioInvalidObjectNameError(super.message);

  static void check(String object) {
    if (isValidObjectName(object)) return;
    throw MinioInvalidObjectNameError('Invalid object name: $object');
  }
}

class MinioAccessKeyRequiredError extends ProxyError {
  MinioAccessKeyRequiredError(super.message);
}

class MinioSecretKeyRequiredError extends ProxyError {
  MinioSecretKeyRequiredError(super.message);
}

class MinioExpiresParamError extends ProxyError {
  MinioExpiresParamError(super.message);
}

class MinioInvalidDateError extends ProxyError {
  MinioInvalidDateError(super.message);
}

class MinioInvalidPrefixError extends ProxyError {
  MinioInvalidPrefixError(super.message);

  static void check(String prefix) {
    if (isValidPrefix(prefix)) return;
    throw MinioInvalidPrefixError('Invalid prefix: $prefix');
  }
}

class MinioInvalidBucketPolicyError extends ProxyError {
  MinioInvalidBucketPolicyError(super.message);
}

class MinioIncorrectSizeError extends ProxyError {
  MinioIncorrectSizeError(super.message);
}

class MinioInvalidXMLError extends ProxyError {
  MinioInvalidXMLError(super.message);
}
