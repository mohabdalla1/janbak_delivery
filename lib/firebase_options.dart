// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macOS;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
  apiKey: "AIzaSyBkxkxQUg5t-Ep0RY7M9lWhoPXaw8vse5A",
  authDomain: "janbak-delivery.firebaseapp.com",
  projectId: "janbak-delivery",
  storageBucket: "janbak-delivery.firebasestorage.app",
  messagingSenderId: "726035575772",
  appId: "1:726035575772:web:84fa6f28a356764e87d519",
  measurementId: "G-1PKTSTJ8H0"
  );

  static const FirebaseOptions android = FirebaseOptions(
  apiKey: "AIzaSyBkxkxQUg5t-Ep0RY7M9lWhoPXaw8vse5A",
  authDomain: "janbak-delivery.firebaseapp.com",
  projectId: "janbak-delivery",
  storageBucket: "janbak-delivery.firebasestorage.app",
  messagingSenderId: "726035575772",
  appId: "1:726035575772:web:84fa6f28a356764e87d519",
  measurementId: "G-1PKTSTJ8H0"
  );

  static const FirebaseOptions ios = FirebaseOptions(
  apiKey: "AIzaSyBkxkxQUg5t-Ep0RY7M9lWhoPXaw8vse5A",
  authDomain: "janbak-delivery.firebaseapp.com",
  projectId: "janbak-delivery",
  storageBucket: "janbak-delivery.firebasestorage.app",
  messagingSenderId: "726035575772",
  appId: "1:726035575772:web:84fa6f28a356764e87d519",
  measurementId: "G-1PKTSTJ8H0"
  );

  static const FirebaseOptions macOS = FirebaseOptions(
  apiKey: "AIzaSyBkxkxQUg5t-Ep0RY7M9lWhoPXaw8vse5A",
  authDomain: "janbak-delivery.firebaseapp.com",
  projectId: "janbak-delivery",
  storageBucket: "janbak-delivery.firebasestorage.app",
  messagingSenderId: "726035575772",
  appId: "1:726035575772:web:84fa6f28a356764e87d519",
  measurementId: "G-1PKTSTJ8H0"
  );
}