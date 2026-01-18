import 'package:flutter/material.dart';
import '../fields/wave_fields.dart';
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

  @override
  void paint(Canvas canvas, Size size) {
    // 背景
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFF7F7FB));

    final center = Offset(size.width / 2, size.height / 2);
    // スケール: 1ユニット = 30ピクセル程度 (サイズに合わせて調整)
    final double unitScale = (size.width / 12) * scale; 

    Offset worldToScreen(double x, double y) {
      return Offset(center.dx + x * unitScale, center.dy - y * unitScale * 2); // yは強調表示
    }

    const range = 5.0;

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

    // 1. 軸と目盛り
    final axisPaint = Paint()..color = Colors.black45..strokeWidth = 1.0;
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

    // 事前に各点のコンポーネント値を計算
    // [componentIndex][sampleIndex]
    final List<List<Offset>> paths = [];
    final List<Color> colors = [];

    for (int i = 0; i <= samples; i++) {
      final x = -range + i * step;
      final components = getComponents(x);
      
      if (i == 0) {
        for (var comp in components) {
          paths.add([worldToScreen(x, comp.value)]);
          colors.add(comp.color);
        }
      } else {
        for (int j = 0; j < components.length; j++) {
          if (j < paths.length) {
            paths[j].add(worldToScreen(x, components[j].value));
          }
        }
      }
    }

    for (int j = 0; j < paths.length; j++) {
      final paint = Paint()
        ..color = colors[j]
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      final path = Path();
      path.moveTo(paths[j][0].dx, paths[j][0].dy);
      for (int i = 1; i < paths[j].length; i++) {
        path.lineTo(paths[j][i].dx, paths[j][i].dy);
      }
      canvas.drawPath(path, paint);
    }

    // 4. マーカーの描画
    final markerStroke = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (final m in markers) {
      final comps = getComponents(m.point.x);
      if (comps.isEmpty) continue;
      final double mz = comps.last.value;
      final p = worldToScreen(m.point.x, mz);
      final markerPaint = Paint()
        ..color = m.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p, 6.0, markerPaint);
      canvas.drawCircle(p, 6.0, markerStroke);
    }
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
        oldDelegate.markers != markers;
  }
}

