import 'dart:math';

/// Displayed magnetometer field after optional zero-baseline offset.
class MagnetometerDisplayField {
  final double x;
  final double y;
  final double z;
  final double magnitude;

  const MagnetometerDisplayField({
    required this.x,
    required this.y,
    required this.z,
    required this.magnitude,
  });
}

/// When [useZeroBaseline] is true, subtract the captured baseline vector
/// (soft offset for device/environment bias). Magnitude is of the residual.
MagnetometerDisplayField magnetometerDisplayField({
  required double rawX,
  required double rawY,
  required double rawZ,
  required bool useZeroBaseline,
  double baselineX = 0,
  double baselineY = 0,
  double baselineZ = 0,
}) {
  final x = useZeroBaseline ? rawX - baselineX : rawX;
  final y = useZeroBaseline ? rawY - baselineY : rawY;
  final z = useZeroBaseline ? rawZ - baselineZ : rawZ;
  return MagnetometerDisplayField(
    x: x,
    y: y,
    z: z,
    magnitude: sqrt(x * x + y * y + z * z),
  );
}
