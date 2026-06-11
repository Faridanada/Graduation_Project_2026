import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/ui/patient/home/patient_bottom_nav.dart';

class ReportWoundScreen extends StatefulWidget {
  const ReportWoundScreen({super.key});

  @override
  State<ReportWoundScreen> createState() => _ReportWoundScreenState();
}

class _ReportWoundScreenState extends State<ReportWoundScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  String selectedPain = "Medium";
  String selectedArea = "Knee";
  File? _selectedImage;
  bool _isSubmitting = false;
  String? _errorMessage;

  final List<String> _bodyAreas = [
    'Knee',
    'Ankle',
    'Shoulder',
    'Wrist',
    'Back',
    'Hip',
    'Elbow',
    'Other'
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
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
              leading: const Icon(Icons.camera_alt_rounded,
                  color: Color(0xFF4A90E2)),
              title: const Text('Take a Photo'),
              onTap: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: Color(0xFF4A90E2)),
              title: const Text('Choose from Gallery'),
              onTap: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    setState(() => _errorMessage = null);
    if (selectedArea.isEmpty || selectedPain.isEmpty) {
      setState(() => _errorMessage = 'Please fill all required fields');
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await ApiService.submitWoundReport(
      woundArea: selectedArea,
      painLevel: selectedPain,
      description: _descriptionController.text.trim(),
      imageFile: _selectedImage != null ? File(_selectedImage!.path) : null,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Wound report submitted! Your doctor will be notified.'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
      if (Navigator.canPop(context)) Navigator.pop(context);
    } else {
      setState(() => _errorMessage = 'Failed to submit. Please try again.');
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
                    onTap: () {
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back_ios, size: 18),
                  ),
                  const Spacer(),
                  const Text(
                    "Report Wound",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyWoundsHistoryScreen()));
                    },
                    child: const Icon(Icons.history,
                        size: 24, color: Color(0xFF4A90E2)),
                  ),
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
                              child: const Icon(Icons.add,
                                  size: 28, color: Color(0xFF4A90E2)),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Tap to take or upload a wound photo",
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFF7A8194)),
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
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: Color(0xFF4A90E2)),
                    items: _bodyAreas
                        .map((area) =>
                            DropdownMenuItem(value: area, child: Text(area)))
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
                    hintStyle:
                        TextStyle(color: Color(0xFF7A8194), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

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
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white))
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

class MyWoundsHistoryScreen extends StatefulWidget {
  const MyWoundsHistoryScreen({super.key});

  @override
  State<MyWoundsHistoryScreen> createState() => _MyWoundsHistoryScreenState();
}

class _MyWoundsHistoryScreenState extends State<MyWoundsHistoryScreen> {
  List<dynamic> _wounds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final wounds = await ApiService.getMyWounds();
    if (mounted) {
      setState(() {
        _wounds = wounds;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: const Text(
          "My Reports",
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _wounds.isEmpty
              ? const Center(
                  child: Text("No wound reports found.",
                      style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _wounds.length,
                  itemBuilder: (context, index) {
                    final w = _wounds[index];
                    final meta = w['metadata'] ?? {};
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  meta['woundArea'] ?? 'Unknown Area',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (w['status'] == 'reviewed' ||
                                                w['status'] == 'healed'
                                            ? Colors.green
                                            : Colors.orange)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    (w['status'] ?? 'pending')
                                        .toString()
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: w['status'] == 'reviewed' ||
                                              w['status'] == 'healed'
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text("Pain Level: ${meta['painLevel'] ?? 'N/A'}",
                                style: TextStyle(
                                    color: Colors.grey[700], fontSize: 13)),
                            if (meta['description'] != null &&
                                meta['description'].toString().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(meta['description'],
                                  style: const TextStyle(fontSize: 14)),
                            ],
                            const SizedBox(height: 12),
                            Text(
                              "Reported on: ${w['createdAt'] != null ? w['createdAt'].toString().substring(0, 10) : 'Unknown'}",
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
