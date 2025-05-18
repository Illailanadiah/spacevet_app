import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:get/get.dart';
import 'package:spacevet_app/color.dart';
import 'package:spacevet_app/homescreen.dart';

class Biometric extends StatefulWidget {
  const Biometric({super.key});

  @override
  State<Biometric> createState() => _BiometricState();
}

class _BiometricState extends State<Biometric> {
  final LocalAuthentication auth = LocalAuthentication();

  Future<void> _authenticateWithBiometrics() async {
    bool isAvailable = await auth.canCheckBiometrics;

    if (isAvailable) {
      bool isAuthenticated = await auth.authenticate(
        localizedReason: "Scan your fingerprint to continue",
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (isAuthenticated) {
        // Navigate to HomeScreen after successful authentication
        Get.to(() => HomeScreen());
      } else {
        // Handle failed authentication
        Get.snackbar("Authentication Failed", "Please try again.",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      // Biometric not available
      Get.snackbar("Error", "Biometric authentication is not available.",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  void initState() {
    super.initState();
    _authenticateWithBiometrics(); // Trigger biometric auth when this screen loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Biometric Authentication"),
      foregroundColor: AppColors.background,
      backgroundColor: AppColors.primary,
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Biometric Authentication",
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      
      ),
    );
  }
}
