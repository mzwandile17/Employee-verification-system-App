import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Notification.dart';

class NotificationsScreen extends StatefulWidget {
  final String EmployeeId;

  const NotificationsScreen({super.key, required this.EmployeeId});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    markAllUnreadAsRead();
  }

  /// Mark all unread notifications as read for this employee
  void markAllUnreadAsRead() async {
    final query = await _firestore
        .collection('notifications')
        .where('EmployeeId', isEqualTo: widget.EmployeeId)
        .where('IsRead', isEqualTo: false)
        .get();

    for (var doc in query.docs) {
      doc.reference.update({'IsRead': true});
    }
  }

  Stream<List<AppNotification>> getNotificationsStream() {
    return _firestore
        .collection('notifications')
        .where('EmployeeId', isEqualTo: widget.EmployeeId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppNotification.fromJson(doc.data(), id: doc.id))
          .toList();
    });
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'ApplicationApproved':
        return Colors.green;
      case 'DocumentRequired':
        return Colors.orange;
      case 'Error':
      case 'ApplicationRejected':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'ApplicationApproved':
        return Icons.check_circle;
      case 'DocumentRequired':
        return Icons.warning;
      case 'Error':
      case 'ApplicationRejected':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color.fromARGB(255, 33, 146, 239);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: mainColor,
        elevation: 2,
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: getNotificationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.notifications_off, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No Notifications',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  onTap: () async {
                    if (!notification.IsRead) {
                      await _firestore
                          .collection('notifications')
                          .doc(notification.Id)
                          .update({'IsRead': true});
                    }

                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(notification.Type),
                        content: Text(notification.Message),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            _getNotificationColor(notification.Type)
                                .withOpacity(0.2),
                        child: Icon(
                          _getNotificationIcon(notification.Type),
                          color: _getNotificationColor(notification.Type),
                        ),
                      ),
                      if (!notification.IsRead)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(notification.Type),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.Message),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(notification.CreatedAt),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
