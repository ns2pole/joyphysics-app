import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/waves/animations/fields/wave_fields.dart';

void main() {
  const field = PlaneWaveField(
    theta: 0,
    lambda: 2.0,
    periodT: 0.5,
  );

  test('波面は可視領域の左端 x=-5 から entryDelay 後に入る', () {
    expect(kPlaneWaveStartOffset, 5.0);
    expect(kPlaneWaveEntryDelay, 0.1);
    expect(field.hasReached('total', -5.0, 0, 0), isFalse);
    expect(
        field.hasReached('total', -5.0, 0, kPlaneWaveEntryDelay - 0.01), isFalse);
    expect(
        field.hasReached('total', -5.0, 0, kPlaneWaveEntryDelay + 0.01), isTrue);
    expect(field.hasReached('total', 0, 0, 0), isFalse);
  });

  test('旧オフセット 7.5 だと約 0.6 秒は左端に届かない', () {
    const v = 2.0 / 0.5;
    final oldDelay = (7.5 - 5.0) / v;
    expect(oldDelay, closeTo(0.625, 1e-12));
    expect(field.hasReached('total', -5.0, 0, oldDelay - 0.05), isTrue);
  });
}
