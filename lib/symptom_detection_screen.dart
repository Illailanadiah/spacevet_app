import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:spacevet_app/bottomnav_bar.dart';
import 'package:spacevet_app/color.dart';

class SymptomDetectionScreen extends StatefulWidget {
  const SymptomDetectionScreen({Key? key}) : super(key: key);

  @override
  _SymptomDetectionScreenState createState() => _SymptomDetectionScreenState();
}

class _SymptomDetectionScreenState extends State<SymptomDetectionScreen> {
  File? _pickedImage;

   Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, maxWidth: 800);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

    void _clearImage() {
    setState(() => _pickedImage = null);
  }

    Future<void> _onSwipeContinue() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Continuing to detection...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cornerLength  = 40.0;
    final cornerThickness = 4.0;

      int currentIndex = 1; // Track the selected index for bottom navigation


    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Symptom Detection'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
        leading: BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            const Text(
              'Upload Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // --- image box with corner accents ---
             Center(
              child: Stack(
                children: [
                  // 1) The image / placeholder
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 260,
                      height: 260,
                      color: AppColors.background,
                      child: _pickedImage == null
                          ? const Icon(Icons.image_not_supported,
                              size: 80, color: Colors.grey)
                          : Image.file(_pickedImage!, fit: BoxFit.cover),
                    ),
                  ),


                  // 2) Cancel icon to retake/choose another
                  if (_pickedImage != null)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: _clearImage,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.close,
                              size: 20, color: Colors.white),
                        ),
                      ),
                    ),

                  // 3) Corner accents
                  // Top-left
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Column(
                      children: [
                        Container(
                          width: cornerLength,
                          height: cornerThickness,
                          color: AppColors.primary,
                        ),
                        Container(
                          width: cornerThickness,
                          height: cornerLength,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  // Top-right
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          width: cornerLength,
                          height: cornerThickness,
                          color: AppColors.primary,
                        ),
                        Container(
                          width: cornerThickness,
                          height: cornerLength,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  // Bottom-left
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Column(
                      children: [
                        Container(
                          width: cornerThickness,
                          height: cornerLength,
                          color: AppColors.primary,
                        ),
                        Container(
                          width: cornerLength,
                          height: cornerThickness,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  // Bottom-right
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          width: cornerThickness,
                          height: cornerLength,
                          color: AppColors.primary,
                        ),
                        Container(
                          width: cornerLength,
                          height: cornerThickness,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

              // === Camera / Gallery buttons ===
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Camera
                InkWell(
                  onTap: () => _pickImage(ImageSource.camera),
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Icon(Icons.camera_alt,
                        size: 32, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 32),
                // Gallery
                InkWell(
                  onTap: () => _pickImage(ImageSource.gallery),
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Icon(Icons.photo_library,
                        size: 32, color: Colors.white),
                  ),
                ),
              ],
            ),



           
            const SizedBox(height: 32),
             // === Swipe to continue ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SlideAction(
                innerColor: AppColors.primary,
                outerColor: AppColors.textSecondary,
                text: 'Swipe to Continue',
                textStyle:
                    const TextStyle(color: AppColors.background, fontSize: 16),
                onSubmit: _onSwipeContinue,
                sliderButtonIcon: const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.background,
                ),
                borderRadius: 12,
                elevation: 0,
              ),
            ),
          ],
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
