import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/ui/exercises/ExoskeletonDegreeSetupPage.dart';
import 'package:rehabilitation_app/ui/chats/ConversationScreen.dart';
import 'package:rehabilitation_app/ui/doctor/patients/CreateRecoveryPlan.dart';

class PatientProfilePage extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PatientProfilePage({
    Key? key,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _patientData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.patientId.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getPatientDetails(widget.patientId);
      if (mounted) {
        setState(() {
          _patientData = data == null ? null : Map<String, dynamic>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading patient details: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _patientData = null;
        });
      }
    }
  }

  Future<void> _confirmRemovePatient() async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Patient?'),
        content: Text('Are you sure you want to remove ${widget.patientName} from your active patients list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final success = await ApiService.removePatient(widget.patientId);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient removed successfully.')),
          );
          if (Navigator.canPop(context)) Navigator.pop(context, true);
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to remove patient.'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _patientData == null
              ? const Center(child: Text('Failed to load patient data'))
              : _buildContent(),
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  Widget _buildContent() {
    final profile = Map<String, dynamic>.from(_patientData!['profile'] ?? {});
    final profileData = Map<String, dynamic>.from(profile['profileData'] ?? {});

    final injuryType =
        profile['injuryType'] ?? profileData['injuryType'] ?? 'General Patient';

    return CustomScrollView(
      slivers: [
        // Premium Header
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          backgroundColor: const Color(0xFF6BA5CF),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_remove),
              color: Colors.white,
              tooltip: 'Remove Patient',
              onPressed: () => _confirmRemovePatient(),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6BA5CF), Color(0xFF9B8FD9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      widget.patientName[0].toUpperCase(),
                      style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.patientName,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    injuryType,
                    style: TextStyle(
                        fontSize: 16, color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Info Grid
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(profile, profileData),
                const SizedBox(height: 20),
                // Tabs Header
                TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF6BA5CF),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFF6BA5CF),
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'History'),
                    Tab(text: 'Appointments'),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Tabs Content
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildHistoryTab(),
              _buildAppointmentsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(
      Map<String, dynamic> profile, Map<String, dynamic> profileData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
              'Age', '${profile['age'] ?? profileData['age'] ?? 'N/A'}'),
          _buildInfoItem('Weight',
              '${profile['weight'] ?? profileData['weight'] ?? '-'} kg'),
          _buildInfoItem(
              'Phone', '${profile['phone'] ?? profileData['phone'] ?? 'N/A'}'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildHistoryTab() {
    final exercises = _patientData!['exercises'] as List? ?? [];
    if (exercises.isEmpty)
      return const Center(child: Text('No exercise history.'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final ex = Map<String, dynamic>.from(exercises[index] as Map);
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.grey[50],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.fitness_center, color: Color(0xFF6BA5CF)),
            title: Text(ex['title'] ?? 'Exercise'),
            subtitle: Text('Progress: ${ex['progress'] ?? 0}%'),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentsTab() {
    final appointments = _patientData!['appointments'] as List? ?? [];
    if (appointments.isEmpty)
      return const Center(child: Text('No upcoming appointments.'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final apt = Map<String, dynamic>.from(appointments[index] as Map);
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.grey[50],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.orange),
            title: Text(apt['type'] ?? 'Appointment'),
            subtitle: Text('${apt['date']} at ${apt['time']}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    (apt['status'] == 'completed' ? Colors.green : Colors.blue)
                        .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                apt['status'] ?? 'Pending',
                style: TextStyle(
                    fontSize: 10,
                    color: (apt['status'] == 'completed'
                        ? Colors.green
                        : Colors.blue)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConversationScreen(
                          name: widget.patientName,
                          initials: widget.patientName[0],
                          message: "Hello!",
                          receiverId: widget.patientId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6BA5CF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExoskeletonDegreeSetupPage(
                          patientName: widget.patientName,
                          exerciseTitle: 'Session Monitoring',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.videocam_outlined),
                  label: const Text('Monitor'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF6BA5CF)),
                    foregroundColor: const Color(0xFF6BA5CF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateRecoveryPlan(
                      patientId: widget.patientId,
                      patientName: widget.patientName,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.assignment_add),
              label: const Text('Create Recovery Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34D399),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
