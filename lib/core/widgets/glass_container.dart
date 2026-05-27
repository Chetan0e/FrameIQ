import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Frosted panel used on camera HUD and controls.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool blur;
  final Color? tint;
  final Border? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.blur = true,
    this.tint,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final panel = DecoratedBox(
      decoration: BoxDecoration(
        color: (tint ?? Colors.black).withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ??
            Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );

    if (!blur) return panel;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: panel,
      ),
    );
  }
}

/// Primary CTA used on onboarding and error screens.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool expanded;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.bg,
        disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.35),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          letterSpacing: 0.2,
        ),
      ),
      child: Text(label),
    );

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
