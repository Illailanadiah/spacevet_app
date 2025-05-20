import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacevet_app/authentication/login.dart';
import 'package:spacevet_app/bottomnav_bar.dart';
import 'package:spacevet_app/color.dart';
import 'package:spacevet_app/settings/biometric.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool _isBiometricEnabled = false;
  final User? user = FirebaseAuth.instance.currentUser;
  int currentIndex = 4;

  @override
  void initState() {
    super.initState();
    _loadBiometricPreference();
  }

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

  Future<void> _saveBiometricPreference(bool value) async {
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'biometric_enabled': value});
    }
  }

  Future<void> _startBiometricSetup() async {
    if (_isBiometricEnabled) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Biometric()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biometric Authentication is not enabled.'),
        ),
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAll(() => const Login());
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
            SwitchListTile(
              activeColor: AppColors.primary,
              secondary: const Icon(Icons.fingerprint,
                  color: AppColors.textSecondary),
              title: const Text('Enable Biometric Authentication'),
              value: _isBiometricEnabled,
              onChanged: (value) async {
                setState(() => _isBiometricEnabled = value);

                // 1) persist to Firestore
                await _saveBiometricPreference(value);

                // 2) clear per-session flag so HomeScreen re-prompts next time
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('biometric_authenticated');

                // 3) if they just turned it on, kick off setup immediately
                if (value) {
                  _startBiometricSetup();
                }
              },
            ),

            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.textSecondary),
              title: const Text('Logout',
                  style: TextStyle(color: AppColors.primary)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomnavBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
      ),
    );
  }
}
