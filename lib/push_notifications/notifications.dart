
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  String _formatTimestamp(Timestamp ts) {
    final dt = ts.toDate();
    final now = DateTime.now();
    if (dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day) {
      return DateFormat.Hm().format(dt); // e.g. “14:37”
    }
    return DateFormat.yMMMd().add_Hm().format(dt); // e.g. “Jun 23, 14:37”
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final notificationsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notificationsRef.snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = docs[i];
              final data = d.data()! as Map<String, dynamic>;
              final read = data['read'] as bool? ?? false;
              final title = data['title'] as String? ?? '';
              final body = data['body'] as String? ?? '';
              final ts = data['timestamp'] as Timestamp;
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                tileColor: read ? Colors.grey[100] : Colors.white,
                title: Text(
                  title,
                  style: TextStyle(
                    fontWeight: read ? FontWeight.normal : FontWeight.bold,
                    color: read ? Colors.grey[700] : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  body,
                  style: TextStyle(
                    color: read ? Colors.grey[600] : Colors.black54,
                  ),
                ),
                trailing: Text(
                  _formatTimestamp(ts),
                  style: TextStyle(
                    color: read ? Colors.grey : Colors.black45,
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  if (!read) {
                    // mark as read
                    d.reference.update({'read': true});
                  }
                  // optionally: navigate somewhere based on data['itemId']
                },
              );
            },
          );
        },
      ),
    );
  }
}
