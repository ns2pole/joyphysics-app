import 'dart:math' as math;

import 'pushed_block_params.dart';
import 'pushed_block_pipeline.dart';
import 'pushed_block_sliding.dart';
import 'pushed_block_statics.dart';
import 'pushed_block_tipping.dart';

/// 再生用ステッパ。
class PushedBlockRuntime {
  PushedBlockRuntime(this.params) {
    reset();
  }

  PushedBlockParams params;
  PushedBlockPhase phase = PushedBlockPhase.equilibrium;
  double time = 0;
  double x = 0;
  double v = 0;
  double theta = 0;
  double omega = 0;
  double? leaveT;
  double? sideT;
  double handParkX = 0;
  double handParkY = 0;
  bool handParked = false;

  PushedBlockSample get sample => _toSample();

  void reset() {
    time = 0;
    x = 0;
    v = 0;
    theta = 0;
    omega = 0;
    leaveT = null;
    sideT = null;
    handParked = false;
    handParkX = 0;
    handParkY = params.pushHeight;
    final st = pushedBlockStatics(params);
    if (st.onset == PushedBlockOnset.holds) {
      phase = PushedBlockPhase.equilibrium;
    } else if (st.onset == PushedBlockOnset.slide) {
      phase = PushedBlockPhase.sliding;
    } else {
      phase = PushedBlockPhase.tipping;
    }
  }

  void setParams(PushedBlockParams next) {
    params = next;
    reset();
  }

  bool step(double dt) {
    if (phase == PushedBlockPhase.equilibrium ||
        phase == PushedBlockPhase.onSide) {
      return false;
    }
    final target = time + math.max(0.0, dt);
    const h = 1e-3;
    while (time < target - 1e-15) {
      final stepDt = math.min(h, target - time);
      if (phase == PushedBlockPhase.sliding) {
        final a = pushedBlockSlidingAccel(params);
        x += v * stepDt + 0.5 * a * stepDt * stepDt;
        v += a * stepDt;
        time += stepDt;
      } else if (phase == PushedBlockPhase.tipping ||
          phase == PushedBlockPhase.freeTip) {
        if (!_stepTip(stepDt)) break;
      } else {
        break;
      }
    }
    return phase != PushedBlockPhase.onSide;
  }

  bool _stepTip(double stepDt) {
    final y0 = (theta: theta, omega: omega);
    final before = pushedBlockTippingAccel(params, theta, omega);
    final y1Theta = _rk4Tip(params, y0, stepDt);
    var th = y1Theta.theta;
    var om = y1Theta.omega;
    if (th < 0) {
      th = 0;
      om = 0;
    }

    final after = pushedBlockTippingAccel(params, th, om);
    if (before.fingerContact && !after.fingerContact) {
      _parkHandAtTheta(theta);
      leaveT ??= time + stepDt;
      phase = PushedBlockPhase.freeTip;
    }

    if (th >= kPushedBlockOnSideTheta) {
      var lo = 0.0;
      var hi = stepDt;
      var yLo = y0;
      for (var i = 0; i < 20; i++) {
        final mid = 0.5 * (lo + hi);
        final yMid = _rk4Tip(params, y0, mid);
        if (yMid.theta < kPushedBlockOnSideTheta) {
          lo = mid;
          yLo = yMid;
        } else {
          hi = mid;
        }
      }
      time += lo;
      sideT = time;
      theta = math.min(yLo.theta, math.pi / 2);
      omega = 0;
      if (!handParked) {
        _parkHandAtTheta(pushedBlockFingerLeaveTheta(params));
      }
      phase = PushedBlockPhase.onSide;
      return false;
    }

    theta = th;
    omega = om;
    time += stepDt;
    if (!after.fingerContact) {
      if (!handParked) {
        _parkHandAtTheta(pushedBlockFingerLeaveTheta(params));
        leaveT ??= time;
      }
      phase = PushedBlockPhase.freeTip;
    }
    return true;
  }

  void _parkHandAtTheta(double th) {
    final pt = pushedBlockContactPoint(params, th);
    handParkX = params.width + pt.x;
    handParkY = params.pushHeight;
    handParked = true;
  }

  PushedBlockSample _toSample() {
    if (phase == PushedBlockPhase.equilibrium) {
      return PushedBlockSample(
        t: 0,
        phase: phase,
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
    if (phase == PushedBlockPhase.sliding) {
      return PushedBlockSample(
        t: time,
        phase: phase,
        x: x,
        theta: 0,
        omega: 0,
        fingerContact: true,
        forceApplied: params.force,
        leaveT: null,
        sideT: null,
        handX: x,
        handY: params.pushHeight,
      );
    }
    final st = pushedBlockTippingAccel(params, theta, omega);
    // 指離れ後は赤丸をその場に固定。
    final double hx;
    final double hy;
    if (handParked || !st.fingerContact) {
      if (!handParked) {
        _parkHandAtTheta(pushedBlockFingerLeaveTheta(params));
      }
      hx = handParkX;
      hy = handParkY;
    } else {
      final pt = pushedBlockContactPoint(params, theta);
      hx = params.width + pt.x;
      hy = params.pushHeight;
    }
    return PushedBlockSample(
      t: time,
      phase: phase,
      x: params.width,
      theta: theta,
      omega: phase == PushedBlockPhase.onSide ? 0 : omega,
      fingerContact: st.fingerContact,
      forceApplied: st.forceApplied,
      leaveT: leaveT,
      sideT: sideT,
      handX: hx,
      handY: hy,
    );
  }
}

({double theta, double omega}) _rk4Tip(
  PushedBlockParams params,
  ({double theta, double omega}) y,
  double dt,
) {
  ({double theta, double omega}) deriv(({double theta, double omega}) s) {
    final st = pushedBlockTippingAccel(params, s.theta, s.omega);
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
