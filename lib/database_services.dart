import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  final _db = FirebaseFirestore.instance;

  create() {
    try {
      _db.collection("Users").add({
        'name': 'Illaila',
        'email': 'illailanadiah@gmail.com',
        'password': 'Illaila1234'
      });
    } catch (e) {
      // Handle error
      log(e.toString());
    }
    // Create a new user in the database
  }
}
