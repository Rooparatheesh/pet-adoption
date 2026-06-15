import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Palette
  static const Color primary = Color(0xFFFF6F43); // Warm Coral / Deep Orange
  static const Color primaryLight = Color(0xFFFF9E80);
  static const Color secondary = Color(0xFF008080); // Teal accent
  static const Color secondaryLight = Color(0xFFE0F2F1);
  
  static const Color background = Color(0xFFFAF9F6); // Soft Cream/Alabaster
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;
  
  static const Color textPrimary = Color(0xFF2B2B2B); // Soft charcoal
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6F43), Color(0xFFFFB74D)], // Deep Orange to Amber
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient tealGradient = LinearGradient(
    colors: [Color(0xFF008080), Color(0xFF4DB6AC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color danger = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCardBg = Color(0xFF252525);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);
}
