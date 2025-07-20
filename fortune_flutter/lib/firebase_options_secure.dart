// Secure Firebase configuration
// This file demonstrates how to use Firebase without hardcoding API keys

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Secure [FirebaseOptions] that reads from environment variables
/// 
/// IMPORTANT: Firebase Web API keys are designed to be public and are 
/// restricted by domain. However, for better security practices:
/// 1. Use Firebase App Check
/// 2. Configure Security Rules properly
/// 3. Use domain restrictions in Firebase Console
class SecureFirebaseOptions {
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

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_WEB_API_KEY'] ?? _throwMissingKey('FIREBASE_WEB_API_KEY'),
    appId: dotenv.env['FIREBASE_WEB_APP_ID'] ?? _throwMissingKey('FIREBASE_WEB_APP_ID'),
    messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? _throwMissingKey('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? _throwMissingKey('FIREBASE_PROJECT_ID'),
    authDomain: '${dotenv.env['FIREBASE_PROJECT_ID']}.firebaseapp.com',
    storageBucket: '${dotenv.env['FIREBASE_PROJECT_ID']}.firebasestorage.app',
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? _throwMissingKey('FIREBASE_ANDROID_API_KEY'),
    appId: dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? _throwMissingKey('FIREBASE_ANDROID_APP_ID'),
    messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? _throwMissingKey('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? _throwMissingKey('FIREBASE_PROJECT_ID'),
    storageBucket: '${dotenv.env['FIREBASE_PROJECT_ID']}.firebasestorage.app',
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_IOS_API_KEY'] ?? _throwMissingKey('FIREBASE_IOS_API_KEY'),
    appId: dotenv.env['FIREBASE_IOS_APP_ID'] ?? _throwMissingKey('FIREBASE_IOS_APP_ID'),
    messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? _throwMissingKey('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? _throwMissingKey('FIREBASE_PROJECT_ID'),
    storageBucket: '${dotenv.env['FIREBASE_PROJECT_ID']}.firebasestorage.app',
    iosBundleId: 'com.beyond.fortuneFlutter',
  );

  static FirebaseOptions get macos => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_MACOS_API_KEY'] ?? _throwMissingKey('FIREBASE_MACOS_API_KEY'),
    appId: dotenv.env['FIREBASE_MACOS_APP_ID'] ?? _throwMissingKey('FIREBASE_MACOS_APP_ID'),
    messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? _throwMissingKey('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? _throwMissingKey('FIREBASE_PROJECT_ID'),
    storageBucket: '${dotenv.env['FIREBASE_PROJECT_ID']}.firebasestorage.app',
    iosBundleId: 'com.beyond.fortuneFlutter',
  );

  static String _throwMissingKey(String key) {
    throw Exception('Missing required Firebase configuration: $key. Please check your .env file.');
  }
}