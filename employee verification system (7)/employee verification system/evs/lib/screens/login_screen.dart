import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/routes_manager.dart';
import 'package:flutter_application_1/viewmodels/auth_view_model.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  bool passwordVisible = false;
  bool termsAccepted = false;

  final TextEditingController inputController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? inputErrorText;
  String? passwordErrorText;

  // 🔹 NEW: flag to track if the input is a phone number
  bool _isNumberLogin = false;

  @override
  void initState() {
    super.initState();
    inputController.addListener(_validateInput);
    passwordController.addListener(_validatePassword);

    // 🔹 Listen to changes in input and check if it's a number
    inputController.addListener(_checkIfNumber);
  }

  // 🔹 Checks if the input is a 10-digit number
  void _checkIfNumber() {
    final text = inputController.text.trim();
    final isNumber = RegExp(r'^\d{10}$').hasMatch(text);
    if (isNumber != _isNumberLogin) {
      setState(() {
        _isNumberLogin = isNumber;
      });
    }
  }

  void _validateInput() {
    final text = inputController.text.trim();
    if (text.isEmpty) {
      setState(() => inputErrorText = null);
      return;
    }
    final isEmail = _isValidEmail(text);
    final isPhone = _isValidPhone(text);

    setState(() {
      inputErrorText = (isEmail || isPhone)
          ? null
          : 'Enter a valid email or 10-digit phone number';
    });
  }

  void _validatePassword() {
    final text = passwordController.text.trim();
    setState(() {
      passwordErrorText = (text.isEmpty || text.length >= 6)
          ? null
          : 'Password must be at least 6 characters';
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    return phoneRegex.hasMatch(phone);
  }

  bool get _isFormValid {
    final input = inputController.text.trim();
    final password = passwordController.text.trim();
    final isEmail = _isValidEmail(input);
    final isPhone = _isValidPhone(input);
    return ((isEmail || isPhone) && (isEmail ? password.length >= 6 : true));
  }

  Future<void> _login() async {
    _validateInput();
    _validatePassword();
    final auth = context.read<AuthViewModel>();

    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields correctly'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final input = inputController.text.trim();
    final password = passwordController.text.trim();
    final isEmail = _isValidEmail(input);
    final isPhone = _isValidPhone(input);

    String? error;

    if (isEmail) {
      error = await auth.loginWithEmail(input, password);
      if (error == null && auth.EmployeeId != null) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          RouteManager.welcome,
          arguments: {'EmployeeId': auth.EmployeeId!},
        );
      } else if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    } else if (isPhone) {
      error = await auth.sendOtp(input, (verificationId) {
        if (!mounted) return;
        Navigator.pushNamed(
          context,
          RouteManager.otp,
          arguments: {
            'phoneNumber': input,
            'verificationId': verificationId,
          },
        );
      });

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                color: Colors.white.withOpacity(0.95),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Welcome Back!",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 31, 146, 228),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Login to your account",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 11, 11, 11),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: inputController,
                        decoration: InputDecoration(
                          hintText: "Email or Phone number",
                          filled: true,
                          fillColor: const Color.fromARGB(255, 241, 244, 241),
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorText: inputErrorText,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🔹 Password field disabled if number detected
                      TextField(
                        controller: passwordController,
                        obscureText: !passwordVisible,
                        enabled: !_isNumberLogin, // 👈 disables field
                        decoration: InputDecoration(
                          hintText: _isNumberLogin
                              ? "Password disabled for phone login"
                              : "Password",
                          filled: true,
                          fillColor: const Color.fromARGB(255, 241, 244, 241),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () =>
                                setState(() => passwordVisible = !passwordVisible),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorText: passwordErrorText,
                        ),
                      ),

                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, RouteManager.forgotPassword);
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (value) =>
                                setState(() => rememberMe = value!),
                          ),
                          const Text("Remember Me"),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: termsAccepted,
                            onChanged: (value) =>
                                setState(() => termsAccepted = value!),
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: 'I accept the ',
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: 'Terms & Conditions',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.pushNamed(
                                            context, RouteManager.terms);
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: termsAccepted && !auth.isLoading
                              ? _login
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: termsAccepted
                                ? const Color.fromARGB(255, 33, 146, 239)
                                : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: auth.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    inputController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
