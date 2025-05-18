import 'package:flutter/material.dart';
import 'package:spacevet_app/bottomnav_bar.dart';
import 'package:spacevet_app/color.dart';

class SymptomDetection extends StatefulWidget {
  const SymptomDetection({super.key});

  @override
  State<SymptomDetection> createState() => _SymptomDetectionState();
}

class _SymptomDetectionState extends State<SymptomDetection> {
  int currentIndex = 1; // Set the initial index for the bottom navigation bar
  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Symptom Detection', textAlign: TextAlign.center,),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
         centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Add a photo of your pet',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Add your symptom detection logic here
                },
                child: const Icon(Icons.camera_alt),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Add your symptom detection logic here
                },
                child: const Text('Take from photo'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomnavBar(  // Add the BottomnavBar
        currentIndex: currentIndex,  // Set the current index for the bottom nav bar
        onTap: (index) {
          setState(() {
            currentIndex = index;  // Update the selected tab index
            // Handle navigation based on index
          });
        },
      ),
    );
  }
}