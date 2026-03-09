import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('This platform is not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBPw29Y4ouBwbaySe4BuJAuFmkUQK9SQ-c',
    appId: '1:670264828398:android:e168443d4b0aaa3285aeff',
    messagingSenderId: '670264828398',
    projectId: 'mob-app-a12ff',
    storageBucket: 'mob-app-a12ff.firebasestorage.app',
  );


  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: '670264828398',
    projectId: 'mob-app-a12ff',
    storageBucket: 'mob-app-a12ff.firebasestorage.app',
    iosBundleId: 'com.mob.app',
  );
}
