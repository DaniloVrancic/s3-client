import 'package:flutter/material.dart';

import 'package:amplify_core/amplify_core.dart';

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
  

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(settingsController: settingsController));
}
