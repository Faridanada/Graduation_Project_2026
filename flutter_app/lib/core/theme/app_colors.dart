import 'package:flutter/material.dart';

/// Shared color constants for the entire app.
/// Use these instead of hardcoding hex values throughout the codebase.
class AppColors {
  AppColors._();

  /// Primary blue used across patient-facing UI (buttons, highlights, icons)
  static const Color primaryBlue = Color(0xFF2196F3);

  /// Softer blue used across doctor-facing UI (cards, app bars, chips)
  static const Color doctorBlue = Color(0xFF95B8D1);

  /// Accent blue used in some exercise / session screens
  static const Color accentBlue = Color(0xFF5798C6);

  /// Light background blue
  static const Color lightBlue = Color(0xFFE3F2FD);

  /// Background light blue gradient start
  static const Color bgLight = Color(0xFFF6F8FC);

  /// Emergency red
  static const Color emergencyRed = Color(0xFFFF6B6B);

  /// Danger red (alerts, critical states)
  static const Color red = Color(0xFFE53935);

  /// Primary text color
  static const Color textPrimary = Color(0xFF1A1A2E);

  /// Secondary text / subtitle color
  static const Color textSecondary = Color(0xFF6B7280);
}