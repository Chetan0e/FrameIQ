import 'package:flutter/material.dart';
import '../../domain/enums/scene_mode.dart';
import '../../../../core/constants/app_colors.dart';

class ModeSelector extends StatelessWidget {
  final SceneMode currentScene;
  final ValueChanged<SceneMode> onModeSelected;

  static const _modes = [
    SceneMode.auto,
    SceneMode.portrait,
    SceneMode.selfie,
    SceneMode.landscape,
    SceneMode.food,
    SceneMode.architecture,
    SceneMode.macro,
    SceneMode.action,
    SceneMode.night,
    SceneMode.street,
  ];

  const ModeSelector({
    super.key,
    required this.currentScene,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _modes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final mode = _modes[i];
          final isActive = mode == currentScene;
          return GestureDetector(
            onTap: () => onModeSelected(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.accent.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? AppColors.accent
                      : Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              child: Text(
                '${mode.emoji} ${mode.label}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive ? AppColors.accent : AppColors.textMuted,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
