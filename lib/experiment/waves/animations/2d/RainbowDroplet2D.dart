import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../widgets/wave_slider.dart';

class _RayOptics {
  static const double dropRadius = 1.0;

  static _RayPath? computeRayPath(double k, double n) {
    final x = k.clamp(0.0, 0.999);
    final alpha = math.asin(x);
    final p1 = Offset(
      -dropRadius * math.cos(alpha),
      dropRadius * math.sin(alpha),
    );

    const incoming = Offset(1, 0);
    final normalAtP1 = _normalize(p1);
    final d1 = _refract(incoming, normalAtP1, 1.0, n);
    if (d1 == null) return null;

    final p2 = _nextCircleIntersection(p1 + d1 * 1e-6, d1, dropRadius);
    if (p2 == null) return null;

    final normalAtP2 = _normalize(p2);
    final d2 = _reflect(d1, normalAtP2);

    final p3 = _nextCircleIntersection(p2 + d2 * 1e-6, d2, dropRadius);
    if (p3 == null) return null;

    final normalAtP3 = _normalize(p3);
    final outDir = _refract(d2, normalAtP3, n, 1.0);
    if (outDir == null) return null;

    return _RayPath(p1: p1, p2: p2, p3: p3, outDir: _normalize(outDir));
  }

  static double phiGeoDegFromPath(_RayPath path) {
    final back = -path.outDir;
    final phi = math.atan2(back.dy.abs(), back.dx.abs());
    return phi * 180.0 / math.pi;
  }

  static double theoryPhiDeg(double k, double n) {
    final x = k.clamp(0.0, 0.999);
    final phiRad = 4.0 * math.asin(x / n) - 2.0 * math.asin(x);
    return phiRad * 180.0 / math.pi;
  }

  static double peakK(double n) => math.sqrt((4.0 - n * n) / 3.0);

  static Offset? horizontalIntersection(Offset p, Offset dir, double y) {
    if (dir.dy.abs() < 1e-9) return null;
    final t = (y - p.dy) / dir.dy;
    return p + dir * t;
  }

  static Offset? _nextCircleIntersection(Offset origin, Offset dir, double r) {
    final a = _dot(dir, dir);
    final b = 2.0 * _dot(origin, dir);
    final c = _dot(origin, origin) - r * r;
    final d = b * b - 4.0 * a * c;
    if (d < 0.0) return null;

    final sqrtD = math.sqrt(d);
    final t1 = (-b - sqrtD) / (2.0 * a);
    final t2 = (-b + sqrtD) / (2.0 * a);
    const eps = 1e-6;

    double? t;
    if (t1 > eps && t2 > eps) {
      t = math.min(t1, t2);
    } else if (t1 > eps) {
      t = t1;
    } else if (t2 > eps) {
      t = t2;
    }
    if (t == null) return null;
    return origin + dir * t;
  }

  static Offset _reflect(Offset v, Offset n) {
    return v - n * (2.0 * _dot(v, n));
  }

  static Offset? _refract(Offset incident, Offset normal, double n1, double n2) {
    final i = _normalize(incident);
    var n = _normalize(normal);
    // n1, n2 は呼び出し側で媒質を指定済みなので、法線は向きだけ合わせる
    if (_dot(i, n) > 0) {
      n = -n;
    }
    final cosI = -_dot(i, n);
    final eta = n1 / n2;
    final k = 1.0 - eta * eta * (1.0 - cosI * cosI);
    if (k < 0.0) return null;
    return i * eta + n * (eta * cosI - math.sqrt(k));
  }

  static Offset _normalize(Offset v) {
    final len = v.distance;
    if (len == 0.0) return Offset.zero;
    return v / len;
  }

  static double _dot(Offset a, Offset b) => a.dx * b.dx + a.dy * b.dy;
}

final rainbowDroplet2D = createWaveVideo(
  title: "虹の光路 (単一水滴)",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>入射パラメータ $k$ を 0 から 1 の範囲で動かし、球状水滴での屈折→内部反射→出射を可視化します。</p>
  <p>赤色光 ($n=1.33$) と青色光 ($n=1.34$) の分散により、出射方向に差が生まれます。</p>
  """,
  simulation: RainbowDroplet2DSimulation(),
  height: 780,
);

class RainbowDroplet2DSimulation extends WaveSimulation {
  RainbowDroplet2DSimulation()
      : super(
          title: "虹の光路 (単一水滴)",
          is3D: false,
          showTimeOverlay: false,
          enableTime: false,
        );

  @override
  Map<String, double> get initialParameters => const {
        'k': 0.82,
        'viewMode': 0.0,
      };

  @override
  List<Widget> buildControls(context, params, updateParam) {
    final metrics = _buildMetrics(params);
    final viewMode = _viewModeFromParams(params);

    return [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ChoiceChip(
            label: const Text('通常'),
            selected: viewMode == _RainbowViewMode.normal,
            onSelected: (_) => updateParam('viewMode', 0.0),
          ),
          ChoiceChip(
            label: const Text('極小水滴'),
            selected: viewMode == _RainbowViewMode.tinyDroplet,
            onSelected: (_) => updateParam('viewMode', 1.0),
          ),
          ChoiceChip(
            label: const Text('出射点拡大'),
            selected: viewMode == _RainbowViewMode.exitZoom,
            onSelected: (_) => updateParam('viewMode', 2.0),
          ),
        ],
      ),
      Text(
        'k = ${metrics.k.toStringAsFixed(3)}   φ_red = ${metrics.redPhiGeo.toStringAsFixed(2)}°   φ_blue = ${metrics.bluePhiGeo.toStringAsFixed(2)}°',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      WaveParameterSlider(
        label: 'k',
        value: metrics.k,
        min: 0.0,
        max: 0.999,
        onChanged: (v) => updateParam('k', v),
      ),
      Text(
        '理論ピーク φ: 赤 ${metrics.redPeakPhi.toStringAsFixed(2)}° / 青 ${metrics.bluePeakPhi.toStringAsFixed(2)}°',
        style: const TextStyle(fontSize: 15, color: Colors.black54),
      ),
      Text(
        '理論との差 |Δφ|: 赤 ${(metrics.redPhiGeo - metrics.redPhiTheory).abs().toStringAsFixed(2)}° / 青 ${(metrics.bluePhiGeo - metrics.bluePhiTheory).abs().toStringAsFixed(2)}°',
        style: const TextStyle(fontSize: 14, color: Colors.black54),
      ),
    ];
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    final k = (params['k'] ?? 0.82).clamp(0.0, 0.999);
    final viewMode = _viewModeFromParams(params);
    return CustomPaint(
      size: Size.infinite,
      painter: _RainbowDropletPainter(k: k, scale: scale, viewMode: viewMode),
    );
  }
  
  _RainbowMetrics _buildMetrics(Map<String, double> params) {
    final k = (params['k'] ?? 0.82).clamp(0.0, 0.999);
    final redPath = _RayOptics.computeRayPath(k, _RainbowDropletPainter.redN);
    final bluePath = _RayOptics.computeRayPath(k, _RainbowDropletPainter.blueN);
    final redPhiGeo = redPath == null ? 0.0 : _RayOptics.phiGeoDegFromPath(redPath);
    final bluePhiGeo =
        bluePath == null ? 0.0 : _RayOptics.phiGeoDegFromPath(bluePath);
    final redPhiTheory = _RayOptics.theoryPhiDeg(k, _RainbowDropletPainter.redN);
    final bluePhiTheory =
        _RayOptics.theoryPhiDeg(k, _RainbowDropletPainter.blueN);
    final redPeakPhi = _RayOptics.theoryPhiDeg(
      _RayOptics.peakK(_RainbowDropletPainter.redN),
      _RainbowDropletPainter.redN,
    );
    final bluePeakPhi = _RayOptics.theoryPhiDeg(
      _RayOptics.peakK(_RainbowDropletPainter.blueN),
      _RainbowDropletPainter.blueN,
    );
    return _RainbowMetrics(
      k: k,
      redPhiGeo: redPhiGeo,
      bluePhiGeo: bluePhiGeo,
      redPhiTheory: redPhiTheory,
      bluePhiTheory: bluePhiTheory,
      redPeakPhi: redPeakPhi,
      bluePeakPhi: bluePeakPhi,
    );
  }

  _RainbowViewMode _viewModeFromParams(Map<String, double> params) {
    final raw = (params['viewMode'] ?? 0.0).round().clamp(0, 2);
    return _RainbowViewMode.values[raw];
  }
}

class _RainbowMetrics {
  final double k;
  final double redPhiGeo;
  final double bluePhiGeo;
  final double redPhiTheory;
  final double bluePhiTheory;
  final double redPeakPhi;
  final double bluePeakPhi;

  const _RainbowMetrics({
    required this.k,
    required this.redPhiGeo,
    required this.bluePhiGeo,
    required this.redPhiTheory,
    required this.bluePhiTheory,
    required this.redPeakPhi,
    required this.bluePeakPhi,
  });
}

class _RayPath {
  final Offset p1;
  final Offset p2;
  final Offset p3;
  final Offset outDir;

  const _RayPath({
    required this.p1,
    required this.p2,
    required this.p3,
    required this.outDir,
  });
}

class _RainbowDropletPainter extends CustomPainter {
  final double k;
  final double scale;
  final _RainbowViewMode viewMode;

  static const double _dropRadius = 1.0;
  static const double redN = 1.33;
  static const double blueN = 1.34;

  static const double _normalRadiusFactor = 0.40;
  static const double _tinyRadiusFactor = 0.018;
  static const double _exitZoomWorldZoom = 2.7;

  const _RainbowDropletPainter({
    required this.k,
    required this.scale,
    required this.viewMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final view = _computeView(size);
    _drawDroplet(canvas, size, view);

    _drawColorPath(
      canvas: canvas,
      size: size,
      worldToScreen: view.worldToScreen,
      refractiveIndex: redN,
      color: Colors.red.withOpacity(0.7),
    );
    _drawColorPath(
      canvas: canvas,
      size: size,
      worldToScreen: view.worldToScreen,
      refractiveIndex: blueN,
      color: Colors.blue.withOpacity(0.7),
    );
  }

  _RainbowView _computeView(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height);

    var radiusFactor = _normalRadiusFactor;
    var worldZoom = 1.0;
    var focusWorld = Offset.zero;
    Offset? exitFocusPoint;

    if (viewMode == _RainbowViewMode.tinyDroplet) {
      radiusFactor = _tinyRadiusFactor;
    } else if (viewMode == _RainbowViewMode.exitZoom) {
      radiusFactor = _normalRadiusFactor;
      worldZoom = _exitZoomWorldZoom;
      final redPath = _RayOptics.computeRayPath(k, redN);
      final bluePath = _RayOptics.computeRayPath(k, blueN);
      exitFocusPoint = redPath?.p3 ?? bluePath?.p3 ?? Offset.zero;
      focusWorld = exitFocusPoint;
    }

    final pixelRadius = baseRadius * radiusFactor;
    final pixelsPerWorld = pixelRadius * scale * worldZoom;

    Offset worldToScreen(Offset p) {
      return Offset(
        center.dx + (p.dx - focusWorld.dx) * pixelsPerWorld,
        center.dy - (p.dy - focusWorld.dy) * pixelsPerWorld,
      );
    }

    return _RainbowView(
      center: center,
      pixelsPerWorld: pixelsPerWorld,
      worldToScreen: worldToScreen,
      exitFocusPoint: exitFocusPoint,
    );
  }

  void _drawDroplet(Canvas canvas, Size size, _RainbowView view) {
    final dropletCenter = view.worldToScreen(Offset.zero);
    final dropletRadius = view.pixelsPerWorld * _dropRadius;

    if (viewMode != _RainbowViewMode.exitZoom) {
      final fill = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF81D4FA).withOpacity(0.35);
      final outline = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.lightBlue.shade200;
      canvas.drawCircle(dropletCenter, dropletRadius, fill);
      canvas.drawCircle(dropletCenter, dropletRadius, outline);
      return;
    }

    // exitZoom: 測角点(p3)を通る境界弧と、水側（円内部）を塗る
    final p3World = view.exitFocusPoint ?? Offset.zero;
    final p3Screen = view.worldToScreen(p3World);

    final circleRect = Rect.fromCircle(center: dropletCenter, radius: dropletRadius);
    final boundaryAngle = math.atan2(
      p3Screen.dy - dropletCenter.dy,
      p3Screen.dx - dropletCenter.dx,
    );

    const span = 1.95; // 境界弧の開き角
    final startAngle = boundaryAngle - span / 2;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF4FC3F7).withOpacity(0.30);
    final boundaryColor = Colors.lightBlue.shade600.withOpacity(0.95);
    final boundaryPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..color = boundaryColor;

    // p3近傍のみ表示（他所に出る大きな弧を抑制）
    final clipSize = math.min(size.width, size.height) * 0.70;
    final localClip =
        Rect.fromCenter(center: p3Screen, width: clipSize, height: clipSize);
    canvas.save();
    canvas.clipRect(localClip);
    canvas.drawCircle(dropletCenter, dropletRadius, fillPaint);
    canvas.drawArc(circleRect, startAngle, span, false, boundaryPaint);
    canvas.restore();
  }

  void _drawColorPath({
    required Canvas canvas,
    required Size size,
    required Offset Function(Offset) worldToScreen,
    required double refractiveIndex,
    required Color color,
  }) {
    final path = _RayOptics.computeRayPath(k, refractiveIndex);
    if (path == null) return;

    final rayPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = color;

    final p1s = worldToScreen(path.p1);
    final p2s = worldToScreen(path.p2);
    final p3s = worldToScreen(path.p3);
    final outDirScreen = worldToScreen(path.p3 + path.outDir) - p3s;
    final isTinyMode = viewMode == _RainbowViewMode.tinyDroplet;

    // 左から水平入射する前置きの線分
    final incidentStart = isTinyMode
        ? _rayToCanvasEdge(p1s, const Offset(-1, 0), size) ?? p1s
        : worldToScreen(Offset(path.p1.dx - 1.3, path.p1.dy));
    _drawArrowedLine(
      canvas,
      incidentStart,
      p1s,
      rayPaint,
      arrowPosition: isTinyMode ? 0.72 : 0.58,
    );

    // 水滴内: 屈折 -> 内部反射 -> 出射点まで
    _drawArrowedLine(
      canvas,
      p1s,
      p2s,
      rayPaint,
    );
    _drawArrowedLine(
      canvas,
      p2s,
      p3s,
      rayPaint,
    );

    // 出射光（実線）
    final exitEnd = isTinyMode
        ? _rayToCanvasEdge(p3s, outDirScreen, size) ?? p3s
        : worldToScreen(path.p3 + path.outDir * 1.6);
    _drawArrowedLine(
      canvas,
      p3s,
      exitEnd,
      rayPaint,
      arrowPosition: isTinyMode ? 0.72 : 0.58,
    );

    final helperPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color.withOpacity(0.85);

    // 出射点を通る水平基準線（点線）
    final horizontalY = p3s.dy;
    final horizontalStart = isTinyMode
        ? Offset(0, horizontalY)
        : worldToScreen(Offset(path.p3.dx - 1.0, path.p3.dy));
    final horizontalEnd = isTinyMode
        ? Offset(size.width, horizontalY)
        : worldToScreen(Offset(path.p3.dx + 1.0, path.p3.dy));
    _drawDashedLine(
      canvas,
      horizontalStart,
      horizontalEnd,
      helperPaint,
    );

    // 出射光の後方延長（点線）
    final backEnd = isTinyMode
        ? _rayToCanvasEdge(p3s, -outDirScreen, size) ?? p3s
        : worldToScreen(path.p3 - path.outDir * 1.0);
    _drawDashedLine(
      canvas,
      p3s,
      backEnd,
      helperPaint,
    );

    if (viewMode == _RainbowViewMode.exitZoom ||
        viewMode == _RainbowViewMode.normal ||
        viewMode == _RainbowViewMode.tinyDroplet) {
      _drawPhiArc(
        canvas,
        vertex: p3s,
        lineDir: const Offset(1, 0),
        rayDir: -outDirScreen,
        color: color,
        arcRadius: (refractiveIndex == redN ? 34.0 : 26.0) * 3.0,
        useVerticalAngle: true,
      );
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    final delta = end - start;
    final len = delta.distance;
    if (len <= 0.0) return;
    final unit = delta / len;
    const dash = 7.0;
    const gap = 5.0;
    double d = 0.0;
    while (d < len) {
      final s = start + unit * d;
      final e = start + unit * math.min(d + dash, len);
      canvas.drawLine(s, e, paint);
      d += dash + gap;
    }
  }

  void _drawArrowedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    {double arrowPosition = 0.58}
  ) {
    canvas.drawLine(start, end, paint);

    final delta = end - start;
    final len = delta.distance;
    if (len <= 1e-6) return;

    final dir = delta / len;
    const arrowLength = 9.0;
    const arrowAngle = 28.0 * math.pi / 180.0;

    final tip = start + delta * arrowPosition;
    final left = tip - _rotate(dir, arrowAngle) * arrowLength;
    final right = tip - _rotate(dir, -arrowAngle) * arrowLength;
    canvas.drawLine(tip, left, paint);
    canvas.drawLine(tip, right, paint);
  }

  Offset _rotate(Offset v, double rad) {
    final c = math.cos(rad);
    final s = math.sin(rad);
    return Offset(
      v.dx * c - v.dy * s,
      v.dx * s + v.dy * c,
    );
  }

  Offset? _rayToCanvasEdge(Offset start, Offset dir, Size size) {
    const eps = 1e-6;
    final dLen = dir.distance;
    if (dLen <= eps) return null;
    final unit = dir / dLen;
    final w = size.width;
    final h = size.height;
    final candidates = <double>[];

    void addT(double t) {
      if (t > eps && t.isFinite) {
        candidates.add(t);
      }
    }

    if (unit.dx.abs() > eps) {
      addT((0 - start.dx) / unit.dx);
      addT((w - start.dx) / unit.dx);
    }
    if (unit.dy.abs() > eps) {
      addT((0 - start.dy) / unit.dy);
      addT((h - start.dy) / unit.dy);
    }
    if (candidates.isEmpty) return null;

    double? bestT;
    for (final t in candidates) {
      final p = start + unit * t;
      final inBounds =
          p.dx >= -0.5 && p.dx <= w + 0.5 && p.dy >= -0.5 && p.dy <= h + 0.5;
      if (!inBounds) continue;
      if (bestT == null || t < bestT) bestT = t;
    }
    if (bestT == null) return null;
    return start + unit * bestT;
  }

  void _drawPhiArc(
    Canvas canvas,
    {
    required Offset vertex,
    required Offset lineDir,
    required Offset rayDir,
    required Color color,
    required double arcRadius,
    bool useVerticalAngle = false,
  }) {
    if (lineDir.distance <= 1e-6 || rayDir.distance <= 1e-6) return;

    final lineAngle = math.atan2(lineDir.dy, lineDir.dx);
    final oppositeLineAngle = _normalizeAngle(lineAngle + math.pi);
    final rayAngle = math.atan2(rayDir.dy, rayDir.dx);

    final delta1 = _normalizeSignedAngle(rayAngle - lineAngle);
    final delta2 = _normalizeSignedAngle(rayAngle - oppositeLineAngle);
    final usePrimary = delta1.abs() <= delta2.abs();
    var startAngle = usePrimary ? lineAngle : oppositeLineAngle;
    final sweep = usePrimary ? delta1 : delta2;
    if (useVerticalAngle) {
      // 対頂角（反対側の同じ角）として描く：両方の半直線をπだけ回転した位置に移す
      startAngle = _normalizeAngle(startAngle + math.pi);
    }
    final center = vertex;

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcRadius),
      startAngle,
      sweep,
      false,
      arcPaint,
    );

    final midAngle = startAngle + sweep * 0.5;
    final label = TextPainter(
      text: TextSpan(
        text: 'φ',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final labelCenter = center +
        Offset(
          math.cos(midAngle) * (arcRadius + 10),
          math.sin(midAngle) * (arcRadius + 10),
        );
    label.paint(
      canvas,
      labelCenter - Offset(label.width / 2, label.height / 2),
    );
  }

  double _normalizeAngle(double a) {
    var out = a;
    while (out > math.pi) out -= 2 * math.pi;
    while (out < -math.pi) out += 2 * math.pi;
    return out;
  }

  double _normalizeSignedAngle(double a) {
    var out = a;
    while (out > math.pi) out -= 2 * math.pi;
    while (out < -math.pi) out += 2 * math.pi;
    return out;
  }

  @override
  bool shouldRepaint(covariant _RainbowDropletPainter oldDelegate) {
    return oldDelegate.k != k ||
        oldDelegate.scale != scale ||
        oldDelegate.viewMode != viewMode;
  }
}

class _RainbowView {
  final Offset center;
  final double pixelsPerWorld;
  final Offset Function(Offset) worldToScreen;
  final Offset? exitFocusPoint;

  const _RainbowView({
    required this.center,
    required this.pixelsPerWorld,
    required this.worldToScreen,
    required this.exitFocusPoint,
  });
}

enum _RainbowViewMode { normal, tinyDroplet, exitZoom }
