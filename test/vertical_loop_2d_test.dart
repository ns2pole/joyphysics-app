import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/verticalLoop2D.dart';

void main() {
  LoopSample runUntil(LoopSim sim, bool Function(LoopSample s) done, {double limit = 30}) {
    var guard = 0;
    while (!done(sim.snapshot()) && sim.t < limit && guard < 5000000) {
      sim.step(sim.dt);
      guard++;
    }
    return sim.snapshot();
  }

  test('H=0.6 は離れず、止まる角度がエネルギーと一致する', () {
    final sim = LoopSim(heightRatio: 0.6);
    final s = runUntil(sim, (s) => s.turnTheta != null);
    final expected = math.acos(1 - 0.6);
    expect(s.leftTheta, isNull);
    expect(s.turnTheta!, closeTo(expected, 0.02));
    expect(s.turnTheta!, inInclusiveRange(0.9, 1.2));
    expect(s.t, inInclusiveRange(0.5, 4.0));
  });

  test('H=1 は右端で止まり、放物運動に入らない', () {
    final sim = LoopSim(heightRatio: 1);
    final s = runUntil(sim, (s) => s.turnTheta != null || s.phase == LoopPhase.flight);
    expect(s.phase, isNot(LoopPhase.flight));
    expect(s.turnTheta!, closeTo(math.pi / 2, 0.03));
  });

  test('離脱角度・飛行時間・着地点が解析解と一致する', () {
    for (final h in [1.2, 1.5, 1.75, 2.0, 2.2, 2.4]) {
      final sim = LoopSim(heightRatio: h);
      final s = runUntil(sim, (s) => s.landT != null || s.finished);
      final mu = 2 * (h - 1) / 3;
      final leave = math.acos(-mu);
      final flight = 4 * math.sqrt(mu * (1 - mu * mu)) * math.sqrt(kLoopR / kLoopG);
      final landX = math.sqrt(1 - mu * mu) * (1 - 4 * mu * mu) * kLoopR;
      final landY = (1 + mu * (4 * mu * mu - 3)) * kLoopR;
      expect(s.leftTheta, isNotNull, reason: 'H=$h');
      expect(s.leftTheta!, closeTo(leave, 0.03), reason: 'H=$h leave');
      expect(s.leaveT, inInclusiveRange(0.3, 5.0));
      expect(s.landT! - s.leaveT!, closeTo(flight, 0.03), reason: 'H=$h flight');
      expect(s.landX!, closeTo(landX, 0.03), reason: 'H=$h x');
      expect(s.landY!, closeTo(landY, 0.03), reason: 'H=$h y');
      expect(s.speed, closeTo(0, 1e-9), reason: '着地直後は v=0');
      expect(s.energy, closeTo(kLoopG * s.landY!, 1e-6));
    }
  });

  test('H=7/4 は最下点で止まり、中心通過と左端着地も合う', () {
    final bottom = LoopSim(heightRatio: kLoopBottomH);
    final b = runUntil(bottom, (s) => s.finished);
    expect(b.landX!, closeTo(0, 0.03));
    expect(b.landY!, closeTo(0, 0.03));
    expect(b.phase, LoopPhase.stopped);
    expect(b.speed, closeTo(0, 1e-9));

    final center = LoopSim(heightRatio: kLoopCenterH);
    final c = runUntil(center, (s) => s.landT != null);
    expect(c.minCenter, lessThan(0.05));
    expect(c.landX!, lessThan(0));

    final left = LoopSim(heightRatio: 1 + 3 * math.sqrt(3) / 4);
    final l = runUntil(left, (s) => s.landT != null);
    expect(l.landX!, closeTo(-kLoopR, 0.04));
    expect(l.landY!, closeTo(kLoopR, 0.04));
  });

  test('右着地は斜面へ戻り、左着地は右の地面へ滑り出す', () {
    final right = LoopSim(heightRatio: 1.5);
    runUntil(right, (s) => s.landT != null);
    final after = runUntil(right, (s) => s.phase == LoopPhase.flatLeft || s.phase == LoopPhase.ramp);
    expect(after.t, greaterThan(right.landT!));
    expect(after.vx, lessThan(0));

    final left = LoopSim(heightRatio: 2.2);
    runUntil(left, (s) => s.landT != null);
    expect(left.landX!, lessThan(0));
    final exit = runUntil(left, (s) => s.phase == LoopPhase.flatRight);
    expect(exit.vx, greaterThan(0));
    expect(exit.y, closeTo(0, 1e-9));
  });

  test('H=2.5 は頂上付近まで N が負にならず、H=3 は一周して右へ出る', () {
    final critical = LoopSim(heightRatio: 2.5);
    final c = runUntil(critical, (s) => s.phase == LoopPhase.flatRight || s.phase == LoopPhase.flight);
    expect(c.phase, LoopPhase.flatRight);
    expect(c.minNormal, greaterThan(-0.08));
    expect(c.minNormal, lessThan(0.15));
    expect(c.speed, closeTo(math.sqrt(2 * kLoopG * 2.5 * kLoopR), 0.08));

    final full = LoopSim(heightRatio: 3);
    final before = full.energy;
    final f = runUntil(full, (s) => s.phase == LoopPhase.flatRight);
    expect(f.leftTheta, isNull);
    expect(f.minNormal, greaterThan(0.5));
    expect(f.entrySpeed!, closeTo(math.sqrt(2 * kLoopG * 3 * kLoopR), 0.05));
    expect(f.speed, closeTo(math.sqrt(2 * kLoopG * 3 * kLoopR), 0.08));
    expect(f.energy, closeTo(before, 0.05));
    final end = runUntil(full, (s) => s.finished);
    expect(end.x, greaterThanOrEqualTo(kLoopRightStopX * kLoopR - 0.05));
    expect(end.finished, isTrue);
  });

  test('レール上と空中ではエネルギーがほぼ保存される', () {
    final sim = LoopSim(heightRatio: 2.0);
    final e0 = sim.energy;
    runUntil(sim, (s) => s.phase == LoopPhase.flight);
    expect(sim.energy, closeTo(e0, 0.02));
    runUntil(sim, (s) => s.landT != null);
    expect(sim.snapshot().speed, closeTo(0, 1e-9));
  });

  test('往復は 100 回で止まる', () {
    final sim = LoopSim(heightRatio: 0.6, dt: 5e-4);
    final s = runUntil(sim, (s) => s.finished, limit: 400);
    expect(s.roundTrips, kLoopMaxTrips);
    expect(s.finished, isTrue);
    expect(s.t, greaterThan(10));
  });

  test('円運動の実験に登録されている', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final circular = dynamics.subcategories.firstWhere((s) => s.name == '円運動');
    expect(circular.videos, contains(verticalLoop2D));
  });
}
