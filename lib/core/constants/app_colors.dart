import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color bg = Color(0xFF000000);
  static const Color surface = Color(0xFF141414);
  static const Color card = Color(0xFF1C1C1E);
  static const Color border = Color(0x26FFFFFF); // 15% white

  static const Color accent = Color(0xFFFFB000);   // Pro Amber
  static const Color accent2 = Color(0xFFFF453A);  // iOS Red
  static const Color accent3 = Color(0xFF00F0FF);  // Cyber Cyan
  static const Color success = Color(0xFF32D74B);  // iOS Green

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF8E8E93);

  // Composition overlay colors
  static const Color overlayGrid = Color(0x66FFFFFF);       // White 40%
  static const Color overlayGridPower = Color(0xCCFFB000);  // Amber 80% for power points
  static const Color overlaySpiral = Color(0x80FFD700);     // gold
  static const Color overlayLeading = Color(0x99FF453A);    // red
  static const Color overlaySymmetry = Color(0x8000F0FF);   // cyan
  static const Color overlayHorizon = Color(0x6600F0FF);    // cyan faint
  static const Color overlayDiagonal = Color(0x80BF5AF2);   // purple

  // Suggestion badge colors
  static const Color warnBg = Color(0x33FF453A);
  static const Color infoBg = Color(0x3300F0FF);
  static const Color goodBg = Color(0x3332D74B);
  static const Color warnIcon = Color(0xFFFF453A);
  static const Color infoIcon = Color(0xFF00F0FF);
  static const Color goodIcon = Color(0xFF32D74B);
}
