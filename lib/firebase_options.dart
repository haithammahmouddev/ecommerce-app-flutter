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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBRmDQ5I8lBw2i2iFX8z3Culzh8fiRKYFE',
    appId: '1:601648007192:web:9f23509c7723e5c3f7db6d',
    messagingSenderId: '601648007192',
    projectId: 'fit-store-b7042',
    authDomain: 'fit-store-b7042.firebaseapp.com',
    storageBucket: 'fit-store-b7042.firebasestorage.app',
    measurementId: 'G-T9RE0KF52S',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCrBAsz2WNZRNXTvRsBi3TorS2uGPpdF6Y',
    appId: '1:601648007192:android:f5210fd58ebbba40f7db6d',
    messagingSenderId: '601648007192',
    projectId: 'fit-store-b7042',
    storageBucket: 'fit-store-b7042.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAgLaGb4Yf-4ulwaAAxy8JM7JzNXG19asI',
    appId: '1:601648007192:ios:5e45b8e3f42af969f7db6d',
    messagingSenderId: '601648007192',
    projectId: 'fit-store-b7042',
    storageBucket: 'fit-store-b7042.firebasestorage.app',
    iosClientId: '601648007192-3ql0ajb6ra2i0r1nbnb8tfpth4rrbp2r.apps.googleusercontent.com',
    iosBundleId: 'com.haitham.fitstore2026',
  );
}
