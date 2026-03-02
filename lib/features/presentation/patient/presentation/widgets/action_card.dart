import 'package:flutter/material.dart';
import 'package:rehabilitation_app/core/theme/app_colors.dart';

class ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconBg;
  final bool isEmergency;

  const ActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconBg,
    this.isEmergency = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isEmergency ? Colors.white : AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color:
                  isEmergency ? AppColors.red : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}