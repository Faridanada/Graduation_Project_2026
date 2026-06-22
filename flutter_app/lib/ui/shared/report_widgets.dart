import 'package:flutter/material.dart';
import 'package:rehabilitation_app/models/session_report.dart';

class RiskBadge extends StatelessWidget {
  final String severity;
  final String? customText;

  const RiskBadge({Key? key, required this.severity, this.customText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String text = customText ?? severity.toUpperCase();

    switch (severity.toLowerCase()) {
      case 'high':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        text = customText ?? 'High Risk';
        break;
      case 'medium':
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        text = customText ?? 'Medium Risk';
        break;
      case 'low':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        text = customText ?? 'Low Risk';
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        text = customText ?? 'No Risk Data';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;

  const MetricCard({
    Key? key,
    required this.label,
    required this.value,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ConcernCard extends StatelessWidget {
  final Concern concern;

  const ConcernCard({Key? key, required this.concern}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color stripeColor;
    switch (concern.severity.toLowerCase()) {
      case 'high':
        stripeColor = const Color(0xFFC62828);
        break;
      case 'medium':
        stripeColor = const Color(0xFFE65100);
        break;
      case 'low':
      default:
        stripeColor = const Color(0xFF2E7D32);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: stripeColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      concern.type,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      concern.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SafetyEventRow extends StatelessWidget {
  final SafetyEvent event;

  const SafetyEventRow({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData iconData = Icons.info_outline;
    Color iconColor = Colors.grey;

    if (event.type == 'verbal_stop') {
      iconData = Icons.mic;
      iconColor = Colors.red;
    } else if (event.type == 'abnormal_motion') {
      iconData = Icons.warning_amber_rounded;
      iconColor = Colors.orange;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'at minute ${(event.atSecond / 60).floor()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.context,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PatientHighlightCard extends StatelessWidget {
  final String text;

  const PatientHighlightCard({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

String deriveRiskLevel(List<SessionReportEnvelope> recent) {
  bool hasHigh = recent.any((s) => s.report?.concerns.any((c) => c.severity == 'high') ?? false);
  bool hasMedium = recent.any((s) => s.report?.concerns.any((c) => c.severity == 'medium') ?? false);
  if (hasHigh) return 'high';
  if (hasMedium) return 'medium';
  if (recent.any((s) => s.reportStatus == 'completed')) return 'low';
  return 'none';
}
