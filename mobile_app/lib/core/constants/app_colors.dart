import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF047857); // Modern Emerald Green
  static const Color primaryDark = Color(0xFF0F291E); // Forest Dark
  static const Color secondary = Color(0xFF0284C7); // Sky Blue
  static const Color accent = Color(0xFFF59E0B); // Amber
  static const Color danger = Color(0xFFDC2626); // Red
  static const Color success = Color(0xFF16A34A); // Green
  static const Color background = Color(0xFFF8FAFC); // Soft Slate Background
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF1E293B); // Dark Slate
  static const Color textLight = Color(0xFF64748B); // Muted Slate
  static const Color border = Color(0xFFE2E8F0); // Border Gray
  static const Color divider = Color(0xFFCBD5E1);

  // Gradient helpers
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF047857), Color(0xFF065F46)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF0F291E), Color(0xFF1E3A2B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Common card box shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}
