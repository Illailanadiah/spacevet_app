import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:spacevet_app/home_screen.dart'; 

class Biometric extends StatefulWidget {
  const Biometric({super.key});

  @override
  State<Biometric> createState() => _BiometricState();
}

class _BiometricState extends State<Biometric> {

final LocalAuthentication auth = LocalAuthentication();

  checkAuth() async {
    bool isAvailable;
    isAvailable = await auth.canCheckBiometrics;
    print(isAvailable);
    if (isAvailable) {
      bool result = await auth.authenticate(
        localizedReason: "Scan your finger",
        options: AuthenticationOptions(biometricOnly: true),
      );
      if (result) {
        Get.to(HomeScreen());
      }else{
        print("Authentication failed");
      }
    } else {
      print("Biometric authentication is not available");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar(
        title: const Text("Biometric Authentication"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: (() => checkAuth()),
          child: const Text("Authenticate"),
        ),
      ),
    );
  }
}


