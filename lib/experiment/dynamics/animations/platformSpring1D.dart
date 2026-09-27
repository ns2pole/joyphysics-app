import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/energy_gauge.dart';
import 'package:joyphysics/experiment/dynamics/animations/springOscillator1D.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// 床に立てた鉛直ばねの上の台 $M$ と、その上に載せたおもり $m$。
/// 下向き正。$y$ は自然長の位置から測った台（接触中はおもりも）の変位。
const double kPlatformSpringMinM = 0.20;
const double kPlatformSpringMaxM = 1.00;
const double kPlatformSpringDefaultM = 0.50;
const double kPlatformSpringMinMMass = 0.10;
const double kPlatformSpringMaxMMass = 0.60;
const double kPlatformSpringDefaultMMass = 0.20;
const double kPlatformSpringMinK = 20.0;
const double kPlatformSpringMaxK = 80.0;
const double kPlatformSpringDefaultK = 40.0;
const double kPlatformSpringMinG = 0.0;
const double kPlatformSpringMaxG = 9.8;
const double kPlatformSpringDefaultG = 9.8;
const double kPlatformSpringMinY0 = 0.02;
const double kPlatformSpringMaxY0 = 0.45;
const double kPlatformSpringDefaultY0 = 0.28;
const double kPlatformSpringMinE = 0.0;
const double kPlatformSpringMaxE = 1.0;
const double kPlatformSpringDefaultE = 0.0;

double platformSpringOmega(double totalMass, double k) =>
    math.sqrt(k / totalMass);

double platformSpringPeriod(double totalMass, double k) =>
    2 * math.pi * math.sqrt(totalMass / k);

class PlatformSpringParams {
  const PlatformSpringParams({
    required this.bigM,
    required this.m,
    required this.k,
    required this.g,
    this.y0 = kPlatformSpringDefaultY0,
    this.e = kPlatformSpringDefaultE,
  });

  /// 台の質量 $M$。
  final double bigM;

  /// おもりの質量 $m$。
  final double m;
  final double k;
  final double g;

  /// 自然長からの初期圧縮。下向き正。静かに放す。
  final double y0;

  /// おもりと台の反発係数。$0$ はくっつく（完全非弾性）、$1$ は完全弾性。
  final double e;

  double get totalMass => bigM + m;

  double get omega => platformSpringOmega(totalMass, k);

  double get period => platformSpringPeriod(totalMass, k);

  /// 一体で振動するときのつりあい。$\displaystyle \delta=\frac{(M+m)g}{k}$。
  double get delta => totalMass * g / k;

  /// 台だけのつりあい。$\displaystyle \delta_M=\frac{Mg}{k}$。
  double get deltaPlatform => bigM * g / k;

  double get omegaPlatform => platformSpringOmega(bigM, k);

  /// $y_0\ge 2\delta$ なら、一体振動のあいだに自然長へ達しておもりが離れる。
  bool get willSeparate => y0 >= 2 * delta - 1e-9;

  factory PlatformSpringParams.fromMap(Map<String, double> params) {
    return PlatformSpringParams(
      bigM: (params['M'] ?? kPlatformSpringDefaultM)
          .clamp(kPlatformSpringMinM, kPlatformSpringMaxM)
          .toDouble(),
      m: (params['m'] ?? kPlatformSpringDefaultMMass)
          .clamp(kPlatformSpringMinMMass, kPlatformSpringMaxMMass)
          .toDouble(),
      k: (params['k'] ?? kPlatformSpringDefaultK)
          .clamp(kPlatformSpringMinK, kPlatformSpringMaxK)
          .toDouble(),
      g: (params['g'] ?? kPlatformSpringDefaultG)
          .clamp(kPlatformSpringMinG, kPlatformSpringMaxG)
          .toDouble(),
      y0: (params['y0'] ?? kPlatformSpringDefaultY0)
          .clamp(kPlatformSpringMinY0, kPlatformSpringMaxY0)
          .toDouble(),
      e: (params['e'] ?? kPlatformSpringDefaultE)
          .clamp(kPlatformSpringMinE, kPlatformSpringMaxE)
          .toDouble(),
    );
  }
}

class PlatformSpringSample {
  const PlatformSpringSample({
    required this.t,
    required this.yPlatform,
    required this.yMass,
    required this.vPlatform,
    required this.vMass,
    required this.aPlatform,
    required this.aMass,
    required this.normal,
    required this.contact,
    required this.dissipated,
  });

  final double t;

  /// 台の位置。自然長から下向き正。
  final double yPlatform;

  /// おもりの位置。自然長から下向き正。
  final double yMass;
  final double vPlatform;
  final double vMass;
  final double aPlatform;
  final double aMass;

  /// 垂直抗力。下向き正の定義では $N=m(g-a)$（接触中）。離れているときは 0。
  final double normal;
  final bool contact;
  final double dissipated;

  double get y => yPlatform;
  double get v => vPlatform;
  double get a => aPlatform;
}

/// 接触中の垂直抗力。下向き正で $\displaystyle N=m(g-a)$。
double platformSpringNormal({
  required double m,
  required double g,
  required double a,
  required bool contact,
}) {
  if (!contact) return 0;
  return m * (g - a);
}

/// 接触中の一体加速度。$\displaystyle a=g-\frac{ky}{M+m}$。
double platformSpringContactAccel(PlatformSpringParams params, double y) {
  return params.g - params.k * y / params.totalMass;
}

/// おもりと台の衝突後速度。下向き正。
/// $\displaystyle v_M'=\frac{Mv_M+mv_m+me(v_m-v_M)}{M+m}$,
/// $\displaystyle v_m'=v_M'-e(v_m-v_M)$。
({double vPlatform, double vMass}) platformSpringImpact({
  required double bigM,
  required double m,
  required double e,
  required double vPlatform,
  required double vMass,
}) {
  final uRel = vMass - vPlatform;
  final vP =
      (bigM * vPlatform + m * vMass + m * e * uRel) / (bigM + m);
  final vM = vP - e * uRel;
  return (vPlatform: vP, vMass: vM);
}

EnergyLedger platformSpringEnergy(
  PlatformSpringParams params,
  PlatformSpringSample sample,
) {
  final ke = 0.5 * params.bigM * sample.vPlatform * sample.vPlatform +
      0.5 * params.m * sample.vMass * sample.vMass;
  final spring = 0.5 * params.k * sample.yPlatform * sample.yPlatform;
  // 下向き正なので重力 PE は $-mgy$。自然長を基準に、初期で非負になるようずらす。
  final grav = -params.bigM * params.g * sample.yPlatform -
      params.m * params.g * sample.yMass;
  final grav0 = -params.totalMass * params.g * params.y0;
  final potential = spring + grav - grav0;
  final e0 = 0.5 * params.k * params.y0 * params.y0;
  return EnergyLedger(
    kinetic: ke,
    potential: potential < 0 ? 0 : potential,
    dissipated: sample.dissipated,
    scale: math.max(e0, ke + potential + sample.dissipated),
    kineticPortions: [
      EnergyPortion(
        value: 0.5 * params.bigM * sample.vPlatform * sample.vPlatform,
        label: '台の運動エネルギー',
        color: const Color(0xFF5E35B1),
      ),
      EnergyPortion(
        value: 0.5 * params.m * sample.vMass * sample.vMass,
        label: 'おもりの運動エネルギー',
        color: kEnergyKinetic,
      ),
    ],
    legendHeat: sample.dissipated > 1e-9,
    potentialLabel: '弾性＋重力',
  );
}

String platformSpringCaption(PlatformSpringParams params) {
  final d = params.delta;
  final thr = 2 * d;
  final eNote = params.e > 1e-6
      ? '再接触の反発係数 e = ${params.e.toStringAsFixed(2)} です。\n'
      : '';
  if (params.willSeparate) {
    return '${eNote}初期圧縮 y0 が 2δ = ${thr.toStringAsFixed(3)} m 以上なので、'
        '自然長で垂直抗力が 0 になりおもりが離れます。\n'
        'δ = ${d.toStringAsFixed(3)} m。離れたあとは台だけが振動し、おもりは放物運動します。';
  }
  return '${eNote}初期圧縮は 2δ = ${thr.toStringAsFixed(3)} m 未満なので、おもりは台から離れません。\n'
      '一体の質量 M+m、つりあい δ = ${d.toStringAsFixed(3)} m のまわりで単振動します。';
}

/// 接触中の単振動。$\displaystyle y=y_{\mathrm{eq}}+(y_c-y_{\mathrm{eq}})\cos\omega\tau+\frac{v_c}{\omega}\sin\omega\tau$。
({double y, double v, double a}) _contactState(
  PlatformSpringParams params,
  double yc,
  double vc,
  double tau,
) {
  final w = params.omega;
  final ye = params.delta;
  final c = math.cos(w * tau);
  final s = math.sin(w * tau);
  final y = ye + (yc - ye) * c + (vc / w) * s;
  final v = -(yc - ye) * w * s + vc * c;
  final a = platformSpringContactAccel(params, y);
  return (y: y, v: v, a: a);
}

/// 台だけの単振動。
({double y, double v, double a}) _platformAlone(
  PlatformSpringParams params,
  double yc,
  double vc,
  double tau,
) {
  final w = params.omegaPlatform;
  final ye = params.deltaPlatform;
  final c = math.cos(w * tau);
  final s = math.sin(w * tau);
  final y = ye + (yc - ye) * c + (vc / w) * s;
  final v = -(yc - ye) * w * s + vc * c;
  final a = params.g - params.k * y / params.bigM;
  return (y: y, v: v, a: a);
}

/// A cos θ + B sin θ = C の、区間 (0, limit] の最小 τ = θ/ω。
double? _shmLevelHit({
  required double ampCos,
  required double ampSin,
  required double level,
  required double omega,
  required double limit,
}) {
  final radius = math.sqrt(ampCos * ampCos + ampSin * ampSin);
  if (radius < 1e-12 || level.abs() > radius + 1e-8) return null;
  final alpha = math.atan2(ampSin, ampCos);
  final delta = math.acos((level / radius).clamp(-1.0, 1.0));
  double? best;
  for (var k = 0; k <= 4; k++) {
    for (final sign in const [1.0, -1.0]) {
      final theta = alpha + sign * delta + 2 * math.pi * k;
      if (theta <= 1e-9) continue;
      final time = theta / omega;
      if (time <= limit + 1e-9 && (best == null || time < best)) {
        best = time;
      }
    }
  }
  if (best == null || best > limit) return null;
  return best;
}

double? _contactSeparateTau(
  PlatformSpringParams params,
  double yc,
  double vc,
  double limit,
) {
  if (params.g < 1e-12) return null;
  final w = params.omega;
  final ye = params.delta;
  final ampCos = yc - ye;
  final ampSin = vc / w;
  // N = m k y / (M+m) なので、自然長 y=0 で離れる。上向き (v≤0) のとき。
  final hit = _shmLevelHit(
    ampCos: ampCos,
    ampSin: ampSin,
    level: -ye,
    omega: w,
    limit: limit,
  );
  if (hit == null) return null;
  final state = _contactState(params, yc, vc, hit);
  if (state.y > 1e-6) return null;
  if (state.v > 1e-6) return null;
  return hit;
}

PlatformSpringSample platformSpringAt(PlatformSpringParams params, double t) {
  final time = math.max(0.0, t);
  var yc = params.y0;
  var vc = 0.0;
  var contact = true;
  var elapsed = 0.0;
  var heat = 0.0;
  var yP = yc;
  var vP = vc;
  var aP = platformSpringContactAccel(params, yc);
  var yM = yc;
  var vM = vc;
  var aM = aP;

  for (var guard = 0; guard < 64 && elapsed < time - 1e-12; guard++) {
    final remain = time - elapsed;
    if (contact) {
      final sep = _contactSeparateTau(params, yc, vc, remain);
      if (sep == null) {
        final s = _contactState(params, yc, vc, remain);
        yP = s.y;
        vP = s.v;
        aP = s.a;
        yM = s.y;
        vM = s.v;
        aM = s.a;
        elapsed = time;
        break;
      }
      final s = _contactState(params, yc, vc, sep);
      yP = 0;
      vP = s.v;
      aP = platformSpringContactAccel(params, 0);
      yM = 0;
      vM = s.v;
      aM = params.g;
      contact = false;
      elapsed += sep;
      yc = 0;
      vc = s.v;
      continue;
    }

    // 離れている：台は単独振動、おもりは自由落下。再接触を探す。
    final freeStart = elapsed;
    final yP0 = yc;
    final vP0 = vc;
    final yM0 = yM;
    final vM0 = vM;
    var tauHit = remain;
    var hit = false;
    const steps = 800;
    final hStep = math.max(remain / steps, 1e-5);
    final nSteps = math.max(1, (remain / hStep).ceil());
    var prevGap = yM0 - yP0;
    for (var i = 1; i <= nSteps; i++) {
      final tau = math.min(remain, hStep * i);
      final plat = _platformAlone(params, yP0, vP0, tau);
      final yMass = yM0 + vM0 * tau + 0.5 * params.g * tau * tau;
      final gap = yMass - plat.y;
      if (prevGap < -1e-10 && gap >= -1e-10) {
        final frac = prevGap.abs() / (prevGap.abs() + gap.abs() + 1e-18);
        tauHit = hStep * (i - 1) + frac * hStep;
        hit = true;
        break;
      }
      prevGap = gap;
      if (i == nSteps) {
        yP = plat.y;
        vP = plat.v;
        aP = plat.a;
        yM = yMass;
        vM = vM0 + params.g * tau;
        aM = params.g;
      }
    }
    if (!hit) {
      elapsed = time;
      break;
    }
    final plat = _platformAlone(params, yP0, vP0, tauHit);
    final yHit = plat.y;
    final vMass = vM0 + params.g * tauHit;
    final keBefore =
        0.5 * params.bigM * plat.v * plat.v + 0.5 * params.m * vMass * vMass;
    final impact = platformSpringImpact(
      bigM: params.bigM,
      m: params.m,
      e: params.e,
      vPlatform: plat.v,
      vMass: vMass,
    );
    final keAfter = 0.5 * params.bigM * impact.vPlatform * impact.vPlatform +
        0.5 * params.m * impact.vMass * impact.vMass;
    heat += math.max(0.0, keBefore - keAfter);
    yP = yHit;
    yM = yHit;
    vP = impact.vPlatform;
    vM = impact.vMass;
    elapsed = freeStart + tauHit;

    // e≈0 ならくっつく。それ以外は弾いて離れる。
    if (params.e <= 1e-6) {
      final vCommon = impact.vPlatform;
      vP = vCommon;
      vM = vCommon;
      aP = platformSpringContactAccel(params, yP);
      aM = aP;
      contact = true;
      yc = yP;
      vc = vCommon;
      final n = platformSpringNormal(
        m: params.m,
        g: params.g,
        a: aP,
        contact: true,
      );
      if (n < -1e-9 && vP < 0) {
        contact = false;
        aM = params.g;
      }
    } else {
      aP = params.g - params.k * yP / params.bigM;
      aM = params.g;
      contact = false;
      yc = yP;
      vc = vP;
    }
  }

  final normal = platformSpringNormal(
    m: params.m,
    g: params.g,
    a: aP,
    contact: contact,
  );
  return PlatformSpringSample(
    t: time,
    yPlatform: yP,
    yMass: contact ? yP : yM,
    vPlatform: vP,
    vMass: contact ? vP : vM,
    aPlatform: aP,
    aMass: contact ? aP : aM,
    normal: math.max(0.0, normal),
    contact: contact,
    dissipated: heat,
  );
}

const String kPlatformSpringFormula =
    r'\displaystyle (M+m)\ddot y=(M+m)g-ky';

final platformSpring1D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: 'ばね上の台とおもり',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>床に立てたばねの上に質量 $M$ の平らな台があり、その上に質量 $m$ のおもりが載っています。ばね定数を $k$ とし、下向きを正、自然長の位置を $y=0$ とします。おもりが台から離れないあいだは一体で動き</p>
  <p>$$\displaystyle (M+m)\ddot y=(M+m)g-ky$$</p>
  <p>つりあい $\displaystyle \delta=\frac{(M+m)g}{k}$ からの変位を $x=y-\delta$ とすると</p>
  <p>$$\displaystyle \ddot x=-\omega^{2}x,\quad \omega=\sqrt{\frac{k}{M+m}},\quad T=2\pi\sqrt{\frac{M+m}{k}}$$</p>
  <p>おもりの運動方程式 $\displaystyle mg-N=ma$ から、垂直抗力は</p>
  <p>$$\displaystyle N=m(g-a)=\frac{mky}{M+m}$$</p>
  <p>自然長 $y=0$ で $N=0$ になります。静かに圧縮して放すとき、反対側の端が $2\delta-y_0$ なので、$y_0\ge 2\delta$ なら途中でおもりが台から離れます。離れたあとのおもりは自由落下、台は質量 $M$ だけの単振動です。</p>
  <p>再び触れたときの反発係数を $e$ とします（$e=0$ はくっついて一体、$e=1$ は完全弾性）。運動量保存と</p>
  <p>$$\displaystyle v_m'-v_M'=-e(v_m-v_M)$$</p>
  <p>から衝突後の速度が決まり、$e>0$ なら弾んでまた離れます。</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: PlatformSpring1DSimulation(),
      height: 1040,
    ),
  ],
);

class PlatformSpring1DSimulation extends PhysicsSimulation {
  PlatformSpring1DSimulation()
      : super(
          title: 'ばね上の台とおもり',
          formula: const FormulaDisplay(kPlatformSpringFormula),
          // 鉛直バネと同じ縦長キャンバス。
          aspectRatio: 4 / 5,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> simTime = ValueNotifier(0.0);

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    simTime.value += dt * _playback;
  });

  ValueNotifier<bool> get running => _loop.running;

  Map<String, double> _latestParams = {};

  static const double _playback = 0.45;

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'M': kPlatformSpringDefaultM,
        'm': kPlatformSpringDefaultMMass,
        'k': kPlatformSpringDefaultK,
        'g': kPlatformSpringDefaultG,
        'y0': kPlatformSpringDefaultY0,
        'e': kPlatformSpringDefaultE,
      };

  PlatformSpringParams get _params {
    if (_latestParams.isEmpty) {
      return PlatformSpringParams.fromMap(initialParameters);
    }
    return PlatformSpringParams.fromMap(_latestParams);
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
  Widget? buildFormulaOverlay(Map<String, double> parameters) {
    _rememberParams(parameters);
    return const FormulaDisplay(kPlatformSpringFormula);
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
              platformSpringCaption(_params),
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
        '台 M・おもり m・ばね k・重力 g・初期圧縮 y0・反発係数 e',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _PlatformSlider(
        label: 'M',
        value: p.bigM,
        min: kPlatformSpringMinM,
        max: kPlatformSpringMaxM,
        onChanged: (v) {
          updateParam('M', v);
          resetMotion();
        },
        semanticLabel: '台の質量 M',
      ),
      _PlatformSlider(
        label: 'm',
        value: p.m,
        min: kPlatformSpringMinMMass,
        max: kPlatformSpringMaxMMass,
        onChanged: (v) {
          updateParam('m', v);
          resetMotion();
        },
        semanticLabel: 'おもりの質量 m',
      ),
      _PlatformSlider(
        label: 'k',
        value: p.k,
        min: kPlatformSpringMinK,
        max: kPlatformSpringMaxK,
        onChanged: (v) {
          updateParam('k', v);
          resetMotion();
        },
        semanticLabel: 'ばね定数 k',
      ),
      _PlatformSlider(
        label: 'g',
        value: p.g,
        min: kPlatformSpringMinG,
        max: kPlatformSpringMaxG,
        onChanged: (v) {
          updateParam('g', v);
          resetMotion();
        },
        semanticLabel: '重力加速度 g',
      ),
      _PlatformSlider(
        label: 'y0',
        value: p.y0,
        min: kPlatformSpringMinY0,
        max: kPlatformSpringMaxY0,
        onChanged: (v) {
          updateParam('y0', v);
          resetMotion();
        },
        semanticLabel: '初期圧縮 自然長から下',
      ),
      _PlatformSlider(
        label: 'e',
        value: p.e,
        min: kPlatformSpringMinE,
        max: kPlatformSpringMaxE,
        onChanged: (v) {
          updateParam('e', v);
          resetMotion();
        },
        semanticLabel: 'おもりと台の反発係数 e（0 がくっつく、1 が完全弾性）',
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'δ = ${p.delta.toStringAsFixed(3)} m    '
          '2δ = ${(2 * p.delta).toStringAsFixed(3)} m    '
          'T = ${p.period.toStringAsFixed(2)} s',
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
        final p = PlatformSpringParams.fromMap(parameters);
        final sample = platformSpringAt(p, simTime.value);
        return CustomPaint(
          size: Size.infinite,
          painter: _PlatformSpringPainter(
            params: p,
            sample: sample,
            running: running.value,
          ),
        );
      },
    );
  }
}

class _PlatformSlider extends StatelessWidget {
  const _PlatformSlider({
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

class _PlatformSpringPainter extends CustomPainter {
  _PlatformSpringPainter({
    required this.params,
    required this.sample,
    required this.running,
  });

  final PlatformSpringParams params;
  final PlatformSpringSample sample;
  final bool running;

  static const _bg = Color(0xFFF7FAFC);
  static const _platform = Color(0xFF546E7A);
  static const _mass = Color(0xFF1E88E5);
  static const _eq = Color(0xFFEF6C00);
  static const _natural = Color(0xFF607D8B);
  static const _velocity = Color(0xFF1565C0);
  static const _gravity = Color(0xFFEF6C00);
  static const _springForce = Color(0xFF2E7D32);
  static const _normal = Color(0xFF00897B);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final contactLabel = sample.contact ? '接触' : '離れている';
    final hud = 't = ${sample.t.toStringAsFixed(2)} s\n'
        'y = ${sample.yPlatform.toStringAsFixed(3)} m\n'
        'v = ${springVelocityReadout(sample.vPlatform, downwardPositive: true)} m/s\n'
        'N = ${sample.normal.toStringAsFixed(2)} N\n'
        '$contactLabel\n'
        'T = ${params.period.toStringAsFixed(2)} s';
    final ledger = platformSpringEnergy(params, sample);
    final ceiling = dynamicsReadoutCard(
      hud,
      ledger,
      textColumnWidth: 200,
      bounds: size,
    ).bottom;

    final top = ceiling + 8;
    final floorY = size.height - 24;
    final amp = math.max(
      (params.y0 - params.delta).abs(),
      params.delta,
    );
    final yHi = math.max(params.y0, params.delta + amp) + 0.08;
    // 鉛直バネと同じ：HUD直下〜床までをフルに座標へ使う。
    final hang = top + 16;
    final yLo = -math.max(0.22, 0.55 * params.y0);
    double sy(double y) =>
        hang + ((y - yLo) / (yHi - yLo)) * (floorY - hang);
    final naturalScreen = sy(0);
    final rMass = springMassRadius(params.m);
    final cx = size.width * 0.40;
    const platformHalf = 54.0;
    const platformH = 14.0;

    // 床
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 88, floorY, 176, 16),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF78909C),
    );

    _dashedH(canvas, 24, size.width - 24, naturalScreen, _natural);
    _label(canvas, '自然長', 28, naturalScreen - 16, _natural);
    if (params.delta > 1e-4) {
      _dashedH(canvas, 24, size.width - 24, sy(params.delta), _eq);
      _label(canvas, 'つりあい δ', size.width - 92, sy(params.delta) - 16, _eq);
    }

    final platformTop = sy(sample.yPlatform);
    final springTop = platformTop + platformH * 0.15;
    paintCoilSpring(
      canvas,
      Offset(cx, floorY),
      Offset(cx, springTop),
      params.k,
      coils: 20,
    );

    // 台
    final platRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, platformTop),
        width: platformHalf * 2,
        height: platformH,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(platRect, Paint()..color = _platform);
    canvas.drawRRect(
      platRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    _label(canvas, 'M', cx - 8, platformTop - 6, Colors.white);

    // おもり（接触中は台の上、離れているときは yMass）
    final massY = sample.contact
        ? platformTop - platformH * 0.5 - rMass
        : sy(sample.yMass) - rMass;
    final massCenter = Offset(cx, massY);
    canvas.drawCircle(
      massCenter.translate(1.5, 2),
      rMass,
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
    canvas.drawCircle(massCenter, rMass, Paint()..color = _mass);
    canvas.drawCircle(
      massCenter,
      rMass,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: 'm',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(massCenter.dx - tp.width / 2, massCenter.dy - tp.height / 2),
    );

    // —— 力の図示（下向き正の物理に対応：下向き矢印＝重力など）——
    final fScale = 46.0 / math.max(params.m * math.max(params.g, 1.0), 1e-6);
    final mgLen = (params.m * params.g * fScale).clamp(8.0, 70.0);
    final MgLen = (params.bigM * params.g * fScale).clamp(8.0, 80.0);
    final springF = params.k * sample.yPlatform; // 下向き正で台へのばね力は -ky
    final springLen = (springF.abs() * fScale).clamp(0.0, 90.0);
    final nLen = (sample.normal * fScale).clamp(0.0, 70.0);

    // おもり m: mg ↓、接触中は N ↑
    final massForceX = massCenter.dx + rMass + 16;
    _arrowDown(canvas, Offset(massForceX, massCenter.dy), mgLen, _gravity);
    _label(
      canvas,
      'mg',
      massForceX + 6,
      massCenter.dy + mgLen + 2,
      _gravity,
    );
    if (sample.contact && nLen > 2) {
      _arrowUp(canvas, Offset(massForceX + 22, massCenter.dy), nLen, _normal);
      _label(
        canvas,
        'N',
        massForceX + 14,
        massCenter.dy - nLen - 14,
        _normal,
      );
    }

    // 台 M: Mg ↓、ばね力（圧縮なら上、伸びなら下）、接触中は N ↓（作用反作用）
    final platForceX = cx + platformHalf + 18;
    _arrowDown(canvas, Offset(platForceX, platformTop), MgLen, _gravity);
    _label(
      canvas,
      'Mg',
      platForceX + 6,
      platformTop + MgLen + 2,
      _gravity,
    );
    if (springLen > 2) {
      if (sample.yPlatform >= 0) {
        _arrowUp(
          canvas,
          Offset(platForceX + 24, platformTop),
          springLen,
          _springForce,
        );
        _label(
          canvas,
          'ky',
          platForceX + 16,
          platformTop - springLen - 14,
          _springForce,
        );
      } else {
        _arrowDown(
          canvas,
          Offset(platForceX + 24, platformTop),
          springLen,
          _springForce,
        );
        _label(
          canvas,
          'ky',
          platForceX + 16,
          platformTop + springLen + 2,
          _springForce,
        );
      }
    }
    if (sample.contact && nLen > 2) {
      _arrowDown(
        canvas,
        Offset(platForceX + 48, platformTop),
        nLen,
        _normal,
      );
      _label(
        canvas,
        'N',
        platForceX + 40,
        platformTop + nLen + 2,
        _normal,
      );
    }

    final vMax = math.max(amp * params.omega, 0.3);
    _arrowY(
      canvas,
      Offset(cx - platformHalf - 18, platformTop),
      sample.vPlatform / vMax * 64,
      _velocity,
    );
    _label(canvas, 'v', cx - platformHalf - 38, platformTop - 18, _velocity);

    paintDynamicsReadout(canvas, hud, ledger, textColumnWidth: 200);
  }

  @override
  bool shouldRepaint(covariant _PlatformSpringPainter oldDelegate) {
    return oldDelegate.sample.t != sample.t ||
        oldDelegate.sample.yPlatform != sample.yPlatform ||
        oldDelegate.sample.yMass != sample.yMass ||
        oldDelegate.sample.contact != sample.contact ||
        oldDelegate.params.bigM != params.bigM ||
        oldDelegate.params.m != params.m ||
        oldDelegate.params.k != params.k ||
        oldDelegate.params.g != params.g ||
        oldDelegate.params.y0 != params.y0 ||
        oldDelegate.params.e != params.e ||
        oldDelegate.running != running;
  }
}

void _label(Canvas canvas, String text, double x, double y, Color color) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(canvas, Offset(x, y));
}

void _arrowY(Canvas canvas, Offset origin, double dy, Color color) {
  if (dy.abs() < 2) return;
  final end = origin.translate(0, dy);
  final paint = Paint()
    ..color = color
    ..strokeWidth = 2.4
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(origin, end, paint);
  final sign = dy >= 0 ? 1.0 : -1.0;
  canvas.drawPath(
    Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(end.dx - 4, end.dy - 8 * sign)
      ..lineTo(end.dx + 4, end.dy - 8 * sign)
      ..close(),
    Paint()..color = color,
  );
}

void _arrowUp(Canvas canvas, Offset origin, double len, Color color) {
  if (len < 2) return;
  final end = origin.translate(0, -len);
  final paint = Paint()
    ..color = color
    ..strokeWidth = 2.4
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(origin, end, paint);
  canvas.drawPath(
    Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(end.dx - 4, end.dy + 8)
      ..lineTo(end.dx + 4, end.dy + 8)
      ..close(),
    Paint()..color = color,
  );
}

void _arrowDown(Canvas canvas, Offset origin, double len, Color color) {
  if (len < 2) return;
  final end = origin.translate(0, len);
  final paint = Paint()
    ..color = color
    ..strokeWidth = 2.4
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(origin, end, paint);
  canvas.drawPath(
    Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(end.dx - 4, end.dy - 8)
      ..lineTo(end.dx + 4, end.dy - 8)
      ..close(),
    Paint()..color = color,
  );
}

void _dashedH(Canvas canvas, double x0, double x1, double y, Color color) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = 1.4;
  var x = x0;
  while (x < x1) {
    canvas.drawLine(Offset(x, y), Offset(math.min(x + 6, x1), y), paint);
    x += 10;
  }
}
