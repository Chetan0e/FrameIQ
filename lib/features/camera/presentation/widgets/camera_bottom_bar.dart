import 'package:flutter/material.dart';

import '../../domain/enums/scene_mode.dart';
import 'mode_selector.dart';
import 'shutter_button.dart';
import 'suggestion_strip.dart';
import '../../domain/models/coaching_suggestion.dart';

/// Bottom camera controls with safe-area padding and a readability gradient.
class CameraBottomBar extends StatelessWidget {
  final List<CoachingSuggestion> suggestions;
  final bool isAutoMode;
  final SceneMode? manualMode;
  final ValueChanged<SceneMode> onModeSelected;
  final VoidCallback onCapture;
  final VoidCallback onFlip;

  const CameraBottomBar({
    super.key,
    required this.suggestions,
    required this.isAutoMode,
    required this.manualMode,
    required this.onModeSelected,
    required this.onCapture,
    required this.onFlip,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SuggestionStrip(suggestions: suggestions),
                ),
                const SizedBox(height: 12),
                ModeSelector(
                  isAutoMode: isAutoMode,
                  manualMode: manualMode,
                  onModeSelected: onModeSelected,
                ),
                const SizedBox(height: 14),
                ShutterRow(
                  onCapture: onCapture,
                  onFlip: onFlip,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
