import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;

  signout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: Text('${user!.email}'),
          ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 28,vertical: 5),
          child:Center(
              child: Text("Successfully logged in as ${user!.email} using fingerprint authentication"),
            ),
          
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() => signout()),
        child: const Icon(Icons.login_rounded),
      ),
    );
  }
}
