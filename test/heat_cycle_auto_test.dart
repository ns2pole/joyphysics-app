import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/thermoDynamics/animations/heat_cycle_auto.dart';

void main() {
  const minT = 300.0;

  HeatCycleAutoSnapshot snap({
    required double temperature,
    bool cargoOn = true,
    bool insulated = true,
    bool heating = true,
    double volume = 0.40,
  }) {
    return HeatCycleAutoSnapshot(
      temperature: temperature,
      minTemp: minT,
      cargoOn: cargoOn,
      insulated: insulated,
      heating: heating,
      volume: volume,
      vMin: 0.25,
      vMax: 0.70,
    );
  }

  group('荷物持ち上げ Auto（1アクションずつ）', () {
    test('持ち上げ中は加熱を維持', () {
      expect(
        nextHeatCycleAutoCommand(snap(
          temperature: 800,
          volume: 0.40,
          cargoOn: true,
          insulated: true,
          heating: true,
        )),
        isNull,
      );
    });

    test('加熱が切れていたらまず断熱材を入れる', () {
      expect(
        nextHeatCycleAutoCommand(snap(
          temperature: 800,
          cargoOn: true,
          insulated: false,
          heating: false,
        )),
        const HeatCycleAutoCommand(insulated: true),
      );
    });

    test('断熱あり・加熱OFFなら加熱を始める', () {
      expect(
        nextHeatCycleAutoCommand(snap(
          temperature: 800,
          cargoOn: true,
          insulated: true,
          heating: false,
        )),
        const HeatCycleAutoCommand(heating: true),
      );
    });

    test('加熱中に荷物がなければ載せ直す', () {
      expect(
        nextHeatCycleAutoCommand(snap(
          temperature: 600,
          cargoOn: false,
          insulated: true,
          heating: true,
        )),
        const HeatCycleAutoCommand(cargoOn: true),
      );
    });

    test('体積上端: 加熱OFF → 荷物下ろし → 断熱解除', () {
      var cargoOn = true;
      var insulated = true;
      var heating = true;

      void apply(HeatCycleAutoCommand? cmd) {
        if (cmd == null) return;
        if (cmd.cargoOn != null) cargoOn = cmd.cargoOn!;
        if (cmd.insulated != null) insulated = cmd.insulated!;
        if (cmd.heating != null) heating = cmd.heating!;
      }

      HeatCycleAutoCommand? tick() => nextHeatCycleAutoCommand(snap(
            temperature: 1100,
            volume: 0.70,
            cargoOn: cargoOn,
            insulated: insulated,
            heating: heating,
          ));

      apply(tick());
      expect(heating, isFalse);
      expect(cargoOn, isTrue);

      apply(tick());
      expect(cargoOn, isFalse);
      expect(insulated, isTrue);

      apply(tick());
      expect(insulated, isFalse);
      expect(heating, isFalse);
    });

    test('下限: 荷物載せ → 断熱 → 加熱', () {
      var cargoOn = false;
      var insulated = false;
      var heating = false;

      void apply(HeatCycleAutoCommand? cmd) {
        if (cmd == null) return;
        if (cmd.cargoOn != null) cargoOn = cmd.cargoOn!;
        if (cmd.insulated != null) insulated = cmd.insulated!;
        if (cmd.heating != null) heating = cmd.heating!;
      }

      HeatCycleAutoCommand? tick() => nextHeatCycleAutoCommand(snap(
            temperature: minT,
            cargoOn: cargoOn,
            insulated: insulated,
            heating: heating,
          ));

      apply(tick());
      expect(cargoOn, isTrue);
      expect(insulated, isFalse);

      apply(tick());
      expect(insulated, isTrue);
      expect(heating, isFalse);

      apply(tick());
      expect(heating, isTrue);
    });
  });

  group('物理ステップ Session', () {
    HeatCycleAutoSession session({
      double temperature = 800,
      bool insulated = true,
      bool heating = true,
      bool cargoOn = true,
      double volume = 0.40,
      double actionHoldSec = 0,
    }) {
      return HeatCycleAutoSession(
        minTemp: minT,
        temperature: temperature,
        insulated: insulated,
        heating: heating,
        cargoOn: cargoOn,
        volume: volume,
        actionHoldSec: actionHoldSec,
      );
    }

    test('上端張り付きでも step で加熱OFF→荷物下ろし→断熱OFFへ進む', () {
      final s = session(
        temperature: 1100,
        volume: 0.70,
        insulated: true,
        heating: true,
        cargoOn: true,
      );
      s.onPhysicsSample(1100, sampleVolume: 0.70);
      expect(s.heating, isFalse);
      expect(s.cargoOn, isTrue);
      s.onPhysicsSample(1100, sampleVolume: 0.70);
      expect(s.cargoOn, isFalse);
      expect(s.insulated, isTrue);
      s.onPhysicsSample(1100, sampleVolume: 0.70);
      expect(s.insulated, isFalse);
      expect(s.heating, isFalse);
    });

    test('見える操作のあと 2 秒ホールドする', () {
      final s = session(
        temperature: 1100,
        volume: 0.70,
        insulated: true,
        heating: true,
        cargoOn: true,
        actionHoldSec: 2.0,
      );

      s.onPhysicsSample(1100, sampleVolume: 0.70, dt: 0.05);
      expect(s.heating, isFalse);
      expect(s.isHolding, isTrue);

      s.onPhysicsSample(1100, sampleVolume: 0.70, dt: 1.0);
      expect(s.heating, isFalse);
      expect(s.cargoOn, isTrue);

      s.onPhysicsSample(1100, sampleVolume: 0.70, dt: 1.0);
      expect(s.isHolding, isFalse);

      s.onPhysicsSample(1100, sampleVolume: 0.70, dt: 0.05);
      expect(s.cargoOn, isFalse);
      expect(s.insulated, isTrue);
      expect(s.isHolding, isTrue);
    });

    test('工程ラベル', () {
      expect(
        heatCycleAutoStatusLabel(snap(
          temperature: 800,
          cargoOn: true,
          insulated: true,
          heating: true,
          volume: 0.40,
        )),
        '定圧膨張',
      );
      expect(
        heatCycleAutoStatusLabel(snap(
          temperature: 400,
          cargoOn: true,
          insulated: true,
          heating: true,
          volume: 0.25,
        )),
        '定積昇圧',
      );
      expect(
        heatCycleAutoStatusLabel(snap(
          temperature: 1100,
          cargoOn: true,
          insulated: true,
          heating: true,
          volume: 0.70,
        )),
        '加熱を止めています',
      );
      expect(
        heatCycleAutoStatusLabel(snap(
          temperature: 1100,
          cargoOn: true,
          insulated: true,
          heating: false,
          volume: 0.70,
        )),
        '荷物を下ろしています',
      );
      expect(
        heatCycleAutoStatusLabel(snap(
          temperature: 900,
          cargoOn: false,
          insulated: false,
          heating: false,
        )),
        '放熱により冷却中',
      );
      expect(
        heatCycleAutoStatusLabel(snap(
          temperature: minT,
          cargoOn: true,
          insulated: false,
          heating: false,
        )),
        '断熱材を入れています',
      );
      expect(
        heatCycleAutoStatusLabel(snap(
          temperature: minT,
          cargoOn: true,
          insulated: true,
          heating: false,
        )),
        '加熱を始めています',
      );
    });

    test('加熱→上端→冷却→下限で1周（ホールド無し）', () {
      final s = session(
        temperature: minT,
        volume: 0.25,
        cargoOn: true,
        insulated: true,
        heating: false,
      );

      s.onPhysicsSample(minT, sampleVolume: 0.25);
      expect(s.heating, isTrue);

      s.onPhysicsSample(800, sampleVolume: 0.40);
      expect(s.cargoOn, isTrue);
      expect(s.heating, isTrue);

      s.onPhysicsSample(1100, sampleVolume: 0.70);
      expect(s.heating, isFalse);
      s.onPhysicsSample(1100, sampleVolume: 0.70);
      expect(s.cargoOn, isFalse);
      s.onPhysicsSample(1100, sampleVolume: 0.70);
      expect(s.insulated, isFalse);

      s.onPhysicsSample(800, sampleVolume: 0.50);
      expect(s.cargoOn, isFalse);

      s.onPhysicsSample(minT, sampleVolume: 0.25);
      expect(s.cargoOn, isTrue);
      s.onPhysicsSample(minT, sampleVolume: 0.25);
      expect(s.insulated, isTrue);
      expect(s.heating, isFalse);
      s.onPhysicsSample(minT, sampleVolume: 0.25);
      expect(s.heating, isTrue);
    });
  });
}
