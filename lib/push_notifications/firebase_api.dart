import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {

  //create an instance of Firebase Messaging
  final _firebaseMessaging = FirebaseMessaging.instance;
  //function to initialize notifications
  Future<void> initNotifications() async {
    // Request permission from the user
    await _firebaseMessaging.requestPermission();
    //fetch the FCM token for this device
    final fCMToken = await _firebaseMessaging.getToken();
    //print the token (normally you would send this token to your server)
    print('Token: $fCMToken');
  }

  //funtion to handle receive messages

  //function to initialize foreground and background settings
}
