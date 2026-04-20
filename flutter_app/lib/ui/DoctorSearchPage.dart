import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DoctorSearchPage extends StatefulWidget {
  const DoctorSearchPage({Key? key}) : super(key: key);

  @override
  State<DoctorSearchPage> createState() => _DoctorSearchPageState();
}

class _DoctorSearchPageState extends State<DoctorSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _allPatients = [];
  List<dynamic> _allDoctors = [];
  List<dynamic> _filteredPatients = [];
  List<dynamic> _filteredDoctors = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSearchData();
    _searchController.addListener(_applyLocalFilter);
  }

  Future<void> _loadSearchData() async {
    setState(() => _isLoading = true);

    final results = await Future.wait([
      ApiService.getAllPatientsForDoctor(),
      ApiService.getAllDoctorsForDoctor(),
    ]);

    if (!mounted) return;

    setState(() {
      _allPatients = results[0];
      _allDoctors = results[1];
      _filteredPatients = List<dynamic>.from(_allPatients);
      _filteredDoctors = List<dynamic>.from(_allDoctors);
      _isLoading = false;
    });
  }

  void _applyLocalFilter() {
    final term = _searchController.text.trim().toLowerCase();

    setState(() {
      if (term.isEmpty) {
        _filteredPatients = List<dynamic>.from(_allPatients);
        _filteredDoctors = List<dynamic>.from(_allDoctors);
        return;
      }

      _filteredPatients = _allPatients.where((item) {
        final name = (item['name'] ?? '').toString().toLowerCase();
        final email = (item['email'] ?? '').toString().toLowerCase();
        return name.contains(term) || email.contains(term);
      }).toList();

      _filteredDoctors = _allDoctors.where((item) {
        final name = (item['name'] ?? '').toString().toLowerCase();
        final email = (item['email'] ?? '').toString().toLowerCase();
        final specialty =
            (item['profileData']?['specialty'] ?? '').toString().toLowerCase();
        return name.contains(term) ||
            email.contains(term) ||
            specialty.contains(term);
      }).toList();
    });
  }

  Widget _sectionTitle(String text, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile({
    required String title,
    required String subtitle,
    required String roleLabel,
    required Color badgeColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: badgeColor.withValues(alpha: 0.18),
            child: Text(
              title.isNotEmpty ? title[0].toUpperCase() : '?',
              style: TextStyle(
                color: badgeColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              roleLabel,
              style: TextStyle(
                color: badgeColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSearchData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search patients and doctors...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  _sectionTitle('Patients', _filteredPatients.length),
                  if (_filteredPatients.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(
                        'No matching patients found.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ..._filteredPatients.map((patient) {
                    final name =
                        (patient['name'] ?? 'Unknown Patient').toString();
                    final email = (patient['email'] ?? 'No email').toString();
                    return _buildUserTile(
                      title: name,
                      subtitle: email,
                      roleLabel: 'PATIENT',
                      badgeColor: const Color(0xFF1976D2),
                    );
                  }),
                  _sectionTitle('Doctors', _filteredDoctors.length),
                  if (_filteredDoctors.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(
                        'No matching doctors found.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ..._filteredDoctors.map((doctor) {
                    final name =
                        (doctor['name'] ?? 'Unknown Doctor').toString();
                    final specialty =
                        (doctor['profileData']?['specialty'] ?? 'No specialty')
                            .toString();
                    return _buildUserTile(
                      title: name,
                      subtitle: specialty,
                      roleLabel: 'DOCTOR',
                      badgeColor: const Color(0xFF2E7D32),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
