import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spacevet_app/color.dart';
import 'package:spacevet_app/pets/add_pet_screen.dart';

class PetProfileView extends StatefulWidget {
  /// the petId that was tapped on HomeScreen, so we can start on that page
  final String initialPetId;
  const PetProfileView({Key? key, required this.initialPetId})
      : super(key: key);

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
          final idx = _docs
              .indexWhere((d) => d.id == widget.initialPetId)
              .clamp(0, _docs.length - 1);
          _pageController =
              PageController(initialPage: idx, viewportFraction: 0.85);
          _hasController = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_docs.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text("Pet Profiles")),
        body: const Center(child: Text("No pets found.")),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Pet Profiles"),
        foregroundColor: AppColors.background,
        backgroundColor: AppColors.primary,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
      ),
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: _docs.length,
          itemBuilder: (ctx, idx) {
            final pet = _docs[idx].data()! as Map<String, dynamic>;
            final petId = _docs[idx].id;
            return _buildProfileCard(context, petId, pet);
          },
        ),
      ),
      
    );
  }

  Widget _buildProfileCard(
      BuildContext context, String petId, Map<String, dynamic> pet) {
    final name = pet['name'] as String? ?? '';
    final age = pet['age'] as int? ?? 0;
    final gender = pet['gender'] as String? ?? '';
    final weight = pet['weight'] as num? ?? 0.0;
    final avatar = pet['avatarUrl'] as String?;

    // height of our header
    const double headerHeight = 200;
    // how much we slide the white card up
    const double overlap = 32;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            // ------ STACK: blue header + avatar + edit + white card ------
            Stack(
              clipBehavior: Clip.none,
              children: [
                // 1) Blue header
                Container(
                  width: double.infinity,
                  height: headerHeight,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  // just to give some padding for the avatar row
                  padding: const EdgeInsets.all(16),
                  child: Align(
  alignment: Alignment.topCenter,    // horizontally center, stick to top
  child: Padding(
    padding: const EdgeInsets.only(top: 20),
    child: CircleAvatar(
      radius: 60,
      backgroundColor: Colors.white24,
      backgroundImage: avatar != null
          ? NetworkImage(avatar)
          : const AssetImage('assets/icons/default_avatar.png')
              as ImageProvider,
    ),
  ),
),

                ),



                // 3) Edit button
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.background),
                    onPressed: () =>
                        Get.to(() => PetProfileScreen(petId: petId)),
                  ),
                ),

                // 4) White details card, slid up by `overlap`
                Transform.translate(
                  offset: const Offset(0, headerHeight - overlap),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 8)
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
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
                ),
              ],
            ),

            // give room for stack + overlap
            SizedBox(height: headerHeight - overlap + 24),

            // ------ ACTIONS ------
            // DELETE PROFILE
TextButton(
  onPressed: () async {
    // 1. Show loading spinner
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    // 2. Perform delete
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('pets')
        .doc(petId)
        .delete();

    // 3. Hide loading
    Get.back();

    // 4. Show success snackbar
    Get.snackbar(
      "Deleted",
      "Pet profile removed successfully",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    // 5. Pop out of this detail‐page
    Get.back();
  },
  child: const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.delete, color: Colors.red),
      SizedBox(width: 8),
      Text("Delete Profile", style: TextStyle(color: Colors.red)),
    ],
  ),
),
// ADD NEW PROFILE BUTTON
Align(
  alignment: Alignment.bottomCenter,
  child: ElevatedButton.icon(
    onPressed: () async {
      // push to Add/Edit screen; wait for it to come back
      await Get.to(() => PetProfileScreen(petId: null));
      // when we return, you might want to show a message:
      Get.snackbar(
        "Ready",
        "You can now add a new pet",
        snackPosition: SnackPosition.BOTTOM,
      );
    },
    icon: const Icon(Icons.add),
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    label: const Text("Add Profile",),
  ),
),
          ],
        ),
      ),
    );
  }

// helper row
  Widget _rowDetail(String label, String value) {
    return Row(
      children: [
        Text("$label:",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
