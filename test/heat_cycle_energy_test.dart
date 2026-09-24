import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/thermoDynamics/animations/heat_cycle_energy.dart';

void main() {
  test('一周すると W = Q - Q\' で熱効率が出る', () {
    const pLow = 1013.0;
    const pHigh = 1313.0;
    const vLow = 1.0;
    const vHigh = 2.8;
    const t0 = 300.0;
    final t1 = t0 * (pHigh / pLow);
    final t2 = t1 * (vHigh / vLow);
    final t3 = t0 * (vHigh / vLow);

    final ledger = HeatCycleEnergyLedger();
    void leg({
      required double t0,
      required double t1,
      required double v0,
      required double v1,
      required double p0,
      required double p1,
      required bool cargoOn,
      int steps = 40,
    }) {
      for (var i = 1; i <= steps; i++) {
        final u = i / steps;
        ledger.sample(
          temperatureK: t0 + (t1 - t0) * u,
          volumeL: v0 + (v1 - v0) * u,
          pressureHPa: p0 + (p1 - p0) * u,
          cargoOn: cargoOn,
        );
      }
    }

    ledger.sample(
      temperatureK: t0,
      volumeL: vLow,
      pressureHPa: pLow,
      cargoOn: true,
    );
    leg(t0: t0, t1: t1, v0: vLow, v1: vLow, p0: pLow, p1: pHigh, cargoOn: true);
    leg(t0: t1, t1: t2, v0: vLow, v1: vHigh, p0: pHigh, p1: pHigh, cargoOn: true);
    leg(t0: t2, t1: t3, v0: vHigh, v1: vHigh, p0: pHigh, p1: pLow, cargoOn: false);
    leg(t0: t3, t1: t0, v0: vHigh, v1: vLow, p0: pLow, p1: pLow, cargoOn: false);
    ledger.sample(
      temperatureK: t0,
      volumeL: vLow,
      pressureHPa: pLow,
      cargoOn: true,
    );

    expect(ledger.completed, 1);
    final q = ledger.closedHeatInJ!;
    final qp = ledger.closedHeatOutJ!;
    expect(ledger.closedWorkJ, closeTo(q - qp, 1e-6));

    final wGeom = heatCycleNetWorkJ(
      pLowHPa: pLow,
      pHighHPa: pHigh,
      vLowL: vLow,
      vHighL: vHigh,
    );
    expect(ledger.closedWorkJ, closeTo(wGeom, 1.5));
    expect(
      ledger.closedEfficiency,
      closeTo(heatCycleEfficiencyFromHeats(q, qp), 1e-9),
    );
    expect(ledger.closedEfficiency!, greaterThan(0));
    expect(ledger.closedEfficiency!, lessThan(1));
  });
}
