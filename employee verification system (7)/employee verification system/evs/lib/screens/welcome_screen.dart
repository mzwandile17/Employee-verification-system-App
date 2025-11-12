import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/routes_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WelcomeScreen extends StatelessWidget {
  final String EmployeeId;

  const WelcomeScreen({Key? key, required this.EmployeeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const mainColor = Color.fromARGB(255, 33, 146, 239);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                height: 120,
              ),
              const SizedBox(height: 30),

              const Text(
                "Welcome to the Employee Verification System",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 7, 131, 193),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                "This system securely verifies employee details. "
                "If you have already completed the verification process, "
                "you may proceed to the Home to track your application/download certificate. "
                "Otherwise, start the verification process to submit your details for approval.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // 🔹 Start Verification Process button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    final doc = await FirebaseFirestore.instance
                        .collection('Employees')
                        .doc(EmployeeId)
                        .get();

                    if (!doc.exists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Employee record not found.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final status = doc.data()?['Status'] ?? 'NotStarted';

                    if (status == 'NotStarted') {
                      // Employee has not started verification
                      Navigator.pushReplacementNamed(
                        context,
                        RouteManager.editProfile,
                        arguments: {'EmployeeId': EmployeeId},
                      );
                    } else if (status == 'Pending') {
                      // Employee started but not completed
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'You have already started verification. Please Navigate to home to track your application.',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      // Stay on this screen
                    } else if (status == 'Approved' || status == 'Verified') {
                      // Employee already verified
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'You have already completed verification.',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Stay on this screen
                    } else {
                      // Default fallback
                      Navigator.pushReplacementNamed(
                        context,
                        RouteManager.editProfile,
                        arguments: {'EmployeeId': EmployeeId},
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 6,
                    shadowColor: mainColor.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Start Verification Process",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Go to Home button (still always visible)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      RouteManager.home,
                      arguments: {'EmployeeId': EmployeeId},
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: mainColor, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    foregroundColor: mainColor,
                    overlayColor: mainColor.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Go to Home",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: mainColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
