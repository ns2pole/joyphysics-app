import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/magnetometer_baseline.dart';

void main() {
  test('absolute mode returns raw vector and magnitude', () {
    final field = magnetometerDisplayField(
      rawX: 30,
      rawY: 40,
      rawZ: 0,
      useZeroBaseline: false,
      baselineX: 10,
      baselineY: 10,
      baselineZ: 10,
    );
    expect(field.x, 30);
    expect(field.y, 40);
    expect(field.z, 0);
    expect(field.magnitude, 50);
  });

  test('zero-baseline mode subtracts soft offset vector', () {
    final field = magnetometerDisplayField(
      rawX: 55,
      rawY: 45,
      rawZ: 10,
      useZeroBaseline: true,
      baselineX: 50,
      baselineY: 40,
      baselineZ: 10,
    );
    expect(field.x, closeTo(5, 1e-9));
    expect(field.y, closeTo(5, 1e-9));
    expect(field.z, closeTo(0, 1e-9));
    expect(field.magnitude, closeTo(sqrt(50), 1e-9));
  });

  test('zero-baseline at exactly the baseline yields near-zero magnitude', () {
    final field = magnetometerDisplayField(
      rawX: 120,
      rawY: -30,
      rawZ: 40,
      useZeroBaseline: true,
      baselineX: 120,
      baselineY: -30,
      baselineZ: 40,
    );
    expect(field.magnitude, closeTo(0, 1e-9));
  });
}
