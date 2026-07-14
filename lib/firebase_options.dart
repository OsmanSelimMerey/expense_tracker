import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
        apiKey: "AIzaSyCP0hEYEOM9VIN0-3sV-bzVGq1Bjlgp3b0",
        authDomain: "expense-tracker-osman.firebaseapp.com",
        projectId: "expense-tracker-osman",
        storageBucket: "expense-tracker-osman.firebasestorage.app",
        messagingSenderId: "103031076573",
        appId: "1:103031076573:web:f7d982b3b13ee0ce210d34",
        measurementId: "G-KL33JDD4TW",
    );
  }
}