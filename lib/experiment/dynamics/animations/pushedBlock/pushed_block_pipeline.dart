import 'dart:math' as math;

import 'pushed_block_params.dart';
import 'pushed_block_sliding.dart';
import 'pushed_block_statics.dart';
import 'pushed_block_tipping.dart';
import 'package:joyphysics/l10n/anim_ui.dart';

enum PushedBlockPhase {
  equilibrium,
  sliding,
  tipping,
  freeTip,
  onSide,
}

class PushedBlockSample {
  const PushedBlockSample({
    required this.t,
    required this.phase,
    required this.x,
    required this.theta,
    required this.omega,
    required this.fingerContact,
    required this.forceApplied,
    required this.leaveT,
    required this.sideT,
    required this.handX,
    required this.handY,
  });

  final double t;
  final PushedBlockPhase phase;
  /// 滑り時は左下の床座標。転倒時は枢軸（初期右下）の床座標。
  final double x;
  final double theta;
  final double omega;
  final bool fingerContact;
  final double forceApplied;
  final double? leaveT;
  final double? sideT;
  final double handX;
  final double handY;
}

String pushedBlockPhaseLabel(PushedBlockPhase phase) {
  switch (phase) {
    case PushedBlockPhase.equilibrium:
      return animL('静止', 'At rest');
    case PushedBlockPhase.sliding:
      return animL('滑り', 'Sliding');
    case PushedBlockPhase.tipping:
      return animL('転倒', 'Tipping');
    case PushedBlockPhase.freeTip:
      return animL('指離れ後', 'After finger leaves');
    case PushedBlockPhase.onSide:
      return animL('側面着地', 'Landed on side');
  }
}

PushedBlockSample pushedBlockAt(PushedBlockParams params, double t) {
  final time = math.max(0.0, t);
  final st = pushedBlockStatics(params);
  final pivotX0 = params.width;

  if (st.onset == PushedBlockOnset.holds) {
    return PushedBlockSample(
      t: 0,
      phase: PushedBlockPhase.equilibrium,
      x: 0,
      theta: 0,
      omega: 0,
      fingerContact: true,
      forceApplied: params.force,
      leaveT: null,
      sideT: null,
      handX: 0,
      handY: params.pushHeight,
    );
  }

  if (st.onset == PushedBlockOnset.slide) {
    final slide = pushedBlockSlidingAt(params, time);
    return PushedBlockSample(
      t: time,
      phase: PushedBlockPhase.sliding,
      x: slide.x,
      theta: 0,
      omega: 0,
      fingerContact: true,
      forceApplied: params.force,
      leaveT: null,
      sideT: null,
      handX: slide.x,
      handY: params.pushHeight,
    );
  }

  // tip
  final tip = pushedBlockTippingIntegrate(params, time);
  final th = tip.state.theta;
  final contact = tip.state.fingerContact;
  final phase = tip.sideT != null
      ? PushedBlockPhase.onSide
      : (contact ? PushedBlockPhase.tipping : PushedBlockPhase.freeTip);

  final leaveTh = pushedBlockFingerLeaveTheta(params);
  final parked = pushedBlockContactPoint(params, leaveTh);
  final follow = pushedBlockContactPoint(params, th);
  final handX = contact ? pivotX0 + follow.x : pivotX0 + parked.x;
  final handY = params.pushHeight;

  return PushedBlockSample(
    t: tip.sideT ?? tip.time,
    phase: phase,
    x: pivotX0,
    theta: th,
    omega: tip.state.omega,
    fingerContact: contact,
    forceApplied: tip.state.forceApplied,
    leaveT: tip.leaveT,
    sideT: tip.sideT,
    handX: handX,
    handY: handY,
  );
}
