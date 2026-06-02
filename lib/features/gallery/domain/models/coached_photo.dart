import '../../../camera/domain/enums/scene_mode.dart';

class CoachedPhoto {
  final String id;
  final String filePath;
  final DateTime dateTime;
  final double score;
  final SceneMode sceneMode;
  final List<String> suggestionMessages;
  final String? aiCritique;

  CoachedPhoto({
    required this.id,
    required this.filePath,
    required this.dateTime,
    required this.score,
    required this.sceneMode,
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
    List<String>? suggestionMessages,
    String? aiCritique,
  }) {
    return CoachedPhoto(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      dateTime: dateTime ?? this.dateTime,
      score: score ?? this.score,
      sceneMode: sceneMode ?? this.sceneMode,
      suggestionMessages: suggestionMessages ?? this.suggestionMessages,
      aiCritique: aiCritique ?? this.aiCritique,
    );
  }
}
