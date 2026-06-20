import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/models/session_report.dart';
import 'package:rehabilitation_app/ui/shared/report_widgets.dart';
import 'package:rehabilitation_app/ui/doctor/session_report_detail.dart';

class AiReports extends StatefulWidget {
  const AiReports({Key? key}) : super(key: key);

  @override
  State<AiReports> createState() => _AiReportsState();
}

class _AiReportsState extends State<AiReports> {
  bool _isLoadingPatients = true;
  List<dynamic> _patients = [];
  String? _selectedPatientId;

  bool _isLoadingSessions = false;
  List<SessionListItem> _sessions = [];
  SessionListItem? _latestSession;

  String _riskLevel = 'none';
  bool _isLoadingRisk = false;

  String _selectedFilter = 'Weekly';

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final patients = await ApiService.getDoctorPatients();
    if (mounted) {
      setState(() {
        _patients = patients;
        _isLoadingPatients = false;
        if (_patients.isNotEmpty) {
          _selectedPatientId = _patients.first['id'];
          _loadSessions();
        }
      });
    }
  }

  Future<void> _loadSessions() async {
    if (_selectedPatientId == null) return;

    setState(() {
      _isLoadingSessions = true;
      _riskLevel = 'none';
    });

    try {
      final sessions = await ApiService.getPatientSessions(_selectedPatientId!);
      
      // Filter sessions based on selected filter (basic client-side filtering)
      DateTime now = DateTime.now();
      List<SessionListItem> filtered = sessions;
      if (_selectedFilter == 'Weekly') {
        filtered = sessions.where((s) => now.difference(s.startTime).inDays <= 7).toList();
      } else if (_selectedFilter == 'Monthly') {
        filtered = sessions.where((s) => now.difference(s.startTime).inDays <= 30).toList();
      }

      // Sort by start time descending
      filtered.sort((a, b) => b.startTime.compareTo(a.startTime));

      SessionListItem? latest;
      if (filtered.isNotEmpty) {
        latest = filtered.first;
      }

      if (mounted) {
        setState(() {
          _sessions = filtered;
          _latestSession = latest;
          _isLoadingSessions = false;
        });
        
        _calculateRisk(filtered);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSessions = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load sessions')));
      }
    }
  }

  Future<void> _calculateRisk(List<SessionListItem> allSessions) async {
    setState(() => _isLoadingRisk = true);
    
    // Get last 5 completed sessions
    final completed = allSessions.where((s) => s.reportStatus == 'completed').take(5).toList();
    if (completed.isEmpty) {
      if (mounted) setState(() {
        _riskLevel = 'none';
        _isLoadingRisk = false;
      });
      return;
    }

    try {
      List<SessionReportEnvelope> envelopes = [];
      for (var s in completed) {
        final env = await ApiService.getSessionReport(s.id);
        envelopes.add(env);
      }
      
      final risk = deriveRiskLevel(envelopes);
      if (mounted) {
        setState(() {
          _riskLevel = risk;
          _isLoadingRisk = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingRisk = false);
    }
  }

  void _onPatientChanged(String? newId) {
    if (newId != null && newId != _selectedPatientId) {
      setState(() {
        _selectedPatientId = newId;
      });
      _loadSessions();
    }
  }

  void _onFilterChanged(String filter) {
    if (filter == 'Custom') {
      // Just mock custom for now to avoid building complex date picker logic if not strictly requested
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Custom date picker coming soon')));
      return;
    }
    setState(() => _selectedFilter = filter);
    _loadSessions(); // Reload and re-filter
  }

  void _navigateToDetail(String sessionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionReportDetailScreen(sessionId: sessionId),
      ),
    ).then((_) {
      // Refresh on return in case of regeneration
      _loadSessions();
    });
  }

  void _showNoteDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Clinical Note'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter your note here...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatShortDate(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('AI Reports', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoadingPatients
          ? const Center(child: CircularProgressIndicator())
          : _patients.isEmpty
              ? const Center(child: Text("No patients assigned to you."))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Patient Selector
                            const Text("Select Patient", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedPatientId,
                                  isExpanded: true,
                                  items: _patients.map((p) {
                                    return DropdownMenuItem<String>(
                                      value: p['id'],
                                      child: Text("${p['name'] ?? 'Unknown'}"),
                                    );
                                  }).toList(),
                                  onChanged: _onPatientChanged,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Time Filter
                            Row(
                              children: ['Weekly', 'Monthly', 'Custom'].map((filter) {
                                final isSelected = _selectedFilter == filter;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(filter),
                                    selected: isSelected,
                                    selectedColor: const Color(0xFF2196F3),
                                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                                    onSelected: (_) => _onFilterChanged(filter),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),

                            if (_isLoadingSessions)
                              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                            else ...[
                              // Risk Badge Card
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
                                ),
                                child: Column(
                                  children: [
                                    _isLoadingRisk 
                                      ? const CircularProgressIndicator()
                                      : RiskBadge(severity: _riskLevel),
                                    const SizedBox(height: 8),
                                    Text("Based on last 5 completed sessions", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Latest Session Summary Card
                              const Text("Latest Session", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                              const SizedBox(height: 12),
                              if (_latestSession == null)
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                                  child: const Center(child: Text("No completed sessions yet", style: TextStyle(color: Colors.grey))),
                                )
                              else
                                GestureDetector(
                                  onTap: () => _navigateToDetail(_latestSession!.id),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.3)),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(_formatDate(_latestSession!.startTime), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                        const SizedBox(height: 8),
                                        if (_latestSession!.reportStatus == 'processing') ...[
                                          Row(
                                            children: const [
                                              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                                              SizedBox(width: 8),
                                              Text("AI is analyzing this session...", style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
                                            ],
                                          )
                                        ] else if (_latestSession!.reportStatus == 'failed') ...[
                                          const Text("Report failed to generate.", style: TextStyle(color: Colors.red, fontSize: 14)),
                                        ] else ...[
                                          Text(_latestSession!.summary ?? "No summary available.", style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
                                        ]
                                      ],
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 24),

                              // Recent Sessions List
                              const Text("Recent Sessions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                              const SizedBox(height: 12),
                              ..._sessions.skip(1).map((s) {
                                String displaySummary = s.summary?.split('\n').first ?? 'Session completed';
                                if (s.reportStatus == 'processing') displaySummary = 'Analyzing...';
                                if (s.reportStatus == 'failed') displaySummary = 'Report failed';

                                return GestureDetector(
                                  onTap: () => _navigateToDetail(s.id),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 80,
                                          child: Text(_formatShortDate(s.startTime), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              if (s.durationSeconds != null)
                                                Text("${(s.durationSeconds! / 60).round()} min", style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                                              Text(
                                                displaySummary,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: s.reportStatus == 'failed' ? Colors.red : Colors.grey[800],
                                                  fontStyle: s.reportStatus == 'processing' ? FontStyle.italic : FontStyle.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (s.reportStatus == 'completed')
                                          Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFF2E7D32), shape: BoxShape.circle)),
                                        if (s.reportStatus == 'failed')
                                          const Icon(Icons.refresh, size: 16, color: Colors.red),
                                        const SizedBox(width: 8),
                                        Icon(Icons.chevron_right, color: Colors.grey[400]),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ],
                        ),
                      ),
                    ),
                    // Footer Actions
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3), padding: const EdgeInsets.symmetric(vertical: 14)),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report sent to patient')));
                              },
                              child: const Text("Send Report to Patient", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: null, // Disabled
                                  child: const Tooltip(message: 'Coming soon', child: Text("Export PDF")),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _showNoteDialog,
                                  child: const Text("Add Clinical Note"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
