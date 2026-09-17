/// 熱サイクル Auto の判定（UI 非依存・単体テスト可能）
///
/// ルール（ユーザー指定）:
/// 1. 温度が上がらなくなった（上限）→ 荷物下ろし → 錘載せ → 断熱解除（各ステップ）
/// 2. 温度が下がり切った（下限）→ 錘外し → 荷物載せ → 断熱＋加熱
/// 見える操作のあいだは [HeatCycleAutoSession.actionHoldSec]（既定 2s）待つ。
library;

class HeatCycleAutoSnapshot {
  const HeatCycleAutoSnapshot({
    required this.temperature,
    required this.minTemp,
    required this.maxTemp,
    required this.weights,
    required this.cargoLiftMode,
    required this.cargoOn,
    required this.insulated,
    required this.heating,
    this.volume = 0.25,
    this.vMin = 0.25,
    this.vMax = 0.70,
  });

  final double temperature;
  final double minTemp;
  final double maxTemp;
  final int weights;
  final bool cargoLiftMode;
  final bool cargoOn;
  final bool insulated;
  final bool heating;
  final double volume;
  final double vMin;
  final double vMax;

  bool get atMax => temperature >= maxTemp - 1.0;
  bool get atMin => temperature <= minTemp + 1.0;
  bool get atTopVolume => volume >= vMax - 0.02;
  bool get atBottomVolume => volume <= vMin + 0.02;
}

/// null のフィールドは変更しない（1ティック1系統の操作を基本とする）
class HeatCycleAutoCommand {
  const HeatCycleAutoCommand({
    this.weights,
    this.cargoOn,
    this.insulated,
    this.heating,
  });

  final int? weights;
  final bool? cargoOn;
  final bool? insulated;
  final bool? heating;

  /// 画面で追いやすい操作（ホールド対象）。1フィールドずつ切り替える。
  bool get isVisibleAction =>
      weights != null ||
      cargoOn != null ||
      insulated != null ||
      heating != null;

  @override
  bool operator ==(Object other) =>
      other is HeatCycleAutoCommand &&
      other.weights == weights &&
      other.cargoOn == cargoOn &&
      other.insulated == insulated &&
      other.heating == heating;

  @override
  int get hashCode => Object.hash(weights, cargoOn, insulated, heating);

  @override
  String toString() =>
      'HeatCycleAutoCommand(weights: $weights, cargoOn: $cargoOn, '
      'insulated: $insulated, heating: $heating)';
}

/// いまの状態から、次にやるべき **1アクション** を返す。
/// すでに望ましい状態なら null。
/// 断熱／加熱／荷物／錘は同時に切り替えない（各操作のあいだにホールドが入る）。
HeatCycleAutoCommand? nextHeatCycleAutoCommand(HeatCycleAutoSnapshot s) {
  final w = s.weights.clamp(0, 1);

  // --- 錘あり ---
  if (w == 1) {
    // 加熱OFF → 断熱OFF の順（同時にやらない）
    if (s.heating) {
      return const HeatCycleAutoCommand(heating: false);
    }
    if (s.insulated) {
      return const HeatCycleAutoCommand(insulated: false);
    }
    if (s.atMin) {
      return const HeatCycleAutoCommand(weights: 0);
    }
    return null; // 放熱冷却継続
  }

  // --- 錘なし・上限: 荷物下ろし → 錘載せ ---
  if (s.atMax) {
    if (s.cargoOn) {
      return const HeatCycleAutoCommand(cargoOn: false);
    }
    return const HeatCycleAutoCommand(weights: 1);
  }

  // --- 錘なし・加熱相の維持／下限からの復帰 ---
  // 荷物 → 断熱材ON → 加熱ON の順
  if (s.cargoLiftMode && !s.cargoOn) {
    return const HeatCycleAutoCommand(cargoOn: true);
  }
  if (!s.cargoLiftMode && s.cargoOn) {
    return const HeatCycleAutoCommand(cargoOn: false);
  }
  if (!s.insulated) {
    return const HeatCycleAutoCommand(insulated: true);
  }
  if (!s.heating) {
    return const HeatCycleAutoCommand(heating: true);
  }
  return null;
}

/// Auto 中のいまの工程ラベル（UI 表示用）
String heatCycleAutoStatusLabel(HeatCycleAutoSnapshot s) {
  final w = s.weights.clamp(0, 1);

  if (w == 1) {
    if (s.heating) return '加熱を止めています';
    if (s.insulated) return '壁（断熱）を外しています';
    if (s.atMin) return '下限到達・錘を外します';
    return '放熱により冷却中';
  }

  if (s.atMax) {
    if (s.cargoOn) return '荷物を下ろしています';
    return '上限到達・錘を載せます';
  }

  if (s.cargoLiftMode && !s.cargoOn) return '荷物を載せています';
  if (!s.cargoLiftMode && s.cargoOn) return '荷物を外しています';
  if (!s.insulated) return '断熱材を入れています';
  if (!s.heating) return '加熱を始めています';

  // 加熱相: 体積で定圧膨張 ↔ 定積昇圧を切り替える
  if (s.atTopVolume) return '定積昇圧';
  if (s.cargoOn && s.atBottomVolume) return '定積昇圧';
  return '定圧膨張';
}

String heatCycleAutoCommandLabel(HeatCycleAutoCommand cmd) {
  if (cmd.cargoOn == false) return '荷物を下ろしています';
  if (cmd.cargoOn == true) return '荷物を載せています';
  if (cmd.weights == 1) return '錘を載せています';
  if (cmd.weights == 0) return '錘を外しています';
  if (cmd.insulated == false) return '壁（断熱）を外しています';
  if (cmd.insulated == true) return '断熱材を入れています';
  if (cmd.heating == false) return '加熱を止めています';
  if (cmd.heating == true) return '加熱を始めています';
  return '自動サイクル中';
}

/// 物理フレームごとに呼ぶ Auto セッション（UI 非依存）。
///
/// 見える操作のあと [actionHoldSec] 秒は次の操作に進まない。
class HeatCycleAutoSession {
  HeatCycleAutoSession({
    required this.minTemp,
    required this.maxTemp,
    this.temperature = 300.0,
    this.weights = 0,
    this.cargoLiftMode = false,
    this.cargoOn = false,
    this.insulated = true,
    this.heating = false,
    this.volume = 0.25,
    this.vMin = 0.25,
    this.vMax = 0.70,
    this.actionHoldSec = 2.0,
  });

  final double minTemp;
  final double maxTemp;
  final double vMin;
  final double vMax;

  /// 荷物／錘／断熱の切り替え後に待つ秒数
  final double actionHoldSec;

  double temperature;
  int weights;
  bool cargoLiftMode;
  bool cargoOn;
  bool insulated;
  bool heating;
  double volume;

  /// 次の操作まで残っているホールド時間（秒）
  double holdRemainingSec = 0.0;

  /// ホールド中に表示する直前操作ラベル
  String? holdStatusLabel;

  bool get isHolding => holdRemainingSec > 1e-9;

  HeatCycleAutoSnapshot get snapshot => HeatCycleAutoSnapshot(
        temperature: temperature,
        minTemp: minTemp,
        maxTemp: maxTemp,
        weights: weights,
        cargoLiftMode: cargoLiftMode,
        cargoOn: cargoOn,
        insulated: insulated,
        heating: heating,
        volume: volume,
        vMin: vMin,
        vMax: vMax,
      );

  /// UI 用。ホールド中は直前操作、それ以外は状態ベース。
  String get statusLabel {
    if (isHolding && holdStatusLabel != null) return holdStatusLabel!;
    return heatCycleAutoStatusLabel(snapshot);
  }

  /// 1 物理フレーム。[temperature] が前回と同じでも評価する（ホールド中は除く）。
  HeatCycleAutoCommand? onPhysicsSample(
    double sampleTemp, {
    double? sampleVolume,
    double dt = 1 / 60,
  }) {
    temperature = sampleTemp;
    if (sampleVolume != null) volume = sampleVolume;
    if (holdRemainingSec > 0) {
      holdRemainingSec -= dt;
      if (holdRemainingSec < 0) holdRemainingSec = 0;
      if (holdRemainingSec <= 0) holdStatusLabel = null;
      return null;
    }
    return applyTick();
  }

  HeatCycleAutoCommand? applyTick() {
    final cmd = nextHeatCycleAutoCommand(snapshot);
    if (cmd == null) return null;
    if (cmd.weights != null) weights = cmd.weights!.clamp(0, 1);
    if (cmd.cargoOn != null) cargoOn = cmd.cargoOn!;
    if (cmd.insulated != null) insulated = cmd.insulated!;
    if (cmd.heating != null) heating = cmd.heating!;
    if (cmd.isVisibleAction && actionHoldSec > 0) {
      holdRemainingSec = actionHoldSec;
      holdStatusLabel = heatCycleAutoCommandLabel(cmd);
    }
    return cmd;
  }
}
