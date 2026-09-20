import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/waves/animations/1d/coupled_oscillator_transverse_physics.dart';

void main() {
  test('固有モードは両端で 0', () {
    for (final nMasses in [2, 5, 12, 50, 100]) {
      for (int n = 1; n <= nMasses; n++) {
        expect(coupledModeShape(n, 0, nMasses), closeTo(0, 1e-12));
        expect(coupledModeShape(n, nMasses + 1, nMasses), closeTo(0, 1e-12));
      }
    }
  });

  test('t=0 は初期変位・速度に戻る', () {
    const y0 = [0.4, -0.2, 0.7, 0.1];
    const v0 = [0.3, 0.0, -0.5, 0.2];
    final modes = projectCoupledOscillator(y0: y0, v0: v0);
    final snap = evolveCoupledOscillator(modes, 0);
    for (int i = 0; i < y0.length; i++) {
      expect(snap.y[i], closeTo(y0[i], 1e-12));
      expect(snap.v[i], closeTo(v0[i], 1e-12));
    }
  });

  test('単一モードは1周期後に形が戻る', () {
    const nMasses = 5;
    const n = 2;
    final y0 = coupledModeDisplacements(n, nMasses);
    final v0 = List<double>.filled(nMasses, 0);
    final modes = projectCoupledOscillator(y0: y0, v0: v0);
    final period = 2 * math.pi / coupledModeOmega(n, nMasses);
    final snap = evolveCoupledOscillator(modes, period);
    for (int i = 0; i < nMasses; i++) {
      expect(snap.y[i], closeTo(y0[i], 1e-9));
      expect(snap.v[i], closeTo(0, 1e-9));
    }
    expect(dominantModeIndex(modes), 2);
  });

  test('N=2 の1次モードは同相', () {
    final y = coupledModeDisplacements(1, 2);
    expect(y[0], closeTo(y[1], 1e-12));
    expect(y[0], greaterThan(0));
  });

  test('N は 2 から 100、初期は 50', () {
    expect(kCoupledOscillatorMinN, 2);
    expect(kCoupledOscillatorMaxN, 100);
    expect(kCoupledOscillatorDefaultN, 50);
  });

  test('ばね定数を上げると伝播が速くなる', () {
    expect(kCoupledOscillatorK, 100);
    final slow = coupledModeOmega(1, 50, k: 4);
    final fast = coupledModeOmega(1, 50);
    expect(fast / slow, closeTo(5, 1e-12));
  });

  test('N=100 でも1質点変位の初期形が t=0 で戻る', () {
    final y0 = List<double>.filled(kCoupledOscillatorMaxN, 0.0);
    y0[0] = kCoupledOscillatorAmplitude;
    final v0 = List<double>.filled(kCoupledOscillatorMaxN, 0.0);
    final modes = projectCoupledOscillator(y0: y0, v0: v0);
    final snap = evolveCoupledOscillator(modes, 0);
    expect(snap.y[0], closeTo(kCoupledOscillatorAmplitude, 1e-10));
    for (int i = 1; i < kCoupledOscillatorMaxN; i++) {
      expect(snap.y[i], closeTo(0, 1e-10));
    }
  });
}
