import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacevet_app/biometric.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricPreference();
  }

  // Load the biometric preference from SharedPreferences
  Future<void> _loadBiometricPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    });
  }

  // Save the biometric preference to SharedPreferences
  Future<void> _saveBiometricPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Enable Biometric Authentication'),
              value: _isBiometricEnabled,
              onChanged: (value) {
                setState(() {
                  _isBiometricEnabled = value;
                  _saveBiometricPreference(value); // Save the preference
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (_isBiometricEnabled) {
                  // Navigate to the screen where the user can set up biometric authentication (if required)
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) =>  Biometric()),
                  );
                }
              },
              child: const Text('Setup Biometric Authentication'),
            ),
          ],
        ),
      ),
    );
  }
}