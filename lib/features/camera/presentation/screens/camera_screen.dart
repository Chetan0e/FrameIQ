import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/enums/scene_mode.dart';
import '../painters/composition_painter.dart';
import '../widgets/hud_bar.dart';
import '../widgets/mode_selector.dart';
import '../widgets/score_meter.dart';
import '../widgets/shutter_button.dart';
import '../widgets/suggestion_strip.dart';
import 'camera_controller_provider.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late AnimationController _overlayAnimCtrl;
  late Animation<double> _overlayFade;

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
    super.dispose();
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

    ref.listen(overlayOpacityProvider, (prev, next) {
      if (next > (prev ?? 0)) {
        _overlayAnimCtrl.forward();
      } else if (next <= 0.01) {
        _overlayAnimCtrl.reverse();
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: cameraAsync.when(
        loading: () => const _LoadingView(),
        error: (e, _) => _ErrorView(error: e.toString()),
        data: (controller) {
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
                    cameraPreviewSize: controller.value.previewSize != null
                        ? Size(controller.value.previewSize!.height,
                            controller.value.previewSize!.width)
                        : null,
                  ),
                ),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 100,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: HudBar(
                  scene: ref.watch(manualSceneModeProvider) ??
                      analysis.detectedScene,
                  onFlip: () => ref
                      .read(cameraControllerProvider.notifier)
                      .flipCamera(),
                ),
              ),

              Positioned(
                left: 16,
                top: MediaQuery.of(context).size.height * 0.25,
                child: ScoreMeter(score: analysis.compositionScore),
              ),

              Positioned(
                bottom: 140,
                left: 16,
                right: 16,
                child: SuggestionStrip(suggestions: analysis.suggestions),
              ),

              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: ModeSelector(
                  currentScene: ref.watch(manualSceneModeProvider) ??
                      analysis.detectedScene,
                  onModeSelected: (mode) {
                    ref.read(manualSceneModeProvider.notifier).state =
                        mode == SceneMode.auto ? null : mode;
                  },
                ),
              ),

              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: ShutterRow(
                  onCapture: () => _capture(controller),
                  onFlip: () => ref
                      .read(cameraControllerProvider.notifier)
                      .flipCamera(),
                ),
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
            ],
          );
        },
      ),
    );
  }

  Future<void> _capture(CameraController controller) async {
    ref.read(shutterFlashProvider.notifier).state = true;
    HapticFeedback.heavyImpact();
    final file =
        await ref.read(cameraControllerProvider.notifier).capture();
    await Future.delayed(const Duration(milliseconds: 120));
    if (mounted) {
      ref.read(shutterFlashProvider.notifier).state = false;
    }
    if (file != null && mounted) {
      // Save image to device gallery
      final result = await ImageGallerySaver.saveFile(file.path);
      final isSuccess = result['isSuccess'] ?? false;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSuccess ? 'Saved to gallery' : 'Failed to save'),
          backgroundColor: isSuccess ? AppColors.card : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.accent),
            SizedBox(height: 16),
            Text(
              'Warming up camera…',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
          ],
        ),
      );
}

class _ErrorView extends StatelessWidget {
  final String error;
  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_outlined,
                  color: AppColors.accent2, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Camera unavailable',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}
