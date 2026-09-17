import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/thermoDynamics/animations/heat_cycle_auto.dart';

void main() {
  const minT = 300.0;
  const maxT = 1680.0;

  HeatCycleAutoSnapshot snap({
    required double temperature,
    int weights = 0,
    bool cargoLiftMode = false,
    bool cargoOn = false,
    bool insulated = true,
    bool heating = true,
    double volume = 0.40,
  }) {
    return HeatCycleAutoSnapshot(
      temperature: temperature,
      minTemp: minT,
      maxTemp: maxT,
      weights: weights,
      cargoLiftMode: cargoLiftMode,
      cargoOn: cargoOn,
      insulated: insulated,
      heating: heating,
      volume: volume,
      vMin: 0.25,
      vMax: 0.70,
    );
  }

  group('通常モード Auto（1アクションずつ）', () {
    test('加熱中は断熱ON・加熱ONを維持（変更なし）', () {
      expect(
        nextHeatCycleAutoCommand(snap(
          temperature: 800,
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
          insulated: true,
          heating: false,
        )),
        const HeatCycleAutoCommand(heating: true),
      );
    });

    test('上限: まず錘だけ載せる', () {
      expect(
        nextHeatCycleAutoCommand(snap(
          temperature: maxT,
          weights: 0,
          insulated: true,
          heating: true,
        )),
        const HeatCycleAutoCommand(weights: 1),
      );
    });

    test('上限の次: 錘ありならまず加熱OFF', () {
      expect(
        nextHeatCycleAutoCommand(snap(
          temperature: maxT,
          weights: 1,
          insulated: true,
          heating: true,
        )),
        const HeatCycleAutoCommand(heating: false),
      );
    });

    test('加熱OFF後: 断熱を外す', () {
      expect(
        nextHeatCycleAutoCommand(snap(
          temperature: maxT,
          weights: 1,
          insulated: true,
          heating: false,
        )),
        const HeatCycleAutoCommand(insulated: false),
      );
    });

    test('錘あり冷却中は断熱OFF・加熱OFFを維持', () {
      expect(
        nextHeatCycleAutoCommand(snap(
          temperature: 900,
          weights: 1,
          insulated: false,
          heating: false,
        )),
        isNull,
      );
    });

    test('下限: まず錘だけ外す', () {
      expect(
        nextHeatCycleAutoCommand(snap(
          temperature: minT,
          weights: 1,
          insulated: false,
          heating: false,
        )),
        const HeatCycleAutoCommand(weights: 0),
      );
    });

    test('下限の次: 錘なしならまず断熱材を入れる', () {
      expect(
        nextHeatCycleAutoCommand(snap(
          temperature: minT,
          weights: 0,
          insulated: false,
          heating: false,
        )),
        const HeatCycleAutoCommand(insulated: true),
      );
    });

    test('状態をミューテートしながら3周回る', () {
      var temperature = 500.0;
      var weights = 0;
      var insulated = true;
      var heating = true;
      var cargoOn = false;

      void apply(HeatCycleAutoCommand? cmd) {
        if (cmd == null) return;
        if (cmd.weights != null) weights = cmd.weights!;
        if (cmd.cargoOn != null) cargoOn = cmd.cargoOn!;
        if (cmd.insulated != null) insulated = cmd.insulated!;
        if (cmd.heating != null) heating = cmd.heating!;
      }

      HeatCycleAutoCommand? tick() => nextHeatCycleAutoCommand(snap(
            temperature: temperature,
            weights: weights,
            insulated: insulated,
            heating: heating,
            cargoOn: cargoOn,
          ));

      for (var cycle = 0; cycle < 3; cycle++) {
        temperature = 800;
        expect(tick(), isNull);

        temperature = maxT;
        apply(tick());
        expect(weights, 1);
        expect(insulated, isTrue);
        expect(heating, isTrue);
        apply(tick());
        expect(heating, isFalse);
        expect(insulated, isTrue);
        apply(tick());
        expect(insulated, isFalse);
        expect(heating, isFalse);

        temperature = 900;
        expect(tick(), isNull);

        temperature = minT;
        apply(tick());
        expect(weights, 0);
        expect(insulated, isFalse);
        apply(tick());
        expect(insulated, isTrue);
        expect(heating, isFalse);
        apply(tick());
        expect(heating, isTrue);
      }
    });
  });

  group('荷物モード Auto（1アクションずつ）', () {
    test('加熱中は荷物ありを維持', () {
      final cmd = nextHeatCycleAutoCommand(snap(
        temperature: 600,
        cargoLiftMode: true,
        cargoOn: false,
        insulated: true,
        heating: true,
      ));
      expect(cmd, const HeatCycleAutoCommand(cargoOn: true));
    });

    test('上限: 荷物下ろし → 錘 → 加熱OFF → 断熱解除', () {
      var cargoOn = true;
      var weights = 0;
      var insulated = true;
      var heating = true;

      void apply(HeatCycleAutoCommand? cmd) {
        if (cmd == null) return;
        if (cmd.weights != null) weights = cmd.weights!;
        if (cmd.cargoOn != null) cargoOn = cmd.cargoOn!;
        if (cmd.insulated != null) insulated = cmd.insulated!;
        if (cmd.heating != null) heating = cmd.heating!;
      }

      HeatCycleAutoCommand? tick() => nextHeatCycleAutoCommand(snap(
            temperature: maxT,
            cargoLiftMode: true,
            cargoOn: cargoOn,
            weights: weights,
            insulated: insulated,
            heating: heating,
          ));

      apply(tick());
      expect(cargoOn, isFalse);
      expect(weights, 0);

      apply(tick());
      expect(weights, 1);
      expect(heating, isTrue);

      apply(tick());
      expect(heating, isFalse);
      expect(insulated, isTrue);

      apply(tick());
      expect(insulated, isFalse);
      expect(heating, isFalse);
    });

    test('下限: 錘外し → 荷物載せ → 断熱 → 加熱', () {
      var cargoOn = false;
      var weights = 1;
      var insulated = false;
      var heating = false;

      void apply(HeatCycleAutoCommand? cmd) {
        if (cmd == null) return;
        if (cmd.weights != null) weights = cmd.weights!;
        if (cmd.cargoOn != null) cargoOn = cmd.cargoOn!;
        if (cmd.insulated != null) insulated = cmd.insulated!;
        if (cmd.heating != null) heating = cmd.heating!;
      }

      HeatCycleAutoCommand? tick() => nextHeatCycleAutoCommand(snap(
            temperature: minT,
            cargoLiftMode: true,
            cargoOn: cargoOn,
            weights: weights,
            insulated: insulated,
            heating: heating,
          ));

      apply(tick());
      expect(weights, 0);
      expect(cargoOn, isFalse);

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
      int weights = 0,
      bool insulated = true,
      bool heating = true,
      bool cargoLiftMode = false,
      bool cargoOn = false,
      double actionHoldSec = 0,
    }) {
      return HeatCycleAutoSession(
        minTemp: minT,
        maxTemp: maxT,
        temperature: temperature,
        weights: weights,
        insulated: insulated,
        heating: heating,
        cargoLiftMode: cargoLiftMode,
        cargoOn: cargoOn,
        actionHoldSec: actionHoldSec,
      );
    }

    test('上限張り付きでも step で錘→加熱OFF→断熱OFFへ進む', () {
      final s = session(
        temperature: maxT,
        weights: 0,
        insulated: true,
        heating: true,
      );
      s.onPhysicsSample(maxT);
      expect(s.weights, 1);
      expect(s.heating, isTrue);
      s.onPhysicsSample(maxT);
      expect(s.heating, isFalse);
      expect(s.insulated, isTrue);
      s.onPhysicsSample(maxT);
      expect(s.insulated, isFalse);
      expect(s.heating, isFalse);
    });

    test('見える操作のあと 2 秒ホールドする', () {
      final s = session(
        temperature: maxT,
        weights: 0,
        insulated: true,
        heating: true,
        actionHoldSec: 2.0,
      );

      s.onPhysicsSample(maxT, dt: 0.05);
      expect(s.weights, 1);
      expect(s.isHolding, isTrue);

      // ホールド中は次の操作（加熱OFF）に進まない
      s.onPhysicsSample(maxT, dt: 1.0);
      expect(s.heating, isTrue);
      expect(s.weights, 1);

      s.onPhysicsSample(maxT, dt: 1.0); // 残りを消化
      expect(s.isHolding, isFalse);

      s.onPhysicsSample(maxT, dt: 0.05);
      expect(s.heating, isFalse);
      expect(s.insulated, isTrue);
      expect(s.isHolding, isTrue);
    });

    test('荷物モードで各操作のあいだにホールドが入る', () {
      final s = session(
        temperature: maxT,
        weights: 0,
        insulated: true,
        heating: true,
        cargoLiftMode: true,
        cargoOn: true,
        actionHoldSec: 2.0,
      );

      s.onPhysicsSample(maxT, dt: 0.01);
      expect(s.cargoOn, isFalse);
      expect(s.weights, 0);
      expect(s.isHolding, isTrue);

      s.onPhysicsSample(maxT, dt: 2.0);
      s.onPhysicsSample(maxT, dt: 0.01);
      expect(s.weights, 1);
      expect(s.heating, isTrue);
      expect(s.isHolding, isTrue);

      s.onPhysicsSample(maxT, dt: 2.0);
      s.onPhysicsSample(maxT, dt: 0.01);
      expect(s.heating, isFalse);
      expect(s.insulated, isTrue);
      expect(s.isHolding, isTrue);

      s.onPhysicsSample(maxT, dt: 2.0);
      s.onPhysicsSample(maxT, dt: 0.01);
      expect(s.insulated, isFalse);
      expect(s.heating, isFalse);
    });

    test('工程ラベル', () {
      expect(
        heatCycleAutoStatusLabel(snap(
          temperature: 800,
          insulated: true,
          heating: true,
          volume: 0.40,
        )),
        '定圧膨張',
      );
      expect(
        heatCycleAutoStatusLabel(snap(
          temperature: 1200,
          insulated: true,
          heating: true,
          volume: 0.70,
        )),
        '定積昇圧',
      );
      expect(
        heatCycleAutoStatusLabel(snap(
          temperature: 400,
          cargoLiftMode: true,
          cargoOn: true,
          insulated: true,
          heating: true,
          volume: 0.25,
        )),
        '定積昇圧',
      );
      expect(
        heatCycleAutoStatusLabel(snap(
          temperature: maxT,
          weights: 1,
          insulated: true,
          heating: true,
        )),
        '加熱を止めています',
      );
      expect(
        heatCycleAutoStatusLabel(snap(
          temperature: maxT,
          weights: 1,
          insulated: true,
          heating: false,
        )),
        '壁（断熱）を外しています',
      );
      expect(
        heatCycleAutoStatusLabel(snap(
          temperature: 900,
          weights: 1,
          insulated: false,
          heating: false,
        )),
        '放熱により冷却中',
      );
      expect(
        heatCycleAutoStatusLabel(snap(
          temperature: minT,
          insulated: false,
          heating: false,
        )),
        '断熱材を入れています',
      );
      expect(
        heatCycleAutoStatusLabel(snap(
          temperature: minT,
          insulated: true,
          heating: false,
        )),
        '加熱を始めています',
      );
    });

    test('加熱→上限→冷却→下限で1周（ホールド無し）', () {
      final s = session(
        temperature: minT,
        weights: 0,
        insulated: true,
        heating: false,
      );

      s.onPhysicsSample(minT);
      expect(s.heating, isTrue);

      s.onPhysicsSample(900);
      expect(s.weights, 0);

      s.onPhysicsSample(maxT);
      expect(s.weights, 1);
      s.onPhysicsSample(maxT);
      expect(s.heating, isFalse);
      s.onPhysicsSample(maxT);
      expect(s.insulated, isFalse);

      s.onPhysicsSample(1000);
      expect(s.weights, 1);

      s.onPhysicsSample(minT);
      expect(s.weights, 0);
      s.onPhysicsSample(minT);
      expect(s.insulated, isTrue);
      expect(s.heating, isFalse);
      s.onPhysicsSample(minT);
      expect(s.heating, isTrue);
    });
  });
}
