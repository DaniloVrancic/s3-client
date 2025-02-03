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

  BackblazeService({required this.keyId, required this.applicationKey, required this.region, required this.userbaseBucket, required this.userbaseObject}) 
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
       stream = await minio.getObject("---user-repository", "my_userbase.csv");
      }

      var content = await stream.fold<String>("", (prev, element) => prev + utf8.decode(element));
      return content.isNotEmpty ? content.split<List<String>>("\n") : [];
      
    }
    catch (e) {
      print("Error fetching userbase: $e");
      return [];
    }
  }
}