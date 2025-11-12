import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String Id; // Firestore document ID
  final String AdminId;
  final String EmployeeId;
  final String Message;
  final String Type;
  final bool IsRead;
  final DateTime CreatedAt;

  AppNotification({
    required this.Id,
    required this.AdminId,
    required this.EmployeeId,
    required this.Message,
    required this.Type,
    this.IsRead = false,
    DateTime? createdAt,
  }) : CreatedAt = createdAt ?? DateTime.now();

  /// Factory method to create Notification from Firestore JSON
  factory AppNotification.fromJson(Map<String, dynamic> json, {String? id}) {
    return AppNotification(
      Id: id ?? '', // assign Firestore doc ID
      AdminId: json['AdminId'] ?? '',
      EmployeeId: json['EmployeeId'] ?? '',
      Message: json['Message'] ?? '',
      Type: json['Type'] ?? '',
      IsRead: json['IsRead'] ?? false,
      createdAt: (json['CreatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert Notification object → Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'AdminId': AdminId,
      'EmployeeId': EmployeeId,
      'Message': Message,
      'Type': Type,
      'IsRead': IsRead,
      'CreatedAt': Timestamp.fromDate(CreatedAt),
    };
  }
}
