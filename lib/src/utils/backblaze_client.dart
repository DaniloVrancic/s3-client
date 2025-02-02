// S3Service class utilizing AWSSignatureV4Factory
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:s3_client/src/utils/aws_signature_v4_factory.dart';

class S3Service {
  final AwsSignatureV4Factory _signer;

  final String _provider;
  String _endpoint = ""; // e.g., 'https://s3.<yourprovider>.com'

  S3Service(this._signer, this._provider)
  {
    _endpoint ="https://s3.${_signer.getRegion()}.$_provider.com";
  }

  Future<String> createBucket(String bucketName) async {
    final method = 'PUT';
    final path = '/$bucketName';
    final headers = {
      'Host': _endpoint,
      'X-Amz-Date': DateFormat('yyyyMMddTHHmmssZ').format(DateTime.now().toUtc()),
      };

    final authHeader = _signer.getAuthorizationHeader(
      method: method,
      endpoint: _endpoint,
      path: path,
      headers: headers,
      queryParameters: {},
      payload: '',
    );

    headers['Authorization'] = authHeader;

    final response = await http.put(Uri.parse('$_endpoint$path'), headers: headers);
    return response.statusCode == 200 ? 'Bucket created' : response.body;
  }

  Future<String> deleteBucket(String bucketName) async {
    final method = 'DELETE';
    final path = '/$bucketName';
    final headers = {
      'Host': _endpoint,
      'X-Amz-Date': DateFormat('yyyyMMddTHHmmssZ').format(DateTime.now().toUtc()),
      };

    final authHeader = _signer.getAuthorizationHeader(
      method: method,
      endpoint: _endpoint,
      path: path,
      headers: headers,
      queryParameters: {},
      payload: '',
    );

    headers['Authorization'] = authHeader;

    final response = await http.delete(Uri.parse('$_endpoint$path'), headers: headers);
    return response.statusCode == 204 ? 'Bucket deleted' : response.body;
  }

  Future<String> listObjects(String bucketName) async {
    final method = 'GET';
    final path = '/$bucketName';
    final headers = {
      'Host': _endpoint,
      'X-Amz-Date': DateFormat('yyyyMMddTHHmmssZ').format(DateTime.now().toUtc()),
      };

    final authHeader = _signer.getAuthorizationHeader(
      method: method,
      endpoint: _endpoint,
      path: path,
      headers: headers,
      queryParameters: {},
      payload: '',
    );

    headers['Authorization'] = authHeader;

    final response = await http.get(Uri.parse('$_endpoint$path'), headers: headers);
    return response.statusCode == 200 ? response.body : 'Error: ${response.body}';
  }

  Future<String> readObject(String bucketName, String objectKey) async {
    final method = 'GET';
    final path = '/$bucketName/$objectKey';
    final headers = {
      'Host': _endpoint,
      'X-Amz-Date': DateFormat('yyyyMMddTHHmmssZ').format(DateTime.now().toUtc()),
      //Optional: "x-amz-expected-bucket-owner": [accountID of the bucket owner]
      };

    final authHeader = _signer.getAuthorizationHeader(
      method: method,
      endpoint: _endpoint,
      path: path,
      headers: headers,
      queryParameters: {},
      payload: '',
    );

    headers['Authorization'] = authHeader;

    final response = await http.get(Uri.parse('$_endpoint$path'), headers: headers);
    return response.statusCode == 200 ? response.body : 'Error: ${response.body}';
  }
}

// Usage example:
// final s3Service = S3Service(awsSigner, 'https://s3.<custom-provider>.com');
// (await s3Service.createBucket('my-new-bucket'));
