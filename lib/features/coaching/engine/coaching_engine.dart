import 'dart:math' as math;
import 'dart:ui';

import 'package:sensors_plus/sensors_plus.dart';

import '../../camera/data/services/face_coach_service.dart';
import '../../camera/domain/enums/composition_type.dart';
import '../../camera/domain/enums/scene_mode.dart';
import '../../camera/domain/models/coaching_suggestion.dart';
import '../../camera/domain/models/frame_analysis.dart';
import '../../../core/constants/app_constants.dart';

/// Assembles a complete [FrameAnalysis] from individual service results
/// and accelerometer tilt data.
class CoachingEngine {
  double _accelX = 0;
  double _accelY = 0;
  double _prevAccelX = 0;
  double _prevAccelY = 0;
  double _deviceStillSeconds = 0;

  void updateAccelerometer(AccelerometerEvent e) {
    _prevAccelX = _accelX;
    _prevAccelY = _accelY;
    _accelX = e.x;
    _accelY = e.y;

    final delta = (_accelX - _prevAccelX) * (_accelX - _prevAccelX) +
        (_accelY - _prevAccelY) * (_accelY - _prevAccelY);
    if (delta < 0.02) {
      _deviceStillSeconds += 0.1;
    } else {
      _deviceStillSeconds = 0;
    }
  }

  bool get isDeviceStill =>
      _deviceStillSeconds >= AppConstants.overlayAutoHide.inSeconds;

  /// Roll angle from gravity vector (positive = clockwise roll).
  double get horizonTiltDeg =>
      -math.atan2(_accelX, _accelY) * (180 / math.pi);

  FrameAnalysis assemble({
    required SceneMode scene,
    required FaceCoachResult? faceResult,
    required bool isFrontCamera,
  }) {
    final suggestions = <CoachingSuggestion>[];
    double score = 70.0;

    final tilt = horizonTiltDeg;
    if (tilt.abs() > 5.0) {
      suggestions.add(CoachingSuggestion(
        type: SuggestionType.warn,
        label: 'HORIZON',
        message: tilt > 0
            ? 'Tilt camera ${tilt.abs().toStringAsFixed(0)}° left to level'
            : 'Tilt camera ${tilt.abs().toStringAsFixed(0)}° right to level',
        emoji: '⚖️',
      ));
      score -= math.min(20, tilt.abs() * 1.5);
    } else if (tilt.abs() < 1.0) {
      score += 5;
    }

    if (faceResult != null && faceResult.faceDetected) {
      suggestions.addAll(faceResult.suggestions);
      score = (score + faceResult.score) / 2;
    } else if (faceResult != null &&
        !faceResult.faceDetected &&
        (scene == SceneMode.portrait || scene == SceneMode.selfie)) {
      suggestions.addAll(faceResult.suggestions);
      score -= 20;
    }

    switch (scene) {
      case SceneMode.landscape:
        if (tilt.abs() < 2.0) {
          suggestions.add(const CoachingSuggestion(
            type: SuggestionType.info,
            label: 'COMPOSITION',
            message: 'Use rule of thirds — place horizon on lower line',
            emoji: '📐',
          ));
        }
        break;
      case SceneMode.food:
        suggestions.add(const CoachingSuggestion(
          type: SuggestionType.info,
          label: 'ANGLE',
          message: 'Shoot from directly above (90°) for flat-lay perfection',
          emoji: '⬆️',
        ));
        break;
      case SceneMode.architecture:
        if (tilt.abs() > 3.0) {
          suggestions.add(const CoachingSuggestion(
            type: SuggestionType.warn,
            label: 'VERTICALS',
            message: 'Straighten verticals — keep camera perfectly level',
            emoji: '🏛',
          ));
          score -= 10;
        } else {
          suggestions.add(const CoachingSuggestion(
            type: SuggestionType.info,
            label: 'SYMMETRY',
            message:
                'Center on the symmetry axis for strong architecture shots',
            emoji: '↔️',
          ));
        }
        break;
      case SceneMode.night:
        suggestions.add(const CoachingSuggestion(
          type: SuggestionType.warn,
          label: 'STABILITY',
          message: 'Brace elbows against body to minimize shake',
          emoji: '🌙',
        ));
        score -= 10;
        break;
      case SceneMode.macro:
        suggestions.add(const CoachingSuggestion(
          type: SuggestionType.info,
          label: 'DEPTH',
          message: 'Keep camera parallel to subject for sharpest macro detail',
          emoji: '🔬',
        ));
        break;
      case SceneMode.action:
        suggestions.add(const CoachingSuggestion(
          type: SuggestionType.info,
          label: 'LEAD ROOM',
          message: 'Leave space in the direction of motion for dynamic shots',
          emoji: '⚡',
        ));
        break;
      default:
        break;
    }

    if (suggestions.isEmpty) {
      suggestions.add(const CoachingSuggestion(
        type: SuggestionType.good,
        label: 'FRAME',
        message: 'Looking great — tap shutter when ready!',
        emoji: '✅',
      ));
      score = math.min(score + 10, 100);
    }

    final composition = _recommendComposition(scene, faceResult);

    Rect? faceRect = faceResult?.faceRect;
    if (faceRect != null && isFrontCamera) {
      faceRect = Rect.fromLTWH(
        1.0 - faceRect.right,
        faceRect.top,
        faceRect.width,
        faceRect.height,
      );
    }

    return FrameAnalysis(
      detectedScene: scene,
      recommendedComposition: composition,
      suggestions: _topSuggestions(suggestions),
      compositionScore: score.clamp(0, 100),
      horizonTiltDeg: tilt,
      faceDetected: faceResult?.faceDetected ?? false,
      faceRect: faceRect,
      timestamp: DateTime.now(),
    );
  }

  static List<CoachingSuggestion> _topSuggestions(
      List<CoachingSuggestion> all) {
    const priority = {
      SuggestionType.warn: 0,
      SuggestionType.info: 1,
      SuggestionType.good: 2,
    };
    final sorted = [...all]
      ..sort((a, b) =>
          priority[a.type]!.compareTo(priority[b.type]!));
    return sorted.take(2).toList();
  }

  CompositionType _recommendComposition(
      SceneMode scene, FaceCoachResult? face) {
    if (face != null && face.faceDetected) {
      return CompositionType.ruleOfThirds;
    }
    switch (scene) {
      case SceneMode.portrait:
      case SceneMode.selfie:
      case SceneMode.landscape:
      case SceneMode.night:
      case SceneMode.auto:
        return CompositionType.ruleOfThirds;
      case SceneMode.architecture:
        return CompositionType.symmetry;
      case SceneMode.food:
        return CompositionType.centerFrame;
      case SceneMode.street:
        return CompositionType.leadingLines;
      case SceneMode.action:
        return CompositionType.diagonal;
      case SceneMode.macro:
        return CompositionType.goldenSpiral;
    }
  }
}
