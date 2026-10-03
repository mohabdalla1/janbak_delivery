// File generated manually for janbak_delivery.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyBkxkxQUg5t-Ep0RY7M9lWhoPXaw8vse5A',
    appId: '1:726035575772:web:0796ffb1b3320ba687d519',
    messagingSenderId: '726035575772',
    projectId: 'janbak-delivery',
    authDomain: 'janbak-delivery.firebaseapp.com',
    storageBucket: 'janbak-delivery.firebasestorage.app',
    measurementId: 'G-W4XMT37HTE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDvRAl7FRUqdtn-I-Ppld0Xuuos1YKZsvw',
    // تم تحديث appId ليطابق التطبيق الجديد com.janbak.delivery.app
    appId: '1:726035575772:android:ac9e314164fac5a487d519',
    messagingSenderId: '726035575772',
    projectId: 'janbak-delivery',
    storageBucket: 'janbak-delivery.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBITgUeD5PGMmitALKrFWf4E-slE8MDNXM',
    appId: '1:726035575772:ios:33d96a00d8f500e687d519',
    messagingSenderId: '726035575772',
    projectId: 'janbak-delivery',
    storageBucket: 'janbak-delivery.firebasestorage.app',
    iosClientId: '726035575772-6lj7l59lj77pfv54tm3j2f23oiba7v5e.apps.googleusercontent.com',
    iosBundleId: 'com.janbak.delivery',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBITgUeD5PGMmitALKrFWf4E-slE8MDNXM',
    appId: '1:726035575772:ios:33d96a00d8f500e687d519',
    messagingSenderId: '726035575772',
    projectId: 'janbak-delivery',
    storageBucket: 'janbak-delivery.firebasestorage.app',
    iosClientId: '726035575772-6lj7l59lj77pfv54tm3j2f23oiba7v5e.apps.googleusercontent.com',
    iosBundleId: 'com.janbak.delivery',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBkxkxQUg5t-Ep0RY7M9lWhoPXaw8vse5A',
    appId: '1:726035575772:web:3523c45c7c5db36d87d519',
    messagingSenderId: '726035575772',
    projectId: 'janbak-delivery',
    authDomain: 'janbak-delivery.firebaseapp.com',
    storageBucket: 'janbak-delivery.firebasestorage.app',
    measurementId: 'G-7SZ6R8ZDG0',
  );
}