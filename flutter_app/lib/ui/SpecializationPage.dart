import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SpecializationPage extends StatefulWidget {
  const SpecializationPage({Key? key}) : super(key: key);

  @override
  State<SpecializationPage> createState() => _SpecializationPageState();
}

class _SpecializationPageState extends State<SpecializationPage> {
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic> _specializations = {
    'primary': null,
    'secondary': [],
  };

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
          final data = profile['profileData']['specializations'];
          if (data != null) {
            _specializations = Map<String, dynamic>.from(data);
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
        'specializations': _specializations,
      }
    });
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Specializations updated' : 'Failed to update'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _editItem(bool isPrimary, [int? index]) {
    final item = isPrimary
        ? _specializations['primary'] ?? {}
        : _specializations['secondary'][index!];

    final titleController = TextEditingController(text: item['title'] ?? '');
    final subtitleController = TextEditingController(text: item['subtitle'] ?? '');
    final expController = TextEditingController(text: item['experience'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isPrimary ? 'Edit Primary Specialization' : 'Edit Specialization'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title (e.g. Physical Therapy)')),
            TextField(controller: subtitleController, decoration: const InputDecoration(labelText: 'Subtitle (e.g. Rehabilitation)')),
            TextField(controller: expController, decoration: const InputDecoration(labelText: 'Experience (e.g. 10+ years)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final newItem = {
                  'title': titleController.text,
                  'subtitle': subtitleController.text,
                  'experience': expController.text,
                };
                if (isPrimary) {
                  _specializations['primary'] = newItem;
                } else {
                  if (index == null) {
                    _specializations['secondary'].add(newItem);
                  } else {
                    _specializations['secondary'][index] = newItem;
                  }
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
        title: const Text('Specialization', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                          const Text('Primary Specialization', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _editItem(true)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_specializations['primary'] != null)
                        _buildSpecializationCard(
                          _specializations['primary']['title'],
                          _specializations['primary']['subtitle'],
                          _specializations['primary']['experience'],
                          Colors.teal,
                          onTap: () => _editItem(true),
                        )
                      else
                        const Text('No primary specialization set.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                      
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Secondary Specializations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(icon: const Icon(Icons.add_circle_outline, size: 20), onPressed: () => _editItem(false)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...List.generate((_specializations['secondary'] as List).length, (index) {
                        final item = _specializations['secondary'][index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildSpecializationCard(
                            item['title'],
                            item['subtitle'],
                            item['experience'],
                            Colors.blue,
                            onTap: () => _editItem(false, index),
                            onDelete: () => setState(() => _specializations['secondary'].removeAt(index)),
                          ),
                        );
                      }),
                      if ((_specializations['secondary'] as List).isEmpty)
                        const Text('No secondary specializations.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                      
                      const SizedBox(height: 40),
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
                          child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSpecializationCard(String title, String subtitle, String experience, Color color, {VoidCallback? onTap, VoidCallback? onDelete}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.verified, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(experience, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic)),
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
