import 'package:flutter/material.dart';
import '../fields/wave_fields.dart';
import '../utils/coordinate_transformer.dart';
import 'wave_surface_painter.dart';

class WaveLinePainter extends CustomPainter {
  WaveLinePainter({
    required this.time,
    required this.field,
    required this.surfaceColor,
    this.showTicks = true,
    this.boundaryX = 5.0,
    this.showBoundaryLine = false,
    this.mediumSlab,
    this.activeComponentIds,
    this.scale = 1.0,
    this.markers = const [],
    this.componentAxisOffsets = const {},
    this.componentAxisLabels = const {},
  });

  final double time;
  final WaveField field;
  final Color surfaceColor;
  final bool showTicks;
  final double boundaryX;
  final bool showBoundaryLine;
  final MediumSlabOverlay? mediumSlab;
  final Set<String>? activeComponentIds;
  final double scale;
  final List<WaveMarker> markers;

  /// 成分ごとの描画軸（y=0 からのずれ）。入射を上・反射を下に分けるときなどに使う。
  final Map<String, double> componentAxisOffsets;
  final Map<String, String> componentAxisLabels;

  static double plotY(
    double value,
    String id,
    Map<String, double> offsets,
  ) {
    return value + (offsets[id] ?? 0.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 背景
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFF7F7FB));

    final transformer = WaveCoordinateTransformer(
      size: size,
      scale: scale,
      is3D: false,
    );
    final center = transformer.center;
    final double unitScale = transformer.unitScale;

    Offset worldToScreen(double x, double y) => transformer.worldToScreen(x, 0.0, y);

    const range = WaveCoordinateTransformer.lineWorldHalfRange;

    // 0. 媒質背景 (Slab)
    if (mediumSlab != null) {
      final slab = mediumSlab!;
      final slabPaint = Paint()
        ..color = slab.color.withOpacity(slab.opacity)
        ..style = PaintingStyle.fill;
      
      final rect = Rect.fromPoints(
        worldToScreen(slab.xStart, -5.0), // 十分な高さ
        worldToScreen(slab.xEnd, 5.0),
      );
      canvas.drawRect(rect, slabPaint);
    }

    // 1. 軸と目盛り（成分軸があるときは中央 x 軸は位置の目安）
    final axisPaint = Paint()
      ..color = componentAxisOffsets.isEmpty ? Colors.black45 : Colors.black26
      ..strokeWidth = 1.0;
    canvas.drawLine(worldToScreen(-range, 0), worldToScreen(range, 0), axisPaint); // x軸
    canvas.drawLine(worldToScreen(0, -2), worldToScreen(0, 2), axisPaint); // y軸

    if (showTicks) {
      for (int i = -5; i <= 5; i++) {
        final p1 = worldToScreen(i.toDouble(), -0.1);
        final p2 = worldToScreen(i.toDouble(), 0.1);
        canvas.drawLine(p1, p2, axisPaint);

        final span = TextSpan(
          style: const TextStyle(color: Colors.black54, fontSize: 10),
          text: i.toString(),
        );
        final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
        tp.paint(canvas, p2 + const Offset(-5, 2));
      }
    }

    List<WaveComponent> getComponents(double x) {
      if (activeComponentIds == null) {
        return [
          WaveComponent(
            id: 'total',
            label: '合成波',
            color: surfaceColor,
            value: field.z(x, 0, time),
          ),
        ];
      }
      return field.getComponents(x, 0, time, activeComponentIds!);
    }

    // 成分ごとの描画軸（入射・反射の軸分けなど）
    if (componentAxisOffsets.isNotEmpty) {
      final xEnd = showBoundaryLine && boundaryX < range ? boundaryX : range;
      if (xEnd > -range) {
        final probeX = xEnd < range ? (xEnd + -range) / 2 : -range;
        final probe = field.getComponents(
          probeX,
          0,
          time,
          componentAxisOffsets.keys.toSet(),
        );
        final colorById = {for (final c in probe) c.id: c.color};
        for (final entry in componentAxisOffsets.entries) {
          final y0 = entry.value;
          final color = colorById[entry.key] ?? Colors.black45;
          final splitAxisPaint = Paint()
            ..color = color.withOpacity(0.55)
            ..strokeWidth = 1.2;
          canvas.drawLine(
            worldToScreen(-range, y0),
            worldToScreen(xEnd, y0),
            splitAxisPaint,
          );
          final label = componentAxisLabels[entry.key];
          if (label != null) {
            final span = TextSpan(
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.white70,
              ),
              text: label,
            );
            final tp = TextPainter(text: span, textDirection: TextDirection.ltr)
              ..layout();
            final p = worldToScreen(-range, y0);
            tp.paint(canvas, p + const Offset(6, -16));
          }
        }
      }
    }

    // 2. 境界線 (もし指定されていれば)
    if (showBoundaryLine) {
      final boundaryPaint = Paint()
        ..color = Colors.yellow.withOpacity(0.8)
        ..strokeWidth = 4.0;
      canvas.drawLine(worldToScreen(boundaryX, -2.5),
          worldToScreen(boundaryX, 2.5), boundaryPaint);
    }

    // 3. 波の描画 (複数成分対応)
    const samples = 400;
    const step = (range * 2) / samples;

    // セレクタが指定されているのに何も選択されていない場合は描画しない
    if (activeComponentIds != null && activeComponentIds!.isEmpty) return;

    // 事前に各点のコンポーネント値を計算
    // [componentIndex][sampleIndex]
    final List<List<Offset>> paths = [];
    final List<Color> colors = [];
    final List<String> ids = [];

    for (int i = 0; i <= samples; i++) {
      final x = -range + i * step;
      final components = getComponents(x);
      if (components.isEmpty) continue;

      if (paths.isEmpty) {
        for (var comp in components) {
          paths.add([
            worldToScreen(x, plotY(comp.value, comp.id, componentAxisOffsets)),
          ]);
          colors.add(comp.color);
          ids.add(comp.id);
        }
      } else {
        for (int j = 0; j < components.length; j++) {
          if (j < paths.length) {
            paths[j].add(worldToScreen(
              x,
              plotY(components[j].value, components[j].id, componentAxisOffsets),
            ));
          }
        }
      }
    }

    // 合成波があるときだけ構成波を控えめにし、合成波を上に描く
    final emphasizeComposite = ids.any(_isCompositeComponentId);

    void drawWave(int j) {
      if (paths[j].isEmpty) return;
      final isComposite = _isCompositeComponentId(ids[j]);
      final fadeComponent = emphasizeComposite && !isComposite;
      final paint = Paint()
        ..color = fadeComponent ? colors[j].withOpacity(0.85) : colors[j]
        ..strokeWidth = fadeComponent ? 2.0 : 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(paths[j][0].dx, paths[j][0].dy);
      for (int i = 1; i < paths[j].length; i++) {
        path.lineTo(paths[j][i].dx, paths[j][i].dy);
      }
      canvas.drawPath(path, paint);
    }

    for (int j = 0; j < paths.length; j++) {
      if (!_isCompositeComponentId(ids[j])) drawWave(j);
    }
    for (int j = 0; j < paths.length; j++) {
      if (_isCompositeComponentId(ids[j])) drawWave(j);
    }

    // 4. マーカーの描画
    final markerStroke = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (final m in markers) {
      final comps = getComponents(m.point.x);
      if (comps.isEmpty) continue;

      final marked = componentAxisOffsets.isEmpty ? [comps.last] : comps;
      Offset? labelAt;
      var labelY = -double.infinity;
      for (final comp in marked) {
        final mz = plotY(comp.value, comp.id, componentAxisOffsets);
        final p = worldToScreen(m.point.x, mz);
        final markerPaint = Paint()
          ..color = m.color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(p, 6.0, markerPaint);
        canvas.drawCircle(p, 6.0, markerStroke);
        if (mz >= labelY) {
          labelY = mz;
          labelAt = p;
        }
      }

      if (m.label != null && labelAt != null) {
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
        tp.paint(canvas, labelAt + const Offset(8, -20));
      }
    }
  }

  static bool _isCompositeComponentId(String id) {
    return id == 'combined' ||
        id == 'total' ||
        id == 'combinedReflected';
  }

  @override
  bool shouldRepaint(covariant WaveLinePainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.field != field ||
        oldDelegate.surfaceColor != surfaceColor ||
        oldDelegate.boundaryX != boundaryX ||
        oldDelegate.showBoundaryLine != showBoundaryLine ||
        oldDelegate.mediumSlab != mediumSlab ||
        oldDelegate.activeComponentIds != activeComponentIds ||
        oldDelegate.scale != scale ||
        oldDelegate.markers != markers ||
        oldDelegate.componentAxisOffsets != componentAxisOffsets ||
        oldDelegate.componentAxisLabels != componentAxisLabels;
  }
}

