import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/thermoDynamics/animations/thermo_process_auto.dart';

void main() {
  group('定積・定圧 Auto（温度往復）', () {
    const ambient = 300.0;
    const maxT = 1000.0;

    ThermoTempAutoSnapshot snap({
      required double temperature,
      required ThermoTempAutoPhase phase,
      bool insulated = false,
      bool heating = false,
      bool cooling = false,
    }) {
      return ThermoTempAutoSnapshot(
        temperature: temperature,
        ambientTemp: ambient,
        maxTemp: maxT,
        phase: phase,
        insulated: insulated,
        heating: heating,
        cooling: cooling,
      );
    }

    test('加熱相: まず断熱材を入れる', () {
      expect(
        nextThermoTempAutoCommand(snap(
          temperature: 400,
          phase: ThermoTempAutoPhase.heating,
        )),
        const ThermoTempAutoCommand(insulated: true),
      );
    });

    test('断熱ありなら加熱を始める', () {
      expect(
        nextThermoTempAutoCommand(snap(
          temperature: 400,
          phase: ThermoTempAutoPhase.heating,
          insulated: true,
        )),
        const ThermoTempAutoCommand(heating: true),
      );
    });

    test('上限到達 → まず加熱OFF', () {
      expect(
        nextThermoTempAutoCommand(snap(
          temperature: maxT,
          phase: ThermoTempAutoPhase.heating,
          insulated: true,
          heating: true,
        )),
        const ThermoTempAutoCommand(heating: false),
      );
    });

    test('加熱OFF後 → 壁外し（冷却はまだ）', () {
      expect(
        nextThermoTempAutoCommand(snap(
          temperature: maxT,
          phase: ThermoTempAutoPhase.heating,
          insulated: true,
          heating: false,
        )),
        const ThermoTempAutoCommand(
          insulated: false,
          phase: ThermoTempAutoPhase.cooling,
        ),
      );
    });

    test('冷却相・壁外し後 → 冷却ON', () {
      expect(
        nextThermoTempAutoCommand(snap(
          temperature: maxT,
          phase: ThermoTempAutoPhase.cooling,
          insulated: false,
          heating: false,
          cooling: false,
        )),
        const ThermoTempAutoCommand(cooling: true),
      );
    });

    test('冷却相で外気温付近 → まず冷却OFF', () {
      expect(
        nextThermoTempAutoCommand(snap(
          temperature: ambient,
          phase: ThermoTempAutoPhase.cooling,
          cooling: true,
        )),
        const ThermoTempAutoCommand(cooling: false),
      );
    });

    test('冷却OFF後 → 断熱材を入れる', () {
      expect(
        nextThermoTempAutoCommand(snap(
          temperature: ambient,
          phase: ThermoTempAutoPhase.cooling,
          cooling: false,
        )),
        const ThermoTempAutoCommand(
          insulated: true,
          phase: ThermoTempAutoPhase.heating,
        ),
      );
    });

    test('断熱後 → 加熱を始める', () {
      expect(
        nextThermoTempAutoCommand(snap(
          temperature: ambient,
          phase: ThermoTempAutoPhase.heating,
          insulated: true,
          heating: false,
        )),
        const ThermoTempAutoCommand(heating: true),
      );
    });

    test('Session で加熱→壁外し→冷却→加熱の往復を複数周', () {
      final s = ThermoTempAutoSession(
        ambientTemp: ambient,
        maxTemp: maxT,
        temperature: ambient,
        actionHoldSec: 0,
      );

      // 起動: 断熱 → 加熱
      s.onPhysicsSample(ambient);
      expect(s.insulated, isTrue);
      expect(s.heating, isFalse);
      s.onPhysicsSample(ambient);
      expect(s.heating, isTrue);
      expect(s.phase, ThermoTempAutoPhase.heating);

      // 上限: 加熱OFF → 壁外し
      s.onPhysicsSample(maxT);
      expect(s.heating, isFalse);
      expect(s.insulated, isTrue);
      s.onPhysicsSample(maxT);
      expect(s.phase, ThermoTempAutoPhase.cooling);
      expect(s.insulated, isFalse);
      expect(s.cooling, isFalse);

      s.onPhysicsSample(maxT);
      expect(s.cooling, isTrue);

      s.onPhysicsSample(ambient);
      expect(s.cooling, isFalse);

      s.onPhysicsSample(ambient);
      expect(s.insulated, isTrue);
      expect(s.phase, ThermoTempAutoPhase.heating);
      expect(s.heating, isFalse);

      s.onPhysicsSample(ambient);
      expect(s.heating, isTrue);

      // 2周目
      s.onPhysicsSample(maxT);
      expect(s.heating, isFalse);
      s.onPhysicsSample(maxT);
      expect(s.phase, ThermoTempAutoPhase.cooling);
      s.onPhysicsSample(maxT);
      expect(s.cooling, isTrue);
      s.onPhysicsSample(ambient);
      s.onPhysicsSample(ambient);
      s.onPhysicsSample(ambient);
      expect(s.phase, ThermoTempAutoPhase.heating);
      expect(s.heating, isTrue);
    });

    test('断熱ONと加熱ONのあいだに2秒ホールド', () {
      final s = ThermoTempAutoSession(
        ambientTemp: ambient,
        maxTemp: maxT,
        temperature: ambient,
        actionHoldSec: 2.0,
      );

      s.onPhysicsSample(ambient, dt: 0.05);
      expect(s.insulated, isTrue);
      expect(s.heating, isFalse);
      expect(s.isHolding, isTrue);

      s.onPhysicsSample(ambient, dt: 1.0);
      expect(s.heating, isFalse);

      s.onPhysicsSample(ambient, dt: 1.0);
      expect(s.isHolding, isFalse);

      s.onPhysicsSample(ambient, dt: 0.05);
      expect(s.heating, isTrue);
      expect(s.isHolding, isTrue);
    });

    test('加熱OFFのあと2秒ホールドしてから壁外し', () {
      final s = ThermoTempAutoSession(
        ambientTemp: ambient,
        maxTemp: maxT,
        temperature: ambient,
        insulated: true,
        heating: true,
        actionHoldSec: 2.0,
      );
      s.phase = ThermoTempAutoPhase.heating;

      s.onPhysicsSample(maxT, dt: 0.05);
      expect(s.heating, isFalse);
      expect(s.insulated, isTrue);
      expect(s.isHolding, isTrue);

      s.onPhysicsSample(maxT, dt: 2.0);
      expect(s.isHolding, isFalse);

      s.onPhysicsSample(maxT, dt: 0.05);
      expect(s.insulated, isFalse);
      expect(s.phase, ThermoTempAutoPhase.cooling);
      expect(s.isHolding, isTrue);
    });

    test('工程ラベル', () {
      expect(
        thermoTempAutoStatusLabel(snap(
          temperature: 400,
          phase: ThermoTempAutoPhase.heating,
          insulated: true,
          heating: true,
        )),
        '加熱中',
      );
      expect(
        thermoTempAutoStatusLabel(snap(
          temperature: 400,
          phase: ThermoTempAutoPhase.heating,
          insulated: false,
        )),
        '断熱材を入れています',
      );
      expect(
        thermoTempAutoStatusLabel(snap(
          temperature: 400,
          phase: ThermoTempAutoPhase.heating,
          insulated: true,
          heating: false,
        )),
        '加熱を始めています',
      );
      expect(
        thermoTempAutoStatusLabel(snap(
          temperature: 500,
          phase: ThermoTempAutoPhase.cooling,
          cooling: true,
        )),
        '冷却中',
      );
    });
  });

  group('等温・断熱 Auto（体積往復）', () {
    const home = 1.0;
    const far = 2.0;

    test('膨張相は遠端を目標', () {
      final cmd = nextThermoVolumeAutoCommand(ThermoVolumeAutoSnapshot(
        volume: home,
        homeVolume: home,
        farVolume: far,
        phase: ThermoVolumeAutoPhase.expanding,
      ));
      expect(cmd.targetVolume, far);
      expect(cmd.phase, isNull);
    });

    test('遠端到達で圧縮相へ', () {
      final cmd = nextThermoVolumeAutoCommand(ThermoVolumeAutoSnapshot(
        volume: far,
        homeVolume: home,
        farVolume: far,
        phase: ThermoVolumeAutoPhase.expanding,
      ));
      expect(cmd.targetVolume, home);
      expect(cmd.phase, ThermoVolumeAutoPhase.compressing);
    });

    test('初期体積到達で再び膨張相へ', () {
      final cmd = nextThermoVolumeAutoCommand(ThermoVolumeAutoSnapshot(
        volume: home,
        homeVolume: home,
        farVolume: far,
        phase: ThermoVolumeAutoPhase.compressing,
      ));
      expect(cmd.targetVolume, far);
      expect(cmd.phase, ThermoVolumeAutoPhase.expanding);
    });

    test('Session が膨張→遠端ホールド→圧縮→初期へ戻る', () {
      final s = ThermoVolumeAutoSession(
        homeVolume: home,
        farVolume: far,
        speedLps: 1.0,
        actionHoldSec: 0.5,
      );

      var v = home;
      for (var i = 0; i < 50 && v < far - 0.01; i++) {
        v = s.onPhysicsSample(v, dt: 0.1);
      }
      expect(v, closeTo(far, 0.02));
      expect(s.phase, ThermoVolumeAutoPhase.compressing);
      expect(s.isHolding, isTrue);

      v = s.onPhysicsSample(v, dt: 0.5);
      expect(s.isHolding, isFalse);

      for (var i = 0; i < 50 && v > home + 0.01; i++) {
        v = s.onPhysicsSample(v, dt: 0.1);
      }
      expect(v, closeTo(home, 0.02));
      expect(s.phase, ThermoVolumeAutoPhase.expanding);
    });

    test('ホールド無しなら連続で何周でも往復', () {
      final s = ThermoVolumeAutoSession(
        homeVolume: home,
        farVolume: far,
        speedLps: 2.0,
        actionHoldSec: 0,
      );
      var v = home;
      var crossedFar = 0;
      var returnedHome = 0;
      for (var i = 0; i < 400; i++) {
        final prev = v;
        v = s.onPhysicsSample(v, dt: 0.05);
        if (prev < far - 0.05 && v >= far - 0.02) crossedFar++;
        if (s.phase == ThermoVolumeAutoPhase.expanding &&
            prev > home + 0.05 &&
            v <= home + 0.02) {
          returnedHome++;
        }
      }
      expect(crossedFar, greaterThanOrEqualTo(2));
      expect(returnedHome, greaterThanOrEqualTo(2));
    });
  });
}
