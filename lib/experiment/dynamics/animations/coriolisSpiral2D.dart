import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// $y$ 軸上の初期位置 $y_0$ から、速度 $v$ で等速直線運動する物体を、角速度 $\omega$ で回る座標系から見る。
/// $v>0$ は原点から遠ざかる向き。$v<0$ は原点へ向かい、そのまま通り過ぎる。
const double kSpiralMinV = -5.00;
const double kSpiralMaxV = 5.00;
const double kSpiralDefaultV = 2.50;
const double kSpiralMinY0 = 0.00;
const double kSpiralMaxY0 = 40.0;
const double kSpiralDefaultY0 = 0.00;
const double kSpiralMinOmega = 0.60;
const double kSpiralMaxOmega = 2.00;
const double kSpiralDefaultOmega = 1.20;
const double kSpiralMinM = 0.50;
const double kSpiralMaxM = 4.00;
const double kSpiralDefaultM = 1.00;
const double kSpiralSideBySideWidth = 640.0;

class SpiralParams {
  const SpiralParams({
    this.y0 = 0,
    required this.v,
    required this.omega,
    required this.mass,
  });

  final double y0;
  final double v;
  final double omega;
  final double mass;

  /// 5周分。螺旋をこの時間だけ描く。
  double get turn => 5 * 2 * math.pi / omega;

  factory SpiralParams.fromMap(Map<String, double> params) {
    return SpiralParams(
      y0: (params['y0'] ?? kSpiralDefaultY0).clamp(kSpiralMinY0, kSpiralMaxY0).toDouble(),
      v: params['v']!.clamp(kSpiralMinV, kSpiralMaxV).toDouble(),
      omega: params['W']!.clamp(kSpiralMinOmega, kSpiralMaxOmega).toDouble(),
      mass: params['m']!.clamp(kSpiralMinM, kSpiralMaxM).toDouble(),
    );
  }
}

class SpiralLabSample {
  const SpiralLabSample({
    required this.t,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
  });

  final double t;
  final double x;
  final double y;
  final double vx;
  final double vy;
}

class SpiralRotatingSample {
  const SpiralRotatingSample({
    required this.xTilde,
    required this.yTilde,
    required this.vxTilde,
    required this.vyTilde,
    required this.coriolisX,
    required this.coriolisY,
    required this.centrifugalX,
    required this.centrifugalY,
  });

  final double xTilde;
  final double yTilde;
  final double vxTilde;
  final double vyTilde;
  final double coriolisX;
  final double coriolisY;
  final double centrifugalX;
  final double centrifugalY;

  double get radius => math.sqrt(xTilde * xTilde + yTilde * yTilde);
  double get speed => math.sqrt(vxTilde * vxTilde + vyTilde * vyTilde);
  double get coriolis => math.sqrt(coriolisX * coriolisX + coriolisY * coriolisY);
  double get centrifugal => math.sqrt(centrifugalX * centrifugalX + centrifugalY * centrifugalY);
}

double spiralLabY(SpiralParams params, double t) => params.y0 + params.v * t;

SpiralLabSample spiralLabAt(SpiralParams params, double t) {
  final time = math.max(0.0, t);
  return SpiralLabSample(t: time, x: 0, y: spiralLabY(params, time), vx: 0, vy: params.v);
}

/// $\tilde{x}=(y_0+vt)\sin\omega t,\ \tilde{y}=(y_0+vt)\cos\omega t$。真の力は 0。
SpiralRotatingSample spiralRotatingAt(SpiralParams params, double t) {
  final time = math.max(0.0, t);
  final w = params.omega;
  final s = math.sin(w * time);
  final c = math.cos(w * time);
  final along = spiralLabY(params, time);
  final x = along * s;
  final y = along * c;
  final vx = params.v * s + along * w * c;
  final vy = params.v * c - along * w * s;
  return SpiralRotatingSample(
    xTilde: x,
    yTilde: y,
    vxTilde: vx,
    vyTilde: vy,
    coriolisX: 2 * params.mass * w * vy,
    coriolisY: -2 * params.mass * w * vx,
    centrifugalX: params.mass * w * w * x,
    centrifugalY: params.mass * w * w * y,
  );
}

String spiralCaption() {
  return '地上では y 軸上を等速直線運動する。力は働いていない。\n'
      '+v は原点から遠ざかり、-v は原点へ向かって通り過ぎる。\n'
      '回って見ると螺旋を描き、コリオリ力は進行方向の右向き。';
}

final coriolisSpiral2D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '遠心力とコリオリ力(等速直線運動)',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>慣性系から見て、物体は $y$ 軸上の $y=y_0$ から速度 $v$ で等速直線運動します。$v>0$ は原点から遠ざかる向き、$v<0$ は原点へ向かう向きです。向かうときは原点を通り過ぎて反対側へ出ます。働く力はありません。これを、角速度 $\omega$ で回転する座標系から見ます。広い画面では左右、狭い画面では上下です。上または左が地上、下または右がその人の座標系です。</p>
  <p>真の力は $\vec{0}$ なので、回転系の運動方程式は</p>
  <p>$$\begin{cases}\tilde{x}''(t)=2\omega\tilde{y}'(t)+\omega^{2}\tilde{x}(t)\\ \tilde{y}''(t)=-2\omega\tilde{x}'(t)+\omega^{2}\tilde{y}(t)\end{cases}$$</p>
  <p>$t=0$ で二つの座標系の軸が重なるときの解は</p>
  <p>$$\tilde{x}(t)=(y_0+vt)\sin\omega t,\quad \tilde{y}(t)=(y_0+vt)\cos\omega t$$</p>
  <p>原点からの距離は $r=\lvert y_0+vt\rvert$ です。$y_0=0$ で $v>0$ のあいだは、回転系の $y$ 軸から測った角 $\theta=\omega t$ を使うと</p>
  <p>$$r=\frac{v}{\omega}\theta$$</p>
  <p>原点を過ぎると螺旋は一度すぼまってから、反対側で再び広がります。コリオリ力に入る速度は、この回転している座標系から見た速度で、向きは進行方向の右です。</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: CoriolisSpiral2DSimulation(),
      height: 980,
    ),
  ],
);

class CoriolisSpiral2DSimulation extends PhysicsSimulation {
  CoriolisSpiral2DSimulation()
      : super(
          title: '遠心力とコリオリ力(等速直線運動)',
          formula: const FormulaDisplay(
            r'\displaystyle \tilde{x}=(y_{0}+vt)\sin\omega t',
          ),
          aspectRatio: 0.72,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> simTime = ValueNotifier(0.0);

  static const double _playback = 1;

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    final limit = _params.turn;
    final next = math.min(limit, simTime.value + dt * _playback);
    simTime.value = next;
    if (next >= limit - 1e-4) _loop.pause();
  });

  @override
  String? get situation => '慣性系で見ると、y 軸上を等速直線運動する物体';

  ValueNotifier<bool> get running => _loop.running;
  Map<String, double> _latestParams = {};

  @override
  double aspectRatioForWidth(double width) {
    return width >= kSpiralSideBySideWidth ? 1.85 : 0.72;
  }

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'y0': kSpiralDefaultY0,
        'v': kSpiralDefaultV,
        'W': kSpiralDefaultOmega,
        'm': kSpiralDefaultM,
      };

  SpiralParams get _params {
    if (_latestParams.isEmpty) return SpiralParams.fromMap(initialParameters);
    return SpiralParams.fromMap(_latestParams);
  }

  void start() {
    if (running.value) return;
    if (simTime.value >= _params.turn - 1e-3) simTime.value = 0.0;
    _loop.start();
  }

  void pause() => _loop.pause();

  void resetMotion() {
    _loop.reset();
    simTime.value = 0.0;
  }

  @override
  Widget? buildExtraControls(
    BuildContext context,
    Set<String> activeIds,
    void Function(Set<String> ids) updateActiveIds,
  ) {
    return ValueListenableBuilder<bool>(
      valueListenable: running,
      builder: (context, isRunning, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              spiralCaption(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF546E7A)),
            ),
            const SizedBox(height: 8),
            PlayPauseResetButtons(
              playing: isRunning,
              onPlayPause: isRunning ? pause : start,
              onReset: resetMotion,
            ),
          ],
        );
      },
    );
  }

  @override
  List<Widget> buildControls(
    BuildContext context,
    Map<String, double> parameters,
    void Function(String key, double value) updateParam,
  ) {
    _latestParams = Map<String, double>.from(parameters);
    final p = _params;
    final frame = spiralRotatingAt(p, simTime.value);
    return [
      const Text(
        '地上では y 軸上の等速直線運動。+v は原点から遠ざかる',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _SpiralSlider(
        label: 'v',
        value: p.v,
        min: kSpiralMinV,
        max: kSpiralMaxV,
        onChanged: (v) => updateParam('v', v),
        semanticLabel: '速度 v。正は原点から遠ざかる',
      ),
      _SpiralSlider(
        label: 'y0',
        value: p.y0,
        min: kSpiralMinY0,
        max: kSpiralMaxY0,
        onChanged: (v) => updateParam('y0', v),
        semanticLabel: '初期位置 y0',
      ),
      _SpiralSlider(
        label: 'ω',
        value: p.omega,
        min: kSpiralMinOmega,
        max: kSpiralMaxOmega,
        onChanged: (v) => updateParam('W', v),
        semanticLabel: '人の角速度 ω',
      ),
      _SpiralSlider(
        label: 'm',
        value: p.mass,
        min: kSpiralMinM,
        max: kSpiralMaxM,
        onChanged: (v) => updateParam('m', v),
        semanticLabel: '質量 m',
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'r = ${frame.radius.toStringAsFixed(2)} m    '
          'θ = ${(p.omega * simTime.value).toStringAsFixed(2)} rad\n'
          'コリオリ ${frame.coriolis.toStringAsFixed(2)} N    '
          '遠心力 ${frame.centrifugal.toStringAsFixed(2)} N',
          style: const TextStyle(fontSize: 12, fontFamily: 'Courier', color: Color(0xFF37474F)),
        ),
      ),
    ];
  }

  @override
  Widget buildAnimation(
    BuildContext context,
    double time,
    double azimuth,
    double tilt,
    double scale,
    Map<String, double> parameters,
    Set<String> activeIds,
  ) {
    _latestParams = Map<String, double>.from(parameters);
    return AnimatedBuilder(
      animation: Listenable.merge([running, simTime]),
      builder: (context, _) {
        final p = SpiralParams.fromMap(parameters);
        final t = math.min(simTime.value, p.turn);
        return CustomPaint(
          size: Size.infinite,
          painter: _SpiralPainter(
            params: p,
            lab: spiralLabAt(p, t),
            rotating: spiralRotatingAt(p, t),
          ),
        );
      },
    );
  }
}

class _SpiralSlider extends StatelessWidget {
  const _SpiralSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.semanticLabel,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Semantics(
            label: semanticLabel,
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
              semanticFormatterCallback: (v) => '$semanticLabel ${v.toStringAsFixed(2)}',
            ),
          ),
        ),
        SizedBox(
          width: 52,
          child: Text(
            value.toStringAsFixed(2),
            style: const TextStyle(fontSize: 12, fontFamily: 'Courier'),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _SpiralPainter extends CustomPainter {
  _SpiralPainter({required this.params, required this.lab, required this.rotating});

  final SpiralParams params;
  final SpiralLabSample lab;
  final SpiralRotatingSample rotating;

  static const _bg = Color(0xFFF7FAFC);
  static const _ball = Color(0xFF1E88E5);
  static const _velocity = Color(0xFF5D4037);
  static const _centrifugal = Color(0xFF2E7D32);
  static const _coriolis = Color(0xFF6A1B9A);
  static const _trail = Color(0xFF78909C);
  static const _floorA = Color(0xFFE7DFD2);
  static const _floorB = Color(0xFFD2C3B0);
  static const _person = Color(0xFF6D4C41);
  static const _ink = Color(0xFF37474F);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final sideBySide = size.width >= kSpiralSideBySideWidth && size.width > size.height;
    if (sideBySide) {
      const gap = 8.0;
      final w = (size.width - gap) / 2;
      _panel(canvas, Rect.fromLTWH(0, 0, w, size.height), ground: true);
      _panel(canvas, Rect.fromLTWH(w + gap, 0, w, size.height), ground: false);
    } else {
      const gap = 8.0;
      final h = (size.height - gap) / 2;
      _panel(canvas, Rect.fromLTWH(0, 0, size.width, h), ground: true);
      _panel(canvas, Rect.fromLTWH(0, h + gap, size.width, h), ground: false);
    }
  }

  void _panel(Canvas canvas, Rect panel, {required bool ground}) {
    canvas.save();
    canvas.clipRect(panel);
    final plot = Rect.fromLTRB(panel.left + 8, panel.top + 26, panel.right - 8, panel.bottom - 28);
    final endY = (params.y0 + params.v * params.turn).abs();
    final reach = math.max(math.max(params.y0.abs(), endY), 0.8) * 1.15;
    final scale = math.min(plot.width, plot.height) / (2 * reach);
    Offset of(double x, double y) =>
        Offset(plot.center.dx + x * scale, plot.center.dy - y * scale);
    _drawFloor(canvas, panel, of, scale, ground: ground);
    canvas.drawRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFCFD8DC),
    );
    _text(
      canvas,
      Offset(panel.left + 8, panel.top + 6),
      ground ? '地上（慣性系）' : '人の座標系',
      _ink,
      alignLeft: true,
    );
    _scene(canvas, of, scale, ground: ground);
    _text(
      canvas,
      Offset(panel.center.dx, panel.bottom - 18),
      ground ? 'y 軸上をまっすぐ進む。' : 'アルキメデスの螺旋を描く。',
      const Color(0xFF546E7A),
    );
    canvas.restore();
  }

  void _scene(
    Canvas canvas,
    Offset Function(double x, double y) of,
    double scale, {
    required bool ground,
  }) {
    final pin = of(0, 0);
    _drawTrail(canvas, of, ground: ground);
    final ball = ground ? of(lab.x, lab.y) : of(rotating.xTilde, rotating.yTilde);
    if (ground) {
      _vectorArrow(canvas, of, ball, lab.vx, lab.vy, 18, _velocity, 'v');
    } else {
      _forceArrow(canvas, of, ball, rotating.coriolisX, rotating.coriolisY, _coriolis, 'コリオリ', dashed: true);
      _forceArrow(
        canvas,
        of,
        ball,
        rotating.centrifugalX,
        rotating.centrifugalY,
        _centrifugal,
        '遠心力',
        dashed: true,
        shift: _overlaps(rotating) ? 11 : 0,
      );
      _vectorArrow(canvas, of, ball, rotating.vxTilde, rotating.vyTilde, 14, _velocity, '速度');
    }
    final nose = ground ? params.omega * lab.t : 0.0;
    canvas.drawCircle(pin, 7, Paint()..color = _person);
    canvas.drawLine(
      pin,
      pin + Offset(16 * math.cos(nose), -16 * math.sin(nose)),
      Paint()
        ..color = _person
        ..strokeWidth = 2,
    );
    _text(canvas, pin + const Offset(0, 10), '人', _person);
    canvas.drawCircle(ball.translate(1.2, 1.4), 9, Paint()..color = Colors.black12);
    canvas.drawCircle(ball, 8, Paint()..color = _ball);
  }

  bool _overlaps(SpiralRotatingSample s) {
    final c = s.coriolis;
    final f = s.centrifugal;
    if (c < 1e-4 || f < 1e-4) return false;
    final dot = (s.coriolisX * s.centrifugalX + s.coriolisY * s.centrifugalY) / (c * f);
    return dot.abs() > 0.85;
  }

  void _drawTrail(Canvas canvas, Offset Function(double x, double y) of, {required bool ground}) {
    final paint = Paint()
      ..color = _trail
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    final path = Path();
    final end = lab.t;
    if (end < 1e-4) return;
    final steps = math.max(24, (params.omega * end / (2 * math.pi) * 36).ceil());
    for (var i = 0; i <= steps; i++) {
      final t = end * i / steps;
      final along = spiralLabY(params, t);
      final p = ground
          ? of(0, along)
          : of(along * math.sin(params.omega * t), along * math.cos(params.omega * t));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  void _vectorArrow(
    Canvas canvas,
    Offset Function(double x, double y) of,
    Offset origin,
    double vx,
    double vy,
    double pxPerSpeed,
    Color color,
    String label,
  ) {
    final speed = math.sqrt(vx * vx + vy * vy);
    if (speed < 1e-4) return;
    final tip = of(0, 0);
    final ahead = of(vx * 0.05, vy * 0.05);
    final dir = ahead - tip;
    if (dir.distance < 1e-4) return;
    _arrow(canvas, origin, dir / dir.distance, (speed * pxPerSpeed).clamp(16.0, 64.0), color, label);
  }

  void _forceArrow(
    Canvas canvas,
    Offset Function(double x, double y) of,
    Offset origin,
    double fx,
    double fy,
    Color color,
    String label, {
    bool dashed = false,
    double shift = 0,
  }) {
    final mag = math.sqrt(fx * fx + fy * fy);
    if (mag < 0.05) return;
    final ahead = of(fx * 0.05, fy * 0.05) - of(0, 0);
    if (ahead.distance < 1e-4) return;
    final dir = ahead / ahead.distance;
    final side = Offset(-dir.dy, dir.dx);
    _arrow(
      canvas,
      origin + side * shift,
      dir,
      (mag * 4).clamp(14.0, 70.0),
      color,
      label,
      dashed: dashed,
      labelDir: side,
    );
  }

  void _drawFloor(
    Canvas canvas,
    Rect panel,
    Offset Function(double x, double y) of,
    double scale, {
    required bool ground,
  }) {
    final spacing = (28 / scale).clamp(0.35, 12.0);
    final origin = of(0, 0);
    var radius = spacing;
    for (final corner in [panel.topLeft, panel.topRight, panel.bottomLeft, panel.bottomRight]) {
      final dx = (corner.dx - origin.dx) / scale;
      final dy = (origin.dy - corner.dy) / scale;
      radius = math.max(radius, math.sqrt(dx * dx + dy * dy));
    }
    radius += spacing;
    final n = (radius / spacing).ceil() + 1;
    for (var ix = -n; ix < n; ix++) {
      for (var iy = -n; iy < n; iy++) {
        final x0 = ix * spacing;
        final y0 = iy * spacing;
        final x1 = x0 + spacing;
        final y1 = y0 + spacing;
        final dx = x1 < 0 ? -x1 : (x0 > 0 ? x0 : 0.0);
        final dy = y1 < 0 ? -y1 : (y0 > 0 ? y0 : 0.0);
        if (dx * dx + dy * dy > radius * radius) continue;
        final corners = [
          _floorPoint(x0, y0, ground),
          _floorPoint(x1, y0, ground),
          _floorPoint(x1, y1, ground),
          _floorPoint(x0, y1, ground),
        ];
        final path = Path();
        for (var i = 0; i < corners.length; i++) {
          final p = of(corners[i].dx, corners[i].dy);
          if (i == 0) {
            path.moveTo(p.dx, p.dy);
          } else {
            path.lineTo(p.dx, p.dy);
          }
        }
        path.close();
        canvas.drawPath(path, Paint()..color = (ix + iy).isEven ? _floorA : _floorB);
      }
    }
  }

  Offset _floorPoint(double x, double y, bool ground) {
    if (ground) return Offset(x, y);
    final angle = params.omega * lab.t;
    final c = math.cos(angle);
    final s = math.sin(angle);
    return Offset(x * c + y * s, -x * s + y * c);
  }

  void _arrow(
    Canvas canvas,
    Offset origin,
    Offset dir,
    double length,
    Color color,
    String label, {
    bool dashed = false,
    Offset? labelDir,
  }) {
    final tip = origin + dir * length;
    const headLen = 9.0;
    const headHalf = 4.5;
    final shaftEnd = tip - dir * (headLen * 0.7);
    final n = labelDir ?? Offset(-dir.dy, dir.dx);
    final shaft = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    if (!dashed) {
      canvas.drawLine(origin, shaftEnd, shaft);
    } else {
      final delta = shaftEnd - origin;
      final len = delta.distance;
      if (len > 1) {
        final step = delta / len;
        var d = 0.0;
        while (d < len) {
          canvas.drawLine(origin + step * d, origin + step * math.min(d + 4, len), shaft);
          d += 7;
        }
      }
    }
    final head = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo((tip - dir * headLen + n * headHalf).dx, (tip - dir * headLen + n * headHalf).dy)
      ..lineTo((tip - dir * headLen - n * headHalf).dx, (tip - dir * headLen - n * headHalf).dy)
      ..close();
    canvas.drawPath(head, Paint()..color = color);
    final labelN = n.distance < 1e-6 ? n : n / n.distance;
    _text(canvas, tip + labelN * 14, label, color);
  }

  void _text(Canvas canvas, Offset o, String text, Color color, {bool alignLeft = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700, height: 1.25),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(alignLeft ? o.dx : o.dx - tp.width / 2, o.dy));
  }

  @override
  bool shouldRepaint(covariant _SpiralPainter oldDelegate) {
    return oldDelegate.lab.t != lab.t ||
        oldDelegate.params.y0 != params.y0 ||
        oldDelegate.params.v != params.v ||
        oldDelegate.params.omega != params.omega ||
        oldDelegate.params.mass != params.mass;
  }
}
