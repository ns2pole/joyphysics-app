import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../fields/wave_fields.dart';
import '../utils/coordinate_transformer.dart';

class ThinFilmWavelengthRow {
  final int lambdaNm;
  final Color color;

  const ThinFilmWavelengthRow({required this.lambdaNm, required this.color});
}

class ThinFilmStackPainter extends CustomPainter {
  ThinFilmStackPainter({
    required this.time,
    required this.n,
    required this.thicknessLInternal,
    required this.scale,
    required this.rows,
    required this.activeComponentIds,
    this.scaleFactor = 250.0,
    this.glowGamma = 1.35,
  });

  final double time;
  final double n;
  final double thicknessLInternal;
  final double scale;
  final List<ThinFilmWavelengthRow> rows;
  final Set<String> activeComponentIds;
  final double scaleFactor;
  final double glowGamma;

  static const double _worldRange = 5.0; // x in [-5,5] like WaveLinePainter

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFF7F7FB));

    final transformer = WaveCoordinateTransformer(
      size: size,
      scale: scale,
      is3D: false,
    );
    final center = transformer.center;
    final unitScale = transformer.unitScale;

    // Geometry for stacked rows
    final rowCount = rows.isEmpty ? 1 : rows.length;
    // Compress the stack a bit to reduce vertical gaps.
    const stackHeightFactor = 0.86; // smaller -> tighter rows
    final stackHeight = size.height * stackHeightFactor;
    final yOffset = (size.height - stackHeight) / 2.0;
    final rowHeight = stackHeight / rowCount;
    final ampPx = rowHeight * 0.30; // tuned for tighter rows
    final topPadPx = 10.0;

    double xToScreen(double xWorld) => center.dx + xWorld * unitScale;

    double rowBaselineY(int rowIndex) {
      // Keep some padding and center within each band.
      final y = yOffset + (rowIndex + 0.5) * rowHeight;
      return y.clamp(topPadPx, size.height - topPadPx);
    }

    double valueToScreenY(int rowIndex, double value) {
      final base = rowBaselineY(rowIndex);
      return base - value * ampPx;
    }

    // Slab overlay (0..L)
    final slabPaint = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..style = PaintingStyle.fill;
    final slabBorder = Paint()
      ..color = Colors.black.withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final slabX0 = xToScreen(0.0);
    final slabX1 = xToScreen(thicknessLInternal.clamp(-_worldRange, _worldRange));
    final slabRect = Rect.fromLTRB(
      slabX0,
      yOffset,
      slabX1,
      yOffset + stackHeight,
    );
    canvas.drawRect(slabRect, slabPaint);
    canvas.drawRect(slabRect, slabBorder);

    // Grid baselines (subtle)
    final gridPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..strokeWidth = 1.0;
    for (int i = 0; i < rowCount; i++) {
      final y = rowBaselineY(i);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Styles
    Paint componentPaint(Color c) => Paint()
      ..color = c.withOpacity(0.30)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Paint combinedPaint(Color c) => Paint()
      ..color = c.withOpacity(0.92)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Label style
    const labelStyle = TextStyle(
      color: Colors.black87,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      fontFamily: 'Courier',
    );

    // Sampling
    const samples = 380;
    const step = (_worldRange * 2) / samples;

    // Draw each row
    for (int rowIndex = 0; rowIndex < rowCount; rowIndex++) {
      final row = rows[rowIndex];
      final lambdaInternal = row.lambdaNm / scaleFactor;

      final showIncident = activeComponentIds.contains('incident');
      final showR1 = activeComponentIds.contains('reflected1');
      final showR2 = activeComponentIds.contains('reflected2');
      final showCombined = activeComponentIds.contains('combinedReflected');

      final field = ThinFilmInterferenceField(
        lambda: lambdaInternal,
        periodT: 1.0,
        n: n,
        thicknessL: thicknessLInternal,
        mode: ThinFilmMode.combinedReflected,
        amplitude: 0.35, // slightly reduced for stack view
      );

      // Label (left)
      final labelSpan = TextSpan(text: '${row.lambdaNm}', style: labelStyle);
      final tp = TextPainter(text: labelSpan, textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, Offset(8, rowBaselineY(rowIndex) - tp.height / 2));

      // Intensity-based glow on the left side (x < 0), only when combined is shown
      if (showCombined && slabX0 > 0) {
        // Do not show glow until the 2nd reflected wave reaches the left side.
        // This avoids coloring before any combined reflection exists.
        // Use the reach time at x=0 (boundary) for reflected2:
        // tReachR2 = (0 - xSource)/v1 + (2*L)/v2, where v1=lambda/periodT, v2=v1/n
        const xSource = -7.5;
        final v1 = lambdaInternal; // periodT=1.0
        final v2 = (n <= 0) ? v1 : (v1 / n);
        final tReachR2AtBoundary =
            (0 - xSource) / v1 + (2 * thicknessLInternal) / v2;
        if (time < tReachR2AtBoundary) {
          // skip glow
        } else {
        // Use time-averaged intensity based on optical path difference.
        // DeltaPhi = 4*pi*n*L/lambda + pi (fixed-end reflection at x=0)
        // I = (1 + cos(DeltaPhi))/2 = (1 - cos(4*pi*n*L/lambda))/2
        final phase = 4 * math.pi * n * thicknessLInternal / lambdaInternal;
        final iNorm = (1.0 - math.cos(phase)) * 0.5; // 0..1
        final shaped = math.pow(iNorm.clamp(0.0, 1.0), glowGamma).toDouble();
        final alpha = (0.42 * shaped).clamp(0.0, 0.42);

        if (alpha > 0.01) {
          final bandTop = yOffset + rowIndex * rowHeight;
          final bandBottom = yOffset + (rowIndex + 1) * rowHeight;
          final glowRect = Rect.fromLTRB(
            0,
            bandTop,
            slabX0,
            bandBottom,
          );

          final gradient = LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [
              row.color.withOpacity(alpha),
              row.color.withOpacity(0.0),
            ],
          );

          final glowPaint = Paint()
            ..shader = gradient.createShader(glowRect)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

          canvas.save();
          canvas.clipRect(glowRect);
          canvas.drawRect(glowRect, glowPaint);
          canvas.restore();
        }
        }
      }

      // Collect paths
      final pathIncident = Path();
      final pathR1 = Path();
      final pathR2 = Path();
      final pathCombined = Path();

      bool started = false;
      for (int i = 0; i <= samples; i++) {
        final x = -_worldRange + i * step;
        final comps = field.getComponents(
          x,
          0,
          time,
          activeComponentIds,
        );

        double vIncident = 0.0;
        double vR1 = 0.0;
        double vR2 = 0.0;
        double vCombined = 0.0;
        for (final c in comps) {
          switch (c.id) {
            case 'incident':
              vIncident = c.value;
              break;
            case 'reflected1':
              vR1 = c.value;
              break;
            case 'reflected2':
              vR2 = c.value;
              break;
            case 'combinedReflected':
              vCombined = c.value;
              break;
          }
        }

        final sx = xToScreen(x);
        final yi = valueToScreenY(rowIndex, vIncident);
        final yr1 = valueToScreenY(rowIndex, vR1);
        final yr2 = valueToScreenY(rowIndex, vR2);
        final yc = valueToScreenY(rowIndex, vCombined);

        if (!started) {
          if (showIncident) pathIncident.moveTo(sx, yi);
          if (showR1) pathR1.moveTo(sx, yr1);
          if (showR2) pathR2.moveTo(sx, yr2);
          if (showCombined) pathCombined.moveTo(sx, yc);
          started = true;
        } else {
          if (showIncident) pathIncident.lineTo(sx, yi);
          if (showR1) pathR1.lineTo(sx, yr1);
          if (showR2) pathR2.lineTo(sx, yr2);
          if (showCombined) pathCombined.lineTo(sx, yc);
        }
      }

      final cp = componentPaint(row.color);
      if (showIncident) canvas.drawPath(pathIncident, cp);
      if (showR1) canvas.drawPath(pathR1, cp);
      if (showR2) canvas.drawPath(pathR2, cp);
      if (showCombined) canvas.drawPath(pathCombined, combinedPaint(row.color));
    }
  }

  @override
  bool shouldRepaint(covariant ThinFilmStackPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.n != n ||
        oldDelegate.thicknessLInternal != thicknessLInternal ||
        oldDelegate.scale != scale ||
        oldDelegate.scaleFactor != scaleFactor ||
        oldDelegate.glowGamma != glowGamma ||
        oldDelegate.activeComponentIds != activeComponentIds ||
        oldDelegate.rows != rows;
  }
}

