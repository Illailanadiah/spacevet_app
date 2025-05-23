import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spacevet_app/color.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final notifs = FirebaseFirestore.instance
      .collection('users').doc(uid)
      .collection('notifications')
      .orderBy('timestamp', descending: true);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text("Notifications"),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.background,
      centerTitle: true,
      shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notifs.snapshots(),
        builder: (ctx,snap) {
          if(!snap.hasData) return Center(child:CircularProgressIndicator());
          final docs = snap.data!.docs;
          if(docs.isEmpty) return Center(child:Text("No notifications"));
          return ListView.builder(
            itemCount:docs.length,
            itemBuilder:(_,i){
              final d = docs[i];
              final data = d.data()! as Map<String,dynamic>;
              final read = data['read'] as bool? ?? false;
              return ListTile(
                title: Text(data['title'],
                  style: TextStyle(
                    color: read?Colors.grey:AppColors.textPrimary
                  )),
                subtitle: Text(data['body'],
                  style: TextStyle(
                    color: read?Colors.grey:AppColors.textSecondary
                  )),
                trailing: read?null:Icon(Icons.circle,size:10,color:AppColors.primary),
                onTap: (){
                  // mark read
                  d.reference.update({'read':true});
                },
              );
            }
          );
        }
      ),
    );
  }
}
