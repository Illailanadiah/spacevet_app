import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:get/get.dart';
import 'package:spacevet_app/home_screen.dart';

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
        Get.to(() => const HomeScreen());
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
      appBar: AppBar(title: const Text("Biometric Authentication")),
      body: Center(
        child: ElevatedButton(
          onPressed: _authenticateWithBiometrics,
          child: const Text("Authenticate with Fingerprint"),
        ),
      ),
    );
  }
}
