// ignore_for_file: prefer_final_fields, avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:minio/minio.dart';
import 'package:minio/models.dart';

class BackblazeService {
  static final String DEFAULT_ADDRESS = "10.99.167.45";
  // FOR REMOVAL !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  String keyId = "YOUR_KEY_ID";
  String applicationKey = "YOUR_APPLICATION_KEY";
  String region = "YOUR_REGION";

  //String proxyAddress = "YOUR_PROXY_SERVER_ADDRESS";
  //int? proxyPort = null;
  // FOR REMOVAL !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  String? _userbaseBucket = "YOUR_BUCKET";
  String? _userbaseObject = "YOUR_OBJECT";

  String address  = DEFAULT_ADDRESS;
  int?   port     = 9000;

  
  
  
  Minio minio;



  BackblazeService(
    {
      required this.keyId, 
      required this.applicationKey, 
      required this.region,
      required this.address,
      this.port,
      //required this.proxyAddress,
      //required this.proxyPort,
      userbaseBucket, 
      userbaseObject,

    }) 
      :
      _userbaseBucket = userbaseBucket,
      _userbaseObject = userbaseObject,
      
      minio = Minio(
        endPoint: address,
        accessKey: keyId,
        secretKey: applicationKey,
        region: region,
        port: port,
        useSSL: false
      );
  /*
  String get userbaseBucket => _userbaseBucket ?? "a---user-repository";
  String get userbaseObject => _userbaseObject ?? "a---user-repository";
    
  Future<List<String>> fetchUserbase() async {

    try{
      dynamic stream;
      if(_userbaseBucket != null && _userbaseObject != null)
      {
       stream = await minio.getObject(_userbaseBucket.toString(), _userbaseObject.toString());
      }
      else{
       stream = await minio.getObject("a---user-repository", "my_userbase.csv");
      }

      // Correct the fold function to decode the byte array and concatenate the result
      var content = await stream.fold<String>("", (String prev, List<int> element) {
        return prev + utf8.decode(element);
      });
       // Split content by newlines
    final List<String> result = content.isNotEmpty ? content.split("\n") : [];

    // Process each line
    List<String> processedLines = [];
    for (String line in result) {
      // Split each line by comma and trim each token
      List<String> tokens = line.split(",").map((token) {
        return token.trim();  // Trim whitespace from each token
      }).toList();

      // Rejoin the tokens into a single line using commas
      processedLines.add(tokens.join(","));
    }
    return processedLines;
    }
    catch (e) {
      print("Error fetching userbase: $e");
      return [];
    }
  }
  */

  Future<List<Bucket>> listAllBuckets() async {
    return await minio.listBuckets();
  }

  void updateKeys(String keyId, String applicationKey){
    this.keyId = keyId;
    this.applicationKey = applicationKey;

   this.minio = Minio(
      endPoint: address,
      region: region,
      accessKey: keyId,
      secretKey: applicationKey,
      useSSL: false,
      port: (port != null) ? port : null
    );

  }
  void updateRegion(String region){
    this.region = region;

    this.minio = Minio(
      endPoint: address,
      region: region,
      accessKey: keyId,
      secretKey: applicationKey,
      useSSL: false,
      port: (port != null) ? port : null
    );
  }

   void updateAddress({required String address, int? port}){
    this.address = address;
    if(port != null)
    {
      this.port = port;
    }

    this.minio = Minio(
      endPoint: address,
      region: region,
      accessKey: keyId,
      secretKey: applicationKey,
      useSSL: false,
      port: (port != null) ? port : null
    );
  }

  void updateMinioClient({
    required String address,
    int? port,
    required String region,
    bool useSSL = false,
    required String accessKey,
    required String secretKey
  })
  {
    this.address = address;
    if(port != null){
      this.port = port;
    }
    this.region = region;
    this.keyId = accessKey;
    this.applicationKey = secretKey;
    this.minio = Minio(
      endPoint: address,
      region: region,
      accessKey: accessKey,
      secretKey: secretKey,
      useSSL: useSSL,
      port: (port != null) ? port : null
    );
  }

  Future<ListObjectsResult?> fetchAllObjectsFromBucket(String bucketName, {String prefix = ""}) async {

    List<ListObjectsResult> listOfObjects = await minio.listObjects(bucketName, recursive: true, prefix: prefix).toList();
    if(listOfObjects.isNotEmpty)
    {
      ListObjectsResult result = listOfObjects.first;
      return result;
    }
    else{
      return null;
    }
  }

  Future<ListObjectsResult?> fetchAllObjects(String bucketName) async {

    List<ListObjectsResult> listOfObjects = await minio.listObjects(bucketName).toList();
    
    if(listOfObjects.isNotEmpty)
    {
      ListObjectsResult result = listOfObjects.first;
      return result;
    }
    else{
      return null;
    }
  }

   /// Uploads a new version of the user database, the List has a user in each line
  Future<bool> uploadNewDatabase(List<String> updatedUserList) async {
    try {
      if (_userbaseBucket == null || _userbaseObject == null) {
        throw Exception("Bucket or object name not set");
      }

      String newUserData = updatedUserList.join("\n");

      await minio.putObject(
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

      await minio.putObject(
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
        await minio.removeObject(bucket, objectName);
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
        await minio.removeObjects(bucket, objectPaths);
        print("Files successfully deleted!");
        return true;
      }
      catch(e){
        print("Error deleting objects:");
        print(e);
        return false;
      }
    }

    Future<void> deleteBucket({required String bucket}) async {    
     
        await minio.removeBucket(bucket);
        //print("File successfully deleted: $bucket/$objectName");
      
    }

    
  

  Future<bool> uploadFileFromBytes(Uint8List fileBytes, String bucket, String objectName, {String contentType = 'application/octet-stream'}) async {
  try {
    Stream<Uint8List> fileStream = Stream.value(fileBytes);
    await minio.putObject(
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
      bool exists = await minio.bucketExists(bucketName);
      if(exists){
        return true;
        }
      else{
        return false;
        }
      }
        on MinioError catch (e) {
          print(e);
        return false;
      } on SocketException {
          print("Network error: Unable to connect to Backblaze B2.");
        return false;
      } catch (e) {
          print("Unexpected error while creating bucket ");
          print(e);
        return false;
      }   
  }

  Future<bool> createBucket(String bucketName) async {
    try{
      await minio.makeBucket(
        bucketName, 
        region,
        );
      return true;
      }
      on MinioError catch (e) {
      print("MinioError: Failed to create bucket '$bucketName' - ${e.message}");
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
      final stream = await minio.getObject(bucketName, objectName);

      // Get the file size (in bytes) for progress calculation
      final fileSize = await minio.statObject(bucketName, objectName);
      final totalSize = fileSize.size;

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

  Future<String> getPresignedGetUrl({required String bucket, required String object, int? hoursUntilExpire})
  {
    return minio.presignedGetObject( bucket, object, expires: hoursUntilExpire! * 60 * 24);
  }

  Future<String> getPresignedPutUrl({required String bucket, required String object, int? hoursUntilExpire})
  {
    return minio.presignedPutObject( bucket, object, expires: hoursUntilExpire! * 60 * 24);
  }
}
