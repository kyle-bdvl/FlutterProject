
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyAsMp_oeW1KNMOweBV-iJQ8ubTolDucBKw",
    authDomain: "certificateapp-43f4c.firebaseapp.com",
    projectId: "certificateapp-43f4c",
    storageBucket: "certificateapp-43f4c.firebasestorage.app",
    messagingSenderId: "94865691318",
    appId: "1:94865691318:android:7b99db7059decd07848c17",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyAsMp_oeW1KNMOweBV-iJQ8ubTolDucBKw",
    projectId: "certificateapp-43f4c",
    storageBucket: "certificateapp-43f4c.firebasestorage.app",
    messagingSenderId: "94865691318",
    appId: "1:94865691318:android:7b99db7059decd07848c17",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyAsMp_oeW1KNMOweBV-iJQ8ubTolDucBKw",
    projectId: "certificateapp-43f4c",
    storageBucket: "certificateapp-43f4c.firebasestorage.app",
    messagingSenderId: "94865691318",
    appId: "1:94865691318:android:7b99db7059decd07848c17",
    iosBundleId: "com.your.bundle.id",
  );
}