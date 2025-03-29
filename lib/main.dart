import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:s3_client/src/models/change_follower.dart';
import 'package:s3_client/src/models/user.dart';
import 'package:s3_client/src/utils/backblaze_service.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';


void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  //Load flutter_dotenv

  await dotenv.load(fileName: 'assets/.env');

  
  //Instantiate the S3Client for sending requests and working with the cloud:
  final String myRegion = dotenv.env['REGION_NAME'].toString();
  final String myProvider = dotenv.env['PROVIDER_NAME'].toString();
  final String myEndpoint = "https://s3.$myRegion.$myProvider.com";
  final String apiKeyId = dotenv.env['API_KEY_ID'].toString();
  final String secretKey = dotenv.env['APPLICATION_KEY'].toString();
  final String serviceName = dotenv.env['SERVICE_NAME'].toString();

  final String userbaseBucket = dotenv.env['USER_DATABASE_BUCKET'].toString();
  final String userbaseObject = dotenv.env['USER_DATABASE_OBJECT'].toString();

/*
  final awsSigner = AwsSignatureV4Factory(
    apiKeyId, //The KeyID
    secretKey, //The ApplicationKey
    myRegion, //region
    serviceName, //service
    );
*/
  
 // final S3Service s3Service = S3Service(awsSigner, myEndpoint);
  final BackblazeService b2Service = BackblazeService
  (
    keyId: apiKeyId, 
    applicationKey: secretKey, 
    region: myRegion,
    userbaseBucket: userbaseBucket,
    userbaseObject: userbaseObject);

  //final ChangeFollower changeFollower = ChangeFollower();


  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
   runApp(
    MultiProvider(
    providers: [
      Provider<BackblazeService>.value(value: b2Service),
      ChangeNotifierProvider<SettingsController>.value(value: settingsController),
      ChangeNotifierProvider<ChangeFollower>(create: (_) => ChangeFollower()),
      ChangeNotifierProvider<User>(create: (_) => User()), // The User that I will use anywhere in the application
    ],
    child: MyApp(settingsController: settingsController),
  ),
    //Accessing Provider: final s3Service = Provider.of<S3Service>(context);
    //or more concise:
    //final loggedUser = context.read<S3Service>();
  );
}
