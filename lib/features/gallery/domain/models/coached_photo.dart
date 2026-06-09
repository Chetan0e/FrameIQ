import '../../../camera/domain/enums/scene_mode.dart';
import '../../../camera/domain/enums/composition_type.dart';

class CoachedPhoto {
  final String id;
  final String filePath;
  final DateTime dateTime;
  final double score;
  final SceneMode sceneMode;
  final CompositionType compositionType;
  final List<String> suggestionMessages;
  final String? aiCritique;

  CoachedPhoto({
    required this.id,
    required this.filePath,
    required this.dateTime,
    required this.score,
    required this.sceneMode,
    this.compositionType = CompositionType.none,
    required this.suggestionMessages,
    this.aiCritique,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'dateTime': dateTime.toIso8601String(),
      'score': score,
      'sceneMode': sceneMode.name,
      'compositionType': compositionType.name,
      'suggestionMessages': suggestionMessages,
      'aiCritique': aiCritique,
    };
  }

  factory CoachedPhoto.fromJson(Map<String, dynamic> json) {
    return CoachedPhoto(
      id: json['id'],
      filePath: json['filePath'],
      dateTime: DateTime.parse(json['dateTime']),
      score: (json['score'] as num).toDouble(),
      sceneMode: SceneMode.values.firstWhere(
        (e) => e.name == json['sceneMode'],
        orElse: () => SceneMode.auto,
      ),
      compositionType: CompositionType.values.firstWhere(
        (e) => e.name == json['compositionType'],
        orElse: () => CompositionType.none,
      ),
      suggestionMessages: List<String>.from(json['suggestionMessages'] ?? []),
      aiCritique: json['aiCritique'],
    );
  }

  CoachedPhoto copyWith({
    String? id,
    String? filePath,
    DateTime? dateTime,
    double? score,
    SceneMode? sceneMode,
    CompositionType? compositionType,
    List<String>? suggestionMessages,
    String? aiCritique,
  }) {
    return CoachedPhoto(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      dateTime: dateTime ?? this.dateTime,
      score: score ?? this.score,
      sceneMode: sceneMode ?? this.sceneMode,
      compositionType: compositionType ?? this.compositionType,
      suggestionMessages: suggestionMessages ?? this.suggestionMessages,
      aiCritique: aiCritique ?? this.aiCritique,
    );
  }
}
