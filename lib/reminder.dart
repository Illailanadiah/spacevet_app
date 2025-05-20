import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:spacevet_app/bottomnav_bar.dart';
import 'package:spacevet_app/color.dart';

class AddReminderScreen extends StatefulWidget {
  /// If [existing] is passed, we prefill fields and do an update/delete instead of create.
  final QueryDocumentSnapshot? existing;
  const AddReminderScreen({Key? key, this.existing}) : super(key: key);

  @override
  _AddReminderScreenState createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isReminder = true; // pill vs plan
  String title = '';
  int amount = 1;
  int duration = 1;
  bool foodBefore = true;
  TimeOfDay notificationTime = TimeOfDay.now();

  late CollectionReference _itemsRef;
  bool _loading = false;

  int currentIndex = 2; // Track the selected index for bottom navigation


  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _itemsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('items');

    // if editing, prefill
    if (widget.existing != null) {
      final data = widget.existing!.data()! as Map<String, dynamic>;
      isReminder = (data['category'] ?? 'reminder') == 'reminder';
      title = data['title'] ?? '';
      amount = data['amount'] ?? 1;
      duration = data['duration'] ?? 1;
      foodBefore = (data['foodBefore'] ?? true) as bool;
      final ts = data['timestamp'] as Timestamp;
      notificationTime = TimeOfDay.fromDateTime(ts.toDate());
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: notificationTime,
    );
    if (t != null) setState(() => notificationTime = t);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);
    final now = DateTime.now();
    // Build a DateTime with today's date and chosen time
    final notifDateTime = DateTime(
      now.year, now.month, now.day,
      notificationTime.hour, notificationTime.minute,
    );

    final docData = {
      'category': isReminder ? 'reminder' : 'plan',
      'title': title,
      'amount': amount,
      'duration': duration,
      'foodBefore': foodBefore,
      'timestamp': Timestamp.fromDate(notifDateTime),
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      if (widget.existing != null) {
        await _itemsRef.doc(widget.existing!.id).update(docData);
      } else {
        await _itemsRef.add(docData);
      }
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    if (widget.existing == null) return;
    await _itemsRef.doc(widget.existing!.id).delete();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.existing != null ? 'Edit ${isReminder ? "Reminder" : "Plan"}' : 'Add ${isReminder ? "Reminder" : "Plan"}'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
        leading: BackButton(color: AppColors.background),
        actions: [
          if (widget.existing != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _delete,
            )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Category toggle
                    Text('Categories', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _categoryButton(Icons.medication, 'Reminder', isReminder, () {
                          setState(() => isReminder = true);
                        }),
                        const SizedBox(width: 16),
                        _categoryButton(Icons.event, 'Plan', !isReminder, () {
                          setState(() => isReminder = false);
                        }),
                      ],
                    ),

                    const SizedBox(height: 24),
                    // Title input
                    Text(
                      isReminder ? 'Medicine name' : 'Event title',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: title,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: Icon(isReminder ? Icons.medication : Icons.event),
                        hintText: isReminder ? 'e.g. Oxycodone' : 'e.g. Vet Visit',
                      ),
                      validator: (s) => (s == null || s.isEmpty) ? 'Required' : null,
                      onSaved: (s) => title = s!.trim(),
                    ),

                    const SizedBox(height: 24),
                    // Amount & duration
                    Row(
                      children: [
                        Expanded(
                          child: _numberField(
                            label: 'Amount',
                            value: amount,
                            onChanged: (v) => setState(() => amount = v),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _numberField(
                            label: 'Duration (days)',
                            value: duration,
                            onChanged: (v) => setState(() => duration = v),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    // Food vs Pills icon
                    if (isReminder) ...[
                      Text('Medicine Intake', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _iconToggle(Icons.fastfood, 'Before', foodBefore, () {
                            setState(() => foodBefore = true);
                          }),
                          const SizedBox(width: 16),
                          _iconToggle(Icons.restaurant, 'After', !foodBefore, () {
                            setState(() => foodBefore = false);
                          }),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Notification time
                    Text('Notification', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      tileColor: Colors.grey.shade200,
                      leading: const Icon(Icons.notifications),
                      title: Text(notificationTime.format(context)),
                      trailing: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _pickTime,
                      ),
                    ),

                    const SizedBox(height: 32),
                    // Save slider
                    SlideAction(
                      text: widget.existing != null ? 'Update' : 'Save',
                      innerColor: Colors.white,
                      outerColor: AppColors.primary,
                      onSubmit: _save,
                    ),
                  ],
                ),
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

  Widget _categoryButton(IconData icon, String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(icon, size: 32, color: selected ? Colors.white : AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _numberField({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: '$value',
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (s) {
            final v = int.tryParse(s) ?? 1;
            onChanged(v);
          },
        ),
      ],
    );
  }

  Widget _iconToggle(IconData icon, String semantic, bool selected, VoidCallback onTap) {
    return Expanded(
      child: Semantics(
        label: semantic,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(icon, size: 32, color: selected ? Colors.white : AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }
}

