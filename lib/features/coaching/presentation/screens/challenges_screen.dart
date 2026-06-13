import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../camera/domain/enums/scene_mode.dart';
import '../../../camera/domain/enums/composition_type.dart';
import '../../../gallery/presentation/controllers/gallery_notifier.dart';
import '../../../gallery/presentation/screens/photo_detail_screen.dart';
import '../controllers/challenges_notifier.dart';
import '../../domain/models/challenge.dart';

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(challengesProvider);
    final photos = ref.watch(galleryNotifierProvider);

    final completedQuests = state.challenges.where((c) => c.isCompleted).toList();
    final activeQuests = state.challenges.where((c) => !c.isCompleted).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          'Photography Academy',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.accent,
                labelColor: AppColors.accent,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                dividerColor: Colors.white10,
                tabs: [
                  Tab(text: 'Active Quests (${activeQuests.length})'),
                  Tab(text: 'Completed (${completedQuests.length})'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Academy Level Header
            _AcademyHeader(state: state),
            
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Active Quests Tab
                  activeQuests.isEmpty
                      ? const _EmptyQuestsView(
                          message: 'All quests completed!\nYou are a FrameIQ Master.',
                          icon: Icons.emoji_events_rounded,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: activeQuests.length,
                          separatorBuilder: (_, __) => const Gap(12),
                          itemBuilder: (context, index) {
                            final ch = activeQuests[index];
                            return _QuestCard(challenge: ch).animate().slideY(
                                  begin: 0.1,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                          },
                        ),

                  // Completed Tab
                  completedQuests.isEmpty
                      ? const _EmptyQuestsView(
                          message: 'No completed achievements yet.\nCapture photos to complete quests!',
                          icon: Icons.lock_outline_rounded,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: completedQuests.length,
                          separatorBuilder: (_, __) => const Gap(12),
                          itemBuilder: (context, index) {
                            final ch = completedQuests[index];
                            // Try to find matching photo
                            final photo = photos.firstWhere(
                              (p) => p.id == ch.completedWithPhotoId,
                              orElse: () => photos.isNotEmpty ? photos.first : photos.first, // Fallback if deleted, but wait, if deleted let's handle gracefully
                            );
                            final photoExists = photos.any((p) => p.id == ch.completedWithPhotoId);
                            
                            return _CompletedQuestCard(
                              challenge: ch,
                              photoPath: photoExists ? photo.filePath : null,
                              photoId: ch.completedWithPhotoId,
                            ).animate().fadeIn(
                                  duration: const Duration(milliseconds: 300),
                                );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AcademyHeader extends StatelessWidget {
  final ChallengesState state;

  const _AcademyHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: GlassContainer(
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Level Badge
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.8),
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'LVL',
                        style: TextStyle(
                          fontSize: 8,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${state.level}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(16),
                // Level Name and Progress
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${state.rankName} photographer',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        '${state.xp} total XP · ${state.xpNeededForNextLevel} XP to next level',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(14),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 8,
                child: LinearProgressIndicator(
                  value: state.levelProgress,
                  backgroundColor: Colors.white10,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  final Challenge challenge;

  const _QuestCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Gap(6),
                    Text(
                      challenge.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(12),
              // XP Reward Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
                ),
                child: Text(
                  '+${challenge.xpReward} XP',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const Gap(14),
          // Requirements Strip
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _RequirementChip(
                icon: Icons.photo_camera_rounded,
                label: 'Mode: ${challenge.sceneMode.label}',
              ),
              _RequirementChip(
                icon: Icons.grid_3x3_rounded,
                label: challenge.compositionType.label,
              ),
              _RequirementChip(
                icon: Icons.analytics_rounded,
                label: 'Score >= ${challenge.minScore.round()}%',
              ),
              if (challenge.maxTilt < 5.0)
                _RequirementChip(
                  icon: Icons.straighten_rounded,
                  label: 'Level Tilt (< ${challenge.maxTilt}°)',
                ),
              if (challenge.requireFace)
                const _RequirementChip(
                  icon: Icons.face_rounded,
                  label: 'Face Required',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletedQuestCard extends StatelessWidget {
  final Challenge challenge;
  final String? photoPath;
  final String? photoId;

  const _CompletedQuestCard({
    required this.challenge,
    required this.photoPath,
    required this.photoId,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = challenge.completedAt != null
        ? '${challenge.completedAt!.day}/${challenge.completedAt!.month}/${challenge.completedAt!.year}'
        : 'Completed';

    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Left Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 18,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        challenge.title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(6),
                Text(
                  'Completed on $formattedDate',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${challenge.xpReward} XP Earned',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          // Photo Thumbnail link
          if (photoPath != null && photoId != null)
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PhotoDetailScreen(photoId: photoId!),
                  ),
                );
              },
              child: Hero(
                tag: 'photo_$photoId',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Image.file(
                        File(photoPath!),
                        width: 68,
                        height: 68,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.visibility_rounded,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: Colors.white30,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }
}

class _RequirementChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _RequirementChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textMuted, size: 11),
          const Gap(5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyQuestsView extends StatelessWidget {
  final String message;
  final IconData icon;

  const _EmptyQuestsView({
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
              ),
              child: Icon(
                icon,
                color: AppColors.accent,
                size: 28,
              ),
            ),
            const Gap(16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
