import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import 'DoctorHome.dart';
import 'OnboardingPage.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController ageController;
  late TextEditingController dateOfBirthController;
  late TextEditingController locationController;
  late TextEditingController injuryDateController;
  late TextEditingController otherDiagnosisController;
  late TextEditingController otherAssistiveDeviceController;
  late TextEditingController otherAllergyController;
  late TextEditingController otherAffectedAreaController;
  late TextEditingController otherMobilityLevelController;
  late TextEditingController otherMedicationStatusController;
  late TextEditingController otherRehabGoalController;

  DateTime? selectedDateOfBirth;
  DateTime? selectedInjuryDate;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool acceptedTerms = false;
  int currentStep = 0;
  String? selectedGender;
  String? selectedPainLevel;
  String? selectedDiagnosis;
  String? selectedAffectedArea;
  String? selectedMobilityLevel;
  String? selectedAssistiveDevice;
  String? selectedMedicationStatus;
  String? selectedAllergyStatus;
  String? selectedRehabGoal;
  File? selectedProfileImage;

  PasswordStrength _passwordStrength = PasswordStrength.none;

  void _onSocialTap(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider sign up coming soon')),
    );
  }

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    ageController = TextEditingController();
    dateOfBirthController = TextEditingController();
    locationController = TextEditingController();
    injuryDateController = TextEditingController();
    otherDiagnosisController = TextEditingController();
    otherAssistiveDeviceController = TextEditingController();
    otherAllergyController = TextEditingController();
    otherAffectedAreaController = TextEditingController();
    otherMobilityLevelController = TextEditingController();
    otherMedicationStatusController = TextEditingController();
    otherRehabGoalController = TextEditingController();

    passwordController.addListener(_onPasswordChanged);
    confirmPasswordController.addListener(_onConfirmPasswordChanged);
  }

  void _onConfirmPasswordChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    passwordController.removeListener(_onPasswordChanged);
    confirmPasswordController.removeListener(_onConfirmPasswordChanged);
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    ageController.dispose();
    dateOfBirthController.dispose();
    locationController.dispose();
    injuryDateController.dispose();
    otherDiagnosisController.dispose();
    otherAssistiveDeviceController.dispose();
    otherAllergyController.dispose();
    otherAffectedAreaController.dispose();
    otherMobilityLevelController.dispose();
    otherMedicationStatusController.dispose();
    otherRehabGoalController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day / $month / $year';
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    final hadBirthdayThisYear = now.month > birthDate.month ||
        (now.month == birthDate.month && now.day >= birthDate.day);
    if (!hadBirthdayThisYear) {
      age--;
    }
    return age;
  }

  DateTime? _tryParseDateFromText(String value) {
    final compact = value.replaceAll(' ', '');
    final parts = compact.split('/');
    if (parts.length != 3) {
      return null;
    }

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return null;
    }

    try {
      final parsed = DateTime(year, month, day);
      final isValidDate =
          parsed.year == year && parsed.month == month && parsed.day == day;
      if (!isValidDate || parsed.isAfter(DateTime.now())) {
        return null;
      }
      return parsed;
    } catch (_) {
      return null;
    }
  }

  void _onDateOfBirthTyped(String value) {
    final parsed = _tryParseDateFromText(value);
    if (parsed == null) {
      setState(() {
        selectedDateOfBirth = null;
        ageController.clear();
      });
      return;
    }

    setState(() {
      selectedDateOfBirth = parsed;
      ageController.text = _calculateAge(parsed).toString();
    });
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initialDate = selectedDateOfBirth ??
        _tryParseDateFromText(dateOfBirthController.text) ??
        now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked == null) {
      return;
    }

    setState(() {
      selectedDateOfBirth = picked;
      dateOfBirthController.text = _formatDate(picked);
      ageController.text = _calculateAge(picked).toString();
    });
  }

  Future<void> _pickInjuryDate() async {
    final now = DateTime.now();
    final initialDate = selectedInjuryDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked == null) {
      return;
    }

    setState(() {
      selectedInjuryDate = picked;
      injuryDateController.text = _formatDate(picked);
    });
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        selectedProfileImage = File(image.path);
      });
    }
  }

  void _onPasswordChanged() {
    final nextStrength = _evaluatePasswordStrength(passwordController.text);
    if (nextStrength != _passwordStrength && mounted) {
      setState(() {
        _passwordStrength = nextStrength;
      });
    } else if (mounted) {
      setState(() {});
    }
  }

  PasswordStrength _evaluatePasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.none;

    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(password)) score++;
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;

    if (score <= 1) return PasswordStrength.weak;
    if (score <= 3) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  bool get _passwordsMatch =>
      confirmPasswordController.text.isNotEmpty &&
      passwordController.text == confirmPasswordController.text;

  bool _hasMinLength(String password) => password.length >= 8;
  bool _hasUpperCase(String password) => RegExp(r'[A-Z]').hasMatch(password);
  bool _hasLowerCase(String password) => RegExp(r'[a-z]').hasMatch(password);
  bool _hasNumber(String password) => RegExp(r'\d').hasMatch(password);
  bool _hasSpecialChar(String password) =>
      RegExp(r'[^A-Za-z0-9]').hasMatch(password);

  String get _normalizedEmail => emailController.text.trim().toLowerCase();

  // Explicit Role tracking variable
  String? selectedRole;

  bool _isPhoneValid(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    return digitsOnly.length >= 8;
  }

  bool _validateStepOne() {
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return false;
    }

    if (!_isPhoneValid(phoneController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return false;
    }

    if (_passwordStrength == PasswordStrength.weak ||
        _passwordStrength == PasswordStrength.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please use at least a medium-strength password'),
        ),
      );
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return false;
    }

    if (!acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept Terms of Use and Privacy Policy'),
        ),
      );
      return false;
    }

    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select whether you are a Doctor or Patient.'),
        ),
      );
      return false;
    }

    return true;
  }

  bool _validateStepTwo() {
    if (selectedGender == null ||
        dateOfBirthController.text.trim().isEmpty ||
        ageController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please complete gender, date of birth, age and address'),
        ),
      );
      return false;
    }

    final age = int.tryParse(ageController.text.trim());
    if (age == null || age < 1 || age > 120) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid age')),
      );
      return false;
    }

    return true;
  }

  bool _validateStepThree() {
    if (selectedDiagnosis == null ||
        selectedAffectedArea == null ||
        selectedPainLevel == null ||
        selectedMobilityLevel == null ||
        selectedAssistiveDevice == null ||
        selectedMedicationStatus == null ||
        selectedAllergyStatus == null ||
        selectedRehabGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select all medical history fields'),
        ),
      );
      return false;
    }

    // Validate "Other" fields have text
    if (selectedDiagnosis == 'Other' &&
        otherDiagnosisController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please specify the diagnosis')),
      );
      return false;
    }

    if (selectedAffectedArea == 'Other' &&
        otherAffectedAreaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please specify the affected body area')),
      );
      return false;
    }

    if (selectedMobilityLevel == 'Other' &&
        otherMobilityLevelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please specify the mobility limitation')),
      );
      return false;
    }

    if (selectedAssistiveDevice == 'Other' &&
        otherAssistiveDeviceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please specify the assistive device')),
      );
      return false;
    }

    if (selectedMedicationStatus == 'Other' &&
        otherMedicationStatusController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please specify the medication')),
      );
      return false;
    }

    if (selectedAllergyStatus == 'Other' &&
        otherAllergyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please specify the allergy or contraindication')),
      );
      return false;
    }

    if (selectedRehabGoal == 'Other' &&
        otherRehabGoalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please specify the rehabilitation goal')),
      );
      return false;
    }

    return true;
  }

  void _goToPersonalInfo() {
    if (!_validateStepOne()) {
      return;
    }

    setState(() {
      currentStep = 1;
    });
  }

  void _goToMedicalHistory() {
    if (!_validateStepTwo()) {
      return;
    }

    if (selectedRole == 'doctor') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DoctorHome()),
      );
      return;
    }

    setState(() {
      currentStep = 2;
    });
  }

  Future<void> handleSignUp() async {
    if (!_validateStepOne() || !_validateStepTwo()) {
      return;
    }

    if (selectedRole != 'doctor' && !_validateStepThree()) {
      return;
    }

    // Prepare Name
    final fullName = '${firstNameController.text.trim()} ${lastNameController.text.trim()}';

    // Prepare Profile Data Map
    final Map<String, dynamic> profileData = {
      "phone": phoneController.text.trim(),
      "role": selectedRole,
      // Step 2 details
      "gender": selectedGender,
      "dateOfBirth": dateOfBirthController.text.trim(),
      "age": int.tryParse(ageController.text.trim()),
      "location": locationController.text.trim(),
    };

    // If it's a patient, add Step 3 Medical History details
    if (selectedRole != 'doctor') {
      profileData.addAll({
        "diagnosis": selectedDiagnosis == 'Other' ? otherDiagnosisController.text.trim() : selectedDiagnosis,
        "affectedArea": selectedAffectedArea == 'Other' ? otherAffectedAreaController.text.trim() : selectedAffectedArea,
        "currentPainLevel": selectedPainLevel,
        "mobilityLimitations": selectedMobilityLevel == 'Other' ? otherMobilityLevelController.text.trim() : selectedMobilityLevel,
        "assistiveDevices": selectedAssistiveDevice == 'Other' ? otherAssistiveDeviceController.text.trim() : selectedAssistiveDevice,
        "currentMedicationUse": selectedMedicationStatus == 'Other' ? otherMedicationStatusController.text.trim() : selectedMedicationStatus,
        "allergies": selectedAllergyStatus == 'Other' ? otherAllergyController.text.trim() : selectedAllergyStatus,
        "injuryDate": injuryDateController.text.trim(),
        "rehabilitationGoal": selectedRehabGoal == 'Other' ? otherRehabGoalController.text.trim() : selectedRehabGoal,
      });
    }

    try {
      final response = await AuthService.register(
        name: fullName,
        email: emailController.text.trim(),
        password: passwordController.text,
        profileData: profileData,
      );

      if (response['statusCode'] == 201) {
        // Success: Registration complete!
        // You could theoretically also call login here to get a token instantly,
        // but for now, let's just proceed to Onboarding/Home.
        
        if (selectedRole == 'doctor') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DoctorHome()),
          );
          return;
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OnboardingPage(userEmail: emailController.text),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['data']['message'] ?? 'Sign Up failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: Could not connect to the server.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
    double labelFontSize = 14,
  }) {
    return InputDecoration(
      prefixIcon: prefixIcon == null
          ? null
          : Icon(
              prefixIcon,
              color: Colors.grey[600],
            ),
      suffixIcon: suffixIcon,
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey[400],
        fontSize: 14,
      ),
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.grey[700],
        fontSize: labelFontSize,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey[300]!,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(
          color: Color(0xFF2196F3),
          width: 2,
        ),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 14,
      ),
    );
  }

  Widget _buildRehabDropdown({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: _inputDecoration(
        label: label,
        hint: hint,
        prefixIcon: icon,
        labelFontSize: 15,
      ),
      borderRadius: BorderRadius.circular(12),
      items: options
          .map(
            (option) => DropdownMenuItem(
              value: option,
              child: Text(option),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildStepOneContent() {
    return Column(
      children: [
        // ROLE SELECTION UI
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedRole = 'patient';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: selectedRole == 'patient'
                        ? const Color(0xFF2196F3).withValues(alpha: 0.1)
                        : Colors.white,
                    border: Border.all(
                      color: selectedRole == 'patient'
                          ? const Color(0xFF2196F3)
                          : Colors.grey.shade300,
                      width: selectedRole == 'patient' ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.accessible_forward,
                        size: 32,
                        color: selectedRole == 'patient'
                            ? const Color(0xFF2196F3)
                            : Colors.grey.shade500,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Patient',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: selectedRole == 'patient'
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: selectedRole == 'patient'
                              ? const Color(0xFF2196F3)
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedRole = 'doctor';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: selectedRole == 'doctor'
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                        : Colors.white,
                    border: Border.all(
                      color: selectedRole == 'doctor'
                          ? const Color(0xFF4CAF50)
                          : Colors.grey.shade300,
                      width: selectedRole == 'doctor' ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.local_hospital,
                        size: 32,
                        color: selectedRole == 'doctor'
                            ? const Color(0xFF4CAF50)
                            : Colors.grey.shade500,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Doctor',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: selectedRole == 'doctor'
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: selectedRole == 'doctor'
                              ? const Color(0xFF4CAF50)
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: firstNameController,
                decoration: _inputDecoration(
                  label: 'First Name',
                  hint: 'First Name',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: lastNameController,
                decoration: _inputDecoration(
                  label: 'Last Name',
                  hint: 'Last Name',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _inputDecoration(
            label: 'Phone Number',
            hint: '01012345678',
            prefixIcon: Icons.phone_outlined,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(
            label: 'Email',
            hint: 'example@gmail.com',
            prefixIcon: Icons.mail_outline,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          decoration: _inputDecoration(
            label: 'Password',
            hint: '••••••••••',
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: confirmPasswordController,
          obscureText: obscureConfirmPassword,
          decoration: _inputDecoration(
            label: 'Confirm Password',
            hint: '••••••••••',
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  obscureConfirmPassword = !obscureConfirmPassword;
                });
              },
              icon: Icon(
                obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
        if (passwordController.text.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(
                color: Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Password Requirements:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _RequirementCheck(
                  text: 'At least 8 characters',
                  isMet: _hasMinLength(passwordController.text),
                ),
                _RequirementCheck(
                  text: 'Capital letter (A-Z)',
                  isMet: _hasUpperCase(passwordController.text),
                ),
                _RequirementCheck(
                  text: 'Lowercase letter (a-z)',
                  isMet: _hasLowerCase(passwordController.text),
                ),
                _RequirementCheck(
                  text: 'Number (0-9)',
                  isMet: _hasNumber(passwordController.text),
                ),
                _RequirementCheck(
                  text: 'Special character (!@#\$%^&*)',
                  isMet: _hasSpecialChar(passwordController.text),
                ),
              ],
            ),
          ),
        ],
        if (confirmPasswordController.text.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                _passwordsMatch ? Icons.check_circle : Icons.cancel,
                size: 18,
                color: _passwordsMatch ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 6),
              Text(
                _passwordsMatch ? 'Passwords match' : 'Passwords do not match',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _passwordsMatch ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
              value: acceptedTerms,
              onChanged: (value) {
                setState(() {
                  acceptedTerms = value ?? false;
                });
              },
              activeColor: const Color(0xFF2196F3),
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: Text(
                'I accept the Terms of Use & Privacy Policy',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _goToPersonalInfo,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Or Continue with',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _SocialAuthButton(
              onTap: () => _onSocialTap('Apple'),
              child: const Icon(
                Icons.apple,
                color: Colors.black,
                size: 26,
              ),
            ),
            _SocialAuthButton(
              onTap: () => _onSocialTap('Google'),
              child: const _GoogleLogo(),
            ),
            _SocialAuthButton(
              onTap: () => _onSocialTap('Facebook'),
              child: const Text(
                'f',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1877F2),
                  height: 0.95,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepTwoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickProfileImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: selectedProfileImage != null
                          ? FileImage(selectedProfileImage!)
                          : null,
                      child: selectedProfileImage == null
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey[600],
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add Profile Photo (Optional)',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: dateOfBirthController,
          keyboardType: TextInputType.datetime,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9/ ]')),
          ],
          onChanged: _onDateOfBirthTyped,
          decoration: _inputDecoration(
            label: 'Date of Birth',
            hint: 'DD / MM / YYYY',
            prefixIcon: Icons.date_range_outlined,
            suffixIcon: IconButton(
              onPressed: _pickDateOfBirth,
              icon: const Icon(Icons.calendar_month_outlined),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: ageController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _inputDecoration(
            label: 'Age',
            hint: 'Enter age or use date of birth',
            prefixIcon: Icons.cake_outlined,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: selectedGender,
          decoration: _inputDecoration(
            label: 'Gender',
            hint: 'Select gender',
            prefixIcon: Icons.wc_outlined,
          ),
          borderRadius: BorderRadius.circular(12),
          items: const [
            DropdownMenuItem(value: 'Male', child: Text('Male')),
            DropdownMenuItem(value: 'Female', child: Text('Female')),
            DropdownMenuItem(value: 'Other', child: Text('Other')),
          ],
          onChanged: (value) {
            setState(() {
              selectedGender = value;
            });
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: locationController,
          decoration: _inputDecoration(
            label: 'Address',
            hint: 'Street, City, Country',
            prefixIcon: Icons.location_on_outlined,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    currentStep = 0;
                  });
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  side: const BorderSide(color: Color(0xFF2196F3), width: 1.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    color: Color(0xFF2196F3),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _goToMedicalHistory,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: const Color(0xFF2196F3),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  selectedRole == 'doctor' ? 'Sign Up' : 'Continue',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepThreeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _buildRehabDropdown(
          label: 'Primary Diagnosis / Injury',
          hint: 'Select diagnosis',
          icon: Icons.description_outlined,
          value: selectedDiagnosis,
          options: const [
            'Stroke',
            'ACL Tear',
            'Post Fracture',
            'Spinal Injury',
            'Shoulder Injury',
            'Total Knee Replacement',
            'Other',
          ],
          onChanged: (value) {
            setState(() {
              selectedDiagnosis = value;
              if (value != 'Other') {
                otherDiagnosisController.clear();
              }
            });
          },
        ),
        if (selectedDiagnosis == 'Other') ...[
          const SizedBox(height: 12),
          TextField(
            controller: otherDiagnosisController,
            decoration: _inputDecoration(
              label: 'Specify Other Diagnosis',
              hint: 'Enter your diagnosis',
              prefixIcon: Icons.edit_outlined,
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildRehabDropdown(
          label: 'Affected Body Area',
          hint: 'Select area',
          icon: Icons.accessibility_new_outlined,
          value: selectedAffectedArea,
          options: const [
            'Neck',
            'Shoulder',
            'Arm',
            'Back',
            'Hip',
            'Knee',
            'Ankle / Foot',
            'Multiple Areas',
            'Other',
          ],
          onChanged: (value) {
            setState(() {
              selectedAffectedArea = value;
              if (value != 'Other') {
                otherAffectedAreaController.clear();
              }
            });
          },
        ),
        if (selectedAffectedArea == 'Other') ...[
          const SizedBox(height: 12),
          TextField(
            controller: otherAffectedAreaController,
            decoration: _inputDecoration(
              label: 'Specify Other Body Area',
              hint: 'Enter the affected body area',
              prefixIcon: Icons.edit_outlined,
            ),
          ),
        ],
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: selectedPainLevel,
          isExpanded: true,
          decoration: _inputDecoration(
            label: 'Current Pain Level',
            hint: 'Select pain level (0-10)',
            prefixIcon: Icons.monitor_heart_outlined,
          ),
          borderRadius: BorderRadius.circular(12),
          items: List.generate(
            11,
            (index) => DropdownMenuItem(
              value: index.toString(),
              child: Text('$index / 10'),
            ),
          ),
          onChanged: (value) {
            setState(() {
              selectedPainLevel = value;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildRehabDropdown(
          label: 'Mobility Limitations',
          hint: 'Select mobility status',
          icon: Icons.directions_walk_outlined,
          value: selectedMobilityLevel,
          options: const [
            'No major limitation',
            'Mild limitation',
            'Moderate limitation',
            'Severe limitation',
            'Unable to walk independently',
            'Other',
          ],
          onChanged: (value) {
            setState(() {
              selectedMobilityLevel = value;
              if (value != 'Other') {
                otherMobilityLevelController.clear();
              }
            });
          },
        ),
        if (selectedMobilityLevel == 'Other') ...[
          const SizedBox(height: 12),
          TextField(
            controller: otherMobilityLevelController,
            decoration: _inputDecoration(
              label: 'Specify Other Limitation',
              hint: 'Enter your mobility limitation',
              prefixIcon: Icons.edit_outlined,
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildRehabDropdown(
          label: 'Assistive Devices',
          hint: 'Select assistive device',
          icon: Icons.elderly_outlined,
          value: selectedAssistiveDevice,
          options: const [
            'None',
            'Walker',
            'Crutches',
            'Cane',
            'Wheelchair',
            'Knee Brace',
            'Ankle Foot Orthosis (AFO)',
            'Other',
          ],
          onChanged: (value) {
            setState(() {
              selectedAssistiveDevice = value;
              if (value != 'Other') {
                otherAssistiveDeviceController.clear();
              }
            });
          },
        ),
        if (selectedAssistiveDevice == 'Other') ...[
          const SizedBox(height: 12),
          TextField(
            controller: otherAssistiveDeviceController,
            decoration: _inputDecoration(
              label: 'Specify Other Device',
              hint: 'Enter the assistive device',
              prefixIcon: Icons.edit_outlined,
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildRehabDropdown(
          label: 'Current Medication Use',
          hint: 'Select medication status',
          icon: Icons.medication_outlined,
          value: selectedMedicationStatus,
          options: const [
            'No medications',
            'Pain medications',
            'Anti-inflammatory medications',
            'Muscle relaxants',
            'Multiple medications',
            'Not sure',
            'Other',
          ],
          onChanged: (value) {
            setState(() {
              selectedMedicationStatus = value;
              if (value != 'Other') {
                otherMedicationStatusController.clear();
              }
            });
          },
        ),
        if (selectedMedicationStatus == 'Other') ...[
          const SizedBox(height: 12),
          TextField(
            controller: otherMedicationStatusController,
            decoration: _inputDecoration(
              label: 'Specify Other Medication',
              hint: 'Enter your medication details',
              prefixIcon: Icons.edit_outlined,
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildRehabDropdown(
          label: 'Allergies / Contraindications',
          hint: 'Select allergy status',
          icon: Icons.warning_amber_outlined,
          value: selectedAllergyStatus,
          options: const [
            'None',
            'Drug allergies',
            'Latex allergy',
            'Skin sensitivity',
            'Known contraindications to therapy',
            'Other',
          ],
          onChanged: (value) {
            setState(() {
              selectedAllergyStatus = value;
              if (value != 'Other') {
                otherAllergyController.clear();
              }
            });
          },
        ),
        if (selectedAllergyStatus == 'Other') ...[
          const SizedBox(height: 12),
          TextField(
            controller: otherAllergyController,
            decoration: _inputDecoration(
              label: 'Specify Other Allergy / Contraindication',
              hint: 'Enter the allergy or contraindication',
              prefixIcon: Icons.edit_outlined,
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: injuryDateController,
          keyboardType: TextInputType.datetime,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9/ ]')),
          ],
          decoration: _inputDecoration(
            label: 'Injury / Surgery Date',
            hint: 'DD / MM / YYYY',
            prefixIcon: Icons.calendar_month_outlined,
            suffixIcon: IconButton(
              onPressed: _pickInjuryDate,
              icon: const Icon(Icons.calendar_today_outlined),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildRehabDropdown(
          label: 'Rehabilitation Goal',
          hint: 'Select primary goal',
          icon: Icons.flag_outlined,
          value: selectedRehabGoal,
          options: const [
            'Reduce pain',
            'Improve range of motion',
            'Walk independently',
            'Improve balance',
            'Return to work',
            'Return to sports',
            'Improve daily activities',
            'Other',
          ],
          onChanged: (value) {
            setState(() {
              selectedRehabGoal = value;
              if (value != 'Other') {
                otherRehabGoalController.clear();
              }
            });
          },
        ),
        if (selectedRehabGoal == 'Other') ...[
          const SizedBox(height: 12),
          TextField(
            controller: otherRehabGoalController,
            decoration: _inputDecoration(
              label: 'Specify Other Goal',
              hint: 'Enter your rehabilitation goal',
              prefixIcon: Icons.edit_outlined,
            ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    currentStep = 1;
                  });
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  side: const BorderSide(color: Color(0xFF2196F3), width: 1.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    color: Color(0xFF2196F3),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: handleSignUp,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: const Color(0xFF2196F3),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB3D9E8),
              Color(0xFFD4E8F0),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  if (currentStep == 0)
                    const SizedBox(height: 5)
                  else if (currentStep == 1)
                    const SizedBox(height: 20)
                  else
                    const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: currentStep == 0
                          ? const EdgeInsets.fromLTRB(24, 16, 24, 35)
                          : currentStep == 1
                              ? const EdgeInsets.fromLTRB(24, 16, 24, 80)
                              : const EdgeInsets.fromLTRB(24, 16, 24, 10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 28,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            currentStep == 0
                                ? (selectedRole == 'doctor'
                                    ? 'Step 1 of 2 • Essential account details'
                                    : 'Step 1 of 3 • Essential account details')
                                : currentStep == 1
                                    ? (selectedRole == 'doctor'
                                        ? 'Step 2 of 2 • Personal information'
                                        : 'Step 2 of 3 • Personal information')
                                    : 'Step 3 of 3 • Medical history',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (currentStep == 0)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              child: _buildStepOneContent(),
                            )
                          else if (currentStep == 1)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              child: _buildStepTwoContent(),
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              padding:
                                  const EdgeInsets.fromLTRB(16, 24, 16, 16),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.75,
                                ),
                                child: SingleChildScrollView(
                                  child: _buildStepThreeContent(),
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Log in here!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum PasswordStrength { none, weak, medium, strong }

class _RequirementCheck extends StatelessWidget {
  const _RequirementCheck({
    required this.text,
    required this.isMet,
  });

  final String text;
  final bool isMet;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? Colors.green : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isMet ? Colors.green : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialAuthButton extends StatelessWidget {
  const _SocialAuthButton({
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        width: 72,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4285F4),
            Color(0xFFEA4335),
            Color(0xFFFBBC05),
            Color(0xFF34A853),
            Color(0xFF4285F4),
          ],
          stops: [0.0, 0.3, 0.55, 0.8, 1.0],
        ).createShader(bounds);
      },
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
