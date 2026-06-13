import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/settings/settings_provider.dart';
import '../../domain/enums/scene_mode.dart';
import '../../domain/models/frame_analysis.dart';
import '../painters/composition_painter.dart';
import '../widgets/camera_bottom_bar.dart';
import '../widgets/hud_bar.dart';
import '../widgets/score_meter.dart';
import 'camera_controller_provider.dart';
import '../../../gallery/presentation/controllers/gallery_notifier.dart';
import '../../../coaching/domain/models/challenge.dart';
import '../../../coaching/presentation/controllers/challenges_notifier.dart';
import '../../../../core/widgets/glass_container.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late AnimationController _overlayAnimCtrl;
  late Animation<double> _overlayFade;
  Timer? _smartCaptureTimer;
  bool _isCapturing = false;
  int _smartCountdown = 0;
  Challenge? _recentlyUnlockedChallenge;
  Timer? _toastDismissTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _overlayAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _overlayFade = CurvedAnimation(
      parent: _overlayAnimCtrl,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _overlayAnimCtrl.dispose();
    _smartCaptureTimer?.cancel();
    _toastDismissTimer?.cancel();
    super.dispose();
  }

  void _showChallengeCompletedToast(Challenge challenge) {
    _toastDismissTimer?.cancel();
    setState(() {
      _recentlyUnlockedChallenge = challenge;
    });
    // Haptic feedback
    HapticFeedback.mediumImpact();
    // Dismiss after 3.5 seconds
    _toastDismissTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() {
          _recentlyUnlockedChallenge = null;
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      final ctrl = ref.read(cameraControllerProvider).valueOrNull;
      ctrl?.stopImageStream();
    } else if (state == AppLifecycleState.resumed) {
      final ctrl = ref.read(cameraControllerProvider).valueOrNull;
      if (ctrl != null && !ctrl.value.isStreamingImages) {
        ref.read(cameraControllerProvider.notifier).resumeImageStream();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraAsync = ref.watch(cameraControllerProvider);
    final analysis = ref.watch(frameAnalysisProvider);
    final overlayBase = ref.watch(overlayOpacityProvider);
    final manualMode = ref.watch(manualSceneModeProvider);
    final isAutoMode = manualMode == null;
    final smartCaptureEnabled = ref.watch(smartCaptureProvider);
    final isStill = ref.watch(deviceStillProvider);

    ref.listen(overlayOpacityProvider, (prev, next) {
      if (next > (prev ?? 0)) {
        _overlayAnimCtrl.forward();
      } else if (next <= 0.01) {
        _overlayAnimCtrl.reverse();
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: cameraAsync.when(
        loading: () => const _LoadingView(),
        error: (e, _) => _ErrorView(error: e.toString()),
        data: (controller) {
          _maybeHandleSmartCapture(
            analysis: analysis,
            enabled: smartCaptureEnabled,
            isStill: isStill,
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              _CameraPreview(controller: controller),

              AnimatedBuilder(
                animation: _overlayFade,
                builder: (_, __) => CustomPaint(
                  painter: CompositionPainter(
                    type: analysis.recommendedComposition,
                    opacity: _overlayFade.value * overlayBase,
                    horizonTiltDeg: analysis.horizonTiltDeg,
                    faceRect: analysis.faceRect,
                    postureGuide: analysis.postureGuide,
                    cameraPreviewSize: controller.value.previewSize != null
                        ? Size(
                            controller.value.previewSize!.height,
                            controller.value.previewSize!.width,
                          )
                        : null,
                  ),
                ),
              ),

              // Top vignette
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 120,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                ),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: HudBar(
                  scene: manualMode ?? SceneMode.auto,
                  isAutoMode: isAutoMode,
                  detectedScene: analysis.detectedScene,
                ),
              ),

              Positioned(
                left: 12,
                top: MediaQuery.paddingOf(context).top + 72,
                child: ScoreMeter(score: analysis.compositionScore),
              ),
              CameraBottomBar(
                suggestions: analysis.suggestions,
                isAutoMode: isAutoMode,
                manualMode: manualMode,
                onModeSelected: (mode) {
                  ref.read(manualSceneModeProvider.notifier).state =
                      mode == SceneMode.auto ? null : mode;
                },
                onCapture: () => _capture(),
                onFlip: () => ref
                    .read(cameraControllerProvider.notifier)
                    .flipCamera(),
              ),

              Consumer(
                builder: (_, ref, __) {
                  final flash = ref.watch(shutterFlashProvider);
                  return IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: flash ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 80),
                      child: const ColoredBox(color: Colors.white),
                    ),
                  );
                },
              ),
              if (_smartCountdown > 0)
                _SmartCaptureCountdown(value: _smartCountdown),
              if (_recentlyUnlockedChallenge != null)
                _ChallengeCompletedToast(
                  challenge: _recentlyUnlockedChallenge!,
                  onDismiss: () {
                    setState(() {
                      _recentlyUnlockedChallenge = null;
                    });
                  },
                ),
            ],
          );
        },
      ),
    );
  }
  Future<void> _capture() async {
    if (_isCapturing) return;
    _isCapturing = true;
    try {
      HapticFeedback.heavyImpact();
      final file =
          await ref.read(cameraControllerProvider.notifier).capture();

      if (!mounted || file == null) return;

      ref.read(shutterFlashProvider.notifier).state = true;
      await Future.delayed(const Duration(milliseconds: 80));
      if (mounted) {
        ref.read(shutterFlashProvider.notifier).state = false;
      }

      // Save to local coached gallery
      final analysis = ref.read(frameAnalysisProvider);
      final savedPhoto = await ref.read(galleryNotifierProvider.notifier).savePhoto(
            file: file,
            score: analysis.compositionScore,
            sceneMode: analysis.detectedScene,
            compositionType: analysis.recommendedComposition,
            suggestions: analysis.suggestions.map((s) => s.message).toList(),
          );

      // Check challenges completion
      final unlockedChallenge = await ref.read(challengesProvider.notifier).checkAndUnlockChallenge(
            photo: savedPhoto,
            actualTilt: analysis.horizonTiltDeg,
            faceDetected: analysis.faceDetected,
          );

      if (unlockedChallenge != null && mounted) {
        _showChallengeCompletedToast(unlockedChallenge);
      }

      bool isSuccess = false;
      try {
        await Gal.putImage(file.path);
        isSuccess = true;
      } catch (e) {
        debugPrint('Failed to save to gallery: $e');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle_rounded : Icons.error_outline,
                color: isSuccess ? AppColors.success : AppColors.accent2,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isSuccess
                      ? 'Photo saved to gallery'
                      : 'Could not save photo',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.card,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      _isCapturing = false;
    }
  }

  void _maybeHandleSmartCapture({
    required FrameAnalysis analysis,
    required bool enabled,
    required bool isStill,
  }) {
    if (!enabled || _isCapturing) {
      _cancelSmartCapture();
      return;
    }

    final settings = ref.read(settingsProvider);
    final minScore = settings.smartCaptureMinScore;
    final ready = isStill &&
        analysis.compositionScore >= minScore &&
        analysis.horizonTiltDeg.abs() < 1.2;
    if (!ready) {
      _cancelSmartCapture();
      return;
    }

    if (_smartCaptureTimer != null || _smartCountdown > 0) return;
    if (mounted) setState(() => _smartCountdown = 2);

    _smartCaptureTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        _smartCaptureTimer = null;
        return;
      }
      if (_smartCountdown > 1) {
        setState(() => _smartCountdown -= 1);
        return;
      }

      timer.cancel();
      _smartCaptureTimer = null;
      setState(() => _smartCountdown = 0);
      _capture();
    });
  }

  void _cancelSmartCapture() {
    _smartCaptureTimer?.cancel();
    _smartCaptureTimer = null;
    if (_smartCountdown != 0 && mounted) {
      setState(() => _smartCountdown = 0);
    }
  }
}

class _SmartCaptureCountdown extends StatelessWidget {
  final int value;
  const _SmartCaptureCountdown({required this.value});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
          ),
          alignment: Alignment.center,
          child: Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _CameraPreview extends StatelessWidget {
  final CameraController controller;

  const _CameraPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize?.height ?? 1080,
          height: controller.value.previewSize?.width ?? 1920,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: const CircularProgressIndicator(
              color: AppColors.accent,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Starting camera…',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.accent2.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.videocam_off_outlined,
              color: AppColors.accent2,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Camera unavailable',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ChallengeCompletedToast extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onDismiss;

  const _ChallengeCompletedToast({
    required this.challenge,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 72,
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: onDismiss,
        child: GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.6), width: 1.5),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'QUEST COMPLETED!',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      challenge.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+${challenge.xpReward} XP',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          .animate()
          .scale(begin: const Offset(0.9, 0.9), duration: 250.ms, curve: Curves.easeOutBack)
          .fadeIn(duration: 200.ms)
          .then(delay: 2800.ms)
          .slideY(end: -0.3, duration: 400.ms, curve: Curves.easeIn)
          .fadeOut(duration: 350.ms),
    );
  }
}
