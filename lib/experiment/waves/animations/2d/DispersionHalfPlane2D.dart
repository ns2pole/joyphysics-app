import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../utils/coordinate_transformer.dart';
import '../widgets/wave_slider.dart';
import 'dart:math' as math;

/// 水（20℃）。C 線（赤 656.3 nm）と F 線（青 486.1 nm）。
const double kWaterNRed = 1.33115;
const double kWaterNBlue = 1.33712;
const double kWaterLambdaRedNm = 656.3;
const double kWaterLambdaBlueNm = 486.1;

/// 画面上の青の波長。赤は真空中の波長比だけ長く、空気中の速さは同じ。
const double kDispersionLambdaBlue = 1.20;

final dispersionHalfPlane2D = createWaveVideo(
  title: "2次元直線波の分散",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>色によって屈折率が違うので、同じ入射角でも屈折角が少し違います。</p>
  <p>スネルの法則: $\sin\theta_1=n\sin\theta_2$（空気側の屈折率は $1$）</p>
  <p>水では、赤 $n=1.331$、青 $n=1.337$ です。入射角 $80^\circ$ のとき、屈折角は赤 $47.72^\circ$、青 $47.44^\circ$ で、差は $0.28^\circ$ です。</p>
  <p>黄色の領域は厚さが十分な水で、境界面の右側はずっと水です。</p>
  <div class="common-box">注意</div>
  <p>境界面では透過と同時に反射も起きます。このシミュレーションでは、屈折した波面を見やすくするため、反射波は描いていません。</p>
  <p>角の差は $1^\circ$ より小さいので、波面の折れ方は赤と青でほとんど重なって見えます。波面の間隔（波長）の違いの方がはっきりします。</p>
  <p>「光線」をオンにすると、入射光線と、赤・青の屈折光線を重ねます。</p>
  """,
  simulation: DispersionHalfPlaneSimulation(),
);

class DispersionHalfPlaneSimulation extends WaveSimulation {
  DispersionHalfPlaneSimulation()
      : super(
          title: "2次元直線波の分散",
          is3D: true,
          formula: const Column(
            children: [
              FormulaDisplay(r'\sin\theta_1=n\sin\theta_2'),
              SizedBox(height: 4),
              FormulaDisplay(r'n_{\mathrm{red}}=1.331,\ n_{\mathrm{blue}}=1.337'),
            ],
          ),
        );

  static double get lambdaRed =>
      kDispersionLambdaBlue * kWaterLambdaRedNm / kWaterLambdaBlueNm;

  @override
  Map<String, double> get initialParameters => {
        'theta': 80 * math.pi / 180,
        'periodBlue': 0.55,
      };

  @override
  Set<String> get initialActiveIds => {
        'red',
        'blue',
        'showWavefrontTopView',
        'showWavefront:red',
        'showWavefront:blue',
        'showRays',
      };

  @override
  List<WavefrontLayer> get wavefrontLayers => const [
        WavefrontLayer(id: 'red', label: '赤', color: Colors.red),
        WavefrontLayer(id: 'blue', label: '青', color: Colors.blue),
      ];

  @override
  Widget buildExtraControls(context, activeIds, updateActiveIds) {
    return Wrap(
      spacing: 8,
      alignment: WrapAlignment.center,
      children: [
        buildChip(
          '光線',
          'showRays',
          Colors.deepOrange,
          activeIds,
          updateActiveIds,
          fontSize: 12,
        ),
      ],
    );
  }

  @override
  List<Widget> buildControls(context, params, updateParam) {
    final theta = params['theta']!;
    final redDeg = snellTheta2(theta, kWaterNRed) * 180 / math.pi;
    final blueDeg = snellTheta2(theta, kWaterNBlue) * 180 / math.pi;
    final gap = redDeg - blueDeg;
    return [
      Text(
        '赤 ${redDeg.toStringAsFixed(2)}°   青 ${blueDeg.toStringAsFixed(2)}°   差 ${gap.toStringAsFixed(2)}°',
        style: const TextStyle(fontSize: 12),
      ),
      ThetaSlider(
        value: theta,
        showDegrees: true,
        onChanged: (v) => updateParam('theta', v),
      ),
      PeriodTSlider(
        value: params['periodBlue']!,
        onChanged: (v) => updateParam('periodBlue', v),
      ),
    ];
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    final periodBlue = params['periodBlue']!;
    final theta = params['theta']!;
    final field = HalfPlaneDispersionWaveField(
      theta: theta,
      lambdaRed: lambdaRed,
      periodRed: periodBlue * lambdaRed / kDispersionLambdaBlue,
      nRed: kWaterNRed,
      lambdaBlue: kDispersionLambdaBlue,
      periodBlue: periodBlue,
      nBlue: kWaterNBlue,
      amplitude: 0.4,
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: WaveSurfacePainter(
            time: time,
            field: field,
            azimuth: azimuth,
            tilt: tilt,
            activeComponentIds: activeIds,
            scale: scale,
            wavefrontStrokeScale: 0.5,
            mediumSlab: const MediumSlabOverlay(
              xStart: 0.0,
              xEnd: 5.0,
              color: Colors.yellow,
              opacity: 0.45,
            ),
          ),
        ),
        if (activeIds.contains('showRays'))
          CustomPaint(
            size: Size.infinite,
            painter: DispersionRayPainter(
              azimuth: azimuth,
              tilt: tilt,
              scale: scale,
              theta: theta,
              thetaRed: snellTheta2(theta, kWaterNRed),
              thetaBlue: snellTheta2(theta, kWaterNBlue),
            ),
          ),
      ],
    );
  }
}

/// 原点で境界面に当たる光線が、可視範囲 [-5, 5] の端に出る点。
/// [intoMedium] が false のときは入射側（進行の逆向き）をたどる。
math.Point<double> dispersionRayEnd({
  required double angle,
  required bool intoMedium,
  double range = 5.0,
}) {
  final sign = intoMedium ? 1.0 : -1.0;
  final dx = sign * math.cos(angle);
  final dy = sign * math.sin(angle);
  var tHit = double.infinity;
  void consider(double t) {
    if (t > 1e-6 && t < tHit) tHit = t;
  }

  if (dx.abs() > 1e-9) consider((dx > 0 ? range : -range) / dx);
  if (dy.abs() > 1e-9) consider((dy > 0 ? range : -range) / dy);
  if (!tHit.isFinite) tHit = range;
  return math.Point(dx * tHit, dy * tHit);
}

class DispersionRayPainter extends CustomPainter {
  DispersionRayPainter({
    required this.azimuth,
    required this.tilt,
    required this.scale,
    required this.theta,
    required this.thetaRed,
    required this.thetaBlue,
  });

  final double azimuth;
  final double tilt;
  final double scale;
  final double theta;
  final double thetaRed;
  final double thetaBlue;

  @override
  void paint(Canvas canvas, Size size) {
    final transformer = WaveCoordinateTransformer(
      size: size,
      scale: scale,
      is3D: true,
      azimuth: azimuth,
      tilt: tilt,
    );
    final incident = dispersionRayEnd(angle: theta, intoMedium: false);
    final red = dispersionRayEnd(angle: thetaRed, intoMedium: true);
    final blue = dispersionRayEnd(angle: thetaBlue, intoMedium: true);

    _drawRay(canvas, transformer, incident.x, incident.y, 0, 0, Colors.black87);
    _drawRay(canvas, transformer, 0, 0, blue.x, blue.y, Colors.blue.shade800);
    _drawRay(canvas, transformer, 0, 0, red.x, red.y, Colors.red.shade700);

    final hit = transformer.worldToScreen(0, 0, 0);
    canvas.drawCircle(
      hit,
      4.5,
      Paint()..color = Colors.black87,
    );
  }

  void _drawRay(
    Canvas canvas,
    WaveCoordinateTransformer transformer,
    double x0,
    double y0,
    double x1,
    double y1,
    Color color,
  ) {
    final p0 = transformer.worldToScreen(x0, y0, 0);
    final p1 = transformer.worldToScreen(x1, y1, 0);
    canvas.drawLine(
      p0,
      p1,
      Paint()
        ..color = color
        ..strokeWidth = 1.3
        ..strokeCap = StrokeCap.round,
    );
    final delta = p1 - p0;
    final len = delta.distance;
    if (len < 16) return;
    final u = delta / len;
    final n = Offset(-u.dy, u.dx);
    final base = p1 - u * 11;
    canvas.drawPath(
      Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(base.dx + n.dx * 5, base.dy + n.dy * 5)
        ..lineTo(base.dx - n.dx * 5, base.dy - n.dy * 5)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant DispersionRayPainter oldDelegate) {
    return oldDelegate.azimuth != azimuth ||
        oldDelegate.tilt != tilt ||
        oldDelegate.scale != scale ||
        oldDelegate.theta != theta ||
        oldDelegate.thetaRed != thetaRed ||
        oldDelegate.thetaBlue != thetaBlue;
  }
}
