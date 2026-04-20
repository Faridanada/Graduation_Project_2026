import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MedicalLicensePage extends StatefulWidget {
  const MedicalLicensePage({Key? key}) : super(key: key);

  @override
  State<MedicalLicensePage> createState() => _MedicalLicensePageState();
}

class _MedicalLicensePageState extends State<MedicalLicensePage> {
  bool _isLoading = true;
  bool _isSaving = false;
  List<dynamic> _licenses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = await ApiService.getUserProfile();
    if (mounted) {
      setState(() {
        if (profile != null && profile['profileData'] != null) {
          final data = profile['profileData']['medicalLicenses'];
          if (data != null) {
            _licenses = List<dynamic>.from(data);
          }
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _saveData() async {
    setState(() => _isSaving = true);
    final success = await ApiService.updateProfile({
      'profileData': {
        'medicalLicenses': _licenses,
      }
    });
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Licenses updated' : 'Failed to update'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _editLicense([int? index]) {
    final item = index == null ? {} : _licenses[index];

    final titleController = TextEditingController(text: item['title'] ?? '');
    final numberController = TextEditingController(text: item['number'] ?? '');
    final stateController = TextEditingController(text: item['state'] ?? '');
    final issuedController = TextEditingController(text: item['issued'] ?? '');
    final expiresController = TextEditingController(text: item['expires'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? 'Add Medical License' : 'Edit Medical License'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title (e.g. PT License)')),
              TextField(controller: numberController, decoration: const InputDecoration(labelText: 'License Number')),
              TextField(controller: stateController, decoration: const InputDecoration(labelText: 'State')),
              TextField(controller: issuedController, decoration: const InputDecoration(labelText: 'Issued (e.g. Jan 2015)')),
              TextField(controller: expiresController, decoration: const InputDecoration(labelText: 'Expires (e.g. Jan 2025)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final newItem = {
                  'title': titleController.text,
                  'number': numberController.text,
                  'state': stateController.text,
                  'issued': issuedController.text,
                  'expires': expiresController.text,
                };
                if (index == null) {
                  _licenses.add(newItem);
                } else {
                  _licenses[index] = newItem;
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF6BA5CF),
        elevation: 0,
        title: const Text('Medical Licenses', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          if (_isSaving)
            const Center(child: Padding(padding: EdgeInsets.only(right: 16), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
          else
            IconButton(icon: const Icon(Icons.save, color: Colors.white), onPressed: _saveData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Active Licenses & Certifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(icon: const Icon(Icons.add_circle_outline, size: 24), onPressed: () => _editLicense()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_licenses.isEmpty)
                        const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Text('No licenses added yet.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))))
                      else
                        ...List.generate(_licenses.length, (index) {
                          final item = _licenses[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildCredentialCard(
                              item['title'] ?? 'License',
                              'License #: ${item['number'] ?? 'N/A'}',
                              'State: ${item['state'] ?? 'N/A'}',
                              'Issued: ${item['issued'] ?? 'N/A'}',
                              'Expires: ${item['expires'] ?? 'N/A'}',
                              Colors.green,
                              onTap: () => _editLicense(index),
                              onDelete: () => setState(() => _licenses.removeAt(index)),
                            ),
                          );
                        }),
                      
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6BA5CF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Update All Credentials', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCredentialCard(
    String title,
    String line1,
    String line2,
    String line3,
    String line4,
    Color statusColor, {
    VoidCallback? onTap,
    VoidCallback? onDelete,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Text(line1, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  const SizedBox(height: 4),
                  Text(line2, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  const SizedBox(height: 4),
                  Text(line3, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  if (line4.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(line4, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  ],
                ],
              ),
            ),
          ),
          if (onDelete != null)
            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: onDelete),
        ],
      ),
    );
  }
}

