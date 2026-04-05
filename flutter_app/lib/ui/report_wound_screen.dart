import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class ReportWoundScreen extends StatefulWidget {
  const ReportWoundScreen({super.key});

  @override
  State<ReportWoundScreen> createState() => _ReportWoundScreenState();
}

class _ReportWoundScreenState extends State<ReportWoundScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String selectedPain = "Medium";
  String selectedArea = "Knee";
  File? _selectedImage;
  bool _isSubmitting = false;

  final List<String> _bodyAreas = [
    'Knee', 'Ankle', 'Shoulder', 'Wrist', 'Back', 'Hip', 'Elbow', 'Other'
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF4A90E2)),
              title: const Text('Take a Photo'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF4A90E2)),
              title: const Text('Choose from Gallery'),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (selectedArea.isEmpty || selectedPain.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await ApiService.submitWoundReport(
      woundArea: selectedArea,
      painLevel: selectedPain,
      description: _descriptionController.text.trim(),
      notes: _notesController.text.trim(),
      imageFile: _selectedImage != null ? File(_selectedImage!.path) : null,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wound report submitted! Your doctor will be notified.'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // HEADER
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, size: 18),
                  ),
                  const Spacer(),
                  const Text(
                    "Report Wound",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const SizedBox(width: 36),
                ],
              ),

              const SizedBox(height: 30),

              // UPLOAD PHOTO
              const Text("Upload Photo",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _showImageSourceSheet,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD6DEEA)),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8EEF8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.add, size: 28, color: Color(0xFF4A90E2)),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Tap to take or upload a wound photo",
                              style: TextStyle(fontSize: 13, color: Color(0xFF7A8194)),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 28),

              // WOUND AREA
              const Text("Wound Area",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedArea,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF4A90E2)),
                    items: _bodyAreas
                        .map((area) => DropdownMenuItem(value: area, child: Text(area)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedArea = val!),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // PAIN LEVEL
              const Text("Pain Level",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              Row(
                children: [
                  _painOption("Low", Colors.teal),
                  const SizedBox(width: 12),
                  _painOption("Medium", Colors.orange),
                  const SizedBox(width: 12),
                  _painOption("High", Colors.red),
                ],
              ),

              const SizedBox(height: 28),

              // DESCRIPTION
              const Text("Description",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: "Describe what the wound looks like...",
                    hintStyle: TextStyle(color: Color(0xFF7A8194), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // NOTES
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: "Additional notes (optional)...",
                    hintStyle: TextStyle(color: Color(0xFF7A8194), fontSize: 14),
                    prefixIcon: Icon(Icons.note_alt_outlined, color: Color(0xFF4A90E2)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // SUBMIT BUTTON
              GestureDetector(
                onTap: _isSubmitting ? null : _submitReport,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6FA8F6), Color(0xFF4A90E2)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x334A90E2),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _isSubmitting
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              "Submit Report",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _painOption(String label, Color color) {
    final bool isSelected = selectedPain == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedPain = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
