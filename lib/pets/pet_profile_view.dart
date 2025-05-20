import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spacevet_app/color.dart';
import 'package:spacevet_app/pets/add_pet_screen.dart';

class PetProfileView extends StatefulWidget {
  /// the petId that was tapped on HomeScreen, so we can start on that page
  final String initialPetId;
  const PetProfileView({Key? key, required this.initialPetId}) : super(key: key);

  @override
  State<PetProfileView> createState() => _PetProfileViewState();
}

class _PetProfileViewState extends State<PetProfileView> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  List<QueryDocumentSnapshot> _docs = [];
  late PageController _pageController;
  bool _hasController = false;

  @override
  void initState() {
    super.initState();
    // listen to the pets collection
    FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('pets')
      .snapshots()
      .listen((snapshot) {
        setState(() {
          _docs = snapshot.docs;
          if (!_hasController && _docs.isNotEmpty) {
            // find index of the tapped pet
            final idx = _docs.indexWhere((d) => d.id == widget.initialPetId).clamp(0, _docs.length - 1);
            _pageController = PageController(initialPage: idx, viewportFraction: 0.85);
            _hasController = true;
          }
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    if (_docs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Pet Profiles")),
        body: const Center(child: Text("No pets found.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Pet Profiles")),
      body: PageView.builder(
        controller: _pageController,
        itemCount: _docs.length,
        itemBuilder: (ctx, idx) {
          final pet = _docs[idx].data()! as Map<String, dynamic>;
          final petId = _docs[idx].id;
          return _buildProfileCard(context, petId, pet);
        },
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, String petId, Map<String,dynamic> pet) {
    final name   = pet['name']    as String? ?? '';
    final age    = pet['age']     as int?    ?? 0;
    final gender = pet['gender']  as String? ?? '';
    final weight = pet['weight']  as num?    ?? 0.0;
    final avatar = pet['avatarUrl'] as String?;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          // BLUE CARD with avatar + edit icon
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // empty space to balance the avatar on the right
                    const Spacer(),
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.white24,
                      backgroundImage:
                          avatar != null ? NetworkImage(avatar) : const AssetImage('assets/icons/default_avatar.png') as ImageProvider,
                    ),
                  ],
                ),
              ),
              // edit button top‐right
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    Get.to(() => PetProfileScreen(petId: petId));
                  },
                ),
              ),
            ],
          ),

          // White details panel overlapping
          Container(
            margin: const EdgeInsets.only(top: -32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [ BoxShadow(color: Colors.black12, blurRadius: 8) ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _rowDetail("Name", name),
                const SizedBox(height: 12),
                _rowDetail("Age", "$age y/o"),
                const SizedBox(height: 12),
                _rowDetail("Gender", gender),
                const SizedBox(height: 12),
                _rowDetail("Weight", "${weight.toStringAsFixed(2)} kg"),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // delete profile
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('pets')
                .doc(petId)
                .delete();
              Get.back(); // go back if you want
            },
            child: const Text("Delete Profile", style: TextStyle(color: Colors.red)),
          ),

          // add new profile button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                Get.to(() => PetProfileScreen(petId: null));
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Profile"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowDetail(String label, String value) {
    return Row(
      children: [
        Text("$label:",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
        ),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
