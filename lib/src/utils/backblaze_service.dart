// ignore_for_file: prefer_final_fields, avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:s3_client/src/models/exception/proxy_errors.dart';
import 'package:s3_client/src/models/proxy_object.dart';
import 'package:s3_client/src/models/proxy_stat_object_result.dart';
import 'package:s3_client/src/utils/proxy_client.dart';

class BackblazeService {

  // FOR REMOVAL !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  String keyId = "YOUR_KEY_ID";
  String applicationKey = "YOUR_APPLICATION_KEY";
  String region = "YOUR_REGION";
  String proxyAddress = "YOUR_PROXY_SERVER_ADDRESS";
  int? proxyPort = null;
  // FOR REMOVAL !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  String? _userbaseBucket = "YOUR_BUCKET";
  String? _userbaseObject = "YOUR_OBJECT";

  
  
  // FOR REMOVAL !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  //  final Minio minio;
  // FOR REMOVAL !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  final ProxyClient proxyClient;

  BackblazeService(
    {
      required this.keyId, 
      required this.applicationKey, 
      required this.region, 
      required this.proxyAddress,
      required this.proxyPort,
      required userbaseBucket, 
      required userbaseObject,

    }) 
      :
      _userbaseBucket = userbaseBucket,
      _userbaseObject = userbaseObject, 
      /*
      minio = Minio(
        endPoint: "s3.$region.backblazeb2.com",
        accessKey: keyId,
        secretKey: applicationKey,
        region: region,
        useSSL: true
      ),
      */
      proxyClient = ProxyClient(address: proxyAddress, port: proxyPort);
  
  String get userbaseBucket => _userbaseBucket ?? "a---user-repository";
  String get userbaseObject => _userbaseObject ?? "a---user-repository";

  updateProxyAddress(String newProxyAddress, {int? newPort})
  {
      proxyAddress = newProxyAddress;
      proxyClient.address = newProxyAddress;
      proxyClient.port = newPort;
      proxyPort = newPort;    
    
  }
    
  Future<List<String>> fetchUserbase() async {

    try {
    // Get the streamed response from the proxy client
    final stream = _userbaseBucket != null && _userbaseObject != null
        ? await proxyClient.downloadFile(
            bucket: _userbaseBucket.toString(),
            object: _userbaseObject.toString(),
          )
        : await proxyClient.downloadFile(
            bucket: "a---user-repository",
            object: "my_userbase.csv",
          );

    // Use the stream property of the response to fold the byte chunks into a single string
    var content = await stream.fold<String>(
      "",
      (String prev, List<int> element) => prev + utf8.decode(element),
    );

    // Split content by newlines
    final List<String> result = content.isNotEmpty ? content.split("\n") : [];

    // Process each line
    List<String> processedLines = [];
    for (String line in result) {
      // Split each line by comma, trim each token, and rejoin the tokens with commas
      List<String> tokens = line.split(",").map((token) => token.trim()).toList();
      processedLines.add(tokens.join(","));
    }
    return processedLines;
  } catch (e) {
    print("Error fetching userbase: $e");
    return [];
    }
  }

  Future<List<ProxyObject>> fetchAllObjectsFromBucket(String bucketName, {String prefix = ""}) async {

    List<ProxyObject> listOfObjects = await proxyClient.listObjects(bucket: bucketName, prefix: prefix);
      return listOfObjects;
  }

  Future<List<ProxyObject>> fetchAllObjects(String bucketName) async {

    return await fetchAllObjectsFromBucket(bucketName, prefix: "");
  }

   /// Uploads a new version of the user database, the List has a user in each line
  Future<bool> uploadNewDatabase(List<String> updatedUserList) async {
    try {
      if (_userbaseBucket == null || _userbaseObject == null) {
        throw Exception("Bucket or object name not set");
      }

      String newUserData = updatedUserList.join("\n");

      /*
      await minio.putObject(
        _userbaseBucket!,
        _userbaseObject!,
        Stream.value(utf8.encode(newUserData)),
        metadata: {'Content-Type': 'text/csv'},
      );
      */
      await proxyClient.putObject(
        _userbaseBucket!,
        _userbaseObject!,
        Stream.value(utf8.encode(newUserData)),
        metadata: {'Content-Type': 'text/csv'},
      );

      

      print("User database updated successfully.");
      return true;
    } catch (e) {
      print("Error updating user database: $e");
      return false;
    }
  }

  /// Uploads a specified file to a bucket
  Future<bool> uploadFile(String filePath, String bucket, String objectName) async {
    try {
      File file = File(filePath);
      if (!file.existsSync()) {
        throw Exception("File does not exist: $filePath");
      }

      int fileSize = await file.length();
      Stream<Uint8List> fileStream = file.openRead().map((chunk) => Uint8List.fromList(chunk));
      /*
      await minio.putObject(
        bucket,
        objectName,
        fileStream,
        size: fileSize,
        metadata: {'Content-Type': 'application/octet-stream'},
      );
      */
      await proxyClient.putObject(
        bucket,
        objectName,
        fileStream,
        size: fileSize,
        metadata: {'Content-Type': 'application/octet-stream'},
      );

      print("File uploaded successfully: $objectName");
      return true;
    } catch (e) {
      print("Error uploading file: $e");
      return false;
    }
  }

    Future<bool> deleteObject({required String bucket, required String objectName}) async {    
      try{
        //await minio.removeObject(bucket, objectName);
        await proxyClient.deleteObject(bucket: bucket, object: objectName);
        //print("File successfully deleted: $bucket/$objectName");
        return true;
      }
      catch(e){
        print("Error deleting object: $e");
        return false;
      }
    }

    Future<bool> deleteObjects({
      required String bucket, 
      required List<String> objectPaths
    }) async {
      try{
        //  await minio.removeObjects(bucket, objectPaths);
        await proxyClient.deleteObjects(bucket: bucket, objects: objectPaths);
        print("Files successfully deleted!");
        return true;
      }
      catch(e){
        print("Error deleting objects:");
        print(e);
        return false;
      }
    }

    
  

  Future<bool> uploadFileFromBytes(Uint8List fileBytes, String bucket, String objectName, {String contentType = 'application/octet-stream'}) async {
  try {
    Stream<Uint8List> fileStream = Stream.value(fileBytes);
    /*
    await minio.putObject(
      bucket,
      objectName,
      fileStream,
      size: fileBytes.length,
      metadata: {'Content-Type': contentType},
    );
    */

    await proxyClient.putObject(
      bucket,
      objectName,
      fileStream,
      size: fileBytes.length,
      metadata: {'Content-Type': contentType},
    );

    print("File uploaded successfully: $objectName");
    return true;
  } catch (e) {
    print("Error uploading file: $e");
    return false;
  }
}

  Future<bool> bucketExists(String bucketName) async {
    try{
      //bool exists = await minio.bucketExists(bucketName);
      bool exists = await proxyClient.bucketExists(bucket: bucketName);
      if(exists){
        return true;
        }
      else{
        return false;
        }
      }
        on ProxyError catch (e) {
          print(e);
        return false;
      } on SocketException {
          print("Network error: Unable to connect to Application Gateway.");
        return false;
      } catch (e) {
          print("Unexpected error while creating bucket ");
          print(e);
        return false;
      }   
  }

  Future<bool> createBucket(String bucketName) async {
    try{
      await proxyClient.makeBucket(bucket: bucketName);
      return true;
      }
      on ProxyError catch (e) {
      print("ProxyError: Failed to create bucket '$bucketName' - ${e.message}");
      return false;
    } on SocketException {
      print("Network error: Unable to connect to Backblaze B2.");
      return false;
    } catch (e) {
      print("Unexpected error while creating bucket '$bucketName': $e");
      return false;
    }
  }

  /// Downloads a file from the specified bucket and object, reporting progress
  /// Parameters:
  /// - [bucketName] (String): The name of the bucket where the object (file) is stored. This is a required parameter.
  /// - [objectName] (String): The name of the object (file) to download. This is a required parameter.
  /// - [savePath] (String): The local file path where the downloaded file should be saved. The method will write the file to this location.
  /// - [onProgress] (Function): A callback function that receives a `double` parameter, which represents the download progress as a percentage. 
  ///   This function is called periodically as chunks of data are downloaded. The value passed to this callback is between 0.0 (start) and 1.0 (complete).
  Future<bool> downloadFileWithProgress({required String bucketName, required String objectName, required String savePath, Function(double progress)? onProgress}) async {
    try {
      // Get the file stream
      //final stream = await minio.getObject(bucketName, objectName);
      final stream = await proxyClient.downloadFile(bucket: bucketName, object: objectName);

      // Get the file size (in bytes) for progress calculation
      final ProxyStatObjectResult fileStats = await proxyClient.statObject(bucket: bucketName, object: objectName);
      print("FILE STATS MATE:");
      print(fileStats);
      final totalSize = fileStats.size;

      // Open the file to save the data
      final file = File(savePath);
      final fileSink = file.openWrite();

      // Track downloaded bytes
      int bytesDownloaded = 0;

      
      await for (List<int> chunk in stream) {
        fileSink.add(chunk);
        bytesDownloaded += chunk.length;

        
        double progress = (bytesDownloaded / totalSize!);

        // Call the onProgress callback to report progress (If it exists)
        if(onProgress != null)
        {
          onProgress(progress);
        }
      }

      // Close the file once done
      await fileSink.close();

      print("File downloaded successfully: $objectName");
      return true;
    } catch (e) {
      print("Error downloading file: $e");
      return false;
    }
  }
}
