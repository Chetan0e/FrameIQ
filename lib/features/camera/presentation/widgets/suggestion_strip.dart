import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/models/coaching_suggestion.dart';
import '../../../../core/constants/app_colors.dart';

class SuggestionStrip extends StatelessWidget {
  final List<CoachingSuggestion> suggestions;

  const SuggestionStrip({super.key, required this.suggestions});

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: suggestions
          .map((s) => _SuggestionPill(suggestion: s)
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.3, end: 0, duration: 300.ms, curve: Curves.easeOut))
          .toList(),
    );
  }
}

class _SuggestionPill extends StatelessWidget {
  final CoachingSuggestion suggestion;

  const _SuggestionPill({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
        // very subtle blur via BackdropFilter in parent if needed
      ),
      child: Row(
        children: [
          // Icon badge
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: suggestion.bgColor,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Text(suggestion.emoji, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: suggestion.iconColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  suggestion.message,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
