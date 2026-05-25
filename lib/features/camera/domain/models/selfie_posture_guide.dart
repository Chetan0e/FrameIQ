import 'dart:ui' show Offset;

/// Background-aware selfie framing hint drawn on the live preview.
enum SelfiePostureStyle {
  /// Face on a rule-of-thirds power point; show more environment.
  environmental,

  /// Face near vertical center — buildings, symmetry.
  symmetryCenter,

  /// Face on the open side of the frame (away from current position).
  offCenterThirds,

  /// Centered upper-body framing for close scenes (food, macro).
  casualCenter,

  /// Slight diagonal body line for street/action energy.
  dynamicDiagonal,
}

class SelfiePostureGuide {
  /// Normalized target for the center of the head (0–1 in preview space).
  final Offset targetHeadCenter;

  final SelfiePostureStyle style;

  const SelfiePostureGuide({
    required this.targetHeadCenter,
    required this.style,
  });
}
