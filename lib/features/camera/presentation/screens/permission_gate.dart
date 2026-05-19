import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_colors.dart';
import 'camera_screen.dart';

/// Requests camera (and photo) permissions with a rationale before opening the camera.
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

    var camera = await Permission.camera.status;
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
        return const Scaffold(
          backgroundColor: AppColors.bg,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        );
      case _GateState.granted:
        return const CameraScreen();
      case _GateState.rationale:
        return _RationaleView(onContinue: _requestPermissions);
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

class _RationaleView extends StatelessWidget {
  final VoidCallback onContinue;

  const _RationaleView({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Text(
                'Real-time coaching',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'FrameIQ uses your camera to overlay composition guides and '
                'give live tips while you shoot. We only process frames on '
                'your device — nothing is uploaded unless you enable AI tips.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onContinue,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.bg,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_outlined,
                  color: AppColors.accent2, size: 56),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.bg,
                ),
                child: const Text('Try again'),
              ),
              TextButton(
                onPressed: onOpenSettings,
                child: const Text('Open settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
