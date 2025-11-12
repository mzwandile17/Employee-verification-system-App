import 'package:cloud_firestore/cloud_firestore.dart';

class VerificationRecord {
  final String Id;
  final String EmployeeId;
  final String Status;
  final String Notes;
  final String VerifiedByAdminId;
  final DateTime VerificationDate;

  VerificationRecord({
    required this.Id,
    required this.EmployeeId,
    required this.Status,
    required this.Notes,
    required this.VerifiedByAdminId,
    required this.VerificationDate,
  });

  factory VerificationRecord.fromJson(Map<String, dynamic> json, {required String id}) {
    DateTime verificationDate;

    final rawDate = json['VerificationDate'];
    if (rawDate is Timestamp) {
      verificationDate = rawDate.toDate();
    } else if (rawDate is DateTime) {
      verificationDate = rawDate;
    } else {
      verificationDate = DateTime.now();
    }

    return VerificationRecord(
      Id: id,
      EmployeeId: json['EmployeeId'] ?? '',
      Status: json['Status'] ?? 'Unknown',
      Notes: json['Notes'] ?? '',
      VerifiedByAdminId: json['VerifiedByAdminId'] ?? 'N/A',
      VerificationDate: verificationDate,
    );
  }
}
