import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/energy_gauge.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// 上向き正。$g=9.8\,\mathrm{m/s^2}$。画面の再生だけ遅くしている。
const double kVerticalG = 9.8;
const double kVerticalMinH = 0.5;
const double kVerticalMaxH = 5.0;
const double kVerticalDefaultH = 3.0;
const double kVerticalMinV0 = 4.0;
const double kVerticalMaxV0 = 12.0;
const double kVerticalDefaultV0 = 8.0;
const double kVerticalStrobeDt = 0.10;

enum VerticalMotionKind { freeFall, throwUp, throwDown }

class VerticalMotionParams {
  const VerticalMotionParams({required this.h, required this.v0});

  final double h;
  final double v0;

  factory VerticalMotionParams.fromMap(Map<String, double> params) {
    return VerticalMotionParams(
      h: params['h']!.clamp(kVerticalMinH, kVerticalMaxH).toDouble(),
      v0: params['v0']!.clamp(kVerticalMinV0, kVerticalMaxV0).toDouble(),
    );
  }
}

class VerticalMotionSample {
  const VerticalMotionSample({
    required this.t,
    required this.y,
    required this.v,
  });

  final double t;
  final double y;
  final double v;
}

/// 質量 1 kg。地面を位置エネルギーの基準にする。空気抵抗はない。
EnergyLedger verticalMotionEnergy(
  VerticalMotionKind kind,
  VerticalMotionParams params,
  VerticalMotionSample sample,
) {
  const mass = 1.0;
  final y0 = kind == VerticalMotionKind.throwUp ? 0.0 : params.h;
  final v0 = kind == VerticalMotionKind.freeFall ? 0.0 : params.v0;
  final scale = 0.5 * mass * v0 * v0 + mass * kVerticalG * y0;
  final y = math.max(0.0, sample.y);
  return EnergyLedger(
    kinetic: 0.5 * mass * sample.v * sample.v,
    potential: mass * kVerticalG * y,
    dissipated: 0,
    scale: scale,
    potentialLabel: kLabelGravity,
  );
}

VerticalMotionSample verticalMotionAt(
  VerticalMotionKind kind,
  VerticalMotionParams params,
  double t,
) {
  final g = kVerticalG;
  final time = math.max(0.0, t);
  switch (kind) {
    case VerticalMotionKind.freeFall:
      return VerticalMotionSample(
        t: time,
        y: params.h - 0.5 * g * time * time,
        v: -g * time,
      );
    case VerticalMotionKind.throwUp:
      return VerticalMotionSample(
        t: time,
        y: params.v0 * time - 0.5 * g * time * time,
        v: params.v0 - g * time,
      );
    case VerticalMotionKind.throwDown:
      return VerticalMotionSample(
        t: time,
        y: params.h - params.v0 * time - 0.5 * g * time * time,
        v: -(params.v0 + g * time),
      );
  }
}

double verticalFlightDuration(
  VerticalMotionKind kind,
  VerticalMotionParams params,
) {
  final g = kVerticalG;
  switch (kind) {
    case VerticalMotionKind.freeFall:
      return math.sqrt(2 * params.h / g);
    case VerticalMotionKind.throwUp:
      return 2 * params.v0 / g;
    case VerticalMotionKind.throwDown:
      return (-params.v0 + math.sqrt(params.v0 * params.v0 + 2 * g * params.h)) /
          g;
  }
}

double verticalApexHeight(VerticalMotionKind kind, VerticalMotionParams params) {
  final g = kVerticalG;
  switch (kind) {
    case VerticalMotionKind.freeFall:
    case VerticalMotionKind.throwDown:
      return params.h;
    case VerticalMotionKind.throwUp:
      return params.v0 * params.v0 / (2 * g);
  }
}

String verticalMotionCaption(VerticalMotionKind kind) {
  switch (kind) {
    case VerticalMotionKind.freeFall:
      return '静かに離す。初速度は 0。働く力は重力だけ。\n'
          '重力は一定で下向き。速度だけが下向きに増える。\n'
          '着地の速さは √(2gh)。点の間隔は下ほど広い。';
    case VerticalMotionKind.throwUp:
      return '上向きに投げたとき、重力は下向きなので速さは減る。\n'
          '最高点では速度は 0 でも、重力は消えない。\n'
          '下降は、最高点から静かに放した自由落下と同じ。\n'
          '元の高さに戻ったとき、速さは初速と同じで、向きだけ下。';
    case VerticalMotionKind.throwDown:
      return '下向きに投げる。重力も下向きで、初めから速さがある。\n'
          '加速度は自由落下と同じ g。点の間隔は初めから広い。\n'
          '着地の速さは √(v₀²+2gh)。';
  }
}

List<VerticalMotionSample> verticalStrobe(
  VerticalMotionKind kind,
  VerticalMotionParams params,
  double t, {
  double dt = kVerticalStrobeDt,
}) {
  if (t <= 1e-9 || dt <= 0) return const [];
  final samples = <VerticalMotionSample>[];
  for (double ti = dt; ti < t - 1e-9; ti += dt) {
    final s = verticalMotionAt(kind, params, ti);
    if (s.y < -1e-6) break;
    samples.add(s);
  }
  return samples;
}

final freeFall1D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '自由落下',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>空気抵抗を無視すると、働く力は重力だけです。加速度は常に下向きの $g$ で、質量にはよりません。</p>
  <p>上向きを正にし、高さ $h$ から静かに放すと</p>
  <p>$$\displaystyle y=h-\frac{1}{2}gt^{2},\quad v=-gt$$</p>
  <p>地面に着くまでの時間と速さは</p>
  <p>$$\displaystyle t=\sqrt{\frac{2h}{g}},\quad |v|=\sqrt{2gh}$$</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: VerticalMotion1DSimulation.freeFall(),
      height: 860,
    ),
  ],
);

final verticalThrow1D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '鉛直投げ上げ・投げ下げ',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>空気抵抗を無視すると、働く力は重力だけです。加速度は常に下向きの $g$ で、投げた向きでは変わりません。</p>
  <p>上向きを正にします。鉛直投げ上げ（地面から初速 $v_0$）</p>
  <p>$$\displaystyle y=v_0 t-\frac{1}{2}gt^{2},\quad v=v_0-gt$$</p>
  <p>最高点では $v=0$ ですが、力は $mg$ のまま下向きです。</p>
  <p>$$\displaystyle H=\frac{v_0^{2}}{2g}$$</p>
  <p>鉛直投げ下げ（高さ $h$ から下向きの初速 $v_0$）</p>
  <p>$$\displaystyle y=h-v_0 t-\frac{1}{2}gt^{2},\quad v=-(v_0+gt)$$</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: VerticalMotion1DSimulation.verticalThrow(),
      height: 900,
    ),
  ],
);

class VerticalMotion1DSimulation extends PhysicsSimulation {
  VerticalMotion1DSimulation.freeFall()
      : this._(
          title: '自由落下',
          kinds: const [VerticalMotionKind.freeFall],
          initialKind: VerticalMotionKind.freeFall,
        );

  VerticalMotion1DSimulation.verticalThrow()
      : this._(
          title: '鉛直投げ上げ・投げ下げ',
          kinds: const [
            VerticalMotionKind.throwUp,
            VerticalMotionKind.throwDown,
          ],
          initialKind: VerticalMotionKind.throwUp,
        );

  VerticalMotion1DSimulation._({
    required String title,
    required this.kinds,
    required VerticalMotionKind initialKind,
  })  : _kind = initialKind,
        super(
          title: title,
          formula: const FormulaDisplay(
            r'\displaystyle a=-g',
          ),
          aspectRatio: 4 / 5,
          enableTime: false,
          showTimeOverlay: false,
        );

  final List<VerticalMotionKind> kinds;

  final ValueNotifier<double> simTime = ValueNotifier(0.0);

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    final next = math.min(_duration, simTime.value + dt * _playback);
    simTime.value = next;
    if (next >= _duration - 1e-4) _loop.pause();
  });

  ValueNotifier<bool> get running => _loop.running;

  Map<String, double> _latestParams = {};
  VerticalMotionKind _kind;

  static const double _playback = 0.25;

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'h': kVerticalDefaultH,
        'v0': kVerticalDefaultV0,
      };

  VerticalMotionParams get _params {
    if (_latestParams.isEmpty) {
      return VerticalMotionParams.fromMap(initialParameters);
    }
    return VerticalMotionParams.fromMap(_latestParams);
  }

  void _rememberParams(Map<String, double> params) {
    _latestParams = Map<String, double>.from(params);
  }

  double get _duration => verticalFlightDuration(_kind, _params);

  void start() {
    if (running.value) return;
    if (simTime.value >= _duration - 1e-3) {
      simTime.value = 0.0;
    }
    _loop.start();
  }

  void pause() => _loop.pause();

  void resetMotion() {
    _loop.reset();
    simTime.value = 0.0;
  }

  void applyKind(VerticalMotionKind kind) {
    _kind = kind;
    resetMotion();
  }

  String _formulaTex() {
    switch (_kind) {
      case VerticalMotionKind.freeFall:
        return r'\displaystyle y=h-\frac{1}{2}gt^{2},\quad v=-gt';
      case VerticalMotionKind.throwUp:
        return r'\displaystyle y=v_0 t-\frac{1}{2}gt^{2},\quad v=v_0-gt';
      case VerticalMotionKind.throwDown:
        return r'\displaystyle y=h-v_0 t-\frac{1}{2}gt^{2},\quad v=-(v_0+gt)';
    }
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
            Text(
              verticalMotionCaption(_kind),
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
            if (kinds.length > 1) ...[
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final kind in kinds)
                    _kindButton(_kindLabel(kind), kind, updateActiveIds),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  String _kindLabel(VerticalMotionKind kind) {
    switch (kind) {
      case VerticalMotionKind.freeFall:
        return '自由落下';
      case VerticalMotionKind.throwUp:
        return '鉛直投げ上げ';
      case VerticalMotionKind.throwDown:
        return '鉛直投げ下げ';
    }
  }

  Widget _kindButton(
    String label,
    VerticalMotionKind kind,
    void Function(Set<String> ids) updateActiveIds,
  ) {
    final selected = _kind == kind;
    final onPressed = () {
      applyKind(kind);
      // t=0 のままだと running / simTime が通知しない。親を作り直す。
      updateActiveIds({kind.name});
    };
    if (selected) {
      return FilledButton(onPressed: onPressed, child: Text(label));
    }
    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }

  @override
  List<Widget> buildControls(
    BuildContext context,
    Map<String, double> parameters,
    void Function(String key, double value) updateParam,
  ) {
    _rememberParams(parameters);
    final p = _params;
    final controls = <Widget>[
      const Text(
        '初期条件（g = 9.8 m/s²）',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    ];
    if (_kind != VerticalMotionKind.throwUp) {
      controls.add(
        _VerticalSlider(
          label: 'h',
          value: p.h,
          min: kVerticalMinH,
          max: kVerticalMaxH,
          onChanged: (v) => updateParam('h', v),
          semanticLabel: '高さ h',
        ),
      );
    }
    if (_kind != VerticalMotionKind.freeFall) {
      controls.add(
        _VerticalSlider(
          label: 'v0',
          value: p.v0,
          min: kVerticalMinV0,
          max: kVerticalMaxV0,
          onChanged: (v) => updateParam('v0', v),
          semanticLabel: '初速度 v0',
        ),
      );
    }
    final apex = verticalApexHeight(_kind, p);
    final duration = verticalFlightDuration(_kind, p);
    controls.add(
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '最高の高さ ${apex.toStringAsFixed(2)} m    着地まで ${duration.toStringAsFixed(2)} s',
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Courier',
            color: Color(0xFF37474F),
          ),
        ),
      ),
    );
    return controls;
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
        final p = VerticalMotionParams.fromMap(parameters);
        final duration = verticalFlightDuration(_kind, p);
        final t = math.min(simTime.value, duration);
        final sample = verticalMotionAt(_kind, p, t);
        final landed = simTime.value >= duration - 1e-4 && simTime.value > 0;
        final shown = landed
            ? VerticalMotionSample(t: duration, y: 0, v: verticalMotionAt(_kind, p, duration).v)
            : sample;
        return CustomPaint(
          size: Size.infinite,
          painter: _VerticalMotionPainter(
            kind: _kind,
            params: p,
            sample: shown,
            strobes: verticalStrobe(_kind, p, shown.t),
            running: running.value,
          ),
        );
      },
    );
  }
}

class _VerticalSlider extends StatelessWidget {
  const _VerticalSlider({
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

class _VerticalMotionPainter extends CustomPainter {
  _VerticalMotionPainter({
    required this.kind,
    required this.params,
    required this.sample,
    required this.strobes,
    required this.running,
  });

  final VerticalMotionKind kind;
  final VerticalMotionParams params;
  final VerticalMotionSample sample;
  final List<VerticalMotionSample> strobes;
  final bool running;

  static const _bg = Color(0xFFF7FAFC);
  static const _ball = Color(0xFF1E88E5);
  static const _force = Color(0xFFEF6C00);
  static const _trail = Color(0xFF78909C);
  static const _ground = Color(0xFF8D6E63);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final lines = _hudLines();
    final ledger = verticalMotionEnergy(kind, params, sample);
    final cardBottom = dynamicsReadoutCard(
      lines,
      ledger,
      textColumnWidth: 168,
      bounds: size,
    ).bottom;
    final map = _mapper(size, cardBottom + 16);
    _drawGround(canvas, size, map);
    _drawTrail(canvas, map);
    _drawBall(canvas, map);
    paintDynamicsReadout(
      canvas,
      lines,
      ledger,
      textColumnWidth: 168,
      bounds: size,
    );
  }

  String _hudLines() {
    final landed = sample.y <= 1e-3 && sample.t > 1e-3;
    return 't = ${sample.t.toStringAsFixed(2)} s\n'
        'y = ${(landed ? 0 : sample.y).toStringAsFixed(2)} m\n'
        'v = ${sample.v.toStringAsFixed(2)} m/s';
  }

  _YMap _mapper(Size size, double marginTop) {
    final top = verticalApexHeight(kind, params);
    const yMin = -0.15;
    final yMax = math.max(top, 0.8) + 0.35;
    const marginBottom = 22.0;
    final s = (size.height - marginTop - marginBottom) / (yMax - yMin);
    final x = size.width * 0.46;
    return _YMap(
      x: x,
      yOf: (y) => size.height - marginBottom - (y - yMin) * s,
      pxPerSpeed: 7,
    );
  }

  void _drawGround(Canvas canvas, Size size, _YMap map) {
    final y0 = map.yOf(0);
    canvas.drawLine(
      Offset(18, y0),
      Offset(size.width - 18, y0),
      Paint()
        ..color = _ground
        ..strokeWidth = 3,
    );
    _label(canvas, Offset(size.width - 36, y0 + 6), '地面', _ground);
  }

  void _drawTrail(Canvas canvas, _YMap map) {
    final rising = <Offset>[];
    final falling = <Offset>[];
    for (final s in strobes) {
      final goingUp = kind == VerticalMotionKind.throwUp && s.v >= -0.02;
      final dx = goingUp ? -16.0 : (kind == VerticalMotionKind.throwUp ? 16.0 : 0.0);
      final p = Offset(map.x + dx, map.yOf(math.max(0, s.y)));
      if (goingUp) {
        rising.add(p);
      } else {
        falling.add(p);
      }
    }
    _dash(canvas, rising);
    _dash(canvas, falling);
    for (final p in [...rising, ...falling]) {
      canvas.drawCircle(p, 3.2, Paint()..color = _trail);
    }
  }

  void _dash(Canvas canvas, List<Offset> pts) {
    if (pts.length < 2) return;
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
      while (d < len) {
        final end = math.min(d + dash, len);
        canvas.drawLine(a + dir * d, a + dir * end, paint);
        d += dash + gap;
      }
    }
  }

  void _drawBall(Canvas canvas, _YMap map) {
    final y = math.max(0.0, sample.y);
    final c = Offset(map.x, map.yOf(y));
    canvas.drawCircle(c.translate(0, 2), 12, Paint()..color = Colors.black12);
    canvas.drawCircle(c, 11, Paint()..color = _ball);
    _drawArrow(
      canvas,
      c + const Offset(-18, 0),
      const Offset(0, 1),
      52,
      _force,
      '重力',
      labelSide: -1,
    );
    if (sample.v.abs() < 0.4) {
      _label(canvas, c + const Offset(28, -6), 'v = 0', _ball);
    } else {
      final dir = sample.v >= 0 ? const Offset(0, -1) : const Offset(0, 1);
      final len = (sample.v.abs() * map.pxPerSpeed).clamp(12.0, 96.0);
      _drawArrow(
        canvas,
        c + const Offset(18, 0),
        dir,
        len,
        _ball,
        'v',
        labelSide: 1,
      );
    }
  }

  void _drawArrow(
    Canvas canvas,
    Offset origin,
    Offset dir,
    double length,
    Color color,
    String label, {
    required int labelSide,
  }) {
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
      ..lineTo((tip - dir * headLen + n * headHalf).dx,
          (tip - dir * headLen + n * headHalf).dy)
      ..lineTo((tip - dir * headLen - n * headHalf).dx,
          (tip - dir * headLen - n * headHalf).dy)
      ..close();
    canvas.drawPath(head, Paint()..color = color);
    _label(canvas, tip + n * (12.0 * labelSide), label, color);
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
  bool shouldRepaint(covariant _VerticalMotionPainter oldDelegate) {
    return oldDelegate.sample.t != sample.t ||
        oldDelegate.sample.y != sample.y ||
        oldDelegate.kind != kind ||
        oldDelegate.params.h != params.h ||
        oldDelegate.params.v0 != params.v0 ||
        oldDelegate.running != running;
  }
}

class _YMap {
  const _YMap({required this.x, required this.yOf, required this.pxPerSpeed});

  final double x;
  final double Function(double y) yOf;
  final double pxPerSpeed;
}
