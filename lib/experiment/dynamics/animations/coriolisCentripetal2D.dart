import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// 地上で静止している物体を、中心の人が角速度 $\Omega$ で回って見る。
const double kRestMinR = 0.60;
const double kRestMaxR = 1.40;
const double kRestDefaultR = 1.00;
const double kRestMinOmega = 0.80;
const double kRestMaxOmega = 2.50;
const double kRestDefaultOmega = 1.50;
const double kRestMinM = 0.50;
const double kRestMaxM = 4.00;
const double kRestDefaultM = 1.00;
const double kRestSideBySideWidth = 640.0;

class RestRotatingParams {
  const RestRotatingParams({
    required this.r,
    required this.omega,
    required this.mass,
  });

  final double r;
  final double omega;
  final double mass;

  /// 人の座標系での速さ $\Omega R$。
  double get rotatingSpeed => omega * r;

  /// 外向きの遠心力 $\displaystyle m\Omega^{2}R$。
  double get centrifugal => mass * omega * omega * r;

  /// 外向き正。静止物体なのでコリオリ力は内向き $\displaystyle -2m\Omega^{2}R$。
  double get coriolisRadial => -2 * centrifugal;

  /// 見かけの円運動の向心力の大きさ $\displaystyle m\Omega^{2}R$。
  double get centripetal => centrifugal;

  factory RestRotatingParams.fromMap(Map<String, double> params) {
    return RestRotatingParams(
      r: params['r']!.clamp(kRestMinR, kRestMaxR).toDouble(),
      omega: params['W']!.clamp(kRestMinOmega, kRestMaxOmega).toDouble(),
      mass: params['m']!.clamp(kRestMinM, kRestMaxM).toDouble(),
    );
  }
}

class RestLabSample {
  const RestLabSample({required this.t, required this.x, required this.y});

  final double t;
  final double x;
  final double y;
}

class RestRotatingSample {
  const RestRotatingSample({
    required this.xTilde,
    required this.yTilde,
    required this.vxTilde,
    required this.vyTilde,
    required this.centrifugalRadial,
    required this.coriolisRadial,
  });

  final double xTilde;
  final double yTilde;
  final double vxTilde;
  final double vyTilde;
  final double centrifugalRadial;
  final double coriolisRadial;

  double get speed => math.sqrt(vxTilde * vxTilde + vyTilde * vyTilde);
}

RestLabSample restLabAt(RestRotatingParams params, double t) {
  return RestLabSample(t: math.max(0.0, t), x: params.r, y: 0);
}

/// 人の角速度を $\Omega$ とすると、静止物体は $\tilde{x}=R\cos\Omega t,\ \tilde{y}=-R\sin\Omega t$。
RestRotatingSample restRotatingAt(RestRotatingParams params, double t) {
  final time = math.max(0.0, t);
  final c = math.cos(params.omega * time);
  final s = math.sin(params.omega * time);
  return RestRotatingSample(
    xTilde: params.r * c,
    yTilde: -params.r * s,
    vxTilde: -params.omega * params.r * s,
    vyTilde: -params.omega * params.r * c,
    centrifugalRadial: params.centrifugal,
    coriolisRadial: params.coriolisRadial,
  );
}

String restRotatingCaption() {
  return '地上では物体は止まっていて、力は働いていない。\n'
      '中心の人が回って見ると、物体は円を描く。\n'
      '内向きのコリオリ力と外向きの遠心力の合力が、見かけの向心力。';
}

final coriolisCentripetal2D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '遠心力とコリオリ力(静止物体)',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>水平な床の上で、物体は止まっています。働く力はありません。中心にいる人が角速度 $\Omega$ で回ってこの物体を見ます。広い画面では左右、狭い画面では上下です。上または左が地上、下または右がその人の座標系です。</p>
  <p>人から見ると、物体は半径 $R$ の円周上を速さ $\Omega R$ で動きます。この見かけの円運動に必要な向心力は内向きの</p>
  <p>$$m\frac{(\Omega R)^{2}}{R}=m\Omega^{2}R$$</p>
  <p>人の座標系では、外向きの遠心力 $\displaystyle m\Omega^{2}R$ と、内向きのコリオリ力 $\displaystyle 2m\Omega^{2}R$ が働きます。外向きを正とすると</p>
  <p>$$F_{\mathrm{cen}}=m\Omega^{2}R,\quad F_{\mathrm{Cor}}=-2m\Omega^{2}R$$</p>
  <p>合力は内向きの $\displaystyle m\Omega^{2}R$ で、見かけの向心力と一致します。コリオリ力に入る速度は、この回転している座標系から見た速度です。床の模様は地上に固定されているので、物体といっしょに逆向きへ回って見えます。</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: CoriolisCentripetal2DSimulation(),
      height: 980,
    ),
  ],
);

class CoriolisCentripetal2DSimulation extends PhysicsSimulation {
  CoriolisCentripetal2DSimulation()
      : super(
          title: '遠心力とコリオリ力(静止物体)',
          formula: const FormulaDisplay(
            r'\displaystyle F_{\mathrm{cen}}+F_{\mathrm{Cor}}=-m\Omega^{2}R',
          ),
          aspectRatio: 0.72,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> simTime = ValueNotifier(0.0);

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    simTime.value = simTime.value + dt * 0.45;
  });

  @override
  String? get situation => '慣性系で見ると、止まっている物体';

  ValueNotifier<bool> get running => _loop.running;
  Map<String, double> _latestParams = {};

  @override
  double aspectRatioForWidth(double width) {
    return width >= kRestSideBySideWidth ? 1.85 : 0.72;
  }

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'r': kRestDefaultR,
        'W': kRestDefaultOmega,
        'm': kRestDefaultM,
      };

  RestRotatingParams get _params {
    if (_latestParams.isEmpty) return RestRotatingParams.fromMap(initialParameters);
    return RestRotatingParams.fromMap(_latestParams);
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
              restRotatingCaption(),
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
    return [
      const Text(
        '物体は地上で静止。中心の人が角速度 Ω で回る',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _RestSlider(
        label: 'R',
        value: p.r,
        min: kRestMinR,
        max: kRestMaxR,
        onChanged: (v) => updateParam('r', v),
        semanticLabel: '中心からの距離 R',
      ),
      _RestSlider(
        label: 'Ω',
        value: p.omega,
        min: kRestMinOmega,
        max: kRestMaxOmega,
        onChanged: (v) => updateParam('W', v),
        semanticLabel: '人の角速度 Ω',
      ),
      _RestSlider(
        label: 'm',
        value: p.mass,
        min: kRestMinM,
        max: kRestMaxM,
        onChanged: (v) => updateParam('m', v),
        semanticLabel: '質量 m',
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '速さ ${p.rotatingSpeed.toStringAsFixed(2)} m/s（人から見た値）\n'
          '遠心力 ${p.centrifugal.toStringAsFixed(2)} N 外向き    '
          'コリオリ ${(-p.coriolisRadial).toStringAsFixed(2)} N 内向き\n'
          '合力 = 向心力 ${p.centripetal.toStringAsFixed(2)} N 内向き',
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
        final p = RestRotatingParams.fromMap(parameters);
        return CustomPaint(
          size: Size.infinite,
          painter: _RestPainter(
            params: p,
            lab: restLabAt(p, simTime.value),
            rotating: restRotatingAt(p, simTime.value),
          ),
        );
      },
    );
  }
}

class _RestSlider extends StatelessWidget {
  const _RestSlider({
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

class _RestPainter extends CustomPainter {
  _RestPainter({required this.params, required this.lab, required this.rotating});

  final RestRotatingParams params;
  final RestLabSample lab;
  final RestRotatingSample rotating;

  static const _bg = Color(0xFFF7FAFC);
  static const _ball = Color(0xFF1E88E5);
  static const _velocity = Color(0xFF5D4037);
  static const _centrifugal = Color(0xFF2E7D32);
  static const _coriolis = Color(0xFF6A1B9A);
  static const _orbit = Color(0xFF90A4AE);
  static const _floorA = Color(0xFFE7DFD2);
  static const _floorB = Color(0xFFD2C3B0);
  static const _person = Color(0xFF6D4C41);
  static const _ink = Color(0xFF37474F);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final sideBySide = size.width >= kRestSideBySideWidth && size.width > size.height;
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
    final reach = params.r * 1.72;
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
    _text(canvas, Offset(panel.left + 8, panel.top + 6), ground ? '地上（慣性系）' : '人の座標系', _ink, alignLeft: true);
    _scene(canvas, of, scale, ground: ground);
    _text(
      canvas,
      Offset(panel.center.dx, panel.bottom - 18),
      ground ? '物体は静止し、力は働いていない。' : '合力が見かけの向心力になる。',
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
    final ball = ground ? of(lab.x, lab.y) : of(rotating.xTilde, rotating.yTilde);
    final origin = of(0, 0);
    canvas.drawCircle(
      origin,
      params.r * scale,
      Paint()
        ..color = _orbit
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    final face = ground ? params.omega * lab.t : 0.0;
    final nose = of(0.18 * math.cos(face), 0.18 * math.sin(face));
    canvas.drawLine(
      origin,
      nose,
      Paint()
        ..color = _person
        ..strokeWidth = 2,
    );
    if (!ground) {
      final toOrigin = origin - ball;
      final len = toOrigin.distance;
      if (len > 8) {
        final inward = toOrigin / len;
        final side = Offset(-inward.dy, inward.dx);
        double forcePx(double newtons) => (28 * newtons.abs() / 4).clamp(12.0, len * 0.55);
        _arrow(canvas, ball, inward, forcePx(params.coriolisRadial), _coriolis, 'コリオリ', dashed: true, labelDir: side);
        _arrow(
          canvas,
          ball + side * 11,
          -inward,
          forcePx(params.centrifugal),
          _centrifugal,
          '遠心力',
          dashed: true,
          labelDir: side,
        );
        final ahead = of(rotating.xTilde + rotating.vxTilde * 0.05, rotating.yTilde + rotating.vyTilde * 0.05);
        final vel = ahead - ball;
        if (vel.distance > 0.5) {
          _arrow(canvas, ball, vel / vel.distance, (rotating.speed * 16).clamp(18.0, 56.0), _velocity, '速度');
        }
      }
    }
    canvas.drawCircle(origin, 7, Paint()..color = _person);
    _text(canvas, origin + const Offset(0, 10), '人', _person);
    canvas.drawCircle(ball.translate(1.2, 1.4), 9, Paint()..color = Colors.black12);
    canvas.drawCircle(ball, 8, Paint()..color = _ball);
  }

  void _drawFloor(
    Canvas canvas,
    Rect panel,
    Offset Function(double x, double y) of,
    double scale, {
    required bool ground,
  }) {
    const spacing = 0.40;
    final pin = of(0, 0);
    var radius = spacing;
    for (final corner in [panel.topLeft, panel.topRight, panel.bottomLeft, panel.bottomRight]) {
      final dx = (corner.dx - pin.dx) / scale;
      final dy = (pin.dy - corner.dy) / scale;
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
    final wing = n.distance < 1e-6 ? Offset(-dir.dy, dir.dx) : n / n.distance;
    final head = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo((tip - dir * headLen + wing * headHalf).dx, (tip - dir * headLen + wing * headHalf).dy)
      ..lineTo((tip - dir * headLen - wing * headHalf).dx, (tip - dir * headLen - wing * headHalf).dy)
      ..close();
    canvas.drawPath(head, Paint()..color = color);
    _text(canvas, tip + wing * 14, label, color);
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
  bool shouldRepaint(covariant _RestPainter oldDelegate) {
    return oldDelegate.lab.t != lab.t ||
        oldDelegate.params.r != params.r ||
        oldDelegate.params.omega != params.omega ||
        oldDelegate.params.mass != params.mass;
  }
}
