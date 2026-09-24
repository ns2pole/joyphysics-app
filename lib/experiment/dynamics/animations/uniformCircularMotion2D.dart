import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/energy_gauge.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// 水平面上の等速円運動。質量は $1\,\mathrm{kg}$。再生だけ遅くする。
const double kCircularMass = 1.0;
const double kCircularMinR = 0.60;
const double kCircularMaxR = 1.40;
const double kCircularDefaultR = 1.00;
const double kCircularMinV = 1.20;
const double kCircularMaxV = 3.00;
const double kCircularDefaultV = 2.00;
const double kCircularStrobeDt = 0.10;

class CircularParams {
  const CircularParams({required this.r, required this.v});

  final double r;
  final double v;

  double get omega => v / r;
  double get period => 2 * math.pi * r / v;
  double get centripetalAccel => v * v / r;
  double get tension => kCircularMass * centripetalAccel;

  factory CircularParams.fromMap(Map<String, double> params) {
    return CircularParams(
      r: params['r']!.clamp(kCircularMinR, kCircularMaxR).toDouble(),
      v: params['v']!.clamp(kCircularMinV, kCircularMaxV).toDouble(),
    );
  }
}

class CircularSample {
  const CircularSample({
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

/// 水平面なので位置エネルギーは一定。張力は仕事をしないので運動エネルギーも一定。
EnergyLedger circularEnergy(CircularParams params) {
  final kinetic = 0.5 * kCircularMass * params.v * params.v;
  return EnergyLedger(
    kinetic: kinetic,
    potential: 0,
    dissipated: 0,
    scale: kinetic,
    legendPotential: false,
  );
}

CircularSample circularAt(CircularParams params, double t) {
  final time = math.max(0.0, t);
  final theta = params.omega * time;
  return CircularSample(
    t: time,
    theta: theta,
    x: params.r * math.cos(theta),
    y: params.r * math.sin(theta),
    vx: -params.v * math.sin(theta),
    vy: params.v * math.cos(theta),
  );
}

String circularCaption() {
  return '水平面上、摩擦なし。働く力は紐の張力だけ。\n'
      '速さは一定。速度は接線、張力は中心向き。';
}

List<CircularSample> circularStrobe(
  CircularParams params,
  double t, {
  double dt = kCircularStrobeDt,
}) {
  if (t <= 1e-9 || dt <= 0) return const [];
  final limit = math.min(t, params.period);
  final samples = <CircularSample>[];
  for (double ti = dt; ti < limit - 1e-9; ti += dt) {
    samples.add(circularAt(params, ti));
  }
  return samples;
}

final uniformCircularMotion2D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '等速円運動',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>水平な机の上で、ピンに結んだ伸びない紐の先のボールが、摩擦なしで等速円運動します。働く力は張力だけです。</p>
  <p>$$\displaystyle x=R\cos\omega t,\quad y=R\sin\omega t$$</p>
  <p>$$\displaystyle \omega=\frac{v}{R},\quad T=\frac{2\pi R}{v}$$</p>
  <p>向心加速度と張力の大きさは</p>
  <p>$$\displaystyle a=\frac{v^{2}}{R},\quad F=m\frac{v^{2}}{R}$$</p>
  <p>加速度の向きは中心向きで、速度は常に接線方向です。速さは一定のまま、向きだけが変わります。</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: UniformCircularMotion2DSimulation(),
      height: 860,
    ),
  ],
);

class UniformCircularMotion2DSimulation extends PhysicsSimulation {
  UniformCircularMotion2DSimulation()
      : super(
          title: '等速円運動',
          formula: const FormulaDisplay(
            r'\displaystyle a=\frac{v^{2}}{R},\quad T=\frac{2\pi R}{v}',
          ),
          aspectRatio: 1,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> simTime = ValueNotifier(0.0);

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    simTime.value = simTime.value + dt * _playback;
  });

  ValueNotifier<bool> get running => _loop.running;

  Map<String, double> _latestParams = {};

  static const double _playback = 0.45;

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'r': kCircularDefaultR,
        'v': kCircularDefaultV,
      };

  CircularParams get _params {
    if (_latestParams.isEmpty) {
      return CircularParams.fromMap(initialParameters);
    }
    return CircularParams.fromMap(_latestParams);
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
              circularCaption(),
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
        '初期条件（m = 1 kg、水平面、摩擦なし）',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _CircularSlider(
        label: 'R',
        value: p.r,
        min: kCircularMinR,
        max: kCircularMaxR,
        onChanged: (v) => updateParam('r', v),
        semanticLabel: '半径 R',
      ),
      _CircularSlider(
        label: 'v',
        value: p.v,
        min: kCircularMinV,
        max: kCircularMaxV,
        onChanged: (v) => updateParam('v', v),
        semanticLabel: '速さ v',
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '周期 ${p.period.toStringAsFixed(2)} s    '
          '加速度 ${p.centripetalAccel.toStringAsFixed(2)} m/s²    '
          '張力(向心力) ${p.tension.toStringAsFixed(2)} N',
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
        final p = CircularParams.fromMap(parameters);
        final sample = circularAt(p, simTime.value);
        return CustomPaint(
          size: Size.infinite,
          painter: _CircularPainter(
            params: p,
            sample: sample,
            strobes: circularStrobe(p, sample.t),
          ),
        );
      },
    );
  }
}

class _CircularSlider extends StatelessWidget {
  const _CircularSlider({
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

class _CircularPainter extends CustomPainter {
  _CircularPainter({
    required this.params,
    required this.sample,
    required this.strobes,
  });

  final CircularParams params;
  final CircularSample sample;
  final List<CircularSample> strobes;

  static const _bg = Color(0xFFF7FAFC);
  static const _ball = Color(0xFF1E88E5);
  static const _force = Color(0xFFEF6C00);
  static const _string = Color(0xFF6D4C41);
  static const _orbit = Color(0xFFB0BEC5);
  static const _trail = Color(0xFF78909C);
  static const _pin = Color(0xFF263238);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final lines = _hudLines();
    final ledger = circularEnergy(params);
    final cardBottom = dynamicsReadoutCard(
      lines,
      ledger,
      textColumnWidth: 260,
      bounds: size,
    ).bottom;
    final map = _mapper(size, cardBottom);
    _drawOrbit(canvas, map);
    _drawTrail(canvas, map);
    _drawString(canvas, map);
    _drawArrows(canvas, map);
    _drawBall(canvas, map);
    _drawPin(canvas, map);
    paintDynamicsReadout(
      canvas,
      lines,
      ledger,
      textColumnWidth: 260,
      bounds: size,
    );
  }

  String _hudLines() {
    final deg = (sample.theta * 180 / math.pi) % 360;
    return 't = ${sample.t.toStringAsFixed(2)} s    '
        'θ = ${deg.toStringAsFixed(0)}°\n'
        'v = ${sample.speed.toStringAsFixed(2)} m/s\n'
        'a = ${params.centripetalAccel.toStringAsFixed(2)} m/s²    '
        'F = ${params.tension.toStringAsFixed(2)} N';
  }

  _Map _mapper(Size size, double cardBottom) {
    final reach = params.r * 1.35;
    const margin = 28.0;
    final hudClear = math.max(72.0, cardBottom + 8);
    final plotH = math.max(48.0, size.height - hudClear);
    final s = math.min(size.width, plotH) / 2 - margin;
    final scale = s / reach;
    return _Map(
      of: (x, y) => Offset(
        size.width / 2 + x * scale,
        hudClear + plotH / 2 - y * scale,
      ),
      pxPerSpeed: math.min(18.0, 70 / math.max(params.v, 0.5)),
      pxPerForce: math.min(14.0, 90 / math.max(params.tension, 0.5)),
    );
  }

  void _drawOrbit(Canvas canvas, _Map map) {
    final c = map.of(0, 0);
    final edge = map.of(params.r, 0);
    canvas.drawCircle(
      c,
      (edge - c).distance,
      Paint()
        ..color = _orbit
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  void _drawTrail(Canvas canvas, _Map map) {
    final lap = sample.t % params.period;
    final pts = <Offset>[map.of(params.r, 0)];
    for (final s in strobes) {
      if (s.t <= lap + 1e-9) pts.add(map.of(s.x, s.y));
    }
    pts.add(map.of(sample.x, sample.y));
    final paint = Paint()
      ..color = _trail
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    const dash = 5.0;
    const gap = 4.0;
    for (int i = 0; i < pts.length - 1; i++) {
      final a = pts[i];
      final b = pts[i + 1];
      final delta = b - a;
      final len = delta.distance;
      if (len < 1) continue;
      final dir = delta / len;
      double d = 0;
      var draw = i.isEven;
      while (d < len) {
        final end = math.min(d + (draw ? dash : gap), len);
        if (draw) {
          canvas.drawLine(a + dir * d, a + dir * end, paint);
        }
        d = end;
        if (d < len) draw = !draw;
      }
    }
    for (final s in strobes) {
      canvas.drawCircle(map.of(s.x, s.y), 3.1, Paint()..color = _trail);
    }
  }

  void _drawString(Canvas canvas, _Map map) {
    canvas.drawLine(
      map.of(0, 0),
      map.of(sample.x, sample.y),
      Paint()
        ..color = _string
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawArrows(Canvas canvas, _Map map) {
    final c = map.of(sample.x, sample.y);
    final pin = map.of(0, 0);
    final toPin = pin - c;
    final pinLen = toPin.distance;
    if (pinLen > 8) {
      final tensionLen =
          (params.tension * map.pxPerForce).clamp(18.0, pinLen * 0.72);
      _arrow(canvas, c, toPin / pinLen, tensionLen, _force, '張力(向心力)');
    }
    final ahead = map.of(
      sample.x + sample.vx * 0.05,
      sample.y + sample.vy * 0.05,
    );
    final vel = ahead - c;
    final velLen = vel.distance;
    if (velLen > 0.5) {
      _arrow(
        canvas,
        c,
        vel / velLen,
        (sample.speed * map.pxPerSpeed).clamp(22.0, 78.0),
        _ball,
        'v',
      );
    }
  }

  void _drawBall(Canvas canvas, _Map map) {
    final c = map.of(sample.x, sample.y);
    canvas.drawCircle(c.translate(1.5, 2), 11, Paint()..color = Colors.black12);
    canvas.drawCircle(c, 10, Paint()..color = _ball);
  }

  void _drawPin(Canvas canvas, _Map map) {
    final c = map.of(0, 0);
    canvas.drawCircle(c, 5.5, Paint()..color = _pin);
    canvas.drawCircle(c.translate(-1.2, -1.2), 1.6, Paint()..color = Colors.white70);
  }

  void _arrow(
    Canvas canvas,
    Offset origin,
    Offset dir,
    double length,
    Color color,
    String label,
  ) {
    final tip = origin + dir * length;
    const headLen = 10.0;
    const headHalf = 5.0;
    final shaftEnd = tip - dir * (headLen * 0.72);
    final n = Offset(-dir.dy, dir.dx);
    canvas.drawLine(
      origin,
      shaftEnd,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 4.4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      origin,
      shaftEnd,
      Paint()
        ..color = color
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    final head = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo((tip - dir * headLen + n * headHalf).dx, (tip - dir * headLen + n * headHalf).dy)
      ..lineTo((tip - dir * headLen - n * headHalf).dx, (tip - dir * headLen - n * headHalf).dy)
      ..close();
    canvas.drawPath(head, Paint()..color = color);
    _label(canvas, tip + n * 12, label, color);
  }

  void _label(Canvas canvas, Offset o, String text, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(o.dx - tp.width / 2, o.dy));
  }

  @override
  bool shouldRepaint(covariant _CircularPainter oldDelegate) {
    return oldDelegate.sample.t != sample.t ||
        oldDelegate.params.r != params.r ||
        oldDelegate.params.v != params.v;
  }
}

class _Map {
  const _Map({
    required this.of,
    required this.pxPerSpeed,
    required this.pxPerForce,
  });

  final Offset Function(double x, double y) of;
  final double pxPerSpeed;
  final double pxPerForce;
}
