import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:spacevet_app/bottomnav_bar.dart';
import 'package:spacevet_app/color.dart';
import 'package:spacevet_app/custom_icon.dart';

class AddReminderScreen extends StatefulWidget {
  /// If [existing] is passed, we prefill fields and do an update/delete instead of create.
  final QueryDocumentSnapshot? existing;
  const AddReminderScreen({Key? key, this.existing}) : super(key: key);

  @override
  _AddReminderScreenState createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();

  // category
  bool isReminder = true; // pill vs plan

  // core fields
  String title = '';
  int amount = 1;
  double amountMl = 1.0;
  int timesPerDay = 1;
  bool pillType = true;
  bool foodBefore = true;

  // scheduling
  TimeOfDay notificationTime = TimeOfDay.now();
  DateTime selectedDate = DateTime.now();
  final List<String> _daysOfWeek = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];
  final Set<String> _selectedDays = {};

  late CollectionReference _itemsRef;
  bool _loading = false;
  int currentIndex = 2;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _itemsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('items');

    // if editing, prefill:
    if (widget.existing != null) {
      final data = widget.existing!.data()! as Map<String, dynamic>;
      isReminder = (data['category'] ?? 'reminder') == 'reminder';
      title = data['title'] ?? '';
      amount = data['amount'] ?? 1;
      amountMl = (data['amountMl'] as num?)?.toDouble() ?? 1.0;
      timesPerDay = data['timesPerDay'] ?? 1;
      pillType = data['pillType'] ?? true;
      foodBefore = data['foodBefore'] ?? true;

      final ts = (data['timestamp'] as Timestamp).toDate();
      notificationTime = TimeOfDay.fromDateTime(ts);
      selectedDate = ts;
      final days = (data['days'] as List<dynamic>?)?.cast<String>() ?? [];
      _selectedDays.addAll(days);
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: notificationTime,
    );
    if (t != null) setState(() => notificationTime = t);
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (d != null) setState(() => selectedDate = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);

    // Build a DateTime with today's date at the chosen time:
    final now = DateTime.now();
    final startDT = DateTime(now.year, now.month, now.day,
        notificationTime.hour, notificationTime.minute);

    // milliseconds between doses:
    final intervalMs = (24 * 60 * 60 * 1000) ~/ timesPerDay;

    final docData = {
      'category': isReminder ? 'reminder' : 'plan',
      'title': title,
      'timesPerDay': timesPerDay,
      'startTime': Timestamp.fromDate(startDT),
      'intervalMs': intervalMs,
      'createdAt': FieldValue.serverTimestamp(),
      // … any other fields …
    };

    await _itemsRef.add(docData);

    try {
      if (widget.existing != null) {
        await _itemsRef.doc(widget.existing!.id).update(docData);
      } else {
        await _itemsRef.add(docData);
      }
      // pop back
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
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
        title: Text(widget.existing != null
            ? 'Edit ${isReminder ? "Reminder" : "Plan"}'
            : 'Add ${isReminder ? "Reminder" : "Plan"}'),
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
                    Text('Categories',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Row(children: [
                      _categoryButton(Icons.medication, 'Reminder', isReminder,
                          () {
                        setState(() => isReminder = true);
                      }),
                      const SizedBox(width: 16),
                      _categoryButton(Icons.event, 'Plan', !isReminder, () {
                        setState(() => isReminder = false);
                      }),
                    ]),

                    const SizedBox(height: 24),
                    // Title
                    Text(
                      isReminder ? 'Medicine name' : 'Event title',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: title,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon:
                            Icon(isReminder ? Icons.medication : Icons.event),
                        hintText:
                            isReminder ? 'e.g. Oxycodone' : 'e.g. Vet Visit',
                      ),
                      validator: (s) =>
                          (s == null || s.isEmpty) ? 'Required' : null,
                      onSaved: (s) => title = s!.trim(),
                    ),

                    const SizedBox(height: 24),
                    if (isReminder) ...[
                      // Amount VT
                      Text('Dose Amount',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: pillType ? '$amount' : '$amountMl',
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          suffixText: pillType ? 'pill' : 'ml',
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                            decimal: !pillType, signed: false),
                        inputFormatters: pillType
                            ? [FilteringTextInputFormatter.digitsOnly]
                            : [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}'))
                              ],
                        onSaved: (s) {
                          if (pillType)
                            amount = int.tryParse(s!) ?? amount;
                          else
                            amountMl = double.tryParse(s!) ?? amountMl;
                        },
                      ),

                      const SizedBox(height: 24),
                    ],

                    Row(
                      children: [
                        Icon(Icons.timelapse),
                        const Text('Times per day:'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: timesPerDay,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12))),
                            items: List.generate(6, (i) => i + 1)
                                .map((n) => DropdownMenuItem(
                                    value: n, child: Text('$n')))
                                .toList(),
                            onChanged: (v) => setState(() => timesPerDay = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (isReminder) ...[
                      // Pill type & food before/after
                      Text('Medicine Type',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Row(children: [
                        _iconToggle(CustomIcon.pill_1, 'Pill', pillType, () {
                          setState(() => pillType = true);
                        }),
                        const SizedBox(width: 16),
                        _iconToggle(CustomIcon.liquid, 'Syrup', !pillType, () {
                          setState(() => pillType = false);
                        }),
                      ]),
                      const SizedBox(height: 24),
                      Text('Take Medicine',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Row(children: [
                        _iconToggle(CustomIcon.before_eat, 'Before', foodBefore,
                            () {
                          setState(() => foodBefore = true);
                        }),
                        const SizedBox(width: 16),
                        _iconToggle(CustomIcon.after_eat, 'After', !foodBefore,
                            () {
                          setState(() => foodBefore = false);
                        }),
                      ]),
                      const SizedBox(height: 24),
                    ],

                    // Date picker
                    Text('Select Date',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      tileColor: Colors.grey.shade200,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                          '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}'),
                      trailing: IconButton(
                          icon: const Icon(Icons.edit), onPressed: _pickDate),
                    ),

                    const SizedBox(height: 24),
                    // Days of week
                    Text('Repeat On',
                        style: Theme.of(context).textTheme.titleMedium),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _daysOfWeek.map((d) {
                        final sel = _selectedDays.contains(d);
                        return ChoiceChip(
                          label: Text(d),
                          selected: sel,
                          onSelected: (yes) {
                            setState(() {
                              if (yes)
                                _selectedDays.add(d);
                              else
                                _selectedDays.remove(d);
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),
                    // Time picker
                    Text('Reminder Time',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      tileColor: Colors.grey.shade200,
                      leading: const Icon(Icons.notifications),
                      title: Text(notificationTime.format(context)),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: _pickTime,
                      ),
                    ),

                    const SizedBox(height: 32),
                    // Save slider
                    SlideAction(
                      borderRadius: 12,
                      elevation: 0,
                      innerColor: AppColors.primary,
                      outerColor: AppColors.textSecondary,
                      sliderButtonIcon:
                          const Icon(Icons.check, color: AppColors.background),
                      text: widget.existing != null
                          ? 'Swipe to Update'
                          : 'Swipe to Save',
                      textStyle: const TextStyle(
                          color: AppColors.background, fontSize: 16),
                      onSubmit: () async {
                        await _save();
                        // give the slide a chance to animate back
                        await Future.delayed(const Duration(milliseconds: 300));
                        if (!mounted) return;
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomnavBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
      ),
    );
  }

  Widget _categoryButton(
      IconData icon, String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon,
                  size: 32, color: selected ? Colors.white : AppColors.primary),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      color: selected ? Colors.white : AppColors.primary,
                      fontSize: 12)),
            ])),
      ),
    );
  }

  Widget _iconToggle(
      IconData icon, String semantic, bool selected, VoidCallback onTap) {
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
                child: Icon(icon,
                    size: 32,
                    color: selected ? Colors.white : AppColors.primary)),
          ),
        ),
      ),
    );
  }
}
