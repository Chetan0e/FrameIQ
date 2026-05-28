import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../main.dart';
import '../../../../shared/utils/camera_input_image.dart';
import '../../../coaching/engine/coaching_engine.dart';
import '../../data/services/face_coach_service.dart';
import '../../data/services/scene_detector_service.dart';
import '../../domain/enums/scene_mode.dart';
import '../../domain/models/frame_analysis.dart';

final cameraControllerProvider =
    AsyncNotifierProvider<CameraControllerNotifier, CameraController>(
  CameraControllerNotifier.new,
);

final frameAnalysisProvider =
    StateNotifierProvider<FrameAnalysisNotifier, FrameAnalysis>(
  (ref) => FrameAnalysisNotifier(),
);

final manualSceneModeProvider = StateProvider<SceneMode?>((ref) => null);

final overlayOpacityProvider = StateProvider<double>((ref) => 0.55);

final autoOpacityProvider = StateProvider<bool>((ref) => true);

final shutterFlashProvider = StateProvider<bool>((ref) => false);

final deviceStillProvider = StateProvider<bool>((ref) => false);
final smartCaptureProvider = StateProvider<bool>((ref) => false);
final compositionLockProvider = StateProvider<bool>((ref) => false);

class CameraControllerNotifier extends AsyncNotifier<CameraController> {
  late SceneDetectorService _sceneDetector;
  late FaceCoachService _faceCoach;
  late CoachingEngine _engine;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  bool _isProcessingScene = false;
  bool _isProcessingPose = false;
  int _cameraIndex = 0;
  DateTime? _lastSceneAt;
  DateTime? _lastPoseAt;
  CameraDescription? _activeCamera;

  @override
  Future<CameraController> build() async {
    ref.onDispose(_cleanup);
    return _initCamera();
  }

  Future<CameraController> _initCamera() async {
    if (cameras.isEmpty) {
      throw CameraException(
        'no_camera',
        'No cameras found on this device',
      );
    }

    _sceneDetector = SceneDetectorService();
    _faceCoach = FaceCoachService();
    _engine = CoachingEngine();

    await _sceneDetector.initialize();
    await _faceCoach.initialize();

    _cameraIndex = 0;
    _activeCamera = cameras[_cameraIndex];

    final controller = CameraController(
      _activeCamera!,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: imageFormatGroupForPlatform(),
    );
    await controller.initialize();

    _startAccelerometer();
    _startImageStream(controller);

    return controller;
  }

  void _startAccelerometer() {
    _accelSub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 100),
    ).listen((event) {
      _engine.updateAccelerometer(event);
      ref.read(deviceStillProvider.notifier).state = _engine.isDeviceStill;

      final tilt = _engine.horizonTiltDeg;
      ref.read(frameAnalysisProvider.notifier).updateTilt(tilt);

      if (ref.read(autoOpacityProvider)) {
        final analysis = ref.read(frameAnalysisProvider);
        final wellComposed = analysis.compositionScore >= 85 &&
            analysis.horizonTiltDeg.abs() < 1.5;
        final base = wellComposed ? 0.4 : AppConstants.overlayOpacityActive;
        final opacity = _engine.isDeviceStill ? 0.0 : base;
        ref.read(overlayOpacityProvider.notifier).state = opacity;
      }
    });
  }

  void _startImageStream(CameraController controller) {
    controller.startImageStream((image) {
      if (ref.read(compositionLockProvider)) return;

      final camera = _activeCamera ?? cameras[_cameraIndex];
      final rotation = rotationFromSensorOrientation(camera.sensorOrientation);
      final manualScene = ref.read(manualSceneModeProvider);
      final now = DateTime.now();

      if (!_isProcessingScene &&
          (_lastSceneAt == null ||
              now.difference(_lastSceneAt!).inMilliseconds >=
                  AppConstants.sceneDetectionIntervalMs)) {
        _isProcessingScene = true;
        _lastSceneAt = now;
        Future(() async {
          try {
            final scene = manualScene ??
                await _sceneDetector.detectScene(image, rotation);
            ref.read(frameAnalysisProvider.notifier).updateScene(scene);
          } finally {
            _isProcessingScene = false;
          }
        });
      }

      if (!_isProcessingPose &&
          (_lastPoseAt == null ||
              now.difference(_lastPoseAt!).inMilliseconds >=
                  AppConstants.poseDetectionIntervalMs)) {
        _isProcessingPose = true;
        _lastPoseAt = now;
        Future(() async {
          try {
            final previewSize = Size(
              image.width.toDouble(),
              image.height.toDouble(),
            );
            final faceResult =
                await _faceCoach.analyze(image, rotation, previewSize);
            final detected =
                ref.read(frameAnalysisProvider).detectedScene;
            final manual = ref.read(manualSceneModeProvider);
            final isFront =
                camera.lensDirection == CameraLensDirection.front;
            final sceneForCoaching = manual ??
                (isFront ? SceneMode.selfie : detected);
            final backgroundScene = _postureBackgroundScene(detected);
            final analysis = _engine.assemble(
              scene: sceneForCoaching,
              backgroundScene: backgroundScene,
              faceResult: faceResult,
              isFrontCamera: isFront,
            );
            ref.read(frameAnalysisProvider.notifier).update(analysis);
          } finally {
            _isProcessingPose = false;
          }
        });
      }
    });
  }

  Future<void> flipCamera() async {
    final ctrl = state.valueOrNull;
    if (ctrl == null || cameras.length < 2) return;

    state = const AsyncValue.loading();
    await ctrl.stopImageStream();
    await ctrl.dispose();

    _cameraIndex = (_cameraIndex + 1) % cameras.length;
    _activeCamera = cameras[_cameraIndex];

    final newCtrl = CameraController(
      _activeCamera!,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: imageFormatGroupForPlatform(),
    );
    await newCtrl.initialize();
    _startImageStream(newCtrl);
    state = AsyncValue.data(newCtrl);
  }

  Future<XFile?> capture() async {
    final ctrl = state.valueOrNull;
    if (ctrl == null || !ctrl.value.isInitialized) return null;
    try {
      await ctrl.stopImageStream();
      final file = await ctrl.takePicture();
      _startImageStream(ctrl);
      return file;
    } catch (e) {
      debugPrint('${AppConstants.tag}: capture error $e');
      return null;
    }
  }

  void resumeImageStream() {
    final ctrl = state.valueOrNull;
    if (ctrl != null && !ctrl.value.isStreamingImages) {
      _startImageStream(ctrl);
    }
  }

  static SceneMode _postureBackgroundScene(SceneMode detected) {
    switch (detected) {
      case SceneMode.auto:
      case SceneMode.selfie:
        return SceneMode.portrait;
      default:
        return detected;
    }
  }

  void _cleanup() {
    _accelSub?.cancel();
    _sceneDetector.dispose();
    _faceCoach.dispose();
    state.valueOrNull?.dispose();
  }
}

class FrameAnalysisNotifier extends StateNotifier<FrameAnalysis> {
  FrameAnalysisNotifier() : super(FrameAnalysis.initial());

  void update(FrameAnalysis analysis) {
    final smoothedScore = state.compositionScore +
        (analysis.compositionScore - state.compositionScore) *
            AppConstants.scoreSmoothing;

    state = analysis.copyWith(compositionScore: smoothedScore);
  }

  void updateScene(SceneMode scene) {
    state = state.copyWith(detectedScene: scene);
  }

  void updateTilt(double tiltDeg) {
    state = state.copyWith(horizonTiltDeg: tiltDeg);
  }
}
