import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color bg = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF12121A);
  static const Color card = Color(0xFF1A1A26);
  static const Color border = Color(0x12FFFFFF);

  static const Color accent = Color(0xFFE8FF47);   // lime-yellow
  static const Color accent2 = Color(0xFFFF6B35);  // orange
  static const Color accent3 = Color(0xFF47C8FF);  // sky blue
  static const Color success = Color(0xFF3DDC84);  // green

  static const Color textPrimary = Color(0xFFF0F0F8);
  static const Color textMuted = Color(0xFF6B6B88);

  // Composition overlay colors
  static const Color overlayGrid = Color(0x66E8FF47);       // lime 40%
  static const Color overlayGridPower = Color(0xCCE8FF47);  // lime 80% for power points
  static const Color overlaySpiral = Color(0x80FFD700);     // gold
  static const Color overlayLeading = Color(0x99FF6B35);    // orange
  static const Color overlaySymmetry = Color(0x8047C8FF);   // sky
  static const Color overlayHorizon = Color(0x6647C8FF);    // sky faint
  static const Color overlayDiagonal = Color(0x809B59B6);   // purple

  // Suggestion badge colors
  static const Color warnBg = Color(0x33FF6B35);
  static const Color infoBg = Color(0x3347C8FF);
  static const Color goodBg = Color(0x333DDC84);
  static const Color warnIcon = Color(0xFFFF6B35);
  static const Color infoIcon = Color(0xFF47C8FF);
  static const Color goodIcon = Color(0xFF3DDC84);
}
