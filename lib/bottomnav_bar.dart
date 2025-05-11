import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spacevet_app/color.dart';
import 'package:spacevet_app/homescreen.dart';
import 'package:spacevet_app/pets/pet_profile_view.dart';
import 'package:spacevet_app/settings/setting_screen.dart';
import 'package:spacevet_app/symptom_detection_screen.dart';

class BottomnavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomnavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: currentIndex,
      height: 60.0,
      color: AppColors.background,
      buttonBackgroundColor: AppColors.primary,
      backgroundColor: Colors.transparent,
      items: const <Widget>[
        Icon(Icons.home, size: 30), // Navigate to HomeScreen
        Icon(Icons.pets, size: 30),
        Icon(Icons.pets_rounded,size: 30), // Navigate to PetProfileScreen
        Icon(Icons.settings, size: 30),
         // Navigate to Setting screen
      ],
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 600),
      onTap: (index) {
        onTap(index); // Call onTap to handle navigation
        _navigateToScreen(index, context); // Navigate based on index
      },
    );
  }

  // Navigate to the appropriate screen based on the selected index
  void _navigateToScreen(int index, BuildContext context) {
    switch (index) {
      case 0:
        // Navigate to HomeScreen
        Get.to(() =>  HomeScreen());
        break;
      case 1:
        // Navigate to PetProfileScreen
        Get.to(() =>  SymptomDetection());
        break;
      case 2:
        // Navigate to Settings screen
        Get.to(() =>  PetProfileView());
        break;
      case 3:
        // Navigate to Settings screen
        Get.to(() =>  Setting());
        break;
      
      default:
        break;
    }
  }
}
