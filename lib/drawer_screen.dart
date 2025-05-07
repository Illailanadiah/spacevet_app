import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spacevet_app/add_pet_screen.dart';
import 'package:spacevet_app/color.dart';
import 'package:spacevet_app/settings.dart';
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

  final user = FirebaseAuth.instance.currentUser;
  late String userId;
  late Stream<DocumentSnapshot> userStream;

  @override
  void initState() {
    super.initState();
    userId = user!.uid;
    // Stream to listen to user document
    userStream =
        FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Drawer(
          child: Container(
            color: AppColors.primary,
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                  ),
                  child: Column(
                    children: [
                      // Fetch the user's nickname and display it
                      StreamBuilder<DocumentSnapshot>(
                        stream: userStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          if (!snapshot.hasData || snapshot.data == null) {
                            return const Text('Error: No data found');
                          }

                          // Get the nickname from Firestore
                          var userData = snapshot.data!;
                          String userNickname = userData['name'] ?? 'Guest';

                          return Text(
                            userNickname,
                            style: const TextStyle(color: AppColors.background),
                          );
                        },
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
                  title: const Text('Add Pet Profile',
                      style: TextStyle(color: AppColors.background)),
                  onTap: () {
                     Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const PetProfileScreen(petId: '',)),
                              );
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.notifications_active, color: AppColors.background),
                  title: const Text('Notifications',
                      style: TextStyle(color: AppColors.background)),
                  onTap: () {
                    // Navigate to Notifications
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.settings, color: AppColors.background),
                  title: const Text('Settings',
                      style: TextStyle(color: AppColors.background)),
                  onTap: () {
                    // Navigate to Settings
                    Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => Setting()),
                              );
                  },
                ),
                const SizedBox(height: 50),
                ListTile(
                  leading:
                      const Icon(Icons.logout, color: AppColors.background),
                  title: const Text('Logout',
                      style: TextStyle(color: AppColors.background)),
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
