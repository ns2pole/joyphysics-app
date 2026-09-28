import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/thermoDynamics/animations/common.dart';
import 'package:joyphysics/experiment/waves/animations/1d/Beating1D.dart';
import 'package:joyphysics/experiment/waves/animations/2d/DispersionHalfPlane2D.dart';
import 'package:joyphysics/experiment/waves/animations/fields/wave_fields.dart';

void main() {
  test('円形波の腹線・節線は位相差込みの経路差', () {
    const lambda = 2.0;
    const a = 1.2;
    const x = 3.0;
    const y = 0.4;
    final r1 = math.sqrt(x * x + (y - a) * (y - a));
    final r2 = math.sqrt(x * x + (y + a) * (y + a));
    final phiBright = -2 * math.pi * (r1 - r2) / lambda;
    final bright = CircularInterferenceField(
      lambda: lambda,
      periodT: 0.7,
      a: a,
      phi: phiBright,
    );
    expect(bright.antinodalMetric(x, y), closeTo(0, 1e-9));

    final dark = CircularInterferenceField(
      lambda: lambda,
      periodT: 0.7,
      a: a,
      phi: phiBright + math.pi,
    );
    expect(dark.nodalMetric(x, y), closeTo(0, 1e-9));
  });

  test('ヤングの腹線は (r1-r2)/λ + φ/2π = m', () {
    const lambda = 0.8;
    const a = 1.0;
    const x = 2.0;
    const y = 1.5;
    final r1 = math.sqrt((x + 4) * (x + 4) + (y - a) * (y - a));
    final r2 = math.sqrt((x + 4) * (x + 4) + (y + a) * (y + a));
    final phi = -2 * math.pi * (r1 - r2) / lambda;
    final field = YoungDoubleSlitField(
      lambda: lambda,
      periodT: 0.7,
      a: a,
      phi: phi,
    );
    expect(field.antinodalMetric(x, y), closeTo(0, 1e-9));
    expect(
      (r1 - r2) / lambda + phi / (2 * math.pi),
      closeTo(0, 1e-9),
    );
  });

  test('うなりは同じ速さで、包絡線の周期は 1/|f1-f2|', () {
    const t1 = 1.6;
    const t2 = 1.8;
    const field = BeatingField(
      amplitude: 0.5,
      lambda: 4.0,
      periodT1: t1,
      periodT2: t2,
      phase2: 0,
    );
    final v1 = field.lambda / t1;
    final v2 = field.lambda2 / t2;
    expect(v2, closeTo(v1, 1e-12));

    const x = 1.25;
    final f1 = 1 / t1;
    final f2 = 1 / t2;
    for (var i = 0; i <= 12; i++) {
      final t = 0.15 * i;
      final y1 = 0.5 * math.sin(2 * math.pi * (f1 * t - x / field.lambda));
      final y2 = 0.5 *
          math.sin(2 * math.pi * (f2 * t - x / field.lambda2));
      expect(field.z(x, 0, t), closeTo(y1 + y2, 1e-9));
    }

    final beat = (f1 - f2).abs();
    final envelope = (double t) =>
        (2 * 0.5 * math.cos(math.pi * (f1 - f2) * t)).abs();
    expect(envelope(1 / beat), closeTo(envelope(0), 1e-9));
    expect(envelope(0.5 / beat), closeTo(0, 1e-9));
  });

  test('半平面の分散はスネルの法則で、境界面で位相がつながる', () {
    const theta = 80 * math.pi / 180;
    final redDeg = snellTheta2(theta, kWaterNRed) * 180 / math.pi;
    final blueDeg = snellTheta2(theta, kWaterNBlue) * 180 / math.pi;
    expect(redDeg, closeTo(47.716, 0.01));
    expect(blueDeg, closeTo(47.435, 0.01));
    expect(redDeg - blueDeg, closeTo(0.281, 0.01));

    final lambdaRed =
        kDispersionLambdaBlue * kWaterLambdaRedNm / kWaterLambdaBlueNm;
    const periodBlue = 0.55;
    final field = HalfPlaneDispersionWaveField(
      theta: theta,
      lambdaRed: lambdaRed,
      periodRed: periodBlue * lambdaRed / kDispersionLambdaBlue,
      nRed: kWaterNRed,
      lambdaBlue: kDispersionLambdaBlue,
      periodBlue: periodBlue,
      nBlue: kWaterNBlue,
    );
    expect(field.lambdaRed / field.periodRed,
        closeTo(field.lambdaBlue / field.periodBlue, 1e-12));

    const y = 0.4;
    const t = 0.35;
    expect(
      field.componentPhase('red', -1e-6, y, t),
      closeTo(field.componentPhase('red', 1e-6, y, t), 1e-4),
    );
    expect(
      field.componentPhase('blue', -1e-6, y, t),
      closeTo(field.componentPhase('blue', 1e-6, y, t), 1e-4),
    );

    double directionDeg(String id, double x) {
      const h = 1e-4;
      final p0 = field.componentPhase(id, x, 0.2, t);
      final gx = (field.componentPhase(id, x + h, 0.2, t) - p0) / h;
      final gy = (field.componentPhase(id, x, 0.2 + h, t) - p0) / h;
      return math.atan2(-gy, -gx) * 180 / math.pi;
    }

    expect(directionDeg('red', -1.5), closeTo(80, 0.05));
    expect(directionDeg('blue', -1.5), closeTo(80, 0.05));
    expect(directionDeg('red', 1.5), closeTo(redDeg, 0.05));
    expect(directionDeg('blue', 1.5), closeTo(blueDeg, 0.05));

    final incident = dispersionRayEnd(angle: theta, intoMedium: false);
    final redRay = dispersionRayEnd(angle: theta, intoMedium: true);
    expect(incident.y, closeTo(-5, 1e-6));
    expect(incident.x, lessThan(0));
    expect(redRay.x, greaterThan(0));
    expect(redRay.x.abs(), lessThanOrEqualTo(5));
    expect(redRay.y.abs(), lessThanOrEqualTo(5));
  });

  test('観測者ドップラーは波に向かうと上がり、波といっしょだと下がる', () {
    const v = 4.0;
    // 左側の観測者が右へ進む = 音源へ向かう。記事の u>0 なら (V+u)/V。
    expect(
      observerDopplerRatio(waveSpeed: v, uParallel: -0.8),
      closeTo((v + 0.8) / v, 1e-12),
    );
    // 波の進む向きの速度が正なら (V-u)/V。
    expect(
      observerDopplerRatio(waveSpeed: v, uParallel: 0.8),
      closeTo((v - 0.8) / v, 1e-12),
    );
  });

  test('薄膜は表面の位相πで、2nL=mλ が反射の弱め合い', () {
    const lambda = 2.0;
    const n = 1.5;
    const t = 20.0;
    final dark = ThinFilmInterference2DField(
      theta: 0,
      lambda: lambda,
      periodT: 1,
      n: n,
      thicknessL: lambda / (2 * n),
    );
    final darkSum = _reflectedSum(dark, t);
    expect(darkSum, closeTo(0, 1e-9));

    final bright = ThinFilmInterference2DField(
      theta: 0,
      lambda: lambda,
      periodT: 1,
      n: n,
      thicknessL: lambda / (4 * n),
    );
    final parts = bright.getComponents(-1, 0, t, {'reflected1', 'reflected2'});
    final a = parts.first.value;
    expect(a.abs(), greaterThan(0.1));
    expect(_reflectedSum(bright, t), closeTo(2 * a, 1e-9));
  });

  test('分子の速さは絶対温度の平方根に比例する', () {
    final room = IdealGasRef.molecularSpeedScale(300);
    final hot = IdealGasRef.molecularSpeedScale(1200);
    expect(room, closeTo(1, 1e-12));
    expect(hot / room, closeTo(2, 1e-12));
    expect(
      IdealGasRef.adiabaticTemperatureK(IdealGasRef.v0L),
      closeTo(IdealGasRef.t0K, 1e-9),
    );
  });
}

double _reflectedSum(ThinFilmInterference2DField field, double t) {
  final parts = field.getComponents(-1, 0, t, {'reflected1', 'reflected2'});
  return parts.fold<double>(0, (sum, part) => sum + part.value);
}
