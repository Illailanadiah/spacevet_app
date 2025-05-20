import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacevet_app/authentication/login.dart'; // Import the Login screen
import 'package:spacevet_app/bottomnav_bar.dart';
import 'package:spacevet_app/color.dart';
import 'package:spacevet_app/settings/biometric.dart'; // Assuming the Biometric setup page

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool _isBiometricEnabled = false;
  final User? user = FirebaseAuth.instance.currentUser;
    int currentIndex = 4; // Track the selected index for bottom navigation


  @override
  void initState() {
    super.initState();
    _loadBiometricPreference();
  }

  // Load the biometric preference from Firestore
  Future<void> _loadBiometricPreference() async {
  if (user == null) return;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .get();

  final data = doc.data() ?? {};
  setState(() {
    _isBiometricEnabled = (data['biometric_enabled'] is bool)
      ? data['biometric_enabled'] as bool
      : false;
  });
}


  // Save the biometric preference to Firestore
  Future<void> _saveBiometricPreference(bool value) async {
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'biometric_enabled': value,
      });
    }
  }

  // Function to start biometric authentication setup
  Future<void> _startBiometricSetup() async {
    // If biometric is enabled, directly ask the user to authenticate with their fingerprint
    if (_isBiometricEnabled) {
      // Here we can prompt the biometric authentication
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Biometric()), // Replace Biometric() with the actual biometric setup screen
      );
    } else {
      // Optionally show a message if biometric is not enabled
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
        
      ),
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
                  _saveBiometricPreference(value); // Save the preference to Firestore
                });

                // If biometric is enabled, trigger the biometric setup directly
                if (_isBiometricEnabled) {
                  _startBiometricSetup(); // Initiate biometric setup when toggled on
                }
              },
            ),
            //remove the setup button as the setup will be triggered by the switch toggle 
           
  
            const SizedBox(height: 20.0),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.textSecondary),
              onTap: _logout, // Call _logout method on button press
              title: const Text('Logout', style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomnavBar(  // Add the BottomnavBar
        currentIndex: currentIndex,  // Set the current index for the bottom nav bar
        onTap: (index) {
          setState(() {
            currentIndex = index;  // Update the selected tab index
            // Handle navigation based on index
          });
        },
      ),
    );
  }
}
