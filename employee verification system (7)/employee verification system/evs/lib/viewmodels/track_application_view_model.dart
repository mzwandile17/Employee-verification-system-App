/// ViewModel responsible for tracking application progress
/// and generating employee verification certificates.
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class TrackApplicationViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? employeeData;
  bool isLoading = false;
  bool isLoadingCertificate = false;
  File? existingCertificate;

  /// Fetch employee data from Firestore
  Future<void> fetchEmployee(String employeeId) async {
    isLoading = true;
    notifyListeners();
    try {
      final doc = await _firestore.collection('Employees').doc(employeeId).get();
      if (doc.exists) {
        employeeData = doc.data();
      } else {
        employeeData = null;
      }
    } catch (e) {
      employeeData = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Check if a certificate already exists locally
  Future<void> checkExistingCertificate(String employeeId) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/employee_certificate_$employeeId.pdf");
    if (await file.exists()) {
      existingCertificate = file;
      notifyListeners();
    }
  }

  /// Generate a visually professional PDF certificate (valid for 3 months)
  Future<Uint8List> generateCertificateBytes() async {
    if (employeeData == null) throw Exception("No employee data");

    final pdf = pw.Document();

    final name =
        '${employeeData!['FirstName'] ?? 'Unknown'} ${employeeData!['LastName'] ?? ''}'.trim();
    final employeeId = employeeData!['WorkId'] ?? 'N/A';
    final department = employeeData!['Department'] ?? 'N/A';
    final status = employeeData!['Status'] ?? 'N/A';

    final now = DateTime.now();
    final issueDate =
        '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
    final expiry = now.add(const Duration(days: 90)); // 3 months
    final expiryDate =
        '${expiry.year}/${expiry.month.toString().padLeft(2, '0')}/${expiry.day.toString().padLeft(2, '0')}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(40),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.indigo900, width: 3),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                /// Header section
                pw.Text(
                  'Republic of South Africa',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey700,
                    fontWeight: pw.FontWeight.normal,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'EMPLOYEE VERIFICATION CERTIFICATE',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo900,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 6),
                pw.Container(
                  width: 120,
                  height: 2,
                  color: PdfColors.indigo,
                ),
                pw.SizedBox(height: 30),

                /// Body section
                pw.Text(
                  'This is to formally certify that',
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  name.isEmpty ? 'Employee Name Missing' : name,
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'has successfully completed the verification process',
                  style: pw.TextStyle(fontSize: 16),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Employee ID: $employeeId', style: pw.TextStyle(fontSize: 14)),
                      pw.Text('Department: $department', style: pw.TextStyle(fontSize: 14)),
                      pw.Text('Status: $status', style: pw.TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 25),

                /// Validity info
                pw.Text('Issued on: $issueDate', style: pw.TextStyle(fontSize: 12)),
                pw.Text('Valid until: $expiryDate', style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 35),

                /// Footer note instead of signature
                pw.Text(
                  'This certificate is digitally generated and does not require a physical signature.',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Verified by the Department of Employee Validation Services (EVS)',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo900,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Save PDF locally
  Future<File> saveCertificateLocally(Uint8List pdfBytes, String employeeId) async {
    final output = await getApplicationDocumentsDirectory();
    final file = File("${output.path}/employee_certificate_$employeeId.pdf");
    await file.writeAsBytes(pdfBytes, flush: true);
    existingCertificate = file;
    notifyListeners();
    return file;
  }

  /// Face verification score
  double get faceScore {
    if (employeeData == null) return 0;
    if (employeeData!['PhotoVerification'] != null &&
        employeeData!['PhotoVerification'] is String) {
      final regex = RegExp(r'(\d+(\.\d+)?)%');
      final match = regex.firstMatch(employeeData!['PhotoVerification']);
      if (match != null) return double.tryParse(match.group(1)!) ?? 0;
    }
    return 0;
  }

  bool get faceVerified => faceScore > 80;

  bool get isApproved =>
      (employeeData?['Status']?.toString().toLowerCase() ?? '') == 'approved';
      
  bool get isRejected => 
  (employeeData?["Status"]?.toString().toLowerCase() ?? '') == 'rejected';
}
