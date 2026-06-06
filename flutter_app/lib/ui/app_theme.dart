import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF4A90E2);
  static const Color primaryLight = Color(0xFFB3D9E8);
  static const Color primarySoft = Color(0xFFD4E8F0);
  static const Color accent = Color(0xFF6BA5CF);
  static const Color background = Color(0xFFF9FBFF);
  static const Color surface = Colors.white;
  static const Color success = Color(0xFF2E7D32);
}

class AppTextStyles {
  static TextStyle heading(BuildContext c) => GoogleFonts.poppins(
      textStyle: const TextStyle(
          fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black));

  static TextStyle section(BuildContext c) => GoogleFonts.poppins(
      textStyle: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black));

  static TextStyle body(BuildContext c) => GoogleFonts.poppins(
      textStyle: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black));

  static TextStyle caption(BuildContext c) => GoogleFonts.poppins(
      textStyle: const TextStyle(fontSize: 12, color: Colors.grey));
}

class AppSpacing {
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
}

class AppRadius {
  static const double small = 4.0;
  static const double medium = 12.0;
  static const double large = 20.0;
  static const double card = 16.0;
}

class AppTheme {
  static ThemeData lightTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        margin: const EdgeInsets.all(AppSpacing.m),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary),
    );
  }
}
