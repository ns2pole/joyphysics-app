import 'dart:math' as math;

import 'leaning_rod_after_leave.dart';
import 'leaning_rod_params.dart';
import 'leaning_rod_sliding_both.dart';
import 'leaning_rod_statics.dart';
import 'package:joyphysics/l10n/anim_ui.dart';

enum LeaningRodPhase { equilibrium, slidingBoth, afterLeave, flat }

class LeaningRodSample {
  const LeaningRodSample({
    required this.t,
    required this.phase,
    required this.theta,
    required this.omega,
    required this.xA,
    required this.xB,
    required this.yB,
    required this.nf,
    required this.ff,
    required this.nw,
    required this.leaveT,
    required this.flatT,
  });

  final double t;
  final LeaningRodPhase phase;
  final double theta;
  final double omega;
  final double xA;
  final double xB;
  final double yB;
  final double nf;
  final double ff;
  final double nw;
  final double? leaveT;
  final double? flatT;

  double get xG => 0.5 * (xA + xB);
  double get yG => 0.5 * yB;
}

String leaningRodPhaseLabel(LeaningRodPhase phase) {
  switch (phase) {
    case LeaningRodPhase.equilibrium:
      return animL('静止', 'At rest');
    case LeaningRodPhase.slidingBoth:
      return animL('両端接触', 'Both ends contact');
    case LeaningRodPhase.afterLeave:
      return animL('壁離れ後', 'After leaving wall');
    case LeaningRodPhase.flat:
      return animL('倒れた', 'Fallen');
  }
}

/// 静止なら equilibrium。破れれば両端滑り → $N_w=0$ で壁離れ → $\theta\approx0$ で倒れ。
LeaningRodSample leaningRodAt(LeaningRodParams params, double t) {
  final time = math.max(0.0, t);
  final statics = leaningRodStaticsReactions(params);
  if (statics.holds) {
    final th = params.thetaFloor;
    final L = params.length;
    return LeaningRodSample(
      t: 0,
      phase: LeaningRodPhase.equilibrium,
      theta: th,
      omega: 0,
      xA: L * math.cos(th),
      xB: 0,
      yB: L * math.sin(th),
      nf: statics.nf,
      ff: statics.ff,
      nw: statics.nw,
      leaveT: null,
      flatT: null,
    );
  }

  final both = leaningRodSlidingBothIntegrate(params, time);
  if (both.leaveT == null) {
    final s = both.state;
    return LeaningRodSample(
      t: both.time,
      phase: LeaningRodPhase.slidingBoth,
      theta: s.theta,
      omega: s.omega,
      xA: s.xA,
      xB: 0,
      yB: s.yB,
      nf: s.nf,
      ff: s.ff,
      nw: math.max(0.0, s.nw),
      leaveT: null,
      flatT: null,
    );
  }

  final leaveT = both.leaveT!;
  final leaveState = both.state;
  final initial = leaningRodAfterLeaveFromBoth(params, leaveState);

  if (time <= leaveT + 1e-12) {
    return LeaningRodSample(
      t: leaveT,
      phase: LeaningRodPhase.slidingBoth,
      theta: leaveState.theta,
      omega: leaveState.omega,
      xA: leaveState.xA,
      xB: 0,
      yB: leaveState.yB,
      nf: leaveState.nf,
      ff: leaveState.ff,
      nw: 0,
      leaveT: leaveT,
      flatT: null,
    );
  }

  final after = leaningRodAfterLeaveIntegrate(
    params,
    initial,
    time - leaveT,
  );
  final s = after.state;
  if (after.flatT != null) {
    final flatT = leaveT + after.flatT!;
    return LeaningRodSample(
      t: flatT,
      phase: LeaningRodPhase.flat,
      theta: math.max(s.theta, 0.0),
      omega: 0,
      xA: s.xA,
      xB: s.xB,
      yB: math.max(0.0, s.yB),
      nf: s.nf,
      ff: 0,
      nw: 0,
      leaveT: leaveT,
      flatT: flatT,
    );
  }

  return LeaningRodSample(
    t: leaveT + after.time,
    phase: LeaningRodPhase.afterLeave,
    theta: s.theta,
    omega: s.omega,
    xA: s.xA,
    xB: s.xB,
    yB: s.yB,
    nf: s.nf,
    ff: s.ff,
    nw: 0,
    leaveT: leaveT,
    flatT: null,
  );
}

/// 再生を止める時刻。静止は 0。倒れなければ十分長い上限。
double? leaningRodStopTime(LeaningRodParams params) {
  if (leaningRodHolds(params)) return 0;
  final sample = leaningRodAt(params, 30.0);
  if (sample.flatT != null) return sample.flatT;
  return sample.t;
}
