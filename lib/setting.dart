import 'package:flutter/material.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ListTile(
              title: const Text("Secure Account"),
              subtitle: const Text("Enable two-factor authentication"),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // Handle switch change
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}