import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/routes_manager.dart';
import 'package:flutter_application_1/viewmodels/track_application_view_model.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'edit_profile_screen.dart';
import '../routes/routes_manager.dart';

class TrackApplicationScreen extends StatefulWidget {
  final String EmployeeId;
  const TrackApplicationScreen({super.key, required this.EmployeeId});

  @override
  State<TrackApplicationScreen> createState() => _TrackApplicationScreenState();
}

class _TrackApplicationScreenState extends State<TrackApplicationScreen> {
  @override
  void initState() {
    super.initState();
    final vm = context.read<TrackApplicationViewModel>();
    vm.fetchEmployee(widget.EmployeeId);
    vm.checkExistingCertificate(widget.EmployeeId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackApplicationViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final empData = vm.employeeData ?? {};
        final finalStatus = empData['Status'] ?? 'Pending';
        final isApproved = vm.isApproved;
        final faceVerified = vm.faceVerified;
        final isRejected = vm.isRejected;

        if (finalStatus == 'NotStarted') {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "You cannot track as you have not started an application.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(
                                EmployeeId: widget.EmployeeId,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          "Start Application",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final stages = [
          {
            "name": "Face Verification",
            "status": faceVerified ? "Verified" : "Pending",
          },
          {
            "name": "Documents Approval",
            "status": isApproved ? "Approved" : "Pending",
          },
          {"name": "Final Status", "status": finalStatus},
        ];

        Color getColor(String status) {
          switch (status.toLowerCase()) {
            case "approved":
            case "verified":
              return Colors.green;
            case "pending":
              return Colors.orange.shade400;
            case "declined":
              return Colors.redAccent;
            default:
              return Colors.grey;
          }
        }

        IconData getIcon(String name, String status) {
          switch (name) {
            case "Face Verification":
              return Icons.face;
            case "Final Status":
              return status.toLowerCase() == "approved"
                  ? Icons.check
                  : status.toLowerCase() == "declined"
                  ? Icons.close
                  : Icons.timelapse;
            default:
              return status.toLowerCase() == "approved"
                  ? Icons.check
                  : Icons.timelapse;
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Track Application',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 33, 146, 239),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            elevation: 2,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (_, __) => const SizedBox(height: 40),
                    itemCount: stages.length,
                    itemBuilder: (context, index) {
                      final stage = stages[index];
                      final status = stage['status']!;
                      final color = getColor(status);
                      final icon = getIcon(stage['name']!, status);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: Colors.white, size: 70),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 160,
                            child: Text(
                              stage['name']!,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            status,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: (isApproved && !vm.isLoadingCertificate)
                        ? () async {
                            try {
                              final pdfBytes = await vm
                                  .generateCertificateBytes();
                              if (pdfBytes.isNotEmpty) {
                                await vm.saveCertificateLocally(
                                  pdfBytes,
                                  widget.EmployeeId,
                                );
                                await Printing.layoutPdf(
                                  onLayout: (format) async => pdfBytes,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Error generating certificate',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        : null,
                    icon: vm.isLoadingCertificate
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.download, color: Colors.white),
                    label: Text(
                      isApproved
                          ? 'Download Certificate'
                          : 'Pending Verification',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isApproved ? Colors.green : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                // BELOW your first button (Download Certificate)
                const SizedBox(height: 16),

                // ✅ Only show if rejected
                if (isRejected)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          RouteManager.reUpload,
                          arguments: {"EmployeeId":widget.EmployeeId},
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text(
                        "Re-upload",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
