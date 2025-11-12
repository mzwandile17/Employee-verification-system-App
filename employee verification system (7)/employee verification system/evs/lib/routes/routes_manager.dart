import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/notification.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/upload_document_screen.dart';
import '../screens/face_verification_screen.dart';
import '../screens/home_screen.dart';
import '../screens/application_history_screen.dart';
import '../screens/track_application_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/forgot_password.dart';
import '../screens/TermsScreen.dart';
import '../screens/ReUploadScreen.dart';

class RouteManager {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String welcome = '/welcome';
  static const String editProfile = '/edit-profile';
  static const String documents = '/documents';
  static const String faceVerification = '/face-verification';
  static const String home = '/home';
  static const String notifications = '/notifications';
  static const String applicationHistory = '/application-history';
  static const String trackApplication = '/track-application';
  static const String profile = '/profile';
  static const String otp = '/otp';
  static const String forgotPassword = '/forgot-password';
  static const String terms = '/terms';
  static const String reUpload = '/re_upload';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case welcome:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => WelcomeScreen(EmployeeId: args['EmployeeId']),
        );

      case editProfile:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EditProfileScreen(EmployeeId: args['EmployeeId']),
        );

      case documents:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DocumentsScreen(EmployeeId: args['EmployeeId']),
        );

      case faceVerification:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) =>
              FaceVerificationScreen(EmployeeId: args['EmployeeId']),
        );

      case home:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => HomeScreen(EmployeeId: args['EmployeeId']),
        );

      case notifications:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) =>
              NotificationsScreen(EmployeeId: args['EmployeeId']),
        );

      case applicationHistory:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) =>
              VerificationHistoryScreen(EmployeeId: args['EmployeeId']),
        );

      case trackApplication:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) =>
              TrackApplicationScreen(EmployeeId: args['EmployeeId']),
        );

      case profile:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ViewProfileScreen(EmployeeId: args['EmployeeId']),
        );

      case otp:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => OtpScreen(
            phoneNumber: args['phoneNumber'],
            verificationId: args['verificationId'],
          ),
        );

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case terms:
        return MaterialPageRoute(builder: (_) => const TermsScreen());


      case reUpload:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ReUploadScreen(EmployeeId: args['EmployeeId']),
        );


      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text(' Route not found')),
          ),
        );
    }
  }
}
