import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/api_service.dart';

class AddNewPatient extends StatefulWidget {
  const AddNewPatient({Key? key}) : super(key: key);

  @override
  State<AddNewPatient> createState() => _AddNewPatientState();
}

class _AddNewPatientState extends State<AddNewPatient> {
  bool _isLoading = true;
  List<dynamic> _availablePatients = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPatients() async {
    setState(() => _isLoading = true);
    try {
      final allPatients = await ApiService.getAllPatientsForDoctor(name: _searchQuery);
      
      // Filter out patients that already have an assigned doctor
      final unassignedPatients = allPatients.where((p) => p['assignedDoctorId'] == null).toList();

      if (mounted) {
        setState(() {
          _availablePatients = unassignedPatients;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load patients'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _assignPatient(String patientId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await ApiService.assignExistingPatient(patientId);

    if (mounted) {
      if (Navigator.canPop(context)) Navigator.pop(context); // pop loading
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient assigned successfully!'), backgroundColor: Colors.green),
        );
        _fetchPatients(); // Refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to assign patient'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Add New Patient',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                _searchQuery = val;
                _fetchPatients();
              },
              decoration: InputDecoration(
                hintText: 'Search patients by name...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF4F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6BA5CF)))
                : _availablePatients.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_search_rounded, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty 
                                ? 'No unassigned patients found.' 
                                : 'No patients match your search.',
                              style: TextStyle(color: Colors.grey[500], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _availablePatients.length,
                        itemBuilder: (context, index) {
                          final patient = _availablePatients[index];
                          final profileData = patient['profileData'] ?? {};
                          final age = profileData['age'] ?? 'N/A';
                          final gender = profileData['gender'] ?? 'N/A';
                          final name = patient['name'] ?? 'Unknown';
                          final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: const Color(0xFF6BA5CF).withValues(alpha: 0.2),
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      color: Color(0xFF6BA5CF),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF2D3142),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Age: $age • $gender',
                                        style: const TextStyle(
                                          color: Color(0xFF9098B1),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => _assignPatient(patient['id']),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6BA5CF),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
