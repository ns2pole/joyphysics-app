import 'dart:math' as math;

const int kCoupledOscillatorMinN = 2;
const int kCoupledOscillatorMaxN = 100;
const int kCoupledOscillatorDefaultN = 50;
const int kCoupledOscillatorLongitudinalMaxN = 50;
const int kCoupledOscillatorLongitudinalDefaultN = 30;
const double kCoupledOscillatorMass = 1.0;
const double kCoupledOscillatorK = 100.0;
const double kCoupledOscillatorAmplitude = 0.8;
const double kCoupledOscillatorLongitudinalAmplitude = 0.75;
const double kCoupledOscillatorLongitudinalPadX = 0;

double coupledModeOmega(
  int n,
  int nMasses, {
  double k = kCoupledOscillatorK,
  double mass = kCoupledOscillatorMass,
}) {
  return 2 *
      math.sqrt(k / mass) *
      math.sin(n * math.pi / (2 * (nMasses + 1)));
}

double coupledModeShape(int n, int j, int nMasses) {
  return math.sin(n * math.pi * j / (nMasses + 1));
}

List<double> coupledModeDisplacements(
  int n,
  int nMasses, {
  double amplitude = kCoupledOscillatorAmplitude,
}) {
  return [
    for (int j = 1; j <= nMasses; j++)
      amplitude * coupledModeShape(n, j, nMasses),
  ];
}

class CoupledOscillatorModes {
  const CoupledOscillatorModes({
    required this.nMasses,
    required this.a,
    required this.b,
    this.k = kCoupledOscillatorK,
    this.mass = kCoupledOscillatorMass,
  });

  final int nMasses;
  final List<double> a;
  final List<double> b;
  final double k;
  final double mass;
}

CoupledOscillatorModes projectCoupledOscillator({
  required List<double> y0,
  required List<double> v0,
  double k = kCoupledOscillatorK,
  double mass = kCoupledOscillatorMass,
}) {
  final nMasses = y0.length;
  final a = List<double>.filled(nMasses, 0);
  final b = List<double>.filled(nMasses, 0);
  final norm = 2.0 / (nMasses + 1);
  for (int n = 1; n <= nMasses; n++) {
    var projY = 0.0;
    var projV = 0.0;
    for (int j = 1; j <= nMasses; j++) {
      final s = coupledModeShape(n, j, nMasses);
      projY += y0[j - 1] * s;
      projV += v0[j - 1] * s;
    }
    a[n - 1] = norm * projY;
    final omega = coupledModeOmega(n, nMasses, k: k, mass: mass);
    b[n - 1] = omega == 0 ? 0.0 : norm * projV / omega;
  }
  return CoupledOscillatorModes(
    nMasses: nMasses,
    a: a,
    b: b,
    k: k,
    mass: mass,
  );
}

class CoupledOscillatorSnapshot {
  const CoupledOscillatorSnapshot({
    required this.y,
    required this.v,
  });

  final List<double> y;
  final List<double> v;
}

CoupledOscillatorSnapshot evolveCoupledOscillator(
  CoupledOscillatorModes modes,
  double t,
) {
  final nMasses = modes.nMasses;
  final y = List<double>.filled(nMasses, 0);
  final v = List<double>.filled(nMasses, 0);
  for (int n = 1; n <= nMasses; n++) {
    final omega = coupledModeOmega(n, nMasses, k: modes.k, mass: modes.mass);
    final c = math.cos(omega * t);
    final s = math.sin(omega * t);
    final amp = modes.a[n - 1] * c + modes.b[n - 1] * s;
    final ampDot = -modes.a[n - 1] * omega * s + modes.b[n - 1] * omega * c;
    for (int j = 1; j <= nMasses; j++) {
      final shape = coupledModeShape(n, j, nMasses);
      y[j - 1] += amp * shape;
      v[j - 1] += ampDot * shape;
    }
  }
  return CoupledOscillatorSnapshot(y: y, v: v);
}

int? dominantModeIndex(CoupledOscillatorModes modes, {double ratio = 0.92}) {
  var energy = 0.0;
  var best = 0;
  var bestAmp2 = 0.0;
  for (int n = 0; n < modes.nMasses; n++) {
    final amp2 = modes.a[n] * modes.a[n] + modes.b[n] * modes.b[n];
    energy += amp2;
    if (amp2 > bestAmp2) {
      bestAmp2 = amp2;
      best = n;
    }
  }
  if (energy < 1e-12) return null;
  if (bestAmp2 / energy < ratio) return null;
  return best + 1;
}
