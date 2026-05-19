import 'package:flutter/material.dart';
import '../../domain/enums/scene_mode.dart';
import '../../../../core/constants/app_colors.dart';

class HudBar extends StatelessWidget {
  final SceneMode scene;
  final VoidCallback onFlip;

  const HudBar({super.key, required this.scene, required this.onFlip});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, top + 12, 20, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          // App name
          const Text(
            'Frame',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'IQ',
            style: TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),

          // Scene mode chip
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(scene),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Text(
                '${scene.emoji} ${scene.label}',
                style: const TextStyle(
                  color: AppColors.accent3,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Settings icon
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: const Icon(Icons.tune_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
