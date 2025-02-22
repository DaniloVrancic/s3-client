import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:s3_client/src/settings/settings_controller.dart';

class SettingsPageWidget extends StatefulWidget {
  const SettingsPageWidget({Key? key}) : super(key: key);

  @override
  State<SettingsPageWidget> createState() => _SettingsPageWidgetState();
}

class _SettingsPageWidgetState extends State<SettingsPageWidget> {

  // Local state for the selected theme.
  late ThemeMode _selectedTheme;

  // Example state variables for additional settings.
  bool _notificationsEnabled = true;
  late double _textSizeFactor; // 1.0 = normal text size
   late String _selectedFontFamily; // new: font family selection

  @override
  void initState() {
    super.initState();
    
    final SettingsController settingsController = context.read<SettingsController>();
    _selectedTheme = settingsController.themeMode;
    _textSizeFactor = settingsController.textScaleFactor;
    _selectedFontFamily = settingsController.fontFamily;
  }
  

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Setting: Theme Selection Dropdown
              const Text(
                'Theme:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButton<ThemeMode>(
                isExpanded: true,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                padding: EdgeInsets.all(10),
                value: _selectedTheme,
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('System'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Dark'),
                  ),
                ],
                onChanged: (ThemeMode? newTheme) async {
                  if (newTheme == null) return;
                  setState(() {
                    _selectedTheme = newTheme;
                  });
                  await settingsController.updateThemeMode(newTheme);
                },
              ),
              const SizedBox(height: 24),
              //  TODO: Possible update: Add Push Notifications or local notifications for the app
              /*
              // Setting: Notifications Toggle
              const Text(
                'Notifications:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SwitchListTile(
                title: const Text('Enable Notifications'),
                value: _notificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              */
              // Setting: Text Size Slider
              const Text(
                'Text Size:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Slider(
                value: _textSizeFactor,
                min: 0.7,
                max: 1.3,
                divisions: 6,
                label: "${(_textSizeFactor * 100).round()}%",
                onChanged: (double value) async {
                  setState(() {
                    _textSizeFactor = value;
                  });
                  await settingsController.updateTextScaleFactor(_textSizeFactor);
                },
              ),
               // New Setting: Font Family Dropdown
              const Text(
                'Font Family:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                isExpanded: true,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                padding: const EdgeInsets.all(10),
                value: _selectedFontFamily,
                items: const [
                  DropdownMenuItem(
                    value: 'default',
                    child: Text('Default'),
                  ),
                  DropdownMenuItem(
                    value: 'serif',
                    child: Text('Serif'),
                  ),
                  DropdownMenuItem(
                    value: 'monospace',
                    child: Text('Monospace'),
                  ),
                  DropdownMenuItem(
                    value: 'cursive',
                    child: Text('Cursive'),
                  ),
                ],
                onChanged: (String? newFontFamily) async {
                  if (newFontFamily == null) return;
                  setState(() {
                    _selectedFontFamily = newFontFamily;
                  });
                  await settingsController.updateFontFamily(newFontFamily);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
