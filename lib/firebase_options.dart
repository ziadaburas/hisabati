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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBDiT6Vtz1ZmEJWme7YouMolvBwKiCj4mg",
    authDomain: "own7xledger.firebaseapp.com",
    projectId: "own7xledger",
    storageBucket: "own7xledger.firebasestorage.app",
    messagingSenderId: "326847435666",
    appId: "1:326847435666:web:85137e188f2f531b41a74b",
    measurementId: "G-DR1FKZLE9K"
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD1YsS6Xh1nO5V2hIfkJJH_pyLTL-iI1t0',
    appId: '1:326847435666:android:f27535f38a1310f541a74b',
    messagingSenderId: '326847435666',
    projectId: 'own7xledger',
    storageBucket: 'own7xledger.firebasestorage.app',
  );
}
