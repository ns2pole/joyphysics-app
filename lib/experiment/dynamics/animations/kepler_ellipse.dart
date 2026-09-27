import 'dart:math' as math;

import 'package:joyphysics/experiment/dynamics/animations/energy_gauge.dart';

const double kKeplerGM = 1.0;
const double kKeplerVelocityArrowScale = 0.5;

double keplerMeanMotion(double a, {double gm = kKeplerGM}) =>
    math.sqrt(gm / (a * a * a));

double keplerPeriod(double a, {double gm = kKeplerGM}) =>
    2 * math.pi / keplerMeanMotion(a, gm: gm);

double keplerSemiMinor(double a, double e) =>
    a * math.sqrt(math.max(0.0, 1 - e * e));

/// 表示が $1.00$ になる幅では放物線として扱う。
bool keplerIsParabola(double e) => (e - 1).abs() <= 0.005;

bool keplerIsEllipse(double e) => e < 1 && !keplerIsParabola(e);

bool keplerIsHyperbola(double e) => e > 1 && !keplerIsParabola(e);

/// 楕円は $a(1-e)$、双曲線は $a(e-1)$、放物線は半長軸スライダーの $a$ を近日点距離にする。
double keplerPeriapsisRadius(double a, double e) {
  if (keplerIsParabola(e)) return a;
  if (e < 1) return a * (1 - e);
  return a * (e - 1);
}

double keplerApoapsisRadius(double a, double e) => a * (1 + e);

double keplerPeriapsisSpeed(double a, double e, {double gm = kKeplerGM}) {
  final rp = math.max(keplerPeriapsisRadius(a, e), 1e-12);
  if (keplerIsParabola(e)) return math.sqrt(2 * gm / rp);
  return math.sqrt(gm * (1 + e) / rp);
}

double keplerSpecificAngularMomentum(double a, double e,
    {double gm = kKeplerGM}) {
  if (keplerIsParabola(e)) {
    return math.sqrt(2 * gm * keplerPeriapsisRadius(a, e));
  }
  if (e > 1) return math.sqrt(gm * a * (e * e - 1));
  return math.sqrt(gm * a * (1 - e * e));
}

String keplerOrbitKindLabel(double e) {
  if (keplerIsParabola(e)) return '放物線';
  if (e > 1) return '双曲線';
  return '楕円';
}

double keplerPhaseToMeanAnomaly(double phase) {
  final frac = phase - phase.floorToDouble();
  final wrapped = frac < 0 ? frac + 1 : frac;
  return 2 * math.pi * wrapped;
}

/// ケプラー方程式 $nt = u - e\sin u$ を $u$ について解く。
double solveKeplerEccentricAnomaly(double meanAnomaly, double e) {
  var m = meanAnomaly % (2 * math.pi);
  if (m < 0) m += 2 * math.pi;
  var u = m;
  for (int i = 0; i < 20; i++) {
    final sinU = math.sin(u);
    final cosU = math.cos(u);
    final f = u - e * sinU - m;
    final fp = 1 - e * cosU;
    final du = f / fp;
    u -= du;
    if (du.abs() < 1e-14) break;
  }
  return u;
}

double keplerSemiMajorFromPeriapsis(
  double rMin,
  double vPeri, {
  double gm = kKeplerGM,
}) {
  final invA = 2 / rMin - vPeri * vPeri / gm;
  return 1 / invA;
}

double keplerEccentricityFromPeriapsis(double rMin, double a) => 1 - rMin / a;

class KeplerOrbitState {
  const KeplerOrbitState({
    required this.a,
    required this.e,
    required this.phase,
    required this.u,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    this.gm = kKeplerGM,
  });

  final double a;
  final double e;
  final double phase;
  final double u;
  final double x;
  final double y;
  final double vx;
  final double vy;
  final double gm;

  double get r => math.sqrt(x * x + y * y);
  double get speed => math.sqrt(vx * vx + vy * vy);
  double get theta => math.atan2(y, x);
  double get period => keplerPeriod(a, gm: gm);
  double get time => phase * period;
  double get b => keplerSemiMinor(a, e);
  double get periapsisX => keplerPeriapsisRadius(a, e);
  double get apoapsisX => -keplerApoapsisRadius(a, e);

  /// 楕円は太陽の反対側、双曲線は近日点の外側。放物線に空の焦点はない。
  double? get emptyFocusX {
    if (keplerIsParabola(e) || e <= 0.04) return null;
    if (e > 1) return 2 * a * e;
    return -2 * a * e;
  }
}

/// エネルギーゲージ用の力学的エネルギー。
///
/// 真のポテンシャル $U=-GMm/r$ と力学的エネルギー $E=K+U$ は楕円で負なので、
/// ゲージには出さない。代わりに近日点 $r_{\min}$ を位置エネルギーの 0 にした
/// $$U'=GMm\left(\frac{1}{r_{\min}}-\frac{1}{r}\right)=U(r)-U(r_{\min})$$
/// を緑帯にする。これは近日点から現在の距離まで質量を準静的に運ぶのに
/// 外力がする仕事（位置エネルギーの増分）に等しい。枠の長さは近日点の
/// 運動エネルギーで、軌道上では $K+U'$ が一定（=近日点の $K$）になる。
EnergyLedger keplerMechanicalLedger(KeplerOrbitState state, {double mass = 1}) {
  final rMin = math.max(keplerPeriapsisRadius(state.a, state.e), 1e-9);
  final r = math.max(state.r, 1e-9);
  final potential = mass * state.gm * (1 / rMin - 1 / r);
  final kinetic = 0.5 * mass * state.speed * state.speed;
  final periSpeed = keplerPeriapsisSpeed(state.a, state.e, gm: state.gm);
  final scale = 0.5 * mass * periSpeed * periSpeed;
  return EnergyLedger(
    kinetic: kinetic,
    potential: math.max(0, potential),
    dissipated: 0,
    scale: scale,
    potentialLabel: kLabelGravitation,
  );
}

({double x, double y}) keplerVelocityArrowOffset(KeplerOrbitState s) {
  return (
    x: s.vx * kKeplerVelocityArrowScale,
    y: s.vy * kKeplerVelocityArrowScale,
  );
}

/// 単位質量あたりの重力加速度。向きは焦点（原点）へ、大きさは $GM/r^{2}$。
({double x, double y}) keplerAcceleration(KeplerOrbitState s) {
  final r = s.r;
  if (r < 1e-9) return (x: 0.0, y: 0.0);
  final invR3 = s.gm / (r * r * r);
  return (x: -s.x * invR3, y: -s.y * invR3);
}

KeplerOrbitState evolveKeplerEllipse({
  required double a,
  required double e,
  required double phase,
  double gm = kKeplerGM,
}) {
  final n = keplerMeanMotion(a, gm: gm);
  final mean = keplerPhaseToMeanAnomaly(phase);
  final u = solveKeplerEccentricAnomaly(mean, e);
  final b = keplerSemiMinor(a, e);
  final cosU = math.cos(u);
  final sinU = math.sin(u);
  final uDot = n / (1 - e * cosU);
  return KeplerOrbitState(
    a: a,
    e: e,
    phase: phase,
    u: u,
    x: a * (cosU - e),
    y: b * sinU,
    vx: -a * sinU * uDot,
    vy: b * cosU * uDot,
    gm: gm,
  );
}

double _cbrt(double x) => x.sign * math.pow(x.abs(), 1.0 / 3.0);

double _sinh(double x) {
  final e = math.exp(x);
  return (e - 1 / e) / 2;
}

double _cosh(double x) {
  final e = math.exp(x);
  return (e + 1 / e) / 2;
}

double _acosh(double x) => math.log(x + math.sqrt(x * x - 1));

/// バーカー方程式 $s+s^{3}/3=\tau$。
double solveParabolicAnomaly(double tau) {
  final b = 1.5 * tau;
  final disc = math.sqrt(b * b + 1);
  return _cbrt(b + disc) + _cbrt(b - disc);
}

/// $M=e\sinh H-H$。
double solveHyperbolicAnomaly(double meanAnomaly, double e) {
  if (meanAnomaly.abs() < 1e-14) return 0;
  final sign = meanAnomaly.sign;
  final m = meanAnomaly.abs();
  var h = m < 1 ? m : math.log(2 * m / e + 1.5);
  for (int i = 0; i < 20; i++) {
    final sh = _sinh(h);
    final ch = _cosh(h);
    final f = e * sh - h - m;
    final fp = e * ch - 1;
    final dh = f / fp;
    h -= dh;
    if (dh.abs() < 1e-14) break;
  }
  return sign * h;
}

const double kKeplerBranchRadiusFactor = 6.0;

double keplerHyperbolicAnomalyExtent(double e) {
  final c = (kKeplerBranchRadiusFactor + 1) / math.max(e, 1 + 1e-6);
  return _acosh(math.max(c, 1.0000001));
}

/// 描いた枝の端までの位相。再生はこの範囲を往復する。
double keplerFlybyPhaseLimit(double a, double e, {double gm = kKeplerGM}) {
  if (keplerIsParabola(e)) {
    const sMax = 2.2;
    final tau = sMax + sMax * sMax * sMax / 3;
    final q = keplerPeriapsisRadius(a, e);
    final t = tau * math.sqrt(2 * q * q * q / gm);
    return t / keplerPeriod(a, gm: gm);
  }
  if (e > 1) {
    final h = keplerHyperbolicAnomalyExtent(e);
    final m = e * _sinh(h) - h;
    return m / (2 * math.pi);
  }
  return 0.5;
}

KeplerOrbitState evolveKeplerParabola({
  required double a,
  required double e,
  required double phase,
  double gm = kKeplerGM,
}) {
  final q = keplerPeriapsisRadius(a, e);
  final t = phase * keplerPeriod(a, gm: gm);
  final tau = t * math.sqrt(gm / (2 * q * q * q));
  final s = solveParabolicAnomaly(tau);
  final dsdt = math.sqrt(gm / (2 * q * q * q)) / (1 + s * s);
  return KeplerOrbitState(
    a: a,
    e: e,
    phase: phase,
    u: s,
    x: q * (1 - s * s),
    y: 2 * q * s,
    vx: -2 * q * s * dsdt,
    vy: 2 * q * dsdt,
    gm: gm,
  );
}

KeplerOrbitState evolveKeplerHyperbola({
  required double a,
  required double e,
  required double phase,
  double gm = kKeplerGM,
}) {
  final n = keplerMeanMotion(a, gm: gm);
  final mean = 2 * math.pi * phase;
  final h = solveHyperbolicAnomaly(mean, e);
  final ch = _cosh(h);
  final sh = _sinh(h);
  final hDot = n / (e * ch - 1);
  final b = a * math.sqrt(e * e - 1);
  return KeplerOrbitState(
    a: a,
    e: e,
    phase: phase,
    u: h,
    x: a * (e - ch),
    y: b * sh,
    vx: -a * sh * hDot,
    vy: b * ch * hDot,
    gm: gm,
  );
}

KeplerOrbitState evolveKeplerConic({
  required double a,
  required double e,
  required double phase,
  double gm = kKeplerGM,
}) {
  if (keplerIsParabola(e)) {
    return evolveKeplerParabola(a: a, e: e, phase: phase, gm: gm);
  }
  if (e > 1) {
    return evolveKeplerHyperbola(a: a, e: e, phase: phase, gm: gm);
  }
  return evolveKeplerEllipse(a: a, e: e, phase: phase, gm: gm);
}

/// 軌道の折れ線。楕円は一周、放物線・双曲線は描画範囲の枝。
List<({double x, double y})> keplerConicPoints(
  double a,
  double e, {
  int samples = 180,
}) {
  final pts = <({double x, double y})>[];
  if (keplerIsParabola(e)) {
    const sMax = 2.2;
    final q = keplerPeriapsisRadius(a, e);
    for (int i = 0; i <= samples; i++) {
      final s = -sMax + 2 * sMax * i / samples;
      pts.add((x: q * (1 - s * s), y: 2 * q * s));
    }
    return pts;
  }
  if (e > 1) {
    final hMax = keplerHyperbolicAnomalyExtent(e);
    final b = a * math.sqrt(e * e - 1);
    for (int i = 0; i <= samples; i++) {
      final h = -hMax + 2 * hMax * i / samples;
      pts.add((x: a * (e - _cosh(h)), y: b * _sinh(h)));
    }
    return pts;
  }
  final b = keplerSemiMinor(a, e);
  for (int i = 0; i <= samples; i++) {
    final u = 2 * math.pi * i / samples;
    pts.add((x: a * (math.cos(u) - e), y: b * math.sin(u)));
  }
  return pts;
}

double keplerSweptAreaFromPeriapsis(
  double a,
  double e,
  double phase, {
  double gm = kKeplerGM,
}) {
  if (!keplerIsEllipse(e)) {
    final t = phase * keplerPeriod(a, gm: gm);
    return 0.5 * keplerSpecificAngularMomentum(a, e, gm: gm) * t;
  }
  final frac = phase - phase.floorToDouble();
  final wrapped = frac < 0 ? frac + 1 : frac;
  return 0.5 *
      keplerSpecificAngularMomentum(a, e, gm: gm) *
      wrapped *
      keplerPeriod(a, gm: gm);
}
