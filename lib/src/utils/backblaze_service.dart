import 'package:minio/minio.dart';

class BackblazeService {
  String keyId = "YOUR_KEY_ID";
  String applicationKey = "YOUR_APPLICATION_KEY";
  String region = "YOUR_REGION";

  final String userbaseBucket = '---user-repository';
  final String userbaseObject = 'my_userbase.csv';

  final Minio minio;

  BackblazeService({required this.keyId, required this.applicationKey, required this.region}) 
      : minio = Minio(
        endPoint: "s3.$region.backblazeb2.com",
        accessKey: keyId,
        secretKey: applicationKey,
        region: region,
        useSSL: true
      );
}