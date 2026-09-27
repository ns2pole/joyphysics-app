import 'pushed_block_params.dart';

enum PushedBlockOnset { holds, slide, tip }

class PushedBlockStatics {
  const PushedBlockStatics({
    required this.onset,
    required this.fSlide,
    required this.fTip,
    required this.normalXFromCenter,
  });

  final PushedBlockOnset onset;
  final double fSlide;
  final double fTip;

  /// 底面の垂直抗力合力の、底面中央からの水平ずれ（右正）。$|x|\le w/2$。
  final double normalXFromCenter;

  bool get holds => onset == PushedBlockOnset.holds;
}

/// 重心まわりのモーメント釣り合いから、底面合力のずれ（右正）。
///
/// 静止（$f=F$）: $\displaystyle x=\frac{Fh}{mg}$。
/// 滑り（$f=\mu_k mg$）: $\displaystyle x=\frac{F(h-H/2)+\mu_k mg\cdot H/2}{mg}$。
/// いずれも $|x|\le w/2$ にクランプ（端に張り付いたら転倒側）。
double pushedBlockNormalXFromCenter(
  PushedBlockParams params, {
  required bool kinetic,
}) {
  final mg = params.weight;
  final h = params.pushHeight.clamp(1e-9, params.height);
  final H = params.height;
  final F = params.force;
  final double x;
  if (kinetic) {
    x = (F * (h - H / 2) + params.muK * mg * (H / 2)) / mg;
  } else {
    x = (F * h) / mg;
  }
  final half = params.width / 2;
  if (x > half) return half;
  if (x < -half) return -half;
  return x;
}

/// $F_{\mathrm{slide}}=\mu_s mg$，$F_{\mathrm{tip}}=mg\cdot w/(2h)$。
///
/// $F$ を静かに上げるとき、先に達する限界が勝つ。両方を超えても
/// $\min(F_{\mathrm{slide}},F_{\mathrm{tip}})$ の側のまま（滑り中に転倒へ跳び移らない）。
PushedBlockStatics pushedBlockStatics(PushedBlockParams params) {
  final mg = params.weight;
  final h = params.pushHeight.clamp(1e-9, params.height);
  final fSlide = params.muS * mg;
  final fTip = mg * params.width / (2 * h);
  final F = params.force;

  final PushedBlockOnset onset;
  final firstLimit = fSlide <= fTip ? fSlide : fTip;
  if (F <= firstLimit + 1e-9) {
    onset = PushedBlockOnset.holds;
  } else if (fSlide <= fTip) {
    onset = PushedBlockOnset.slide;
  } else {
    onset = PushedBlockOnset.tip;
  }

  final double xN;
  switch (onset) {
    case PushedBlockOnset.holds:
      xN = pushedBlockNormalXFromCenter(params, kinetic: false);
    case PushedBlockOnset.slide:
      xN = pushedBlockNormalXFromCenter(params, kinetic: true);
    case PushedBlockOnset.tip:
      xN = params.width / 2;
  }

  return PushedBlockStatics(
    onset: onset,
    fSlide: fSlide,
    fTip: fTip,
    normalXFromCenter: xN,
  );
}

bool pushedBlockHolds(PushedBlockParams params) =>
    pushedBlockStatics(params).holds;

/// $F$ を静かに上げるとき転倒が先になる押し高。$\displaystyle h=\frac{w}{2\mu_s}$。
double pushedBlockCriticalPushHeight(PushedBlockParams params) {
  if (params.muS <= 1e-12) return double.infinity;
  return params.width / (2 * params.muS);
}
