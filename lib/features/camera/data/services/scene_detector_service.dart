import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

import '../../../../shared/utils/camera_input_image.dart';
import '../../domain/enums/scene_mode.dart';

/// Uses ML Kit Image Labeling to classify the scene from a camera frame.
class SceneDetectorService {
  late final ImageLabeler _labeler;
  bool _isBusy = false;
  bool _isInitialized = false;

  Future<void> initialize() async {
    final options = ImageLabelerOptions(confidenceThreshold: 0.55);
    _labeler = ImageLabeler(options: options);
    _isInitialized = true;
    debugPrint('[SceneDetector] initialized');
  }

  Future<SceneMode> detectScene(
    CameraImage image,
    InputImageRotation rotation,
  ) async {
    if (!_isInitialized || _isBusy) return SceneMode.auto;
    _isBusy = true;

    try {
      final inputImage = cameraImageToInputImage(image, rotation);
      final labels = await _labeler.processImage(inputImage);

      if (labels.isEmpty) return SceneMode.auto;

      labels.sort((a, b) => b.confidence.compareTo(a.confidence));

      final scores = <SceneMode, double>{};
      for (final mode in SceneMode.values) {
        if (mode == SceneMode.auto) continue;
        double score = 0;
        for (final label in labels) {
          final text = label.label.toLowerCase();
          for (final keyword in mode.mlKeywords) {
            if (text.contains(keyword.toLowerCase())) {
              score += label.confidence;
              break;
            }
          }
        }
        scores[mode] = score;
      }

      final best = scores.entries.where((e) => e.value > 0.5).toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return best.isEmpty ? SceneMode.auto : best.first.key;
    } catch (e) {
      debugPrint('[SceneDetector] error: $e');
      return SceneMode.auto;
    } finally {
      _isBusy = false;
    }
  }

  void dispose() => _labeler.close();
}
