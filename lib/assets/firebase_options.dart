// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC-9Qn2vcSYGZbLngJXB2ZFAapVQsj0LW0',
    appId: '1:889381416201:web:f78fef222a119ac01cb7d8',
    messagingSenderId: '889381416201',
    projectId: 'mujdating',
    authDomain: 'mujdating.firebaseapp.com',
    databaseURL: 'https://mujdating-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'mujdating.appspot.com',
    measurementId: 'G-DNPCWREVLW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBc3slZkIZeEx-LTp-ORB5YxoCqXDxe-Lk',
    appId: '1:889381416201:android:c8d56855371ed6921cb7d8',
    messagingSenderId: '889381416201',
    projectId: 'mujdating',
    databaseURL: 'https://mujdating-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'mujdating.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCWs65a8xw3TcaPNZCX9wRi7h8tKkDi15A',
    appId: '1:889381416201:ios:cafbeeeeff282e8d1cb7d8',
    messagingSenderId: '889381416201',
    projectId: 'mujdating',
    databaseURL: 'https://mujdating-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'mujdating.appspot.com',
    iosBundleId: 'com.example.demo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCWs65a8xw3TcaPNZCX9wRi7h8tKkDi15A',
    appId: '1:889381416201:ios:754eb5c65fb702271cb7d8',
    messagingSenderId: '889381416201',
    projectId: 'mujdating',
    databaseURL: 'https://mujdating-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'mujdating.appspot.com',
    iosBundleId: 'com.example.demo.RunnerTests',
  );
}
