/// 熱サイクル Auto の判定（UI 非依存・単体テスト可能）
///
/// 荷物持ち上げ: 体積上端 → 加熱OFF → 荷物下ろし → 断熱解除
/// / 下限 → 荷物載せ → 断熱＋加熱
/// 見える操作のあいだは [HeatCycleAutoSession.actionHoldSec]（既定 2s）待つ。
library;

class HeatCycleAutoSnapshot {
  const HeatCycleAutoSnapshot({
    required this.temperature,
    required this.minTemp,
    required this.cargoOn,
    required this.insulated,
    required this.heating,
    this.volume = 0.25,
    this.vMin = 0.25,
    this.vMax = 0.70,
  });

  final double temperature;
  final double minTemp;
  final bool cargoOn;
  final bool insulated;
  final bool heating;
  final double volume;
  final double vMin;
  final double vMax;

  bool get atMin => temperature <= minTemp + 1.0;
  bool get atTopVolume => volume >= vMax - 0.02;
  bool get atBottomVolume => volume <= vMin + 0.02;
}

class HeatCycleAutoCommand {
  const HeatCycleAutoCommand({
    this.cargoOn,
    this.insulated,
    this.heating,
  });

  final bool? cargoOn;
  final bool? insulated;
  final bool? heating;

  bool get isVisibleAction =>
      cargoOn != null || insulated != null || heating != null;

  @override
  bool operator ==(Object other) =>
      other is HeatCycleAutoCommand &&
      other.cargoOn == cargoOn &&
      other.insulated == insulated &&
      other.heating == heating;

  @override
  int get hashCode => Object.hash(cargoOn, insulated, heating);

  @override
  String toString() =>
      'HeatCycleAutoCommand(cargoOn: $cargoOn, insulated: $insulated, '
      'heating: $heating)';
}

HeatCycleAutoCommand? nextHeatCycleAutoCommand(HeatCycleAutoSnapshot s) {
  if (s.atTopVolume) {
    if (s.heating) {
      return const HeatCycleAutoCommand(heating: false);
    }
    if (s.cargoOn) {
      return const HeatCycleAutoCommand(cargoOn: false);
    }
    if (s.insulated) {
      return const HeatCycleAutoCommand(insulated: false);
    }
    return null;
  }

  if (!s.cargoOn) {
    if (s.atMin) {
      return const HeatCycleAutoCommand(cargoOn: true);
    }
    if (!s.insulated) {
      if (s.heating) {
        return const HeatCycleAutoCommand(heating: false);
      }
      return null;
    }
    return const HeatCycleAutoCommand(cargoOn: true);
  }

  if (!s.insulated) {
    return const HeatCycleAutoCommand(insulated: true);
  }
  if (!s.heating) {
    return const HeatCycleAutoCommand(heating: true);
  }
  return null;
}

String heatCycleAutoStatusLabel(HeatCycleAutoSnapshot s) {
  if (s.atTopVolume) {
    if (s.heating) return '加熱を止めています';
    if (s.cargoOn) return '荷物を下ろしています';
    if (s.insulated) return '壁（断熱）を外しています';
    return '放熱により冷却中';
  }

  if (!s.cargoOn) {
    if (s.atMin) return '荷物を載せています';
    if (!s.insulated) {
      if (s.heating) return '加熱を止めています';
      return '放熱により冷却中';
    }
    return '荷物を載せています';
  }
  if (!s.insulated) return '断熱材を入れています';
  if (!s.heating) return '加熱を始めています';

  if (s.atBottomVolume) return '定積昇圧';
  return '定圧膨張';
}

String heatCycleAutoCommandLabel(HeatCycleAutoCommand cmd) {
  if (cmd.cargoOn == false) return '荷物を下ろしています';
  if (cmd.cargoOn == true) return '荷物を載せています';
  if (cmd.insulated == false) return '壁（断熱）を外しています';
  if (cmd.insulated == true) return '断熱材を入れています';
  if (cmd.heating == false) return '加熱を止めています';
  if (cmd.heating == true) return '加熱を始めています';
  return '自動サイクル中';
}

class HeatCycleAutoSession {
  HeatCycleAutoSession({
    required this.minTemp,
    this.temperature = 300.0,
    this.cargoOn = true,
    this.insulated = true,
    this.heating = false,
    this.volume = 0.25,
    this.vMin = 0.25,
    this.vMax = 0.70,
    this.actionHoldSec = 2.0,
  });

  final double minTemp;
  final double vMin;
  final double vMax;
  final double actionHoldSec;

  double temperature;
  bool cargoOn;
  bool insulated;
  bool heating;
  double volume;

  double holdRemainingSec = 0.0;
  String? holdStatusLabel;

  bool get isHolding => holdRemainingSec > 1e-9;

  HeatCycleAutoSnapshot get snapshot => HeatCycleAutoSnapshot(
        temperature: temperature,
        minTemp: minTemp,
        cargoOn: cargoOn,
        insulated: insulated,
        heating: heating,
        volume: volume,
        vMin: vMin,
        vMax: vMax,
      );

  String get statusLabel {
    if (isHolding && holdStatusLabel != null) return holdStatusLabel!;
    return heatCycleAutoStatusLabel(snapshot);
  }

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
