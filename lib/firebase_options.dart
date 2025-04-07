// This file was generated using FlutterFire CLI.
// Updated manually to match google-services.json

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyASQ8CPGoVN7GAf0ia0OQA6FTX108Dh5Cw',
    appId: '1:178253537919:android:a543cead5c46c1a43ad54a',
    messagingSenderId: '178253537919',
    projectId: 'garong-app',
    storageBucket: 'garong-app.firebasestorage.app',
    databaseURL:
        'https://garong-app-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAbarYtw9ZKsKflIMUzxQtrPg4sXTU1UO4',
    appId: '1:178253537919:ios:5de30d1dc262f2b63ad54a',
    messagingSenderId: '178253537919',
    projectId: 'garong-app',
    storageBucket: 'garong-app.firebasestorage.app',
    databaseURL:
        'https://garong-app-default-rtdb.asia-southeast1.firebasedatabase.app',
    iosBundleId: 'com.example.utsGarongTest',
  );
}
