import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:minio/minio.dart';
import 'package:s3_client/src/models/user.dart';

class BackblazeService {
  String keyId = "YOUR_KEY_ID";
  String applicationKey = "YOUR_APPLICATION_KEY";
  String region = "YOUR_REGION";

  String? userbaseBucket = "YOUR_BUCKET";
  String? userbaseObject = "YOUR_OBJECT";

  final Minio minio;

  BackblazeService(
    {
      required this.keyId, 
      required this.applicationKey, 
      required this.region, 
      required this.userbaseBucket, 
      required this.userbaseObject
    }) 
      : minio = Minio(
        endPoint: "s3.$region.backblazeb2.com",
        accessKey: keyId,
        secretKey: applicationKey,
        region: region,
        useSSL: true
      );
    
  Future<List<String>> fetchUserbase() async {

    try{
      dynamic stream;
      if(userbaseBucket != null && userbaseObject != null)
      {
       stream = await minio.getObject(userbaseBucket.toString(), userbaseObject.toString());
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
   /// Uploads a new version of the user database, the List has a user in each line
  Future<bool> uploadNewDatabase(List<String> updatedUserList) async {
    try {
      if (userbaseBucket == null || userbaseObject == null) {
        throw Exception("Bucket or object name not set");
      }

      String newUserData = updatedUserList.join("\n");

      await minio.putObject(
        userbaseBucket!,
        userbaseObject!,
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
}