import 'package:flutter/material.dart';
import 'package:spacevet_app/bottomnav_bar.dart';
import 'package:spacevet_app/color.dart';

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {

  int currentIndex = 3; // Track the selected index for bottom navigation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Chatbot"),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
      ),
      body: Center(
        child: Text(
          "Chatbot functionality will be here.",
          style: TextStyle(fontSize: 20),
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