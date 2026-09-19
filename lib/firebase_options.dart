// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web not configured');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCcbd7SfbjoNurA1ig91_-0lS6TUqkip6c',
    appId: '1:712019137000:android:3b648bb3024d43e7eed45d',
    messagingSenderId: '712019137000',
    projectId: 'alexbank-transport',
    storageBucket: 'alexbank-transport.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB87l3uTvSmHa2cV20nhvoN871yFZ8XQig',
    appId: '1:712019137000:ios:19dcb8c1742b0054eed45d',
    messagingSenderId: '712019137000',
    projectId: 'alexbank-transport',
    storageBucket: 'alexbank-transport.firebasestorage.app',
    iosBundleId: 'alexbank.com.alexTransportation',
  );
}
