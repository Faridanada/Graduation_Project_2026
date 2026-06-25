import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/ui/exercises/ExoskeletonDegreeSetupPage.dart';
import 'package:rehabilitation_app/ui/chats/ConversationScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rehabilitation_app/ui/doctor/patients/CreateRecoveryPlan.dart';
import 'package:rehabilitation_app/ui/patient/recovery/recovery_plan_screen.dart';
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
    _tabController = TabController(length: 4, vsync: this);
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
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _patientData == null
                ? const Center(child: Text('Failed to load profile', style: TextStyle(fontFamily: 'Poppins')))
                : Column(
                    children: [
                      Expanded(
                        child: _buildContent(),
                      ),
                    ],
                  ),
      ),
    );
  }

  Map<String, dynamic>? _getPendingPhaseData() {
    final plansList = _patientData?['recoveryPlans'] as List?;
    final List<dynamic> plans = [];
    
    if (plansList != null) {
      plans.addAll(plansList);
    } else if (_patientData?['recoveryPlan'] != null) {
      plans.add(_patientData!['recoveryPlan']);
    }

    for (var plan in plans) {
      if (plan is Map) {
        final phases = plan['phases'] as List?;
        if (phases != null) {
          for (var i = 0; i < phases.length; i++) {
            if (phases[i]['status'] == 'Pending Approval') {
              return {
                'planId': plan['id'] ?? plan['_id'],
                'phaseIndex': i,
              };
            }
          }
        }
      }
    }
    return null;
  }

  bool _hasPendingPhase() => _getPendingPhaseData() != null;

  Widget _buildPendingPhaseBanner() {
    final pendingData = _getPendingPhaseData();
    if (pendingData == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(bottom: BorderSide(color: Colors.orange.shade200)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Patient requested approval for the next recovery phase.',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() => _isLoading = true);
              final success = await ApiService.approvePhase(pendingData['planId'], pendingData['phaseIndex']);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phase Approved!')));
                await _loadData();
              } else {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to approve.'), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 0),
              elevation: 0,
            ),
            child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () async {
              setState(() => _isLoading = true);
              final success = await ApiService.declinePhase(pendingData['planId'], pendingData['phaseIndex']);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phase Declined.')));
                await _loadData();
              } else {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to decline.'), backgroundColor: Colors.red));
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 0),
            ),
            child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final profile = Map<String, dynamic>.from(_patientData!['profile'] ?? {});
    final profileData = Map<String, dynamic>.from(profile['profileData'] ?? {});
    final injuryType = profile['injuryType'] ?? profileData['injuryType'] ?? 'General Patient';

    return Column(
      children: [
        // Top Gradient Area + App Bar
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Custom AppBar row
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.person_remove, color: Colors.white),
                      tooltip: 'Remove Patient',
                      onPressed: () => _confirmRemovePatient(),
                    ),
                  ],
                ),
                // Check for pending phase inside the header
                if (_hasPendingPhase()) _buildPendingPhaseBanner(),
                // Avatar
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      widget.patientName.isNotEmpty ? widget.patientName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeaderAction(Icons.chat_bubble_outline, 'Message', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConversationScreen(
                            name: widget.patientName,
                            initials: widget.patientName.isNotEmpty ? widget.patientName[0] : '?',
                            message: "Hello!",
                            receiverId: widget.patientId,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 16),
                    _buildHeaderAction(Icons.call, 'Call Patient', () async {
                      final phone = profile['phone'] ?? profileData['phone'] ?? '';
                      if (phone.toString().trim().isNotEmpty) {
                        final uri = Uri.parse('tel:${phone.toString().trim()}');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cannot launch phone dialer')),
                            );
                          }
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No phone number available for this patient.')),
                          );
                        }
                      }
                    }),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        
        // Info Box
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildInfoSection(profile, profileData),
        ),
        
        // Tabs Spacing
        const SizedBox(height: 10),

        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
          tabs: const [
            Tab(text: 'Recovery Plans'),
            Tab(text: 'Appointments'),
            Tab(text: 'History'),
            Tab(text: 'Information'),
          ],
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRecoveryPlansTab(),
              _buildAppointmentsTab(),
              _buildHistoryTab(),
              _buildInformationTab(profile, profileData),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderAction(IconData icon, String tooltip, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        tooltip: tooltip,
        onPressed: onTap,
      ),
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
          _buildInfoItem(Icons.phone_outlined, 'Phone', '${profile['phone'] ?? profileData['phone'] ?? 'N/A'}'),
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

  Widget _buildInformationTab(Map<String, dynamic> profile, Map<String, dynamic> profileData) {
    final Map<String, dynamic> allInfo = {};
    
    profile.forEach((key, value) {
      if (!['id', '_id', 'profileImage', 'password', 'assignedDoctorId', 'createdAt', 'updatedAt', '__v', 'profileData'].contains(key) && value != null && value.toString().isNotEmpty) {
        allInfo[key] = value;
      }
    });
    
    profileData.forEach((key, value) {
      if (!['id', '_id'].contains(key) && value != null && value.toString().isNotEmpty) {
        allInfo[key] = value;
      }
    });

    if (allInfo.isEmpty) {
      return const Center(child: Text('No information available.', style: TextStyle(fontFamily: 'Poppins')));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: allInfo.length,
      itemBuilder: (context, index) {
        final key = allInfo.keys.elementAt(index);
        final value = allInfo[key];
        
        // Format key (e.g. injuryType -> Injury Type)
        String formattedKey = key.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}');
        formattedKey = formattedKey[0].toUpperCase() + formattedKey.substring(1);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  formattedKey,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontFamily: 'Poppins'),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontFamily: 'Poppins'),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      },
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No recovery plans assigned.',
              style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 16),
            _buildCreatePlanButton(false),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: plans.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildCreatePlanButton(true),
          );
        }
        final plan = plans[index - 1];
        final startDate = plan['startDate'] ?? 'N/A';
        final endDate = plan['endDate'] ?? 'N/A';
        final title = plan['exercisePlan']?['title'] ?? 'Recovery Plan';
        
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecoveryPlanScreen(
                  isDoctorView: true,
                  initialPlanData: plan,
                  initialPatientProfile: _patientData!['profile'],
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
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

  Widget _buildCreatePlanButton(bool isDisabled) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isDisabled ? null : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateRecoveryPlan(
                patientId: widget.patientId,
                patientName: widget.patientName,
                existingPlan: null,
              ),
            ),
          ).then((_) => _loadData());
        },
        icon: Icon(Icons.add, size: 20, color: isDisabled ? Colors.grey[400] : Colors.white),
        label: Text(
          isDisabled ? 'Recovery Plan Already Exists' : 'Create New Recovery Plan', 
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: isDisabled ? Colors.grey[400] : Colors.white)
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? Colors.grey[200] : AppColors.primary,
          disabledBackgroundColor: Colors.grey[200],
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

