import 'dart:math' as math;

/// 壁滑らか・床粗い立て掛け棒の共通定数・パラメータ。
///
/// 角度 θ は**棒と壁**の角（壁は鉛直）。床との角は $\pi/2-\theta$。
const double kLeaningRodG = 9.8;
const double kLeaningRodMass = 1.0;
const double kLeaningRodLength = 2.0;
/// 壁との角（度）。小さいほど直立に近く、大きいほど寝かす。
const double kLeaningRodMinTheta = 10.0;
const double kLeaningRodMaxTheta = 70.0;
const double kLeaningRodDefaultTheta = 30.0;
const double kLeaningRodMinMu = 0.0;
const double kLeaningRodMaxMu = 1.0;
const double kLeaningRodMuGap = 0.15;
const double kLeaningRodMinMuS = 0.15;
const double kLeaningRodMaxMuS = 1.15;
const double kLeaningRodDefaultMuK = 0.25;
const double kLeaningRodDefaultMuS = 0.45;
/// 床との角がこれ以下で倒れ扱い（内部は床角で積分）。
const double kLeaningRodFlatTheta = 0.04;
/// 描画の物理視野（m）。角度や滑りでズームしない。壁・床の見た目を固定する。
const double kLeaningRodViewWidth = 3.2;
const double kLeaningRodViewHeight = 2.6;

/// Auto デモで θ を段階的に上げる間隔。
const Duration kLeaningRodDemoRampPeriod = Duration(milliseconds: 40);

/// Auto デモで θ を目標まで上げ切るおおよそのステップ数（〜1.6 s）。
const int kLeaningRodDemoRampSteps = 40;

enum LeaningRodDemo { slip }

/// 滑りデモの初期形（静止する θ・μ）。
Map<String, double> leaningRodDemoShape(LeaningRodDemo demo) {
  switch (demo) {
    case LeaningRodDemo.slip:
      return {
        'theta': 25.0,
        'mu': 0.25,
        'muS': 0.45,
      };
  }
}

/// 形固定のうえで滑り出す θ（限界の少し上、度）。
double leaningRodDemoThetaDeg(LeaningRodParams shape) {
  final crit = math.atan(2 * shape.muS) * 180 / math.pi;
  return (crit * 1.18)
      .clamp(kLeaningRodMinTheta, kLeaningRodMaxTheta)
      .toDouble();
}

class LeaningRodParams {
  const LeaningRodParams({
    required this.thetaDeg,
    required this.muK,
    required this.muS,
  });

  /// 棒と壁の角（度）。
  final double thetaDeg;
  final double muK;
  final double muS;

  /// 棒と壁の角（rad）。
  double get theta => thetaDeg * math.pi / 180.0;

  /// 棒と床の角（rad）。$\displaystyle\frac{\pi}{2}-\theta$。力学の積分はこちら。
  double get thetaFloor => math.pi / 2 - theta;

  double get mass => kLeaningRodMass;
  double get length => kLeaningRodLength;
  double get weight => mass * kLeaningRodG;

  factory LeaningRodParams.fromMap(Map<String, double> params) {
    var muK = params['mu']!.clamp(kLeaningRodMinMu, kLeaningRodMaxMu).toDouble();
    var muS = (params['muS'] ?? (muK + kLeaningRodMuGap))
        .clamp(kLeaningRodMinMuS, kLeaningRodMaxMuS)
        .toDouble();
    if (muS < muK + kLeaningRodMuGap) {
      if (muK + kLeaningRodMuGap <= kLeaningRodMaxMuS) {
        muS = muK + kLeaningRodMuGap;
      } else {
        muS = kLeaningRodMaxMuS;
        muK = muS - kLeaningRodMuGap;
      }
    }
    return LeaningRodParams(
      thetaDeg: params['theta']!
          .clamp(kLeaningRodMinTheta, kLeaningRodMaxTheta)
          .toDouble(),
      muK: muK,
      muS: muS,
    );
  }
}
