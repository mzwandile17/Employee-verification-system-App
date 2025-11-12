import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/viewmodels/face_verification_view_model.dart';
import 'package:provider/provider.dart';
import '../routes/routes_manager.dart';

class FaceVerificationScreen extends StatefulWidget {
  final String EmployeeId;
  const FaceVerificationScreen({super.key, required this.EmployeeId});

  @override
  State<FaceVerificationScreen> createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  late FaceVerificationViewModel vm;

  @override
  void initState() {
    super.initState();
    // Use the existing provider from MultiProvider
    vm = context.read<FaceVerificationViewModel>();
    vm.initialize(widget.EmployeeId);
  }

  @override
  void dispose() {
    vm.disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the provider notifies
    vm = context.watch<FaceVerificationViewModel>();

    final canStart = vm.isReady &&
        !vm.isVerifying &&
        vm.referenceImageFile != null &&
        vm.isCameraInitialized;
    final canProceed = vm.faceVerified;

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: const Text('Face Verification'),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black,
              ),
              child: vm.isCameraInitialized && vm.cameraController != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CameraPreview(vm.cameraController!),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, -2))
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    vm.verificationResult,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: vm.faceVerified
                          ? Colors.green.shade700
                          : Colors.blueGrey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  if (vm.similarityScore > 0)
                    Text(
                      'Similarity: ${(vm.similarityScore * 100).toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            vm.similarityScore > 0.7 ? Colors.green : Colors.redAccent,
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed:
                            canStart ? () => vm.startVerification(widget.EmployeeId) : null,
                        icon: const Icon(Icons.verified_user, color: Colors.white),
                        label: Text(
                          vm.isVerifying ? 'Verifying...' : 'Start Verification',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: canProceed
                            ? () {
                                // ✅ Navigate using named route
                                Navigator.pushReplacementNamed(
                                  context,
                                  RouteManager.home,
                                  arguments: {'EmployeeId': widget.EmployeeId},
                                );
                              }
                            : null,
                        icon: const Icon(Icons.arrow_forward, color: Colors.white),
                        label: const Text('Next',
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
