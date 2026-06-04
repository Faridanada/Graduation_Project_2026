import 'package:flutter/material.dart';
import 'package:rehabilitation_app/services/api_service.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({Key? key}) : super(key: key);

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  List<dynamic> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    try {
      final data = await ApiService.getNotifications();
      if (mounted) {
        setState(() {
          // In a real app, we'd have a specific alerts endpoint or flag.
          // For now, we'll treat notifications with "Recovery", "Alert", or "Critical" in the title/message as alerts.
          _alerts = data.where((n) {
            final title = n['title']?.toString() ?? '';
            final message = n['message']?.toString() ?? '';
            final text = (title + message).toLowerCase();
            return text.contains('alert') || text.contains('critical') || text.contains('recovery') || text.contains('wound');
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final criticalCount = _alerts.where((a) => (a['title'] + a['message']).toLowerCase().contains('critical')).length;
    final highCount = _alerts.where((a) => (a['title'] + a['message']).toLowerCase().contains('recovery')).length;
    final otherCount = _alerts.length - criticalCount - highCount;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF95B8D1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () { if (Navigator.canPop(context)) Navigator.pop(context); },
        ),
        title: const Text(
          'Alerts',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Alerts: ${_alerts.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildRiskSummary('Critical', criticalCount, Colors.red),
                            const SizedBox(width: 12),
                            _buildRiskSummary('High', highCount, Colors.orange),
                            const SizedBox(width: 12),
                            _buildRiskSummary('Moderate', otherCount, Colors.amber),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _alerts.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _alerts.length,
                            itemBuilder: (context, index) {
                              return _buildAlertCard(_alerts[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.green[200]),
          const SizedBox(height: 16),
          const Text(
            'System Stable',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          const Text('No critical patient alerts at this time.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRiskSummary(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final String title = alert['title'] ?? '';
    final String message = alert['message'] ?? '';
    final bool isCritical = (title + message).toLowerCase().contains('critical');
    final Color riskColor = isCritical ? Colors.red : Colors.orange;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: riskColor.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isCritical ? Icons.priority_high : Icons.warning_amber_rounded, color: riskColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  _formatDate(alert['createdAt']),
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Mark as read and refresh
                  ApiService.markNotificationRead(alert['id']).then((_) => _fetchAlerts());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: riskColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Acknowledge'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return "${date.hour}:${date.minute.toString().padLeft(2, '0')} · ${date.day}/${date.month}";
    } catch (_) {
      return '';
    }
  }
}


