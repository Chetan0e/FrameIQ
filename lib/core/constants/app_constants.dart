class AppConstants {
  AppConstants._();

  static const String tag = 'FrameIQ';
  static const String appName = 'FrameIQ';

  // OpenRouter
  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1';
  static const String openRouterModel = 'google/gemini-flash-1.5';

  // Coaching thresholds
  static const double goodScoreThreshold = 80.0;
  static const double okScoreThreshold = 60.0;

  // Composition overlay opacity
  static const double overlayOpacityActive = 0.55;
  static const double overlayOpacityFade = 0.0;
  static const Duration overlayFadeDuration = Duration(milliseconds: 600);

  // Auto-hide overlay after this long without movement
  static const Duration overlayAutoHide = Duration(seconds: 4);

  // How often we re-run scene detection (ms)
  static const int sceneDetectionIntervalMs = 1200;

  // How often we re-run face/pose detection (ms)
  static const int poseDetectionIntervalMs = 400;

  // Score smoothing factor (0–1, higher = snappier)
  static const double scoreSmoothing = 0.25;

  // Tilt threshold in degrees before we warn
  static const double horizonTiltThreshold = 2.5;
}
