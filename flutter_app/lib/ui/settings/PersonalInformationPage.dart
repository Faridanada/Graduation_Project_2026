import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rehabilitation_app/services/api_service.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({Key? key}) : super(key: key);

  @override
  State<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  bool isLoading = true;
  bool isEditing = false;
  bool isSaving = false;
  Map<String, dynamic> userProfile = {};

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final List<String> _ptSpecialties = [
    'Orthopedic Physical Therapy',
    'Geriatric Physical Therapy',
    'Neurological Physical Therapy',
    'Cardiopulmonary Physical Therapy',
    'Pediatric Physical Therapy',
    'Sports Physical Therapy',
    'Women\'s Health',
    'General Physical Therapy',
    'Other'
  ];
  String? _selectedSpecialty;

  @override
  void initState() {
    super.initState();
    _loadData();
    ApiService.profileUpdateNotifier.addListener(_loadData);
  }

  @override
  void dispose() {
    ApiService.profileUpdateNotifier.removeListener(_loadData);
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final profile = await ApiService.getUserProfile() ?? {};
      if (mounted) {
        setState(() {
          userProfile = profile;
          _nameController.text = userProfile['name'] ?? '';
          _phoneController.text = userProfile['phone'] ?? '';
          _locationController.text =
              userProfile['profileData']?['location'] ?? '';
          _dobController.text =
              userProfile['profileData']?['dateOfBirth'] ?? '';
          _genderController.text = userProfile['profileData']?['gender'] ?? '';
          
          final loadedSpecialty = userProfile['profileData']?['specialty'];
          if (loadedSpecialty != null && loadedSpecialty.toString().isNotEmpty) {
            if (_ptSpecialties.contains(loadedSpecialty)) {
              _selectedSpecialty = loadedSpecialty;
            } else {
              _ptSpecialties.add(loadedSpecialty);
              _selectedSpecialty = loadedSpecialty;
            }
          }
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _saveData() async {
    setState(() => isSaving = true);
    final success = await ApiService.updateProfile({
      'name': _nameController.text,
      'phone': _phoneController.text,
      'profileData': {
        'phone': _phoneController.text,
        'location': _locationController.text,
        'dateOfBirth': _dobController.text,
        'gender': _genderController.text,
        if (userProfile['role'] == 'doctor') 'specialty': _selectedSpecialty ?? '',
      }
    });

    setState(() => isSaving = false);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() => isEditing = false);
      _loadData();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    
    if (image != null) {
      setState(() => isSaving = true);
      final success = await ApiService.updateProfileImage(File(image.path));
      setState(() => isSaving = false);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile picture'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: const Text(
          'Personal Information',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!isLoading && !isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black87),
              onPressed: () => setState(() => isEditing = true),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  _buildProfilePictureSection(),
                  const SizedBox(height: 20),
                  _buildField(
                      'Full Name', userProfile['name'], _nameController),
                  _buildField('Email', userProfile['email'], null,
                      readOnly: true),
                  _buildField('Phone', userProfile['phone'],
                      _phoneController),
                  _buildField(
                      'Address',
                      userProfile['profileData']?['location'],
                      _locationController),
                  _buildField(
                      'Date of Birth',
                      userProfile['profileData']?['dateOfBirth'],
                      _dobController),
                  _buildField('Gender', userProfile['profileData']?['gender'],
                      _genderController),
                  if (userProfile['role'] == 'doctor')
                    _buildSpecialtyDropdown(),
                ],
                const SizedBox(height: 30),
                if (isEditing)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _saveData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    final profileImageUrl = userProfile['profileImageUrl'] ?? userProfile['profileImage'];
    final bool hasImage = profileImageUrl != null && profileImageUrl.toString().isNotEmpty;
    
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            backgroundImage: hasImage
                ? NetworkImage(profileImageUrl.toString().startsWith('http') 
                    ? profileImageUrl 
                    : '${ApiService.baseUrl.replaceAll('/api', '')}/$profileImageUrl')
                : null,
            child: !hasImage
                ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                : null,
          ),
          if (isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: isSaving ? null : _pickAndUploadImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                  child: isSaving 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    String? value,
    TextEditingController? controller, {
    bool readOnly = false,
  }) {
    final displayValue = value ?? 'Not set';

    if (isEditing && !readOnly && controller != null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.black87, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayValue.isEmpty ? 'Not set' : displayValue,
            style: TextStyle(
              fontSize: 16,
              color: readOnly ? Colors.grey[600] : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyDropdown() {
    final displayValue = _selectedSpecialty ?? 'Not set';

    if (isEditing) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: DropdownButtonFormField<String>(
          value: _selectedSpecialty,
          decoration: InputDecoration(
            labelText: 'Specialty',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.black87, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          items: _ptSpecialties.map((String specialty) {
            return DropdownMenuItem<String>(
              value: specialty,
              child: Text(specialty),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedSpecialty = newValue;
            });
          },
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Specialty',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayValue.isEmpty ? 'Not set' : displayValue,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
