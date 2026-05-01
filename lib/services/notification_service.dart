import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  NotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> init() async {
    await _requestPermission();
    await _saveCurrentToken();
    _listenTokenRefresh();
    _listenForegroundMessages();
  }

  static Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> _saveCurrentToken() async {
    final token = await _messaging.getToken();
    print('FCM TOKEN: $token');
    await _saveTokenToFirestore(token);
  }

  static void _listenTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print('NEW FCM TOKEN: $newToken');
      await _saveTokenToFirestore(newToken);
    });
  }

  static void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('FCM MESSAGE: ${message.notification?.title}');
    });
  }

  static Future<void> _saveTokenToFirestore(String? token) async {
    final user = _auth.currentUser;

    if (user == null || token == null) return;

    await _db.collection('users').doc(user.uid).update({
      'fcmToken': token,
      'fcmUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<String?> getToken() async {
    return _messaging.getToken();
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    print('NOTIFICATION: $title - $body');
  }
}