import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/waves/animations/fields/wave_fields.dart';

void main() {
  group('CircularInterferenceField', () {
    const field = CircularInterferenceField(
      lambda: 2.0,
      periodT: 0.5,
      a: 1.0,
      phi: 0,
    );
    // v = λ/T = 4. 波源は (0, ±1)
    // 点 (0, 1) は波1にすぐ届き、波2は距離 2 → t = 0.5
    test('片方の波しか届いていない点では干渉していない', () {
      expect(field.hasReached('wave1', 0, 1, 0.1), isTrue);
      expect(field.hasReached('wave2', 0, 1, 0.1), isFalse);
      expect(field.interferenceHasReached(0, 1, 0.1), isFalse);
    });

    test('両波が届いた点では干渉している', () {
      expect(field.interferenceHasReached(0, 1, 0.51), isTrue);
    });
  });

  group('PlaneWaveInterferenceField', () {
    const field = PlaneWaveInterferenceField(
      theta1: 0,
      lambda1: 2.0,
      periodT1: 0.5,
      theta2: 0.4,
      lambda2: 2.0,
      periodT2: 0.5,
    );

    test('直線波がまだ重ならない点では干渉していない', () {
      expect(field.interferenceHasReached(-5, 0, 0), isFalse);
    });

    test('十分時間が経てば原点付近で干渉する', () {
      expect(field.interferenceHasReached(0, 0, 5.0), isTrue);
    });
  });
}
