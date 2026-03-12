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
    apiKey: 'AIzaSyD80lNA-9R-VDc21sruOUyJyN3gJ61Xn0I',
    appId: '1:236206598377:android:8e7bf1731d82d26bd72878',
    messagingSenderId: '236206598377',
    projectId: 'mob-universal',
    storageBucket: 'mob-universal.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDU-RMPZP6ekARld1uA4-WvgoFZubNYJ44',
    appId: '1:236206598377:ios:b8f2f8078bbcba9cd72878',
    messagingSenderId: '236206598377',
    projectId: 'mob-universal',
    storageBucket: 'mob-universal.firebasestorage.app',
    iosBundleId: 'com.maximuschizoba.mob',
  );

}