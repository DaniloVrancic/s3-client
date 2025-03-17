import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:s3_client/src/settings/settings_controller.dart';
import 'package:s3_client/src/utils/backblaze_service.dart';
import 'package:s3_client/src/utils/proxy_client.dart';

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
  late BackblazeService b2service = context.read<BackblazeService>();


    // New state for proxy settings.
  bool _proxyEnabled = false;
  final TextEditingController _proxyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    final SettingsController settingsController = context.read<SettingsController>();
    _selectedTheme = settingsController.themeMode;
    _textSizeFactor = settingsController.textScaleFactor;
    _selectedFontFamily = settingsController.fontFamily;
  }

   /// Validate the proxy input.
  /// Returns true if the input is either a valid IPv4 (with optional port) or a valid domain (with optional port).
  bool validateProxyInput(String input) {
    // Pattern for IPv4 address with optional port.
    final ipPattern =
        r'^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}(:\d{1,5})?$';
    // Simple pattern for a domain name with optional port.
    final domainPattern =
        r'^(?!\-)(?:[a-zA-Z0-9\-]{1,63}\.)+[a-zA-Z]{2,6}(:\d{1,5})?$|^$|^localhost(:(\d{1,5}))?$';

    final ipRegex = RegExp(ipPattern);
    final domainRegex = RegExp(domainPattern);

    return ipRegex.hasMatch(input) || domainRegex.hasMatch(input);
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
              const SizedBox(height: 24),
              // New Setting: Proxy IP/Domain Input
              const Text(
                'Proxy IP/Domain:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Checkbox(
                    value: _proxyEnabled,
                    onChanged: (bool? value) {
                     setState(() {
                        _proxyEnabled = value ?? false;
                        if (_proxyEnabled) {
                          // Retrieve the current proxy address and port.
                          final address = b2service.proxyClient.address;
                          final port = b2service.proxyClient.port;
                          // Set the controller text to the address and port, if available.
                          _proxyController.text = port != null ? "$address:$port" : address;
                        } else {
                          // Optionally clear the text when disabling.
                          _proxyController.clear();
                        }
                      });
                    },
                  ),
                  const Text("Enable custom proxy"),
                ],
              ),
              TextField(
                controller: _proxyController,
                enabled: _proxyEnabled,
                decoration: const InputDecoration(
                  hintText: "Enter IP:port or domain",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
             Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.33,
                  child: ElevatedButton(
                    onPressed: !_proxyEnabled
                        ? null
                        : () {
                            final input = _proxyController.text.trim();
                            if (validateProxyInput(input)) {
                              List<String> tokens = input.split(':');
                              if (tokens.length == 2) {
                                b2service.updateProxyAddress(tokens[0],
                                    newPort: int.tryParse(tokens[1]));
                              } else {
                                b2service.updateProxyAddress(input);
                              }
                              final String newBaseUrl = b2service.proxyClient.baseUrl;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "Proxy updated successfully to $newBaseUrl")),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Invalid proxy address")),
                              );
                            }
                          },
                    child: const Text("Apply"),
                  ),
                ),
),

            ],
          ),
        ),
      ),
    );
  }
}
