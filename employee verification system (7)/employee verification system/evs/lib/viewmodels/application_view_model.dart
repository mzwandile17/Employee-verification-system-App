import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/Application.dart';
import 'package:file_picker/file_picker.dart';

class ApplicationViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Application> _applications = [];
  Application? _latestApplication;
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;

  Map<String, bool> uploadedDocuments = {
    'IdentityDocument': false,
    'ProofOfAddress': false,
    'EmploymentContract': false,
  };

  /// Getters
  List<Application> get applications => _applications;
  Application? get latestApplication => _latestApplication;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;

  bool get allUploaded => uploadedDocuments.values.every((v) => v);
  bool get hasUploadedAny =>
      uploadedDocuments.values.any((uploaded) => uploaded);

  /// Fetch applications for specific employeeId
  Future<void> fetchApplications(String employeeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('Applications')
          .where('EmployeeId', isEqualTo: employeeId)
          .orderBy('SubmissionDate', descending: true)
          .get();

      _applications = querySnapshot.docs
          .map((doc) => Application.fromJson(doc.data(), id: doc.id))
          .toList();

      if (_applications.isNotEmpty) {
        _latestApplication = _applications.first;
        final data = _latestApplication!.toJson();
        uploadedDocuments['IdentityDocument'] =
            (data['IdentityDocument'] ?? '').toString().isNotEmpty;
        uploadedDocuments['ProofOfAddress'] =
            (data['ProofOfAddress'] ?? '').toString().isNotEmpty;
        uploadedDocuments['EmploymentContract'] =
            (data['EmploymentContract'] ?? '').toString().isNotEmpty;
      } else {
        uploadedDocuments = {
          'IdentityDocument': false,
          'ProofOfAddress': false,
          'EmploymentContract': false,
        };
      }
    } catch (e, st) {
      debugPrint('Error fetching applications: $e\n$st');
      _errorMessage = 'Failed to load applications';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Upload a document for a specific employeeId
  Future<void> uploadDocument(String employeeId, String docType) async {
    if (employeeId.trim().isEmpty) return;

    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;

      _isUploading = true;
      notifyListeners();

      // Upload to Firebase Storage
      final storageRef = _storage.ref().child('documents/$employeeId/$fileName');
      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      // Find or create application in Firestore
      final appQuery = await _firestore
          .collection('Applications')
          .where('EmployeeId', isEqualTo: employeeId)
          .limit(1)
          .get();

      if (appQuery.docs.isEmpty) {
        // Create new application
        await _firestore.collection('Applications').add({
          'EmployeeId': employeeId,
          'EmploymentContract':
              docType == 'EmploymentContract' ? downloadUrl : '',
          'IdentityDocument':
              docType == 'IdentityDocument' ? downloadUrl : '',
          'ProofOfAddress': docType == 'ProofOfAddress' ? downloadUrl : '',
          'Status': 'Pending',
          'SubmissionDate': FieldValue.serverTimestamp(),
          'UpdatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Update existing application
        final appDoc = appQuery.docs.first;
        await appDoc.reference.update({
          docType: downloadUrl,
          'UpdatedAt': FieldValue.serverTimestamp(),
        });
      }

      uploadedDocuments[docType] = true;

      // Refresh applications after upload
      await fetchApplications(employeeId);

      // ✅ Automatically update status when all documents are uploaded
      if (allUploaded) {
        await updateStatusToPending(employeeId);
      }
    } catch (e) {
      debugPrint("❌ Error uploading document: $e");
      _errorMessage = "Failed to upload $docType";
      notifyListeners();
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  /// ✅ Update status in both Employees and Applications collections
  Future<void> updateStatusToPending(String employeeId) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Update Applications
      final appQuery = await firestore
          .collection('Applications')
          .where('EmployeeId', isEqualTo: employeeId)
          .limit(1)
          .get();

      if (appQuery.docs.isEmpty) {
        await firestore.collection('Applications').add({
          'EmployeeId': employeeId,
          'Status': 'Pending',
          'SubmissionDate': FieldValue.serverTimestamp(),
          'UpdatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        final appDoc = appQuery.docs.first;
        await appDoc.reference.update({
          'Status': 'Pending',
          'UpdatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Update Employees
      final empQuery = await firestore
          .collection('Employees')
          .where('EmployeeId', isEqualTo: employeeId)
          .limit(1)
          .get();

      if (empQuery.docs.isEmpty) {
        await firestore.collection('Employees').add({
          'EmployeeId': employeeId,
          'Status': 'Pending',
          'SubmissionDate': FieldValue.serverTimestamp(),
          'UpdatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        final empDoc = empQuery.docs.first;
        await empDoc.reference.update({
          'Status': 'Pending',
          'UpdatedAt': FieldValue.serverTimestamp(),
        });
      }

      debugPrint("✅ Status updated to Pending for $employeeId");
    } catch (e) {
      debugPrint("❌ Failed to update status for $employeeId: $e");
    }
  }

  /// Clear all data
  void clear() {
    _applications = [];
    _latestApplication = null;
    uploadedDocuments = {
      'IdentityDocument': false,
      'ProofOfAddress': false,
      'EmploymentContract': false,
    };
    _errorMessage = null;
    _isLoading = false;
    _isUploading = false;
    notifyListeners();
  }
}
