import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/application_view_model.dart';
import '../routes/routes_manager.dart';

class DocumentsScreen extends StatefulWidget {
  final String EmployeeId;

  const DocumentsScreen({super.key, required this.EmployeeId});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.EmployeeId.trim().isNotEmpty) {
      final appVM = context.read<ApplicationViewModel>();
      appVM.fetchApplications(widget.EmployeeId);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ EmployeeId is missing. Cannot upload documents.'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appVM = context.watch<ApplicationViewModel>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF87C2F3), Color(0xFF87C2F3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 25),
                _buildDocumentItem(
                  title: "ID Document",
                  subtitle: "Front and back of SA ID Card/Book",
                  documentType: 'IdentityDocument',
                  isUploaded: appVM.uploadedDocuments['IdentityDocument']!,
                  isUploading: appVM.isUploading,
                  onUpload: () => appVM.uploadDocument(
                      widget.EmployeeId, 'IdentityDocument'),
                ),
                const SizedBox(height: 16),
                _buildDocumentItem(
                  title: "Proof of Address",
                  subtitle:
                      "Utility bill or bank statement (not older than 3 months)",
                  documentType: 'ProofOfAddress',
                  isUploaded: appVM.uploadedDocuments['ProofOfAddress']!,
                  isUploading: appVM.isUploading,
                  onUpload: () =>
                      appVM.uploadDocument(widget.EmployeeId, 'ProofOfAddress'),
                ),
                const SizedBox(height: 16),
                _buildDocumentItem(
                  title: "Employment Contract",
                  subtitle: "Signed employment agreement",
                  documentType: 'EmploymentContract',
                  isUploaded: appVM.uploadedDocuments['EmploymentContract']!,
                  isUploading: appVM.isUploading,
                  onUpload: () => appVM.uploadDocument(
                      widget.EmployeeId, 'EmploymentContract'),
                ),
                const SizedBox(height: 30),
                _buildContinueButton(appVM.allUploaded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: const [
        Text(
          "Upload Your Documents",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Please upload all required documents before continuing to face verification.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentItem({
    required String title,
    required String subtitle,
    required String documentType,
    required bool isUploaded,
    required bool isUploading,
    required VoidCallback onUpload,
  }) {
    final cardColor = isUploaded ? Colors.white : Colors.white.withOpacity(0.95);
    final borderColor = isUploaded ? Colors.green : Colors.transparent;
    final iconColor = isUploaded ? Colors.green : Colors.blue.shade600;

    return Card(
      elevation: 6,
      color: cardColor,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isUploaded ? Icons.check_circle : Icons.upload_file,
              color: iconColor,
              size: 30,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.grey.shade900)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: isUploading || isUploaded ? null : onUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: isUploaded ? Colors.green : const Color(0xFF1565C0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              child: Text(
                isUploaded ? "UPLOADED" : "UPLOAD",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(bool allUploaded) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: allUploaded
            ? () {
                // ✅ Navigate using named route
                Navigator.pushReplacementNamed(
                  context,
                  RouteManager.faceVerification,
                  arguments: {'EmployeeId': widget.EmployeeId},
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              allUploaded ? Colors.white : Colors.white.withOpacity(0.4),
          foregroundColor: allUploaded ? const Color(0xFF1565C0) : Colors.white70,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: allUploaded ? 6 : 0,
        ),
        child: Text(
          allUploaded
              ? "Continue to Face Verification"
              : "Upload All Documents to Continue",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: allUploaded ? const Color(0xFF1565C0) : Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
