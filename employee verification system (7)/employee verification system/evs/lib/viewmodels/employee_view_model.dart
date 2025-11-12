import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/employee.dart';

class EmployeeViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Employee? employee;
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  /// Fetch employee by EmployeeId
  Future<void> fetchEmployee(String employeeId) async {
    try {
      isLoading = true;
      notifyListeners();

      final doc = await _firestore.collection('Employees').doc(employeeId).get();

      if (doc.exists) {
        final data = doc.data()!;
        // Always set EmployeeId from doc ID
        data['employeeId'] = doc.id;
        employee = Employee.fromJson(data, uid: doc.id);
        errorMessage = null;
      } else {
        employee = null;
        errorMessage = "Employee not found";
      }
    } catch (e) {
      employee = null;
      errorMessage = "Failed to fetch employee: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Update employee fields (partial or full)
  Future<void> updateEmployee(Map<String, dynamic> updates) async {
    if (employee == null) return;

    try {
      isSaving = true;
      notifyListeners();

      // Update Firestore
      await _firestore.collection('Employees').doc(employee!.EmployeeId).update(updates);

      // Refresh local employee
      await fetchEmployee(employee!.EmployeeId);
      errorMessage = null;
    } catch (e) {
      errorMessage = "Failed to update employee: $e";
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
