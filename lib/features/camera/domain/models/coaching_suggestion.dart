import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum SuggestionType { good, warn, info }

class CoachingSuggestion {
  final SuggestionType type;
  final String label;   // e.g. "ANGLE", "LIGHT", "COMPOSITION"
  final String message; // short human-readable tip
  final String emoji;

  const CoachingSuggestion({
    required this.type,
    required this.label,
    required this.message,
    required this.emoji,
  });

  Color get bgColor {
    switch (type) {
      case SuggestionType.good: return AppColors.goodBg;
      case SuggestionType.warn: return AppColors.warnBg;
      case SuggestionType.info: return AppColors.infoBg;
    }
  }

  Color get iconColor {
    switch (type) {
      case SuggestionType.good: return AppColors.goodIcon;
      case SuggestionType.warn: return AppColors.warnIcon;
      case SuggestionType.info: return AppColors.infoIcon;
    }
  }
}
