import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/employee_view_model.dart';
import '../routes/routes_manager.dart';

class EditProfileScreen extends StatefulWidget {
  final String EmployeeId; // Capital E

  const EditProfileScreen({super.key, required this.EmployeeId});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  // Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController workIdController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController raceController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController maritalStatusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final vm = context.read<EmployeeViewModel>();
    if (widget.EmployeeId.trim().isNotEmpty) {
      vm.fetchEmployee(widget.EmployeeId).then((_) {
        if (vm.employee != null) _populateFields(vm.employee!);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ EmployeeId is missing. Cannot load profile.'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  void _populateFields(employee) {
    firstNameController.text = employee.FirstName;
    lastNameController.text = employee.LastName;
    idNumberController.text = employee.IdNumber;
    workIdController.text = employee.WorkId;
    departmentController.text = employee.Department;
    positionController.text = employee.Position;
    emailController.text = employee.email;
    contactNumberController.text = employee.ContactNumber;
    dateOfBirthController.text =
        employee.DateOfBirth.toLocal().toString().split(' ')[0];
    addressController.text = employee.address;
    genderController.text = employee.Gender;
    raceController.text = employee.Race;
    passwordController.text = employee.Password;
    maritalStatusController.text = employee.MaritalStatus;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<EmployeeViewModel>();
    await vm.updateEmployee({
      'FirstName': firstNameController.text,
      'LastName': lastNameController.text,
      'IdNumber': idNumberController.text,
      'WorkId': workIdController.text,
      'Department': departmentController.text,
      'Position': positionController.text,
      'email': emailController.text,
      'ContactNumber': contactNumberController.text,
      'DateOfBirth': Timestamp.fromDate(
          DateTime.tryParse(dateOfBirthController.text) ?? DateTime.now()),
      'address': addressController.text,
      'Gender': genderController.text,
      'Race': raceController.text,
      'Password': passwordController.text,
      'MaritalStatus': maritalStatusController.text,
      'UpdatedAt': FieldValue.serverTimestamp(),
    });

    if (vm.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      // ✅ Use named route for DocumentsScreen
      Navigator.pushReplacementNamed(
        context,
        RouteManager.documents,
        arguments: {'EmployeeId': widget.EmployeeId},
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmployeeViewModel>();

    if (vm.isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit,
                color: Colors.white),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                color: Colors.white.withOpacity(0.95),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor:
                              const Color.fromARGB(255, 31, 146, 228),
                          child: Text(
                            _getInitials(
                                "${firstNameController.text} ${lastNameController.text}"),
                            style: const TextStyle(
                                fontSize: 28,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${firstNameController.text} ${lastNameController.text}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 31, 146, 228),
                          ),
                        ),
                        const SizedBox(height: 25),
                        _buildCardSection("Personal Info", [
                          _buildTextField("First Name", firstNameController),
                          _buildTextField("Last Name", lastNameController),
                          _buildTextField("Email", emailController),
                          _buildTextField(
                              "Contact Number", contactNumberController),
                          _buildTextField("Date of Birth", dateOfBirthController),
                          _buildTextField("Gender", genderController),
                          _buildTextField("Race", raceController),
                          _buildTextField(
                              "Marital Status", maritalStatusController),
                        ]),
                        const SizedBox(height: 20),
                        _buildCardSection("Job Info", [
                          _buildTextField("Work ID", workIdController),
                          _buildTextField("Department", departmentController),
                          _buildTextField("Position", positionController),
                          _buildTextField("Address", addressController),
                          _buildTextField("ID Number", idNumberController),
                          _buildTextField("Password", passwordController,
                              obscureText: true),
                        ]),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                _isEditing && !vm.isSaving ? _saveProfile : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isEditing
                                  ? const Color.fromARGB(255, 33, 146, 239)
                                  : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: vm.isSaving
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    "Save Profile",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: !_isEditing,
        validator: (value) =>
            value == null || value.isEmpty ? "$label cannot be empty" : null,
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          fillColor: const Color.fromARGB(255, 241, 244, 241),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 171, 204, 232),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.blue,
              width: 2,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCardSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 31, 146, 228))),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(" ");
    return parts.map((e) => e.isNotEmpty ? e[0].toUpperCase() : "").join();
  }
}
