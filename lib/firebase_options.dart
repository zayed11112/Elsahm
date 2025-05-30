// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyBco6LHTdUotjBpqwzAwLMOh4A6ERcfgxI',
    appId: '1:992039187831:web:d84c394088380e5ca71d72',
    messagingSenderId: '992039187831',
    projectId: 'elsahm-d8ebd',
    authDomain: 'elsahm-d8ebd.firebaseapp.com',
    storageBucket: 'elsahm-d8ebd.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCHeJEN-Lv_Lt4YOLguWi81PlYpYBbk8JA',
    appId: '1:992039187831:android:cdc60a9dd021fd99a71d72',
    messagingSenderId: '992039187831',
    projectId: 'elsahm-d8ebd',
    storageBucket: 'elsahm-d8ebd.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAVabwLNb49un9jBRC4MqN3Cmx2PALbMk8',
    appId: '1:992039187831:ios:da498421bc792c6ca71d72',
    messagingSenderId: '992039187831',
    projectId: 'elsahm-d8ebd',
    storageBucket: 'elsahm-d8ebd.firebasestorage.app',
    iosBundleId: 'com.example.elsahmApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAVabwLNb49un9jBRC4MqN3Cmx2PALbMk8',
    appId: '1:992039187831:ios:da498421bc792c6ca71d72',
    messagingSenderId: '992039187831',
    projectId: 'elsahm-d8ebd',
    storageBucket: 'elsahm-d8ebd.firebasestorage.app',
    iosBundleId: 'com.example.elsahmApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBco6LHTdUotjBpqwzAwLMOh4A6ERcfgxI',
    appId: '1:992039187831:web:0433e9cafd697f0ea71d72',
    messagingSenderId: '992039187831',
    projectId: 'elsahm-d8ebd',
    authDomain: 'elsahm-d8ebd.firebaseapp.com',
    storageBucket: 'elsahm-d8ebd.firebasestorage.app',
  );
}
