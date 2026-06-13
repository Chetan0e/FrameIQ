import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../camera/domain/enums/scene_mode.dart';
import '../../../camera/domain/enums/composition_type.dart';
import '../../../gallery/domain/models/coached_photo.dart';
import '../../domain/models/challenge.dart';

class ChallengesState {
  final int xp;
  final List<Challenge> challenges;

  const ChallengesState({
    required this.xp,
    required this.challenges,
  });

  int get level {
    return (xp / 300).floor() + 1;
  }

  double get levelProgress {
    final currentLevelBaseXp = (level - 1) * 300;
    final xpInCurrentLevel = xp - currentLevelBaseXp;
    return (xpInCurrentLevel / 300.0).clamp(0.0, 1.0);
  }

  int get xpNeededForNextLevel {
    return 300 - (xp % 300);
  }

  String get rankName {
    final lvl = level;
    if (lvl == 1) return 'Novice';
    if (lvl == 2) return 'Apprentice';
    if (lvl == 3) return 'Enthusiast';
    if (lvl == 4) return 'Pro Framer';
    return 'FrameIQ Master';
  }

  ChallengesState copyWith({
    int? xp,
    List<Challenge>? challenges,
  }) {
    return ChallengesState(
      xp: xp ?? this.xp,
      challenges: challenges ?? this.challenges,
    );
  }
}

final challengesProvider =
    StateNotifierProvider<ChallengesNotifier, ChallengesState>((ref) {
  return ChallengesNotifier();
});

class ChallengesNotifier extends StateNotifier<ChallengesState> {
  ChallengesNotifier()
      : super(const ChallengesState(xp: 0, challenges: [])) {
    _loadState();
  }

  static const _prefXpKey = 'frameiq_user_xp';
  static const _prefCompletedChallengesKey = 'frameiq_completed_challenges';

  final List<Challenge> _defaultChallenges = const [
    Challenge(
      id: 'horizon_leveler',
      title: 'Horizon Leveler',
      description: 'Align the horizon line perfectly level on a landscape shot.',
      sceneMode: SceneMode.landscape,
      compositionType: CompositionType.ruleOfThirds,
      minScore: 88.0,
      maxTilt: 0.8,
      xpReward: 100,
    ),
    Challenge(
      id: 'golden_ratio_macro',
      title: 'Golden Ratio Macro',
      description: 'Use the Golden Spiral overlay to snap a macro shot of flowers or small details.',
      sceneMode: SceneMode.macro,
      compositionType: CompositionType.goldenSpiral,
      minScore: 85.0,
      maxTilt: 15.0,
      xpReward: 150,
    ),
    Challenge(
      id: 'symmetrical_axis',
      title: 'Symmetric Architecture',
      description: 'Compose a building perfectly centered along the vertical axis.',
      sceneMode: SceneMode.architecture,
      compositionType: CompositionType.symmetry,
      minScore: 90.0,
      maxTilt: 1.0,
      xpReward: 150,
    ),
    Challenge(
      id: 'dynamic_motion',
      title: 'Dynamic Action',
      description: 'Shoot dynamic action aligned along diagonal guides.',
      sceneMode: SceneMode.action,
      compositionType: CompositionType.diagonal,
      minScore: 85.0,
      maxTilt: 15.0,
      xpReward: 120,
    ),
    Challenge(
      id: 'portrait_master',
      title: 'Portrait Master',
      description: 'Capture a portrait with a level camera, high score, and face detected.',
      sceneMode: SceneMode.portrait,
      compositionType: CompositionType.ruleOfThirds,
      minScore: 90.0,
      maxTilt: 1.5,
      requireFace: true,
      xpReward: 200,
    ),
    Challenge(
      id: 'vanishing_point_street',
      title: 'Leading Street',
      description: 'Guide the viewer\'s eye along streets or pathways using leading lines.',
      sceneMode: SceneMode.street,
      compositionType: CompositionType.leadingLines,
      minScore: 86.0,
      maxTilt: 2.0,
      xpReward: 120,
    ),
    Challenge(
      id: 'flat_lay_food',
      title: 'Flat-Lay Foodie',
      description: 'Shoot food from directly above, centered perfectly.',
      sceneMode: SceneMode.food,
      compositionType: CompositionType.centerFrame,
      minScore: 88.0,
      maxTilt: 15.0,
      xpReward: 100,
    ),
  ];

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final xp = prefs.getInt(_prefXpKey) ?? 0;
    final completedData = prefs.getStringList(_prefCompletedChallengesKey) ?? [];

    // completedData format: challengeId|photoId|timestamp
    final completedMap = <String, Map<String, dynamic>>{};
    for (final item in completedData) {
      final parts = item.split('|');
      if (parts.length >= 3) {
        completedMap[parts[0]] = {
          'photoId': parts[1],
          'completedAt': parts[2],
        };
      }
    }

    final list = _defaultChallenges.map((ch) {
      if (completedMap.containsKey(ch.id)) {
        final comp = completedMap[ch.id]!;
        return ch.copyWith(
          completedWithPhotoId: comp['photoId'] as String,
          completedAt: DateTime.parse(comp['completedAt'] as String),
        );
      }
      return ch;
    }).toList();

    state = ChallengesState(xp: xp, challenges: list);
  }


  Future<Challenge?> checkAndUnlockChallenge({
    required CoachedPhoto photo,
    required double actualTilt,
    required bool faceDetected,
  }) async {
    Challenge? unlocked;
    final currentChallenges = state.challenges;
    final List<Challenge> nextChallenges = [];

    for (final ch in currentChallenges) {
      if (ch.isCompleted) {
        nextChallenges.add(ch);
        continue;
      }

      // Check conditions
      final sceneMatch = ch.sceneMode == SceneMode.auto || ch.sceneMode == photo.sceneMode;
      final compMatch = ch.compositionType == CompositionType.none || ch.compositionType == photo.compositionType;
      final scoreMatch = photo.score >= ch.minScore;
      final tiltMatch = actualTilt.abs() <= ch.maxTilt;
      final faceMatch = !ch.requireFace || faceDetected;

      if (sceneMatch && compMatch && scoreMatch && tiltMatch && faceMatch) {
        unlocked = ch.copyWith(
          completedWithPhotoId: photo.id,
          completedAt: DateTime.now(),
        );
        nextChallenges.add(unlocked);
      } else {
        nextChallenges.add(ch);
      }
    }

    if (unlocked != null) {
      final newXp = state.xp + unlocked.xpReward;
      state = state.copyWith(xp: newXp, challenges: nextChallenges);
      await _persist(newXp, nextChallenges);
    }

    return unlocked;
  }

  Future<void> _persist(int xp, List<Challenge> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefXpKey, xp);

    final completedData = list
        .where((c) => c.isCompleted)
        .map((c) => '${c.id}|${c.completedWithPhotoId}|${c.completedAt!.toIso8601String()}')
        .toList();

    await prefs.setStringList(_prefCompletedChallengesKey, completedData);
  }
}
