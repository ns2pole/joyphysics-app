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

double keplerPeriapsisRadius(double a, double e) => a * (1 - e);

double keplerApoapsisRadius(double a, double e) => a * (1 + e);

double keplerPeriapsisSpeed(double a, double e, {double gm = kKeplerGM}) =>
    math.sqrt(gm * (1 + e) / (a * (1 - e)));

double keplerSpecificAngularMomentum(double a, double e,
        {double gm = kKeplerGM}) =>
    math.sqrt(gm * a * (1 - e * e));

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
  double get emptyFocusX => -2 * a * e;
}

/// 近日点を位置エネルギーの 0 にする。$K+U'$ は軌道上で一定。
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

double keplerSweptAreaFromPeriapsis(
  double a,
  double e,
  double phase, {
  double gm = kKeplerGM,
}) {
  final frac = phase - phase.floorToDouble();
  final wrapped = frac < 0 ? frac + 1 : frac;
  return 0.5 *
      keplerSpecificAngularMomentum(a, e, gm: gm) *
      wrapped *
      keplerPeriod(a, gm: gm);
}
