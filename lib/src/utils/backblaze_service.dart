import 'dart:convert';

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
      print("TRYING TO FETCH USERBASE:");
      print(userbaseBucket);
      print(userbaseObject);
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
    processedLines.forEach((line)=>print(line));
    return processedLines;
    }
    catch (e) {
      print("Error fetching userbase: $e");
      return [];
    }
  }
}