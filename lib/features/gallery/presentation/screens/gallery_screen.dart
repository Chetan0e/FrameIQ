import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../camera/domain/enums/scene_mode.dart';
import '../controllers/gallery_notifier.dart';
import '../../domain/models/coached_photo.dart';
import 'photo_detail_screen.dart';

final galleryFilterProvider = StateProvider<SceneMode?>((ref) => null);

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  Color _scoreColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.accent;
    return AppColors.accent2;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(galleryNotifierProvider);
    final activeFilter = ref.watch(galleryFilterProvider);

    final filteredPhotos = activeFilter == null
        ? photos
        : photos.where((p) => p.sceneMode == activeFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          'Coached Album',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: photos.isEmpty
          ? const _EmptyGalleryView()
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: _GalleryDashboard(photos: photos),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: _FilterStrip(),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: filteredPhotos.isEmpty
                          ? Center(
                              child: Text(
                                'No coached photos in this mode yet.',
                                style: TextStyle(
                                  color: AppColors.textMuted.withValues(alpha: 0.8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: filteredPhotos.length,
                              itemBuilder: (context, index) {
                                final photo = filteredPhotos[index];
                                final scoreCol = _scoreColor(photo.score);

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => PhotoDetailScreen(photoId: photo.id),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: 'photo_${photo.id}',
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.file(
                                            File(photo.filePath),
                                            fit: BoxFit.cover,
                                          ),
                                          // Gradient overlay for readability
                                          Positioned.fill(
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.black.withValues(alpha: 0.4),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Score badge top right
                                          Positioned(
                                            top: 6,
                                            right: 6,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.75),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: scoreCol.withValues(alpha: 0.6),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                '${photo.score.round()}',
                                                style: TextStyle(
                                                  color: scoreCol,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Scene emoji bottom left
                                          Positioned(
                                            bottom: 6,
                                            left: 6,
                                            child: Text(
                                              photo.sceneMode.emoji,
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _GalleryDashboard extends StatelessWidget {
  final List<CoachedPhoto> photos;

  const _GalleryDashboard({required this.photos});

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();

    // 1. Avg Score
    final avgScore = photos.isEmpty
        ? 0.0
        : photos.map((p) => p.score).reduce((a, b) => a + b) / photos.length;

    // 2. Peak Score
    double peakScore = 0.0;
    for (final p in photos) {
      if (p.score > peakScore) peakScore = p.score;
    }

    // 3. Dominant Genre
    final counts = <SceneMode, int>{};
    for (final p in photos) {
      counts[p.sceneMode] = (counts[p.sceneMode] ?? 0) + 1;
    }
    SceneMode dominantMode = SceneMode.auto;
    int maxCount = 0;
    counts.forEach((mode, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantMode = mode;
      }
    });

    Color scoreColor(double score) {
      if (score >= 80) return AppColors.success;
      if (score >= 60) return AppColors.accent;
      return AppColors.accent2;
    }

    final avgColor = scoreColor(avgScore);

    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'COACHED',
            value: '${photos.length}',
            sub: 'Photos',
            icon: Icons.photo_library_rounded,
            iconColor: AppColors.accent3,
          ),
          Container(width: 1, height: 36, color: Colors.white10),
          _StatItem(
            label: 'AVG SCORE',
            value: '${avgScore.round()}%',
            sub: avgScore >= 80 ? 'Master' : (avgScore >= 60 ? 'Skilled' : 'Novice'),
            icon: Icons.analytics_rounded,
            iconColor: avgColor,
          ),
          Container(width: 1, height: 36, color: Colors.white10),
          _StatItem(
            label: 'PEAK SCORE',
            value: '${peakScore.round()}%',
            sub: 'Personal Best',
            icon: Icons.emoji_events_rounded,
            iconColor: AppColors.accent,
          ),
          Container(width: 1, height: 36, color: Colors.white10),
          _StatItem(
            label: 'FAVORITE',
            value: dominantMode.emoji,
            sub: dominantMode.label,
            icon: Icons.star_rounded,
            iconColor: AppColors.accent2,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color iconColor;

  const _StatItem({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor.withValues(alpha: 0.8), size: 12),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 8,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          sub,
          style: const TextStyle(
            fontSize: 9,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _FilterStrip extends ConsumerWidget {
  const _FilterStrip();

  static const _filters = [
    null, // All
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(galleryFilterProvider);

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final mode = _filters[i];
          final isActive = active == mode;
          final String label = mode == null ? '✨ All' : '${mode.emoji} ${mode.label}';

          return GestureDetector(
            onTap: () {
              ref.read(galleryFilterProvider.notifier).state = mode;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: isActive ? AppColors.accent.withValues(alpha: 0.14) : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isActive
                      ? AppColors.accent.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.08),
                  width: 1.2,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.accent : AppColors.textMuted,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyGalleryView extends StatelessWidget {
  const _EmptyGalleryView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.accent,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No coached photos yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Capture some shots using the camera. FrameIQ will save them here with composition scores and alignment tips.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
