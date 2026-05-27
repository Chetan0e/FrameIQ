import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/enums/scene_mode.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';

class ModeSelector extends StatelessWidget {
  final bool isAutoMode;
  final SceneMode? manualMode;
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
    required this.isAutoMode,
    required this.manualMode,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _modes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final mode = _modes[i];
          final isActive = mode == SceneMode.auto
              ? isAutoMode
              : manualMode == mode;

          return _ModeChip(
            mode: mode,
            isActive: isActive,
            onTap: () {
              HapticFeedback.selectionClick();
              onModeSelected(mode);
            },
          );
        },
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final SceneMode mode;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeChip({
    required this.mode,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: GlassContainer(
          borderRadius: 20,
          blur: false,
          tint: isActive ? AppColors.accent : Colors.black,
          border: Border.all(
            color: isActive
                ? AppColors.accent.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            '${mode.emoji} ${mode.label}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? AppColors.accent : AppColors.textMuted,
              letterSpacing: 0.15,
            ),
          ),
        ),
      ),
    );
  }
}
