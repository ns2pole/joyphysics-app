import 'dart:math' as math;

import 'pushed_block_params.dart';

/// 右下端ピン・時計回り $\theta$（0=直立、$\pi/2$=側面着地）。
class PushedBlockTippingState {
  const PushedBlockTippingState({
    required this.theta,
    required this.omega,
    required this.alpha,
    required this.fingerContact,
    required this.forceApplied,
  });

  final double theta;
  final double omega;
  final double alpha;
  final bool fingerContact;
  final double forceApplied;
}

/// 左面が $y=h$ と交わるか。
bool pushedBlockFingerContacts(PushedBlockParams params, double theta) {
  final w = params.width;
  final H = params.height;
  final h = params.pushHeight;
  final s = math.sin(theta);
  final c = math.cos(theta);
  final yMin = w * s;
  final yMax = w * s + H * c;
  return h + 1e-9 >= yMin && h - 1e-9 <= yMax;
}

/// 指が離れる角（早い方）。$h\le w$ なら多くの場合 $\arcsin(h/w)$。
double pushedBlockFingerLeaveTheta(PushedBlockParams params) {
  final w = params.width;
  final H = params.height;
  final h = params.pushHeight;
  var leave = math.pi / 2;
  if (h <= w + 1e-12) {
    leave = math.min(leave, math.asin((h / w).clamp(0.0, 1.0)));
  }
  // 上面が h より下: w sinθ + H cosθ = h の最小正根を数値で。
  for (var i = 1; i <= 200; i++) {
    final th = i * (math.pi / 2) / 200;
    final yTop = w * math.sin(th) + H * math.cos(th);
    if (yTop <= h + 1e-9) {
      leave = math.min(leave, th);
      break;
    }
  }
  return leave;
}

/// $\displaystyle I_P\ddot\theta=-mg\bigl(\frac{w}{2}\cos\theta-\frac{H}{2}\sin\theta\bigr)+F_{\mathrm{eff}}h$。
double pushedBlockTippingAlpha(
  PushedBlockParams params,
  double theta, {
  required bool fingerContact,
}) {
  final m = params.mass;
  final g = kPushedBlockG;
  final w = params.width;
  final H = params.height;
  final h = params.pushHeight;
  final ip = params.inertiaAboutPivot;
  final gravityTorque = -m * g * (0.5 * w * math.cos(theta) - 0.5 * H * math.sin(theta));
  final fEff = fingerContact ? params.force : 0.0;
  final fingerTorque = fEff * h;
  return (gravityTorque + fingerTorque) / ip;
}

/// 枢軸が床に止まっているときの水平反力 $f_x$（右向き正）と垂直抗力 $N$。
/// $\displaystyle m\ddot{x}=F_{\mathrm{eff}}+f_x$、$\displaystyle m\ddot{y}=N-mg$（$y$ は上向き）。
({double fx, double normal}) pushedBlockPivotReactions(
  PushedBlockParams params,
  double theta,
  double omega, {
  required bool fingerContact,
}) {
  final alpha = pushedBlockTippingAlpha(
    params,
    theta,
    fingerContact: fingerContact,
  );
  final w = params.width;
  final H = params.height;
  final m = params.mass;
  final c = math.cos(theta);
  final s = math.sin(theta);
  final w2 = omega * omega;
  final ax = 0.5 * w * (c * w2 + s * alpha) + 0.5 * H * (-s * w2 + c * alpha);
  final ay =
      0.5 * w * (-s * w2 + c * alpha) + 0.5 * H * (-c * w2 - s * alpha);
  final fApplied = fingerContact ? params.force : 0.0;
  return (fx: m * ax - fApplied, normal: m * ay + m * kPushedBlockG);
}

PushedBlockTippingState pushedBlockTippingAccel(
  PushedBlockParams params,
  double theta,
  double omega,
) {
  final contact = pushedBlockFingerContacts(params, theta);
  final alpha = pushedBlockTippingAlpha(params, theta, fingerContact: contact);
  return PushedBlockTippingState(
    theta: theta,
    omega: omega,
    alpha: alpha,
    fingerContact: contact,
    forceApplied: contact ? params.force : 0.0,
  );
}

/// 接触点の実験室座標（枢軸を原点とした相対）。枢軸は右下。
({double x, double y}) pushedBlockContactPoint(
  PushedBlockParams params,
  double theta,
) {
  final w = params.width;
  final h = params.pushHeight;
  final s = math.sin(theta);
  final c = math.cos(theta);
  // s_param on left face: y = w sinθ + s_param cosθ = h
  final sParam = c.abs() < 1e-9 ? 0.0 : (h - w * s) / c;
  final x = -w * c + sParam * s;
  final y = w * s + sParam * c;
  return (x: x, y: y);
}

/// 重心（枢軸相対）。
({double x, double y}) pushedBlockCmFromPivot(PushedBlockParams params, double theta) {
  final w = params.width;
  final H = params.height;
  final s = math.sin(theta);
  final c = math.cos(theta);
  return (
    x: -0.5 * w * c + 0.5 * H * s,
    y: 0.5 * w * s + 0.5 * H * c,
  );
}

typedef _Y = ({double theta, double omega});

_Y _rk4(PushedBlockParams params, _Y y, double dt) {
  _Y deriv(_Y s) {
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

/// 転倒を積分。$\theta$ が側面角に達したら打ち切り。
({
  PushedBlockTippingState state,
  double time,
  double? leaveT,
  double? sideT,
}) pushedBlockTippingIntegrate(
  PushedBlockParams params,
  double t, {
  double dt = 1e-3,
  double theta0 = 0.0,
  double omega0 = 0.0,
}) {
  var y = (theta: theta0, omega: omega0);
  var time = 0.0;
  double? leaveT;
  var wasContact = pushedBlockFingerContacts(params, y.theta);
  var state = pushedBlockTippingAccel(params, y.theta, y.omega);
  final target = math.max(0.0, t);
  final leaveTheta = pushedBlockFingerLeaveTheta(params);

  while (time < target - 1e-15) {
    final step = math.min(dt, target - time);
    final yNext = _rk4(params, y, step);
    var th = yNext.theta;
    var om = yNext.omega;
    if (th < 0) {
      th = 0;
      om = 0;
    }

    final contact = pushedBlockFingerContacts(params, th);
    if (wasContact && !contact && leaveT == null) {
      leaveT = time + step * 0.5;
    }
    wasContact = contact;

    if (th >= leaveTheta && leaveT == null && !contact) {
      leaveT = time + step;
    }

    if (th >= kPushedBlockOnSideTheta) {
      // 二分
      var lo = 0.0;
      var hi = step;
      var yLo = y;
      for (var i = 0; i < 20; i++) {
        final mid = 0.5 * (lo + hi);
        final yMid = _rk4(params, y, mid);
        if (yMid.theta < kPushedBlockOnSideTheta) {
          lo = mid;
          yLo = yMid;
        } else {
          hi = mid;
        }
      }
      final sideT = time + lo;
      return (
        state: PushedBlockTippingState(
          theta: math.min(yLo.theta, math.pi / 2),
          omega: 0,
          alpha: 0,
          fingerContact: false,
          forceApplied: 0,
        ),
        time: sideT,
        leaveT: leaveT,
        sideT: sideT,
      );
    }

    y = (theta: th, omega: om);
    state = pushedBlockTippingAccel(params, y.theta, y.omega);
    time += step;
  }
  return (state: state, time: time, leaveT: leaveT, sideT: null);
}
