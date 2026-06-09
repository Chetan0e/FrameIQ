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

  void _showLearnDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _LearnModeDialog(suggestion: suggestion),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => _showLearnDialog(context),
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
      ),
    );
  }
}

class _LearnModeDialog extends StatelessWidget {
  final CoachingSuggestion suggestion;

  const _LearnModeDialog({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: suggestion.bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: suggestion.iconColor.withValues(alpha: 0.5)),
                  ),
                  alignment: Alignment.center,
                  child: Text(suggestion.emoji, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    suggestion.label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: suggestion.iconColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              suggestion.message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Photography Lesson',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getLesson(suggestion.label),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: suggestion.iconColor,
                foregroundColor: AppColors.bg,
              ),
              child: const Text('Got it!'),
            ),
          ],
        ),
      ),
    );
  }

  String _getLesson(String label) {
    if (label.contains('Level')) {
      return 'Keeping your camera perfectly level prevents distorted perspectives and makes architectural lines straight.';
    } else if (label.contains('Face')) {
      return 'Positioning faces correctly within the frame ensures the subject is in focus and well-lit.';
    } else if (label.contains('Space')) {
      return 'Leaving space in front of the subject creates a sense of movement or direction.';
    }
    return 'Following fundamental composition rules draws the viewer\'s eye naturally to your subject, creating a more engaging and balanced photograph.';
  }
}
