import 'dart:math' as math;

import 'leaning_rod_params.dart';

/// 両端接触・壁滑らか・床動摩擦力 $\mu_k$ の状態。
class LeaningRodSlidingBothState {
  const LeaningRodSlidingBothState({
    required this.theta,
    required this.omega,
    required this.nf,
    required this.ff,
    required this.nw,
    required this.alpha,
  });

  final double theta;
  final double omega;
  final double nf;
  final double ff;
  final double nw;
  final double alpha;

  double get xA => kLeaningRodLength * math.cos(theta);
  double get yB => kLeaningRodLength * math.sin(theta);
}

/// $\ddot\theta$ と接触力。$\omega=\dot\theta$。
/// 棒の向き角は $\pi-\theta$ なので $I(-\ddot\theta)=\tau_{\mathrm{CCW}}$。
LeaningRodSlidingBothState leaningRodSlidingBothAccel(
  LeaningRodParams params,
  double theta,
  double omega,
) {
  final m = params.mass;
  final L = params.length;
  final g = kLeaningRodG;
  final mu = params.muK;
  final s = math.sin(theta);
  final c = math.cos(theta);
  final a = m * L / 2;
  final w2 = omega * omega;

  // α = [mg(-c+2μs) - 2μ a ω² s²] / [a(4/3 - 2μ s c)]
  final denom = a * (4.0 / 3.0 - 2 * mu * s * c);
  final numer = m * g * (-c + 2 * mu * s) - 2 * mu * a * w2 * s * s;
  final alpha = denom.abs() < 1e-14 ? 0.0 : numer / denom;

  final nf = m * g - a * s * w2 + a * c * alpha;
  final ff = mu * nf;
  final nw = ff - a * c * w2 - a * s * alpha;

  return LeaningRodSlidingBothState(
    theta: theta,
    omega: omega,
    nf: nf,
    ff: ff,
    nw: nw,
    alpha: alpha,
  );
}

/// 摩擦なし床での理論離れ角。$\sin\theta=\frac{2}{3}\sin\theta_0$。
double leaningRodFrictionlessLeaveTheta(double theta0) {
  final target = (2.0 / 3.0) * math.sin(theta0);
  if (target >= 1) return math.pi / 2;
  if (target <= 0) return 0;
  return math.asin(target);
}

typedef _Y = ({double theta, double omega});

_Y _rk4Step(LeaningRodParams params, _Y y, double dt) {
  _Y deriv(_Y s) {
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

/// 両端接触のまま $[0,t]$ を積分。$N_w\le0$ で打ち切り、離れ時刻を [leaveT] に入れる。
({
  LeaningRodSlidingBothState state,
  double time,
  double? leaveT,
}) leaningRodSlidingBothIntegrate(
  LeaningRodParams params,
  double t, {
  double dt = 1e-3,
  double theta0 = double.nan,
  double omega0 = 0.0,
}) {
  final th0 = theta0.isNaN ? params.thetaFloor : theta0;
  var y = (theta: th0, omega: omega0);
  var time = 0.0;
  var state = leaningRodSlidingBothAccel(params, y.theta, y.omega);
  if (state.nw <= 0) {
    return (state: state, time: 0.0, leaveT: 0.0);
  }

  final target = math.max(0.0, t);
  while (time < target - 1e-15) {
    final step = math.min(dt, target - time);
    final yNext = _rk4Step(params, y, step);
    final stNext = leaningRodSlidingBothAccel(params, yNext.theta, yNext.omega);

    if (stNext.nw <= 0 || yNext.theta <= kLeaningRodFlatTheta) {
      // 二分で N_w=0 を探す。
      var lo = 0.0;
      var hi = step;
      var yLo = y;
      for (var i = 0; i < 24; i++) {
        final mid = 0.5 * (lo + hi);
        final yMid = _rk4Step(params, y, mid);
        final stMid = leaningRodSlidingBothAccel(params, yMid.theta, yMid.omega);
        if (stMid.nw > 0 && yMid.theta > kLeaningRodFlatTheta) {
          lo = mid;
          yLo = yMid;
        } else {
          hi = mid;
        }
      }
      final leaveT = time + lo;
      final stLo = leaningRodSlidingBothAccel(params, yLo.theta, yLo.omega);
      return (state: stLo, time: leaveT, leaveT: leaveT);
    }

    y = yNext;
    state = stNext;
    time += step;
  }
  return (state: state, time: time, leaveT: null);
}
