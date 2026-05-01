import 'package:flutter/material.dart';

/// MacroKitchen Design System Colors
/// Extracted from Figma mockups: teal/cyan primary, white backgrounds
class AppColors {
  AppColors._();

  // --- Primary Palette ---
  static const Color primary = Color(0xFF4DC8C8);      // Teal/Cyan from mockups
  static const Color primaryDark = Color(0xFF2DA8A8);
  static const Color primaryLight = Color(0xFF7EDDDD);
  static const Color primaryContainer = Color(0xFFE0F7F7);

  // --- Secondary ---
  static const Color secondary = Color(0xFF2C3E50);
  static const Color secondaryLight = Color(0xFF546E7A);

  // --- Backgrounds ---
  static const Color background = Color(0xFFF8FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F4);

  // --- Text ---
  static const Color textPrimary = Color(0xFF1A2332);
  static const Color textSecondary = Color(0xFF637381);
  static const Color textHint = Color(0xFFB0BEC5);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // --- Macro Colors (from calorie ring in mockup) ---
  static const Color calories = Color(0xFFE53935);    // Red
  static const Color carbs = Color(0xFFFB8C00);       // Orange
  static const Color protein = Color(0xFF43A047);     // Green
  static const Color fats = Color(0xFFFFCA28);        // Yellow

  // --- Status ---
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // --- Borders & Dividers ---
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFF0F0F0);

  // --- Input Fields (from mockup: light blue-tinted) ---
  static const Color inputFill = Color(0xFFEDF7F7);
  static const Color inputBorder = Color(0xFF4DC8C8);
  static const Color inputBorderUnfocused = Color(0xFFCFE8E8);

  // --- Rating ---
  static const Color rating = Color(0xFFFFC107);

  // --- Allergy Warning ---
  static const Color allergyWarning = Color(0xFFFF7043);
  static const Color allergyWarningLight = Color(0xFFFFF3E0);

  // --- Chart Colors ---
  static const Color chartRed = Color(0xFFE53935);
  static const Color chartGreen = Color(0xFF43A047);
  static const Color chartBlue = Color(0xFF1E88E5);
  static const Color chartBackground = Color(0xFFF5F5F5);
}
