import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Full immersive mode — black status bar for camera feel
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
    ),
  );

  // Keep screen awake during camera use
  await WakelockPlus.enable();

  // Discover cameras
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint('${AppConstants.tag}: Camera init error: $e');
  }

  runApp(
    const ProviderScope(
      child: FrameIQApp(),
    ),
  );
}
