import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';

class ScoreMeter extends StatelessWidget {
  final double score;

  const ScoreMeter({super.key, required this.score});

  Color get _color {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.accent;
    return AppColors.accent2;
  }

  @override
  Widget build(BuildContext context) {
    final isHigh = score >= 85;

    Widget meter = GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: SizedBox(
        width: 44,
        height: 148,
        child: Column(
          children: [
            Text(
              score.round().toString(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _color,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      tween: Tween<double>(begin: 0, end: score / 100),
                      builder: (context, value, child) {
                        return FractionallySizedBox(
                          heightFactor: value.clamp(0.04, 1),
                          child: child,
                        );
                      },
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              _color,
                              _color.withValues(alpha: 0.45),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'SCORE',
              style: TextStyle(
                fontSize: 8,
                color: AppColors.textMuted.withValues(alpha: 0.9),
                letterSpacing: 0.7,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );

    if (isHigh) {
      meter = meter
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .shimmer(
            duration: 1600.ms,
            color: _color.withValues(alpha: 0.25),
            curve: Curves.easeInOut,
          );
    }

    return meter;
  }
}
