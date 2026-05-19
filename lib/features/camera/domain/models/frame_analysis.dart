import 'dart:ui' show Rect;

import '../enums/composition_type.dart';
import '../enums/scene_mode.dart';
import 'coaching_suggestion.dart';

/// The complete result of one analysis pass on the live camera frame.
class FrameAnalysis {
  final SceneMode detectedScene;
  final CompositionType recommendedComposition;
  final List<CoachingSuggestion> suggestions;
  final double compositionScore; // 0–100
  final double horizonTiltDeg;  // positive = clockwise tilt
  final bool faceDetected;
  final Rect? faceRect;
  final bool isWellLit;
  final DateTime timestamp;

  const FrameAnalysis({
    required this.detectedScene,
    required this.recommendedComposition,
    required this.suggestions,
    required this.compositionScore,
    this.horizonTiltDeg = 0.0,
    this.faceDetected = false,
    this.faceRect,
    this.isWellLit = true,
    required this.timestamp,
  });

  /// Empty / default state shown before first analysis
  factory FrameAnalysis.initial() => FrameAnalysis(
        detectedScene: SceneMode.auto,
        recommendedComposition: CompositionType.ruleOfThirds,
        suggestions: [],
        compositionScore: 0.0,
        timestamp: DateTime.now(),
      );

  FrameAnalysis copyWith({
    SceneMode? detectedScene,
    CompositionType? recommendedComposition,
    List<CoachingSuggestion>? suggestions,
    double? compositionScore,
    double? horizonTiltDeg,
    bool? faceDetected,
    Rect? faceRect,
    bool? isWellLit,
    DateTime? timestamp,
  }) {
    return FrameAnalysis(
      detectedScene: detectedScene ?? this.detectedScene,
      recommendedComposition: recommendedComposition ?? this.recommendedComposition,
      suggestions: suggestions ?? this.suggestions,
      compositionScore: compositionScore ?? this.compositionScore,
      horizonTiltDeg: horizonTiltDeg ?? this.horizonTiltDeg,
      faceDetected: faceDetected ?? this.faceDetected,
      faceRect: faceRect ?? this.faceRect,
      isWellLit: isWellLit ?? this.isWellLit,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
