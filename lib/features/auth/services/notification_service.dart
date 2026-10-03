import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../../firebase_options.dart'; // استيراد خيارات الفايربيز للعمل في عازل الخلفية

// 1. دالة معالجة الإشعارات في الخلفية (يجب أن تكون خارج الـ Class ومحمية بـ pragma)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // تهيئة الفايربيز داخل عازل الخلفية عند وصول إشعار والتطبيق مغلق
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kDebugMode) {
    print('تم استلام إشعار في الخلفية: ${message.messageId}');
  }
}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> requestPermission() async {
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

  static Future<String?> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $token');
      }
      
      // حفظ التوكن في قاعدة البيانات إذا كان المستخدم مسجلاً دخولاً
      if (token != null) {
        await _saveTokenToDatabase(token);
      }
      
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('خطأ أثناء جلب FCM Token: $e');
      }
      return null;
    }
  }

  // 2. تحويل الدالة إلى Future<void> وتفعيل الاستماع في الخلفية
  static Future<void> initNotifications() async {
    // طلب الصلاحيات وجلب التوكن
    await requestPermission();
    await getToken();

    // ربط دالة معالجة الإشعارات في الخلفية والتطبيق مغلق
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // الاستماع لتحديث التوكن تلقائياً
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _saveTokenToDatabase(newToken);
    });

    // الاستماع للإشعارات والتطبيق مفتوح (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('تم استلام إشعار والتطبيق مفتوح: ${message.notification?.title}');
        print('محتوى الإشعار: ${message.notification?.body}');
      }
    });
  }

  // دالة مساعدة لحفظ التوكن في مستند المستخدم بـ Firestore
  static Future<void> _saveTokenToDatabase(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fcmToken': token,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        if (kDebugMode) {
          print('تم حفظ FCM Token بنجاح في قاعدة البيانات للتاجر/المستخدم');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('خطأ أثناء حفظ FCM Token: $e');
      }
    }
  }
}