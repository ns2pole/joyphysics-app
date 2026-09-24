import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/energy_gauge.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// 右向き正。原点の $M$ は静止。左の $m$ が速さ $v$ で衝突する。
/// 画面の軸は止まっている。物体だけが動く。
const double kCollisionMinMass = 0.5;
const double kCollisionMaxMass = 5.0;
const double kCollisionDefaultM = 1.0;
const double kCollisionDefaultCapitalM = 1.0;
const double kCollisionMinE = 0.0;
const double kCollisionMaxE = 1.0;
const double kCollisionDefaultE = 1.0;
const double kCollisionMinV = 1.0;
const double kCollisionMaxV = 5.0;
const double kCollisionDefaultV = 2.5;

/// 面と面のあいだ。衝突時刻は質量の大きさによらない。
const double kCollisionApproach = 1.5;

/// 静止した目。再生中もスライダーを動かしても、この範囲は変えない。
const double kCollisionViewMin = -3.0;
const double kCollisionViewMax = 4.0;
const double kCollisionStrobeDt = 0.08;
const double kCollisionHalfAt1kg = 0.22;

const Color kCollisionMass = Color(0xFF1E88E5);
const Color kCollisionTarget = Color(0xFFFB8C00);

class Collision1DParams {
  const Collision1DParams({
    required this.m,
    required this.capitalM,
    required this.e,
    required this.v,
  });

  final double m;
  final double capitalM;
  final double e;
  final double v;

  factory Collision1DParams.fromMap(Map<String, double> params) {
    return Collision1DParams(
      m: params['m']!.clamp(kCollisionMinMass, kCollisionMaxMass).toDouble(),
      capitalM: params['M']!
          .clamp(kCollisionMinMass, kCollisionMaxMass)
          .toDouble(),
      e: params['e']!.clamp(kCollisionMinE, kCollisionMaxE).toDouble(),
      v: params['v']!.clamp(kCollisionMinV, kCollisionMaxV).toDouble(),
    );
  }
}

class Collision1DSample {
  const Collision1DSample({
    required this.t,
    required this.xm,
    required this.xM,
    required this.vm,
    required this.vM,
    required this.collided,
  });

  final double t;
  final double xm;
  final double xM;
  final double vm;
  final double vM;
  final bool collided;
}

/// $1\,\mathrm{kg}$ で $0.22\,\mathrm{m}$。重いほど少し大きい。
double collisionHalfWidth(double mass) {
  return kCollisionHalfAt1kg * math.pow(mass, 1 / 3);
}

/// 衝突後。止まっていた $M$ に左から $v$ で当たる。
/// $\displaystyle v_m'=\frac{m-eM}{m+M}v$
double collisionVmPrime(Collision1DParams params) {
  final sum = params.m + params.capitalM;
  return (params.m - params.e * params.capitalM) / sum * params.v;
}

/// $\displaystyle v_M'=\frac{(1+e)m}{m+M}v$
double collisionVMPrime(Collision1DParams params) {
  final sum = params.m + params.capitalM;
  return (1 + params.e) * params.m / sum * params.v;
}

double collisionHitTime(Collision1DParams params) {
  return kCollisionApproach / params.v;
}

double collisionContactGap(Collision1DParams params) {
  return collisionHalfWidth(params.m) + collisionHalfWidth(params.capitalM);
}

/// 左の物体の中心の初期位置。右の物体の中心は原点。
double collisionIncomingX0(Collision1DParams params) {
  return -(collisionContactGap(params) + kCollisionApproach);
}

EnergyLedger collision1DEnergy(
  Collision1DParams params,
  Collision1DSample sample,
) {
  final k1 = 0.5 * params.m * sample.vm * sample.vm;
  final k2 = 0.5 * params.capitalM * sample.vM * sample.vM;
  final scale = 0.5 * params.m * params.v * params.v;
  final heat = math.max(0.0, scale - k1 - k2);
  return EnergyLedger(
    kinetic: k1 + k2,
    potential: 0,
    dissipated: heat,
    scale: scale,
    legendPotential: false,
    legendHeat: heat > 1e-4,
    kineticPortions: [
      EnergyPortion(value: k1, label: 'mの運動エネルギー', color: kCollisionMass),
      EnergyPortion(
        value: k2,
        label: 'Mの運動エネルギー',
        color: kCollisionTarget,
      ),
    ],
  );
}

Collision1DSample collision1DAt(Collision1DParams params, double t) {
  final time = math.max(0.0, t);
  final hit = collisionHitTime(params);
  final x0 = collisionIncomingX0(params);
  if (time < hit) {
    return Collision1DSample(
      t: time,
      xm: x0 + params.v * time,
      xM: 0,
      vm: params.v,
      vM: 0,
      collided: false,
    );
  }
  final after = time - hit;
  final vm = collisionVmPrime(params);
  final vM = collisionVMPrime(params);
  final xmHit = x0 + params.v * hit;
  return Collision1DSample(
    t: time,
    xm: xmHit + vm * after,
    xM: vM * after,
    vm: vm,
    vM: vM,
    collided: true,
  );
}

/// 速さがある物体が、固定した軸の中にまだいる。
bool collision1DOnStage(Collision1DParams params, Collision1DSample sample) {
  bool movingInside(double x, double half, double v) {
    if (v.abs() < 1e-3) return false;
    return x + half > kCollisionViewMin && x - half < kCollisionViewMax;
  }

  return movingInside(sample.xm, collisionHalfWidth(params.m), sample.vm) ||
      movingInside(
        sample.xM,
        collisionHalfWidth(params.capitalM),
        sample.vM,
      );
}

List<Collision1DSample> collision1DStrobe(
  Collision1DParams params,
  double t, {
  double dt = kCollisionStrobeDt,
}) {
  if (t <= 1e-9 || dt <= 0) return const [];
  final samples = <Collision1DSample>[];
  for (var ti = dt; ti < t - 1e-9; ti += dt) {
    samples.add(collision1DAt(params, ti));
  }
  return samples;
}

const String kCollisionCaption =
    '1次元の衝突。原点の M は止まっている。\n'
    '左の m が速さ v で右へ進み、正面からぶつかる。\n'
    '軸は止めたまま。動くのは物体のほう。\n'
    '摩擦はないので、衝突の前後はどちらも等速。\n'
    'e = 1 で m = M なら速度が入れ替わる。e = 0 なら同じ速度で進む。';

final collision1D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '1次元の衝突',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>1次元の衝突です。原点に質量 $M$ の物体が止まっていて、左から質量 $m$ の物体が速さ $v$ でぶつかってきます。摩擦はないので、衝突の前後はどちらも等速直線運動です。右向きを正にします。軸は止めたままです。</p>
  <p>運動量は保存されます。</p>
  <p>$$mv=mv_{m}'+Mv_{M}'$$</p>
  <p>反発係数 $e$ は、離れる向きの相対速度が、近づく向きの相対速度の $e$ 倍になることです。</p>
  <p>$$e=\frac{v_{M}'-v_{m}'}{v}$$</p>
  <p>この二つから、衝突後の速度は</p>
  <p>$$v_{m}'=\frac{m-eM}{m+M}v,\quad v_{M}'=\frac{(1+e)m}{m+M}v$$</p>
  <p>$e=1$ で $m=M$ なら、ぶつかった側は止まり、止まっていた側が速さ $v$ で進みます。$e=0$ なら二つは同じ速度 $\displaystyle \frac{m}{m+M}v$ で進みます。$e<1$ では力学的エネルギーの一部が熱になります。</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: Collision1DSimulation(),
      height: 860,
    ),
  ],
);

class Collision1DSimulation extends PhysicsSimulation {
  Collision1DSimulation()
      : super(
          title: '1次元の衝突',
          formula: const FormulaDisplay(
            r"\displaystyle v_{m}'=\frac{m-eM}{m+M}v,\quad v_{M}'=\frac{(1+e)m}{m+M}v",
          ),
          aspectRatio: (16 / 9) / 1.5,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> simTime = ValueNotifier(0.0);

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    final next = simTime.value + dt * 0.55;
    final sample = collision1DAt(_params, next);
    simTime.value = next;
    if (!collision1DOnStage(_params, sample)) _loop.pause();
  });

  ValueNotifier<bool> get running => _loop.running;

  Map<String, double> _latestParams = {};

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'm': kCollisionDefaultM,
        'M': kCollisionDefaultCapitalM,
        'e': kCollisionDefaultE,
        'v': kCollisionDefaultV,
      };

  Collision1DParams get _params {
    if (_latestParams.isEmpty) {
      return Collision1DParams.fromMap(initialParameters);
    }
    return Collision1DParams.fromMap(_latestParams);
  }

  void _rememberParams(Map<String, double> params) {
    final next = Map<String, double>.from(params);
    if (_latestParams.isNotEmpty && !_sameParams(_latestParams, next)) {
      simTime.value = 0.0;
    }
    _latestParams = next;
  }

  bool _sameParams(Map<String, double> a, Map<String, double> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  void start() {
    if (running.value) return;
    final now = collision1DAt(_params, simTime.value);
    if (simTime.value > 1e-3 && !collision1DOnStage(_params, now)) {
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
      r"\displaystyle v_{m}'=\frac{m-eM}{m+M}v,\quad v_{M}'=\frac{(1+e)m}{m+M}v",
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
              kCollisionCaption,
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
    final vm = collisionVmPrime(p);
    final vM = collisionVMPrime(p);
    return [
      const Text(
        '初期条件（右向き正）',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _CollisionSlider(
        label: 'm',
        value: p.m,
        min: kCollisionMinMass,
        max: kCollisionMaxMass,
        onChanged: (v) => updateParam('m', v),
        semanticLabel: '質量 m',
      ),
      _CollisionSlider(
        label: 'M',
        value: p.capitalM,
        min: kCollisionMinMass,
        max: kCollisionMaxMass,
        onChanged: (v) => updateParam('M', v),
        semanticLabel: '質量 M',
      ),
      _CollisionSlider(
        label: 'e',
        value: p.e,
        min: kCollisionMinE,
        max: kCollisionMaxE,
        onChanged: (v) => updateParam('e', v),
        semanticLabel: '反発係数 e',
      ),
      _CollisionSlider(
        label: 'v',
        value: p.v,
        min: kCollisionMinV,
        max: kCollisionMaxV,
        onChanged: (v) => updateParam('v', v),
        semanticLabel: '衝突前の速さ v',
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          "衝突後  vm' = ${vm.toStringAsFixed(2)} m/s    vM' = ${vM.toStringAsFixed(2)} m/s",
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
        final p = Collision1DParams.fromMap(parameters);
        final sample = collision1DAt(p, simTime.value);
        return CustomPaint(
          size: Size.infinite,
          painter: _CollisionPainter(
            params: p,
            sample: sample,
            strobes: collision1DStrobe(p, sample.t),
            running: running.value,
          ),
        );
      },
    );
  }
}

class _CollisionSlider extends StatelessWidget {
  const _CollisionSlider({
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
          width: 22,
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

class _CollisionPainter extends CustomPainter {
  _CollisionPainter({
    required this.params,
    required this.sample,
    required this.strobes,
    required this.running,
  });

  final Collision1DParams params;
  final Collision1DSample sample;
  final List<Collision1DSample> strobes;
  final bool running;

  static const _bg = Color(0xFFF7FAFC);
  static const _ink = Color(0xFF37474F);
  static const _ground = Color(0xFF8D6E63);
  static const _origin = Color(0xFF607D8B);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final lines = _hudLines();
    final ceiling = dynamicsReadoutCard(
      lines,
      collision1DEnergy(params, sample),
      textColumnWidth: 168,
      bounds: size,
    ).bottom;
    final railY = math.max(size.height * 0.62, ceiling + 96);
    final map = _mapper(size);
    _drawGround(canvas, size, railY, map);
    _drawOrigin(canvas, railY, map);
    _drawTrail(canvas, railY, map);
    _drawBlock(
      canvas,
      railY,
      map,
      sample.xM,
      collisionHalfWidth(params.capitalM),
      sample.vM,
      kCollisionTarget,
      'M',
    );
    _drawBlock(
      canvas,
      railY,
      map,
      sample.xm,
      collisionHalfWidth(params.m),
      sample.vm,
      kCollisionMass,
      'm',
    );
    _drawHud(canvas, lines);
  }

  _XMap _mapper(Size size) {
    const left = 28.0;
    final right = size.width - 20;
    const xMin = kCollisionViewMin;
    const xMax = kCollisionViewMax;
    final span = xMax - xMin;
    return _XMap(
      xOf: (x) => left + (x - xMin) / span * (right - left),
      pxPerMeter: (right - left) / span,
      xMin: xMin,
      xMax: xMax,
    );
  }

  void _drawGround(Canvas canvas, Size size, double railY, _XMap map) {
    canvas.drawLine(
      Offset(map.xOf(map.xMin), railY),
      Offset(map.xOf(map.xMax), railY),
      Paint()
        ..color = _ground
        ..strokeWidth = 3,
    );
    for (var x = map.xMin; x <= map.xMax + 1e-9; x += 1) {
      final px = map.xOf(x);
      canvas.drawLine(
        Offset(px, railY),
        Offset(px, railY + 8),
        Paint()
          ..color = _ground
          ..strokeWidth = 1.4,
      );
      _label(canvas, Offset(px, railY + 12), x.toStringAsFixed(0), _ink);
    }
  }

  void _drawOrigin(Canvas canvas, double railY, _XMap map) {
    final px = map.xOf(0);
    final paint = Paint()
      ..color = _origin
      ..strokeWidth = 1.4;
    var y = railY - 108.0;
    while (y < railY) {
      canvas.drawLine(Offset(px, y), Offset(px, math.min(y + 6, railY)), paint);
      y += 10;
    }
    _label(canvas, Offset(px, railY - 122), '原点', _origin);
  }

  void _drawTrail(Canvas canvas, double railY, _XMap map) {
    for (final s in strobes) {
      _dot(canvas, map, s.xm, railY, kCollisionMass);
      _dot(canvas, map, s.xM, railY, kCollisionTarget);
    }
  }

  void _dot(Canvas canvas, _XMap map, double x, double railY, Color color) {
    if (x < map.xMin || x > map.xMax) return;
    canvas.drawCircle(
      Offset(map.xOf(x), railY - 20),
      3.0,
      Paint()..color = color.withValues(alpha: 0.45),
    );
  }

  void _drawBlock(
    Canvas canvas,
    double railY,
    _XMap map,
    double x,
    double half,
    double velocity,
    Color color,
    String name,
  ) {
    final width = 2 * half * map.pxPerMeter;
    final c = Offset(map.xOf(x), railY - 20);
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: width, height: 34),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect.shift(const Offset(0, 2)), Paint()..color = Colors.black12);
    canvas.drawRRect(rect, Paint()..color = color);
    _label(canvas, c, name, Colors.white);

    if (velocity.abs() < 0.05) {
      _label(canvas, c + const Offset(0, -36), 'v = 0', color);
      return;
    }
    final dir = velocity >= 0 ? const Offset(1, 0) : const Offset(-1, 0);
    final len = (velocity.abs() / kCollisionMaxV * 64).clamp(16.0, 78.0);
    final origin = c + Offset(dir.dx * width / 2, -6);
    _drawArrow(canvas, origin, dir, len, color);
  }

  void _drawArrow(
    Canvas canvas,
    Offset origin,
    Offset dir,
    double length,
    Color color,
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
  }

  String _hudLines() {
    final phase = sample.collided ? '衝突後' : '衝突前';
    return 't = ${sample.t.toStringAsFixed(2)} s  $phase\n'
        'xm = ${sample.xm.toStringAsFixed(2)} m\n'
        'vm = ${sample.vm.toStringAsFixed(2)} m/s\n'
        'xM = ${sample.xM.toStringAsFixed(2)} m\n'
        'vM = ${sample.vM.toStringAsFixed(2)} m/s';
  }

  void _drawHud(Canvas canvas, String lines) {
    paintDynamicsReadout(
      canvas,
      lines,
      collision1DEnergy(params, sample),
      textColumnWidth: 168,
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
  bool shouldRepaint(covariant _CollisionPainter oldDelegate) {
    return oldDelegate.sample.t != sample.t ||
        oldDelegate.sample.xm != sample.xm ||
        oldDelegate.sample.xM != sample.xM ||
        oldDelegate.params.m != params.m ||
        oldDelegate.params.capitalM != params.capitalM ||
        oldDelegate.params.e != params.e ||
        oldDelegate.params.v != params.v ||
        oldDelegate.running != running;
  }
}

class _XMap {
  const _XMap({
    required this.xOf,
    required this.pxPerMeter,
    required this.xMin,
    required this.xMax,
  });

  final double Function(double x) xOf;
  final double pxPerMeter;
  final double xMin;
  final double xMax;
}
