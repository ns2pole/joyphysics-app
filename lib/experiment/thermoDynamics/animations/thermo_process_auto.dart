/// 定積・定圧・等温・断熱の Auto（UI 非依存・単体テスト可能）
///
/// 共通ルール: 一度状態を変え、元に戻す往復を繰り返す。
/// 見える操作のあいだは [actionHoldSec]（既定 2s）待つ。
library;

import 'dart:math' as math;

// ---------------------------------------------------------------------------
// 定積・定圧: 温度往復（加熱 → 上限 → 壁外し → 冷却 → 外気温付近 → …）
// ---------------------------------------------------------------------------

enum ThermoTempAutoPhase { heating, cooling }

class ThermoTempAutoSnapshot {
  const ThermoTempAutoSnapshot({
    required this.temperature,
    required this.ambientTemp,
    required this.maxTemp,
    required this.phase,
    required this.insulated,
    required this.heating,
    required this.cooling,
  });

  final double temperature;
  final double ambientTemp;
  final double maxTemp;
  final ThermoTempAutoPhase phase;
  final bool insulated;
  final bool heating;
  final bool cooling;

  bool get atMax => temperature >= maxTemp - 1.0;
  /// 冷却で外気温付近まで戻った（元の状態）
  bool get atAmbient => temperature <= ambientTemp + 2.0;
}

class ThermoTempAutoCommand {
  const ThermoTempAutoCommand({
    this.insulated,
    this.heating,
    this.cooling,
    this.phase,
  });

  final bool? insulated;
  final bool? heating;
  final bool? cooling;
  final ThermoTempAutoPhase? phase;

  bool get isVisibleAction =>
      insulated != null || heating != null || cooling != null || phase != null;

  @override
  bool operator ==(Object other) =>
      other is ThermoTempAutoCommand &&
      other.insulated == insulated &&
      other.heating == heating &&
      other.cooling == cooling &&
      other.phase == phase;

  @override
  int get hashCode => Object.hash(insulated, heating, cooling, phase);
}

/// 1アクションずつ。断熱／加熱／冷却は同時に切り替えない。
/// 上限到達後: 加熱OFF → 壁外し → 冷却ON。復帰: 冷却OFF → 断熱ON → 加熱ON。
ThermoTempAutoCommand? nextThermoTempAutoCommand(ThermoTempAutoSnapshot s) {
  switch (s.phase) {
    case ThermoTempAutoPhase.heating:
      if (s.atMax) {
        if (s.heating) {
          return const ThermoTempAutoCommand(heating: false);
        }
        if (s.insulated) {
          return const ThermoTempAutoCommand(
            insulated: false,
            phase: ThermoTempAutoPhase.cooling,
          );
        }
        return const ThermoTempAutoCommand(
          phase: ThermoTempAutoPhase.cooling,
        );
      }
      if (s.cooling) {
        return const ThermoTempAutoCommand(cooling: false);
      }
      if (!s.insulated) {
        return const ThermoTempAutoCommand(insulated: true);
      }
      if (!s.heating) {
        return const ThermoTempAutoCommand(heating: true);
      }
      return null;
    case ThermoTempAutoPhase.cooling:
      if (s.atAmbient) {
        if (s.cooling) {
          return const ThermoTempAutoCommand(cooling: false);
        }
        if (s.heating) {
          return const ThermoTempAutoCommand(heating: false);
        }
        if (!s.insulated) {
          return const ThermoTempAutoCommand(
            insulated: true,
            phase: ThermoTempAutoPhase.heating,
          );
        }
        if (!s.heating) {
          return const ThermoTempAutoCommand(heating: true);
        }
        return null;
      }
      if (s.heating) {
        return const ThermoTempAutoCommand(heating: false);
      }
      if (s.insulated) {
        return const ThermoTempAutoCommand(insulated: false);
      }
      if (!s.cooling) {
        return const ThermoTempAutoCommand(cooling: true);
      }
      return null;
  }
}

/// Auto 中のいまの工程ラベル（UI 表示用）
String thermoTempAutoStatusLabel(ThermoTempAutoSnapshot s) {
  switch (s.phase) {
    case ThermoTempAutoPhase.heating:
      if (s.atMax) {
        if (s.heating) return '加熱を止めています';
        if (s.insulated) return '壁（断熱）を外しています';
        return '冷却に切り替えます';
      }
      if (s.cooling) return '冷却を止めています';
      if (!s.insulated) return '断熱材を入れています';
      if (!s.heating) return '加熱を始めています';
      return '加熱中';
    case ThermoTempAutoPhase.cooling:
      if (s.atAmbient) {
        if (s.cooling) return '冷却を止めています';
        if (!s.insulated) return '断熱材を入れています';
        if (!s.heating) return '加熱を始めています';
        return '加熱中';
      }
      if (s.heating) return '加熱を止めています';
      if (s.insulated) return '壁（断熱）を外しています';
      if (!s.cooling) return '冷却を開始しています';
      return '冷却中';
  }
}

String thermoTempAutoCommandLabel(ThermoTempAutoCommand cmd) {
  if (cmd.cooling == true) return '冷却を開始しています';
  if (cmd.cooling == false &&
      cmd.insulated == null &&
      cmd.heating == null &&
      cmd.phase == null) {
    return '冷却を止めています';
  }
  if (cmd.heating == false && cmd.insulated == null && cmd.cooling != true) {
    return '加熱を止めています';
  }
  if (cmd.insulated == false) return '壁（断熱）を外しています';
  if (cmd.insulated == true) return '断熱材を入れています';
  if (cmd.heating == true) return '加熱を始めています';
  return '自動サイクル中';
}

class ThermoTempAutoSession {
  ThermoTempAutoSession({
    required this.ambientTemp,
    required this.maxTemp,
    this.temperature = 300.0,
    this.phase = ThermoTempAutoPhase.heating,
    this.insulated = false,
    this.heating = false,
    this.cooling = false,
    this.actionHoldSec = 2.0,
  });

  final double ambientTemp;
  final double maxTemp;
  final double actionHoldSec;

  double temperature;
  ThermoTempAutoPhase phase;
  bool insulated;
  bool heating;
  bool cooling;
  double holdRemainingSec = 0.0;
  String? holdStatusLabel;

  bool get isHolding => holdRemainingSec > 1e-9;

  ThermoTempAutoSnapshot get snapshot => ThermoTempAutoSnapshot(
        temperature: temperature,
        ambientTemp: ambientTemp,
        maxTemp: maxTemp,
        phase: phase,
        insulated: insulated,
        heating: heating,
        cooling: cooling,
      );

  String get statusLabel {
    if (isHolding && holdStatusLabel != null) return holdStatusLabel!;
    return thermoTempAutoStatusLabel(snapshot);
  }

  ThermoTempAutoCommand? onPhysicsSample(
    double sampleTemp, {
    double dt = 1 / 60,
  }) {
    temperature = sampleTemp;
    if (holdRemainingSec > 0) {
      holdRemainingSec -= dt;
      if (holdRemainingSec < 0) holdRemainingSec = 0;
      if (holdRemainingSec <= 0) holdStatusLabel = null;
      return null;
    }
    return applyTick();
  }

  ThermoTempAutoCommand? applyTick() {
    final cmd = nextThermoTempAutoCommand(snapshot);
    if (cmd == null) return null;
    if (cmd.insulated != null) insulated = cmd.insulated!;
    if (cmd.heating != null) heating = cmd.heating!;
    if (cmd.cooling != null) cooling = cmd.cooling!;
    if (cmd.phase != null) phase = cmd.phase!;
    if (cmd.isVisibleAction && actionHoldSec > 0) {
      holdRemainingSec = actionHoldSec;
      holdStatusLabel = thermoTempAutoCommandLabel(cmd);
    }
    return cmd;
  }

  void reset() {
    temperature = ambientTemp;
    phase = ThermoTempAutoPhase.heating;
    insulated = false;
    heating = false;
    cooling = false;
    holdRemainingSec = 0;
    holdStatusLabel = null;
  }
}

// ---------------------------------------------------------------------------
// 等温・断熱: 体積往復（膨張 → 遠端 → 圧縮 → 初期体積 → …）
// ---------------------------------------------------------------------------

enum ThermoVolumeAutoPhase { expanding, compressing }

class ThermoVolumeAutoSnapshot {
  const ThermoVolumeAutoSnapshot({
    required this.volume,
    required this.homeVolume,
    required this.farVolume,
    required this.phase,
  });

  final double volume;
  final double homeVolume;
  final double farVolume;
  final ThermoVolumeAutoPhase phase;

  bool get atFar => volume >= farVolume - 0.02;
  bool get atHome => volume <= homeVolume + 0.02;
}

/// 次の目標体積。到達していれば相を切り替える。
class ThermoVolumeAutoCommand {
  const ThermoVolumeAutoCommand({
    required this.targetVolume,
    this.phase,
  });

  final double targetVolume;
  final ThermoVolumeAutoPhase? phase;

  @override
  bool operator ==(Object other) =>
      other is ThermoVolumeAutoCommand &&
      other.targetVolume == targetVolume &&
      other.phase == phase;

  @override
  int get hashCode => Object.hash(targetVolume, phase);
}

ThermoVolumeAutoCommand nextThermoVolumeAutoCommand(ThermoVolumeAutoSnapshot s) {
  switch (s.phase) {
    case ThermoVolumeAutoPhase.expanding:
      if (s.atFar) {
        return ThermoVolumeAutoCommand(
          targetVolume: s.homeVolume,
          phase: ThermoVolumeAutoPhase.compressing,
        );
      }
      return ThermoVolumeAutoCommand(targetVolume: s.farVolume);
    case ThermoVolumeAutoPhase.compressing:
      if (s.atHome) {
        return ThermoVolumeAutoCommand(
          targetVolume: s.farVolume,
          phase: ThermoVolumeAutoPhase.expanding,
        );
      }
      return ThermoVolumeAutoCommand(targetVolume: s.homeVolume);
  }
}

String thermoVolumeAutoStatusLabel(ThermoVolumeAutoSnapshot s) {
  switch (s.phase) {
    case ThermoVolumeAutoPhase.expanding:
      if (s.atFar) return '上端で待機中';
      return '膨張中';
    case ThermoVolumeAutoPhase.compressing:
      if (s.atHome) return '下端で待機中';
      return '圧縮中';
  }
}

class ThermoVolumeAutoSession {
  ThermoVolumeAutoSession({
    required this.homeVolume,
    required this.farVolume,
    double? volume,
    this.phase = ThermoVolumeAutoPhase.expanding,
    this.speedLps = 0.35,
    this.actionHoldSec = 2.0,
  }) : volume = volume ?? homeVolume;

  final double homeVolume;
  final double farVolume;

  /// 体積の変化速度 [L/s]
  final double speedLps;
  final double actionHoldSec;

  double volume;
  ThermoVolumeAutoPhase phase;
  double holdRemainingSec = 0.0;
  double? _holdAtVolume;
  String? holdStatusLabel;

  bool get isHolding => holdRemainingSec > 1e-9;

  ThermoVolumeAutoSnapshot get snapshot => ThermoVolumeAutoSnapshot(
        volume: volume,
        homeVolume: homeVolume,
        farVolume: farVolume,
        phase: phase,
      );

  String get statusLabel {
    if (isHolding && holdStatusLabel != null) return holdStatusLabel!;
    return thermoVolumeAutoStatusLabel(snapshot);
  }

  /// 現在体積を進め、新しい体積を返す（ホールド中は同じ値）。
  double onPhysicsSample(double currentVolume, {double dt = 1 / 60}) {
    volume = currentVolume.clamp(
      math.min(homeVolume, farVolume),
      math.max(homeVolume, farVolume),
    );
    if (holdRemainingSec > 0) {
      holdRemainingSec -= dt;
      if (holdRemainingSec < 0) holdRemainingSec = 0;
      if (holdRemainingSec <= 0) holdStatusLabel = null;
      return _holdAtVolume ?? volume;
    }

    final target = phase == ThermoVolumeAutoPhase.expanding
        ? farVolume
        : homeVolume;
    final step = speedLps * dt;
    if ((target - volume).abs() <= step) {
      volume = target;
    } else if (target > volume) {
      volume += step;
    } else {
      volume -= step;
    }

    // 端点到達で相転換（同じサンプル内で確定）
    if (phase == ThermoVolumeAutoPhase.expanding && volume >= farVolume - 0.02) {
      volume = farVolume;
      phase = ThermoVolumeAutoPhase.compressing;
      if (actionHoldSec > 0) {
        holdRemainingSec = actionHoldSec;
        _holdAtVolume = volume;
        holdStatusLabel = '上端で待機中';
      }
    } else if (phase == ThermoVolumeAutoPhase.compressing &&
        volume <= homeVolume + 0.02) {
      volume = homeVolume;
      phase = ThermoVolumeAutoPhase.expanding;
      if (actionHoldSec > 0) {
        holdRemainingSec = actionHoldSec;
        _holdAtVolume = volume;
        holdStatusLabel = '下端で待機中';
      }
    } else {
      _holdAtVolume = null;
    }
    return volume;
  }

  void reset() {
    volume = homeVolume;
    phase = ThermoVolumeAutoPhase.expanding;
    holdRemainingSec = 0;
    _holdAtVolume = null;
    holdStatusLabel = null;
  }
}
