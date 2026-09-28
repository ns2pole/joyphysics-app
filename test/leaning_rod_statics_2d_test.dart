import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/leaningRodStatics2D.dart';

void main() {
  test('滑らかな壁では μs ≥ (1/2)tanθ が静止条件（θは壁との角）', () {
    // 壁角 45° ↔ 床角 45°。必要 μs = 0.5
    const held = LeaningRodParams(thetaDeg: 45, muK: 0.20, muS: 0.50);
    const slip = LeaningRodParams(thetaDeg: 45, muK: 0.20, muS: 0.40);
    expect(leaningRodHolds(held), isTrue);
    expect(leaningRodHolds(slip), isFalse);

    final r = leaningRodStaticsReactions(held);
    expect(r.nf, closeTo(held.weight, 1e-9));
    expect(r.ff, closeTo(held.weight / 2, 1e-9));
    expect(r.nw, closeTo(r.ff, 1e-9));
  });

  test('限界角は arctan(2μs)（壁との角）', () {
    const muS = 0.40;
    final thetaCrit = leaningRodCriticalThetaDeg(muS)!;
    expect(thetaCrit, closeTo(math.atan(2 * muS) * 180 / math.pi, 1e-12));
    final atLimit = LeaningRodParams(thetaDeg: thetaCrit, muK: 0.20, muS: muS);
    // 壁角が大きいほど寝て滑りやすい
    final steeper = LeaningRodParams(thetaDeg: thetaCrit - 5, muK: 0.20, muS: muS);
    final flatter = LeaningRodParams(thetaDeg: thetaCrit + 5, muK: 0.20, muS: muS);
    expect(leaningRodHolds(atLimit), isTrue);
    expect(leaningRodHolds(steeper), isTrue);
    expect(leaningRodHolds(flatter), isFalse);
  });

  test('デフォルトは静止し、θ（壁角）を上げると滑る', () {
    final held = LeaningRodParams.fromMap(const {
      'theta': kLeaningRodDefaultTheta,
      'mu': kLeaningRodDefaultMuK,
      'muS': kLeaningRodDefaultMuS,
    });
    expect(leaningRodHolds(held), isTrue);
    final sample = leaningRodAt(held, 1);
    expect(sample.phase, LeaningRodPhase.equilibrium);

    // 壁角 55° ↔ 旧床角 35°
    const slip = LeaningRodParams(
      thetaDeg: 55,
      muK: kLeaningRodDefaultMuK,
      muS: kLeaningRodDefaultMuS,
    );
    expect(leaningRodHolds(slip), isFalse);
  });

  test('μk=0 の壁離れは cosθ = (2/3)cosθ0（θは壁角）', () {
    // 壁角 30° ↔ 旧床角 60°
    const theta0WallDeg = 30.0;
    const params = LeaningRodParams(thetaDeg: theta0WallDeg, muK: 0.0, muS: 0.15);
    expect(leaningRodHolds(params), isFalse);

    final theta0Floor = params.thetaFloor;
    final expectLeaveFloor = leaningRodFrictionlessLeaveTheta(theta0Floor);
    final both = leaningRodSlidingBothIntegrate(params, 20.0, dt: 5e-4);
    expect(both.leaveT, isNotNull);
    expect(both.state.theta, closeTo(expectLeaveFloor, 2e-2));
    expect(both.state.nw, lessThan(0.05));
  });

  test('滑ると両端接触→壁離れ→倒れの順になる', () {
    // 壁角 40° ↔ 旧床角 50°
    const params = LeaningRodParams(thetaDeg: 40, muK: 0.10, muS: 0.25);
    expect(leaningRodHolds(params), isFalse);

    final early = leaningRodAt(params, 0.05);
    expect(early.phase, LeaningRodPhase.slidingBoth);
    expect(early.nw, greaterThan(0));

    final runtime = LeaningRodRuntime(params);
    var sawAfter = false;
    var sawFlat = false;
    for (var i = 0; i < 20000; i++) {
      runtime.step(1e-3);
      if (runtime.phase == LeaningRodPhase.afterLeave) {
        sawAfter = true;
        expect(runtime.sample.xB, greaterThanOrEqualTo(-1e-6));
      }
      if (runtime.phase == LeaningRodPhase.flat) {
        sawFlat = true;
        break;
      }
    }
    expect(sawAfter, isTrue);
    expect(sawFlat, isTrue);
    expect(runtime.leaveT, isNotNull);
    expect(runtime.sample.theta, lessThan(0.1));
  });

  test('摩擦ゼロでは静止できない', () {
    const params = LeaningRodParams(thetaDeg: 30, muK: 0, muS: 0.15);
    expect(leaningRodHolds(params), isFalse);
  });

  test('滑る Auto の形は静止し、目標 θ では滑る', () {
    final shape = leaningRodDemoShape(LeaningRodDemo.slip);
    final start = LeaningRodParams.fromMap(shape);
    expect(leaningRodHolds(start), isTrue);
    final targetDeg = leaningRodDemoThetaDeg(start);
    expect(targetDeg, greaterThan(start.thetaDeg));
    final atTarget = LeaningRodParams(
      thetaDeg: targetDeg,
      muK: start.muK,
      muS: start.muS,
    );
    expect(leaningRodHolds(atTarget), isFalse);
  });

  test('剛体カテゴリに立て掛け棒が入っている', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final rigid = dynamics.subcategories.firstWhere((s) => s.name == '剛体');
    expect(rigid.videos.contains(leaningRodStatics2D), isTrue);
  });
}
