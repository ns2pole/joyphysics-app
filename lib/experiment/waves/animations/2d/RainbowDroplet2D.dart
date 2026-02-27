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
);

class RainbowDroplet2DSimulation extends WaveSimulation {
  RainbowDroplet2DSimulation()
      : super(
          title: "虹の光路 (単一水滴)",
          is3D: false,
          showTimeOverlay: false,
        );

  @override
  Map<String, double> get initialParameters => const {
        'k': 0.82,
      };

  @override
  List<Widget> buildControls(context, params, updateParam) {
    final k = (params['k'] ?? 0.82).clamp(0.0, 0.999);
    final redPath = _RayOptics.computeRayPath(k, _RainbowDropletPainter.redN);
    final bluePath = _RayOptics.computeRayPath(k, _RainbowDropletPainter.blueN);
    final redPhiGeo = redPath == null ? 0.0 : _RayOptics.phiGeoDegFromPath(redPath);
    final bluePhiGeo = bluePath == null ? 0.0 : _RayOptics.phiGeoDegFromPath(bluePath);
    final redPhiTheory = _RayOptics.theoryPhiDeg(k, _RainbowDropletPainter.redN);
    final bluePhiTheory = _RayOptics.theoryPhiDeg(k, _RainbowDropletPainter.blueN);
    final redPeakPhi = _RayOptics.theoryPhiDeg(
      _RayOptics.peakK(_RainbowDropletPainter.redN),
      _RainbowDropletPainter.redN,
    );
    final bluePeakPhi = _RayOptics.theoryPhiDeg(
      _RayOptics.peakK(_RainbowDropletPainter.blueN),
      _RainbowDropletPainter.blueN,
    );

    return [
      Text(
        'k = ${k.toStringAsFixed(3)}   φ_red = ${redPhiGeo.toStringAsFixed(2)}°   φ_blue = ${bluePhiGeo.toStringAsFixed(2)}°',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      WaveParameterSlider(
        label: 'k',
        value: k,
        min: 0.0,
        max: 0.999,
        onChanged: (v) => updateParam('k', v),
      ),
      Text(
        '理論ピーク φ: 赤 ${redPeakPhi.toStringAsFixed(2)}° / 青 ${bluePeakPhi.toStringAsFixed(2)}°',
        style: const TextStyle(fontSize: 15, color: Colors.black54),
      ),
      Text(
        '理論との差 |Δφ|: 赤 ${(redPhiGeo - redPhiTheory).abs().toStringAsFixed(2)}° / 青 ${(bluePhiGeo - bluePhiTheory).abs().toStringAsFixed(2)}°',
        style: const TextStyle(fontSize: 14, color: Colors.black54),
      ),
    ];
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    final k = (params['k'] ?? 0.82).clamp(0.0, 0.999);
    final redPath = _RayOptics.computeRayPath(k, _RainbowDropletPainter.redN);
    final bluePath = _RayOptics.computeRayPath(k, _RainbowDropletPainter.blueN);
    final redPhiDeg = redPath == null ? 0.0 : _RayOptics.phiGeoDegFromPath(redPath);
    final bluePhiDeg = bluePath == null ? 0.0 : _RayOptics.phiGeoDegFromPath(bluePath);
    return Stack(
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: _RainbowDropletPainter(k: k, scale: scale),
        ),
        Positioned(
          top: 12,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'k = ${k.toStringAsFixed(3)}   φ_red = ${redPhiDeg.toStringAsFixed(2)}°   φ_blue = ${bluePhiDeg.toStringAsFixed(2)}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Courier',
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

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

  static const double _dropRadius = 1.0;
  static const double redN = 1.33;
  static const double blueN = 1.34;

  const _RainbowDropletPainter({required this.k, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final pixelRadius = math.min(size.width, size.height) * 0.34;

    Offset worldToScreen(Offset p) {
      return Offset(
        center.dx + p.dx * pixelRadius * scale,
        center.dy - p.dy * pixelRadius * scale,
      );
    }

    final dropletCenter = worldToScreen(Offset.zero);
    final dropletRadius = pixelRadius * scale * _dropRadius;

    final dropPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF81D4FA).withOpacity(0.35);
    canvas.drawCircle(dropletCenter, dropletRadius, dropPaint);

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.lightBlue.shade200;
    canvas.drawCircle(dropletCenter, dropletRadius, outlinePaint);

    _drawColorPath(
      canvas: canvas,
      worldToScreen: worldToScreen,
      refractiveIndex: redN,
      color: Colors.red.withOpacity(0.7),
    );
    _drawColorPath(
      canvas: canvas,
      worldToScreen: worldToScreen,
      refractiveIndex: blueN,
      color: Colors.blue.withOpacity(0.7),
    );
  }

  void _drawColorPath({
    required Canvas canvas,
    required Offset Function(Offset) worldToScreen,
    required double refractiveIndex,
    required Color color,
  }) {
    final path = _computeRayPath(k, refractiveIndex);
    if (path == null) return;

    final rayPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = color;

    // 左から水平入射する前置きの線分
    final incidentStart = Offset(path.p1.dx - 1.0, path.p1.dy);
    canvas.drawLine(worldToScreen(incidentStart), worldToScreen(path.p1), rayPaint);

    // 水滴内: 屈折 -> 内部反射 -> 出射点まで
    canvas.drawLine(worldToScreen(path.p1), worldToScreen(path.p2), rayPaint);
    canvas.drawLine(worldToScreen(path.p2), worldToScreen(path.p3), rayPaint);

    // 出射光（実線）
    final exitEnd = path.p3 + path.outDir * 1.2;
    canvas.drawLine(worldToScreen(path.p3), worldToScreen(exitEnd), rayPaint);

    final helperPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color.withOpacity(0.85);

    // 出射点の高さで水平基準線（点線）を描く
    final horizontalY = path.p3.dy;
    _drawDashedLine(
      canvas,
      worldToScreen(Offset(2.1, horizontalY)),
      worldToScreen(Offset(-2.1, horizontalY)),
      helperPaint,
    );

    // 出射光の延長（交点までを点線）
    final phiIntersection = _lineHorizontalIntersection(path.p3, path.outDir, horizontalY);
    if (phiIntersection != null) {
      _drawDashedLine(
        canvas,
        worldToScreen(path.p3),
        worldToScreen(phiIntersection),
        helperPaint,
      );
      _drawPhiArc(
        canvas,
        worldToScreen,
        path.p3,
        path.outDir,
        color,
        arcRadius: refractiveIndex == redN ? 24.0 : 16.0,
        centerOffset:
            refractiveIndex == redN ? const Offset(2, 2) : const Offset(-2, -2),
      );
    }
  }

  _RayPath? _computeRayPath(double x, double n) {
    return _RayOptics.computeRayPath(x, n);
  }

  Offset? _lineHorizontalIntersection(Offset p, Offset dir, double y) {
    return _RayOptics.horizontalIntersection(p, dir, y);
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

  void _drawPhiArc(
    Canvas canvas,
    Offset Function(Offset) worldToScreen,
    Offset p3,
    Offset outDir,
    Color color,
    {required double arcRadius, required Offset centerOffset}
  ) {
    final center = worldToScreen(p3) + centerOffset;
    final back = -outDir;
    if (back.distance == 0.0) return;

    // φ は水平線との小さい鋭角で表示する
    final refStart = back.dx >= 0 ? 0.0 : math.pi;
    final target = math.atan2(back.dy, back.dx);
    final acute = math.atan2(back.dy.abs(), back.dx.abs());
    var delta = target - refStart;
    while (delta > math.pi) {
      delta -= 2 * math.pi;
    }
    while (delta < -math.pi) {
      delta += 2 * math.pi;
    }
    final sweep = delta >= 0 ? acute : -acute;

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcRadius),
      refStart,
      sweep,
      false,
      arcPaint,
    );
    final label = TextPainter(
      text: TextSpan(
        text: 'φ',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final labelAnchor = worldToScreen(p3 + outDir * 0.12);
    label.paint(canvas, labelAnchor + const Offset(6, -6));
  }

  @override
  bool shouldRepaint(covariant _RainbowDropletPainter oldDelegate) {
    return oldDelegate.k != k || oldDelegate.scale != scale;
  }
}
