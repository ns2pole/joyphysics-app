import 'dart:math' as math;
import 'package:flutter/material.dart';

class WaveCoordinateTransformer {
  final double scale;
  final Offset center;
  final Size size;
  final bool is3D;
  
  // 3D only
  final double azimuth;
  final double tilt;

  static const double cos45 = 0.70710678118;

  /// 1D ライン描画のワールド x は [-5, 5]（[WaveLinePainter] と同じ）。
  static const double lineWorldHalfRange = 5.0;

  /// 波の式の y-t グラフ並みに、左右余白はラベルが切れない程度だけ。
  static const double lineEdgePadPx = 8.0;

  WaveCoordinateTransformer({
    required this.size,
    required this.scale,
    this.is3D = false,
    this.azimuth = 0.0,
    this.tilt = 0.0,
  }) : center = Offset(size.width / 2, size.height / 2);

  double get unitScale {
    if (is3D) {
      return 50.0 * scale;
    } else {
      final usable = math.max(1.0, size.width - 2 * lineEdgePadPx);
      return (usable / (2 * lineWorldHalfRange)) * scale;
    }
  }

  Offset worldToScreen(double x, double y, double z) {
    final uScale = unitScale;
    if (is3D) {
      final sTilt = math.sin(tilt);
      final cTilt = math.cos(tilt);
      final cAzimuth = math.cos(azimuth);
      final sAzimuth = math.sin(azimuth);
      final cos45Scale = cos45 * uScale;
      final cos45STiltScale = cos45Scale * sTilt;
      final cTiltScale = cTilt * uScale;

      final xr = x * cAzimuth - y * sAzimuth;
      final yr = x * sAzimuth + y * cAzimuth;
      final px = center.dx + (yr - xr) * cos45Scale;
      final py = center.dy + (xr + yr) * cos45STiltScale - z * cTiltScale;
      return Offset(px, py);
    } else {
      // 1D/2D projection for WaveLinePainter
      return Offset(center.dx + x * uScale, center.dy - z * uScale * 2);
    }
  }

  math.Point<double> screenToWorld(Offset screenPoint, {double z = 0.0}) {
    final uScale = unitScale;
    if (is3D) {
      final sTilt = math.sin(tilt);
      final cTilt = math.cos(tilt);
      final cAzimuth = math.cos(azimuth);
      final sAzimuth = math.sin(azimuth);
      final cos45Scale = cos45 * uScale;
      final cos45STiltScale = cos45Scale * sTilt;
      final cTiltScale = cTilt * uScale;

      // Reverse py calculation: py = center.dy + (xr + yr) * cos45STiltScale - z * cTiltScale
      // (xr + yr) = (py - center.dy + z * cTiltScale) / cos45STiltScale
      // Reverse px calculation: px = center.dx + (yr - xr) * cos45Scale
      // (yr - xr) = (px - center.dx) / cos45Scale

      final dy = (screenPoint.dy - center.dy + z * cTiltScale) / cos45STiltScale;
      final dx = (screenPoint.dx - center.dx) / cos45Scale;

      final yr = (dy + dx) / 2.0;
      final xr = (dy - dx) / 2.0;

      // Rotation inverse:
      // x = xr * cAzimuth + yr * sAzimuth
      // y = -xr * sAzimuth + yr * cAzimuth
      final x = xr * cAzimuth + yr * sAzimuth;
      final y = -xr * sAzimuth + yr * cAzimuth;
      
      return math.Point(x, y);
    } else {
      // px = center.dx + x * uScale => x = (px - center.dx) / uScale
      final x = (screenPoint.dx - center.dx) / uScale;
      // py = center.dy - z * uScale * 2 => z = (center.dy - py) / (uScale * 2)
      // Since we usually want to solve for x and z is the height, 
      // but markers are usually on the wave which is z(x).
      // If we are dragging an observation point on the x-axis:
      return math.Point(x, 0.0);
    }
  }
}
