import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/enums/composition_type.dart';

/// CustomPainter that draws all composition overlays on the live camera preview.
/// Rendered at 60fps — all painting must be extremely lightweight.
class CompositionPainter extends CustomPainter {
  final CompositionType type;
  final double opacity;
  final double horizonTiltDeg;
  final Rect? faceRect;

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

  CompositionPainter({
    required this.type,
    required this.opacity,
    this.horizonTiltDeg = 0.0,
    this.faceRect,
  });

  void _applyOpacity() {
    final o = opacity.clamp(0.0, 1.0);
    _gridPaint
      ..color = AppColors.overlayGrid.withOpacity(o)
      ..strokeWidth = 0.8;
    _gridDotPaint.color = AppColors.overlayGridPower.withOpacity(o);
    _gridRingPaint
      ..color = AppColors.overlayGridPower.withOpacity(o * 0.3)
      ..strokeWidth = 1;
    _spiralPaint
      ..color = AppColors.overlaySpiral.withOpacity(o)
      ..strokeWidth = 1.5;
    _spiralDotPaint.color = AppColors.overlaySpiral.withOpacity(o);
    _symmetryPaint
      ..color = AppColors.overlaySymmetry.withOpacity(o)
      ..strokeWidth = 1.2;
    _leadingPaint
      ..color = AppColors.overlayLeading.withOpacity(o)
      ..strokeWidth = 1.2;
    _leadingDotPaint.color = AppColors.overlayLeading.withOpacity(o);
    _diagonalPaint
      ..color = AppColors.overlayDiagonal.withOpacity(o)
      ..strokeWidth = 1.5;
    _centerPaint
      ..color = AppColors.overlaySymmetry.withOpacity(o)
      ..strokeWidth = 1.2;
    final horizonColor = horizonTiltDeg.abs() < 1.5
        ? AppColors.success
        : AppColors.overlayHorizon;
    _horizonPaint
      ..color = horizonColor.withOpacity(o * 0.7)
      ..strokeWidth = 1.0;
    _horizonDotPaint.color = horizonColor.withOpacity(o * 0.8);
    _facePaint
      ..color = AppColors.accent3.withOpacity(o * 0.7)
      ..strokeWidth = 1.5;
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
    const phi = 1.618033988;
    final cx = w * 0.618;
    final cy = h * 0.382;

    double rectW = w;
    double rectH = h;
    double x = 0;
    double y = 0;
    bool horizontal = true;

    for (int i = 0; i < 7; i++) {
      if (horizontal) {
        final newW = rectW / phi;
        canvas.drawArc(
          Rect.fromCenter(
              center: Offset(x + newW, y + rectH), width: rectH * 2, height: rectH * 2),
          -math.pi / 2,
          math.pi / 2,
          false,
          _spiralPaint,
        );
        x += newW;
        rectW -= newW;
      } else {
        final newH = rectH / phi;
        canvas.drawArc(
          Rect.fromCenter(
              center: Offset(x, y + newH), width: rectW * 2, height: rectW * 2),
          0,
          math.pi / 2,
          false,
          _spiralPaint,
        );
        y += newH;
        rectH -= newH;
      }
      horizontal = !horizontal;
    }

    // Focal point dot
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
    canvas.drawLine(Offset(0, 0), Offset(px, h), _spiralPaint);
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
        AppColors.overlayDiagonal.withOpacity(opacity * 0.3);
    canvas.drawLine(Offset.zero, Offset(w, h), _diagonalPaint);
    _diagonalPaint.color = AppColors.overlayDiagonal.withOpacity(opacity);
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
    final rect = Rect.fromLTWH(
      normRect.left * size.width,
      normRect.top * size.height,
      normRect.width * size.width,
      normRect.height * size.height,
    );

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
      old.faceRect != faceRect;
}
