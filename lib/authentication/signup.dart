import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spacevet_app/authentication/login.dart';
import 'package:spacevet_app/color.dart';
import 'package:spacevet_app/no_pet.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController nickname = TextEditingController();


  Future<void> signup() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.text,
      password: password.text,
    );

    await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
      'name': nickname.text,
      'email': email.text,
    });
    Get.snackbar("Success", "You have signed up successfully",
        backgroundColor: AppColors.primary,
        colorText: AppColors.background,
        snackPosition: SnackPosition.BOTTOM);

    Get.offAll(NoPetScreen());
    } catch (e) {
      print("Error: $e");
      Get.snackbar("Error", "Failed to sign up",
          backgroundColor: AppColors.primary,
          colorText: AppColors.background,
          snackPosition: SnackPosition.BOTTOM);
      
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    "assets/logo/logo_signup.png",
                    height: 200,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  icon: Icons.person,
                  hint: 'Nickname',
                  controller: nickname,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  icon: Icons.email,
                  hint: 'Enter your email',
                  controller: email,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  icon: Icons.password,
                  hint: 'Enter your password',
                  controller: password,
                  obscure: true,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: (() {
                    signup();
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(color: AppColors.background),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontFamily: 'Poppins',
                        )),
                    TextButton(
                      onPressed: () => Get.to(Login()),
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade300,
        prefixIcon: Icon(icon, color: Colors.blueGrey),
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Poppins'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
