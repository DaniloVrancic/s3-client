import 'package:flutter/material.dart';

import 'package:amplify_core/amplify_core.dart';
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

  //Instantiate the S3Client for sending requests and working with the cloud:
  final String myRegion = "eu-central-003";
  final String myProvider = "backblazeb2";
  final String myEndpoint = "https://s3.${myRegion}.${myProvider}.com";
  final awsSigner = AwsSignatureV4Factory(
    '', //The KeyID
    '', //The ApplicationKey
    myRegion, //region
    'execute-api', //service
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
