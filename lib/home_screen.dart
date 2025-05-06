import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spacevet_app/color.dart'; // Adjust your app color
import 'package:spacevet_app/drawer_screen.dart';
import 'package:spacevet_app/pet_profile_screen.dart';
import 'package:spacevet_app/symptom_detection_screen.dart'; // Import your hidden drawer

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  bool isDrawerOpen = false;

  final user = FirebaseAuth.instance.currentUser;
  late String userId;
  late Stream<DocumentSnapshot> userStream;

  @override
  void initState() {
    super.initState();
    userId = user!.uid;
    // Stream to listen to user document
    userStream = FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const DrawerScreen(), // Hidden drawer screen
          AnimatedContainer(
            transform: Matrix4.translationValues(xOffset, yOffset, 0)..scale(scaleFactor),
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: isDrawerOpen ? BorderRadius.circular(30) : BorderRadius.zero,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: toggleDrawer,
                            child: Icon(
                              isDrawerOpen ? Icons.arrow_back_ios : Icons.menu,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          // Fetch the user's nickname and display it
                          StreamBuilder<DocumentSnapshot>(
                            stream: userStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }

                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }

                              if (!snapshot.hasData || snapshot.data == null) {
                                return Text('Error: No data found');
                              }

                              // Get the nickname from Firestore
                              var userData = snapshot.data!;
                              String userNickname = userData['name'] ?? 'Guest';

                              return Text(
                                'Hi, $userNickname',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.textPrimary),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => PetProfileScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Pet Info Section (Dynamically Loaded from Firestore)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        height: 220,
                        child: PageView(
                          controller: PageController(viewportFraction: 0.8),
                          children: [
                            _buildPetCard(
                              name: 'Alex',
                              size: '2 y/o',
                              weight: '2.5kg',
                              photoUrl: 'assets/icons/avatar.png',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Symptom Detection Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SymptomDetection()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.pets, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Symptom Detection",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Upcoming Events
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildEventSection(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void toggleDrawer() {
    setState(() {
      if (isDrawerOpen) {
        xOffset = 0;
        yOffset = 0;
        scaleFactor = 1;
        isDrawerOpen = false;
      } else {
        xOffset = 230;
        yOffset = 150;
        scaleFactor = 0.7;
        isDrawerOpen = true;
      }
    });
  }

  Widget _buildPetCard({
    required String name,
    required String size,
    required String weight,
    required String photoUrl,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(size, style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(weight, style: const TextStyle(color: Colors.white)),
                ],
              ),
              const Spacer(),
              CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(photoUrl),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('Upcoming', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(width: 20),
              Text('Past', style: TextStyle(color: Colors.white54)),
            ],
          ),
          const SizedBox(height: 20),
          _buildEventCard(Icons.medication, "Medicine name", "Today | 10:00 AM"),
          const SizedBox(height: 12),
          _buildEventCard(Icons.event_note, "Event name", "Today | 10:00 AM"),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('See More', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(IconData icon, String title, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(time, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
