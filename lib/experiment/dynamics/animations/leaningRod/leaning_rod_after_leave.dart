import 'dart:math' as math;

import 'leaning_rod_params.dart';
import 'leaning_rod_sliding_both.dart';

/// 壁から離れたあと。足は床上、自由度 $(x_A,\theta)$。
class LeaningRodAfterLeaveState {
  const LeaningRodAfterLeaveState({
    required this.xA,
    required this.theta,
    required this.vxA,
    required this.omega,
    required this.nf,
    required this.ff,
    required this.alpha,
    required this.axA,
  });

  final double xA;
  final double theta;
  final double vxA;
  final double omega;
  final double nf;
  final double ff;
  final double alpha;
  final double axA;

  double get xB => xA - kLeaningRodLength * math.cos(theta);
  double get yB => kLeaningRodLength * math.sin(theta);
  double get xG => xA - 0.5 * kLeaningRodLength * math.cos(theta);
  double get yG => 0.5 * kLeaningRodLength * math.sin(theta);
}

double _slipSign(double vx) {
  if (vx > 1e-4) return 1.0;
  if (vx < -1e-4) return -1.0;
  return 0.0;
}

/// 壁なし・床動摩擦。$f_x=-\mu_k N_f\,\mathrm{sgn}(\dot x_A)$。
LeaningRodAfterLeaveState leaningRodAfterLeaveAccel(
  LeaningRodParams params,
  double xA,
  double theta,
  double vxA,
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
  final sigma = _slipSign(vxA);

  // γ = -c + μ σ s
  final gamma = -c + mu * sigma * s;
  final denom = a * (1.0 / 3.0 - c * gamma);
  final numer = (m * g - a * s * w2) * gamma;
  final alpha = denom.abs() < 1e-14 ? 0.0 : numer / denom;

  var nf = m * g - a * s * w2 + a * c * alpha;
  if (nf < 0) nf = 0;
  final ff = -mu * sigma * nf;
  final axA = ff / m - (L / 2) * (c * w2 + s * alpha);

  return LeaningRodAfterLeaveState(
    xA: xA,
    theta: theta,
    vxA: vxA,
    omega: omega,
    nf: nf,
    ff: ff,
    alpha: alpha,
    axA: axA,
  );
}

LeaningRodAfterLeaveState leaningRodAfterLeaveFromBoth(
  LeaningRodParams params,
  LeaningRodSlidingBothState both,
) {
  // 両端接触中は x_A = L cosθ、ẋ_A = -L sinθ · ω。
  final xA = both.xA;
  final vxA = -kLeaningRodLength * math.sin(both.theta) * both.omega;
  return leaningRodAfterLeaveAccel(params, xA, both.theta, vxA, both.omega);
}

typedef _Z = ({double xA, double theta, double vxA, double omega});

_Z _rk4Step(LeaningRodParams params, _Z z, double dt) {
  _Z deriv(_Z s) {
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

/// 壁離れ後を積分。$\theta\le\theta_{\mathrm{flat}}$ で打ち切り。
({
  LeaningRodAfterLeaveState state,
  double time,
  double? flatT,
}) leaningRodAfterLeaveIntegrate(
  LeaningRodParams params,
  LeaningRodAfterLeaveState initial,
  double t, {
  double dt = 1e-3,
}) {
  var z = (
    xA: initial.xA,
    theta: initial.theta,
    vxA: initial.vxA,
    omega: initial.omega,
  );
  var time = 0.0;
  var state = leaningRodAfterLeaveAccel(
    params,
    z.xA,
    z.theta,
    z.vxA,
    z.omega,
  );

  if (z.theta <= kLeaningRodFlatTheta) {
    return (state: state, time: 0.0, flatT: 0.0);
  }

  final target = math.max(0.0, t);
  while (time < target - 1e-15) {
    final step = math.min(dt, target - time);
    final zNext = _rk4Step(params, z, step);

    if (zNext.theta <= kLeaningRodFlatTheta) {
      var lo = 0.0;
      var hi = step;
      var zLo = z;
      for (var i = 0; i < 24; i++) {
        final mid = 0.5 * (lo + hi);
        final zMid = _rk4Step(params, z, mid);
        if (zMid.theta > kLeaningRodFlatTheta) {
          lo = mid;
          zLo = zMid;
        } else {
          hi = mid;
        }
      }
      final flatT = time + lo;
      final stLo = leaningRodAfterLeaveAccel(
        params,
        zLo.xA,
        zLo.theta,
        zLo.vxA,
        zLo.omega,
      );
      return (state: stLo, time: flatT, flatT: flatT);
    }

    // 床下や壁側へ突き抜けない程度のガード。
    if (zNext.theta > math.pi / 2 - 1e-3) {
      z = (
        xA: zNext.xA,
        theta: math.pi / 2 - 1e-3,
        vxA: zNext.vxA,
        omega: math.min(0.0, zNext.omega),
      );
    } else {
      z = zNext;
    }
    state = leaningRodAfterLeaveAccel(
      params,
      z.xA,
      z.theta,
      z.vxA,
      z.omega,
    );
    time += step;
  }
  return (state: state, time: time, flatT: null);
}
