import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/verification_record.dart';

class VerificationHistoryScreen extends StatefulWidget {
  final String EmployeeId;

  const VerificationHistoryScreen({super.key, required this.EmployeeId});

  @override
  State<VerificationHistoryScreen> createState() =>
      _VerificationHistoryScreenState();
}

class _VerificationHistoryScreenState extends State<VerificationHistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<VerificationRecord>> getVerificationStream() {
    return _firestore
        .collection('VerificationRecords')
        .where('EmployeeId', isEqualTo: widget.EmployeeId)
        .orderBy('VerificationDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => VerificationRecord.fromJson(doc.data(), id: doc.id))
          .toList();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.hourglass_bottom;
      default:
        return Icons.info;
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color.fromARGB(255, 33, 146, 239);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verification History',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: mainColor,
        elevation: 2,
      ),
      body: StreamBuilder<List<VerificationRecord>>(
        stream: getVerificationStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = snapshot.data ?? [];

          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No Verification Records',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final color = _getStatusColor(record.Status);
              final icon = _getStatusIcon(record.Status);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.2),
                    child: Icon(icon, color: color),
                  ),
                  title: Text(
                    'Application ${record.Status.toUpperCase()}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: color),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Verified by: ${record.VerifiedByAdminId}'),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(record.VerificationDate),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Verification Details'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status: ${record.Status}'),
                            Text('Verified by: ${record.VerifiedByAdminId}'),
                            Text(
                                'Date: ${record.VerificationDate.day}/${record.VerificationDate.month}/${record.VerificationDate.year} '
                                '${record.VerificationDate.hour}:${record.VerificationDate.minute.toString().padLeft(2, '0')}'),
                            const SizedBox(height: 8),
                            const Text(
                              'Notes:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(record.Notes),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
