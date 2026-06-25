import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/ui/doctor/patients/PatientProfilePage.dart';
import 'package:rehabilitation_app/ui/app_theme.dart';

class ActivePatientsPage extends StatefulWidget {
  const ActivePatientsPage({Key? key}) : super(key: key);

  @override
  State<ActivePatientsPage> createState() => _ActivePatientsPageState();
}

class _ActivePatientsPageState extends State<ActivePatientsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All'; 
  bool _sortNewestFirst = true;
  
  List<Map<String, dynamic>> _patients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => isLoading = true);
    try {
      final fetched = await ApiService.getDoctorPatients();
      if (mounted) {
        setState(() {
          _patients = fetched
              .map((p) => {
                    'id': (p['id'] ?? p['_id'] ?? '').toString(),
                    'name': (p['name'] ?? 'Unknown').toString(),
                    'age': p['age'] ?? p['profileData']?['age']?.toString() ?? 'N/A',
                    'phone': p['phone'] ?? p['profileData']?['phone'] ?? 'N/A',
                    'injuryType': p['injuryType'] ?? p['profileData']?['injuryType'] ?? 'Unknown',
                    'progress': p['progress'] ?? 0,
                    'status': (p['pendingPhaseApproval'] == true)
                        ? 'Action Needed'
                        : (p['hasPlan'] == true) 
                            ? 'On Track'
                            : 'New',
                    'statusColor': (p['pendingPhaseApproval'] == true)
                        ? Colors.orange
                        : (p['hasPlan'] == true)
                            ? Colors.teal
                            : Colors.blue,
                    'createdAt': p['createdAt'] ?? '',
                  })
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredAndSortedPatients {
    final query = _searchController.text.trim().toLowerCase();

    var filtered = _patients.where((patient) {
      final name = (patient['name'] as String).toLowerCase();
      final age = patient['age'].toString();
      final status = patient['status'] as String;
      
      final matchesSearch = query.isEmpty || name.contains(query) || age.contains(query);
      final matchesFilter = _selectedFilter == 'All' || status == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();

    // Sort by date (createdAt)
    filtered.sort((a, b) {
      final dateA = a['createdAt'] as String;
      final dateB = b['createdAt'] as String;
      if (_sortNewestFirst) {
        return dateB.compareTo(dateA); // Descending
      } else {
        return dateA.compareTo(dateB); // Ascending
      }
    });

    return filtered;
  }

  Widget _buildSortButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _sortNewestFirst = !_sortNewestFirst;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _sortNewestFirst ? Icons.arrow_downward : Icons.arrow_upward,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'Date',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = label;
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.18),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isSelected ? AppColors.primary : Colors.black87,
      ),
      side: BorderSide(
        color: isSelected
            ? AppColors.primary.withOpacity(0.45)
            : Colors.grey.shade300,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patients = _filteredAndSortedPatients;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Active Patients',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search patient by name or age',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Action Needed'),
                const SizedBox(width: 8),
                _buildFilterChip('New'),
                const SizedBox(width: 8),
                _buildFilterChip('On Track'),
                const SizedBox(width: 16),
                _buildSortButton(),
              ],
            ),
          ),
        ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : patients.isEmpty
                    ? const Center(
                        child: Text(
                          'No patients found',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.76,
                        ),
                        itemCount: patients.length,
                        itemBuilder: (context, index) {
                          return _ActivePatientCard(
                            patient: patients[index],
                            onReturn: _loadPatients,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _ActivePatientCard extends StatelessWidget {
  const _ActivePatientCard({required this.patient, required this.onReturn});

  final Map<String, dynamic> patient;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientProfilePage(
              patientId: patient['id'],
              patientName: patient['name'],
            ),
          ),
        ).then((_) => onReturn());
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      const Color.fromRGBO(128, 155, 206, 1).withOpacity(0.6),
                  child: Text(
                    (patient['name'] as String).isNotEmpty ? (patient['name'] as String).substring(0, 1).toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color:
                        const Color.fromRGBO(184, 224, 210, 1).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    patient['status'] == 'Needs Attention' ? Icons.warning_amber_rounded : Icons.check_circle,
                    size: 16,
                    color: patient['statusColor'] as Color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              patient['name'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Text(
              'Age ${patient['age']}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${patient['progress']}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (double.tryParse(patient['progress'].toString()) ?? 0) /
                    100,
                minHeight: 6,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  patient['statusColor'] as Color,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 14,
                  color: patient['statusColor'] as Color,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    patient['status'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: patient['statusColor'] as Color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
