import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/energy_gauge.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// 斜面下向き正。傾角 $\theta$ は水平から。$g=9.8\,\mathrm{m/s^2}$。再生だけ遅くしている。
const double kInclineFrictionG = 9.8;
const double kInclineFrictionMinV0 = 0.0;
const double kInclineFrictionMaxV0 = 6.0;
const double kInclineFrictionDefaultV0 = 4.0;
const double kInclineFrictionMinMu = 0.0;
const double kInclineFrictionMaxMu = 1.0;
const double kInclineFrictionDefaultMu = 0.40;
const double kInclineFrictionMuGap = 0.15;
const double kInclineFrictionMinMuS = 0.15;
const double kInclineFrictionMaxMuS = 1.15;
const double kInclineFrictionDefaultMuS = 0.55;
const double kInclineFrictionMinTheta = 0.0;
const double kInclineFrictionMaxTheta = 40.0;
const double kInclineFrictionDefaultTheta = 15.0;
const double kInclineFrictionStrobeDt = 0.10;

class KineticFrictionInclineParams {
  const KineticFrictionInclineParams({
    required this.v0,
    required this.mu,
    required this.muS,
    required this.thetaDeg,
  });

  final double v0;
  final double mu;
  final double muS;
  final double thetaDeg;

  double get theta => thetaDeg * math.pi / 180.0;

  factory KineticFrictionInclineParams.fromMap(Map<String, double> params) {
    var mu = params['mu']!.clamp(kInclineFrictionMinMu, kInclineFrictionMaxMu).toDouble();
    var muS = (params['muS'] ?? (mu + kInclineFrictionMuGap))
        .clamp(kInclineFrictionMinMuS, kInclineFrictionMaxMuS)
        .toDouble();
    if (muS < mu + kInclineFrictionMuGap) {
      if (mu + kInclineFrictionMuGap <= kInclineFrictionMaxMuS) {
        muS = mu + kInclineFrictionMuGap;
      } else {
        muS = kInclineFrictionMaxMuS;
        mu = muS - kInclineFrictionMuGap;
      }
    }
    return KineticFrictionInclineParams(
      v0: params['v0']!.clamp(kInclineFrictionMinV0, kInclineFrictionMaxV0).toDouble(),
      mu: mu,
      muS: muS,
      thetaDeg: params['theta']!
          .clamp(kInclineFrictionMinTheta, kInclineFrictionMaxTheta)
          .toDouble(),
    );
  }
}

/// 摩擦が大きいほど斜面の塗りを背景へ寄せて薄くする。
Color inclineFrictionSlopeColor(double mu, double muS) {
  final kinetic = (mu / kInclineFrictionMaxMu).clamp(0.0, 1.0);
  final stat = ((muS - kInclineFrictionMinMuS) /
          (kInclineFrictionMaxMuS - kInclineFrictionMinMuS))
      .clamp(0.0, 1.0);
  final t = (kinetic + stat) / 2;
  return Color.lerp(const Color(0xFF8E989F), const Color(0xFFF5F8FA), t)!;
}

class KineticFrictionInclineSample {
  const KineticFrictionInclineSample({
    required this.t,
    required this.s,
    required this.v,
    required this.a,
    required this.stopped,
  });

  final double t;
  final double s;
  final double v;
  final double a;
  final bool stopped;
}

/// 斜面下向きの加速度。滑っているとき $\displaystyle a=g(\sin\theta-\mu\cos\theta)$。
double kineticFrictionInclineAccel(KineticFrictionInclineParams params) {
  final th = params.theta;
  return kInclineFrictionG * (math.sin(th) - params.mu * math.cos(th));
}

/// 止まっている物体を静止摩擦が支えられるか。$\mu_s \ge \tan\theta$。
bool kineticFrictionInclineHolds(KineticFrictionInclineParams params) {
  final cosT = math.cos(params.theta);
  if (cosT.abs() < 1e-9) return params.muS >= 0;
  return params.muS + 1e-9 >= math.sin(params.theta) / cosT;
}

/// 初速 0 で、静止摩擦が滑り出しを止める。
bool kineticFrictionInclineStaysPut(KineticFrictionInclineParams params) {
  return params.v0 <= 1e-9 && kineticFrictionInclineHolds(params);
}

/// 減速して止まるとき、または初めから滑らないときは時刻。加速・等速は null。
double? kineticFrictionInclineStopTime(KineticFrictionInclineParams params) {
  if (kineticFrictionInclineStaysPut(params)) return 0;
  final a = kineticFrictionInclineAccel(params);
  if (a >= -1e-9) return null;
  if (params.v0 <= 1e-9) return 0;
  return params.v0 / -a;
}

/// 止まるときの斜面に沿った距離。止まらないときは null。
double? kineticFrictionInclineStopDistance(KineticFrictionInclineParams params) {
  final t = kineticFrictionInclineStopTime(params);
  if (t == null) return null;
  if (t <= 1e-12) return 0;
  final a = kineticFrictionInclineAccel(params);
  return params.v0 * t + 0.5 * a * t * t;
}

KineticFrictionInclineSample kineticFrictionInclineAt(
  KineticFrictionInclineParams params,
  double t,
) {
  final time = math.max(0.0, t);
  if (kineticFrictionInclineStaysPut(params)) {
    return const KineticFrictionInclineSample(
      t: 0,
      s: 0,
      v: 0,
      a: 0,
      stopped: true,
    );
  }
  final a = kineticFrictionInclineAccel(params);
  final v0 = params.v0;
  if (a < -1e-9) {
    final tStop = v0 <= 1e-9 ? 0.0 : v0 / -a;
    if (time >= tStop) {
      final sStop = v0 <= 1e-9 ? 0.0 : v0 * tStop + 0.5 * a * tStop * tStop;
      return KineticFrictionInclineSample(
        t: tStop,
        s: sStop,
        v: 0,
        a: 0,
        stopped: true,
      );
    }
  }
  return KineticFrictionInclineSample(
    t: time,
    s: v0 * time + 0.5 * a * time * time,
    v: v0 + a * time,
    a: a,
    stopped: false,
  );
}

List<KineticFrictionInclineSample> kineticFrictionInclineStrobe(
  KineticFrictionInclineParams params,
  double t, {
  double dt = kInclineFrictionStrobeDt,
}) {
  if (t <= 1e-9 || dt <= 0) return const [];
  var step = dt;
  if (t / step > 80) step = t / 80;
  final samples = <KineticFrictionInclineSample>[];
  for (double ti = step; ti < t - 1e-9; ti += step) {
    final s = kineticFrictionInclineAt(params, ti);
    if (s.stopped) break;
    samples.add(s);
  }
  return samples;
}

/// 質量 1 kg。止まるときは停止位置を位置エネルギーの基準にする。
EnergyLedger kineticFrictionInclineEnergy(
  KineticFrictionInclineParams params,
  KineticFrictionInclineSample sample,
) {
  const mass = 1.0;
  final sinT = math.sin(params.theta);
  final cosT = math.cos(params.theta);
  final kinetic = 0.5 * mass * sample.v * sample.v;
  final heat = mass * kInclineFrictionG * params.mu * cosT * math.max(0.0, sample.s);
  final stop = kineticFrictionInclineStopDistance(params);
  if (stop != null) {
    final potential = mass * kInclineFrictionG * (stop - sample.s) * sinT;
    final scale = 0.5 * mass * params.v0 * params.v0 +
        mass * kInclineFrictionG * stop * sinT;
    return EnergyLedger(
      kinetic: kinetic,
      potential: math.max(0.0, potential),
      dissipated: heat,
      scale: math.max(scale, 0.0),
      legendPotential: sinT > 1e-6,
      legendHeat: heat > 1e-6,
      potentialLabel: kLabelGravity,
    );
  }
  return EnergyLedger(
    kinetic: kinetic,
    potential: 0,
    dissipated: heat,
    scale: math.max(kinetic + heat, 0.0),
    legendPotential: false,
    legendHeat: heat > 1e-6,
  );
}

const String kKineticFrictionInclineCaption =
    '斜面下向きが正。滑っているあいだ加速度は g(sinθ − μ cosθ)。\n'
    '止まっているとき μs ≥ tanθ なら滑らない。';

final kineticFrictionIncline1D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '斜面上の動摩擦力',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>傾角 $\theta$ の斜面です。斜面下向きを正にします。垂直抗力は $N=mg\cos\theta$ です。</p>
  <p>止まっているとき、斜面下向きの分力は $mg\sin\theta$ です。静止摩擦係数を $\mu_s$ とすると、$\displaystyle \mu_s\ge\tan\theta$ のときは静止摩擦力がこの分力を打ち消し、滑り出しません。$\displaystyle \mu_s<\tan\theta$ なら静止摩擦では支えきれず、滑り出します。</p>
  <p>滑っているとき、動摩擦力の大きさは $\mu mg\cos\theta$ で上向きです。加速度は</p>
  <p>$$a=g(\sin\theta-\mu\cos\theta)$$</p>
  <p>動いているあいだ</p>
  <p>$$s=v_0 t+\frac{1}{2}at^{2},\quad v=v_0+at$$</p>
  <p>$\mu>\tan\theta$ なら減速して止まります。止まる時刻と距離は</p>
  <p>$$t=\frac{v_0}{g(\mu\cos\theta-\sin\theta)},\quad s=\frac{v_0^{2}}{2g(\mu\cos\theta-\sin\theta)}$$</p>
  <p>止まったあとは速度 0 のままです。戻ることはありません。このとき $\displaystyle \mu_s\ge\mu+0.15$ なので、$\mu>\tan\theta$ なら止まったあと滑り出すこともありません。$\mu<\tan\theta$ なら加速し続け、$\mu=\tan\theta$ なら等速です。$\theta=0$ では水平面の $a=-\mu g$ に戻ります。</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: KineticFrictionIncline1DSimulation(),
      height: 880,
    ),
  ],
);

class KineticFrictionIncline1DSimulation extends PhysicsSimulation {
  KineticFrictionIncline1DSimulation()
      : super(
          title: '斜面上の動摩擦力',
          formula: const FormulaDisplay(
            r'\displaystyle a=g(\sin\theta-\mu\cos\theta),\quad \mu_s\ge\tan\theta\text{ なら滑らない}',
          ),
          aspectRatio: (16 / 9) / 1.5,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> simTime = ValueNotifier(0.0);

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    final stop = kineticFrictionInclineStopTime(_params);
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
        'v0': kInclineFrictionDefaultV0,
        'mu': kInclineFrictionDefaultMu,
        'muS': kInclineFrictionDefaultMuS,
        'theta': kInclineFrictionDefaultTheta,
      };

  KineticFrictionInclineParams get _params {
    if (_latestParams.isEmpty) {
      return KineticFrictionInclineParams.fromMap(initialParameters);
    }
    return KineticFrictionInclineParams.fromMap(_latestParams);
  }

  void _rememberParams(Map<String, double> params) {
    _latestParams = Map<String, double>.from(params);
  }

  void start() {
    if (running.value) return;
    final stop = kineticFrictionInclineStopTime(_params);
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

  @override
  Widget? buildFormulaOverlay(Map<String, double> parameters) {
    _rememberParams(parameters);
    return const FormulaDisplay(
      r'\displaystyle a=g(\sin\theta-\mu\cos\theta),\quad \mu_s\ge\tan\theta\text{ なら滑らない}',
    );
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
              kKineticFrictionInclineCaption,
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
    final a = kineticFrictionInclineAccel(p);
    final tanTheta = math.tan(p.theta);
    final stopT = kineticFrictionInclineStopTime(p);
    final stopS = kineticFrictionInclineStopDistance(p);
    final String summary;
    if (kineticFrictionInclineStaysPut(p)) {
      summary = '滑らない（μs ≥ tanθ = ${tanTheta.toStringAsFixed(2)}）';
    } else if (stopT == null) {
      summary = a.abs() < 1e-3
          ? '等速（μ = tanθ = ${tanTheta.toStringAsFixed(2)}）'
          : '加速する（止まらない）  tanθ = ${tanTheta.toStringAsFixed(2)}';
    } else if (stopT <= 1e-9) {
      summary = '初めから静止  tanθ = ${tanTheta.toStringAsFixed(2)}';
    } else {
      summary =
          '停止まで ${stopT.toStringAsFixed(2)} s    距離 ${stopS!.toStringAsFixed(2)} m    tanθ = ${tanTheta.toStringAsFixed(2)}';
    }
    return [
      const Text(
        '初期条件（g = 9.8 m/s²、斜面下向き正）',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _InclineSlider(
        label: 'θ',
        value: p.thetaDeg,
        min: kInclineFrictionMinTheta,
        max: kInclineFrictionMaxTheta,
        digits: 0,
        suffix: '°',
        onChanged: (v) => updateParam('theta', v),
        semanticLabel: '傾角 θ',
      ),
      _InclineSlider(
        label: 'μ',
        value: p.mu,
        min: kInclineFrictionMinMu,
        max: kInclineFrictionMaxMu,
        onChanged: (v) {
          updateParam('mu', v);
          final need = v + kInclineFrictionMuGap;
          if (p.muS < need) updateParam('muS', need);
        },
        semanticLabel: '動摩擦係数 μ',
      ),
      _InclineSlider(
        label: 'μs',
        value: p.muS,
        min: kInclineFrictionMinMuS,
        max: kInclineFrictionMaxMuS,
        onChanged: (v) {
          updateParam('muS', v);
          final maxKinetic = v - kInclineFrictionMuGap;
          if (p.mu > maxKinetic) updateParam('mu', maxKinetic);
        },
        semanticLabel: '静止摩擦係数 μs',
      ),
      _InclineSlider(
        label: 'v0',
        value: p.v0,
        min: kInclineFrictionMinV0,
        max: kInclineFrictionMaxV0,
        onChanged: (v) => updateParam('v0', v),
        semanticLabel: '初速度 v0',
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
        final p = KineticFrictionInclineParams.fromMap(parameters);
        final sample = kineticFrictionInclineAt(p, simTime.value);
        return CustomPaint(
          size: Size.infinite,
          painter: _InclineFrictionPainter(
            params: p,
            sample: sample,
            strobes: kineticFrictionInclineStrobe(p, sample.t),
          ),
        );
      },
    );
  }
}

class _InclineSlider extends StatelessWidget {
  const _InclineSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.semanticLabel,
    this.digits = 2,
    this.suffix = '',
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String semanticLabel;
  final int digits;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final shown = '${value.toStringAsFixed(digits)}$suffix';
    return Row(
      children: [
        SizedBox(
          width: 32,
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
                  '$semanticLabel ${v.toStringAsFixed(digits)}$suffix',
            ),
          ),
        ),
        SizedBox(
          width: 52,
          child: Text(
            shown,
            style: const TextStyle(fontSize: 12, fontFamily: 'Courier'),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _InclineFrictionPainter extends CustomPainter {
  _InclineFrictionPainter({
    required this.params,
    required this.sample,
    required this.strobes,
  });

  final KineticFrictionInclineParams params;
  final KineticFrictionInclineSample sample;
  final List<KineticFrictionInclineSample> strobes;

  static const _bg = Color(0xFFF7FAFC);
  static const _block = Color(0xFF1E88E5);
  static const _force = Color(0xFFEF6C00);
  static const _velocity = Color(0xFF1565C0);
  static const _normal = Color(0xFF2E7D32);
  static const _gravity = Color(0xFF546E7A);
  static const _trail = Color(0xFF78909C);
  static const _ink = Color(0xFF37474F);
  static const _slopeEdge = Color(0xFF78909C);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final lines = _hudLines();
    final card = dynamicsReadoutCard(
      lines,
      kineticFrictionInclineEnergy(params, sample),
      textColumnWidth: 230,
      bounds: size,
    );
    final ceiling = card.bottom;
    final map = _mapper(size, ceiling, card.height * 0.5);
    _drawRail(canvas, map);
    _drawAngle(canvas, map);
    _drawStopMark(canvas, map);
    _drawTrail(canvas, map);
    _drawBlock(canvas, map);
    _drawHud(canvas, lines);
  }

  _SMap _mapper(Size size, double ceiling, double extra) {
    final stop = kineticFrictionInclineStopDistance(params);
    late final double sMin;
    late final double sMax;
    if (stop != null && stop > 0.05) {
      sMin = -math.max(1.8, 0.30 * stop);
      sMax = stop + math.max(0.85, 0.12 * stop);
    } else if (stop != null) {
      sMin = -1.7;
      sMax = 2.6;
    } else {
      const window = 5.0;
      if (sample.s < window * 0.65) {
        sMin = -1.8;
        sMax = window;
      } else {
        sMax = sample.s + window * 0.28;
        sMin = sMax - window;
      }
    }
    final span = math.max(sMax - sMin, 0.2);
    final th = params.theta;
    final down = Offset(math.cos(th), math.sin(th));
    final normal = Offset(math.sin(th), -math.cos(th));
    final top = ceiling + 40 + extra;
    final bottom = math.max(top + 56, size.height - 16);
    final pad = Rect.fromLTRB(24, top, size.width - 20, bottom);
    final cosT = math.cos(th);
    final sinT = math.sin(th);
    final maxScaleX = cosT < 1e-4 ? 400.0 : pad.width / (span * cosT);
    final maxScaleY = sinT < 1e-4 ? 400.0 : pad.height / (span * sinT);
    final scale = math.min(math.min(maxScaleX, maxScaleY), 240.0);
    final seg = down * (span * scale);
    final start = Offset(
      pad.center.dx - seg.dx / 2,
      pad.center.dy - seg.dy / 2,
    );
    return _SMap(
      at: (s) => start + down * ((s - sMin) * scale),
      sMin: sMin,
      sMax: sMax,
      down: down,
      normal: normal,
      theta: th,
      ceiling: ceiling,
    );
  }

  /// 斜面の実体。図の斜線くさびと同じく、斜辺の下だけ。
  void _drawWedge(Canvas canvas, Offset a, Offset b) {
    final high = a.dy <= b.dy ? a : b;
    final low = a.dy <= b.dy ? b : a;
    if (low.dy - high.dy < 2) return;
    final foot = Offset(high.dx, low.dy);
    final path = Path()
      ..moveTo(high.dx, high.dy)
      ..lineTo(low.dx, low.dy)
      ..lineTo(foot.dx, foot.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = inclineFrictionSlopeColor(params.mu, params.muS),
    );
    final edge = Paint()
      ..color = _slopeEdge
      ..strokeWidth = 1.6;
    canvas.drawLine(high, foot, edge);
    canvas.drawLine(foot, low, edge);
  }

  void _drawRail(Canvas canvas, _SMap map) {
    final a = map.at(map.sMin);
    final b = map.at(map.sMax);
    _drawWedge(canvas, a, b);
    canvas.drawLine(
      a,
      b,
      Paint()
        ..color = _slopeEdge
        ..strokeWidth = 3,
    );
    final span = map.sMax - map.sMin;
    final step = span > 8
        ? 2.0
        : span > 3
            ? 1.0
            : span > 1
                ? 0.5
                : 0.2;
    final into = -map.normal;
    final first = (map.sMin / step).ceil() * step;
    for (var s = first; s <= map.sMax + 1e-9; s += step) {
      final p = map.at(s);
      canvas.drawLine(
        p,
        p + into * 8,
        Paint()
          ..color = _slopeEdge
          ..strokeWidth = 1.4,
      );
      if ((s / step).round().isEven || step >= 0.5) {
        _label(canvas, p + into * 18, s.toStringAsFixed(step < 0.5 ? 1 : 0), _ink);
      }
    }
  }

  void _drawAngle(Canvas canvas, _SMap map) {
    if (params.thetaDeg < 1) return;
    final origin = map.at(map.sMin + (map.sMax - map.sMin) * 0.08);
    const radius = 36.0;
    canvas.drawLine(
      origin,
      origin + const Offset(radius + 8, 0),
      Paint()
        ..color = _ink
        ..strokeWidth = 1.2,
    );
    final rect = Rect.fromCircle(center: origin, radius: radius);
    canvas.drawArc(
      rect,
      0,
      params.theta,
      false,
      Paint()
        ..color = _force
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    final mid = params.theta / 2;
    final labelAt = origin + Offset(math.cos(mid), math.sin(mid)) * (radius + 14);
    _label(canvas, labelAt, 'θ', _force);
  }

  void _drawStopMark(Canvas canvas, _SMap map) {
    final stop = kineticFrictionInclineStopDistance(params);
    if (stop == null || stop < 1e-6) return;
    final p = map.at(stop);
    final up = -map.normal.dy;
    final room = math.max(0.0, p.dy - map.ceiling - 14);
    final maxLen = up < 0.15 ? 78.0 : math.min(78.0, room / up);
    if (maxLen < 12) return;
    final paint = Paint()
      ..color = _force
      ..strokeWidth = 1.4;
    var d = 6.0;
    while (d < maxLen) {
      canvas.drawLine(
        p + map.normal * d,
        p + map.normal * math.min(d + 6, maxLen),
        paint,
      );
      d += 10;
    }
    _label(canvas, p + map.normal * (maxLen + 12), '停止', _force);
  }

  void _drawTrail(Canvas canvas, _SMap map) {
    final pts = <Offset>[];
    for (final s in strobes) {
      if (s.s < map.sMin || s.s > map.sMax) continue;
      pts.add(map.at(s.s) + map.normal * 16);
    }
    final paint = Paint()
      ..color = _trail
      ..strokeWidth = 1.6;
    for (var i = 0; i < pts.length - 1; i++) {
      final delta = pts[i + 1] - pts[i];
      final len = delta.distance;
      if (len < 1) continue;
      final dir = delta / len;
      var d = 0.0;
      while (d < len) {
        final end = math.min(d + 5, len);
        canvas.drawLine(pts[i] + dir * d, pts[i] + dir * end, paint);
        d += 9;
      }
    }
    for (final p in pts) {
      canvas.drawCircle(p, 3.2, Paint()..color = _trail);
    }
  }

  void _drawBlock(Canvas canvas, _SMap map) {
    final contact = map.at(sample.s);
    canvas.save();
    canvas.translate(contact.dx, contact.dy);
    canvas.rotate(map.theta);
    final rect = RRect.fromRectAndRadius(
      const Rect.fromLTRB(-23, -32, 23, 0),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect.shift(const Offset(1.5, 2)), Paint()..color = Colors.black12);
    canvas.drawRRect(rect, Paint()..color = _block);
    canvas.restore();

    final center = contact + map.normal * 16;
    final gLen = 36.0;
    _drawArrow(canvas, center, const Offset(0, 1), gLen, _gravity, 'mg');
    final nLen = (18 + math.cos(params.theta) * 28).clamp(16.0, 52.0);
    _drawArrow(canvas, center, map.normal, nLen, _normal, 'N');

    final speed = sample.v.abs();
    if (speed <= 0.05) {
      _label(canvas, center + map.normal * 28, 'v = 0', _velocity);
    } else {
      final vLen = (speed / kInclineFrictionMaxV0 * 72).clamp(14.0, 84.0);
      _drawArrow(canvas, center, map.down, vLen, _velocity, 'v');
    }

    if (!sample.stopped && params.mu > 1e-12 && speed > 0.05) {
      final fLen = (16 + params.mu * math.cos(params.theta) * 52).clamp(16.0, 74.0);
      _drawArrow(canvas, center, -map.down, fLen, _force, '摩擦');
    } else if (sample.stopped && math.sin(params.theta) > 0.02) {
      final hold = math.sin(params.theta);
      final fLen = (16 + hold * 40).clamp(16.0, 60.0);
      _drawArrow(canvas, center, -map.down, fLen, _force, '静止');
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
    if (dir.distance < 1e-6 || length < 1) return;
    final u = dir / dir.distance;
    final tip = origin + u * length;
    const headLen = 10.0;
    const headHalf = 5.0;
    final shaftEnd = tip - u * (headLen * 0.75);
    final n = Offset(-u.dy, u.dx);
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
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    final head = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo((tip - u * headLen + n * headHalf).dx, (tip - u * headLen + n * headHalf).dy)
      ..lineTo((tip - u * headLen - n * headHalf).dx, (tip - u * headLen - n * headHalf).dy)
      ..close();
    canvas.drawPath(head, Paint()..color = color);
    _label(canvas, tip + n * 12, label, color);
  }

  String _hudLines() {
    final stopT = kineticFrictionInclineStopTime(params);
    final stopS = kineticFrictionInclineStopDistance(params);
    final String tail;
    if (kineticFrictionInclineStaysPut(params)) {
      tail = '滑らない';
    } else if (stopT == null) {
      tail = sample.a.abs() < 1e-3 ? '等速' : '止まらない';
    } else if (stopT <= 1e-9) {
      tail = '静止';
    } else {
      tail = '停止 ${stopT.toStringAsFixed(2)} s, ${stopS!.toStringAsFixed(2)} m';
    }
    return 'θ = ${params.thetaDeg.toStringAsFixed(0)}°\n'
        'μ = ${params.mu.toStringAsFixed(2)}    μs = ${params.muS.toStringAsFixed(2)}\n'
        't = ${sample.t.toStringAsFixed(2)} s\n'
        's = ${sample.s.toStringAsFixed(2)} m\n'
        'v = ${sample.v.toStringAsFixed(2)} m/s\n'
        'a = ${sample.a.toStringAsFixed(2)} m/s²\n'
        '$tail';
  }

  void _drawHud(Canvas canvas, String lines) {
    paintDynamicsReadout(
      canvas,
      lines,
      kineticFrictionInclineEnergy(params, sample),
      textColumnWidth: 230,
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
    tp.paint(canvas, Offset(o.dx - tp.width / 2, o.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _InclineFrictionPainter oldDelegate) {
    return oldDelegate.sample.t != sample.t ||
        oldDelegate.sample.s != sample.s ||
        oldDelegate.sample.v != sample.v ||
        oldDelegate.params.v0 != params.v0 ||
        oldDelegate.params.mu != params.mu ||
        oldDelegate.params.muS != params.muS ||
        oldDelegate.params.thetaDeg != params.thetaDeg;
  }
}

class _SMap {
  const _SMap({
    required this.at,
    required this.sMin,
    required this.sMax,
    required this.down,
    required this.normal,
    required this.theta,
    required this.ceiling,
  });

  final Offset Function(double s) at;
  final double sMin;
  final double sMax;
  final Offset down;
  final Offset normal;
  final double theta;
  final double ceiling;
}
