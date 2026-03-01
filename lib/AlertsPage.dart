import 'package:flutter/material.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({Key? key}) : super(key: key);

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  final List<Map<String, dynamic>> highRiskAlerts = [
    {
      'name': 'Jack Doe',
      'age': '43',
      'phone': '555-0103',
      'injuryType': 'Back Strain',
      'riskLevel': 'Critical',
      'alertMessage':
          'No progress in last 2 weeks. Requires immediate intervention.',
      'timestamp': '2 hours ago',
    },
    {
      'name': 'Michael Brown',
      'age': '35',
      'phone': '555-0106',
      'injuryType': 'Hip Replacement',
      'riskLevel': 'High',
      'alertMessage': 'Abnormal pain levels detected during last session.',
      'timestamp': '4 hours ago',
    },
    {
      'name': 'Sarah Wilson',
      'age': '42',
      'phone': '555-0107',
      'injuryType': 'Knee Ligament Tear',
      'riskLevel': 'High',
      'alertMessage': 'Patient missed scheduled appointment.',
      'timestamp': '6 hours ago',
    },
    {
      'name': 'James White',
      'age': '45',
      'phone': '555-0112',
      'injuryType': 'Spinal Cord Injury',
      'riskLevel': 'Critical',
      'alertMessage': 'Decreased range of motion detected. Follow-up required.',
      'timestamp': '8 hours ago',
    },
    {
      'name': 'Daniel Miller',
      'age': '44',
      'phone': '555-0116',
      'injuryType': 'Hip Strain',
      'riskLevel': 'Moderate',
      'alertMessage': 'Medication compliance needs review.',
      'timestamp': '12 hours ago',
    },
    {
      'name': 'Ethan Walker',
      'age': '40',
      'phone': '555-0124',
      'injuryType': 'Lumbar Strain',
      'riskLevel': 'High',
      'alertMessage': 'Patient reported increased pain at night.',
      'timestamp': '1 day ago',
    },
    {
      'name': 'Nathan Garcia',
      'age': '41',
      'phone': '555-0120',
      'injuryType': 'Back Disc Herniation',
      'riskLevel': 'Critical',
      'alertMessage':
          'Severe pain episode. Patient needs immediate consultation.',
      'timestamp': '1 day ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF95B8D1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Alerts: ${highRiskAlerts.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildRiskSummary(
                          'Critical',
                          highRiskAlerts
                              .where((a) => a['riskLevel'] == 'Critical')
                              .length,
                          Colors.red),
                      const SizedBox(width: 12),
                      _buildRiskSummary(
                          'High',
                          highRiskAlerts
                              .where((a) => a['riskLevel'] == 'High')
                              .length,
                          Colors.orange),
                      const SizedBox(width: 12),
                      _buildRiskSummary(
                          'Moderate',
                          highRiskAlerts
                              .where((a) => a['riskLevel'] == 'Moderate')
                              .length,
                          Colors.yellow),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: highRiskAlerts.length,
                itemBuilder: (context, index) {
                  return _buildAlertCard(highRiskAlerts[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskSummary(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    Color riskColor = _getRiskColor(alert['riskLevel']);
    IconData riskIcon = _getRiskIcon(alert['riskLevel']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: riskColor.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
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
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFF95B8D1).withOpacity(0.6),
                  child: Text(
                    alert['name'].substring(0, 1),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Age: ${alert['age']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(riskIcon, size: 14, color: riskColor),
                      const SizedBox(width: 4),
                      Text(
                        alert['riskLevel'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: riskColor,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: riskColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_outlined, size: 16, color: riskColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          alert['alertMessage'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        alert['timestamp'],
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    'Phone:',
                    alert['phone'],
                    Icons.phone,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Injury Type:',
                    alert['injuryType'],
                    Icons.medical_services,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Patient ${alert['name']} marked for follow-up'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: riskColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Take Action',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF95B8D1)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'Critical':
        return Colors.red;
      case 'High':
        return Colors.orange;
      case 'Moderate':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _getRiskIcon(String riskLevel) {
    switch (riskLevel) {
      case 'Critical':
        return Icons.priority_high;
      case 'High':
        return Icons.warning;
      case 'Moderate':
        return Icons.info;
      default:
        return Icons.help;
    }
  }
}
