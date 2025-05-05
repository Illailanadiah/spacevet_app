import 'package:flutter/material.dart';
import 'package:spacevet_app/pet_profile.dart'; // Assuming the pet profile screen is located here
import 'package:spacevet_app/color.dart';

class NoPetScreen extends StatelessWidget {
  const NoPetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Greeting Text
              const Text(
                "Hi, Amanda",
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
              ElevatedButton(
                onPressed: () {
                  // Navigate to the pet profile setup page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PetProfile()), // PetProfile is the screen to fill out the pet's info
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Swipe to continue",
                  style: TextStyle(color: AppColors.background),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
