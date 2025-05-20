import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:spacevet_app/pets/add_pet_screen.dart'; // Assuming the pet profile screen is located here
import 'package:spacevet_app/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';

class NoPetScreen extends StatefulWidget {
  const NoPetScreen({super.key});

  @override
  State<NoPetScreen> createState() => _NoPetScreenState();
}

class _NoPetScreenState extends State<NoPetScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  @override
  Widget build(BuildContext context) {
    // Get the current user's UID
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text('Please log in')),
      );
    }

    // Get the user's document from Firestore
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: StreamBuilder<DocumentSnapshot>(
            stream: userDoc.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return Center(child: Text('User data not found.'));
              }

              // Fetch the nickname from Firestore
              String nickname = snapshot.data!['name'] ?? 'Guest';

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Greeting Text
                  Text(
                    "Hi, $nickname", // Use the fetched nickname
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Good Morning!",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Image of cat
                  Image.asset(
                    "assets/icons/uh_oh_cat.png", // Ensure the cat image is placed correctly in your assets
                    height: 200,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Uh Oh!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Looks like you have no profiles set up at this moment, add your pet now",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Slide action for adding pet
                  SlideAction(
                    borderRadius: 12,
                    elevation: 0,
                    innerColor: AppColors.primary,
                    outerColor: AppColors.textSecondary,
                    sliderButtonIcon: const Icon(
                      Icons.arrow_forward,
                      color: AppColors.background,
                    ),
                    text: "Swipe to continue",
                    textStyle: const TextStyle(
                      color: AppColors.background,
                      fontSize: 16,
                    ),
                    onSubmit: ()  {
                      // Navigate to the add pet screen
                      Get.to(() =>  PetProfileScreen());
                      return null;
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
