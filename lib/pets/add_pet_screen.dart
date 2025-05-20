import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PetProfileScreen extends StatefulWidget {
  /// if petId is null → create new. Otherwise edit existing.
  final String? petId;
  const PetProfileScreen({Key? key, this.petId}) : super(key: key);

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  String? _avatarUrl;
  File? _pickedImage;
  final nameCtrl = TextEditingController();
  String gender = "Male";
  int age = 1;
  double weight = 3.0;

  final uid = FirebaseAuth.instance.currentUser!.uid;
  late CollectionReference petsRef;

  @override
  void initState() {
    super.initState();
    petsRef = FirebaseFirestore.instance
      .collection('users').doc(uid).collection('pets');

    // if editing, fetch existing data
    if (widget.petId != null) {
      petsRef.doc(widget.petId).get().then((snap) {
        final data = snap.data()! as Map<String, dynamic>;
        setState(() {
          nameCtrl.text = data['name'] ?? '';
          gender      = data['gender'] ?? gender;
          age         = data['age'] ?? age;
          weight      = (data['weight'] as num?)?.toDouble() ?? weight;
          _avatarUrl  = data['avatarUrl'];
        });
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? f = await picker.pickImage(source: ImageSource.gallery);
    if (f != null) {
      setState(() => _pickedImage = File(f.path));
    }
  }

  Future<String> _uploadImage(File f) async {
    final path = 'pet_avatars/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref  = FirebaseStorage.instance.ref(path);
    await ref.putFile(f);
    return ref.getDownloadURL();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    String finalUrl = _avatarUrl ?? "";
    if (_pickedImage != null) {
      finalUrl = await _uploadImage(_pickedImage!);
    }

    final payload = {
      'name':       nameCtrl.text.trim(),
      'gender':     gender,
      'age':        age,
      'weight':     weight,
      'avatarUrl':  finalUrl,
      'updatedAt':  FieldValue.serverTimestamp(),
    };

    if (widget.petId == null) {
      // create new
      await petsRef.add({
        ...payload,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      // update existing
      await petsRef.doc(widget.petId).update(payload);
    }

    Get.back(); // return
  }

  Future<void> _delete() async {
    if (widget.petId != null) {
      await petsRef.doc(widget.petId).delete();
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.petId == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? "Add Pet" : "Edit Pet"),
        actions: [
          if (!isNew)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _delete,
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // avatar
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: _pickedImage != null
                      ? FileImage(_pickedImage!)
                      : (_avatarUrl != null
                          ? NetworkImage(_avatarUrl!) 
                          : const AssetImage('assets/icons/default_avatar.png'))
                          as ImageProvider,
                  child: const Icon(Icons.camera_alt, size: 32, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 24),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
              ),

              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: gender,
                items: ['Male','Female'].map((g) =>
                  DropdownMenuItem(value: g, child: Text(g))
                ).toList(),
                onChanged: (v) => setState(() => gender = v!),
                decoration: const InputDecoration(labelText: "Gender"),
              ),

              const SizedBox(height: 16),
              Text("Age: $age y/o"),
              Slider(
                min: 0, max: 15, divisions: 15, label: "$age",
                value: age.toDouble(),
                onChanged: (d) => setState(() => age = d.toInt()),
              ),

              const SizedBox(height: 16),
              Text("Weight: ${weight.toStringAsFixed(1)} kg"),
              Slider(
                min: 0.5, max: 30, divisions: 59, label: "${weight.toStringAsFixed(1)}",
                value: weight,
                onChanged: (d) => setState(() => weight = d),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _save,
                child: Text(isNew ? "Create Profile" : "Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
