import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:spacevet_app/firebase_options.dart';
import 'package:spacevet_app/wrapper.dart';

/// 1️⃣ Background message handler must be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Flutter binding & Firebase are initialized
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // You could also show a local notification here if desired
  // (but for most “notification” payloads Android will display it automatically)
}

final FlutterLocalNotificationsPlugin _localNotif =
    FlutterLocalNotificationsPlugin();

// 2️⃣ Define your Android channel
const AndroidNotificationChannel _defaultChannel = AndroidNotificationChannel(
  'default_channel', // id
  'Default Notifications', // title
  description: 'General purpose notifications', // desc
  importance: Importance.max,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3️⃣ Create the notification channel on Android
  await _localNotif
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_defaultChannel);

  // 4️⃣ Initialize flutter_local_notifications
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings(); // if you want iOS taps
  await _localNotif.initialize(
    const InitializationSettings(android: androidInit, iOS: iosInit),
    onDidReceiveNotificationResponse: (response) {
      // 7️⃣ Handle when the user taps on a local notification
      // For example, navigate to a specific screen:
      final payload = response.payload;
      if (payload != null) {
        // Get.toNamed('/someRoute', arguments: payload);
      }
    },
  );

  // 5️⃣ Register your background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _configureFCM();
  }

  Future<void> _configureFCM() async {
    final fcm = FirebaseMessaging.instance;

    // 6️⃣ Request permissions on iOS/Android 13+
    await fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Grab the FCM token & store it
    final token = await fcm.getToken();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && token != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'fcmToken': token});
    }

    // Foreground messages → show a local notification
    FirebaseMessaging.onMessage.listen((msg) {
      final n = msg.notification;
      if (n != null) {
        _localNotif.show(
          n.hashCode,
          n.title,
          n.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _defaultChannel.id,
              _defaultChannel.name,
              channelDescription: _defaultChannel.description,
              importance: Importance.max,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          // you can pass msg.data as payload if you need to act on taps
          payload: msg.data['someKey'],
        );
      }
    });

    // 8️⃣ When user taps on an FCM notification (app in background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      // e.g. navigate to a detail page
      final data = msg.data;
      if (data['screen'] != null) {
        Get.toNamed(data['screen'], arguments: data);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SpaceVet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: const Wrapper(),
    );
  }
}
