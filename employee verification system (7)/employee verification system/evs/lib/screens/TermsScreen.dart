import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2192EF), // Blue gradient base color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Terms & Conditions",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // White rounded container for content
          Positioned.fill(
            top: 100,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
            ),
          ),

          // Scrollable content inside
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 130, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Center(
                  child: Text(
                    "Employee Verification Terms & Conditions",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2192EF),
                    ),
                  ),
                ),
                SizedBox(height: 24),

                Text(
                  "Welcome to our employee verification system. By using this application, you agree to comply with the following terms and conditions:",
                  style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                ),
                SizedBox(height: 20),

                _buildTerm(
                  number: 1,
                  title: "Accurate Information",
                  text:
                      "You must provide true and accurate personal information and documents. Any false or misleading data may result in your verification being denied or legal action being taken.",
                ),
                _buildTerm(
                  number: 2,
                  title: "Document Submission",
                  text:
                      "You agree to submit all required documents, including employment contracts, identity documents, and proof of address. All uploads must be clear, legible, and recent.",
                ),
                _buildTerm(
                  number: 3,
                  title: "Facial Verification",
                  text:
                      "The system may require a facial scan for verification. Please ensure that images are clear, recent, and captured under good lighting conditions.",
                ),
                _buildTerm(
                  number: 4,
                  title: "Data Privacy and Security",
                  text:
                      "Your data will be handled securely and stored according to data protection laws. It will only be used for verification and not shared without your consent.",
                ),
                _buildTerm(
                  number: 5,
                  title: "Ghost Employee Detection",
                  text:
                      "This system actively detects duplicate or fake employee records. Misrepresentation or fraud will lead to account termination.",
                ),
                _buildTerm(
                  number: 6,
                  title: "Device and Account Security",
                  text:
                      "You are responsible for keeping your login credentials safe. Do not share your account with others.",
                ),
                _buildTerm(
                  number: 7,
                  title: "Compliance with Laws",
                  text:
                      "You must comply with all applicable laws and regulations. Misuse of the system may be reported to authorities.",
                ),
                _buildTerm(
                  number: 8,
                  title: "Limitation of Liability",
                  text:
                      "The company is not liable for any indirect or consequential damages arising from the use of this app, including data loss or verification errors.",
                ),
                _buildTerm(
                  number: 9,
                  title: "Modifications",
                  text:
                      "We reserve the right to update or modify these Terms & Conditions at any time. Continued use of the app constitutes acceptance of updates.",
                ),
                _buildTerm(
                  number: 10,
                  title: "Acceptance",
                  text:
                      "By using this application, you acknowledge that you have read, understood, and agreed to these Terms & Conditions.",
                ),
                _buildTerm(
                  number: 11,
                  title: "System Maintenance",
                  text:
                      "Scheduled or unscheduled maintenance may temporarily affect system availability. We are not responsible for any downtime or delays.",
                ),
                _buildTerm(
                  number: 12,
                  title: "Data Retention Policy",
                  text:
                      "Your data will be retained only as long as necessary for verification and compliance purposes, after which it may be securely deleted.",
                ),
                _buildTerm(
                  number: 13,
                  title: "Third-Party Services",
                  text:
                      "Certain features may integrate with third-party systems for verification. We ensure these partners comply with data protection standards.",
                ),
                _buildTerm(
                  number: 14,
                  title: "User Conduct",
                  text:
                      "You agree not to misuse or interfere with the application's functionality. Any abusive behavior may lead to suspension.",
                ),
                _buildTerm(
                  number: 15,
                  title: "Termination of Access",
                  text:
                      "We may suspend or terminate your account if you violate these terms or engage in fraudulent activity.",
                ),
                SizedBox(height: 32),

                Text(
                  "Thank you for cooperating and ensuring the integrity of our employee verification process.",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget for consistent term styling
class _buildTerm extends StatelessWidget {
  final int number;
  final String title;
  final String text;

  const _buildTerm({
    required this.number,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$number. $title: ",
              style: const TextStyle(
                color: Color(0xFF2192EF),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            TextSpan(
              text: text,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
