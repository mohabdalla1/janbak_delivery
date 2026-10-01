import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('تم منح صلاحيات الإشعارات بنجاح');
      }
    } else {
      if (kDebugMode) {
        print('تم رفض صلاحيات الإشعارات');
      }
    }
  }

  Future<String?> getToken() async {
    String? token = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print('FCM Token: $token');
    }
    return token;
  }

  void initNotifications() {
    requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('تم استلام إشعار والتطبيق مفتوح: ${message.notification?.title}');
      }
    });
  }
}