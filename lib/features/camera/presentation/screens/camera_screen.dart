import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/enums/scene_mode.dart';
import '../painters/composition_painter.dart';
import '../widgets/camera_bottom_bar.dart';
import '../widgets/hud_bar.dart';
import '../widgets/score_meter.dart';
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
    final manualMode = ref.watch(manualSceneModeProvider);
    final isAutoMode = manualMode == null;

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
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 120,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.75),
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
                onCapture: () => _capture(controller),
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
            ],
          );
        },
      ),
    );
  }

  Future<void> _capture(CameraController controller) async {
    HapticFeedback.heavyImpact();
    final file =
        await ref.read(cameraControllerProvider.notifier).capture();

    if (!mounted || file == null) return;

    ref.read(shutterFlashProvider.notifier).state = true;
    await Future.delayed(const Duration(milliseconds: 80));
    if (mounted) {
      ref.read(shutterFlashProvider.notifier).state = false;
    }

    final result = await ImageGallerySaver.saveFile(file.path);
    if (!mounted) return;

    final isSuccess = result['isSuccess'] == true;
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
                isSuccess ? 'Photo saved to gallery' : 'Could not save photo',
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.card,
        duration: const Duration(seconds: 2),
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
