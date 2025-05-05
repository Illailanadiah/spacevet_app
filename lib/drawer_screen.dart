import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spacevet_app/color.dart';
import 'package:spacevet_app/wrapper.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  signout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(
        Wrapper()); // Navigate to the Wrapper after sign out (assumed to be your login screen)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Drawer(
          child: Container(
            color: AppColors.background,
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/icons/avatar.png'),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Amanda',
                        style: TextStyle(color: AppColors.background),
                      ),
                      const Text(
                        'Pet Owner',
                        style: TextStyle(
                            color: AppColors.background, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.account_circle,
                        color: AppColors.background),
                  title: const Text('Profile',
                        style: TextStyle(
                            color: AppColors.background)),
                  onTap: () {
                    // Navigate to Profile
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings,
                        color: AppColors.background),
                  title: const Text('Settings',
                        style: TextStyle(
                            color: AppColors.background)),
                  onTap: () {
                    // Navigate to Settings
                  },
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.logout,
                        color: AppColors.background),
                  title: const Text('Logout',
                        style: TextStyle(
                            color: AppColors.background)),
                  onTap: (() => signout()),
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
