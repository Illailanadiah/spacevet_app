import 'package:flutter/material.dart';

class SymptomDetection extends StatefulWidget {
  const SymptomDetection({super.key});

  @override
  State<SymptomDetection> createState() => _SymptomDetectionState();
}

class _SymptomDetectionState extends State<SymptomDetection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar(
        title: const Text('Symptom Detection'),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Symptom Detection Screen',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Add your symptom detection logic here
                },
                child: const Text('Detect Symptoms'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}