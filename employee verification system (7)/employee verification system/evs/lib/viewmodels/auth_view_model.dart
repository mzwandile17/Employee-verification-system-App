import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? currentUser;
  String? EmployeeId;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  AuthViewModel() {
    currentUser = _auth.currentUser;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  ///  EMAIL LOGIN
  Future<String?> loginWithEmail(String email, String password) async {
    try {
      _setLoading(true);

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      currentUser = credential.user;

      if (currentUser != null && !currentUser!.emailVerified) {
        await currentUser!.sendEmailVerification();
        _setLoading(false);
        return "Email not verified! Verification link sent.";
      }

      //  Fetch EmployeeId from Firestore
      final query = await _firestore
          .collection('Employees')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        _setLoading(false);
        return "No employee record found for this email.";
      }

      EmployeeId = query.docs.first['EmployeeId'] ?? '';
      notifyListeners();
      _setLoading(false);
      return null; // success
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      if (e.code == 'user-not-found') return "User not found.";
      if (e.code == 'wrong-password') return "Incorrect password.";
      return e.message ?? "Login failed.";
    } catch (e) {
      _setLoading(false);
      return "An unexpected error occurred.";
    }
  }

  //SEND OTP for phone login 
  Future<String?> sendOtp(String phoneNumber, Function(String) onCodeSent) async {
    try {
      _setLoading(true);

      // Ensure employee exists in Firestore
      final query = await _firestore
          .collection('Employees')
          .where('ContactNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        _setLoading(false);
        return "No employee record found for this phone number.";
      }

      // Format the phone number correctly
      final formattedNumber = phoneNumber.startsWith('0')
          ? '+27${phoneNumber.substring(1)}'
          : (phoneNumber.startsWith('+') ? phoneNumber : '+27$phoneNumber');

      // Trigger Firebase verification flow
      _auth.verifyPhoneNumber(
        phoneNumber: formattedNumber,
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          currentUser = _auth.currentUser;
          EmployeeId = query.docs.first['EmployeeId'] ?? '';
          _setLoading(false);
          notifyListeners();
        },

        verificationFailed: (FirebaseAuthException e) {
          _setLoading(false);
          notifyListeners();
        },

        codeSent: (String verificationId, int? resendToken) {
          _setLoading(false);
          onCodeSent(verificationId);
        },

        codeAutoRetrievalTimeout: (String verificationId) {},
      );

      return null; // success message handled in callbacks
    } catch (e) {
      _setLoading(false);
      return "Failed to send OTP. Please try again.";
    }
  }

  ///  VERIFY OTP
  Future<String?> verifyOtp(String verificationId, String smsCode) async {
    try {
      _setLoading(true);

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await _auth.signInWithCredential(credential);
      currentUser = _auth.currentUser;

      final localPhone = currentUser?.phoneNumber?.replaceFirst('+27', '0');
      final query = await _firestore
          .collection('Employees')
          .where('ContactNumber', isEqualTo: localPhone)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        _setLoading(false);
        return "No employee record found for this number.";
      }

      EmployeeId = query.docs.first['EmployeeId'] ?? '';
      notifyListeners();

      _setLoading(false);
      return null; // success
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message ?? "Verification failed.";
    } catch (e) {
      _setLoading(false);
      return "An unexpected error occurred.";
    }
  }

  ///  LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
    currentUser = null;
    EmployeeId = null;
    notifyListeners();
  }
}
