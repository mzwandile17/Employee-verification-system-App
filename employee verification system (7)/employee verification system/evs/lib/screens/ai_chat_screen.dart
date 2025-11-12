import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AIChatScreen extends StatefulWidget {
  final String EmployeeId; // EmployeeId to fetch info

  const AIChatScreen({super.key, required this.EmployeeId});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];
  Map<String, dynamic>? _employeeData;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _fetchEmployeeInfo();
    _initializeChat();
  }

  void _initializeChat() {
    _messages = [
      ChatMessage(
        text:
            "Welcome! I’m SecureAI — your digital assistant for the Employee Verification System (EVS). How can I help you today?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ];
  }

  Future<void> _fetchEmployeeInfo() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("Employees")
          .doc(widget.EmployeeId)
          .get();

      if (doc.exists) {
        setState(() {
          _employeeData = doc.data();
        });
      }
    } catch (e) {
      print("Error fetching employee info: $e");
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
    });

    _messageController.clear();
    _simulateAIResponse(text);
  }

  Future<void> _simulateAIResponse(String userMessage) async {
    setState(() {
      _isTyping = true;
    });

    String response = _getAIResponse(userMessage);

    await Future.delayed(const Duration(seconds: 1)); // typing delay

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  String _getAIResponse(String message) {
    String lowerMessage = message.toLowerCase().trim();
    String name = _employeeData != null
        ? "${_employeeData!['FirstName'] ?? ''}"
        : "there";

    String status = _employeeData != null
        ? (_employeeData!['Status'] ?? "pending")
        : "pending";

    // Greetings
    if (RegExp(r'\b(hello|hi|hey|morning|afternoon|evening)\b').hasMatch(lowerMessage)) {
      return "Hello $name! I'm SecureAI. How can I assist you with your verification today?";
    }

    if (lowerMessage.contains("thank") || lowerMessage.contains("thanks")) {
      return "You're most welcome, $name!  I'm always here to help.";
    }

    if (lowerMessage.contains("who are you") || lowerMessage.contains("what can you do")) {
      return "I'm SecureAI 🤖 — I help government employees verify their profiles, track status, and guide them through the EVS process.";
    }
    

    // Status / Progress
    if (RegExp(r'\b(status|progress|application update|current state|how is my application)\b').hasMatch(lowerMessage)) {
      return "$name, your current verification status is: **${status.toString().toUpperCase()}**. You can view more details in your dashboard.";
    }

    if (lowerMessage.contains("when will it be approved") || lowerMessage.contains("waiting too long")) {
      return "I understand your concern, $name. The verification usually takes 3–5 working days once all documents are correctly submitted.";
    }

    //  Required Documents
    if (RegExp(r'\b(required documents|document needed|what must i upload|files needed|necessary documents|proof required)\b').hasMatch(lowerMessage)) {
      return "You'll need to provide:\n"
          "1️ A valid South African ID\n"
          "2️ Proof of employment or appointment letter\n"
          "3️ A recent passport-sized photo\n"
          "4️ Additional department-specific documents if requested.";
    }

    //  How to Verify
    if (RegExp(r'\b(how.*verify|steps.*verify|process.*verify|guide me|how to do verification|complete verification)\b').hasMatch(lowerMessage)) {
      return "To verify your profile:\n"
          "1️ Log in to your EVS dashboard\n"
          "2️ Upload all required documents\n"
          "3️ Complete the face verification step\n"
          "4️ Wait for HR review\n"
          "5️ Download your Verification Certificate when approved ✅";
    }

    //  Face Verification
    if (lowerMessage.contains("face") && lowerMessage.contains("verification")) {
      return "Face verification confirms your identity using your photo. Ensure proper lighting, align your face, and press **'Capture & Verify'** in your dashboard.";
    }

    // Processing Time
    if (RegExp(r'\b(how long|processing time|duration|take to process|approval time)\b').hasMatch(lowerMessage)) {
      return "The verification process usually takes **3–5 working days** after submitting all correct documents.";
    }

    // Cancel / Withdraw
    if (RegExp(r'\b(cancel|withdraw|stop).*application\b').hasMatch(lowerMessage)) {
      return "Once submitted, applications cannot be canceled, $name. For exceptional cases, please contact HR.";
    }

    // Contact / Support
    if (RegExp(r'\b(contact|email|call|support|help|assistance|complaint)\b').hasMatch(lowerMessage)) {
      return "You can contact HR support through:\n"
          " hr@education.gov.za\n"
          " 012-345-6789\n\nAvailable Monday–Friday, 8 AM–4 PM.";
    }

    // Certificate
    if (RegExp(r'\b(certificate|proof|download|verification proof)\b').hasMatch(lowerMessage)) {
      if (status.toLowerCase() == "approved") {
        return "$name, your Verification Certificate is ready 🎉. Download it as a PDF from your dashboard.";
      } else {
        return "Your certificate will be available once your application is approved.";
      }
    }

    // Certificate Expiry
    if (RegExp(r'\b(expire|expiry|validity|renew|reverify)\b').hasMatch(lowerMessage)) {
      return "The Verification Certificate is valid for **1 year** from issue. Please re-verify before expiry.";
    }

    //  Errors
    if (RegExp(r'\b(error|issue|problem|failed|trouble)\b').hasMatch(lowerMessage)) {
      return "If you encounter an error, make sure documents are clear and complete. If it persists, contact HR support.";
    }

    // Process Steps
    if (RegExp(r'\b(steps|procedure|process|how it works|explain process)\b').hasMatch(lowerMessage)) {
      return "The EVS process includes:\n"
          "1️ Submit documents\n"
          "2️ Complete face verification\n"
          "3️ HR review & validation\n"
          "4️ Approval and certificate issuance ";
    }

    // Eligibility
    if (RegExp(r'\b(eligible|criteria|who can apply|requirement to verify)\b').hasMatch(lowerMessage)) {
      return "Eligibility: you must be a **registered government employee** with a valid South African ID. Contractors may require additional approvals.";
    }

    // Security / Privacy
    if (RegExp(r'\b(secure|safe|privacy|data|information|protection)\b').hasMatch(lowerMessage)) {
      return "Your data is stored securely  using encryption. Only authorized HR officers can access your information, in compliance with POPIA.";
    }

    // Fees
    if (RegExp(r'\b(fee|cost|payment|charge)\b').hasMatch(lowerMessage)) {
      return "Verification through EVS is **free of charge** — no payment is required.";
    }

    // Multiple Employees
    if (RegExp(r'\b(multiple employees|more than one|team|department verification)\b').hasMatch(lowerMessage)) {
      return "Each employee must verify individually using their employee ID and ID number. HR can monitor group verification progress.";
    }

    // About EVS
    if (RegExp(r'\b(what is evs|employee verification system|meaning of evs|explain evs)\b').hasMatch(lowerMessage)) {
      return "The Employee Verification System (EVS) is a secure government platform that validates real employees and prevents ghost workers.";
    }

    //  Late or Missing Updates
    if (RegExp(r'\b(not updated|no update|no response|still pending|delay)\b').hasMatch(lowerMessage)) {
      return "Sometimes verification takes longer due to workload or document checks. Please check your dashboard for real-time updates.";
    }

    // Account / Login Issues
    if (RegExp(r'\b(login|access|password|account|unable to sign)\b').hasMatch(lowerMessage)) {
      return "If you're having trouble logging in, use the 'Forgot Password' option or contact HR for account reset.";
    }

    //  Updating Info
    if (RegExp(r'\b(update|change info|edit profile|modify details)\b').hasMatch(lowerMessage)) {
      return "You can update your profile in your EVS dashboard under **Profile Settings** before submitting for review.";
    }

    // Verification Failure
    if (RegExp(r'\b(fail|failed verification|not verified|denied)\b').hasMatch(lowerMessage)) {
      return "If your verification failed, it might be due to missing or mismatched details. Please review and resubmit your documents.";
    }

    // Default fallback
    return "I understand you're asking about \"$message\". Could you please clarify if it's related to your verification, documents, or status? ";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green,
              radius: 16,
              child: Icon(Icons.smart_toy, size: 16, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text(
              'Secure Chatbot',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 115, 180, 236),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildChatBubble(_messages[index]),
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 10),
              child: Row(
                children: const [
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 14,
                    child: Icon(Icons.smart_toy, size: 14, color: Colors.white),
                  ),
                  SizedBox(width: 8),
                  Text("SecureAI is typing...", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          _buildChatInput(),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type your question...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Color.fromARGB(255, 9, 197, 56),
                    ),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            const CircleAvatar(
              backgroundColor: Colors.green,
              radius: 16,
              child: Icon(Icons.smart_toy, size: 16, color: Colors.white),
            ),
          if (!message.isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color.fromARGB(255, 75, 166, 232)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
          if (message.isUser)
            const CircleAvatar(
              backgroundColor: Color.fromARGB(255, 96, 185, 240),
              radius: 16,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
