import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spacevet_app/authentication/forgot.dart';
import 'package:spacevet_app/authentication/signup.dart';
import 'package:spacevet_app/color.dart';
import 'package:spacevet_app/homescreen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text, password: password.text);
      Get.to(HomeScreen()); // Navigate to HomeScreen after login
    } catch (e) {
      print("Error: $e");
    }
  }

  googleSignIn() async {
  try {
    // Trigger the Google Sign-In process
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      // User cancelled the sign-in
      return;
    }

    // Retrieve authentication details
    final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
    
    // Create a credential to use with Firebase
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Sign in with Firebase using the credential
    await FirebaseAuth.instance.signInWithCredential(credential);
    
    // Navigate to HomeScreen after successful login
    Get.offAll(() => const HomeScreen()); // Use Get.offAll to remove the login screen from the stack

  } catch (e) {
    print("Error during Google sign-in: $e");
    // Handle error appropriately, maybe show a Snackbar or Alert
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
                    "assets/logo/logo_login.png",
                    height: 200,
                  ),
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
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.to(const Forgot()),
                    child: const Text(
                      "Forgot password?",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
               const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: signIn,
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
                    "Login",
                    style: TextStyle(color: AppColors.background),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("or", style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: googleSignIn,
                  icon: const Icon(Icons.g_mobiledata),
                  label: const Text("Login with Google"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?", 
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontFamily: 'Poppins',
                        )),
                    TextButton(
                      onPressed: () => Get.to(const Signup()),
                      child: const Text(
                        "SignUp",
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
