import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:spacevet_app/pets/add_pet_screen.dart';

class PetProfileView extends StatefulWidget {
  const PetProfileView({super.key});

  @override
  State<PetProfileView> createState() => _PetProfileViewState();
}

class _PetProfileViewState extends State<PetProfileView> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Pet Profile'),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(child: 
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Pet Profile View',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Add your logic here
                },
                child: const Text('View Pet Profile'),
              ),
              IconButton(
                onPressed: () {
                  Get.to(() => PetProfileScreen(petId: ''));
                },
                icon: Icon(Icons.add),
                color: Colors.blue,
                iconSize: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}