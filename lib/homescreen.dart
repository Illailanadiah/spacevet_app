import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacevet_app/color.dart';
import 'package:spacevet_app/push_notifications/notifications.dart';
import 'package:spacevet_app/pets/pet_profile_view.dart';
import 'package:spacevet_app/bottomnav_bar.dart';
import 'package:spacevet_app/reminder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = LocalAuthentication();
  final _user = FirebaseAuth.instance.currentUser!;
  late final String _uid;
  late final Stream<DocumentSnapshot> _userStream;

  bool _isBiometricEnabled = false;
  int _currentIndex = 0;
  bool _showUpcoming = true;

  @override
  void initState() {
    super.initState();
    _uid = _user.uid;
    _userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .snapshots();
    _initBiometricFlow();
  }

  Future<void> _initBiometricFlow() async {
    final prefs = await SharedPreferences.getInstance();
    // Already done once this session?
    if (prefs.getBool('biometric_authenticated') ?? false) return;

    // Read flag from Firestore (default = false)
    final shouldAuth = await _readBiometricFlag();
    if (shouldAuth) {
      final didAuth = await _authenticateWithBiometrics();
      if (didAuth) {
        await prefs.setBool('biometric_authenticated', true);
      }
    } else {
      // mark it done for this session so we don't keep asking
      await prefs.setBool('biometric_authenticated', true);
    }
  }

  Future<bool> _readBiometricFlag() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .get();
    final data = doc.data() ?? {};
    final enabled = data['biometric_enabled'];
    return enabled is bool && enabled;
  }

  Future<bool> _authenticateWithBiometrics() async {
    final canCheck = await _auth.canCheckBiometrics;
    if (!canCheck) {
      Get.snackbar("Error", "Biometric not available",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    final didAuth = await _auth.authenticate(
      localizedReason: "Scan your fingerprint to continue",
      options: const AuthenticationOptions(biometricOnly: true),
    );

    Get.snackbar(
      didAuth ? "Success" : "Failed",
      didAuth ? "Authenticated!" : "Fingerprint auth failed",
      backgroundColor: didAuth ? Colors.green : Colors.red,
      colorText: Colors.white,
    );

    if (didAuth) setState(() => _isBiometricEnabled = true);
    return didAuth;
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return "Good Morning!";
    if (h < 18) return "Good Afternoon!";
    return "Good Evening!";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // — Header Row —
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: _userStream,
                      builder: (ctx, snap) {
                        if (snap.connectionState == ConnectionState.waiting)
                          return const CircularProgressIndicator();
                        final data = snap.data?.data() as Map<String, dynamic>? ?? {};
                        final name = data['name'] as String? ?? 'Guest';
                        return Text(
                          'Hi, $name!',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_active_outlined,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => Get.to(() => Notifications()),
                    ),
                  ],
                ),
              ),

              // — Greeting —
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _greeting(),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 20),

              // — Pet Carousel —
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 220,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(_uid)
                        .collection('pets')
                        .snapshots(),
                    builder: (ctx, snap) {
                      if (snap.connectionState == ConnectionState.waiting)
                        return const Center(
                            child: CircularProgressIndicator());
                      final docs = snap.data?.docs ?? [];
                      if (docs.isEmpty)
                        return const Center(
                            child: Text('No pets yet, add a profile!'));
                      return PageView.builder(
                        controller: PageController(viewportFraction: 0.8),
                        itemCount: docs.length,
                        itemBuilder: (ctx, i) {
                          final pet = docs[i].data()! as Map<String, dynamic>;
                          return _petCard(pet);
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // — Event / Reminder Section —
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _eventSection(),
              ),
            ],
          ),
        ),
      ),

      // — Bottom Navigation Bar —
      bottomNavigationBar: BottomnavBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
      ),
    );
  }

  Widget _petCard(Map<String, dynamic> pet) {
    return GestureDetector(
      onTap: () {
        Get.to(() => PetProfileView(initialPetId: '',));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.pets, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(pet['name'] as String,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16)),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.cake, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text('${pet['age']} y/o',
                          style: const TextStyle(color: Colors.white)),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.male, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(pet['gender'] as String,
                          style: const TextStyle(color: Colors.white)),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.monitor_weight,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text('${(pet['weight'] as num).toStringAsFixed(2)} kg',
                          style: const TextStyle(color: Colors.white)),
                    ]),
                  ]),
            ),
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(pet['avatarUrl'] as String),
            ),
          ],
        ),
      ),
    );
  }

  Widget _eventSection() {
    final itemsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('items')
        .orderBy('timestamp');

    return StreamBuilder<QuerySnapshot>(
      stream: itemsRef.snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) return const SizedBox();

        final now = DateTime.now();
        final upcoming = <QueryDocumentSnapshot>[];
        final past = <QueryDocumentSnapshot>[];

        for (var d in docs) {
          final dt = (d['timestamp'] as Timestamp).toDate();
          if (dt.isAfter(now))
            upcoming.add(d);
          else
            past.add(d);
        }

        final display = _showUpcoming ? upcoming : past;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle
              Row(children: [
                _tabLabel("Upcoming", _showUpcoming, () {
                  setState(() => _showUpcoming = true);
                }),
                const SizedBox(width: 20),
                _tabLabel("Past", !_showUpcoming, () {
                  setState(() => _showUpcoming = false);
                }),
              ]),
              const SizedBox(height: 20),

              if (display.isEmpty)
                Text(
                  _showUpcoming ? "No upcoming items." : "No past items.",
                  style: const TextStyle(color: Colors.white70),
                )
              else
                ...display.map((d) {
                  final data = d.data()! as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _eventCard(
                      icon: data['category'] == 'reminder'
                          ? Icons.medication
                          : Icons.event_note,
                      title: data['title'] as String,
                      time: _formatTimestamp(
                          (data['timestamp'] as Timestamp).toDate()),
                      onTap: () => Get.to(
                          () => const AddReminderScreen() /*pass existing*/),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _tabLabel(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : Colors.white54,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _eventCard({
    required IconData icon,
    required String title,
    required String time,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(time,
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ]),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final date = (dt.year == now.year && dt.month == now.month && dt.day == now.day)
        ? 'Today'
        : '${dt.month}/${dt.day}/${dt.year}';
    final time = TimeOfDay.fromDateTime(dt).format(context);
    return '$date | $time';
  }
}
