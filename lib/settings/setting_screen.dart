import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacevet_app/authentication/login.dart'; // Import the Login screen
import 'package:spacevet_app/settings/biometric.dart'; // Assuming the Biometric setup page

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

  // Function to start biometric authentication setup
  Future<void> _startBiometricSetup() async {
    if (_isBiometricEnabled) {
      // If biometric is enabled, ask the user to authenticate with their fingerprint
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Biometric()), // Replace Biometric() with the actual biometric setup screen
      );
    } else {
      // Show a message if biometric is not enabled
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric Authentication is not enabled.')),
      );
    }
  }

  // Function to handle logout using Get.to(Login()) for navigation
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all the stored preferences

    // Navigate to the Login screen using Get.to()
    Get.to(() => const Login()); // Use Get.to() to navigate to the Login screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // The switch to toggle biometric authentication on/off
            SwitchListTile(
              title: const Text('Enable Biometric Authentication'),
              value: _isBiometricEnabled,
              onChanged: (value) {
                setState(() {
                  _isBiometricEnabled = value;
                  _saveBiometricPreference(value); // Save the preference
                });

                // If biometric is enabled, trigger the biometric setup directly
                if (_isBiometricEnabled) {
                  _startBiometricSetup(); // Initiate biometric setup when toggled on
                }
              },
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _logout, // Call _logout method on button press
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
