import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/waves/animations/2d/PlaneWave.dart';
import 'package:joyphysics/experiment/waves/animations/fields/wave_fields.dart';

void main() {
  test('2D観測点マーカーだけ z 変位の縦点線を出す', () {
    final sim = PlaneWaveSimulation();
    final obs = sim.getObsMarker({'obsX': 1.0, 'obsY': 2.0}, label: '観測点');
    expect(obs.showZDisplacement, isTrue);
    expect(obs.color, Colors.red);

    const source = WaveMarker(point: math.Point(0.0, 0.0), color: Colors.yellow);
    expect(source.showZDisplacement, isFalse);
  });
}
