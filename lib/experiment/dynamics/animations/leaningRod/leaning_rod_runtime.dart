import 'dart:math' as math;

import 'leaning_rod_after_leave.dart';
import 'leaning_rod_params.dart';
import 'leaning_rod_pipeline.dart';
import 'leaning_rod_sliding_both.dart';
import 'leaning_rod_statics.dart';

/// 再生用ステッパ。パラメータ変更時は [reset]。
class LeaningRodRuntime {
  LeaningRodRuntime(this.params) {
    reset();
  }

  LeaningRodParams params;
  LeaningRodPhase phase = LeaningRodPhase.equilibrium;
  double time = 0;
  double theta = 0;
  double omega = 0;
  double xA = 0;
  double vxA = 0;
  double? leaveT;
  double? flatT;

  LeaningRodSample get sample => _toSample();

  void reset() {
    time = 0;
    leaveT = null;
    flatT = null;
    omega = 0;
    vxA = 0;
    if (leaningRodHolds(params)) {
      phase = LeaningRodPhase.equilibrium;
      theta = params.thetaFloor;
      xA = params.length * math.cos(theta);
      return;
    }
    phase = LeaningRodPhase.slidingBoth;
    theta = params.thetaFloor;
    xA = params.length * math.cos(theta);
  }

  void setParams(LeaningRodParams next) {
    params = next;
    reset();
  }

  /// 進めたら true。停止（静止・倒れ）なら false。
  bool step(double dt) {
    if (phase == LeaningRodPhase.equilibrium || phase == LeaningRodPhase.flat) {
      return false;
    }
    final target = time + math.max(0.0, dt);
    const h = 1e-3;
    while (time < target - 1e-15) {
      final stepDt = math.min(h, target - time);
      if (phase == LeaningRodPhase.slidingBoth) {
        if (!_stepBoth(stepDt)) break;
      } else if (phase == LeaningRodPhase.afterLeave) {
        if (!_stepAfter(stepDt)) break;
      } else {
        break;
      }
    }
    return phase != LeaningRodPhase.flat;
  }

  bool _stepBoth(double step) {
    final before = leaningRodSlidingBothAccel(params, theta, omega);
    if (before.nw <= 0) {
      _switchToAfter(before, time);
      return true;
    }
    final y0 = (theta: theta, omega: omega);
    final y1 = _rk4Both(params, y0, step);
    final after = leaningRodSlidingBothAccel(params, y1.theta, y1.omega);
    if (after.nw <= 0 || y1.theta <= kLeaningRodFlatTheta) {
      var lo = 0.0;
      var hi = step;
      var yLo = y0;
      for (var i = 0; i < 20; i++) {
        final mid = 0.5 * (lo + hi);
        final yMid = _rk4Both(params, y0, mid);
        final st = leaningRodSlidingBothAccel(params, yMid.theta, yMid.omega);
        if (st.nw > 0 && yMid.theta > kLeaningRodFlatTheta) {
          lo = mid;
          yLo = yMid;
        } else {
          hi = mid;
        }
      }
      time += lo;
      final stLo = leaningRodSlidingBothAccel(params, yLo.theta, yLo.omega);
      _switchToAfter(stLo, time);
      return true;
    }
    theta = y1.theta;
    omega = y1.omega;
    xA = params.length * math.cos(theta);
    vxA = -params.length * math.sin(theta) * omega;
    time += step;
    return true;
  }

  void _switchToAfter(LeaningRodSlidingBothState both, double at) {
    leaveT = at;
    final launched = leaningRodAfterLeaveFromBoth(params, both);
    phase = LeaningRodPhase.afterLeave;
    theta = launched.theta;
    omega = launched.omega;
    xA = launched.xA;
    vxA = launched.vxA;
  }

  bool _stepAfter(double step) {
    final z0 = (xA: xA, theta: theta, vxA: vxA, omega: omega);
    final z1 = _rk4After(params, z0, step);
    if (z1.theta <= kLeaningRodFlatTheta) {
      var lo = 0.0;
      var hi = step;
      var zLo = z0;
      for (var i = 0; i < 20; i++) {
        final mid = 0.5 * (lo + hi);
        final zMid = _rk4After(params, z0, mid);
        if (zMid.theta > kLeaningRodFlatTheta) {
          lo = mid;
          zLo = zMid;
        } else {
          hi = mid;
        }
      }
      time += lo;
      flatT = time;
      phase = LeaningRodPhase.flat;
      theta = math.max(zLo.theta, 0.0);
      omega = 0;
      xA = zLo.xA;
      vxA = 0;
      return false;
    }
    xA = z1.xA;
    theta = z1.theta;
    vxA = z1.vxA;
    omega = z1.omega;
    time += step;
    return true;
  }

  LeaningRodSample _toSample() {
    if (phase == LeaningRodPhase.equilibrium) {
      final r = leaningRodStaticsReactions(params);
      final L = params.length;
      return LeaningRodSample(
        t: 0,
        phase: phase,
        theta: theta,
        omega: 0,
        xA: L * math.cos(theta),
        xB: 0,
        yB: L * math.sin(theta),
        nf: r.nf,
        ff: r.ff,
        nw: r.nw,
        leaveT: null,
        flatT: null,
      );
    }
    if (phase == LeaningRodPhase.slidingBoth) {
      final st = leaningRodSlidingBothAccel(params, theta, omega);
      return LeaningRodSample(
        t: time,
        phase: phase,
        theta: theta,
        omega: omega,
        xA: st.xA,
        xB: 0,
        yB: st.yB,
        nf: st.nf,
        ff: st.ff,
        nw: math.max(0.0, st.nw),
        leaveT: leaveT,
        flatT: flatT,
      );
    }
    final st = leaningRodAfterLeaveAccel(params, xA, theta, vxA, omega);
    return LeaningRodSample(
      t: time,
      phase: phase,
      theta: theta,
      omega: phase == LeaningRodPhase.flat ? 0 : omega,
      xA: xA,
      xB: st.xB,
      yB: math.max(0.0, st.yB),
      nf: st.nf,
      ff: phase == LeaningRodPhase.flat ? 0 : st.ff,
      nw: 0,
      leaveT: leaveT,
      flatT: flatT,
    );
  }
}

({double theta, double omega}) _rk4Both(
  LeaningRodParams params,
  ({double theta, double omega}) y,
  double dt,
) {
  ({double theta, double omega}) deriv(({double theta, double omega}) s) {
    final st = leaningRodSlidingBothAccel(params, s.theta, s.omega);
    return (theta: s.omega, omega: st.alpha);
  }

  final k1 = deriv(y);
  final k2 = deriv((
    theta: y.theta + 0.5 * dt * k1.theta,
    omega: y.omega + 0.5 * dt * k1.omega,
  ));
  final k3 = deriv((
    theta: y.theta + 0.5 * dt * k2.theta,
    omega: y.omega + 0.5 * dt * k2.omega,
  ));
  final k4 = deriv((
    theta: y.theta + dt * k3.theta,
    omega: y.omega + dt * k3.omega,
  ));
  return (
    theta: y.theta + (dt / 6) * (k1.theta + 2 * k2.theta + 2 * k3.theta + k4.theta),
    omega: y.omega + (dt / 6) * (k1.omega + 2 * k2.omega + 2 * k3.omega + k4.omega),
  );
}

({double xA, double theta, double vxA, double omega}) _rk4After(
  LeaningRodParams params,
  ({double xA, double theta, double vxA, double omega}) z,
  double dt,
) {
  ({double xA, double theta, double vxA, double omega}) deriv(
    ({double xA, double theta, double vxA, double omega}) s,
  ) {
    final st = leaningRodAfterLeaveAccel(
      params,
      s.xA,
      s.theta,
      s.vxA,
      s.omega,
    );
    return (
      xA: s.vxA,
      theta: s.omega,
      vxA: st.axA,
      omega: st.alpha,
    );
  }

  final k1 = deriv(z);
  final k2 = deriv((
    xA: z.xA + 0.5 * dt * k1.xA,
    theta: z.theta + 0.5 * dt * k1.theta,
    vxA: z.vxA + 0.5 * dt * k1.vxA,
    omega: z.omega + 0.5 * dt * k1.omega,
  ));
  final k3 = deriv((
    xA: z.xA + 0.5 * dt * k2.xA,
    theta: z.theta + 0.5 * dt * k2.theta,
    vxA: z.vxA + 0.5 * dt * k2.vxA,
    omega: z.omega + 0.5 * dt * k2.omega,
  ));
  final k4 = deriv((
    xA: z.xA + dt * k3.xA,
    theta: z.theta + dt * k3.theta,
    vxA: z.vxA + dt * k3.vxA,
    omega: z.omega + dt * k3.omega,
  ));
  return (
    xA: z.xA + (dt / 6) * (k1.xA + 2 * k2.xA + 2 * k3.xA + k4.xA),
    theta: z.theta + (dt / 6) * (k1.theta + 2 * k2.theta + 2 * k3.theta + k4.theta),
    vxA: z.vxA + (dt / 6) * (k1.vxA + 2 * k2.vxA + 2 * k3.vxA + k4.vxA),
    omega: z.omega + (dt / 6) * (k1.omega + 2 * k2.omega + 2 * k3.omega + k4.omega),
  );
}
