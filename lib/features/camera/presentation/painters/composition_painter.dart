import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/enums/composition_type.dart';
import '../../domain/models/selfie_posture_guide.dart';

/// CustomPainter that draws all composition overlays on the live camera preview.
/// Rendered at 60fps — all painting must be extremely lightweight.
class CompositionPainter extends CustomPainter {
  final CompositionType type;
  final double opacity;
  final double horizonTiltDeg;
  final Rect? faceRect;
  final SelfiePostureGuide? postureGuide;
  final Size? cameraPreviewSize;

  final Paint _gridPaint = Paint()..style = PaintingStyle.stroke;
  final Paint _gridDotPaint = Paint()..style = PaintingStyle.fill;
  final Paint _gridRingPaint = Paint()..style = PaintingStyle.stroke;
  final Paint _spiralPaint = Paint()..style = PaintingStyle.stroke;
  final Paint _spiralDotPaint = Paint()..style = PaintingStyle.fill;
  final Paint _symmetryPaint = Paint()..style = PaintingStyle.stroke;
  final Paint _leadingPaint = Paint()..style = PaintingStyle.stroke;
  final Paint _leadingDotPaint = Paint()..style = PaintingStyle.fill;
  final Paint _diagonalPaint = Paint()..style = PaintingStyle.stroke;
  final Paint _centerPaint = Paint()..style = PaintingStyle.stroke;
  final Paint _horizonPaint = Paint()..style = PaintingStyle.stroke;
  final Paint _horizonDotPaint = Paint()..style = PaintingStyle.fill;
  final Paint _facePaint = Paint()..style = PaintingStyle.stroke;
  final Paint _posturePaint = Paint()..style = PaintingStyle.stroke;
  final Paint _postureFillPaint = Paint()..style = PaintingStyle.fill;
  final Paint _postureArrowPaint = Paint()..style = PaintingStyle.stroke;

  CompositionPainter({
    required this.type,
    required this.opacity,
    this.horizonTiltDeg = 0.0,
    this.faceRect,
    this.postureGuide,
    this.cameraPreviewSize,
  });

  void _applyOpacity() {
    final o = opacity.clamp(0.0, 1.0);
    _gridPaint
      ..color = AppColors.overlayGrid.withValues(alpha: o)
      ..strokeWidth = 0.8;
    _gridDotPaint.color = AppColors.overlayGridPower.withValues(alpha: o);
    _gridRingPaint
      ..color = AppColors.overlayGridPower.withValues(alpha: o * 0.3)
      ..strokeWidth = 1;
    _spiralPaint
      ..color = AppColors.overlaySpiral.withValues(alpha: o)
      ..strokeWidth = 1.5;
    _spiralDotPaint.color = AppColors.overlaySpiral.withValues(alpha: o);
    _symmetryPaint
      ..color = AppColors.overlaySymmetry.withValues(alpha: o)
      ..strokeWidth = 1.2;
    _leadingPaint
      ..color = AppColors.overlayLeading.withValues(alpha: o)
      ..strokeWidth = 1.2;
    _leadingDotPaint.color = AppColors.overlayLeading.withValues(alpha: o);
    _diagonalPaint
      ..color = AppColors.overlayDiagonal.withValues(alpha: o)
      ..strokeWidth = 1.5;
    _centerPaint
      ..color = AppColors.overlaySymmetry.withValues(alpha: o)
      ..strokeWidth = 1.2;
    final horizonColor = horizonTiltDeg.abs() < 1.5
        ? AppColors.success
        : AppColors.overlayHorizon;
    _horizonPaint
      ..color = horizonColor.withValues(alpha: o * 0.7)
      ..strokeWidth = 1.0;
    _horizonDotPaint.color = horizonColor.withValues(alpha: o * 0.8);
    _facePaint
      ..color = AppColors.accent3.withValues(alpha: o * 0.7)
      ..strokeWidth = 1.5;
    _posturePaint
      ..color = AppColors.accent.withValues(alpha: o * 0.85)
      ..strokeWidth = 2.0;
    _postureFillPaint.color = AppColors.accent.withValues(alpha: o * 0.12);
    _postureArrowPaint
      ..color = AppColors.accent2.withValues(alpha: o * 0.9)
      ..strokeWidth = 2.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.01) return;
    _applyOpacity();

    switch (type) {
      case CompositionType.ruleOfThirds:
        _drawRuleOfThirds(canvas, size);
        break;
      case CompositionType.goldenSpiral:
        _drawGoldenSpiral(canvas, size);
        break;
      case CompositionType.goldenTriangle:
        _drawGoldenTriangle(canvas, size);
        break;
      case CompositionType.symmetry:
        _drawSymmetry(canvas, size);
        break;
      case CompositionType.leadingLines:
        _drawLeadingLines(canvas, size);
        break;
      case CompositionType.diagonal:
        _drawDiagonal(canvas, size);
        break;
      case CompositionType.centerFrame:
        _drawCenterFrame(canvas, size);
        break;
      case CompositionType.selfiePosture:
        _drawSelfiePosture(canvas, size);
        break;
      case CompositionType.none:
        break;
    }

    // Always draw: horizon tilt indicator
    _drawHorizonIndicator(canvas, size);

    // Always draw: face bounding box if available
    if (faceRect != null) {
      _drawFaceBox(canvas, size, faceRect!);
    }
  }

  // ────────────────────────────────────────────────────
  // RULE OF THIRDS
  // ────────────────────────────────────────────────────
  void _drawRuleOfThirds(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawLine(Offset(w / 3, 0), Offset(w / 3, h), _gridPaint);
    canvas.drawLine(Offset(w * 2 / 3, 0), Offset(w * 2 / 3, h), _gridPaint);
    canvas.drawLine(Offset(0, h / 3), Offset(w, h / 3), _gridPaint);
    canvas.drawLine(Offset(0, h * 2 / 3), Offset(w, h * 2 / 3), _gridPaint);

    for (final x in [w / 3, w * 2 / 3]) {
      for (final y in [h / 3, h * 2 / 3]) {
        canvas.drawCircle(Offset(x, y), 5, _gridDotPaint);
        canvas.drawCircle(Offset(x, y), 10, _gridRingPaint);
      }
    }
  }

  // ────────────────────────────────────────────────────
  // GOLDEN SPIRAL (Fibonacci)
  // ────────────────────────────────────────────────────
  void _drawGoldenSpiral(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.618;
    final cy = h * 0.382;

    final path = Path();
    const phi = 1.6180339887;
    final b = math.log(phi) / (math.pi / 2); // ~0.3063489
    
    // Wind in beautifully to the focal point (cx, cy).
    final maxRadius = math.max(w, h) * 0.8;
    bool first = true;
    
    for (double theta = 0; theta < 6 * math.pi; theta += 0.05) {
      final r = maxRadius * math.exp(-b * theta);
      final angle = theta - 0.8; // Align start angle beautifully for portrait
      final px = cx + r * math.cos(angle);
      final py = cy + r * math.sin(angle);

      if (first) {
        path.moveTo(px, py);
        first = false;
      } else {
        path.lineTo(px, py);
      }
    }
    
    canvas.drawPath(path, _spiralPaint);
    canvas.drawCircle(Offset(cx, cy), 6, _spiralDotPaint);
  }

  // ────────────────────────────────────────────────────
  // GOLDEN TRIANGLE
  // ────────────────────────────────────────────────────
  void _drawGoldenTriangle(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final px = w * 0.618;
    canvas.drawLine(Offset(0, h), Offset(w, 0), _spiralPaint);
    canvas.drawLine(const Offset(0, 0), Offset(px, h), _spiralPaint);
    canvas.drawLine(Offset(w, h), Offset(px, 0), _spiralPaint);
  }

  // ────────────────────────────────────────────────────
  // SYMMETRY
  // ────────────────────────────────────────────────────
  void _drawSymmetry(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    canvas.drawLine(Offset(cx, 0), Offset(cx, h), _symmetryPaint);
    _symmetryPaint.strokeWidth = 0.8;
    canvas.drawLine(Offset(0, cy), Offset(w, cy), _symmetryPaint);
    _symmetryPaint.strokeWidth = 1.2;

    canvas.drawCircle(Offset(cx, cy), 12, _symmetryPaint);
    canvas.drawLine(Offset(cx - 6, cy), Offset(cx + 6, cy), _symmetryPaint);
    canvas.drawLine(Offset(cx, cy - 6), Offset(cx, cy + 6), _symmetryPaint);
  }

  // ────────────────────────────────────────────────────
  // LEADING LINES
  // ────────────────────────────────────────────────────
  void _drawLeadingLines(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final vp = Offset(w / 2, h * 0.35);

    final corners = [
      Offset.zero,
      Offset(w, 0),
      Offset(0, h),
      Offset(w, h),
    ];
    for (final corner in corners) {
      _drawDashedLine(canvas, corner, vp, _leadingPaint, 12, 8);
    }

    _leadingPaint.style = PaintingStyle.stroke;
    canvas.drawCircle(vp, 8, _leadingPaint);
    _leadingPaint.style = PaintingStyle.fill;
    canvas.drawCircle(vp, 3, _leadingDotPaint);
    _leadingPaint.style = PaintingStyle.stroke;
  }

  // ────────────────────────────────────────────────────
  // DIAGONAL
  // ────────────────────────────────────────────────────
  void _drawDiagonal(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawLine(Offset(0, h), Offset(w, 0), _diagonalPaint);
    _diagonalPaint.color =
        AppColors.overlayDiagonal.withValues(alpha: opacity * 0.3);
    canvas.drawLine(Offset.zero, Offset(w, h), _diagonalPaint);
    _diagonalPaint.color = AppColors.overlayDiagonal.withValues(alpha: opacity);
  }

  // ────────────────────────────────────────────────────
  // CENTER FRAME
  // ────────────────────────────────────────────────────
  void _drawCenterFrame(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    canvas.drawLine(Offset(cx - 20, cy), Offset(cx + 20, cy), _centerPaint);
    canvas.drawLine(Offset(cx, cy - 20), Offset(cx, cy + 20), _centerPaint);

    for (final scale in [0.2, 0.4, 0.65]) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: w * scale,
          height: h * scale,
        ),
        _centerPaint,
      );
    }
  }

  // ────────────────────────────────────────────────────
  // SELFIE POSTURE (background-aware ghost pose)
  // ────────────────────────────────────────────────────
  void _drawSelfiePosture(Canvas canvas, Size size) {
    final guide = postureGuide;
    if (guide == null) {
      _drawRuleOfThirds(canvas, size);
      return;
    }

    switch (guide.style) {
      case SelfiePostureStyle.environmental:
        _drawRuleOfThirds(canvas, size);
        _drawHorizonBand(canvas, size, size.height * 0.42);
        break;
      case SelfiePostureStyle.symmetryCenter:
        _drawSymmetry(canvas, size);
        break;
      case SelfiePostureStyle.dynamicDiagonal:
        _drawDiagonal(canvas, size);
        break;
      case SelfiePostureStyle.casualCenter:
        _drawCenterFrame(canvas, size);
        break;
      case SelfiePostureStyle.offCenterThirds:
        _drawRuleOfThirds(canvas, size);
        break;
    }

    final target = _normToScreen(guide.targetHeadCenter, size);
    final scale = switch (guide.style) {
      SelfiePostureStyle.environmental => 0.78,
      SelfiePostureStyle.casualCenter => 1.05,
      _ => 0.95,
    };

    _drawPostureSilhouette(canvas, size, target, scale, guide.style);

    canvas.drawCircle(target, 28, _postureFillPaint);
    canvas.drawCircle(target, 28, _posturePaint);

    if (faceRect != null) {
      final faceCenter = _normRectCenter(faceRect!, size);
      final delta = target - faceCenter;
      if (delta.distance > size.shortestSide * 0.04) {
        _drawNudgeArrow(canvas, faceCenter, target);
      }
    }
  }

  void _drawHorizonBand(Canvas canvas, Size size, double y) {
    _drawDashedLine(
      canvas,
      Offset(0, y),
      Offset(size.width, y),
      _horizonPaint,
      10,
      8,
    );
  }

  void _drawPostureSilhouette(
    Canvas canvas,
    Size screenSize,
    Offset headCenter,
    double scale,
    SelfiePostureStyle style,
  ) {
    final s = screenSize.width * 0.09 * scale;
    final head = headCenter;
    final shoulderY = head.dy + s * 1.1;
    final shoulderSpan = s * (style == SelfiePostureStyle.environmental ? 2.2 : 1.8);
    final hipY = shoulderY + s * 1.6;
    final hipSpan = shoulderSpan * 0.85;

    final leftShoulder = Offset(head.dx - shoulderSpan / 2, shoulderY);
    final rightShoulder = Offset(head.dx + shoulderSpan / 2, shoulderY);
    final leftHip = Offset(head.dx - hipSpan / 2, hipY);
    final rightHip = Offset(head.dx + hipSpan / 2, hipY);

    canvas.drawCircle(head, s * 0.55, _postureFillPaint);
    canvas.drawCircle(head, s * 0.55, _posturePaint);

    canvas.drawLine(leftShoulder, rightShoulder, _posturePaint);
    canvas.drawLine(
      Offset(head.dx, head.dy + s * 0.45),
      Offset(head.dx, shoulderY),
      _posturePaint,
    );

    if (style == SelfiePostureStyle.dynamicDiagonal) {
      canvas.drawLine(leftShoulder, leftHip + Offset(-s * 0.2, 0), _posturePaint);
      canvas.drawLine(rightShoulder, rightHip + Offset(s * 0.35, 0), _posturePaint);
    } else {
      canvas.drawLine(leftShoulder, leftHip, _posturePaint);
      canvas.drawLine(rightShoulder, rightHip, _posturePaint);
    }
    canvas.drawLine(leftHip, rightHip, _posturePaint);
  }

  void _drawNudgeArrow(Canvas canvas, Offset from, Offset to) {
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..lineTo(to.dx, to.dy);
    canvas.drawPath(path, _postureArrowPaint);

    final dir = (to - from);
    if (dir.distance < 1) return;
    final unit = dir / dir.distance;
    final tip = to - unit * 14;
    final perp = Offset(-unit.dy, unit.dx) * 8;
    canvas.drawLine(tip, tip + perp, _postureArrowPaint);
    canvas.drawLine(tip, tip - perp, _postureArrowPaint);
  }

  Offset _normToScreen(Offset norm, Size size) {
    final mapped = _mapNormRect(
      Rect.fromCenter(
        center: norm,
        width: 0.001,
        height: 0.001,
      ),
      size,
    );
    return mapped.center;
  }

  Offset _normRectCenter(Rect normRect, Size size) {
    return _mapNormRect(normRect, size).center;
  }

  Rect _mapNormRect(Rect normRect, Size size) {
    double scaleX = size.width;
    double scaleY = size.height;
    double offsetX = 0.0;
    double offsetY = 0.0;

    if (cameraPreviewSize != null) {
      final previewW = cameraPreviewSize!.width;
      final previewH = cameraPreviewSize!.height;
      final scale = math.max(size.width / previewW, size.height / previewH);
      final scaledW = previewW * scale;
      final scaledH = previewH * scale;
      offsetX = (size.width - scaledW) / 2;
      offsetY = (size.height - scaledH) / 2;
      scaleX = scaledW;
      scaleY = scaledH;
    }

    return Rect.fromLTWH(
      offsetX + normRect.left * scaleX,
      offsetY + normRect.top * scaleY,
      normRect.width * scaleX,
      normRect.height * scaleY,
    );
  }

  // ────────────────────────────────────────────────────
  // HORIZON TILT INDICATOR (always shown)
  // ────────────────────────────────────────────────────
  void _drawHorizonIndicator(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(horizonTiltDeg * math.pi / 180);
    canvas.drawLine(const Offset(-40, 0), const Offset(40, 0), _horizonPaint);
    canvas.restore();

    canvas.drawCircle(Offset(cx, cy), 3, _horizonDotPaint);
  }

  // ────────────────────────────────────────────────────
  // FACE BOUNDING BOX
  // ────────────────────────────────────────────────────
  void _drawFaceBox(Canvas canvas, Size size, Rect normRect) {
    final rect = _mapNormRect(normRect, size);

    final clen = math.min(rect.width, rect.height) * 0.2;

    void corner(Offset start, Offset hEnd, Offset vEnd) {
      canvas.drawLine(start, hEnd, _facePaint);
      canvas.drawLine(start, vEnd, _facePaint);
    }

    corner(rect.topLeft, rect.topLeft + Offset(clen, 0),
        rect.topLeft + Offset(0, clen));
    corner(rect.topRight, rect.topRight - Offset(clen, 0),
        rect.topRight + Offset(0, clen));
    corner(rect.bottomLeft, rect.bottomLeft + Offset(clen, 0),
        rect.bottomLeft - Offset(0, clen));
    corner(rect.bottomRight, rect.bottomRight - Offset(clen, 0),
        rect.bottomRight - Offset(0, clen));
  }

  // ────────────────────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────────────────────
  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint,
      double dashLen, double gapLen) {
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    final steps = dist / (dashLen + gapLen);
    final nx = dx / dist;
    final ny = dy / dist;

    for (int i = 0; i < steps; i++) {
      final startFrac = i * (dashLen + gapLen);
      final endFrac = startFrac + dashLen;
      canvas.drawLine(
        Offset(p1.dx + nx * startFrac, p1.dy + ny * startFrac),
        Offset(p1.dx + nx * math.min(endFrac, dist),
            p1.dy + ny * math.min(endFrac, dist)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CompositionPainter old) =>
      old.type != type ||
      old.opacity != opacity ||
      old.horizonTiltDeg != horizonTiltDeg ||
      old.faceRect != faceRect ||
      old.postureGuide != postureGuide ||
      old.cameraPreviewSize != cameraPreviewSize;
}
