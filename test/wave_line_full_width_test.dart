import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/waves/animations/utils/coordinate_transformer.dart';

void main() {
  test('1D の x=±5 は左右 8px 余白に張り付く', () {
    const size = Size(400, 200);
    const scale = 1.0;
    final t = WaveCoordinateTransformer(
      size: size,
      scale: scale,
      is3D: false,
    );

    final left = t.worldToScreen(-WaveCoordinateTransformer.lineWorldHalfRange, 0, 0);
    final right = t.worldToScreen(WaveCoordinateTransformer.lineWorldHalfRange, 0, 0);

    expect(left.dx, closeTo(WaveCoordinateTransformer.lineEdgePadPx, 0.01));
    expect(
      right.dx,
      closeTo(size.width - WaveCoordinateTransformer.lineEdgePadPx, 0.01),
    );
  });
}
