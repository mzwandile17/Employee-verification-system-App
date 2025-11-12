// application_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Application {
  final String EmployeeId;
  final String? employmentContract;
  final String? identityDocument;
  final String? proofOfAddress;
  final String status;
  final DateTime submissionDate;
  final DateTime updatedAt;

  Application({
    required this.EmployeeId,
    this.employmentContract,
    this.identityDocument,
    this.proofOfAddress,
    this.status = 'Pending',
    DateTime? submissionDate,
    DateTime? updatedAt,
  })  : submissionDate = submissionDate ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create Application object from Firestore data
  factory Application.fromJson(Map<String, dynamic> json, {String? id}) {
    return Application(
      EmployeeId: id ?? json['EmployeeId'] ?? '',
      employmentContract: json['EmploymentContract'] ?? '',
      identityDocument: json['IdentityDocument'] ?? '',
      proofOfAddress: json['ProofOfAddress'] ?? '',
      status: json['Status'] ?? 'Pending',
      submissionDate: (json['SubmissionDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['UpdatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert Application object → Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'EmployeeId': EmployeeId,
      'EmploymentContract': employmentContract ?? '',
      'IdentityDocument': identityDocument ?? '',
      'ProofOfAddress': proofOfAddress ?? '',
      'Status': status,
      'SubmissionDate': Timestamp.fromDate(submissionDate),
      'UpdatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
