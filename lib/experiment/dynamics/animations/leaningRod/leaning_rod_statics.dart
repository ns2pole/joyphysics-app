import 'dart:math' as math;

import 'leaning_rod_params.dart';

/// 壁滑らか（$f_w=0$）のときの静止接触力。
class LeaningRodStaticsReactions {
  const LeaningRodStaticsReactions({
    required this.holds,
    required this.nf,
    required this.ff,
    required this.nw,
  });

  final bool holds;
  final double nf;
  final double ff;
  final double nw;
}

/// θ は棒と壁の角。$\displaystyle\mu_s\ge\frac{1}{2}\tan\theta$ なら静止。
/// 解は $N_f=mg,\ f_f=N_w=\frac{1}{2}mg\tan\theta$。
LeaningRodStaticsReactions leaningRodStaticsReactions(LeaningRodParams params) {
  final th = params.theta; // 壁との角
  final cosT = math.cos(th);
  final sinT = math.sin(th);
  if (cosT < 1e-9 || sinT < 1e-9) {
    return const LeaningRodStaticsReactions(
      holds: false,
      nf: 0,
      ff: 0,
      nw: 0,
    );
  }
  final mg = params.weight;
  final ff = 0.5 * mg * sinT / cosT; // (1/2) mg tan θ
  final nf = mg;
  final holds = params.muS + 1e-9 >= ff / nf;
  if (!holds) {
    return const LeaningRodStaticsReactions(
      holds: false,
      nf: 0,
      ff: 0,
      nw: 0,
    );
  }
  return LeaningRodStaticsReactions(holds: true, nf: nf, ff: ff, nw: ff);
}

bool leaningRodHolds(LeaningRodParams params) =>
    leaningRodStaticsReactions(params).holds;

/// 滑らかな壁での限界角（壁との角）。$\displaystyle\theta=\arctan(2\mu_s)$。
double? leaningRodCriticalThetaDeg(double muS) {
  if (muS <= 1e-12) return null;
  return math.atan(2 * muS) * 180 / math.pi;
}
