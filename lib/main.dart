import 'package:flutter/material.dart';

import 'package:amplify_core/amplify_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:s3_client/src/utils/aws_signature_v4_factory.dart';
import 'package:s3_client/src/utils/backblaze_client.dart';

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
  final awsSigner = AwsSignatureV4Factory(
    dotenv.env['API_KEY_ID'].toString(), //The KeyID
    dotenv.env['APPLICATION_KEY'].toString(), //The ApplicationKey
    myRegion, //region
    dotenv.env['SERVICE_NAME'].toString(), //service
    );

  print(
    [
    dotenv.env['API_KEY_ID'].toString(), //The KeyID
    dotenv.env['APPLICATION_KEY'].toString(), //The ApplicationKey
    "Region: $myRegion", //region
    "Provider: $myProvider",
    "Service: ${dotenv.env['SERVICE_NAME'].toString()}", //service
    "Endpoint: $myEndpoint"
    ].toList()
  );
  
  
  final S3Service s3Service = S3Service(awsSigner, myEndpoint);
  


  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
   runApp(
    Provider<S3Service>.value(
      value: s3Service,
      child: MyApp(settingsController: settingsController),
    ),

    //Accessing Provider: final s3Service = Provider.of<S3Service>(context);
  );
}
