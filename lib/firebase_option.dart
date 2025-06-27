
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
    apiKey: "YourApiKey",
    authDomain: "ProjectId.firebaseapp.com",
    projectId: "ProjectId",
    storageBucket: "ProjectId.firebasestorage.app",
    messagingSenderId: "messagingSenderId",
    appId: "appId",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "YourApiKey",
    projectId: "ProjectId",
    storageBucket: "ProjectId.firebasestorage.app",
    messagingSenderId: "messagingSenderId",
    appId: "appId",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "YourApiKey",
    projectId: "ProjectId",
    storageBucket: "ProjectId.firebasestorage.app",
    messagingSenderId: "messagingSenderId",
    appId: "appId",
    iosBundleId: "com.your.bundle.id",
  );
}
