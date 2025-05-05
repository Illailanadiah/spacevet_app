import 'package:flutter/material.dart';
import 'package:spacevet_app/color.dart';

class PetProfile extends StatefulWidget {
  const PetProfile({super.key});

  @override
  State<PetProfile> createState() => _PetProfileState();
}

class _PetProfileState extends State<PetProfile> {
  TextEditingController petNameController = TextEditingController();
  TextEditingController petAgeController = TextEditingController();
  TextEditingController petWeightController = TextEditingController();

  // Function to save the pet profile to Firestore
  saveProfile() {
    // Example: Save pet profile to Firestore or any backend
    print("Pet Name: ${petNameController.text}");
    print("Pet Age: ${petAgeController.text}");
    print("Pet Weight: ${petWeightController.text}");

    // After saving data, navigate to the home screen or another page
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Create Pet Profile"),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Text(
              "Pet Name",
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
            TextField(
              controller: petNameController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: AppColors.textSecondary,
                border: OutlineInputBorder(),
                hintText: 'Enter pet name',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Pet Age",
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
            TextField(
              controller: petAgeController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: AppColors.textSecondary,
                border: OutlineInputBorder(),
                hintText: 'Enter pet age',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Pet Weight",
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
            TextField(
              controller: petWeightController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: AppColors.textSecondary,
                border: OutlineInputBorder(),
                hintText: 'Enter pet weight',
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Save Profile",
                style: TextStyle(color: AppColors.background),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
