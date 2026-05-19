import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/camera/presentation/screens/permission_gate.dart';

class FrameIQApp extends ConsumerWidget {
  const FrameIQApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'FrameIQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const PermissionGate(),
    );
  }
}
