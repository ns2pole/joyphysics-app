import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/energy_gauge.dart';
import 'package:joyphysics/experiment/dynamics/animations/springOscillator1D.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// 粗い水平面。$g=9.8\,\mathrm{m/s^2}$。右が正。
const double kRoughSpringG = 9.8;
const double kRoughSpringMinMu = 0.0;
const double kRoughSpringMaxMu = 0.80;
const double kRoughSpringDefaultMuK = 0.15;
const double kRoughSpringDefaultMuS = 0.30;

/// 静かに放す初期位置。半周期ごとに振幅は $2\delta'$ 減る。
/// 既定の $\mu',\mu,m,k$ では、3往復（6半周期）目の端で $|x|\le\delta$ に入る。
const double kRoughSpringDefaultX0 = 0.24;

class RoughHorizontalSpringParams {
  const RoughHorizontalSpringParams({
    required this.m,
    required this.k,
    required this.muK,
    required this.muS,
    this.x0 = kRoughSpringDefaultX0,
    this.v0 = kSpringDefaultV0,
  });

  final double m;
  final double k;

  /// 動摩擦係数。
  final double muK;

  /// 静止摩擦係数。動摩擦以上。
  final double muS;

  /// つりあい（自然長）からの初期位置。右向き正。
  final double x0;

  /// 右向き正。
  final double v0;

  double get omega => springOmega(m, k);

  /// 動摩擦力がずらす中心。$\displaystyle \delta'=\frac{\mu' mg}{k}$。
  double get deltaK => muK * m * kRoughSpringG / k;

  /// 静止摩擦で止まれる半幅。$\displaystyle \delta=\frac{\mu mg}{k}$。
  double get deltaS => muS * m * kRoughSpringG / k;

  double get kineticFriction => muK * m * kRoughSpringG;

  double get maxStaticFriction => muS * m * kRoughSpringG;

  factory RoughHorizontalSpringParams.fromMap(Map<String, double> params) {
    final muK = (params['muK'] ?? kRoughSpringDefaultMuK)
        .clamp(kRoughSpringMinMu, kRoughSpringMaxMu)
        .toDouble();
    final muS = (params['muS'] ?? kRoughSpringDefaultMuS)
        .clamp(kRoughSpringMinMu, kRoughSpringMaxMu)
        .toDouble();
    return RoughHorizontalSpringParams(
      m: (params['m'] ?? kSpringDefaultM).clamp(kSpringMinM, kSpringMaxM).toDouble(),
      k: (params['k'] ?? kSpringDefaultK).clamp(kSpringMinK, kSpringMaxK).toDouble(),
      muK: muK,
      muS: math.max(muS, muK),
      x0: (params['x0'] ?? kRoughSpringDefaultX0)
          .clamp(kHorizontalSpringMinX0, kHorizontalSpringMaxX0)
          .toDouble(),
      v0: (params['v0'] ?? kSpringDefaultV0)
          .clamp(kSpringMinV0, kSpringMaxV0)
          .toDouble(),
    );
  }
}

class RoughHorizontalSpringSample {
  const RoughHorizontalSpringSample({
    required this.t,
    required this.x,
    required this.v,
    required this.a,
    required this.friction,
    required this.stuck,
  });

  final double t;

  /// つりあいからの変位。右向き正。
  final double x;
  final double v;
  final double a;

  /// 摩擦力。右向き正。静止中はばねを打ち消す。
  final double friction;
  final bool stuck;

  double get position => kHorizontalSpringEll + x;
}

double _mechanical(double m, double v, double k, double x) =>
    0.5 * m * v * v + 0.5 * k * x * x;

EnergyLedger roughHorizontalSpringEnergy(
  RoughHorizontalSpringParams params,
  RoughHorizontalSpringSample sample,
) {
  final scale = _mechanical(params.m, params.v0, params.k, params.x0);
  final kinetic = 0.5 * params.m * sample.v * sample.v;
  final potential = 0.5 * params.k * sample.x * sample.x;
  final heat = math.max(0.0, scale - kinetic - potential);
  return EnergyLedger(
    kinetic: kinetic,
    potential: potential,
    dissipated: heat,
    scale: scale,
    legendHeat: heat > 1e-6,
    potentialLabel: kLabelElastic,
  );
}

class _RoughSpringCache {
  _RoughSpringCache.start(this.params)
      : t = 0,
        x = params.x0,
        v = params.v0,
        stuck = false {
    if (v.abs() <= 1e-10 && x.abs() <= params.deltaS + 1e-9) {
      v = 0;
      stuck = true;
    }
  }

  final RoughHorizontalSpringParams params;
  double t;
  double x;
  double v;
  bool stuck;

  bool matches(RoughHorizontalSpringParams other) {
    return other.m == params.m &&
        other.k == params.k &&
        other.muK == params.muK &&
        other.muS == params.muS &&
        other.x0 == params.x0 &&
        other.v0 == params.v0;
  }
}

_RoughSpringCache? _roughCache;

/// 動いているあいだは、中心を $\mp\delta'$ にずらした単振動。
/// 速度が 0 になったとき $|x|\le\delta$ なら静止摩擦で止まる。
void _advanceRoughSpring(_RoughSpringCache cache, double target) {
  final params = cache.params;
  final w = params.omega;
  final dk = params.deltaK;
  final ds = params.deltaS;
  var guard = 0;
  while (cache.t < target - 1e-14 && !cache.stuck && guard < 800) {
    guard++;
    final moving = cache.v.abs() > 1e-9;
    if (!moving && cache.x.abs() <= math.max(ds, dk) + 1e-9) {
      cache.v = 0;
      cache.stuck = true;
      cache.t = target;
      return;
    }
    final signV = moving ? cache.v.sign : -cache.x.sign;
    final center = -signV * dk;
    final c = cache.x - center;
    final v = moving ? cache.v : 0.0;
    final phi = math.atan2(-c * w, v);
    var theta = phi + math.pi / 2;
    if (theta <= 1e-9) {
      theta += math.pi;
    }
    while (theta > math.pi + 1e-9) {
      theta -= math.pi;
    }
    if (theta < 1e-8) theta = math.pi;
    final tau = theta / w;
    final step = math.min(tau, target - cache.t);
    final th = w * step;
    final nx = center + c * math.cos(th) + (v / w) * math.sin(th);
    final nv = -c * w * math.sin(th) + v * math.cos(th);
    cache.t += step;
    cache.x = nx;
    final hitTurn = step >= tau - 1e-10;
    cache.v = hitTurn ? 0.0 : nv;
    if (hitTurn && cache.x.abs() <= ds + 1e-8) {
      cache.v = 0;
      cache.stuck = true;
      cache.t = target;
      return;
    }
  }
}

RoughHorizontalSpringSample _sampleOf(
  RoughHorizontalSpringParams params,
  _RoughSpringCache cache,
  double time,
) {
  if (cache.stuck) {
    return RoughHorizontalSpringSample(
      t: time,
      x: cache.x,
      v: 0,
      a: 0,
      friction: params.k * cache.x,
      stuck: true,
    );
  }
  final released = cache.v.abs() <= 1e-9;
  final signV = released ? -cache.x.sign : cache.v.sign;
  final friction = -params.kineticFriction * signV;
  return RoughHorizontalSpringSample(
    t: time,
    x: cache.x,
    v: cache.v,
    a: (-params.k * cache.x + friction) / params.m,
    friction: friction,
    stuck: false,
  );
}

RoughHorizontalSpringSample roughHorizontalSpringAt(
  RoughHorizontalSpringParams params,
  double t,
) {
  final time = math.max(0.0, t);
  var cache = _roughCache;
  if (cache == null || !cache.matches(params) || cache.t > time + 1e-12) {
    cache = _RoughSpringCache.start(params);
    _roughCache = cache;
  }
  if (!cache.stuck && cache.t < time - 1e-15) {
    _advanceRoughSpring(cache, time);
  }
  return _sampleOf(params, cache, time);
}

const String kRoughHorizontalSpringCaption =
    '初期位置はつりあい（自然長）から。右が正、左が負。初速度も右が正。\n'
    '動いているあいだは動摩擦力 μ′mg が速度と逆向き。\n'
    '速度が 0 で、ばねの力の大きさが静止摩擦力 μmg 以下なら、そこで止まる。\n'
    '床の色が付いた範囲が、止まれる位置。静止摩擦係数は動摩擦以上。';

final roughHorizontalSpring1D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '水平バネ（粗い床）',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>粗い水平面では、垂直抗力は $N=mg$ です。動いているあいだ、右向きを正にすると</p>
  <p>$$\displaystyle m\ddot x=-kx-\mu' mg\,\mathrm{sgn}(v)$$</p>
  <p>動摩擦力は速度と逆向きで、大きさは $\mu' mg$ です。この運動は、つりあいを $\displaystyle \delta'=\frac{\mu' mg}{k}$ だけずらした単振動です。半周期ごとに、振れ幅は $2\delta'$ ずつ減ります。</p>
  <p>速度が 0 になったとき、ばねの力 $kx$ の大きさが静止摩擦力 $\mu mg$ 以下なら、そこで止まります。</p>
  <p>$$\displaystyle |x|\le \frac{\mu mg}{k}$$</p>
  <p>静止摩擦は速度が 0 のときだけ働き、仕事をしません。減った力学的エネルギーは熱になります。</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: RoughHorizontalSpring1DSimulation(),
      height: 1120,
    ),
  ],
);

class RoughHorizontalSpring1DSimulation extends PhysicsSimulation {
  RoughHorizontalSpring1DSimulation()
      : super(
          title: '水平バネ（粗い床）',
          formula: const FormulaDisplay(
            r"\displaystyle m\ddot x=-kx-\mu' mg\,\mathrm{sgn}(v)",
          ),
          aspectRatio: 16 / 10,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> simTime = ValueNotifier(0.0);

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    final next = simTime.value + dt * _playback;
    simTime.value = next;
    final sample = roughHorizontalSpringAt(_params, next);
    if (sample.stuck) _loop.pause();
  });

  ValueNotifier<bool> get running => _loop.running;

  Map<String, double> _latestParams = {};

  static const double _playback = 0.50;

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'm': kSpringDefaultM,
        'k': kSpringDefaultK,
        'muK': kRoughSpringDefaultMuK,
        'muS': kRoughSpringDefaultMuS,
        'x0': kRoughSpringDefaultX0,
        'v0': kSpringDefaultV0,
      };

  RoughHorizontalSpringParams get _params {
    if (_latestParams.isEmpty) {
      return RoughHorizontalSpringParams.fromMap(initialParameters);
    }
    return RoughHorizontalSpringParams.fromMap(_latestParams);
  }

  void _rememberParams(Map<String, double> params) {
    _latestParams = Map<String, double>.from(params);
  }

  void start() {
    if (running.value) return;
    final sample = roughHorizontalSpringAt(_params, simTime.value);
    if (sample.stuck && simTime.value > 1e-3) {
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
      r"\displaystyle m\ddot x=-kx-\mu' mg\,\mathrm{sgn}(v)",
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
              kRoughHorizontalSpringCaption,
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
    return [
      const Text(
        '質量・ばね・摩擦・初期位置・初速度（右が正）',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _RoughSlider(
        label: 'm',
        value: p.m,
        min: kSpringMinM,
        max: kSpringMaxM,
        onChanged: (v) => updateParam('m', v),
        semanticLabel: '質量 m',
      ),
      _RoughSlider(
        label: 'k',
        value: p.k,
        min: kSpringMinK,
        max: kSpringMaxK,
        onChanged: (v) => updateParam('k', v),
        semanticLabel: 'ばね定数 k',
      ),
      _RoughSlider(
        label: 'μ′',
        value: p.muK,
        min: kRoughSpringMinMu,
        max: kRoughSpringMaxMu,
        onChanged: (v) {
          updateParam('muK', v);
          if (p.muS < v) updateParam('muS', v);
        },
        semanticLabel: '動摩擦係数',
      ),
      _RoughSlider(
        label: 'μ',
        value: p.muS,
        min: kRoughSpringMinMu,
        max: kRoughSpringMaxMu,
        onChanged: (v) {
          updateParam('muS', v);
          if (v < p.muK) updateParam('muK', v);
        },
        semanticLabel: '静止摩擦係数',
      ),
      _RoughSlider(
        label: 'x0',
        value: p.x0,
        min: kHorizontalSpringMinX0,
        max: kHorizontalSpringMaxX0,
        onChanged: (v) => updateParam('x0', v),
        semanticLabel: '初期位置 右が正',
        readout: springVelocityReadout(p.x0, downwardPositive: false),
      ),
      _RoughSlider(
        label: 'v0',
        value: p.v0,
        min: kSpringMinV0,
        max: kSpringMaxV0,
        onChanged: (v) => updateParam('v0', v),
        semanticLabel: '初速度 右が正',
        readout: springVelocityReadout(p.v0, downwardPositive: false),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'μ′mg = ${p.kineticFriction.toStringAsFixed(2)} N    '
          'μmg = ${p.maxStaticFriction.toStringAsFixed(2)} N',
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
        final p = RoughHorizontalSpringParams.fromMap(parameters);
        final sample = roughHorizontalSpringAt(p, simTime.value);
        return CustomPaint(
          size: Size.infinite,
          painter: _RoughHorizontalSpringPainter(
            params: p,
            sample: sample,
            running: running.value,
          ),
        );
      },
    );
  }
}

class _RoughSlider extends StatelessWidget {
  const _RoughSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.semanticLabel,
    this.readout,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String semanticLabel;
  final String? readout;

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
          width: readout == null ? 44 : 72,
          child: Text(
            readout ?? value.toStringAsFixed(2),
            style: const TextStyle(fontSize: 12, fontFamily: 'Courier'),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _RoughHorizontalSpringPainter extends CustomPainter {
  _RoughHorizontalSpringPainter({
    required this.params,
    required this.sample,
    required this.running,
  });

  final RoughHorizontalSpringParams params;
  final RoughHorizontalSpringSample sample;
  final bool running;

  static const _bg = Color(0xFFF7FAFC);
  static const _ball = Color(0xFF1E88E5);
  static const _force = Color(0xFFEF6C00);
  static const _friction = Color(0xFF6D4C41);
  static const _velocity = Color(0xFF1565C0);
  static const _stick = Color(0xFFFFE0B2);
  static const _worldMax = 0.95;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final state = sample.stuck ? '静止' : '運動中';
    final hud = 't = ${sample.t.toStringAsFixed(2)} s\n'
        'x = ${sample.x.toStringAsFixed(3)} m\n'
        'v = ${springVelocityReadout(sample.v, downwardPositive: false)} m/s\n'
        'f = ${sample.friction.toStringAsFixed(2)} N  $state';
    final ledger = roughHorizontalSpringEnergy(params, sample);
    final ceiling = dynamicsReadoutCard(
      hud,
      ledger,
      textColumnWidth: 210,
      bounds: size,
    ).bottom;
    final railY = math.max(size.height * 0.62, ceiling + 100);
    final left = 36.0;
    final right = size.width - 16;
    final amp = springMotionAmplitude(params.x0, params.v0, params.omega);
    final reach = math.max(amp, params.deltaS) + 0.06;
    final xMin = math.min(0.0, kHorizontalSpringEll - reach);
    final xMax = math.max(_worldMax, kHorizontalSpringEll + reach + 0.08);
    double sx(double x) => left + ((x - xMin) / (xMax - xMin)) * (right - left);
    final wallRight = sx(0);

    final axis = Paint()
      ..color = const Color(0xFF90A4AE)
      ..strokeWidth = 3;
    canvas.drawLine(Offset(left, railY), Offset(right, railY), axis);
    _hatch(canvas, left, right, railY);

    final ds = params.deltaS;
    if (ds > 1e-4) {
      final zone = Rect.fromLTRB(
        sx(kHorizontalSpringEll - ds),
        railY - 10,
        sx(kHorizontalSpringEll + ds),
        railY + 14,
      );
      canvas.drawRect(zone, Paint()..color = _stick);
      _label(
        canvas,
        '止まれる範囲',
        zone.center.dx,
        railY + 16,
        const Color(0xFFEF6C00),
        center: true,
      );
    }

    final wall = RRect.fromRectAndRadius(
      Rect.fromLTWH(wallRight - 22, railY - 46, 22, 92),
      const Radius.circular(3),
    );
    canvas.drawRRect(wall, Paint()..color = const Color(0xFF78909C));

    _dashedV(
      canvas,
      sx(kHorizontalSpringEll),
      railY - 78,
      railY + 8,
      const Color(0xFFEF6C00),
    );
    _label(
      canvas,
      'つりあい',
      sx(kHorizontalSpringEll),
      railY - 92,
      const Color(0xFFEF6C00),
      center: true,
    );

    final mass = Offset(sx(sample.position), railY);
    final r = springMassRadius(params.m);
    paintCoilSpring(canvas, Offset(wallRight, railY), mass - Offset(r, 0), params.k);
    _mass(canvas, mass, r, _ball, 'm');

    final vMax = math.max(amp * params.omega, 1e-6);
    final fMax = math.max(
      math.max(params.k * amp, params.maxStaticFriction),
      1e-6,
    );
    _arrow(canvas, mass + const Offset(0, -46), sample.v / vMax * 70, _velocity);
    _arrow(
      canvas,
      mass + const Offset(0, -68),
      (-params.k * sample.x) / fMax * 70,
      _force,
    );
    _arrow(
      canvas,
      mass + const Offset(0, 28),
      sample.friction / fMax * 70,
      _friction,
    );
    _label(canvas, 'v', mass.dx - 18, railY - 58, _velocity);
    _label(canvas, 'F', mass.dx - 18, railY - 80, _force);
    _label(canvas, 'f', mass.dx - 18, railY + 18, _friction);
    paintDynamicsReadout(canvas, hud, ledger, textColumnWidth: 210);
  }

  @override
  bool shouldRepaint(covariant _RoughHorizontalSpringPainter oldDelegate) {
    return oldDelegate.sample.t != sample.t ||
        oldDelegate.sample.x != sample.x ||
        oldDelegate.sample.v != sample.v ||
        oldDelegate.sample.stuck != sample.stuck ||
        oldDelegate.params.m != params.m ||
        oldDelegate.params.k != params.k ||
        oldDelegate.params.muK != params.muK ||
        oldDelegate.params.muS != params.muS ||
        oldDelegate.params.x0 != params.x0 ||
        oldDelegate.params.v0 != params.v0 ||
        oldDelegate.running != running;
  }
}

void _hatch(Canvas canvas, double x0, double x1, double y) {
  final paint = Paint()
    ..color = const Color(0xFF78909C)
    ..strokeWidth = 1.2;
  var x = x0;
  while (x < x1) {
    canvas.drawLine(Offset(x, y), Offset(x - 7, y + 9), paint);
    x += 8;
  }
}

void _mass(Canvas canvas, Offset c, double r, Color color, String label) {
  canvas.drawCircle(
    c.translate(1.5, 2),
    r,
    Paint()..color = Colors.black.withValues(alpha: 0.12),
  );
  canvas.drawCircle(c, r, Paint()..color = color);
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2,
  );
  final tp = TextPainter(
    text: TextSpan(
      text: label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2));
}

void _label(
  Canvas canvas,
  String text,
  double x,
  double y,
  Color color, {
  bool center = false,
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(canvas, Offset(center ? x - tp.width / 2 : x, y));
}

void _arrow(Canvas canvas, Offset origin, double dx, Color color) {
  if (dx.abs() < 2) return;
  final end = origin.translate(dx, 0);
  final paint = Paint()
    ..color = color
    ..strokeWidth = 2.4
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(origin, end, paint);
  final sign = dx >= 0 ? 1.0 : -1.0;
  canvas.drawPath(
    Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(end.dx - 8 * sign, end.dy - 4)
      ..lineTo(end.dx - 8 * sign, end.dy + 4)
      ..close(),
    Paint()..color = color,
  );
}

void _dashedV(Canvas canvas, double x, double y0, double y1, Color color) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = 1.4;
  var y = y0;
  while (y < y1) {
    canvas.drawLine(Offset(x, y), Offset(x, math.min(y + 6, y1)), paint);
    y += 10;
  }
}
