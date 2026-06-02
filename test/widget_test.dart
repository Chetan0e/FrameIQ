import 'package:flutter_test/flutter_test.dart';
import 'package:frameiq/features/coaching/engine/coaching_engine.dart';
import 'package:frameiq/features/camera/domain/enums/scene_mode.dart';
import 'package:frameiq/features/camera/data/services/face_coach_service.dart';
import 'package:frameiq/features/camera/domain/enums/composition_type.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  group('CoachingEngine Unit Tests', () {
    late CoachingEngine engine;

    setUp(() {
      engine = CoachingEngine();
    });

    test('Initial accelerometer yields zero tilt', () {
      expect(engine.horizonTiltDeg, 0.0);
      expect(engine.isDeviceStill, false);
    });

    test('Accelerometer roll calculation matches gravity vector', () {
      // roll = -atan2(x, y) * 180 / pi
      // For x = 1.0, y = 1.0: -atan2(1, 1) = -45 deg
      engine.updateAccelerometer(AccelerometerEvent(1.0, 1.0, 9.8));
      expect(engine.horizonTiltDeg, closeTo(-45.0, 0.01));
    });

    test('Device stillness increases with micro accelerometer movements', () {
      // Send small movements to simulate still hold
      for (int i = 0; i < 45; i++) {
        engine.updateAccelerometer(AccelerometerEvent(0.01, 0.01, 9.8));
      }
      expect(engine.isDeviceStill, true);
    });

    test('Assemble generates appropriate suggestions and scores for level shot', () {
      // Level shot
      engine.updateAccelerometer(AccelerometerEvent(0, 9.8, 0));
      
      final analysis = engine.assemble(
        scene: SceneMode.landscape,
        backgroundScene: SceneMode.portrait,
        faceResult: null,
        isFrontCamera: false,
      );

      expect(analysis.horizonTiltDeg, 0.0);
      expect(analysis.recommendedComposition, CompositionType.ruleOfThirds);
      // Perfect tilt adds +5 score (70 base + 5 = 75)
      expect(analysis.compositionScore, 75.0);
    });

    test('Assemble penalizes tilted camera and adds horizon warning', () {
      // Tilted camera (x=1.5, y=9.8 -> roll angle is around -8.7 degrees)
      engine.updateAccelerometer(AccelerometerEvent(1.5, 9.8, 0));

      final analysis = engine.assemble(
        scene: SceneMode.landscape,
        backgroundScene: SceneMode.portrait,
        faceResult: null,
        isFrontCamera: false,
      );

      // Warning should be added
      final hasHorizonWarning = analysis.suggestions.any((s) => s.label == 'HORIZON');
      expect(hasHorizonWarning, true);
      // Score should be reduced
      expect(analysis.compositionScore, lessThan(70.0));
    });

    test('Assemble integrates FaceCoachResult correctly', () {
      engine.updateAccelerometer(AccelerometerEvent(0, 9.8, 0)); // level

      const faceResult = FaceCoachResult(
        faceDetected: true,
        suggestions: [],
        score: 95.0,
      );

      final analysis = engine.assemble(
        scene: SceneMode.portrait,
        backgroundScene: SceneMode.portrait,
        faceResult: faceResult,
        isFrontCamera: false,
      );

      expect(analysis.faceDetected, true);
      // Score path: (75 base+level_bonus + 95 face) / 2 = 85,
      // then +10 clean-frame bonus (no warnings in suggestions) = 95
      expect(analysis.compositionScore, 95.0);
    });
  });
}
