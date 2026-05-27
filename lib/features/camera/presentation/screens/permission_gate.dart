import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import 'camera_screen.dart';

class PermissionGate extends StatefulWidget {
  const PermissionGate({super.key});

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  _GateState _state = _GateState.checking;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _state = _GateState.checking;
      _error = null;
    });

    final camera = await Permission.camera.status;
    if (camera.isGranted) {
      setState(() => _state = _GateState.granted);
      return;
    }

    if (camera.isPermanentlyDenied) {
      setState(() {
        _state = _GateState.denied;
        _error = 'Camera access is blocked. Enable it in system settings.';
      });
      return;
    }

    setState(() => _state = _GateState.rationale);
  }

  Future<void> _requestPermissions() async {
    final results = await [Permission.camera, Permission.photos].request();
    final camera = results[Permission.camera] ?? PermissionStatus.denied;

    if (camera.isGranted) {
      setState(() => _state = _GateState.granted);
      return;
    }

    if (camera.isPermanentlyDenied) {
      setState(() {
        _state = _GateState.denied;
        _error = 'Camera access is blocked. Enable it in system settings.';
      });
      return;
    }

    setState(() {
      _state = _GateState.denied;
      _error = 'FrameIQ needs camera access to coach your shots in real time.';
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case _GateState.checking:
        return const _SplashView();
      case _GateState.granted:
        return const CameraScreen();
      case _GateState.rationale:
        return _OnboardingView(onContinue: _requestPermissions);
      case _GateState.denied:
        return _DeniedView(
          message: _error ?? 'Camera permission is required.',
          onRetry: _checkPermissions,
          onOpenSettings: openAppSettings,
        );
    }
  }
}

enum _GateState { checking, rationale, granted, denied }

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _LogoBadge(size: 64),
            const SizedBox(height: 24),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
                children: [
                  TextSpan(
                    style: TextStyle(color: AppColors.textPrimary),
                    text: 'Frame',
                  ),
                  TextSpan(
                    style: TextStyle(color: AppColors.accent),
                    text: 'IQ',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  final VoidCallback onContinue;

  const _OnboardingView({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _LogoBadge(size: 52),
              const SizedBox(height: 28),
              Text(
                'Shoot smarter,\nnot harder',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Live composition guides, posture hints, and coaching tips — '
                'processed on your device.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              const _FeatureRow(
                icon: Icons.grid_3x3_rounded,
                title: 'Composition overlays',
                subtitle: 'Rule of thirds, symmetry, and more',
              ),
              const SizedBox(height: 14),
              const _FeatureRow(
                icon: Icons.face_retouching_natural_rounded,
                title: 'Selfie posture guides',
                subtitle: 'Ghost outlines matched to your background',
              ),
              const SizedBox(height: 14),
              const _FeatureRow(
                icon: Icons.insights_rounded,
                title: 'Live score & tips',
                subtitle: 'Know when your frame is ready',
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Enable camera',
                onPressed: onContinue,
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Photos stay on your device unless you enable cloud AI.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeniedView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  const _DeniedView({
    required this.message,
    required this.onRetry,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accent2.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.no_photography_outlined,
                  color: AppColors.accent2,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Camera access needed',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              PrimaryButton(label: 'Try again', onPressed: onRetry),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onOpenSettings,
                child: const Text('Open system settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  final double size;

  const _LogoBadge({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accent, Color(0xFFB8E020)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.camera_enhance_rounded,
        color: AppColors.bg,
        size: size * 0.5,
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 14,
      blur: false,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
