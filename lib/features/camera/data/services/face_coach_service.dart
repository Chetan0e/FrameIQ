import 'dart:ui' show Rect, Size;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../../../shared/utils/camera_input_image.dart';
import '../../domain/models/coaching_suggestion.dart';

class FaceCoachResult {
  final bool faceDetected;
  final List<CoachingSuggestion> suggestions;
  final double score;
  final Rect? faceRect;

  const FaceCoachResult({
    required this.faceDetected,
    required this.suggestions,
    required this.score,
    this.faceRect,
  });
}

/// Detects faces and generates portrait-specific coaching suggestions.
class FaceCoachService {
  late final FaceDetector _detector;
  bool _isBusy = false;
  bool _isInitialized = false;

  Future<void> initialize() async {
    _detector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        enableContours: false,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
    _isInitialized = true;
    debugPrint('[FaceCoach] initialized');
  }

  Future<FaceCoachResult> analyze(
    CameraImage image,
    InputImageRotation rotation,
    Size previewSize,
  ) async {
    if (!_isInitialized || _isBusy) {
      return const FaceCoachResult(
        faceDetected: false,
        suggestions: [],
        score: 50,
      );
    }
    _isBusy = true;

    try {
      final inputImage = cameraImageToInputImage(image, rotation);
      final faces = await _detector.processImage(inputImage);

      if (faces.isEmpty) {
        return const FaceCoachResult(
          faceDetected: false,
          suggestions: [
            CoachingSuggestion(
              type: SuggestionType.info,
              label: 'FRAMING',
              message: 'No face detected — move closer or adjust angle',
              emoji: '👤',
            ),
          ],
          score: 40,
        );
      }

      final face = faces.first;
      final suggestions = <CoachingSuggestion>[];
      double score = 100.0;

      final tiltZ = face.headEulerAngleZ ?? 0;
      if (tiltZ.abs() > 15) {
        suggestions.add(CoachingSuggestion(
          type: SuggestionType.warn,
          label: 'HEAD TILT',
          message: tiltZ > 0
              ? 'Tilt head slightly right to level up'
              : 'Tilt head slightly left to level up',
          emoji: '↕️',
        ));
        score -= 12;
      }

      final yaw = face.headEulerAngleY ?? 0;
      if (yaw.abs() > 30) {
        suggestions.add(const CoachingSuggestion(
          type: SuggestionType.warn,
          label: 'FACE ANGLE',
          message: 'Turn face more toward camera',
          emoji: '↔️',
        ));
        score -= 10;
      }

      final faceTop = face.boundingBox.top / previewSize.height;
      if (faceTop > 0.5) {
        suggestions.add(const CoachingSuggestion(
          type: SuggestionType.info,
          label: 'POSITION',
          message: 'Move camera up — face should be in upper third',
          emoji: '⬆️',
        ));
        score -= 15;
      }

      final faceWidthRatio = face.boundingBox.width / previewSize.width;
      if (faceWidthRatio < 0.15) {
        suggestions.add(const CoachingSuggestion(
          type: SuggestionType.info,
          label: 'DISTANCE',
          message: 'Too far — move closer to subject',
          emoji: '🔍',
        ));
        score -= 8;
      } else if (faceWidthRatio > 0.75) {
        suggestions.add(const CoachingSuggestion(
          type: SuggestionType.warn,
          label: 'DISTANCE',
          message: 'Too close — back up for a natural portrait',
          emoji: '↩️',
        ));
        score -= 8;
      }

      final leftEye = face.leftEyeOpenProbability ?? 1.0;
      final rightEye = face.rightEyeOpenProbability ?? 1.0;
      if (leftEye < 0.4 || rightEye < 0.4) {
        suggestions.add(const CoachingSuggestion(
          type: SuggestionType.warn,
          label: 'EYES',
          message: 'Eyes look closed — ask subject to open eyes',
          emoji: '👁️',
        ));
        score -= 15;
      }

      if (suggestions.isEmpty) {
        suggestions.add(const CoachingSuggestion(
          type: SuggestionType.good,
          label: 'PORTRAIT',
          message: 'Great framing — tap shutter now!',
          emoji: '✅',
        ));
      }

      final normRect = Rect.fromLTWH(
        face.boundingBox.left / previewSize.width,
        face.boundingBox.top / previewSize.height,
        face.boundingBox.width / previewSize.width,
        face.boundingBox.height / previewSize.height,
      );

      return FaceCoachResult(
        faceDetected: true,
        suggestions: suggestions,
        score: score.clamp(0, 100),
        faceRect: normRect,
      );
    } catch (e) {
      debugPrint('[FaceCoach] error: $e');
      return const FaceCoachResult(
        faceDetected: false,
        suggestions: [],
        score: 50,
      );
    } finally {
      _isBusy = false;
    }
  }

  void dispose() => _detector.close();
}
