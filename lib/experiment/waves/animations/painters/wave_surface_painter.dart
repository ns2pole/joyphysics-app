import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart' hide Column, Vertices;
import 'package:flutter/material.dart' as material;

import '../fields/wave_fields.dart';
import '../utils/coordinate_transformer.dart';

/// 節線・腹線の世界座標線分キャッシュ（metric は時間非依存）。
class _ZeroContourCache {
  static final Map<int, Float32List> _byTag = {};
  static WaveField? _field;
  static int? _div;
  static double? _range;

  static Float32List segments({
    required WaveField field,
    required int tag,
    required int div,
    required double range,
    required double Function(double x, double y) metric,
  }) {
    if (_field != field || _div != div || _range != range) {
      _field = field;
      _div = div;
      _range = range;
      _byTag.clear();
    }
    final cached = _byTag[tag];
    if (cached != null) return cached;
    final built = _march(div: div, range: range, metric: metric);
    _byTag[tag] = built;
    return built;
  }

  static Float32List _march({
    required int div,
    required double range,
    required double Function(double x, double y) metric,
  }) {
    final n = div + 1;
    final step = (range * 2) / div;
    final grid = Float32List(n * n);
    for (int i = 0; i < n; i++) {
      final x = -range + i * step;
      for (int j = 0; j < n; j++) {
        grid[i * n + j] = metric(x, -range + j * step);
      }
    }

    final out = <double>[];
    void addCrossing(
      double x0,
      double y0,
      double f0,
      double x1,
      double y1,
      double f1,
      List<double> buf,
    ) {
      if (f0 == 0.0) {
        buf.add(x0);
        buf.add(y0);
        return;
      }
      if (f1 == 0.0) {
        buf.add(x1);
        buf.add(y1);
        return;
      }
      if (f0 * f1 > 0) return;
      final t = f0 / (f0 - f1);
      buf.add(x0 + t * (x1 - x0));
      buf.add(y0 + t * (y1 - y0));
    }

    final cross = <double>[];
    for (int i = 0; i < div; i++) {
      final x0 = -range + i * step;
      final x1 = x0 + step;
      for (int j = 0; j < div; j++) {
        final y0 = -range + j * step;
        final y1 = y0 + step;
        final f00 = grid[i * n + j];
        final f10 = grid[(i + 1) * n + j];
        final f11 = grid[(i + 1) * n + (j + 1)];
        final f01 = grid[i * n + (j + 1)];
        cross.clear();
        addCrossing(x0, y0, f00, x1, y0, f10, cross);
        addCrossing(x1, y0, f10, x1, y1, f11, cross);
        addCrossing(x1, y1, f11, x0, y1, f01, cross);
        addCrossing(x0, y1, f01, x0, y0, f00, cross);
        if (cross.length >= 4) {
          out.add(cross[0]);
          out.add(cross[1]);
          out.add(cross[2]);
          out.add(cross[3]);
        }
        if (cross.length >= 8) {
          out.add(cross[4]);
          out.add(cross[5]);
          out.add(cross[6]);
          out.add(cross[7]);
        }
      }
    }
    return Float32List.fromList(out);
  }
}

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

/// 波源→観測点方向に沿った1次元断面波形の指定
class RadialCrossSectionSpec {
  const RadialCrossSectionSpec({
    required this.start,
    required this.end,
    required this.zAt,
    this.color = Colors.deepPurple,
  });

  final math.Point<double> start;
  final math.Point<double> end;
  /// その断面で描く変位（干渉では各波源成分を渡す）
  final double Function(double x, double y) zAt;
  final Color color;
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
    this.showScreen = true,
    this.scale = 1.0,
    this.radialCrossSections = const [],
    this.showCrossSectionSum = true,
    this.showNodalLines = false,
    this.nodalMetric,
    this.showAntinodalLines = false,
    this.antinodalMetric,
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
  final List<WaveMarker> markers;
  final Set<String>? activeComponentIds;
  final bool showYoungDoubleSlitExtras;
  final double slitA;
  final double screenX;
  final bool showIntersectionLine;
  final bool showIntensityLine;
  final bool showScreen;
  final double scale;
  /// 波源→観測点方向の1次元断面（複数可）
  final List<RadialCrossSectionSpec> radialCrossSections;
  /// 同一観測点で複数断面があるとき、合成変位を青の縦線で表示する
  final bool showCrossSectionSum;
  /// 弱め合いの節線（nodalMetric のゼロ等高線）
  final bool showNodalLines;
  /// ゼロが節線となる指標（例: cos(δ/2)）
  final double Function(double x, double y)? nodalMetric;
  /// 強め合いの腹線（antinodalMetric のゼロ等高線）
  final bool showAntinodalLines;
  /// ゼロが腹線となる指標（例: sin(δ/2)）
  final double Function(double x, double y)? antinodalMetric;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF7F7FB),
    );

    final transformer = WaveCoordinateTransformer(
      size: size,
      scale: scale,
      is3D: true,
      azimuth: azimuth,
      tilt: tilt,
    );
    final unitScale = transformer.unitScale;
    final center = transformer.center;

    final sTilt = math.sin(tilt);
    final cTilt = math.cos(tilt);
    final cAzimuth = math.cos(azimuth);
    final sAzimuth = math.sin(azimuth);
    final cos45Scale = WaveCoordinateTransformer.cos45 * unitScale;
    final cos45STiltScale = cos45Scale * sTilt;
    final cTiltScale = cTilt * unitScale;

    Offset worldToScreen(double x, double y, double z) =>
        transformer.worldToScreen(x, y, z);

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

    const range = 5.0;
    const div = 140;
    const step = (range * 2) / div;

    // Pre-calculate grid bases for efficiency
    final numPoints = div + 1;
    final gridPxBase = Float64List(numPoints * numPoints);
    final gridPyBase = Float64List(numPoints * numPoints);
    final gridZ = Float64List(numPoints * numPoints);
    final gridComps = List<List<WaveComponent>>.generate(numPoints * numPoints, (_) => []);
    
    for (int i = 0; i < numPoints; i++) {
      final x = -range + i * step;
      final x_cAzimuth = x * cAzimuth;
      final x_sAzimuth = x * sAzimuth;
      for (int j = 0; j < numPoints; j++) {
        final y = -range + j * step;
        final xr = x_cAzimuth - y * sAzimuth;
        final yr = x_sAzimuth + y * cAzimuth;
        final idx = i * numPoints + j;
        gridPxBase[idx] = center.dx + (yr - xr) * cos45Scale;
        gridPyBase[idx] = center.dy + (xr + yr) * cos45STiltScale;
        
        final comps = getComponents(x, y);
        gridComps[idx] = comps;
        if (comps.isNotEmpty) {
          gridZ[idx] = field.z(x, y, time);
        }
      }
    }

    // Grid points for total wave (pre-calculated for mesh lines and slab)
    final gridPoints = List.generate(
      numPoints,
      (i) => List<Offset>.filled(numPoints, Offset.zero),
    );
    for (int i = 0; i < numPoints; i++) {
      for (int j = 0; j < numPoints; j++) {
        final idx = i * numPoints + j;
        gridPoints[i][j] = Offset(gridPxBase[idx], gridPyBase[idx] - gridZ[idx] * cTiltScale);
      }
    }

    void drawWaveSurface({required bool onlyAbove}) {
      if (activeComponentIds != null && activeComponentIds!.isEmpty) return;

      final firstComps = gridComps[0];
      final numComps = firstComps.length;
      if (numComps == 0) return;

      final paint = Paint()..isAntiAlias = true;

      for (int compIdx = 0; compIdx < numComps; compIdx++) {
        final vertices = <Offset>[];
        final colors = <Color>[];
        final indices = <int>[];

        final baseColor = firstComps[compIdx].color;
        final colorAbove = baseColor.withOpacity(0.8);
        final colorBelow = baseColor.withOpacity(0.3);

        for (int i = 0; i < div; i++) {
          for (int j = 0; j < div; j++) {
            final idx1 = i * numPoints + j;
            final idx2 = (i + 1) * numPoints + j;
            final idx3 = (i + 1) * numPoints + (j + 1);
            final idx4 = i * numPoints + (j + 1);

            final c1 = gridComps[idx1];
            final c2 = gridComps[idx2];
            final c3 = gridComps[idx3];
            final c4 = gridComps[idx4];

            if (compIdx >= c1.length || compIdx >= c2.length || 
                compIdx >= c3.length || compIdx >= c4.length) continue;

            final z1 = c1[compIdx].value;
            final z2 = c2[compIdx].value;
            final z3 = c3[compIdx].value;
            final z4 = c4[compIdx].value;

            if (onlyAbove && z1 <= 0 && z2 <= 0 && z3 <= 0 && z4 <= 0) continue;

            final p1 = Offset(gridPxBase[idx1], gridPyBase[idx1] - z1 * cTiltScale);
            final p2 = Offset(gridPxBase[idx2], gridPyBase[idx2] - z2 * cTiltScale);
            final p3 = Offset(gridPxBase[idx3], gridPyBase[idx3] - z3 * cTiltScale);
            final p4 = Offset(gridPxBase[idx4], gridPyBase[idx4] - z4 * cTiltScale);

            final color = onlyAbove ? colorAbove : colorBelow;
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
          canvas.drawVertices(v, BlendMode.srcOver, paint);
        }
      }
    }

    // Pass 1: full surface
    drawWaveSurface(onlyAbove: false);

    // z=0 plane
    final planePaint = Paint()
      ..color = const Color(0xFF777777).withOpacity(0.15)
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
      final barrierX = -4.0;

      // 1. Barrier at x = -4
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

      // 2. Screen at x=screenX (4.0)
      if (showScreen) {
        final screenPaint = Paint()
          ..color = Colors.purple.withOpacity(0.3)
          ..style = PaintingStyle.fill;
        final s1 = worldToScreen(screenX, -range, -bH);
        final s2 = worldToScreen(screenX, range, -bH);
        final s3 = worldToScreen(screenX, range, bH);
        final s4 = worldToScreen(screenX, -range, bH);
        canvas.drawPath(
            Path()
              ..moveTo(s1.dx, s1.dy)
              ..lineTo(s2.dx, s2.dy)
              ..lineTo(s3.dx, s3.dy)
              ..lineTo(s4.dx, s4.dy)
              ..close(),
            screenPaint);
      }

      // 3. Interference pattern on the screen (x=screenX)
      final screenIdx = ((screenX + 5) * div / 10).round();
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

      if (showScreen) {
        final b1 = worldToScreen(screenX, -range, 0);
        final b2 = worldToScreen(screenX, range, 0);
        canvas.drawLine(b1, b2, baseLinePaint);
      }

      // Draw intersection line independently if requested
      if (showIntersectionLine && showScreen) {
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
      if (showIntensityLine && showScreen) {
        final intensityPath = Path();
        bool isFirst = true;
        for (int j = 0; j <= div; j++) {
          final double z;
          final double y = -range + j * step;
          if (useGridForScreen) {
            z = field.z(screenX, y, time);
          } else {
            z = field.z(screenX, y, time);
          }
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

      final firstComps = gridComps[0];
      final numComps = firstComps.length;

      if (showScreen && numComps > 0 && (activeComponentIds == null || activeComponentIds!.isNotEmpty)) {
        final patternPaint = Paint()
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

        for (int compIdx = 0; compIdx < numComps; compIdx++) {
          final path = Path();
          bool isFirst = true;

          for (int j = 0; j <= div; j++) {
            final List<WaveComponent> comps;
            if (useGridForScreen) {
              comps = gridComps[screenIdx * numPoints + j];
            } else {
              final y = -range + j * step;
              comps = getComponents(screenX, y);
            }
            
            if (compIdx >= comps.length) continue;
            
            final double z = comps[compIdx].value;
            final p = worldToScreen(screenX, -range + j * step, z);
            
            if (isFirst) {
              path.moveTo(p.dx, p.dy);
              isFirst = false;
            } else {
              path.lineTo(p.dx, p.dy);
            }
          }
          final List<WaveComponent> compsAtEnd;
          if (useGridForScreen) {
            compsAtEnd = gridComps[screenIdx * numPoints + div];
          } else {
            compsAtEnd = getComponents(screenX, range);
          }
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
          final phase1 = getPhase(x, -range + j * step);
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
      final negEnd = worldToScreen(-4.0, 0, 0);
      
      final posPaint = Paint()
        ..color = color.withOpacity(0.8)
        ..strokeWidth = 2.5;
      
      canvas.drawLine(start, posEnd, posPaint);
      
      final negPaint = Paint()
        ..color = color.withOpacity(0.6)
        ..strokeWidth = 2.0;
      
      const dashLen = 0.4;
      double curX = 0.0;
      while (curX > -4.0) {
        final nextX = math.max(curX - dashLen, -4.0);
        canvas.drawLine(
          worldToScreen(curX, 0, 0),
          worldToScreen(nextX, 0, 0),
          negPaint,
        );
        curX -= dashLen * 2;
      }

      if (showTicks) {
        final tickPaint = Paint()
          ..color = color.withOpacity(0.6)
          ..strokeWidth = 1.5;
        for (int i = -4; i <= 5; i++) {
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

    // 節線・腹線: metric のゼロ等高線を z=0 上に描く。
    // 注意: 曲面グリッド(div=140)と同じ解像度で毎フレーム・点線細分化すると
    // UIスレッドが詰まって ANR（応答していません）になる。
    // metric は時間非依存なので世界座標の線分をキャッシュし、粗いグリッドで計算する。
    void drawZeroContours({
      required double Function(double x, double y) metric,
      required Color color,
      required bool dashed,
      required int cacheTag,
    }) {
      const contourDiv = 48;
      final segs = _ZeroContourCache.segments(
        field: field,
        tag: cacheTag,
        div: contourDiv,
        range: range,
        metric: metric,
      );

      final paint = Paint()
        ..color = color
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;

      const dashLen = 12.0;
      const gapLen = 10.0;
      const pattern = dashLen + gapLen;

      for (int k = 0; k + 3 < segs.length; k += 4) {
        final a = worldToScreen(segs[k], segs[k + 1], 0);
        final b = worldToScreen(segs[k + 2], segs[k + 3], 0);
        if (!dashed) {
          canvas.drawLine(a, b, paint);
          continue;
        }
        // セル長の短い線分を while で点線分割すると drawCall 爆発→ANR。
        // 始点の射影位相で「描く／飛ばす」を決め、線分あたり最大1回だけ描く。
        final dx = b.dx - a.dx;
        final dy = b.dy - a.dy;
        final len = math.sqrt(dx * dx + dy * dy);
        if (len < 0.35) continue;
        final ux = dx / len;
        final uy = dy / len;
        var inPat = (a.dx * ux + a.dy * uy) % pattern;
        if (inPat < 0) inPat += pattern;
        if (inPat < dashLen) {
          canvas.drawLine(a, b, paint);
        }
      }
    }

    // 観測点(赤)・波源(黄)・曲面(紫)と被らないオレンジ
    const nodalColor = Color(0xFFFB8C00);
    if (showNodalLines && nodalMetric != null) {
      drawZeroContours(
        metric: nodalMetric!,
        color: nodalColor,
        dashed: true,
        cacheTag: 1,
      );
    }
    if (showAntinodalLines && antinodalMetric != null) {
      drawZeroContours(
        metric: antinodalMetric!,
        color: nodalColor,
        dashed: false,
        cacheTag: 2,
      );
    }

    // 波源〜観測点を結ぶ方向の断面波形（切断平面 + z=0上の基線 + 各成分の変位曲線）
    void drawOneCrossSection(RadialCrossSectionSpec spec) {
      final sx = spec.start.x;
      final sy = spec.start.y;
      final ex = spec.end.x;
      final ey = spec.end.y;
      final dx = ex - sx;
      final dy = ey - sy;
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist <= 1e-6) return;

      final ux = dx / dist;
      final uy = dy / dist;

      // xy 上の直線を可視領域 [-range, range]^2 でクリップ（両方向＝無限平面の足元）
      double tMin = double.negativeInfinity;
      double tMax = double.infinity;
      if (ux.abs() > 1e-9) {
        final tA = (-range - sx) / ux;
        final tB = (range - sx) / ux;
        tMin = math.max(tMin, math.min(tA, tB));
        tMax = math.min(tMax, math.max(tA, tB));
      } else if (sx < -range || sx > range) {
        return;
      }
      if (uy.abs() > 1e-9) {
        final tA = (-range - sy) / uy;
        final tB = (range - sy) / uy;
        tMin = math.max(tMin, math.min(tA, tB));
        tMax = math.min(tMax, math.max(tA, tB));
      } else if (sy < -range || sy > range) {
        return;
      }
      if (!tMin.isFinite || !tMax.isFinite || tMax <= tMin) return;

      final x0 = sx + tMin * ux;
      final y0 = sy + tMin * uy;
      final x1 = sx + tMax * ux;
      final y1 = sy + tMax * uy;

      // z軸に平行な半透明の切断平面（xyは直線で拘束）
      const zExtent = 2.8;
      final cuttingPlanePaint = Paint()
        ..color = spec.color.withOpacity(0.22)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      final c1 = worldToScreen(x0, y0, -zExtent);
      final c2 = worldToScreen(x1, y1, -zExtent);
      final c3 = worldToScreen(x1, y1, zExtent);
      final c4 = worldToScreen(x0, y0, zExtent);
      final cuttingPath = Path()
        ..moveTo(c1.dx, c1.dy)
        ..lineTo(c2.dx, c2.dy)
        ..lineTo(c3.dx, c3.dy)
        ..lineTo(c4.dx, c4.dy)
        ..close();
      canvas.drawPath(cuttingPath, cuttingPlanePaint);
      canvas.drawPath(
        cuttingPath,
        Paint()
          ..color = spec.color.withOpacity(0.40)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

      final basePaint = Paint()
        ..color = spec.color.withOpacity(0.55)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        worldToScreen(x0, y0, 0),
        worldToScreen(x1, y1, 0),
        basePaint,
      );

      // 切断平面上の変位曲線（領域内の直線全体）
      final sectionPaint = Paint()
        ..color = spec.color
        ..strokeWidth = 3.2
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true;
      final sectionPath = Path();
      const samples = 160;
      for (int i = 0; i <= samples; i++) {
        final tParam = tMin + (tMax - tMin) * i / samples;
        final x = sx + tParam * ux;
        final y = sy + tParam * uy;
        final z = spec.zAt(x, y);
        final p = worldToScreen(x, y, z);
        if (i == 0) {
          sectionPath.moveTo(p.dx, p.dy);
        } else {
          sectionPath.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(sectionPath, sectionPaint);
    }

    for (final spec in radialCrossSections) {
      drawOneCrossSection(spec);
    }

    // 観測点の合成変位（z軸平行・青単色）
    if (showCrossSectionSum && radialCrossSections.isNotEmpty) {
      final obs = radialCrossSections.first.end;
      final sameEnd = radialCrossSections.every(
        (s) =>
            (s.end.x - obs.x).abs() < 1e-9 && (s.end.y - obs.y).abs() < 1e-9,
      );
      if (sameEnd) {
        double sumZ = 0.0;
        for (final spec in radialCrossSections) {
          sumZ += spec.zAt(obs.x, obs.y);
        }
        canvas.drawLine(
          worldToScreen(obs.x, obs.y, 0),
          worldToScreen(obs.x, obs.y, sumZ),
          Paint()
            ..color = Colors.blueAccent
            ..strokeWidth = 3.2
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round,
        );
        final tip = worldToScreen(obs.x, obs.y, sumZ);
        canvas.drawCircle(
          tip,
          4.5,
          Paint()..color = Colors.blueAccent,
        );
        canvas.drawCircle(
          tip,
          4.5,
          Paint()
            ..color = Colors.black54
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );
      }
    }

    final markerStroke = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    bool sameXy(math.Point<double> a, math.Point<double> b) =>
        (a.x - b.x).abs() < 1e-9 && (a.y - b.y).abs() < 1e-9;

    for (final m in markers) {
      final comps = getComponents(m.point.x, m.point.y);
      double? mz;
      if (comps.isNotEmpty) {
        mz = comps.last.value;
      } else {
        // 合成波などがオフでも、対応する断面があれば波源・観測点を残す
        final matchingStarts = radialCrossSections
            .where((s) => sameXy(s.start, m.point))
            .toList();
        if (matchingStarts.isNotEmpty) {
          mz = matchingStarts.first.zAt(m.point.x, m.point.y);
        } else {
          final matchingEnds = radialCrossSections
              .where((s) => sameXy(s.end, m.point))
              .toList();
          if (matchingEnds.isNotEmpty) {
            mz = matchingEnds.fold<double>(
              0.0,
              (sum, s) => sum + s.zAt(m.point.x, m.point.y),
            );
          }
        }
      }
      if (mz == null) continue;
      final p = worldToScreen(m.point.x, m.point.y, mz);
      final markerPaint = Paint()
        ..color = m.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p, 6.0, markerPaint);
      canvas.drawCircle(p, 6.0, markerStroke);

      if (m.label != null) {
        final span = TextSpan(
          style: TextStyle(
              color: m.color.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.white70),
          text: m.label,
        );
        final tp = TextPainter(text: span, textDirection: TextDirection.ltr)
          ..layout();
        tp.paint(canvas, p + const Offset(8, -20));
      }
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
        oldDelegate.showIntensityLine != showIntensityLine ||
        oldDelegate.showScreen != showScreen ||
        oldDelegate.scale != scale ||
        oldDelegate.showCrossSectionSum != showCrossSectionSum ||
        oldDelegate.showNodalLines != showNodalLines ||
        oldDelegate.showAntinodalLines != showAntinodalLines ||
        oldDelegate.radialCrossSections.length != radialCrossSections.length ||
        !_sameCrossSections(oldDelegate.radialCrossSections, radialCrossSections);
  }

  static bool _sameCrossSections(
    List<RadialCrossSectionSpec> a,
    List<RadialCrossSectionSpec> b,
  ) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].start != b[i].start ||
          a[i].end != b[i].end ||
          a[i].color != b[i].color) {
        return false;
      }
    }
    return true;
  }
}
