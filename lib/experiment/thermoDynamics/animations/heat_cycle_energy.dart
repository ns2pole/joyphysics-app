import 'dart:math' as math;

import 'common.dart';

/// 熱サイクル一周の熱と仕事。
///
/// 単原子理想気体。\(Q\) は与えた熱、\(Q'\) は捨てた熱（正）。
/// 一周で \(\Delta U=0\) なので \(W=Q-Q'\)、熱効率 \(\eta=W/Q\)。
class HeatCycleEnergyLedger {
  static final double nR = () {
    const pPa = IdealGasRef.p0HPa * 100.0;
    const vM3 = IdealGasRef.v0L * 1e-3;
    return pPa * vM3 / IdealGasRef.t0K;
  }();

  static const double cvOverNR = 1.5;

  double _qIn = 0;
  double _qOut = 0;
  double? _t;
  double? _vL;
  double? _pHPa;
  bool _departed = false;

  int completed = 0;
  double? closedHeatInJ;
  double? closedHeatOutJ;

  double get closedWorkJ {
    final q = closedHeatInJ;
    final qp = closedHeatOutJ;
    if (q == null || qp == null) return 0;
    return q - qp;
  }

  double? get closedEfficiency {
    final q = closedHeatInJ;
    if (q == null || q <= 1e-9) return null;
    return closedWorkJ / q;
  }

  void reset() {
    _qIn = 0;
    _qOut = 0;
    _t = null;
    _vL = null;
    _pHPa = null;
    _departed = false;
    completed = 0;
    closedHeatInJ = null;
    closedHeatOutJ = null;
  }

  /// 状態を1サンプル進める。初期状態へ戻ったら一周として確定する。
  void sample({
    required double temperatureK,
    required double volumeL,
    required double pressureHPa,
    required bool cargoOn,
    double closeTempK = 301.0,
    double closeVolumeL = 1.05,
  }) {
    if (_t != null && _vL != null && _pHPa != null) {
      final dT = temperatureK - _t!;
      final dVM3 = (volumeL - _vL!) * 1e-3;
      final pPa = 0.5 * (pressureHPa + _pHPa!) * 100.0;
      final dW = pPa * dVM3;
      final dU = cvOverNR * nR * dT;
      final dQ = dU + dW;
      if (dQ >= 0) {
        _qIn += dQ;
      } else {
        _qOut += -dQ;
      }
    }
    _t = temperatureK;
    _vL = volumeL;
    _pHPa = pressureHPa;

    final atStart = cargoOn &&
        temperatureK <= closeTempK &&
        volumeL <= closeVolumeL;
    if (!atStart &&
        (temperatureK > closeTempK + 5 || volumeL > closeVolumeL + 0.05)) {
      _departed = true;
    }
    if (_departed && atStart && _qIn > 1 && _qOut > 1) {
      completed++;
      closedHeatInJ = _qIn;
      closedHeatOutJ = _qOut;
      _qIn = 0;
      _qOut = 0;
      _departed = false;
    }
  }
}

/// 矩形に近い熱サイクル（定積加熱→定圧膨張→定積放熱→定圧圧縮）を積分したときの目安。
double heatCycleNetWorkJ({
  required double pLowHPa,
  required double pHighHPa,
  required double vLowL,
  required double vHighL,
}) {
  final dPPa = (pHighHPa - pLowHPa) * 100.0;
  final dVM3 = (vHighL - vLowL) * 1e-3;
  return dPPa * dVM3;
}

double heatCycleEfficiencyFromHeats(double heatInJ, double heatOutJ) {
  if (heatInJ.abs() < 1e-12) return 0;
  return math.max(0, (heatInJ - heatOutJ) / heatInJ);
}
