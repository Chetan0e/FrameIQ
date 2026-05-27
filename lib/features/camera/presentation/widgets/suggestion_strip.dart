import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/models/coaching_suggestion.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';

class SuggestionStrip extends StatelessWidget {
  final List<CoachingSuggestion> suggestions;

  const SuggestionStrip({super.key, required this.suggestions});

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: suggestions
          .map(
            (s) => _SuggestionPill(suggestion: s)
                .animate()
                .fadeIn(duration: 280.ms)
                .slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 280.ms,
                  curve: Curves.easeOutCubic,
                ),
          )
          .toList(),
    );
  }
}

class _SuggestionPill extends StatelessWidget {
  final CoachingSuggestion suggestion;

  const _SuggestionPill({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: suggestion.bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: suggestion.iconColor.withValues(alpha: 0.35),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                suggestion.emoji,
                style: const TextStyle(fontSize: 17),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.9,
                      color: suggestion.iconColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    suggestion.message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
