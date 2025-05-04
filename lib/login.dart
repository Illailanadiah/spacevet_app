import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spacevet_app/forgot.dart';
import 'package:spacevet_app/signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  signIn() async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email.text, password: password.text);
  }

  googleSignIn() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: const InputDecoration(hintText: 'Enter email'),
            ),
            TextField(
              controller: password,
              decoration: const InputDecoration(hintText: 'Enter password'),
            ),
            ElevatedButton(onPressed: (() => signIn()), child: Text("Login")),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: (() => Get.to(Signup())),
                child: Text("Signup now!")),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: (() => Get.to(Forgot())),
                child: Text("Forgot password?")),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: (() => googleSignIn()),
                child: Text("Login with Google")),
            SizedBox(
              height: 20,
            ),
         
          ],
        ),
      ),
    );
  }
}
