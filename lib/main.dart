import 'package:flutter/material.dart';

import 'package:amplify_core/amplify_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:s3_client/src/models/user.dart';
import 'package:s3_client/src/utils/aws_signature_v4_factory.dart';
import 'package:s3_client/src/utils/backblaze_service.dart';
import 'package:s3_client/src/utils/s3_service.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';


final AmplifyLogger _logger = AmplifyLogger('MyStorageApp');
void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Amplify is the package that has been used for all S3 complatible operations.
  // Logging in the debugging level has been enabled here.
  _logger.logLevel = LogLevel.debug;

  //Load flutter_dotenv

  await dotenv.load(fileName: 'assets/.env');

  
  //Instantiate the S3Client for sending requests and working with the cloud:
  final String myRegion = dotenv.env['REGION_NAME'].toString();
  final String myProvider = dotenv.env['PROVIDER_NAME'].toString();
  final String myEndpoint = "https://s3.$myRegion.$myProvider.com";
  final String apiKeyId = dotenv.env['API_KEY_ID'].toString();
  final String secretKey = dotenv.env['APPLICATION_KEY'].toString();
  final String serviceName = dotenv.env['SERVICE_NAME'].toString();
  final awsSigner = AwsSignatureV4Factory(
    apiKeyId, //The KeyID
    secretKey, //The ApplicationKey
    myRegion, //region
    serviceName, //service
    );

  print(
    [
    apiKeyId, //The KeyID
    secretKey, //The ApplicationKey
    "Region: $myRegion", //region
    "Provider: $myProvider",
    "Service: $serviceName", //service
    "Endpoint: $myEndpoint"
    ].toList()
  );
  
  
  final S3Service s3Service = S3Service(awsSigner, myEndpoint);
  final BackblazeService b2Service = BackblazeService(keyId: apiKeyId, applicationKey: secretKey, region: myRegion);

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
   runApp(
    MultiProvider(
    providers: [
      Provider<BackblazeService>.value(value: b2Service),
      ChangeNotifierProvider<User>(create: (_) => User()), // Now it's mutable!
    ],
    child: MyApp(settingsController: settingsController),
  ),
    //Accessing Provider: final s3Service = Provider.of<S3Service>(context);
    //or more concise:
    //final loggedUser = context.read<S3Service>();
  );
}
