import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../fields/wave_fields.dart';

class MediumSlabOverlay {
  const MediumSlabOverlay({
    required this.xStart,
    required this.xEnd,
    this.color = Colors.yellow,
    this.opacity = 0.35,
  });

  final double xStart;
  final double xEnd;
  final Color color;
  final double opacity;

  @override
  bool operator ==(Object other) {
    return other is MediumSlabOverlay &&
        other.xStart == xStart &&
        other.xEnd == xEnd &&
        other.color == color &&
        other.opacity == opacity;
  }

  @override
  int get hashCode => Object.hash(xStart, xEnd, color, opacity);
}

class WaveSurfacePainter extends CustomPainter {
  WaveSurfacePainter({
    required this.time,
    required this.field,
    this.showPeakLines = false,
    required this.azimuth,
    required this.tilt,
    this.mediumSlab,
    this.surfaceColor,
    this.showTicks = false,
    this.xAxisLabel = 'x',
    this.yAxisLabel = 'y',
    this.zAxisLabel = 'z',
    this.markers = const [],
    this.activeComponentIds,
    this.showYoungDoubleSlitExtras = false,
    this.slitA = 2.0,
    this.screenX = 8.0,
    this.showIntersectionLine = false,
    this.showIntensityLine = false,
  });

  final double time;
  final WaveField field;
  final bool showPeakLines;
  final double azimuth;
  final double tilt;
  final MediumSlabOverlay? mediumSlab;
  final Color? surfaceColor;
  final bool showTicks;
  final String xAxisLabel;
  final String yAxisLabel;
  final String zAxisLabel;
  final List<math.Point<double>> markers;
  final Set<String>? activeComponentIds;
  final bool showYoungDoubleSlitExtras;
  final double slitA;
  final double screenX;
  final bool showIntersectionLine;
  final bool showIntensityLine;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF7F7FB),
    );

    const unitScale = 50.0;
    final center = Offset(size.width / 2, size.height / 2);

    const cos45 = 0.7071;
    final sTilt = math.sin(tilt);
    final cTilt = math.cos(tilt);
    
    Offset worldToScreen(double x, double y, double z) {
      final xr = x * math.cos(azimuth) - y * math.sin(azimuth);
      final yr = x * math.sin(azimuth) + y * math.cos(azimuth);
      final px = center.dx + (yr - xr) * cos45 * unitScale;
      final py =
          center.dy + (xr + yr) * cos45 * sTilt * unitScale - z * cTilt * unitScale;
      return Offset(px, py);
    }

    double getPhase(double x, double y) => field.phase(x, y, time);
    List<WaveComponent> getComponents(double x, double y) {
      if (activeComponentIds == null) {
        return [
          WaveComponent(
            id: 'total',
            label: '波面',
            color: surfaceColor ?? const Color(0xFFB38CFF),
            value: field.z(x, y, time),
          )
        ];
      }
      return field.getComponents(x, y, time, activeComponentIds!);
    }

    const range = 10.0;
    const div = 140;
    const step = (range * 2) / div;

    void drawWaveSurface({required bool onlyAbove}) {
      final compsForCount = getComponents(0, 0);
      final numComps = compsForCount.length;

      // セレクタが指定されているのに何も選択されていない場合は描画しない
      if (activeComponentIds != null && activeComponentIds!.isEmpty) return;

      for (int compIdx = 0; compIdx < numComps; compIdx++) {
        final surfacePaintBase = Paint()
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;

        final surfacePaintAbove = Paint()
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;

        for (int i = 0; i < div; i++) {
          for (int j = 0; j < div; j++) {
            final x1 = -range + i * step;
            final y1 = -range + j * step;
            final x2 = x1 + step;
            final y2 = y1 + step;

            final comps1 = getComponents(x1, y1);
            final comps2 = getComponents(x2, y1);
            final comps3 = getComponents(x2, y2);
            final comps4 = getComponents(x1, y2);

            final double z1, z2, z3, z4;
            final Color c;
            if (comps1.isNotEmpty && compIdx < comps1.length) {
              z1 = comps1[compIdx].value;
              z2 = comps2[compIdx].value;
              z3 = comps3[compIdx].value;
              z4 = comps4[compIdx].value;
              c = comps1[compIdx].color;
            } else {
              continue;
            }

            surfacePaintBase.color = c.withOpacity(0.3);
            surfacePaintAbove.color = c.withOpacity(0.8);

            if (onlyAbove && z1 <= 0 && z2 <= 0 && z3 <= 0 && z4 <= 0) continue;

            final crossesZero = (z1 > 0) != (z2 > 0) ||
                (z2 > 0) != (z3 > 0) ||
                (z3 > 0) != (z4 > 0) ||
                (z4 > 0) != (z1 > 0);
            final minAbsZ = math.min(
              math.min(z1.abs(), z2.abs()),
              math.min(z3.abs(), z4.abs()),
            );

            if (crossesZero || minAbsZ < 0.06) {
              const sub = 4;
              final dx = (x2 - x1) / sub;
              final dy = (y2 - y1) / sub;

              for (int si = 0; si < sub; si++) {
                for (int sj = 0; sj < sub; sj++) {
                  final ax1 = x1 + si * dx;
                  final ay1 = y1 + sj * dy;
                  final ax2 = ax1 + dx;
                  final ay2 = ay1 + dy;

                  final aComps1 = getComponents(ax1, ay1);
                  final aComps2 = getComponents(ax2, ay1);
                  final aComps3 = getComponents(ax2, ay2);
                  final aComps4 = getComponents(ax1, ay2);

                  final double az1, az2, az3, az4;
                  if (aComps1.isNotEmpty && compIdx < aComps1.length) {
                    az1 = aComps1[compIdx].value;
                    az2 = aComps2[compIdx].value;
                    az3 = aComps3[compIdx].value;
                    az4 = aComps4[compIdx].value;
                  } else {
                    continue;
                  }

                  if (onlyAbove &&
                      az1 <= 0 &&
                      az2 <= 0 &&
                      az3 <= 0 &&
                      az4 <= 0) {
                    continue;
                  }

                  final ap1 = worldToScreen(ax1, ay1, az1);
                  final ap2 = worldToScreen(ax2, ay1, az2);
                  final ap3 = worldToScreen(ax2, ay2, az3);
                  final ap4 = worldToScreen(ax1, ay2, az4);

                  final path = Path()
                    ..moveTo(ap1.dx, ap1.dy)
                    ..lineTo(ap2.dx, ap2.dy)
                    ..lineTo(ap3.dx, ap3.dy)
                    ..lineTo(ap4.dx, ap4.dy)
                    ..close();
                  canvas.drawPath(
                    path,
                    onlyAbove ? surfacePaintAbove : surfacePaintBase,
                  );
                }
              }
              continue;
            }

            final p1 = worldToScreen(x1, y1, z1);
            final p2 = worldToScreen(x2, y1, z2);
            final p3 = worldToScreen(x2, y2, z3);
            final p4 = worldToScreen(x1, y2, z4);

            final path = Path()
              ..moveTo(p1.dx, p1.dy)
              ..lineTo(p2.dx, p2.dy)
              ..lineTo(p3.dx, p3.dy)
              ..lineTo(p4.dx, p4.dy)
              ..close();

            canvas.drawPath(path, onlyAbove ? surfacePaintAbove : surfacePaintBase);
          }
        }
      }
    }

    // Pass 1: full surface
    drawWaveSurface(onlyAbove: false);

    // z=0 plane
    final planePaint = Paint()
      ..color = const Color(0xFF777777).withOpacity(0.4)
      ..style = PaintingStyle.fill;
    final planePath = Path()
      ..moveTo(
        worldToScreen(-range, -range, 0).dx,
        worldToScreen(-range, -range, 0).dy,
      )
      ..lineTo(
        worldToScreen(range, -range, 0).dx,
        worldToScreen(range, -range, 0).dy,
      )
      ..lineTo(
        worldToScreen(range, range, 0).dx,
        worldToScreen(range, range, 0).dy,
      )
      ..lineTo(
        worldToScreen(-range, range, 0).dx,
        worldToScreen(-range, range, 0).dy,
      )
      ..close();
    canvas.drawPath(planePath, planePaint);

    // Medium overlay on z=0 plane
    final slab = mediumSlab;
    if (slab != null) {
      final paint = Paint()
        ..color = slab.color.withOpacity(slab.opacity)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      final p1 = worldToScreen(slab.xStart, -range, 0);
      final p2 = worldToScreen(slab.xEnd, -range, 0);
      final p3 = worldToScreen(slab.xEnd, range, 0);
      final p4 = worldToScreen(slab.xStart, range, 0);
      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..lineTo(p4.dx, p4.dy)
        ..close();
      canvas.drawPath(path, paint);
    }

    // Young's Double Slit Extras: Barrier and Screen
    if (showYoungDoubleSlitExtras) {
      final barrierX = -8.0;

      // 1. Barrier at x = -8
      final barrierPaint = Paint()
        ..color = Colors.black.withOpacity(0.75) // 黒めに
        ..style = PaintingStyle.fill;
      
      const bH = 3.5; // barrier height
      const gapSize = 0.04; // 黄色い球(半径6px=約0.12unit)の1/3程度

      void drawBarrierPart(double yStart, double yEnd) {
        final p1 = worldToScreen(barrierX, yStart, -bH);
        final p2 = worldToScreen(barrierX, yEnd, -bH);
        final p3 = worldToScreen(barrierX, yEnd, bH);
        final p4 = worldToScreen(barrierX, yStart, bH);
        canvas.drawPath(Path()..moveTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..lineTo(p3.dx, p3.dy)..lineTo(p4.dx, p4.dy)..close(), barrierPaint);
      }

      // Draw barrier with slits at y=slitA and y=-slitA
      drawBarrierPart(-range, -slitA - gapSize);
      drawBarrierPart(-slitA + gapSize, slitA - gapSize);
      drawBarrierPart(slitA + gapSize, range);

      // 2. Screen at x=screenX (8.0)
      final screenPaint = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.fill;
      final s1 = worldToScreen(screenX, -range, -bH);
      final s2 = worldToScreen(screenX, range, -bH);
      final s3 = worldToScreen(screenX, range, bH);
      final s4 = worldToScreen(screenX, -range, bH);
      canvas.drawPath(Path()..moveTo(s1.dx, s1.dy)..lineTo(s2.dx, s2.dy)..lineTo(s3.dx, s3.dy)..lineTo(s4.dx, s4.dy)..close(), screenPaint);

      // 3. Interference pattern on the screen (x=screenX)
      final patternPaint = Paint()
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      // 4. Thick purple intersection line for amplitude on screen
      final intersectionPaint = Paint()
        ..color = Colors.deepPurple // 濃い紫
        ..strokeWidth = 6.0
        ..style = PaintingStyle.stroke;

      // 5. Black base line on the screen (intersection with z=0 plane)
      final baseLinePaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      // 6. Green intensity line (amplitude squared)
      final intensityPaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke;

      final b1 = worldToScreen(screenX, -range, 0);
      final b2 = worldToScreen(screenX, range, 0);
      canvas.drawLine(b1, b2, baseLinePaint);

      final compsForCount = getComponents(screenX, 0);
      final numComps = compsForCount.length;

      // Draw intersection line independently if requested
      if (showIntersectionLine) {
        final intersectionPath = Path();
        bool isFirst = true;
        for (int j = 0; j <= div; j++) {
          final y = -range + j * step;
          // Intersection line is for the total z value (combined)
          final z = field.z(screenX, y, time);
          final p = worldToScreen(screenX, y, z);
          if (isFirst) {
            intersectionPath.moveTo(p.dx, p.dy);
            isFirst = false;
          } else {
            intersectionPath.lineTo(p.dx, p.dy);
          }
        }
        canvas.drawPath(intersectionPath, intersectionPaint);
      }

      // Draw intensity line (z^2)
      if (showIntensityLine) {
        final intensityPath = Path();
        bool isFirst = true;
        for (int j = 0; j <= div; j++) {
          final y = -range + j * step;
          final z = field.z(screenX, y, time);
          // 2乗をスケールして表示
          final intensityZ = z * z * 4.0; 
          final p = worldToScreen(screenX, y, intensityZ);
          if (isFirst) {
            intensityPath.moveTo(p.dx, p.dy);
            isFirst = false;
          } else {
            intensityPath.lineTo(p.dx, p.dy);
          }
        }
        canvas.drawPath(intensityPath, intensityPaint);
      }

      if (numComps > 0 && (activeComponentIds == null || activeComponentIds!.isNotEmpty)) {
        for (int compIdx = 0; compIdx < numComps; compIdx++) {
          final path = Path();
          bool isFirst = true;

          for (int j = 0; j <= div; j++) {
            final y = -range + j * step;
            final comps = getComponents(screenX, y);
            if (compIdx >= comps.length) continue;
            
            final double z = comps[compIdx].value;
            final Color c = comps[compIdx].color;
            
            final p = worldToScreen(screenX, y, z);
            if (isFirst) {
              path.moveTo(p.dx, p.dy);
              isFirst = false;
            } else {
              path.lineTo(p.dx, p.dy);
            }
          }
          final compsAtEnd = getComponents(screenX, range);
          if (compIdx < compsAtEnd.length) {
            canvas.drawPath(path, patternPaint..color = compsAtEnd[compIdx].color);
          }
        }
      }
    }

    // Pass: overwrite above-water part
    drawWaveSurface(onlyAbove: true);

    // Mesh lines
    final meshPaint = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const intRange = 10;
    const meshSamplePoints = 300;

    for (int xInt = -intRange; xInt <= intRange; xInt++) {
      final x = xInt.toDouble();
      final path = Path();
      bool isFirst = true;
      for (int k = 0; k <= meshSamplePoints; k++) {
        final y = -range + (k / meshSamplePoints) * (range * 2);
        final comps = getComponents(x, y);
        if (comps.isEmpty) continue;
        final double z = comps.last.value;
        final p = worldToScreen(x, y, z);
        if (isFirst) {
          path.moveTo(p.dx, p.dy);
          isFirst = false;
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, meshPaint);
    }

    for (int yInt = -intRange; yInt <= intRange; yInt++) {
      final y = yInt.toDouble();
      final path = Path();
      bool isFirst = true;
      for (int k = 0; k <= meshSamplePoints; k++) {
        final x = -range + (k / meshSamplePoints) * (range * 2);
        final comps = getComponents(x, y);
        if (comps.isEmpty) continue;
        final double z = comps.last.value;
        final p = worldToScreen(x, y, z);
        if (isFirst) {
          path.moveTo(p.dx, p.dy);
          isFirst = false;
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, meshPaint);
    }

    // Peak lines
    if (showPeakLines) {
      final peakPaint = Paint()
        ..color = const Color(0xFF6200EA)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      for (int i = 0; i <= div; i++) {
        final x = -range + i * step;
        for (int j = 0; j < div; j++) {
          final y1 = -range + j * step;
          final y2 = y1 + step;
          final phase1 = getPhase(x, y1);
          if (math.sin(phase1) > 0.98) {
            final comps = getComponents(x, y1);
            if (comps.isEmpty) continue;
            final double z = comps.last.value;
            final p1 = worldToScreen(x, y1, z);
            final p2 = worldToScreen(x, y2, z);
            canvas.drawLine(p1, p2, peakPaint);
          }
        }
      }
    }

    // Axes and Ticks
    void drawAxis(double x, double y, double z, Color color, String label) {
      final start = worldToScreen(0, 0, 0);
      final end = worldToScreen(x, y, z);
      final paint = Paint()
        ..color = color.withOpacity(0.8)
        ..strokeWidth = 2.5;
      canvas.drawLine(start, end, paint);

      if (showTicks && x != 0) {
        final tickPaint = Paint()
          ..color = color.withOpacity(0.6)
          ..strokeWidth = 1.5;
        
        // Ticks for x-axis from -intRange to intRange
        for (int i = -intRange; i <= intRange; i++) {
          if (i == 0) continue;
          final tx = i.toDouble();
          final tStart = worldToScreen(tx, -0.2, 0);
          final tEnd = worldToScreen(tx, 0.2, 0);
          canvas.drawLine(tStart, tEnd, tickPaint);
          
          final span = TextSpan(
            style: TextStyle(color: color.withOpacity(0.7), fontSize: 10),
            text: i.toString(),
          );
          final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
          tp.paint(canvas, tEnd + const Offset(-5, 2));
        }
      }

      final span = TextSpan(
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        text: label,
      );
      final tp =
          TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, end + const Offset(5, -5));
    }

    void drawXAxis(double len, Color color, String label) {
      final start = worldToScreen(0, 0, 0);
      final posEnd = worldToScreen(len, 0, 0);
      final negEnd = worldToScreen(-8.0, 0, 0);
      
      final posPaint = Paint()
        ..color = color.withOpacity(0.8)
        ..strokeWidth = 2.5;
      
      // Positive part: solid line
      canvas.drawLine(start, posEnd, posPaint);
      
      // Negative part (x < 0): dashed line
      final negPaint = Paint()
        ..color = color.withOpacity(0.6)
        ..strokeWidth = 2.0;
      
      const dashLen = 0.4;
      double curX = 0.0;
      while (curX > -8.0) {
        final nextX = math.max(curX - dashLen, -8.0);
        canvas.drawLine(
          worldToScreen(curX, 0, 0),
          worldToScreen(nextX, 0, 0),
          negPaint,
        );
        curX -= dashLen * 2;
      }

      // Ticks for x-axis from -8 to 5
      if (showTicks) {
        final tickPaint = Paint()
          ..color = color.withOpacity(0.6)
          ..strokeWidth = 1.5;
        for (int i = -8; i <= 5; i++) {
          if (i == 0) continue;
          final tx = i.toDouble();
          final tStart = worldToScreen(tx, -0.2, 0);
          final tEnd = worldToScreen(tx, 0.2, 0);
          canvas.drawLine(tStart, tEnd, tickPaint);
          
          final span = TextSpan(
            style: TextStyle(color: color.withOpacity(0.7), fontSize: 10),
            text: i.toString(),
          );
          final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
          tp.paint(canvas, tEnd + const Offset(-5, 2));
        }
      }

      final span = TextSpan(
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        text: label,
      );
      final tp =
          TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, posEnd + const Offset(5, -5));
    }

    const axisLen = 5.0;
    drawXAxis(axisLen, Colors.red, xAxisLabel);
    drawAxis(0, axisLen, 0, Colors.green, yAxisLabel);
    drawAxis(0, 0, 3.5, Colors.blue, zAxisLabel);

    // 4. Markers
    final markerPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;
    final markerStroke = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (final m in markers) {
      final comps = getComponents(m.x, m.y);
      if (comps.isEmpty) continue;
      final double mz = comps.last.value;
      final p = worldToScreen(m.x, m.y, mz);
      canvas.drawCircle(p, 6.0, markerPaint);
      canvas.drawCircle(p, 6.0, markerStroke);
    }
  }

  @override
  bool shouldRepaint(covariant WaveSurfacePainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.field != field ||
        oldDelegate.showPeakLines != showPeakLines ||
        oldDelegate.azimuth != azimuth ||
        oldDelegate.tilt != tilt ||
        oldDelegate.mediumSlab != mediumSlab ||
        oldDelegate.surfaceColor != surfaceColor ||
        oldDelegate.showTicks != showTicks ||
        oldDelegate.xAxisLabel != xAxisLabel ||
        oldDelegate.yAxisLabel != yAxisLabel ||
        oldDelegate.zAxisLabel != zAxisLabel ||
        oldDelegate.markers != markers ||
        oldDelegate.activeComponentIds != activeComponentIds ||
        oldDelegate.showYoungDoubleSlitExtras != showYoungDoubleSlitExtras ||
        oldDelegate.slitA != slitA ||
        oldDelegate.screenX != screenX ||
        oldDelegate.showIntersectionLine != showIntersectionLine ||
        oldDelegate.showIntensityLine != showIntensityLine;
  }
}

