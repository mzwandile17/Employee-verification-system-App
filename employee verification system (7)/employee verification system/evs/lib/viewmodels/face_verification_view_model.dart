import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../Services/facenet_service.dart';
import '../models/employee.dart';

class FaceVerificationViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FaceNetService _faceNetService = FaceNetService();

  CameraController? cameraController;
  bool isCameraInitialized = false;
  bool isVerifying = false;
  bool isReady = false;
  bool faceVerified = false;

  String verificationResult = '';
  double similarityScore = 0.0;
  File? referenceImageFile;
  Employee? employee;

  bool isUploading = false;
  String? errorMessage;
  String? uploadedUrl;

  /// Initialize model, load reference image and camera
  Future<void> initialize(String employeeId) async {
    try {
      verificationResult = 'Loading model...';
      notifyListeners();
      await _faceNetService.loadModel();

      verificationResult = 'Loading reference photo...';
      notifyListeners();
      await _loadReferenceImage(employeeId);

      // Load employee data
      final doc = await _firestore.collection('Employees').doc(employeeId).get();
      if (!doc.exists) throw Exception('Employee not found');
      employee = Employee.fromJson(doc.data()!, uid: '');

      verificationResult = 'Initializing camera...';
      notifyListeners();
      await _initializeCamera();

      isReady = true;
      verificationResult = '';
      notifyListeners();
    } catch (e, st) {
      verificationResult = 'Initialization failed: $e';
      isReady = false;
      notifyListeners();
      debugPrint('Initialization error: $e\n$st');
    }
  }

  /// Load reference image from Firestore/Storage
  Future<void> _loadReferenceImage(String employeeId) async {
    try {
      final doc = await _firestore.collection('Employees').doc(employeeId).get();
      if (!doc.exists) throw Exception('Employee not found');

      final url = doc.data()?['ReferencePhoto'] as String?;
      if (url == null || url.isEmpty) throw Exception('No reference photo found');

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/ReferencePhoto_$employeeId.jpg');

      try {
        final ref = _storage.refFromURL(url);
        await ref.writeToFile(file);
      } catch (_) {
        final resp = await http.get(Uri.parse(url));
        if (resp.statusCode != 200) throw Exception('HTTP download failed');
        await file.writeAsBytes(resp.bodyBytes);
      }

      if (!(await file.exists())) throw Exception('Downloaded reference file missing');
      referenceImageFile = file;
    } catch (e) {
      debugPrint('Load reference image error: $e');
      rethrow;
    }
  }

  /// Initialize camera
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front);
      cameraController = CameraController(frontCamera, ResolutionPreset.medium);
      await cameraController!.initialize();
      isCameraInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Camera init error: $e');
      rethrow;
    }
  }

  /// Start live face verification
  Future<void> startVerification(String employeeId) async {
    if (!isReady || cameraController == null || referenceImageFile == null || employee == null) return;

    isVerifying = true;
    faceVerified = false;
    verificationResult = 'Scanning face...';
    similarityScore = 0.0;
    notifyListeners();

    List<double> refEmbedding;
    try {
      refEmbedding = await _getReferenceEmbedding();
    } catch (_) {
      verificationResult = '❌ Failed to process reference image';
      isVerifying = false;
      notifyListeners();
      return;
    }

    final startTime = DateTime.now();
    const timeout = Duration(seconds: 30);

    while (isVerifying) {
      try {
        final xfile = await cameraController!.takePicture();
        final liveFile = File(xfile.path);

        List<double> liveEmbedding;
        try {
          liveEmbedding = await _faceNetService.getEmbedding(liveFile);
          if (liveEmbedding.isEmpty) throw Exception('No face detected');
        } catch (_) {
          verificationResult = 'No face detected, keep steady...';
          notifyListeners();
          await Future.delayed(const Duration(milliseconds: 400));
          continue;
        }

        final similarity = _faceNetService.cosineSimilarity(refEmbedding, liveEmbedding);
        final percentage = (similarity * 100).toStringAsFixed(2);

        similarityScore = similarity;

        if (similarity > 0.7) {
          faceVerified = true;
          employee = employee!.copyWith(
            PhotoVerification: 'Face Verified ($percentage%)',
          );
          verificationResult = ' Face Verified Successfully!';
          isVerifying = false;
        } else {
          employee = employee!.copyWith(
            PhotoVerification: 'Verification mismatch ($percentage%)',
          );
          verificationResult = ' Verifying... $percentage% match';
        }

        notifyListeners();

        // Update only Employees document (do not touch Status in Applications)
        await _firestore.collection('Employees').doc(employeeId).update(employee!.toJson());

        if (faceVerified || DateTime.now().difference(startTime) > timeout) {
          isVerifying = false;
          notifyListeners();
          break;
        }
      } catch (e) {
        debugPrint('Verification error: $e');
        verificationResult = 'Error verifying face';
        isVerifying = false;
        notifyListeners();
      }

      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  Future<List<double>> _getReferenceEmbedding() async {
    if (referenceImageFile == null) throw Exception('Reference image missing');

    List<double> refEmbedding = [];
    int attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      try {
        refEmbedding = await _faceNetService.getEmbedding(referenceImageFile!);
        if (refEmbedding.isNotEmpty) break;
      } catch (_) {
        await Future.delayed(const Duration(milliseconds: 400));
      }
      attempts++;
    }

    if (refEmbedding.isEmpty) throw Exception('Failed to process reference image after retries');
    return refEmbedding;
  }

  /// Dispose camera
  void disposeCamera() {
    cameraController?.dispose();
  }

  /// Reset ViewModel state
  void reset() {
    isUploading = false;
    errorMessage = null;
    faceVerified = false;
    similarityScore = 0.0;
    verificationResult = '';
    referenceImageFile = null;
    employee = null;
    isReady = false;
    isCameraInitialized = false;
    isVerifying = false;
    notifyListeners();
  }
}
