import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/api_service.dart';
import 'package:rehabilitation_app/models/session_report.dart';
import 'package:rehabilitation_app/ui/shared/report_widgets.dart';

class SessionReportDetailScreen extends StatefulWidget {
  final String sessionId;

  const SessionReportDetailScreen({Key? key, required this.sessionId}) : super(key: key);

  @override
  State<SessionReportDetailScreen> createState() => _SessionReportDetailScreenState();
}

class _SessionReportDetailScreenState extends State<SessionReportDetailScreen> {
  bool _isLoading = true;
  SessionReportEnvelope? _envelope;
  Timer? _pollTimer;
  int _pollTicks = 0;
  bool _isRegenerating = false;

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchReport() async {
    try {
      final env = await ApiService.getSessionReport(widget.sessionId);
      if (mounted) {
        setState(() {
          _envelope = env;
          _isLoading = false;
        });

        if (env.reportStatus == 'processing' || env.reportStatus == 'pending') {
          _startPolling();
        } else {
          _pollTimer?.cancel();
          setState(() => _isRegenerating = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load report')));
      }
    }
  }

  void _startPolling() {
    if (_pollTimer != null && _pollTimer!.isActive) return;
    _pollTicks = 0;
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _pollTicks++;
      if (_pollTicks >= 40) { // 2 minutes
        timer.cancel();
        if (mounted) {
          setState(() => _isRegenerating = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Taking longer than usual.')));
        }
      } else {
        _fetchReport();
      }
    });
  }

  void _regenerateReport() async {
    setState(() {
      _isRegenerating = true;
      if (_envelope != null) _envelope!.reportStatus = 'processing';
    });

    try {
      await ApiService.regenerateReport(widget.sessionId);
      _startPolling();
    } catch (e) {
      setState(() => _isRegenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to trigger regeneration')));
    }
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _envelope == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Session Report"), iconTheme: const IconThemeData(color: Colors.black), backgroundColor: Colors.white),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final env = _envelope;
    if (env == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Session Report"), iconTheme: const IconThemeData(color: Colors.black), backgroundColor: Colors.white),
        body: const Center(child: Text("Report not found")),
      );
    }

    final isProcessing = env.reportStatus == 'processing' || env.reportStatus == 'pending' || _isRegenerating;
    final report = env.report;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Session Report", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
        actions: [
          if (env.reportGeneratedAt != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  _formatDate(env.reportGeneratedAt!),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ),
            ),
        ],
      ),
      body: isProcessing
          ? _buildProcessingState()
          : env.reportStatus == 'failed'
              ? _buildErrorState(env.reportError)
              : _buildReportContent(report!),
      bottomNavigationBar: _buildFooterActions(isProcessing),
    );
  }

  Widget _buildProcessingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("AI is analyzing this session...", style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text("Report Failed", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 8),
            Text(error ?? "An unknown error occurred during generation.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent(SessionReport report) {
    // Derive risk for this specific session
    String sessionRisk = 'low';
    if (report.concerns.any((c) => c.severity == 'high')) {
      sessionRisk = 'high';
    } else if (report.concerns.any((c) => c.severity == 'medium')) {
      sessionRisk = 'medium';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Metadata strip
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Duration: ${(report.metrics.duration.value / 60).round()} min", style: const TextStyle(fontWeight: FontWeight.w600)),
                const Text("•", style: TextStyle(color: Colors.grey)),
                Text("Reps: ${report.metrics.repetitionsCompleted}", style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Align(alignment: Alignment.centerLeft, child: RiskBadge(severity: sessionRisk)),
          const SizedBox(height: 24),

          // Summary
          const Text("Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Text(report.summary, style: const TextStyle(fontSize: 14, height: 1.5)),
          ),
          const SizedBox(height: 24),

          // Key Metrics
          const Text("Key Metrics", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: [
              MetricCard(label: "Duration", value: "${(report.metrics.duration.value / 60).round()} min"),
              MetricCard(label: "Repetitions", value: "${report.metrics.repetitionsCompleted}"),
              MetricCard(
                label: "ROM (IMU 1)",
                value: "${report.metrics.rangeOfMotion.imu1.min.round()}° → ${report.metrics.rangeOfMotion.imu1.max.round()}°",
                subtitle: "avg ${report.metrics.rangeOfMotion.imu1.average.round()}°",
              ),
              MetricCard(
                label: "ROM (IMU 2)",
                value: "${report.metrics.rangeOfMotion.imu2.min.round()}° → ${report.metrics.rangeOfMotion.imu2.max.round()}°",
                subtitle: "avg ${report.metrics.rangeOfMotion.imu2.average.round()}°",
              ),
              MetricCard(
                label: "Peak EMG 1",
                value: "Peak ${report.metrics.peakEmg.emg1.peak.toStringAsFixed(2)}",
                subtitle: "RMS ${report.metrics.peakEmg.emg1.rms.toStringAsFixed(2)}",
              ),
              MetricCard(
                label: "Peak EMG 2",
                value: "Peak ${report.metrics.peakEmg.emg2.peak.toStringAsFixed(2)}",
                subtitle: "RMS ${report.metrics.peakEmg.emg2.rms.toStringAsFixed(2)}",
              ),
              MetricCard(
                label: "Symmetry",
                value: "${(report.metrics.muscleSymmetry.score * 100).round()}%",
                subtitle: report.metrics.muscleSymmetry.interpretation,
              ),
              MetricCard(
                label: "Fatigue",
                value: report.metrics.fatigueIndex.interpretation.toUpperCase(),
                subtitle: "1: ${report.metrics.fatigueIndex.emg1} / 2: ${report.metrics.fatigueIndex.emg2}",
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Observations
          const Text("Observations", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: report.observations.map((obs) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• ", style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold, fontSize: 16)),
                    Expanded(child: Text(obs, style: const TextStyle(fontSize: 14, height: 1.4))),
                  ],
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Concerns
          if (report.concerns.isNotEmpty) ...[
            const Text("Concerns", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...report.concerns.map((c) => ConcernCard(concern: c)).toList(),
            const SizedBox(height: 24),
          ],

          // Recommendations
          const Text("Recommendations", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: report.recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                    Expanded(child: Text(rec, style: const TextStyle(fontSize: 14, height: 1.4))),
                  ],
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Safety Events
          if (report.safetyEvents.isNotEmpty) ...[
            const Text("Safety Events", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: report.safetyEvents.map((e) => SafetyEventRow(event: e)).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Attribution
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Generated by ${report.model} on ${_formatDate(report.generatedAt ?? DateTime.now())}",
                style: TextStyle(color: Colors.grey[400], fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterActions(bool isProcessing) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isProcessing ? null : _regenerateReport,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text("Regenerate"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: isProcessing ? null : () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report sent to patient')));
                  },
                  child: const Text("Send to Patient"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: null,
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
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
