import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:s3_client/src/models/proxy_object.dart';

/// A custom client that communicates with your proxy server to perform
/// S3 operations. The methods map to the endpoints defined in your
/// Spring Boot S3Controller.
class ProxyClient {
  /// Constructs a new [ProxyClient].
  ///
  /// [address] is the hostname or IP address of your proxy server.
  /// [port] is optional (default is 80 for HTTP and 443 for HTTPS).
  /// [useSSL] determines if the connection should use HTTPS.
  ProxyClient({
    required address,
    this.port,
    this.useSSL = false,
  }) :
    _address = address;

   // Private variable to store the address.
  String _address;

  // Getter for the address.
  String get address => _address;

  // Setter to allow changing the address at runtime.
  set address(String newAddress) {
    _address = newAddress;
  }

  final int? port;
  final bool useSSL;



  /// Builds the base URL for all proxy endpoints.
  String get baseUrl {
    final scheme = useSSL ? 'https' : 'http';
    final portPart = port != null && port != 80 && port != 443 ? ':$port' : '';
    // All endpoints are under the '/s3' path.
    return '$scheme://$_address$portPart/s3';
  }

  /// Lists all buckets.
  ///
  /// Returns a list of maps, where each map contains bucket information,
  /// for example:
  ///   { "name": "my-bucket", "creationDate": "2021-01-01T12:00:00Z" }
  Future<List<Map<String, String>>> listBuckets() async {
    final url = Uri.parse('$baseUrl/buckets');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      // Cast each item to Map<String, String>
      return jsonList.map((e) => Map<String, String>.from(e)).toList();
    } else {
      throw Exception('Failed to list buckets: ${response.body}');
    }
  }

  /// Lists all objects in the given [bucket]. If a [prefix] is provided,
  /// the result is filtered accordingly.
  Future<List<ProxyObject>> listObjects({
    required String bucket,
    String? prefix,
  }) async {
    final queryParameters = {'bucket': bucket};
    if (prefix != null) {
      queryParameters['prefix'] = prefix;
    }
    final url = Uri.parse('$baseUrl/objects').replace(queryParameters: queryParameters);
   
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      // Decode the response to a List of dynamic objects
      List<dynamic> tempList = json.decode(response.body) as List<dynamic>;

      // Now map each dynamic object to your Minio Object
      // Assuming Object is a Minio Object and can be created from Map<String, dynamic>
      List<ProxyObject> objects = tempList.map((e) => ProxyObject.fromJSON(e as Map<String, dynamic>)).toList();

      
      return objects;
    } else {
      throw Exception('Failed to list objects: ${response.body}');
    }
  }

  /// Uploads a file to the specified [bucket] with the given [objectName].
  ///
  /// The file is uploaded using a multipart/form-data request.
  /// On success, it returns the response string from the proxy server.
  Future<String> uploadFile({
    required String bucket,
    required String objectName,
    required File file,
  }) async {
    // Build the URL with query parameters.
    final url = Uri.parse('$baseUrl/upload?bucket=$bucket&objectName=$objectName');

    // Create a multipart request for PUT.
    final request = http.MultipartRequest('PUT', url);
    // Attach the file as a multipart field named "file" (as expected by your controller).
    final fileStream = http.ByteStream(file.openRead());
    final length = await file.length();
    final multipartFile = http.MultipartFile(
      'file',
      fileStream,
      length,
      filename: file.uri.pathSegments.last,
    );
    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to upload file: ${response.body}');
    }
  }

  /// Uploads a file to the specified [bucket] with the given [objectName].
  /// The file data is read from the [stream] with the given byte [length]
  /// The file is uploaded using a multipart/form-data request.
  /// On success, it returns the response string from the proxy server.
 Future<void> putObject(
  String bucket,
  String object,
  Stream<Uint8List> data, {
  int? size,
  int? chunkSize,
  Map<String, String>? metadata,
  void Function(int)? onProgress, // Keep onProgress callback as void
}) async {
  final url = Uri.parse('$baseUrl/upload?bucket=$bucket&objectName=$object');
  
  // Create a MultipartRequest for the file upload
  final request = http.MultipartRequest('PUT', url);

  // Add metadata if provided as headers
  metadata?.forEach((key, value) {
    request.headers[key] = value;
  });

  // Create a multipart file from the stream of data
  request.files.add(http.MultipartFile(
    'file', // This should match the name in the Spring Boot controller (@RequestParam("file"))
    data,
    size ?? 0, // Size of the file, optional
    filename: object, // Provide the filename here
  ));

  // Optionally track progress if the onProgress callback is provided
  int bytesSent = 0;
  final monitoredStream = data.map((chunk) {
    bytesSent += chunk.length;
    if (onProgress != null) {
      onProgress(bytesSent);  // Call the onProgress with updated bytesSent
    }
    return chunk;
  });

  // Send the file as a stream with the content length if provided
  request.files[0] = http.MultipartFile(
    'file',
    monitoredStream,
    size ?? 0,
    filename: object,
  );

  // Perform the actual upload
  final streamedResponse = await request.send();

  // Check for the response
  final response = await http.Response.fromStream(streamedResponse);
  if (response.statusCode == 200) {
    print('File uploaded successfully');
  } else {
    throw Exception('Failed to upload object: ${response.statusCode}');
  }
}

  /// Downloads a file from the specified [bucket] with the given [object] name.
  ///
  /// Returns a [http.StreamedResponse] that provides access to the file's byte stream.
  Future<http.StreamedResponse> downloadFile({
    required String bucket,
    required String object,
  }) async {
    final url = Uri.parse('$baseUrl/download?bucket=$bucket&object=$object');
    final request = http.Request('GET', url);
    final streamedResponse = await request.send();
    if (streamedResponse.statusCode == 200) {
      return streamedResponse;
    } else {
      throw Exception('Failed to download file: status ${streamedResponse.statusCode}');
    }
  }

  /// Deletes a file from the specified [bucket] with the given [object] name.
  ///
  /// Returns a string message from the proxy server.
  Future<String> deleteFile({
    required String bucket,
    required String object,
  }) async {
    final url = Uri.parse('$baseUrl/object?bucket=$bucket&object=$object');
    final response = await http.delete(url);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to delete file: ${response.body}');
    }
  }

  /// Checks whether the specified [bucket] exists.
  ///
  /// Returns `true` if it exists, or `false` if not.
  Future<bool> bucketExists({
    required String bucket,
  }) async {
    final url = Uri.parse('$baseUrl/bucket/exists?bucket=$bucket');
    final response = await http.get(url);
    // The proxy returns 200 with {"exists": true} or 404 with {"exists": false}.
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['exists'] == true;
    } else if (response.statusCode == 404) {
      return false;
    } else {
      throw Exception('Failed to check bucket existence: ${response.body}');
    }
  }

  /// Creates a new bucket with the given [bucket] name.
  ///
  /// Returns a success message or error message from the proxy.
  Future<String> makeBucket({
    required String bucket,
  }) async {
    final url = Uri.parse('$baseUrl/bucket?bucket=$bucket');
    final response = await http.put(url);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to create bucket: ${response.body}');
    }
  }

  /// Gets a presigned GET URL for the object in the specified [bucket].
  ///
  /// Returns the URL as a string.
  Future<String> getPresignedGetUrl({
    required String bucket,
    required String object,
  }) async {
    final url = Uri.parse('$baseUrl/presigned_get?bucket=$bucket&object=$object');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to get presigned GET URL: ${response.body}');
    }
  }

  /// Gets a presigned PUT URL for the object in the specified [bucket].
  ///
  /// Returns the URL as a string.
  Future<String> getPresignedPutUrl({
    required String bucket,
    required String object,
  }) async {
    final url = Uri.parse('$baseUrl/presigned_put?bucket=$bucket&object=$object');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to get presigned PUT URL: ${response.body}');
    }
  }
}