import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';


class AwsSignatureV4Factory {
  final String _keyID;
  final String _applicationKey;
  final String _region;
  final String _service;

  AwsSignatureV4Factory(this._keyID, this._applicationKey, this._region, this._service);

  String getRegion(){
    return _region;
  }

  String getAuthorizationHeader(
    {
      required String method,
      required String endpoint,
      required String path,
      required Map<String, String> headers,
      required Map<String, String> queryParameters,
      required String payload
    }
  ){
    final now = DateTime.now().toUtc();
    final amazonDate = DateFormat('yyyyMMddTHHmmssZ').format(now);
    final dateStamp = DateFormat('yyyyMMdd').format(now);


    //Step 1: Create the Canonical Request that will define the methods and ways to execute 
    final canonicalRequest = _createCanonicalRequest(
      method: method,
      path: path,
      queryParameters: queryParameters,
      headers: headers,
      payload: payload,
    );

    // Step 2: Create string to sign
    final stringToSign = _createStringToSign(
      amzDate: amazonDate,
      dateStamp: dateStamp,
      canonicalRequest: canonicalRequest,
    );

    // Step 3: Calculate signature
    final signature = _calculateSignature(
      dateStamp: dateStamp,
      stringToSign: stringToSign,
    );

    // Step 4: Construct Authorization Header out of all calculated values
    final credentialScope = '$dateStamp/$_region/$_service/aws4_request';
    return 'AWS4-HMAC-SHA256 '
        'Credential=$_keyID/$credentialScope, '
        'SignedHeaders=${_getSignedHeaders(headers)}, '
        'Signature=$signature';
  }

  String _createCanonicalRequest(
    {
      required String method,
      required String path,
      required Map<String, String> queryParameters,
      required Map<String, String> headers,
      required String payload
    }
  ) {
    final canonicalHeaders = queryParameters.entries
    .map((e) => '${e.key.toLowerCase()}:${e.value.trim()}')
    .toList()
    ..sort(); // Sorts original List

    final signedHeaders = canonicalHeaders.map((header) => header.split(':')[0]).join(';');

    final queryString = queryParameters.entries
    .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
    .toList()
    ..sort();

    final canonicalQueryString = queryString.join('&');

    final payloadHash = sha256.convert(utf8.encode(payload)).toString();

    return [
      method,
      path,
      canonicalQueryString,
      canonicalHeaders.join('\n'),
      '', // Empty line (required by AWS Signature V4)
      signedHeaders,
      payloadHash
    ].join('\n');
    
  }

    String _createStringToSign({
    required String amzDate,
    required String dateStamp,
    required String canonicalRequest,
  }) {
    final credentialScope = '$dateStamp/$_region/$_service/aws4_request';
    final canonicalRequestHash = sha256.convert(utf8.encode(canonicalRequest)).toString();

    return [
      'AWS4-HMAC-SHA256',
      amzDate,
      credentialScope,
      canonicalRequestHash,
    ].join('\n');
  }

    String _calculateSignature({
    required String dateStamp,
    required String stringToSign,
  }) {
    final kDate = _hmacSha256(utf8.encode('AWS4$_applicationKey'), utf8.encode(dateStamp));
    final kRegion = _hmacSha256(kDate, utf8.encode(_region));
    final kService = _hmacSha256(kRegion, utf8.encode(_service));
    final kSigning = _hmacSha256(kService, utf8.encode('aws4_request'));

    return _hmacSha256(kSigning, utf8.encode(stringToSign)).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

    Uint8List _hmacSha256(Uint8List key, List<int> data) {
      final hmac = Hmac(sha256, key);
      return Uint8List.fromList(hmac.convert(data).bytes);
  }

  // Get Signed Headers
  String _getSignedHeaders(Map<String, String> headers) {
    final tempString = headers.keys.map((key) => key.toLowerCase()).toList()..sort();
    return tempString.join(';');
  }


}