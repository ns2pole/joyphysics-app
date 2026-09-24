import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/energy_gauge.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// 右向き正。水平面。$g=9.8\,\mathrm{m/s^2}$。画面の再生だけ遅くしている。
const double kFrictionG = 9.8;
const double kFrictionMinV0 = 1.0;
const double kFrictionMaxV0 = 6.0;
const double kFrictionDefaultV0 = 4.0;
const double kFrictionMinMu = 0.0;
const double kFrictionMaxMu = 0.60;
const double kFrictionDefaultMu = 0.20;
const double kFrictionStrobeDt = 0.10;

class KineticFrictionParams {
  const KineticFrictionParams({required this.v0, required this.mu});

  final double v0;
  final double mu;

  factory KineticFrictionParams.fromMap(Map<String, double> params) {
    return KineticFrictionParams(
      v0: params['v0']!.clamp(kFrictionMinV0, kFrictionMaxV0).toDouble(),
      mu: params['mu']!.clamp(kFrictionMinMu, kFrictionMaxMu).toDouble(),
    );
  }
}

class KineticFrictionSample {
  const KineticFrictionSample({
    required this.t,
    required this.x,
    required this.v,
    required this.a,
    required this.stopped,
  });

  final double t;
  final double x;
  final double v;
  final double a;
  final bool stopped;
}

/// 質量 1 kg。減った運動エネルギーを熱にする。
EnergyLedger kineticFrictionEnergy(
  KineticFrictionParams params,
  KineticFrictionSample sample,
) {
  const mass = 1.0;
  final scale = 0.5 * mass * params.v0 * params.v0;
  final kinetic = 0.5 * mass * sample.v * sample.v;
  final heat = math.max(0.0, scale - kinetic);
  return EnergyLedger(
    kinetic: kinetic,
    potential: 0,
    dissipated: heat,
    scale: scale,
    legendPotential: false,
    legendHeat: heat > 1e-6,
  );
}

/// $\mu=0$ のときは止まらないので null。
double? kineticFrictionStopTime(KineticFrictionParams params) {
  if (params.mu <= 1e-12) return null;
  return params.v0 / (params.mu * kFrictionG);
}

/// $\displaystyle x=\frac{v_0^{2}}{2\mu g}$。$\mu=0$ のときは null。
double? kineticFrictionStopDistance(KineticFrictionParams params) {
  if (params.mu <= 1e-12) return null;
  return params.v0 * params.v0 / (2 * params.mu * kFrictionG);
}

KineticFrictionSample kineticFrictionAt(KineticFrictionParams params, double t) {
  final time = math.max(0.0, t);
  final v0 = params.v0;
  if (params.mu <= 1e-12) {
    return KineticFrictionSample(
      t: time,
      x: v0 * time,
      v: v0,
      a: 0,
      stopped: false,
    );
  }
  final decel = params.mu * kFrictionG;
  final tStop = v0 / decel;
  if (time >= tStop) {
    return KineticFrictionSample(
      t: tStop,
      x: v0 * v0 / (2 * decel),
      v: 0,
      a: 0,
      stopped: true,
    );
  }
  return KineticFrictionSample(
    t: time,
    x: v0 * time - 0.5 * decel * time * time,
    v: v0 - decel * time,
    a: -decel,
    stopped: false,
  );
}

List<KineticFrictionSample> kineticFrictionStrobe(
  KineticFrictionParams params,
  double t, {
  double dt = kFrictionStrobeDt,
}) {
  if (t <= 1e-9 || dt <= 0) return const [];
  final samples = <KineticFrictionSample>[];
  for (double ti = dt; ti < t - 1e-9; ti += dt) {
    final s = kineticFrictionAt(params, ti);
    if (s.stopped) break;
    samples.add(s);
  }
  return samples;
}

const String kKineticFrictionCaption =
    '水平な面を右向きの初速で滑らせる。働く力は動摩擦力だけ。\n'
    '加速度は −μg で一定。速さは直線的に減る。\n'
    '止まったあとは速度も摩擦力も 0 のまま。戻らない。\n'
    'μ = 0 なら等速直線運動で、止まらない。';

final kineticFriction1D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '水平面上の動摩擦力',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>水平な面で、働く力は動摩擦力だけです。垂直抗力は $N=mg$ なので、動摩擦力の大きさは $\mu mg$ です。右向きを正にすると加速度は</p>
  <p>$$a=-\mu g$$</p>
  <p>質量は約分されて、加速度には残りません。初速 $v_0$ で右へ滑らせると、速さが 0 になるまで</p>
  <p>$$x=v_0 t-\frac{1}{2}\mu g t^{2},\quad v=v_0-\mu g t$$</p>
  <p>止まる時刻と距離は</p>
  <p>$$t=\frac{v_0}{\mu g},\quad x=\frac{v_0^{2}}{2\mu g}$$</p>
  <p>止まったあとは速度も摩擦力も 0 です。向きが反転して戻ることはありません。$\mu=0$ なら $a=0$ で、等速直線運動のままです。</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: KineticFriction1DSimulation(),
      height: 780,
    ),
  ],
);

class KineticFriction1DSimulation extends PhysicsSimulation {
  KineticFriction1DSimulation()
      : super(
          title: '水平面上の動摩擦力',
          formula: const FormulaDisplay(
            r'\displaystyle x=v_0 t-\frac{1}{2}\mu g t^{2},\quad v=v_0-\mu g t',
          ),
          aspectRatio: (16 / 9) / 1.5,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> simTime = ValueNotifier(0.0);

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    final stop = kineticFrictionStopTime(_params);
    if (stop == null) {
      simTime.value += dt * _playback;
      return;
    }
    final next = math.min(stop, simTime.value + dt * _playback);
    simTime.value = next;
    if (next >= stop - 1e-4) _loop.pause();
  });

  ValueNotifier<bool> get running => _loop.running;

  Map<String, double> _latestParams = {};

  static const double _playback = 0.35;

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'v0': kFrictionDefaultV0,
        'mu': kFrictionDefaultMu,
      };

  KineticFrictionParams get _params {
    if (_latestParams.isEmpty) {
      return KineticFrictionParams.fromMap(initialParameters);
    }
    return KineticFrictionParams.fromMap(_latestParams);
  }

  void _rememberParams(Map<String, double> params) {
    _latestParams = Map<String, double>.from(params);
  }

  void start() {
    if (running.value) return;
    final stop = kineticFrictionStopTime(_params);
    if (stop != null && simTime.value >= stop - 1e-3) {
      simTime.value = 0.0;
    }
    _loop.start();
  }

  void pause() => _loop.pause();

  void resetMotion() {
    _loop.reset();
    simTime.value = 0.0;
  }

  String _formulaTex() {
    if (_params.mu <= 1e-12) {
      return r'\displaystyle x=v_0 t,\quad v=v_0';
    }
    return r'\displaystyle x=v_0 t-\frac{1}{2}\mu g t^{2},\quad v=v_0-\mu g t';
  }

  @override
  Widget? buildFormulaOverlay(Map<String, double> parameters) {
    _rememberParams(parameters);
    return FormulaDisplay(_formulaTex());
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
            const Text(
              kKineticFrictionCaption,
              textAlign: TextAlign.center,
              style: TextStyle(
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
    final stopT = kineticFrictionStopTime(p);
    final stopX = kineticFrictionStopDistance(p);
    final summary = stopT == null
        ? '止まらない（等速直線運動）'
        : '停止まで ${stopT.toStringAsFixed(2)} s    停止距離 ${stopX!.toStringAsFixed(2)} m';
    return [
      const Text(
        '初期条件（g = 9.8 m/s²、右向き正）',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _FrictionSlider(
        label: 'v0',
        value: p.v0,
        min: kFrictionMinV0,
        max: kFrictionMaxV0,
        onChanged: (v) => updateParam('v0', v),
        semanticLabel: '初速度 v0',
      ),
      _FrictionSlider(
        label: 'μ',
        value: p.mu,
        min: kFrictionMinMu,
        max: kFrictionMaxMu,
        onChanged: (v) => updateParam('mu', v),
        semanticLabel: '動摩擦係数 μ',
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          summary,
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
        final p = KineticFrictionParams.fromMap(parameters);
        final sample = kineticFrictionAt(p, simTime.value);
        return CustomPaint(
          size: Size.infinite,
          painter: _KineticFrictionPainter(
            params: p,
            sample: sample,
            strobes: kineticFrictionStrobe(p, sample.t),
            running: running.value,
          ),
        );
      },
    );
  }
}

class _FrictionSlider extends StatelessWidget {
  const _FrictionSlider({
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
          width: 44,
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

class _KineticFrictionPainter extends CustomPainter {
  _KineticFrictionPainter({
    required this.params,
    required this.sample,
    required this.strobes,
    required this.running,
  });

  final KineticFrictionParams params;
  final KineticFrictionSample sample;
  final List<KineticFrictionSample> strobes;
  final bool running;

  static const _bg = Color(0xFFF7FAFC);
  static const _block = Color(0xFF1E88E5);
  static const _force = Color(0xFFEF6C00);
  static const _velocity = Color(0xFF1565C0);
  static const _trail = Color(0xFF78909C);
  static const _ink = Color(0xFF37474F);
  static const _ground = Color(0xFF8D6E63);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final lines = _hudLines();
    final ceiling = dynamicsReadoutCard(
      lines,
      kineticFrictionEnergy(params, sample),
      textColumnWidth: 220,
      bounds: size,
    ).bottom;
    final railY = math.max(size.height * 0.62, ceiling + 112);
    final map = _mapper(size);
    _drawGround(canvas, size, railY, map);
    _drawStopMark(canvas, railY, map);
    _drawTrail(canvas, railY, map);
    _drawBlock(canvas, railY, map);
    _drawHud(canvas, lines);
  }

  _XMap _mapper(Size size) {
    const left = 28.0;
    final right = size.width - 20;
    final stop = kineticFrictionStopDistance(params);
    late final double xMin;
    late final double xMax;
    if (stop != null) {
      xMin = -0.06 * math.max(stop, 0.4);
      xMax = math.max(stop, 0.4) * 1.22;
    } else {
      const window = 5.0;
      if (sample.x < window * 0.7) {
        xMin = -0.25;
        xMax = window;
      } else {
        xMax = sample.x + window * 0.3;
        xMin = xMax - window;
      }
    }
    final span = xMax - xMin;
    return _XMap(
      xOf: (x) => left + (x - xMin) / span * (right - left),
      xMin: xMin,
      xMax: xMax,
    );
  }

  void _drawGround(Canvas canvas, Size size, double railY, _XMap map) {
    canvas.drawLine(
      Offset(16, railY),
      Offset(size.width - 12, railY),
      Paint()
        ..color = _ground
        ..strokeWidth = 3,
    );
    final span = map.xMax - map.xMin;
    final step = span > 8
        ? 2.0
        : span > 3
            ? 1.0
            : span > 1
                ? 0.5
                : span > 0.4
                    ? 0.2
                    : 0.05;
    final first = (map.xMin / step).ceil() * step;
    for (var x = first; x <= map.xMax + 1e-9; x += step) {
      final px = map.xOf(x);
      canvas.drawLine(
        Offset(px, railY),
        Offset(px, railY + 8),
        Paint()
          ..color = _ground
          ..strokeWidth = 1.4,
      );
      if ((x / step).round().isEven || step >= 0.5) {
        _label(canvas, Offset(px, railY + 12), x.toStringAsFixed(step < 0.2 ? 2 : 1), _ink);
      }
    }
  }

  void _drawStopMark(Canvas canvas, double railY, _XMap map) {
    final stop = kineticFrictionStopDistance(params);
    if (stop == null) return;
    final px = map.xOf(stop);
    final paint = Paint()
      ..color = _force
      ..strokeWidth = 1.4;
    var y = railY - 92.0;
    while (y < railY) {
      canvas.drawLine(Offset(px, y), Offset(px, math.min(y + 6, railY)), paint);
      y += 10;
    }
    _label(canvas, Offset(px, railY - 106), '停止', _force);
  }

  void _drawTrail(Canvas canvas, double railY, _XMap map) {
    final pts = <Offset>[];
    for (final s in strobes) {
      if (s.x < map.xMin || s.x > map.xMax) continue;
      pts.add(Offset(map.xOf(s.x), railY - 18));
    }
    if (pts.length >= 2) {
      final paint = Paint()
        ..color = _trail
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke;
      for (var i = 0; i < pts.length - 1; i++) {
        final a = pts[i];
        final b = pts[i + 1];
        final delta = b - a;
        final len = delta.distance;
        if (len < 1) continue;
        final dir = delta / len;
        var d = 0.0;
        while (d < len) {
          final end = math.min(d + 5, len);
          canvas.drawLine(a + dir * d, a + dir * end, paint);
          d += 9;
        }
      }
    }
    for (final p in pts) {
      canvas.drawCircle(p, 3.2, Paint()..color = _trail);
    }
  }

  void _drawBlock(Canvas canvas, double railY, _XMap map) {
    final c = Offset(map.xOf(sample.x), railY - 18);
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: 46, height: 32),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect.shift(const Offset(0, 2)), Paint()..color = Colors.black12);
    canvas.drawRRect(rect, Paint()..color = _block);

    final vLen = sample.v <= 0.05 ? 0.0 : (sample.v / params.v0 * 72).clamp(14.0, 84.0);
    if (vLen == 0) {
      _label(canvas, c + const Offset(0, -46), 'v = 0', _velocity);
    } else {
      _drawArrow(canvas, c + const Offset(28, -8), const Offset(1, 0), vLen, _velocity, 'v');
    }
    if (!sample.stopped && params.mu > 1e-12) {
      final fLen = (22 + params.mu / kFrictionMaxMu * 48).clamp(22.0, 74.0);
      _drawArrow(canvas, c + const Offset(-28, -28), const Offset(-1, 0), fLen, _force, '摩擦');
    }
  }

  void _drawArrow(
    Canvas canvas,
    Offset origin,
    Offset dir,
    double length,
    Color color,
    String label,
  ) {
    final tip = origin + dir * length;
    const headLen = 11.0;
    const headHalf = 5.5;
    final shaftEnd = tip - dir * (headLen * 0.75);
    final n = Offset(-dir.dy, dir.dx);
    canvas.drawLine(
      origin,
      shaftEnd,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      origin,
      shaftEnd,
      Paint()
        ..color = color
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round,
    );
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
    _label(canvas, tip + const Offset(0, -16), label, color);
  }

  String _hudLines() {
    final stopT = kineticFrictionStopTime(params);
    final stopX = kineticFrictionStopDistance(params);
    final tail = stopT == null
        ? '止まらない'
        : '停止 ${stopT.toStringAsFixed(2)} s, ${stopX!.toStringAsFixed(2)} m';
    return 't = ${sample.t.toStringAsFixed(2)} s\n'
        'x = ${sample.x.toStringAsFixed(2)} m\n'
        'v = ${sample.v.toStringAsFixed(2)} m/s\n'
        'a = ${sample.a.toStringAsFixed(2)} m/s²\n'
        '$tail';
  }

  void _drawHud(Canvas canvas, String lines) {
    paintDynamicsReadout(
      canvas,
      lines,
      kineticFrictionEnergy(params, sample),
      textColumnWidth: 220,
    );
  }

  void _label(Canvas canvas, Offset o, String text, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(o.dx - tp.width / 2, o.dy));
  }

  @override
  bool shouldRepaint(covariant _KineticFrictionPainter oldDelegate) {
    return oldDelegate.sample.t != sample.t ||
        oldDelegate.sample.x != sample.x ||
        oldDelegate.sample.v != sample.v ||
        oldDelegate.params.v0 != params.v0 ||
        oldDelegate.params.mu != params.mu ||
        oldDelegate.running != running;
  }
}

class _XMap {
  const _XMap({required this.xOf, required this.xMin, required this.xMax});

  final double Function(double x) xOf;
  final double xMin;
  final double xMax;
}
