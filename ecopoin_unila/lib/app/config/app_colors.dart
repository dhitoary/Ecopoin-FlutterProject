// lib/app/config/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2ECC71);
  static const Color secondary = Color(0xFF005792);
  static const Color accent = Color(0xFFFDD835);
  static const Color background = Color(0xFFF7F9FC);
  static const Color textDark = Color(0xFF2C3E50);
  static const Color border = Color(0xFFE0E0E0);

  // WARNA BARU DARI HTML AUTH
  static const Color inputBackground = Color(0xFFE7F3EC);
  static const Color textGreen = Color(0xFF4C9A6C);

  static const Gradient userGradient = LinearGradient(
    colors: [Color(0xFF2ECC71), Color(0xFF005792)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}