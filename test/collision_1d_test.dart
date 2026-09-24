import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/dataExporter.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/collision1D.dart';

void main() {
  const equal = Collision1DParams(m: 1, capitalM: 1, e: 1, v: 2.5);

  test('同じ質量の弾性衝突では速度が入れ替わる', () {
    expect(collisionVmPrime(equal), closeTo(0, 1e-12));
    expect(collisionVMPrime(equal), closeTo(2.5, 1e-12));

    final hit = collisionHitTime(equal);
    final before = collision1DAt(equal, hit * 0.5);
    expect(before.collided, isFalse);
    expect(before.xM, closeTo(0, 1e-12));
    expect(before.vM, closeTo(0, 1e-12));
    expect(before.vm, closeTo(2.5, 1e-12));
    expect(before.xm, closeTo(collisionIncomingX0(equal) + 2.5 * before.t, 1e-12));

    final after = collision1DAt(equal, hit + 0.4);
    expect(after.collided, isTrue);
    expect(after.vm, closeTo(0, 1e-12));
    expect(after.vM, closeTo(2.5, 1e-12));
    expect(after.xM, closeTo(1.0, 1e-9));
    expect(after.xm, closeTo(-collisionContactGap(equal), 1e-9));
  });

  test('衝突の瞬間は面が接していて、その前は M が原点にいる', () {
    final hit = collisionHitTime(equal);
    expect(hit, closeTo(kCollisionApproach / 2.5, 1e-12));
    final contact = collision1DAt(equal, hit);
    expect(contact.xM - contact.xm, closeTo(collisionContactGap(equal), 1e-9));
    expect(contact.xM, closeTo(0, 1e-12));
    expect(contact.collided, isTrue);
  });

  test('運動量と反発係数が衝突後も合う', () {
    const cases = [
      Collision1DParams(m: 1, capitalM: 3, e: 0.6, v: 4),
      Collision1DParams(m: 4, capitalM: 0.5, e: 1, v: 1),
      Collision1DParams(m: 2, capitalM: 2, e: 0, v: 3),
    ];
    for (final params in cases) {
      final vm = collisionVmPrime(params);
      final vM = collisionVMPrime(params);
      expect(params.m * params.v, closeTo(params.m * vm + params.capitalM * vM, 1e-9));
      expect(vM - vm, closeTo(params.e * params.v, 1e-9));
      final after = collision1DAt(params, collisionHitTime(params) + 0.3);
      expect(after.vm, closeTo(vm, 1e-12));
      expect(after.vM, closeTo(vM, 1e-12));
      expect(after.xM - after.xm, greaterThanOrEqualTo(collisionContactGap(params) - 1e-9));
    }
  });

  test('e = 0 では同じ速度で接したまま進む', () {
    const params = Collision1DParams(m: 1, capitalM: 3, e: 0, v: 4);
    final common = params.m * params.v / (params.m + params.capitalM);
    expect(collisionVmPrime(params), closeTo(common, 1e-12));
    expect(collisionVMPrime(params), closeTo(common, 1e-12));
    final later = collision1DAt(params, collisionHitTime(params) + 0.8);
    expect(later.xM - later.xm, closeTo(collisionContactGap(params), 1e-9));
  });

  test('軽い方が重い静止物体に弾性衝突すると跳ね返る', () {
    const params = Collision1DParams(m: 0.5, capitalM: 5, e: 1, v: 3);
    expect(collisionVmPrime(params), lessThan(0));
    expect(collisionVMPrime(params), greaterThan(0));
    final later = collision1DAt(params, collisionHitTime(params) + 0.5);
    expect(later.xm, lessThan(-collisionContactGap(params)));
  });

  test('e = 1 では熱が増えず、e が小さいと減った分が熱になる', () {
    const elastic = Collision1DParams(m: 1.5, capitalM: 2.5, e: 1, v: 3);
    final elasticSample = collision1DAt(elastic, collisionHitTime(elastic) + 0.2);
    final elasticLedger = collision1DEnergy(elastic, elasticSample);
    expect(elasticLedger.dissipated, closeTo(0, 1e-9));
    expect(
      elasticLedger.kinetic,
      closeTo(0.5 * elastic.m * elastic.v * elastic.v, 1e-9),
    );

    const soft = Collision1DParams(m: 1.5, capitalM: 2.5, e: 0.5, v: 3);
    final softSample = collision1DAt(soft, collisionHitTime(soft) + 0.2);
    final reduced = soft.m * soft.capitalM / (soft.m + soft.capitalM);
    final heat = 0.5 * reduced * (1 - soft.e * soft.e) * soft.v * soft.v;
    final ledger = collision1DEnergy(soft, softSample);
    expect(ledger.dissipated, closeTo(heat, 1e-9));
    expect(ledger.kinetic + ledger.dissipated, closeTo(ledger.scale, 1e-9));
  });

  test('軸の中に動く物体がいるあいだは止めない', () {
    final hit = collisionHitTime(equal);
    final stillInside = collision1DAt(equal, hit + 1.2);
    expect(collision1DOnStage(equal, stillInside), isTrue);
    expect(stillInside.xM, lessThan(kCollisionViewMax));

    final gone = collision1DAt(equal, hit + 3);
    expect(collision1DOnStage(equal, gone), isFalse);
    expect(gone.xM - collisionHalfWidth(equal.capitalM), greaterThan(kCollisionViewMax));
    expect(gone.t, closeTo(hit + 3, 1e-12));
  });

  test('スライダーの端でも衝突後の速度は有限で、点が時間順に並ぶ', () {
    const corners = [
      Collision1DParams(
        m: kCollisionMinMass,
        capitalM: kCollisionMaxMass,
        e: kCollisionMinE,
        v: kCollisionMinV,
      ),
      Collision1DParams(
        m: kCollisionMaxMass,
        capitalM: kCollisionMinMass,
        e: kCollisionMaxE,
        v: kCollisionMaxV,
      ),
    ];
    for (final params in corners) {
      final vm = collisionVmPrime(params);
      final vM = collisionVMPrime(params);
      expect(vm.isFinite, isTrue);
      expect(vM.isFinite, isTrue);
      expect(vm.abs(), lessThan(20));
      expect(vM.abs(), lessThan(20));
    }
    final strobes = collision1DStrobe(equal, collisionHitTime(equal) + 0.5);
    expect(strobes.length, greaterThan(8));
    for (var i = 1; i < strobes.length; i++) {
      expect(strobes[i].t, greaterThan(strobes[i - 1].t));
    }
    expect(strobes.first.xm, lessThan(0));
  });

  test('力学の衝突に1次元の衝突がある', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final collision = dynamics.subcategories.firstWhere((s) => s.name == '衝突');
    expect(collision.videos.first, collision1D);
    expect(collision1D.title, '1次元の衝突');
    expect(collision.videos, contains(elasticCollision1D));
  });

  test('半分幅は質量の立方根に比例する', () {
    expect(collisionHalfWidth(1), closeTo(kCollisionHalfAt1kg, 1e-12));
    expect(
      collisionHalfWidth(8),
      closeTo(kCollisionHalfAt1kg * math.pow(8, 1 / 3), 1e-12),
    );
  });
}
