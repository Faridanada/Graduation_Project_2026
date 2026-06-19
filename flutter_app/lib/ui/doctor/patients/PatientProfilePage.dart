import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/ui/exercises/ExoskeletonDegreeSetupPage.dart';
import 'package:rehabilitation_app/ui/chats/ConversationScreen.dart';
import 'package:rehabilitation_app/ui/doctor/patients/CreateRecoveryPlan.dart';
import 'package:rehabilitation_app/ui/app_theme.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
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
    final injuryType = profile['injuryType'] ?? profileData['injuryType'] ?? 'General Patient';

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: AppColors.primary,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
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
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          widget.patientName[0].toUpperCase(),
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.patientName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        injuryType,
                        style: const TextStyle(fontSize: 14, color: Colors.white, fontFamily: 'Poppins'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildInfoSection(profile, profileData),
              ),
              const SizedBox(height: 10),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                tabs: const [
                  Tab(text: 'History'),
                  Tab(text: 'Appointments'),
                  Tab(text: 'Recovery Plans'),
                ],
              ),
            ],
          ),
        ),
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildHistoryTab(),
              _buildAppointmentsTab(),
              _buildRecoveryPlansTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> profile, Map<String, dynamic> profileData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoItem(Icons.cake_outlined, 'Age', '${profile['age'] ?? profileData['age'] ?? 'N/A'}'),
          Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
          _buildInfoItem(Icons.monitor_weight_outlined, 'Weight', '${profile['weight'] ?? profileData['weight'] ?? '-'} kg'),
          Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
          _buildInfoItem(Icons.phone_outlined, 'Phone', '${profile['phone'] ?? 'N/A'}'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Poppins')),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Poppins')),
      ],
    );
  }

  Widget _buildHistoryTab() {
    final exercises = _patientData!['exercises'] as List? ?? [];
    if (exercises.isEmpty) return const Center(child: Text('No exercise history.', style: TextStyle(fontFamily: 'Poppins')));

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final ex = Map<String, dynamic>.from(exercises[index] as Map);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.fitness_center, color: AppColors.primary),
            ),
            title: Text(ex['title'] ?? 'Exercise', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Date: ${ex['dateAssigned'] ?? 'N/A'}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
                Text('Progress: ${ex['repsCompleted'] ?? 0} / ${ex['repsTotal'] ?? 0} reps', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12)),
              ],
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentsTab() {
    final appointments = _patientData!['appointments'] as List? ?? [];
    if (appointments.isEmpty) return const Center(child: Text('No upcoming appointments.', style: TextStyle(fontFamily: 'Poppins')));

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final apt = Map<String, dynamic>.from(appointments[index] as Map);
        final isCompleted = apt['status'] == 'completed';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.calendar_today, color: Colors.orange),
            ),
            title: Text(apt['type'] ?? 'Appointment', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            subtitle: Text('${apt['date']} at ${apt['time']}', style: const TextStyle(fontFamily: 'Poppins')),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (isCompleted ? AppColors.success : AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                apt['status'] ?? 'Pending',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: (isCompleted ? AppColors.success : AppColors.primary), fontFamily: 'Poppins'),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecoveryPlansTab() {
    final plansList = _patientData?['recoveryPlans'] as List?;
    final List<Map<String, dynamic>> plans = [];
    
    // Support the new backend (array) or fallback to old backend (single object)
    if (plansList != null) {
      plans.addAll(List<Map<String, dynamic>>.from(plansList));
    } else if (_patientData?['recoveryPlan'] != null) {
      plans.add(Map<String, dynamic>.from(_patientData!['recoveryPlan']));
    }

    if (plans.isEmpty) {
      return const Center(
        child: Text(
          'No recovery plans assigned.',
          style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        final startDate = plan['startDate'] ?? 'N/A';
        final endDate = plan['endDate'] ?? 'N/A';
        final title = plan['exercisePlan']?['title'] ?? 'Recovery Plan';
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins', color: Colors.black87),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.primary),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateRecoveryPlan(
                                  patientId: widget.patientId,
                                  patientName: widget.patientName,
                                  existingPlan: plan,
                                ),
                              ),
                            ).then((_) => _loadData());
                          },
                          tooltip: 'Edit Plan',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDeleteRecoveryPlan(plan['id']),
                          tooltip: 'Delete Plan',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('$startDate to $endDate', style: const TextStyle(fontSize: 13, color: Colors.grey, fontFamily: 'Poppins')),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Created: ${plan['createdAt'] != null ? plan['createdAt'].toString().substring(0, 10) : 'N/A'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Poppins'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteRecoveryPlan(String planId) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recovery Plan?'),
        content: const Text('Are you sure you want to delete this recovery plan? All future pending exercises will also be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final success = await ApiService.deleteRecoveryPlan(planId);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recovery plan deleted successfully.')),
          );
          _loadData();
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete recovery plan.'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        top: false,
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
                    icon: const Icon(Icons.chat_bubble_outline, size: 20, color: Colors.white),
                    label: const Text('Message', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
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
                    icon: const Icon(Icons.videocam_outlined, size: 20, color: AppColors.primary),
                    label: const Text('Monitor', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: AppColors.primary)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primarySoft,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        existingPlan: null,
                      ),
                    ),
                  ).then((_) => _loadData()); // Refresh after returning
                },
                icon: const Icon(Icons.assignment_add, size: 20, color: Colors.white),
                label: const Text('Create New Recovery Plan', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
