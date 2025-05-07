import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spacevet_app/color.dart';
import 'package:spacevet_app/home_screen.dart';

class PetProfileScreen extends StatefulWidget {
  const PetProfileScreen({super.key, required String petId});

  @override
  _PetProfileScreenState createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _petImage;
  final TextEditingController _petNameController = TextEditingController();
  String? _selectedGender = 'Male';
  int _petAge = 1;
  double _petWeight = 3.0;

  final List<String> _genders = ['Male', 'Female'];
// 0-10 years

  // Function to pick an image from the gallery or camera
  Future<void> _pickPetImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _petImage = File(image.path);
      });
    }
  }

  // Save pet data to Firestore
  Future<void> _savePetProfile(String petName, String petGender, int petAge,
      double petWeight, String petImageUrl) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Assuming you have a 'users' collection and pet data will be stored under user UID
    await firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('pets')
        .add({
      'name': petName,
      'gender': petGender,
      'age': petAge,
      'weight': petWeight,
      'avatarUrl': petImageUrl,
    });
  }

  Future<String> _uploadImage(File image) async {
    String fileName =
        'pet_avatars/${DateTime.now().millisecondsSinceEpoch}.png';
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(fileName);
    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Pet Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Pet Avatar - Image Picker
              GestureDetector(
                onTap: _pickPetImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blueGrey,
                  backgroundImage: _petImage != null
                      ? FileImage(_petImage!)
                      : const AssetImage('assets/icons/default_avatar.png')
                          as ImageProvider,
                  child: _petImage == null
                      ? const Icon(Icons.camera_alt, color: AppColors.textSecondary)
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Pet Name - Text Field
              TextField(
                controller: _petNameController,
                decoration: InputDecoration(
                  labelText: 'Pet Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Pet Gender - Dropdown Menu
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: _genders.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Pet Gender',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Pet Age - Slider (adjusted to work with age range)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pet Age (years)', style: TextStyle(fontSize: 16)),
                  Slider(
                    value: _petAge.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: _petAge.toString(),
                    onChanged: (double newValue) {
                      setState(() {
                        _petAge = newValue.toInt();
                      });
                    },
                  ),
                  Text('$_petAge years', style: const TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 20),

              // Pet Weight - Slider (adjusted to a smaller range)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pet Weight (kg)', style: TextStyle(fontSize: 16)),
                  Slider(
                    value: _petWeight,
                    min: 1.0,
                    max: 20.0,
                    divisions: 20,
                    label: _petWeight.toStringAsFixed(1),
                    onChanged: (double newValue) {
                      setState(() {
                        _petWeight = newValue;
                      });
                    },
                  ),
                  Text('${_petWeight.toStringAsFixed(2)} kg',
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 40),

              // Save Button
              ElevatedButton(
                onPressed: () async {
                  String petName = _petNameController.text;
                  String petGender = _selectedGender ?? 'Not selected';

                  if (_petImage != null) {
                    String petImageUrl = await _uploadImage(_petImage!);
                    await _savePetProfile(
                        petName, petGender, _petAge, _petWeight, petImageUrl);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Pet profile saved successfully!')),
                    );
                    Get.to(HomeScreen()); // Go back to the previous screen
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select a pet image.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Profile',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
