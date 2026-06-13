import '../../../camera/domain/enums/scene_mode.dart';
import '../../../camera/domain/enums/composition_type.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final SceneMode sceneMode;
  final CompositionType compositionType;
  final double minScore;
  final double maxTilt;
  final bool requireFace;
  final int xpReward;

  // Completion state
  final String? completedWithPhotoId;
  final DateTime? completedAt;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.sceneMode,
    required this.compositionType,
    required this.minScore,
    required this.maxTilt,
    this.requireFace = false,
    required this.xpReward,
    this.completedWithPhotoId,
    this.completedAt,
  });

  bool get isCompleted => completedWithPhotoId != null;

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    SceneMode? sceneMode,
    CompositionType? compositionType,
    double? minScore,
    double? maxTilt,
    bool? requireFace,
    int? xpReward,
    String? completedWithPhotoId,
    DateTime? completedAt,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      sceneMode: sceneMode ?? this.sceneMode,
      compositionType: compositionType ?? this.compositionType,
      minScore: minScore ?? this.minScore,
      maxTilt: maxTilt ?? this.maxTilt,
      requireFace: requireFace ?? this.requireFace,
      xpReward: xpReward ?? this.xpReward,
      completedWithPhotoId: completedWithPhotoId ?? this.completedWithPhotoId,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'sceneMode': sceneMode.name,
      'compositionType': compositionType.name,
      'minScore': minScore,
      'maxTilt': maxTilt,
      'requireFace': requireFace,
      'xpReward': xpReward,
      'completedWithPhotoId': completedWithPhotoId,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      sceneMode: SceneMode.values.firstWhere(
        (e) => e.name == json['sceneMode'],
        orElse: () => SceneMode.auto,
      ),
      compositionType: CompositionType.values.firstWhere(
        (e) => e.name == json['compositionType'],
        orElse: () => CompositionType.none,
      ),
      minScore: (json['minScore'] as num).toDouble(),
      maxTilt: (json['maxTilt'] as num).toDouble(),
      requireFace: json['requireFace'] as bool? ?? false,
      xpReward: json['xpReward'] as int,
      completedWithPhotoId: json['completedWithPhotoId'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}
