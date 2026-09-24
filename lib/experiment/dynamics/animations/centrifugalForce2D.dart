import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// 水平面上の等速円運動を、中心から一緒に回る座標系で見る。
const double kCentrifugalMinR = 0.60;
const double kCentrifugalMaxR = 1.40;
const double kCentrifugalDefaultR = 1.00;
const double kCentrifugalMinV = 1.20;
const double kCentrifugalMaxV = 3.00;
const double kCentrifugalDefaultV = 2.00;
const double kCentrifugalMinM = 0.50;
const double kCentrifugalMaxM = 4.00;
const double kCentrifugalDefaultM = 1.00;
const double kCentrifugalSideBySideWidth = 640.0;

class CentrifugalParams {
  const CentrifugalParams({
    required this.r,
    required this.v,
    required this.mass,
  });

  final double r;
  final double v;
  final double mass;

  double get omega => v / r;

  /// 張力も遠心力も $\displaystyle m\frac{v^{2}}{R}$。人はボールと同じ角速度。
  double get tension => mass * v * v / r;

  double get centrifugal => tension;

  factory CentrifugalParams.fromMap(Map<String, double> params) {
    return CentrifugalParams(
      r: params['r']!.clamp(kCentrifugalMinR, kCentrifugalMaxR).toDouble(),
      v: params['v']!.clamp(kCentrifugalMinV, kCentrifugalMaxV).toDouble(),
      mass: params['m']!.clamp(kCentrifugalMinM, kCentrifugalMaxM).toDouble(),
    );
  }
}

class CentrifugalLabSample {
  const CentrifugalLabSample({
    required this.t,
    required this.theta,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
  });

  final double t;
  final double theta;
  final double x;
  final double y;
  final double vx;
  final double vy;

  double get speed => math.sqrt(vx * vx + vy * vy);
}

/// ボールと同じ角速度で回る人から見た座標。ボールは静止する。
class CentrifugalRotatingSample {
  const CentrifugalRotatingSample({
    required this.xTilde,
    required this.yTilde,
    required this.vxTilde,
    required this.vyTilde,
    required this.tensionRadial,
    required this.centrifugalRadial,
  });

  final double xTilde;
  final double yTilde;
  final double vxTilde;
  final double vyTilde;

  /// 外向き正。
  final double tensionRadial;
  final double centrifugalRadial;
}

CentrifugalLabSample centrifugalLabAt(CentrifugalParams params, double t) {
  final time = math.max(0.0, t);
  final theta = params.omega * time;
  return CentrifugalLabSample(
    t: time,
    theta: theta,
    x: params.r * math.cos(theta),
    y: params.r * math.sin(theta),
    vx: -params.v * math.sin(theta),
    vy: params.v * math.cos(theta),
  );
}

CentrifugalRotatingSample centrifugalRotatingAt(CentrifugalParams params) {
  return CentrifugalRotatingSample(
    xTilde: params.r,
    yTilde: 0,
    vxTilde: 0,
    vyTilde: 0,
    tensionRadial: -params.tension,
    centrifugalRadial: params.centrifugal,
  );
}

String centrifugalCaption() {
  return '中心の人はボールと同じ角速度で回る。\n'
      '地上では張力が向心力。\n'
      '人から見るとボールは静止し、張力と遠心力がつり合う。';
}

final centrifugalForce2D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '遠心力',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>水平な机の上で、ピンに結んだ伸びない紐の先のボールが、摩擦なしで等速円運動します。広い画面では左右、狭い画面では上下です。上または左が地上、下または右が、中心からボールと一緒に回る人の座標系です。</p>
  <p>地上から見ると働く力は張力だけで、</p>
  <p>$$T=m\frac{v^{2}}{R}=m\omega^{2}R$$</p>
  <p>人の角速度はボールと同じです。人から見るとボールは止まっていて、この座標系での速度は $0$ です。外向きの遠心力 $\displaystyle m\omega^{2}R$ と張力がつり合います。床の模様は地上に固定されているので、人の座標系では逆向きに回ります。</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: CentrifugalForce2DSimulation(),
      height: 980,
    ),
  ],
);

class CentrifugalForce2DSimulation extends PhysicsSimulation {
  CentrifugalForce2DSimulation()
      : super(
          title: '遠心力',
          formula: const FormulaDisplay(
            r'\displaystyle T=m\frac{v^{2}}{R}',
          ),
          aspectRatio: 0.72,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> simTime = ValueNotifier(0.0);

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    simTime.value = simTime.value + dt * _playback;
  });

  @override
  String? get situation =>
      '慣性系で見ると、水平な面上で紐につながれて等速円運動している物体';

  ValueNotifier<bool> get running => _loop.running;

  Map<String, double> _latestParams = {};

  static const double _playback = 0.45;

  @override
  double aspectRatioForWidth(double width) {
    return width >= kCentrifugalSideBySideWidth ? 1.85 : 0.72;
  }

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'r': kCentrifugalDefaultR,
        'v': kCentrifugalDefaultV,
        'm': kCentrifugalDefaultM,
      };

  CentrifugalParams get _params {
    if (_latestParams.isEmpty) {
      return CentrifugalParams.fromMap(initialParameters);
    }
    return CentrifugalParams.fromMap(_latestParams);
  }

  void _rememberParams(Map<String, double> params) {
    _latestParams = Map<String, double>.from(params);
  }

  void start() {
    if (running.value) return;
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
              centrifugalCaption(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Color(0xFF546E7A),
              ),
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
    _rememberParams(parameters);
    final p = _params;
    return [
      const Text(
        '水平面、摩擦なし。人はボールと同じ角速度',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _CentrifugalSlider(
        label: 'R',
        value: p.r,
        min: kCentrifugalMinR,
        max: kCentrifugalMaxR,
        onChanged: (v) => updateParam('r', v),
        semanticLabel: '半径 R',
      ),
      _CentrifugalSlider(
        label: 'v',
        value: p.v,
        min: kCentrifugalMinV,
        max: kCentrifugalMaxV,
        onChanged: (v) => updateParam('v', v),
        semanticLabel: '速さ v',
      ),
      _CentrifugalSlider(
        label: 'm',
        value: p.mass,
        min: kCentrifugalMinM,
        max: kCentrifugalMaxM,
        onChanged: (v) => updateParam('m', v),
        semanticLabel: '質量 m',
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'ω = ${p.omega.toStringAsFixed(2)} rad/s    '
          'T = 遠心力 = ${p.tension.toStringAsFixed(2)} N',
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Courier',
            color: Color(0xFF37474F),
          ),
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
    _rememberParams(parameters);
    return AnimatedBuilder(
      animation: Listenable.merge([running, simTime]),
      builder: (context, _) {
        final p = CentrifugalParams.fromMap(parameters);
        final lab = centrifugalLabAt(p, simTime.value);
        final rotating = centrifugalRotatingAt(p);
        return CustomPaint(
          size: Size.infinite,
          painter: _CentrifugalPainter(
            params: p,
            lab: lab,
            rotating: rotating,
          ),
        );
      },
    );
  }
}

class _CentrifugalSlider extends StatelessWidget {
  const _CentrifugalSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.semanticLabel,
    this.labelWidth = 28,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String semanticLabel;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: labelWidth,
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
              semanticFormatterCallback: (v) =>
                  '$semanticLabel ${v.toStringAsFixed(2)}',
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

class _CentrifugalPainter extends CustomPainter {
  _CentrifugalPainter({
    required this.params,
    required this.lab,
    required this.rotating,
  });

  final CentrifugalParams params;
  final CentrifugalLabSample lab;
  final CentrifugalRotatingSample rotating;

  static const _bg = Color(0xFFF7FAFC);
  static const _ball = Color(0xFF1E88E5);
  static const _tension = Color(0xFFEF6C00);
  static const _velocity = Color(0xFF5D4037);
  static const _centrifugal = Color(0xFF2E7D32);
  static const _string = Color(0xFF6D4C41);
  static const _orbit = Color(0xFF90A4AE);
  static const _pin = Color(0xFF263238);
  static const _floorA = Color(0xFFE7DFD2);
  static const _floorB = Color(0xFFD2C3B0);
  static const _person = Color(0xFF6D4C41);
  static const _ink = Color(0xFF37474F);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final sideBySide =
        size.width >= kCentrifugalSideBySideWidth && size.width > size.height;
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
    final plot = Rect.fromLTRB(
      panel.left + 8,
      panel.top + 26,
      panel.right - 8,
      panel.bottom - 28,
    );
    final reach = params.r * 1.72;
    final scale = math.min(plot.width, plot.height) / (2 * reach);
    Offset of(double x, double y) => Offset(
          plot.center.dx + x * scale,
          plot.center.dy - y * scale,
        );
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
      ground ? '張力が向心力になる。' : '張力と遠心力がつり合う。',
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

    final ballAngle = ground ? lab.theta : math.atan2(rotating.yTilde, rotating.xTilde);
    final ball = of(params.r * math.cos(ballAngle), params.r * math.sin(ballAngle));
    final pin = of(0, 0);

    canvas.drawCircle(
      pin,
      params.r * scale,
      Paint()
        ..color = _orbit
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawLine(
      pin,
      ball,
      Paint()
        ..color = _string
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );

    final toPin = pin - ball;
    final pinLen = toPin.distance;
    double forcePx(double newtons) =>
        (28 * newtons.abs() / 4).clamp(12.0, pinLen * 0.55);
    if (pinLen > 8) {
      final inward = toPin / pinLen;
      final side = Offset(-inward.dy, inward.dx);
      const shift = 11.0;
      var radialIndex = 0;
      void radialArrow(
        Offset dir,
        double length,
        Color color,
        String label, {
        bool dashed = false,
      }) {
        _arrow(
          canvas,
          ball + side * (shift * radialIndex),
          dir,
          length,
          color,
          label,
          dashed: dashed,
          labelDir: side,
        );
        radialIndex++;
      }

      radialArrow(inward, forcePx(params.tension), _tension, '張力');
      if (!ground) {
        radialArrow(
          -inward,
          forcePx(params.centrifugal),
          _centrifugal,
          '遠心力',
          dashed: true,
        );
      }
    }
    if (ground && pinLen > 8) {
      final ahead = of(
        lab.x + lab.vx * 0.05,
        lab.y + lab.vy * 0.05,
      );
      final vel = ahead - ball;
      if (vel.distance > 0.5) {
        _arrow(
          canvas,
          ball,
          vel / vel.distance,
          (lab.speed * 16).clamp(22.0, 64.0),
          _velocity,
          'v',
        );
      }
    }

    canvas.drawCircle(pin, 7, Paint()..color = _person);
    _text(canvas, pin + const Offset(0, 10), '人', _person);
    canvas.drawCircle(ball.translate(1.2, 1.4), 9, Paint()..color = Colors.black12);
    canvas.drawCircle(ball, 8, Paint()..color = _ball);
    canvas.drawCircle(pin, 4.5, Paint()..color = _pin);
  }

  /// 床の市松模様。パネル全体。地上では固定、人の座標系では $\Omega$ で逆向きに回る。
  void _drawFloor(
    Canvas canvas,
    Rect panel,
    Offset Function(double x, double y) of,
    double scale, {
    required bool ground,
  }) {
    const spacing = 0.40;
    final origin = of(0, 0);
    var radius = spacing;
    for (final corner in [
      panel.topLeft,
      panel.topRight,
      panel.bottomLeft,
      panel.bottomRight,
    ]) {
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
          _floorPoint(x0 + spacing, y0, ground),
          _floorPoint(x0 + spacing, y0 + spacing, ground),
          _floorPoint(x0, y0 + spacing, ground),
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
        canvas.drawPath(
          path,
          Paint()..color = (ix + iy).isEven ? _floorA : _floorB,
        );
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
          canvas.drawLine(
            origin + step * d,
            origin + step * math.min(d + 4, len),
            shaft,
          );
          d += 7;
        }
      }
    }
    final head = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        (tip - dir * headLen + n * headHalf).dx,
        (tip - dir * headLen + n * headHalf).dy,
      )
      ..lineTo(
        (tip - dir * headLen - n * headHalf).dx,
        (tip - dir * headLen - n * headHalf).dy,
      )
      ..close();
    canvas.drawPath(head, Paint()..color = color);
    final labelN = n.distance < 1e-6 ? n : n / n.distance;
    _text(canvas, tip + labelN * 14, label, color);
  }

  void _text(
    Canvas canvas,
    Offset o,
    String text,
    Color color, {
    bool alignLeft = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(alignLeft ? o.dx : o.dx - tp.width / 2, o.dy));
  }

  @override
  bool shouldRepaint(covariant _CentrifugalPainter oldDelegate) {
    return oldDelegate.lab.t != lab.t ||
        oldDelegate.params.r != params.r ||
        oldDelegate.params.v != params.v ||
        oldDelegate.params.mass != params.mass;
  }
}
