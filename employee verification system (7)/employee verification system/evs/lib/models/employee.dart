import 'package:cloud_firestore/cloud_firestore.dart';

class Employee {
  final String EmployeeId;
  final String FirstName;
  final String LastName;
  final String IdNumber;
  final String WorkId;
  final String Department;
  final String Position;
  final String email;
  final String ContactNumber;
  final DateTime DateOfBirth;
  final String address;
  final String Gender;
  final String Race;
  final String Status;
  final String Password;
  final String Photo;
  final String ReferencePhoto;
  final String SourceId;
  final String MaritalStatus;
  final DateTime? LastSyncedAt;
  final DateTime? UpdatedAt;
  final List<dynamic>? VerificationRecords;
  final String PhotoVerification;

  Employee({
    required this.EmployeeId,
    required this.FirstName,
    required this.LastName,
    required this.IdNumber,
    required this.WorkId,
    required this.Department,
    required this.Position,
    required this.email,
    required this.ContactNumber,
    required this.DateOfBirth,
    required this.address,
    required this.Gender,
    required this.Race,
    required this.Status,
    required this.Password,
    required this.Photo,
    required this.ReferencePhoto,
    required this.SourceId,
    required this.MaritalStatus,
    this.LastSyncedAt,
    this.UpdatedAt,
    this.VerificationRecords,
    required this.PhotoVerification,
  });

  /// Convert Employee object to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'employeeId': EmployeeId,
      'FirstName': FirstName,
      'LastName': LastName,
      'IdNumber': IdNumber,
      'WorkId': WorkId,
      'Department': Department,
      'Position': Position,
      'email': email,
      'ContactNumber': ContactNumber,
      'DateOfBirth': Timestamp.fromDate(DateOfBirth),
      'address': address,
      'Gender': Gender,
      'Race': Race,
      'Status': Status,
      'Password': Password,
      'Photo': Photo,
      'ReferencePhoto': ReferencePhoto,
      'SourceId': SourceId,
      'MaritalStatus': MaritalStatus,
      'LastSyncedAt': LastSyncedAt != null ? Timestamp.fromDate(LastSyncedAt!) : null,
      'UpdatedAt': UpdatedAt != null ? Timestamp.fromDate(UpdatedAt!) : null,
      'VerificationRecords': VerificationRecords ?? [],
      'PhotoVerification': PhotoVerification,
    };
  }

  /// Create Employee object from Firestore JSON
  factory Employee.fromJson(Map<String, dynamic> json, {required String uid}) {
    return Employee(
      EmployeeId: json['employeeId'] ?? '',
      FirstName: json['FirstName'] ?? '',
      LastName: json['LastName'] ?? '',
      IdNumber: json['IdNumber'] ?? '',
      WorkId: json['WorkId'] ?? '',
      Department: json['Department'] ?? '',
      Position: json['Position'] ?? '',
      email: json['email'] ?? '',
      ContactNumber: json['ContactNumber'] ?? '',
      DateOfBirth: (json['DateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now(),
      address: json['address'] ?? '',
      Gender: json['Gender'] ?? '',
      Race: json['Race'] ?? '',
      Status: json['Status'] ?? 'Pending',
      Password: json['Password'] ?? '',
      Photo: json['Photo'] ?? '',
      ReferencePhoto: json['ReferencePhoto'] ?? '',
      SourceId: json['SourceId'] ?? '',
      MaritalStatus: json['MaritalStatus'] ?? '',
      LastSyncedAt: (json['LastSyncedAt'] as Timestamp?)?.toDate(),
      UpdatedAt: (json['UpdatedAt'] as Timestamp?)?.toDate(),
      VerificationRecords: json['VerificationRecords'] ?? [],
      PhotoVerification: json['PhotoVerification'] ?? '',
    );
  }

  /// CopyWith method to update selective fields
  Employee copyWith({
    String? EmployeeId,
    String? FirstName,
    String? LastName,
    String? IdNumber,
    String? WorkId,
    String? Department,
    String? Position,
    String? email,
    String? ContactNumber,
    DateTime? DateOfBirth,
    String? address,
    String? Gender,
    String? Race,
    String? Status,
    String? Password,
    String? Photo,
    String? ReferencePhoto,
    String? SourceId,
    String? MaritalStatus,
    DateTime? LastSyncedAt,
    DateTime? UpdatedAt,
    List<dynamic>? VerificationRecords,
    String? PhotoVerification,
  }) {
    return Employee(
      EmployeeId: EmployeeId ?? this.EmployeeId,
      FirstName: FirstName ?? this.FirstName,
      LastName: LastName ?? this.LastName,
      IdNumber: IdNumber ?? this.IdNumber,
      WorkId: WorkId ?? this.WorkId,
      Department: Department ?? this.Department,
      Position: Position ?? this.Position,
      email: email ?? this.email,
      ContactNumber: ContactNumber ?? this.ContactNumber,
      DateOfBirth: DateOfBirth ?? this.DateOfBirth,
      address: address ?? this.address,
      Gender: Gender ?? this.Gender,
      Race: Race ?? this.Race,
      Status: Status ?? this.Status,
      Password: Password ?? this.Password,
      Photo: Photo ?? this.Photo,
      ReferencePhoto: ReferencePhoto ?? this.ReferencePhoto,
      SourceId: SourceId ?? this.SourceId,
      MaritalStatus: MaritalStatus ?? this.MaritalStatus,
      LastSyncedAt: LastSyncedAt ?? this.LastSyncedAt,
      UpdatedAt: UpdatedAt ?? this.UpdatedAt,
      VerificationRecords: VerificationRecords ?? this.VerificationRecords,
      PhotoVerification: PhotoVerification ?? this.PhotoVerification,
    );
  }
}
