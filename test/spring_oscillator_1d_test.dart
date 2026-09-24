import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/springOscillator1D.dart';

void main() {
  const horizontal = HorizontalSpringParams(
    m: kSpringDefaultM,
    k: kSpringDefaultK,
  );
  const vertical = VerticalSpringParams(
    m: kSpringDefaultM,
    k: kSpringDefaultK,
    g: kVerticalSpringDefaultG,
  );

  test('標準のおもりとはねは周期 0.7 s 前後', () {
    final expected = 2 * math.pi * math.sqrt(kSpringDefaultM / kSpringDefaultK);
    expect(horizontal.period, closeTo(expected, 1e-12));
    expect(vertical.period, closeTo(horizontal.period, 1e-12));
    expect(horizontal.period, inInclusiveRange(0.6, 0.9));
    expect(kVerticalSpringDefaultG, 9.8);
  });

  test('水平ばねは T/4 でつりあい、T/2 で反対側の端に着く', () {
    final period = horizontal.period;
    final omega = horizontal.omega;
    final amplitude = kHorizontalSpringAmplitude;

    final start = horizontalSpringAt(horizontal, 0);
    expect(start.xi, closeTo(amplitude, 1e-12));
    expect(start.v, closeTo(0, 1e-12));
    expect(start.a, closeTo(-omega * omega * amplitude, 1e-12));

    final quarter = horizontalSpringAt(horizontal, period / 4);
    expect(quarter.t, inInclusiveRange(0.15, 0.25));
    expect(quarter.xi, closeTo(0, 1e-9));
    expect(quarter.v, closeTo(-amplitude * omega, 1e-9));
    expect(quarter.v.abs(), inInclusiveRange(0.5, 1.5));

    final half = horizontalSpringAt(horizontal, period / 2);
    expect(half.t, inInclusiveRange(0.3, 0.5));
    expect(half.xi, closeTo(-amplitude, 1e-9));
    expect(half.v, closeTo(0, 1e-9));
    expect(half.x, greaterThan(0.25));

    for (var i = 0; i <= 16; i++) {
      final s = horizontalSpringAt(horizontal, period * i / 16);
      expect(s.xi.abs(), lessThanOrEqualTo(amplitude + 1e-9));
      expect(s.x, inInclusiveRange(0.25, 0.55));
    }
  });

  test('スライダーの端でも水平ばねの周期は 1 秒前後、速さは歩行程度', () {
    const corners = [
      HorizontalSpringParams(m: kSpringMinM, k: kSpringMaxK),
      HorizontalSpringParams(m: kSpringMaxM, k: kSpringMinK),
      HorizontalSpringParams(m: kSpringMinM, k: kSpringMinK),
      HorizontalSpringParams(m: kSpringMaxM, k: kSpringMaxK),
    ];
    for (final params in corners) {
      expect(params.period, inInclusiveRange(0.35, 1.2));
      final fastest = horizontalSpringAt(params, params.period / 4);
      expect(fastest.xi.abs(), lessThan(1e-8));
      expect(fastest.v.abs(), closeTo(kHorizontalSpringAmplitude * params.omega, 1e-9));
      expect(fastest.v.abs(), inInclusiveRange(0.4, 2.0));
      final far = horizontalSpringAt(params, params.period / 2);
      expect(far.xi, closeTo(-kHorizontalSpringAmplitude, 1e-9));
      expect(far.x, greaterThan(0.20));
    }
  });

  test('鉛直ばねは T/4 でつりあい、T/2 で最下点。初めの加速度は g', () {
    final period = vertical.period;
    final delta = vertical.delta;
    expect(delta, closeTo(kSpringDefaultM * 9.8 / kSpringDefaultK, 1e-12));
    expect(delta, inInclusiveRange(0.08, 0.18));

    final start = verticalSpringAt(vertical, 0);
    expect(start.y, closeTo(kVerticalSpringEll, 1e-12));
    expect(start.v, closeTo(0, 1e-12));
    expect(start.a, closeTo(9.8, 1e-9));

    final quarter = verticalSpringAt(vertical, period / 4);
    expect(quarter.t, inInclusiveRange(0.15, 0.25));
    expect(quarter.xi, closeTo(0, 1e-9));
    expect(quarter.y, closeTo(kVerticalSpringEll + delta, 1e-9));
    expect(quarter.v, closeTo(delta * vertical.omega, 1e-9));
    expect(quarter.v, inInclusiveRange(0.5, 2.0));

    final bottom = verticalSpringAt(vertical, period / 2);
    expect(bottom.t, inInclusiveRange(0.3, 0.5));
    expect(bottom.v, closeTo(0, 1e-9));
    expect(bottom.a, closeTo(-9.8, 1e-9));
    expect(bottom.extensionOf(vertical), closeTo(2 * delta, 1e-9));
    expect(bottom.extensionOf(vertical), inInclusiveRange(0.15, 0.40));
    expect(bottom.y, inInclusiveRange(0.45, 0.80));
  });

  test('g を変えても周期は同じで、最下点だけが mg/k に従う', () {
    const halfG = VerticalSpringParams(
      m: kSpringDefaultM,
      k: kSpringDefaultK,
      g: 4.9,
    );
    expect(halfG.period, closeTo(vertical.period, 1e-12));
    expect(halfG.delta, closeTo(vertical.delta / 2, 1e-12));

    final earthBottom = verticalSpringAt(vertical, vertical.period / 2);
    final halfBottom = verticalSpringAt(halfG, halfG.period / 2);
    expect(
      earthBottom.extensionOf(vertical),
      closeTo(2 * halfBottom.extensionOf(halfG), 1e-9),
    );
    expect(halfBottom.y, inInclusiveRange(kVerticalSpringEll, 0.70));
    expect(verticalSpringAt(halfG, 0).a, closeTo(4.9, 1e-9));

    const noG = VerticalSpringParams(
      m: kSpringDefaultM,
      k: kSpringDefaultK,
      g: 0,
    );
    expect(noG.period, closeTo(vertical.period, 1e-12));
    expect(noG.delta, closeTo(0, 1e-12));
    final still = verticalSpringAt(noG, noG.period / 2);
    expect(still.y, closeTo(kVerticalSpringEll, 1e-12));
    expect(still.v, closeTo(0, 1e-12));
    expect(verticalSpringAt(noG, 0).a, closeTo(0, 1e-12));
  });

  test('スライダーの端でも鉛直ばねは数十 cm 以内で、1 秒前後に戻る', () {
    const corners = [
      VerticalSpringParams(m: kSpringMinM, k: kSpringMaxK, g: kVerticalSpringMinG),
      VerticalSpringParams(m: kSpringMaxM, k: kSpringMinK, g: kVerticalSpringMaxG),
      VerticalSpringParams(m: kSpringMinM, k: kSpringMinK, g: kVerticalSpringMaxG),
      VerticalSpringParams(m: kSpringMaxM, k: kSpringMaxK, g: kVerticalSpringMinG),
    ];
    for (final params in corners) {
      expect(params.period, inInclusiveRange(0.35, 1.2));
      expect(params.delta, inInclusiveRange(0, 0.35));

      final start = verticalSpringAt(params, 0);
      expect(start.a, closeTo(params.g, 1e-9));
      expect(start.y, closeTo(kVerticalSpringEll, 1e-12));

      final bottom = verticalSpringAt(params, params.period / 2);
      expect(bottom.extensionOf(params), closeTo(2 * params.delta, 1e-9));
      expect(bottom.extensionOf(params), lessThan(0.70));
      expect(bottom.y, lessThan(1.1));

      for (var i = 0; i <= 8; i++) {
        final s = verticalSpringAt(params, params.period * i / 8);
        expect(s.y, inInclusiveRange(kVerticalSpringEll - 1e-9, bottom.y + 1e-9));
      }
    }
  });

  test('質量が大きいほど球は大きく、ばね定数が大きいほど線は太い', () {
    expect(springMassRadius(kSpringMinM), lessThan(springMassRadius(kSpringDefaultM)));
    expect(springMassRadius(kSpringDefaultM), lessThan(springMassRadius(kSpringMaxM)));
    expect(springMassRadius(kSpringMaxM) / springMassRadius(kSpringMinM), greaterThan(1.8));

    expect(springWireWidth(kSpringMinK), lessThan(springWireWidth(kSpringDefaultK)));
    expect(springWireWidth(kSpringDefaultK), lessThan(springWireWidth(kSpringMaxK)));
    expect(springCoilAmp(kSpringMaxK), greaterThan(springCoilAmp(kSpringMinK)));
  });

  test('初速度は左右どちらでも、t=0 の位置は右端のまま', () {
    const right = HorizontalSpringParams(
      m: kSpringDefaultM,
      k: kSpringDefaultK,
      v0: 0.80,
    );
    const left = HorizontalSpringParams(
      m: kSpringDefaultM,
      k: kSpringDefaultK,
      v0: -0.80,
    );
    final rightStart = horizontalSpringAt(right, 0);
    final leftStart = horizontalSpringAt(left, 0);
    expect(rightStart.xi, closeTo(kHorizontalSpringAmplitude, 1e-12));
    expect(leftStart.xi, closeTo(kHorizontalSpringAmplitude, 1e-12));
    expect(rightStart.v, closeTo(0.80, 1e-12));
    expect(leftStart.v, closeTo(-0.80, 1e-12));
    expect(springVelocityReadout(rightStart.v, downwardPositive: false), '0.80 右');
    expect(springVelocityReadout(leftStart.v, downwardPositive: false), '-0.80 左');

    final rightAmp = springMotionAmplitude(
      kHorizontalSpringAmplitude,
      right.v0,
      right.omega,
    );
    final leftAmp = springMotionAmplitude(
      kHorizontalSpringAmplitude,
      left.v0,
      left.omega,
    );
    expect(right.period, closeTo(horizontal.period, 1e-12));
    expect(left.period, closeTo(horizontal.period, 1e-12));
    for (var i = 0; i <= 16; i++) {
      final rs = horizontalSpringAt(right, right.period * i / 16);
      final ls = horizontalSpringAt(left, left.period * i / 16);
      expect(rs.xi.abs(), lessThanOrEqualTo(rightAmp + 1e-9));
      expect(ls.xi.abs(), lessThanOrEqualTo(leftAmp + 1e-9));
      expect(rs.x, greaterThan(0.15));
      expect(ls.x, greaterThan(0.15));
      expect(rs.x, lessThan(0.80));
      expect(ls.x, lessThan(0.80));
    }
  });

  test('鉛直ばねの初速度は上でも下でも、t=0 は自然長', () {
    const down = VerticalSpringParams(
      m: kSpringDefaultM,
      k: kSpringDefaultK,
      g: kVerticalSpringDefaultG,
      v0: 0.80,
    );
    const up = VerticalSpringParams(
      m: kSpringDefaultM,
      k: kSpringDefaultK,
      g: kVerticalSpringDefaultG,
      v0: -0.80,
    );
    final downStart = verticalSpringAt(down, 0);
    final upStart = verticalSpringAt(up, 0);
    expect(downStart.y, closeTo(kVerticalSpringEll, 1e-12));
    expect(upStart.y, closeTo(kVerticalSpringEll, 1e-12));
    expect(downStart.v, closeTo(0.80, 1e-12));
    expect(upStart.v, closeTo(-0.80, 1e-12));
    expect(downStart.a, closeTo(9.8, 1e-9));
    expect(upStart.a, closeTo(9.8, 1e-9));
    expect(springVelocityReadout(downStart.v, downwardPositive: true), '0.80 下');
    expect(springVelocityReadout(upStart.v, downwardPositive: true), '-0.80 上');
    expect(down.period, closeTo(vertical.period, 1e-12));
    expect(up.period, closeTo(vertical.period, 1e-12));

    final downAmp = springMotionAmplitude(down.delta, down.v0, down.omega);
    final upAmp = springMotionAmplitude(up.delta, up.v0, up.omega);
    var downMin = downStart.y;
    var upMin = upStart.y;
    var downMax = downStart.y;
    var upMax = upStart.y;
    for (var i = 0; i <= 24; i++) {
      final ds = verticalSpringAt(down, down.period * i / 24);
      final us = verticalSpringAt(up, up.period * i / 24);
      expect((ds.y - (kVerticalSpringEll + down.delta)).abs(), lessThanOrEqualTo(downAmp + 1e-9));
      expect((us.y - (kVerticalSpringEll + up.delta)).abs(), lessThanOrEqualTo(upAmp + 1e-9));
      expect(ds.y, greaterThan(0.05));
      expect(us.y, greaterThan(0.05));
      downMin = math.min(downMin, ds.y);
      upMin = math.min(upMin, us.y);
      downMax = math.max(downMax, ds.y);
      upMax = math.max(upMax, us.y);
    }
    expect(downMin, lessThan(kVerticalSpringEll));
    expect(upMin, lessThan(kVerticalSpringEll));
    expect(downMax, greaterThan(kVerticalSpringEll + 2 * down.delta));
    expect(upMax, greaterThan(kVerticalSpringEll + 2 * up.delta));
  });

  test('初期位置と初速度 ±3 は t=0 にそのまま乗る', () {
    final horizontal = HorizontalSpringParams.fromMap({
      'm': kSpringDefaultM,
      'k': kSpringDefaultK,
      'x0': -0.12,
      'v0': 3,
    });
    expect(horizontal.x0, -0.12);
    expect(horizontal.v0, 3);
    final h0 = horizontalSpringAt(horizontal, 0);
    expect(h0.xi, closeTo(-0.12, 1e-12));
    expect(h0.v, closeTo(3, 1e-12));
    expect(
      HorizontalSpringParams.fromMap({'m': 0.2, 'k': 16, 'v0': 9}).v0,
      kSpringMaxV0,
    );

    final vertical = VerticalSpringParams.fromMap({
      'm': kSpringDefaultM,
      'k': kSpringDefaultK,
      'g': kVerticalSpringDefaultG,
      'y0': 0.55,
      'v0': -3,
    });
    expect(vertical.y0, 0.55);
    expect(vertical.v0, -3);
    final v0 = verticalSpringAt(vertical, 0);
    expect(v0.y, closeTo(0.55, 1e-12));
    expect(v0.v, closeTo(-3, 1e-12));
    expect(vertical.period, closeTo(horizontal.period, 1e-12));
  });

  test('力学のバネに水平バネと鉛直バネがある', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final springs = dynamics.subcategories.firstWhere((s) => s.name == 'バネ');
    expect(springs.videos, contains(horizontalSpring1D));
    expect(springs.videos, contains(verticalSpring1D));
    final falling = dynamics.subcategories.firstWhere((s) => s.name == '落下運動');
    expect(falling.videos, isNot(contains(horizontalSpring1D)));
    expect(falling.videos, isNot(contains(verticalSpring1D)));
    final pendulum = dynamics.subcategories.firstWhere((s) => s.name == '振り子');
    expect(pendulum.videos, isNot(contains(horizontalSpring1D)));
    expect(pendulum.videos, isNot(contains(verticalSpring1D)));
  });
}
