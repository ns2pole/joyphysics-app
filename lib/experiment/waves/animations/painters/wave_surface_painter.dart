import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart' hide Column, Vertices;
import 'package:flutter/material.dart' as material;

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
    final cAzimuth = math.cos(azimuth);
    final sAzimuth = math.sin(azimuth);
    final cos45Scale = cos45 * unitScale;
    final cos45STiltScale = cos45Scale * sTilt;
    final cTiltScale = cTilt * unitScale;
    
    Offset worldToScreen(double x, double y, double z) {
      final xr = x * cAzimuth - y * sAzimuth;
      final yr = x * sAzimuth + y * cAzimuth;
      final px = center.dx + (yr - xr) * cos45Scale;
      final py = center.dy + (xr + yr) * cos45STiltScale - z * cTiltScale;
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
    const div = 90;
    const step = (range * 2) / div;

    // Pre-calculate grid points and wave components
    final numPoints = div + 1;
    // Base screen coordinates without Z-axis contribution
    final gridPxBase = List.generate(numPoints, (i) => Float64List(numPoints));
    final gridPyBase = List.generate(numPoints, (i) => Float64List(numPoints));
    
    // Wave components at each grid point
    final gridComps = List.generate(
      numPoints,
      (i) => List<List<WaveComponent>>.filled(numPoints, []),
    );

    for (int i = 0; i < numPoints; i++) {
      final x = -range + i * step;
      for (int j = 0; j < numPoints; j++) {
        final y = -range + j * step;
        
        final xr = x * cAzimuth - y * sAzimuth;
        final yr = x * sAzimuth + y * cAzimuth;
        gridPxBase[i][j] = center.dx + (yr - xr) * cos45Scale;
        gridPyBase[i][j] = center.dy + (xr + yr) * cos45STiltScale;
        
        gridComps[i][j] = getComponents(x, y);
      }
    }

    // Grid points for total wave (used for mesh lines and slab)
    final gridPoints = List.generate(
      numPoints,
      (i) => List<Offset>.filled(numPoints, Offset.zero),
    );
    for (int i = 0; i < numPoints; i++) {
      for (int j = 0; j < numPoints; j++) {
        final x = -range + i * step;
        final y = -range + j * step;
        final z = field.z(x, y, time);
        gridPoints[i][j] = Offset(gridPxBase[i][j], gridPyBase[i][j] - z * cTiltScale);
      }
    }

    void drawWaveSurface({required bool onlyAbove}) {
      if (activeComponentIds != null && activeComponentIds!.isEmpty) return;

      final compsSample = gridComps[0][0];
      final numComps = compsSample.length;

      for (int compIdx = 0; compIdx < numComps; compIdx++) {
        final vertices = <Offset>[];
        final colors = <Color>[];
        final indices = <int>[];

        final baseColor = compsSample[compIdx].color;
        final aboveColor = baseColor.withOpacity(0.8);
        final belowColor = baseColor.withOpacity(0.3);

        for (int i = 0; i < div; i++) {
          for (int j = 0; j < div; j++) {
            final c1 = gridComps[i][j];
            final c2 = gridComps[i + 1][j];
            final c3 = gridComps[i + 1][j + 1];
            final c4 = gridComps[i][j + 1];

            if (compIdx >= c1.length ||
                compIdx >= c2.length ||
                compIdx >= c3.length ||
                compIdx >= c4.length) continue;

            final z1 = c1[compIdx].value;
            final z2 = c2[compIdx].value;
            final z3 = c3[compIdx].value;
            final z4 = c4[compIdx].value;

            if (onlyAbove && z1 <= 0 && z2 <= 0 && z3 <= 0 && z4 <= 0) continue;

            final p1 = Offset(gridPxBase[i][j], gridPyBase[i][j] - z1 * cTiltScale);
            final p2 = Offset(gridPxBase[i+1][j], gridPyBase[i+1][j] - z2 * cTiltScale);
            final p3 = Offset(gridPxBase[i+1][j+1], gridPyBase[i+1][j+1] - z3 * cTiltScale);
            final p4 = Offset(gridPxBase[i][j+1], gridPyBase[i][j+1] - z4 * cTiltScale);

            final color = onlyAbove ? aboveColor : belowColor;

            final int startIdx = vertices.length;
            vertices.addAll([p1, p2, p3, p4]);
            colors.addAll([color, color, color, color]);
            indices.addAll([
              startIdx, startIdx + 1, startIdx + 2,
              startIdx, startIdx + 2, startIdx + 3,
            ]);
          }
        }

        if (vertices.isNotEmpty) {
          final v = Vertices(
            VertexMode.triangles,
            vertices,
            colors: colors,
            indices: indices,
          );
          canvas.drawVertices(v, BlendMode.srcOver, Paint());
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
      // Since screenX is often 8.0, and with div=90, range=10, 
      // the index for x=8.0 is exactly 81.
      final screenIdx = ((screenX + 10) * div / 20).round();
      final useGridForScreen = (screenIdx >= 0 && screenIdx <= div);

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

      // Draw intersection line independently if requested
      if (showIntersectionLine) {
        final intersectionPath = Path();
        bool isFirst = true;
        for (int j = 0; j <= div; j++) {
          final Offset p;
          if (useGridForScreen) {
            p = gridPoints[screenIdx][j];
          } else {
            final y = -range + j * step;
            final z = field.z(screenX, y, time);
            p = worldToScreen(screenX, y, z);
          }
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
          final double z;
          final double y = -range + j * step;
          if (useGridForScreen) {
            // Need to get the total z, which might be different from individual components
            z = field.z(screenX, y, time);
          } else {
            z = field.z(screenX, y, time);
          }
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

      final compsSample = gridComps[0][0];
      final numComps = compsSample.length;

      if (numComps > 0 && (activeComponentIds == null || activeComponentIds!.isNotEmpty)) {
        final patternPaint = Paint()
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

        for (int compIdx = 0; compIdx < numComps; compIdx++) {
          final path = Path();
          bool isFirst = true;

          for (int j = 0; j <= div; j++) {
            final double z;
            final List<WaveComponent> comps;
            if (useGridForScreen) {
              comps = gridComps[screenIdx][j];
            } else {
              final y = -range + j * step;
              comps = getComponents(screenX, y);
            }
            
            if (compIdx >= comps.length) continue;
            
            z = comps[compIdx].value;
            final p = worldToScreen(screenX, -range + j * step, z);
            
            if (isFirst) {
              path.moveTo(p.dx, p.dy);
              isFirst = false;
            } else {
              path.lineTo(p.dx, p.dy);
            }
          }
          final compsAtEnd = useGridForScreen ? gridComps[screenIdx][div] : getComponents(screenX, range);
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
    // We can't easily use gridPoints for mesh lines because mesh lines are at integer coordinates
    // while gridPoints are at div steps. However, since range=10 and div=90, 
    // step = 20/90 = 2/9. Integer coordinates like -10, -9... 10 are at i = (x+10)/step
    // (x+10)/(2/9) = (x+10)*9/2. 
    // For x=-10, i=0. For x=-8, i=9. For x=0, i=45. For x=10, i=90.
    // All integer coordinates from -10 to 10 are included in the 90-div grid!
    // So we can use gridPoints directly.

    for (int xInt = -intRange; xInt <= intRange; xInt++) {
      final i = ((xInt + 10) * div / 20).round();
      final path = Path();
      bool isFirst = true;
      for (int j = 0; j <= div; j++) {
        final p = gridPoints[i][j];
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
      final j = ((yInt + 10) * div / 20).round();
      final path = Path();
      bool isFirst = true;
      for (int i = 0; i <= div; i++) {
        final p = gridPoints[i][j];
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
          final phase1 = getPhase(x, y1);
          if (math.sin(phase1) > 0.98) {
            final p1 = gridPoints[i][j];
            final p2 = gridPoints[i][j+1];
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

