import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/routes_manager.dart';
import 'package:flutter_application_1/viewmodels/auth_view_model.dart';
import 'package:flutter_application_1/viewmodels/face_verification_view_model.dart';
import 'package:flutter_application_1/viewmodels/track_application_view_model.dart';
import 'package:provider/provider.dart';
import 'viewmodels/employee_view_model.dart';
import 'viewmodels/application_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAJQRBaRKmthJZzhovD4dW4GlYSfPItULo",
        authDomain: "evs-firebaseo.firebaseapp.com",
        projectId: "evs-firebaseo",
        storageBucket: "evs-firebaseo.firebasestorage.app",
        messagingSenderId: "869550824763",
        appId: "1:869550824763:web:c2a3a3f77c03987ba56b1e",
        measurementId: "G-LZYS4E5QFR",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmployeeViewModel()),
        ChangeNotifierProvider(create: (_) => ApplicationViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => FaceVerificationViewModel()),
        ChangeNotifierProvider(create: (_) => TrackApplicationViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Employee Verification System',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),

      // ✅ Use centralized routing system
      initialRoute: RouteManager.splash, // Splash screen route
      onGenerateRoute: RouteManager.generateRoute,
    );
  }
}
