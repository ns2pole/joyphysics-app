import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/dynamics/animations/pushedBlock2D.dart';

void main() {
  PushedBlockParams base({
    double w = 0.80,
    double H = 1.20,
    double h = 0.60,
    double F = 3.0,
    double muK = 0.30,
    double muS = 0.50,
  }) {
    return PushedBlockParams(
      width: w,
      height: H,
      pushHeight: h,
      force: F,
      muK: muK,
      muS: muS,
    );
  }

  test('静止限界 Fslide=μs mg と Ftip=mg w/(2h)', () {
    final p = base();
    final st = pushedBlockStatics(p);
    expect(st.fSlide, closeTo(p.muS * p.weight, 1e-12));
    expect(st.fTip, closeTo(p.weight * p.width / (2 * p.pushHeight), 1e-12));
    expect(st.holds, isTrue);
    expect(st.onset, PushedBlockOnset.holds);
  });

  test('F が滑りだけ超えると滑り、転倒だけ超えると転倒', () {
    // h を低く → Ftip 大。F を Fslide 超・Ftip 未満に。
    final slide = base(h: 0.25, F: 6.0, muS: 0.50); // Fslide=4.9, Ftip=9.8*0.8/(0.5)=15.68
    expect(pushedBlockStatics(slide).onset, PushedBlockOnset.slide);

    // h を高く → Ftip 小。F を Ftip 超・Fslide 未満に。
    final tip = base(h: 1.0, F: 4.5, muS: 0.55); // Fslide=5.39, Ftip=9.8*0.8/2=3.92
    expect(pushedBlockStatics(tip).onset, PushedBlockOnset.tip);
  });

  test('両方超えても、先に達する限界が勝つ（滑り→転倒へ跳び移らない）', () {
    // fSlide < fTip、F が両方超え → 滑りのまま
    final slideFirst = base(h: 0.25, F: 20.0, muS: 0.50);
    final stSlide = pushedBlockStatics(slideFirst);
    expect(stSlide.fSlide, lessThan(stSlide.fTip));
    expect(stSlide.onset, PushedBlockOnset.slide);

    // fTip < fSlide、F が両方超え → 転倒のまま
    final tipFirst = base(h: 1.0, F: 20.0, muS: 0.55);
    final stTip = pushedBlockStatics(tipFirst);
    expect(stTip.fTip, lessThan(stTip.fSlide));
    expect(stTip.onset, PushedBlockOnset.tip);
  });

  test('臨界押し高 h=w/(2μs) で滑りと転倒の限界が一致', () {
    final p = base(muS: 0.50);
    final hCrit = pushedBlockCriticalPushHeight(p);
    expect(hCrit, closeTo(p.width / (2 * p.muS), 1e-12));
    final at = base(h: hCrit, F: p.muS * p.weight, muS: 0.50);
    final st = pushedBlockStatics(at);
    expect(st.fSlide, closeTo(st.fTip, 1e-9));
  });

  test('滑り加速度は (F−μk mg)/m で、μk を上げると遅くなる', () {
    final fast = base(h: 0.20, F: 8.0, muK: 0.20, muS: 0.40);
    final slow = base(h: 0.20, F: 8.0, muK: 0.50, muS: 0.65);
    expect(pushedBlockStatics(fast).onset, PushedBlockOnset.slide);
    final aFast = pushedBlockSlidingAccel(fast);
    final aSlow = pushedBlockSlidingAccel(slow);
    expect(aFast, closeTo((8 - 0.20 * 9.8) / 1.0, 1e-12));
    expect(aSlow, lessThan(aFast));
    final s = pushedBlockSlidingAt(fast, 1.0);
    expect(s.x, closeTo(0.5 * aFast, 1e-12));
    expect(s.v, closeTo(aFast, 1e-12));
  });

  test('転倒開始で θ=0 の角加速度符号が Fh − mg w/2 と一致', () {
    final tip = base(h: 1.0, F: 5.0, muS: 0.60);
    expect(pushedBlockStatics(tip).onset, PushedBlockOnset.tip);
    final alpha = pushedBlockTippingAlpha(tip, 0, fingerContact: true);
    final expected =
        (-tip.weight * tip.width / 2 + tip.force * tip.pushHeight) /
            tip.inertiaAboutPivot;
    expect(alpha, closeTo(expected, 1e-12));
    expect(alpha, greaterThan(0));

    final holdish = base(h: 1.0, F: 2.0, muS: 0.60);
    // F < Ftip so holds statically, but if we force tip equation with F:
    final alphaSmall =
        pushedBlockTippingAlpha(holdish, 0, fingerContact: true);
    expect(alphaSmall, lessThan(0));
  });

  test('指離れ角は arcsin(h/w)（h≤w）で、それ以降 F=0', () {
    // 転倒が先（Ftip < Fslide）。離れ角は幾何だけ。
    final tipOk = base(w: 0.80, H: 1.20, h: 0.70, F: 10.0, muS: 0.60);
    expect(pushedBlockStatics(tipOk).onset, PushedBlockOnset.tip);
    final leave = pushedBlockFingerLeaveTheta(tipOk);
    expect(leave, closeTo(math.asin(0.70 / 0.80), 1e-9));

    expect(pushedBlockFingerContacts(tipOk, leave - 0.02), isTrue);
    expect(pushedBlockFingerContacts(tipOk, leave + 0.02), isFalse);

    final withF = pushedBlockTippingAccel(tipOk, leave - 0.01, 0);
    final noF = pushedBlockTippingAccel(tipOk, leave + 0.01, 0);
    expect(withF.forceApplied, closeTo(tipOk.force, 1e-12));
    expect(noF.forceApplied, closeTo(0, 1e-12));
  });

  test('転倒は指離れを経て側面着地し、エネルギー的におかしくない', () {
    final tip = base(h: 0.90, F: 7.0, muS: 0.80, muK: 0.40);
    expect(pushedBlockStatics(tip).onset, PushedBlockOnset.tip);

    final runtime = PushedBlockRuntime(tip);
    var sawLeave = false;
    var sawSide = false;
    double? maxOmega;
    for (var i = 0; i < 30000; i++) {
      runtime.step(1e-3);
      maxOmega = math.max(maxOmega ?? 0, runtime.omega.abs());
      if (runtime.phase == PushedBlockPhase.freeTip) sawLeave = true;
      if (runtime.phase == PushedBlockPhase.onSide) {
        sawSide = true;
        break;
      }
    }
    expect(sawLeave, isTrue);
    expect(sawSide, isTrue);
    expect(runtime.leaveT, isNotNull);
    expect(runtime.theta, greaterThan(1.0));
    expect(runtime.omega, closeTo(0, 1e-9));
    // 角速度が発散していない
    expect(maxOmega!, lessThan(50));
  });

  test('指離れ後、手の位置は固定される', () {
    final tip = base(h: 0.90, F: 7.0, muS: 0.80, muK: 0.40);
    final runtime = PushedBlockRuntime(tip);
    double? parkedX;
    for (var i = 0; i < 30000; i++) {
      runtime.step(1e-3);
      final s = runtime.sample;
      if (!s.fingerContact) {
        parkedX ??= s.handX;
        expect(s.handX, closeTo(parkedX, 1e-9));
        expect(s.handY, closeTo(tip.pushHeight, 1e-9));
      }
      if (runtime.phase == PushedBlockPhase.onSide) break;
    }
    expect(parkedX, isNotNull);
  });

  test('滑り中の垂直抗力は底面中央ではなくモーメント釣り合いの位置', () {
    // h = H/2 でも fk のトルクで N は前方へずれる。
    final p = base(h: 0.60, H: 1.20, F: 8.0, muK: 0.30, muS: 0.50);
    expect(pushedBlockStatics(p).onset, PushedBlockOnset.slide);
    final xN = pushedBlockNormalXFromCenter(p, kinetic: true);
    final expected = (8.0 * (0.60 - 0.60) + 0.30 * 9.8 * 0.60) / 9.8;
    expect(xN, closeTo(expected, 1e-12));
    expect(xN, greaterThan(0));
    expect(xN, lessThan(p.width / 2));

    // h が高いほど、同じ F でより前方へ寄る。
    final low = base(h: 0.30, H: 1.20, F: 8.0, muK: 0.30, muS: 0.50);
    final high = base(h: 0.90, H: 1.20, F: 8.0, muK: 0.30, muS: 0.50);
    expect(
      pushedBlockNormalXFromCenter(high, kinetic: true),
      greaterThan(pushedBlockNormalXFromCenter(low, kinetic: true)),
    );
  });

  test('質量は固定でも pushedBlockMass 経由（拡張ポイント）', () {
    expect(pushedBlockMass(0.8, 1.2), closeTo(1.0, 1e-12));
    expect(kPushedBlockMassFromArea, isFalse);
  });

  test('剛体カテゴリに直方体押しが入っている', () {
    final dynamics = categoriesData.firstWhere((c) => c.name == '力学');
    final rigid = dynamics.subcategories.firstWhere((s) => s.name == '剛体');
    expect(rigid.videos.contains(pushedBlock2D), isTrue);
  });
}
