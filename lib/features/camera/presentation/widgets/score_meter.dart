import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ScoreMeter extends StatelessWidget {
  final double score; // 0–100

  const ScoreMeter({super.key, required this.score});

  Color get _color {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.accent;
    return AppColors.accent2;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Column(
        children: [
          // Score number
          Text(
            score.round().toString(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _color,
            ),
          ),
          const SizedBox(height: 6),
          // Vertical bar
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(color: Colors.white.withValues(alpha: 0.1)),
<<<<<<< HEAD
                  TweenAnimationBuilder<double>(
=======
                  AnimatedFractionallySizedBox(
>>>>>>> eacce8c11ea1ce82365e02e44cb101f1683bd073
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    tween: Tween<double>(begin: 0.0, end: score / 100),
                    builder: (context, value, child) {
                      return FractionallySizedBox(
                        heightFactor: value,
                        child: child,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [_color, _color.withValues(alpha: 0.5)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'SCORE',
            style: const TextStyle(
              fontSize: 8,
              color: AppColors.textMuted,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
