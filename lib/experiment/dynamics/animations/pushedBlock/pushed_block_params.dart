import 'dart:math' as math;

/// 粗い床上の直方体を水平力で押す。質量は当面固定だが [pushedBlockMass] で差し替え可能。
const double kPushedBlockG = 9.8;
const double kPushedBlockFixedMass = 1.0;
/// 将来 $m=\rho w H$ にするときの密度。いまは未使用。
const double kPushedBlockDensity = 1.0;
const bool kPushedBlockMassFromArea = false;

const double kPushedBlockMinW = 0.40;
const double kPushedBlockMaxW = 1.60;
const double kPushedBlockDefaultW = 0.80;
const double kPushedBlockMinH = 0.40;
const double kPushedBlockMaxH = 2.00;
const double kPushedBlockDefaultH = 1.20;
const double kPushedBlockMinPushH = 0.05;
const double kPushedBlockMinF = 0.0;
const double kPushedBlockMaxF = 20.0;
const double kPushedBlockDefaultF = 1.5;
const double kPushedBlockMinMu = 0.0;
const double kPushedBlockMaxMu = 1.0;
const double kPushedBlockMuGap = 0.15;
const double kPushedBlockMinMuS = 0.15;
const double kPushedBlockMaxMuS = 1.15;
const double kPushedBlockDefaultMuK = 0.30;
const double kPushedBlockDefaultMuS = 0.50;
/// 描画の物理視野（m）。現在の w/H や滑り位置でズームしない。
/// 直方体が見やすいよう、やや寄った視野（約 1.5 倍表示）。
const double kPushedBlockViewWidth = 5.0 / 1.5;
const double kPushedBlockViewHeight = 3.0 / 1.5;
/// 滑走停止判定。左端が視野右端付近を超えたら画面外（見切れたらすぐ）。
const double kPushedBlockOffscreenX = kPushedBlockViewWidth - 0.35;
final double kPushedBlockOnSideTheta = math.pi / 2 - 0.02;

/// 終了後、自動リセットまでの待ち。
const Duration kPushedBlockAutoResetDelay = Duration(milliseconds: 650);

/// Auto デモで F を段階的に上げる間隔。
const Duration kPushedBlockDemoRampPeriod = Duration(milliseconds: 40);

/// Auto デモで F を目標まで上げ切るおおよそのステップ数（〜1.6 s）。
const int kPushedBlockDemoRampSteps = 40;

enum PushedBlockDemo { slide, tip }

/// 滑り／転倒デモの初期形（F=0 で静止）。
Map<String, double> pushedBlockDemoShape(PushedBlockDemo demo) {
  switch (demo) {
    case PushedBlockDemo.slide:
      return {
        'w': 1.10,
        'H': 0.75,
        'h': 0.22,
        'F': 0.0,
        'mu': 0.28,
        'muS': 0.45,
      };
    case PushedBlockDemo.tip:
      return {
        'w': 0.65,
        'H': 1.55,
        'h': 1.25,
        'F': 0.0,
        'mu': 0.30,
        'muS': 0.55,
      };
  }
}

/// 形固定のうえで該当モードが始まる F（限界の少し上）。
double pushedBlockDemoForce(PushedBlockParams shape) {
  final mg = shape.weight;
  final h = shape.pushHeight.clamp(1e-9, shape.height);
  final fSlide = shape.muS * mg;
  final fTip = mg * shape.width / (2 * h);
  final limit = fSlide <= fTip ? fSlide : fTip;
  return (limit * 1.18)
      .clamp(kPushedBlockMinF, kPushedBlockMaxF)
      .toDouble();
}

/// 質量。拡張時は [kPushedBlockMassFromArea] を true にするか、ここを差し替える。
double pushedBlockMass(double width, double height) {
  if (kPushedBlockMassFromArea) {
    return kPushedBlockDensity * width * height;
  }
  return kPushedBlockFixedMass;
}

class PushedBlockParams {
  const PushedBlockParams({
    required this.width,
    required this.height,
    required this.pushHeight,
    required this.force,
    required this.muK,
    required this.muS,
  });

  final double width;
  final double height;
  final double pushHeight;
  final double force;
  final double muK;
  final double muS;

  double get mass => pushedBlockMass(width, height);
  double get weight => mass * kPushedBlockG;

  /// 右下端まわりの慣性モーメント。$\displaystyle I_P=\frac{m}{3}(w^{2}+H^{2})$。
  double get inertiaAboutPivot => mass * (width * width + height * height) / 3.0;

  factory PushedBlockParams.fromMap(Map<String, double> params) {
    final w = params['w']!
        .clamp(kPushedBlockMinW, kPushedBlockMaxW)
        .toDouble();
    final hBlock = params['H']!
        .clamp(kPushedBlockMinH, kPushedBlockMaxH)
        .toDouble();
    final push = params['h']!
        .clamp(kPushedBlockMinPushH, hBlock)
        .toDouble();
    var muK =
        params['mu']!.clamp(kPushedBlockMinMu, kPushedBlockMaxMu).toDouble();
    var muS = (params['muS'] ?? (muK + kPushedBlockMuGap))
        .clamp(kPushedBlockMinMuS, kPushedBlockMaxMuS)
        .toDouble();
    if (muS < muK + kPushedBlockMuGap) {
      if (muK + kPushedBlockMuGap <= kPushedBlockMaxMuS) {
        muS = muK + kPushedBlockMuGap;
      } else {
        muS = kPushedBlockMaxMuS;
        muK = muS - kPushedBlockMuGap;
      }
    }
    return PushedBlockParams(
      width: w,
      height: hBlock,
      pushHeight: push,
      force: params['F']!
          .clamp(kPushedBlockMinF, kPushedBlockMaxF)
          .toDouble(),
      muK: muK,
      muS: muS,
    );
  }

  /// デフォルト押し高（高さの半分、上限はブロック高）。
  static double defaultPushHeight(double blockHeight) =>
      (blockHeight * 0.5).clamp(kPushedBlockMinPushH, blockHeight);
}
