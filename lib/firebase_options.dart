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
    apiKey: 'AIzaSyBzCaiXPzx9RNVHSIPP1QZeiQTrXeP0gQA',
    appId: '1:846460650504:web:c0915728f16758a0c67dbd',
    messagingSenderId: '846460650504',
    projectId: 'estacionamento-55178',
    authDomain: 'estacionamento-55178.firebaseapp.com',
    storageBucket: 'estacionamento-55178.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA29MHXWubs6PLWeTZQVk87OGFdvS7OEPU',
    appId: '1:846460650504:android:b74adc0158fc3a8cc67dbd',
    messagingSenderId: '846460650504',
    projectId: 'estacionamento-55178',
    storageBucket: 'estacionamento-55178.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBdXpw07h82lFCDDeWHi_9VkD0khtzX9_k',
    appId: '1:846460650504:ios:75938c9f0be2c252c67dbd',
    messagingSenderId: '846460650504',
    projectId: 'estacionamento-55178',
    storageBucket: 'estacionamento-55178.appspot.com',
    iosBundleId: 'com.example.estacionamentoApp',
  );
}
