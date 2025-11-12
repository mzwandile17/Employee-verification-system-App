import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/routes/routes_manager.dart';
import 'package:flutter_application_1/screens/ai_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  final String EmployeeId;

  const HomeScreen({Key? key, required this.EmployeeId}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String department = "Loading...";
  String currentStatus = "Pending";
  String employeeName = "Loading...";
  String employeeId = "Loading...";
  String employeeEmail = "Loading...";
  String referencePhotoUrl = "";
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _employeeListener;

  @override
  void initState() {
    super.initState();
    employeeId = widget.EmployeeId;
    _listenToEmployeeInfo();
  }

  void _listenToEmployeeInfo() {
    _employeeListener?.cancel();

    _employeeListener = FirebaseFirestore.instance
        .collection('Employees')
        .doc(employeeId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          employeeName =
              "${data['FirstName'] ?? ''} ${data['LastName'] ?? ''}";
          employeeEmail = data['email'] ?? '';
          department = data['Department'] ?? 'N/A';
          currentStatus = data['Status'] ?? 'Pending';
          referencePhotoUrl = data['ReferencePhoto'] ?? '';
        });
      }
    }, onError: (e) {
      debugPrint("Error listening to employee info: $e");
    });
  }

  @override
  void dispose() {
    _employeeListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Icon(Icons.verified_user, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'EVS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 2,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 111, 180, 237),
        elevation: 0,
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('EmployeeId', isEqualTo: employeeId)
                .where('IsRead', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              int unreadCount = snapshot.data?.docs.length ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      if (employeeId.isEmpty) return;
                      Navigator.pushNamed(
                        context,
                        RouteManager.notifications,
                        arguments: {'EmployeeId': employeeId},
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints:
                            const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Center(
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: _buildDrawer(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(),
                  const SizedBox(height: 30),
                  _buildStatusCard(),
                  const SizedBox(height: 30),
                  _buildTrackApplicationButton(),
                  const SizedBox(height: 40),
                  _buildAIAssistantInfo(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              '© 2025 Employee Verification System',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (employeeId.isEmpty) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AIChatScreen(EmployeeId: employeeId),
            ),
          );
        },
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.smart_toy_outlined),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 111, 180, 237),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  backgroundImage: referencePhotoUrl.isNotEmpty
                      ? NetworkImage(referencePhotoUrl)
                      : null,
                  child: referencePhotoUrl.isEmpty
                      ? const Icon(Icons.person,
                          size: 30, color: Colors.green)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  'Welcome, $employeeName',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  employeeEmail,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              if (employeeId.isEmpty) return;
              Navigator.pushNamed(
                context,
                RouteManager.profile,
                arguments: {'EmployeeId': employeeId},
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Application History'),
            onTap: () {
              Navigator.pop(context);
              if (employeeId.isEmpty) return;
              Navigator.pushNamed(
                context,
                RouteManager.applicationHistory,
                arguments: {'EmployeeId': employeeId},
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.track_changes),
            title: const Text('Track My Application'),
            onTap: () {
              Navigator.pop(context);
              if (employeeId.isEmpty) return;
              Navigator.pushNamed(
                context,
                RouteManager.trackApplication,
                arguments: {'EmployeeId': employeeId},
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title:
                const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteManager.login,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(50, 111, 180, 237),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            backgroundImage: referencePhotoUrl.isNotEmpty
                ? NetworkImage(referencePhotoUrl)
                : null,
            child: referencePhotoUrl.isEmpty
                ? const Icon(Icons.person,
                    size: 30, color: Colors.green)
                : null,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              'Welcome $employeeName',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 33, 146, 239),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Application Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 48, 143, 225),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Employee:', employeeName),
            _buildDetailRow('Employee ID:', employeeId),
            _buildDetailRow('Department:', department),
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('Applications')
                  .doc(employeeId)
                  .snapshots(),
              builder: (context, snapshot) {
                String status = currentStatus;
                Color statusColor = _getStatusColor(currentStatus);

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data();
                  if (data != null && data['Status'] != null) {
                    status = data['Status'];
                    statusColor = _getStatusColor(status);
                  }
                }

                return _buildDetailRow(
                  'Current status:',
                  status,
                  valueColor: statusColor,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackApplicationButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (employeeId.isEmpty) return;
          Navigator.pushNamed(
            context,
            RouteManager.trackApplication,
            arguments: {'EmployeeId': employeeId},
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 87, 169, 240),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Track My Application',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildAIAssistantInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.smart_toy, color: Colors.green, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need help? Ask SecureAI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Click the chat button for instant help with your application',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'face verified':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }
}
