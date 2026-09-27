import 'pushed_block_params.dart';

class PushedBlockSlidingState {
  const PushedBlockSlidingState({
    required this.x,
    required this.v,
    required this.a,
  });

  final double x;
  final double v;
  final double a;
}

/// 床つき並進。$\displaystyle a=\frac{F-\mu_k mg}{m}$（右向き正）。
double pushedBlockSlidingAccel(PushedBlockParams params) {
  return (params.force - params.muK * params.weight) / params.mass;
}

PushedBlockSlidingState pushedBlockSlidingAt(
  PushedBlockParams params,
  double t, {
  double x0 = 0.0,
  double v0 = 0.0,
}) {
  final time = t < 0 ? 0.0 : t;
  final a = pushedBlockSlidingAccel(params);
  return PushedBlockSlidingState(
    x: x0 + v0 * time + 0.5 * a * time * time,
    v: v0 + a * time,
    a: a,
  );
}
