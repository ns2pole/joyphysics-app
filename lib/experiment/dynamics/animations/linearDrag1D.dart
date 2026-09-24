import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/energy_gauge.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// 上向き正。抵抗は速度に比例。$g=9.8\,\mathrm{m/s^2}$。再生だけ遅くしている。
const double kLinearDragG = 9.8;
const double kLinearDragMinH = 4.0;
const double kLinearDragMaxH = 30.0;
const double kLinearDragDefaultH = 15.0;
const double kLinearDragMinV0 = 3.0;
const double kLinearDragMaxV0 = 12.0;
const double kLinearDragDefaultV0 = 8.0;
const double kLinearDragMinVt = 2.0;
const double kLinearDragMaxVt = 12.0;
const double kLinearDragDefaultVt = 5.0;
const double kLinearDragStrobeDt = 0.20;

enum LinearDragKind { drop, throwUp, throwDown }

class LinearDragParams {
  const LinearDragParams({
    required this.h,
    required this.v0,
    required this.vt,
  });

  final double h;
  final double v0;
  final double vt;

  factory LinearDragParams.fromMap(Map<String, double> params) {
    return LinearDragParams(
      h: params['h']!.clamp(kLinearDragMinH, kLinearDragMaxH).toDouble(),
      v0: params['v0']!.clamp(kLinearDragMinV0, kLinearDragMaxV0).toDouble(),
      vt: params['vt']!.clamp(kLinearDragMinVt, kLinearDragMaxVt).toDouble(),
    );
  }
}

class LinearDragSample {
  const LinearDragSample({
    required this.t,
    required this.y,
    required this.v,
    required this.a,
    required this.landed,
  });

  final double t;
  final double y;
  final double v;
  final double a;
  final bool landed;
}

/// 質量 1 kg。抵抗がした仕事を熱にする。地面を位置エネルギーの基準にする。
EnergyLedger linearDragEnergy(
  LinearDragKind kind,
  LinearDragParams params,
  LinearDragSample sample,
) {
  final launch = _launch(kind, params);
  final scale = 0.5 * launch.v0 * launch.v0 + kLinearDragG * launch.y0;
  final kinetic = 0.5 * sample.v * sample.v;
  final potential = kLinearDragG * math.max(0.0, sample.y);
  final heat = math.max(0.0, scale - kinetic - potential);
  return EnergyLedger(
    kinetic: kinetic,
    potential: potential,
    dissipated: heat,
    scale: scale,
    legendHeat: heat > 1e-6,
    potentialLabel: kLabelGravity,
  );
}

/// $k=b/m=g/v_t$。単位は $1/\mathrm{s}$。
double linearDragK(double vt) => kLinearDragG / vt;

class _LinearDragLaunch {
  const _LinearDragLaunch({required this.y0, required this.v0});

  final double y0;
  final double v0;
}

_LinearDragLaunch _launch(LinearDragKind kind, LinearDragParams params) {
  switch (kind) {
    case LinearDragKind.drop:
      return _LinearDragLaunch(y0: params.h, v0: 0);
    case LinearDragKind.throwUp:
      return _LinearDragLaunch(y0: 0, v0: params.v0);
    case LinearDragKind.throwDown:
      return _LinearDragLaunch(y0: params.h, v0: -params.v0);
  }
}

double _decay(double k, double t) {
  final x = k * t;
  if (x > 40) return 0;
  return math.exp(-x);
}

/// 地面で止めない。$y$ は負になり得る。
LinearDragSample linearDragUnbounded(
  LinearDragKind kind,
  LinearDragParams params,
  double t,
) {
  final time = math.max(0.0, t);
  final launch = _launch(kind, params);
  final vt = params.vt;
  final k = linearDragK(vt);
  final e = _decay(k, time);
  final v = -vt + (launch.v0 + vt) * e;
  final y = launch.y0 - vt * time + ((launch.v0 + vt) / k) * (1 - e);
  final a = -k * (launch.v0 + vt) * e;
  return LinearDragSample(t: time, y: y, v: v, a: a, landed: false);
}

/// 投げ上げで速度が 0 になる時刻。
double linearDragApexTime(LinearDragParams params) {
  final k = linearDragK(params.vt);
  return math.log(1 + params.v0 / params.vt) / k;
}

double linearDragApexHeight(LinearDragParams params) {
  return linearDragUnbounded(
    LinearDragKind.throwUp,
    params,
    linearDragApexTime(params),
  ).y;
}

double linearDragFlightDuration(LinearDragKind kind, LinearDragParams params) {
  final start = kind == LinearDragKind.throwUp ? linearDragApexTime(params) : 0.0;
  var lo = start;
  var hi = start + 0.05;
  var guard = 0;
  while (linearDragUnbounded(kind, params, hi).y > 0 && guard < 80) {
    hi = hi * 1.25 + 0.05;
    guard++;
  }
  for (var i = 0; i < 60; i++) {
    final mid = (lo + hi) / 2;
    if (linearDragUnbounded(kind, params, mid).y > 0) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return hi;
}

LinearDragSample linearDragAt(
  LinearDragKind kind,
  LinearDragParams params,
  double t,
) {
  final duration = linearDragFlightDuration(kind, params);
  final time = math.max(0.0, t);
  if (time >= duration) {
    final at = linearDragUnbounded(kind, params, duration);
    return LinearDragSample(t: duration, y: 0, v: at.v, a: at.a, landed: true);
  }
  return linearDragUnbounded(kind, params, time);
}

/// 同じ初期条件で抵抗がないとき。地面で止まる。
LinearDragSample linearDragVacuumAt(
  LinearDragKind kind,
  LinearDragParams params,
  double t,
) {
  final launch = _launch(kind, params);
  final g = kLinearDragG;
  final time = math.max(0.0, t);
  final disc = launch.v0 * launch.v0 + 2 * g * launch.y0;
  final duration = (launch.v0 + math.sqrt(disc)) / g;
  if (time >= duration) {
    final v = launch.v0 - g * duration;
    return LinearDragSample(t: duration, y: 0, v: v, a: -g, landed: true);
  }
  return LinearDragSample(
    t: time,
    y: launch.y0 + launch.v0 * time - 0.5 * g * time * time,
    v: launch.v0 - g * time,
    a: -g,
    landed: false,
  );
}

List<LinearDragSample> linearDragStrobe(
  LinearDragKind kind,
  LinearDragParams params,
  double t, {
  double dt = kLinearDragStrobeDt,
}) {
  if (t <= 1e-9 || dt <= 0) return const [];
  final duration = linearDragFlightDuration(kind, params);
  final end = math.min(t, duration);
  final samples = <LinearDragSample>[];
  for (double ti = dt; ti < end - 1e-9; ti += dt) {
    samples.add(linearDragUnbounded(kind, params, ti));
  }
  return samples;
}

String linearDragCaption(LinearDragKind kind) {
  switch (kind) {
    case LinearDragKind.drop:
      return '静かに放す。抵抗は速さに比例し、速度と逆向き。\n'
          '終端速度に近づくほど、加速度は 0 に近づく。\n'
          '速さは終端速度を超えない。\n'
          '抵抗がないときは、同じ時刻でより下にいる。';
    case LinearDragKind.throwUp:
      return '上向きに投げる。上昇中は重力も抵抗も下向き。\n'
          '最高点では速度も抵抗も 0。重力は残る。\n'
          '戻ったときの速さは、投げたときより小さい。\n'
          '抵抗があると、最高点は低い。';
    case LinearDragKind.throwDown:
      return '下向きに投げる。初速が終端速度より大きいと、抵抗が重力より大きく速さが減る。\n'
          '終端速度より小さいと、重力のほうが大きく速さが増える。\n'
          'どちらも終端速度へ近づく。';
  }
}

final linearDrag1D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '速度比例の空気抵抗',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>速度に比例する抵抗を受けるとき、上向きを正にすると運動方程式は</p>
  <p>$$ma=-mg-bv$$</p>
  <p>$k=b/m$ と書くと</p>
  <p>$$a=-g-kv$$</p>
  <p>速さが増すと抵抗も増し、下向きの加速度は小さくなります。加速度が 0 になる速さが終端速度で、その大きさは</p>
  <p>$$v_t=\frac{g}{k}=\frac{mg}{b}$$</p>
  <p>初期高さ $y_0$、初速 $v_0$（上向き正）のとき</p>
  <p>$$v(t)=-v_t+(v_0+v_t)e^{-kt}$$</p>
  <p>$$y(t)=y_0-v_t t+\frac{v_0+v_t}{k}\left(1-e^{-kt}\right)$$</p>
  <p>静かに放すと $v_0=0$ で、速さは終端速度に近づきますが、有限の時間では到達しません。下向きに終端速度より速く投げると、抵抗が重力より大きく、速さは終端速度まで減ります。投げ上げで戻ったときの速さは、投げたときより小さくなります。</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: LinearDrag1DSimulation(),
      height: 920,
    ),
  ],
);

class LinearDrag1DSimulation extends PhysicsSimulation {
  LinearDrag1DSimulation()
      : super(
          title: '速度比例の空気抵抗',
          formula: const FormulaDisplay(
            r'\displaystyle a=-g-kv,\quad v_t=\frac{g}{k}',
          ),
          aspectRatio: 4 / 5,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> simTime = ValueNotifier(0.0);

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    final duration = linearDragFlightDuration(_kind, _params);
    final next = math.min(duration, simTime.value + dt * _playback);
    simTime.value = next;
    if (next >= duration - 1e-4) _loop.pause();
  });

  ValueNotifier<bool> get running => _loop.running;

  Map<String, double> _latestParams = {};
  LinearDragKind _kind = LinearDragKind.drop;

  static const double _playback = 0.40;

  static const List<LinearDragKind> kinds = [
    LinearDragKind.drop,
    LinearDragKind.throwUp,
    LinearDragKind.throwDown,
  ];

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'h': kLinearDragDefaultH,
        'v0': kLinearDragDefaultV0,
        'vt': kLinearDragDefaultVt,
      };

  LinearDragParams get _params {
    if (_latestParams.isEmpty) {
      return LinearDragParams.fromMap(initialParameters);
    }
    return LinearDragParams.fromMap(_latestParams);
  }

  void _rememberParams(Map<String, double> params) {
    _latestParams = Map<String, double>.from(params);
  }

  void start() {
    if (running.value) return;
    final duration = linearDragFlightDuration(_kind, _params);
    if (simTime.value >= duration - 1e-3) {
      simTime.value = 0.0;
    }
    _loop.start();
  }

  void pause() => _loop.pause();

  void resetMotion() {
    _loop.reset();
    simTime.value = 0.0;
  }

  void applyKind(LinearDragKind kind) {
    _kind = kind;
    resetMotion();
  }

  String _formulaTex() {
    switch (_kind) {
      case LinearDragKind.drop:
        return r'\displaystyle v=-v_t\left(1-e^{-kt}\right),\quad k=\frac{g}{v_t}';
      case LinearDragKind.throwUp:
        return r'\displaystyle v=-v_t+(v_0+v_t)e^{-kt}';
      case LinearDragKind.throwDown:
        return r'\displaystyle v=-v_t+(-v_0+v_t)e^{-kt}';
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
              linearDragCaption(_kind),
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
        );
      },
    );
  }

  String _kindLabel(LinearDragKind kind) {
    switch (kind) {
      case LinearDragKind.drop:
        return '落下';
      case LinearDragKind.throwUp:
        return '投げ上げ';
      case LinearDragKind.throwDown:
        return '投げ下げ';
    }
  }

  Widget _kindButton(
    String label,
    LinearDragKind kind,
    void Function(Set<String> ids) updateActiveIds,
  ) {
    final selected = _kind == kind;
    final onPressed = () {
      applyKind(kind);
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
    final duration = linearDragFlightDuration(_kind, p);
    final impact = linearDragAt(_kind, p, duration);
    final k = linearDragK(p.vt);
    final controls = <Widget>[
      const Text(
        '初期条件（g = 9.8 m/s²、上向き正）',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    ];
    if (_kind != LinearDragKind.throwUp) {
      controls.add(
        _DragSlider(
          label: 'h',
          value: p.h,
          min: kLinearDragMinH,
          max: kLinearDragMaxH,
          onChanged: (v) => updateParam('h', v),
          semanticLabel: '高さ h',
        ),
      );
    }
    if (_kind != LinearDragKind.drop) {
      controls.add(
        _DragSlider(
          label: 'v0',
          value: p.v0,
          min: kLinearDragMinV0,
          max: kLinearDragMaxV0,
          onChanged: (v) => updateParam('v0', v),
          semanticLabel: '初速度 v0',
        ),
      );
    }
    controls.add(
      _DragSlider(
        label: 'vt',
        value: p.vt,
        min: kLinearDragMinVt,
        max: kLinearDragMaxVt,
        onChanged: (v) => updateParam('vt', v),
        semanticLabel: '終端速度 vt',
      ),
    );
    final extra = _kind == LinearDragKind.throwUp
        ? '    最高 ${linearDragApexHeight(p).toStringAsFixed(2)} m'
        : '';
    controls.add(
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'k = ${k.toStringAsFixed(2)} /s    着地 ${duration.toStringAsFixed(2)} s'
          '    |v| = ${impact.v.abs().toStringAsFixed(2)} m/s$extra',
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
        final p = LinearDragParams.fromMap(parameters);
        final duration = linearDragFlightDuration(_kind, p);
        final t = math.min(simTime.value, duration);
        final sample = linearDragAt(_kind, p, t);
        final vacuum = linearDragVacuumAt(_kind, p, t);
        return CustomPaint(
          size: Size.infinite,
          painter: _LinearDragPainter(
            kind: _kind,
            params: p,
            sample: sample,
            vacuum: vacuum,
            strobes: linearDragStrobe(_kind, p, sample.t),
          ),
        );
      },
    );
  }
}

class _DragSlider extends StatelessWidget {
  const _DragSlider({
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

class _LinearDragPainter extends CustomPainter {
  _LinearDragPainter({
    required this.kind,
    required this.params,
    required this.sample,
    required this.vacuum,
    required this.strobes,
  });

  final LinearDragKind kind;
  final LinearDragParams params;
  final LinearDragSample sample;
  final LinearDragSample vacuum;
  final List<LinearDragSample> strobes;

  static const _bg = Color(0xFFF7FAFC);
  static const _ball = Color(0xFF1E88E5);
  static const _gravity = Color(0xFFEF6C00);
  static const _drag = Color(0xFF2E7D32);
  static const _trail = Color(0xFF78909C);
  static const _ghost = Color(0xFF90A4AE);
  static const _ground = Color(0xFF8D6E63);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final lines = _hudLines();
    final ledger = linearDragEnergy(kind, params, sample);
    final cardBottom = dynamicsReadoutCard(
      lines,
      ledger,
      textColumnWidth: 200,
      bounds: size,
    ).bottom;
    final map = _mapper(size, cardBottom + 16);
    _drawGround(canvas, size, map);
    _drawTrail(canvas, map);
    _drawGhost(canvas, map);
    _drawBall(canvas, map);
    paintDynamicsReadout(
      canvas,
      lines,
      ledger,
      textColumnWidth: 200,
      bounds: size,
    );
  }

  String _hudLines() {
    final nearTerminal = (sample.v + params.vt).abs() < 0.08 * params.vt;
    final note = sample.landed
        ? '着地'
        : nearTerminal
            ? '終端速度に近い'
            : '';
    return 't = ${sample.t.toStringAsFixed(2)} s\n'
        'y = ${sample.y.toStringAsFixed(2)} m\n'
        'v = ${sample.v.toStringAsFixed(2)} m/s\n'
        'a = ${sample.a.toStringAsFixed(2)} m/s²\n'
        'vt = ${params.vt.toStringAsFixed(2)} m/s'
        '${note.isEmpty ? '' : '\n$note'}';
  }

  _YMap _mapper(Size size, double marginTop) {
    final dragTop = kind == LinearDragKind.throwUp
        ? linearDragApexHeight(params)
        : params.h;
    final vacuumTop = kind == LinearDragKind.throwUp
        ? params.v0 * params.v0 / (2 * kLinearDragG)
        : params.h;
    const yMin = -0.15;
    final yMax = math.max(dragTop, vacuumTop) + 0.6;
    const marginBottom = 22.0;
    final s = (size.height - marginTop - marginBottom) / (yMax - yMin);
    return _YMap(
      x: size.width * 0.52,
      yOf: (y) => size.height - marginBottom - (y - yMin) * s,
      pxPerSpeed: 6,
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
    final pts = <Offset>[];
    for (final s in strobes) {
      pts.add(Offset(map.x, map.yOf(math.max(0, s.y))));
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

  void _drawGhost(Canvas canvas, _YMap map) {
    final y = math.max(0.0, vacuum.y);
    final c = Offset(map.x - 36, map.yOf(y));
    canvas.drawCircle(c, 8, Paint()..color = _ghost.withValues(alpha: 0.85));
    _label(canvas, c + const Offset(0, -18), '抵抗なし', _ghost);
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
      48,
      _gravity,
      '重力',
      labelSide: -1,
    );

    final dragRatio = (sample.v.abs() / params.vt).clamp(0.0, 1.8);
    if (dragRatio > 0.08) {
      final rising = sample.v >= 0;
      final dir = rising ? const Offset(0, 1) : const Offset(0, -1);
      _drawArrow(
        canvas,
        c + Offset(rising ? -42 : -18, 0),
        dir,
        (48 * dragRatio).clamp(12.0, 86.0),
        _drag,
        '抵抗',
        labelSide: -1,
      );
    } else {
      _label(canvas, c + const Offset(-58, -8), '抵抗 ≈ 0', _drag);
    }

    if (sample.v.abs() < 0.35) {
      _label(canvas, c + const Offset(34, -8), 'v ≈ 0', _ball);
    } else {
      final dir = sample.v >= 0 ? const Offset(0, -1) : const Offset(0, 1);
      final len = (sample.v.abs() * map.pxPerSpeed).clamp(12.0, 90.0);
      _drawArrow(
        canvas,
        c + const Offset(20, 0),
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
    _label(canvas, tip + n * (14.0 * labelSide), label, color);
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
  bool shouldRepaint(covariant _LinearDragPainter oldDelegate) {
    return oldDelegate.sample.t != sample.t ||
        oldDelegate.sample.y != sample.y ||
        oldDelegate.sample.v != sample.v ||
        oldDelegate.kind != kind ||
        oldDelegate.params.h != params.h ||
        oldDelegate.params.v0 != params.v0 ||
        oldDelegate.params.vt != params.vt;
  }
}

class _YMap {
  const _YMap({required this.x, required this.yOf, required this.pxPerSpeed});

  final double x;
  final double Function(double y) yOf;
  final double pxPerSpeed;
}
