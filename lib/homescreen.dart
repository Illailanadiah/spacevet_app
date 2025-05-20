import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacevet_app/color.dart';
import 'package:spacevet_app/notifications.dart';
import 'package:spacevet_app/pets/pet_profile_view.dart';
import 'package:spacevet_app/bottomnav_bar.dart';
import 'package:spacevet_app/reminder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  final user = FirebaseAuth.instance.currentUser;
  late String userId;
  late Stream<DocumentSnapshot> userStream;

  bool isBiometricEnabled = false;
  int currentIndex = 0;
  bool _showUpcoming = true;

  @override
  void initState() {
    super.initState();
    userId = user!.uid;
    userStream =
        FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
    _loadAndMaybeAuthenticate();
  }

  /// 1) Load the user's preference from Firestore
  /// 2) If enabled, run biometric auth once per app launch
  Future<void> _loadAndMaybeAuthenticate() async {
    final prefs = await SharedPreferences.getInstance();

    // A) Check if we've already done the biometric check this session
    final alreadyDone = prefs.getBool('biometric_authenticated') ?? false;
    if (alreadyDone) return;

    // B) Load their preference flag from Firestore
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists && (doc.data()?['biometric_enabled'] ?? false) == true) {
      setState(() => isBiometricEnabled = true);
      await _authenticateWithBiometrics();
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    final prefs = await SharedPreferences.getInstance();
    final canCheck = await _auth.canCheckBiometrics;
    if (!canCheck) {
      Get.snackbar("Error", "Biometric not available",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final didAuth = await _auth.authenticate(
      localizedReason: "Scan your fingerprint to continue",
      options: const AuthenticationOptions(biometricOnly: true),
    );

    if (didAuth) {
      await prefs.setBool('biometric_authenticated', true);
      Get.snackbar("Success", "Authenticated!",
          backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar("Failed", "Fingerprint auth failed",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning!";
    if (hour < 18) return "Good Afternoon!";
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
              // --- Header Row ---
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: userStream,
                      builder: (ctx, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        final name = snap.data?['name'] as String? ?? 'Guest';
                        return Text(
                          'Hi, $name !',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary ),
                              textAlign: TextAlign.center,
                        );
                      },
                    ),
                    IconButton(
                        icon: const Icon(Icons.notifications_active_outlined,
                            color: AppColors.textPrimary),
                        onPressed: () {
                          Get.to(() => Notifications());
                        }
                        ),
                  ],
                ),
              ),

              // --- Greeting ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  getGreeting(),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 20),

              // --- Pet Carousel ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 220,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('pets')
                        .snapshots(),
                    builder: (ctx, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snap.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return const Center(
                            child: Text('No pets yet, add a profile!'));
                      }
                      return PageView.builder(
                        controller: PageController(viewportFraction: 0.8),
                        itemCount: docs.length,
                        itemBuilder: (ctx, i) {
                          final pet = docs[i];
                          return _buildPetCard(
                            name: pet['name'],
                            age: pet['age'],
                            gender: pet['gender'],
                            weight: pet['weight'],
                            photoUrl: pet['avatarUrl'],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Event / Reminder Section ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildEventSection(),
              ),
            ],
          ),
        ),
      ),

      // --- Bottom Navigation ---
      bottomNavigationBar: BottomnavBar(
        currentIndex: currentIndex,
        onTap: (idx) => setState(() => currentIndex = idx),
      ),
    );
  }

  Widget _buildPetCard({
    required String name,
    required int age,
    required String gender,
    required double weight,
    required String photoUrl,
  }) {
    return GestureDetector(
      onTap: () => Get.to(() => PetProfileView(initialPetId: '')),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  const Icon(Icons.pets,color: Colors.white, size: 16),
                  Text(name,style: const TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.cake, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text('$age y/o', style: const TextStyle(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.male, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(gender, style: const TextStyle(color: Colors.white)),

                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.monitor_weight, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
              Text('${weight.toStringAsFixed(2)} kg',
                  style: const TextStyle(color: Colors.white)),
            ]),
            const Spacer(),
            CircleAvatar(radius: 40, backgroundImage: NetworkImage(photoUrl)),
          ],
        ),
          ],
      
    ),
      ),
    );
  }

  Widget _buildEventSection() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final itemsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('items')
        .orderBy('timestamp', descending: false);

    return StreamBuilder<QuerySnapshot>(
      stream: itemsRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return const SizedBox(); // nothing to show

        final now = DateTime.now();
        // partition docs:
        final upcomingDocs = <QueryDocumentSnapshot>[];
        final pastDocs = <QueryDocumentSnapshot>[];

        for (var doc in snapshot.data!.docs) {
          final ts = (doc['timestamp'] as Timestamp).toDate();
          if (ts.isAfter(now))
            upcomingDocs.add(doc);
          else
            pastDocs.add(doc);
        }

        final displayDocs = _showUpcoming ? upcomingDocs : pastDocs;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TAB SELECTOR
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _showUpcoming = true),
                    child: Text(
                      'Upcoming',
                      style: TextStyle(
                        color: _showUpcoming ? Colors.white : Colors.white54,
                        fontWeight:
                            _showUpcoming ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () => setState(() => _showUpcoming = false),
                    child: Text(
                      'Past',
                      style: TextStyle(
                        color: !_showUpcoming ? Colors.white : Colors.white54,
                        fontWeight: !_showUpcoming
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // LIST OF CARDS
              if (displayDocs.isEmpty)
                Text(
                  _showUpcoming ? 'No upcoming items.' : 'No past items.',
                  style: const TextStyle(color: Colors.white70),
                )
              else
                ...displayDocs.map((doc) {
                  final data = doc.data()! as Map<String, dynamic>;
                  final title = data['title'] as String? ?? '';
                  final ts = (data['timestamp'] as Timestamp).toDate();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildEventCard(
                      icon: data['category'] == 'reminder'
                          ? Icons.medication
                          : Icons.event_note,
                      title: title,
                      time: _formatTimestamp(ts),
                      onTap: () {
                        // e.g. navigate to edit screen
                        Get.to(() => AddReminderScreen(existing: doc));
                      },
                    ),
                  );
                }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventCard({
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
        child: Row(
          children: [
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
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final datePart =
        (dt.year == now.year && dt.month == now.month && dt.day == now.day)
            ? 'Today'
            : '${dt.month}/${dt.day}/${dt.year}';
    final timePart = TimeOfDay.fromDateTime(dt).format(context);
    return '$datePart | $timePart';
  }
}
