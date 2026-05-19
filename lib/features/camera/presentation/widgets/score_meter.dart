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
      width: 36,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
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
                  Container(color: Colors.white.withOpacity(0.1)),
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    heightFactor: score / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [_color, _color.withOpacity(0.5)],
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
            style: TextStyle(
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
