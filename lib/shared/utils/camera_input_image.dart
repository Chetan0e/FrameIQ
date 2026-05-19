import 'dart:io' show Platform;
import 'dart:ui' show Size;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

/// Builds an [InputImage] from a camera stream frame with correct format per platform.
InputImage cameraImageToInputImage(
  CameraImage image,
  InputImageRotation rotation,
) {
  final WriteBuffer allBytes = WriteBuffer();
  for (final plane in image.planes) {
    allBytes.putUint8List(plane.bytes);
  }
  final bytes = allBytes.done().buffer.asUint8List();

  final format =
      Platform.isIOS ? InputImageFormat.bgra8888 : InputImageFormat.nv21;

  return InputImage.fromBytes(
    bytes: bytes,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes[0].bytesPerRow,
    ),
  );
}

ImageFormatGroup imageFormatGroupForPlatform() =>
    Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.nv21;

InputImageRotation rotationFromSensorOrientation(int sensorOrientation) {
  switch (sensorOrientation) {
    case 90:
      return InputImageRotation.rotation90deg;
    case 180:
      return InputImageRotation.rotation180deg;
    case 270:
      return InputImageRotation.rotation270deg;
    default:
      return InputImageRotation.rotation0deg;
  }
}
