import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';
import 'dart:math' as math;

final planeWave = createWaveVideo(
  title: "平面波",
  latex: r"""
  <div class="common-box">解説</div>
  <p>進行方向に垂直な平面上で位相が等しい波です。</p>
  """,
  simulation: PlaneWaveSimulation(),
);

class PlaneWaveSimulation extends WaveSimulation {
  PlaneWaveSimulation()
      : super(
          title: "平面波",
          is3D: true,
          formula: const FormulaDisplay(
              r'z(x,y,t)=A\sin\left(2\pi\left(\frac{t}{T} - \frac{x\cos\theta+y\sin\theta}{\lambda}\right)\right)'),
        );

  @override
  Map<String, double> get initialParameters => getInitialParamsWithObs(
        baseParams: {
          'theta': 0.0,
          'lambda': 2.0,
          'periodT': 1.0,
        },
        obsX: 0.0,
        obsY: 0.0,
      );

  @override
  List<Widget> buildControls(context, params, updateParam) {
    final thetaDeg = (params['theta']! * 180 / math.pi) % 360;
    return [
      Text(
        'θ = ${thetaDeg.toStringAsFixed(0)}°   λ = ${params['lambda']!.toStringAsFixed(2)}   T = ${params['periodT']!.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 12),
      ),
      ThetaSlider(
        value: params['theta']!,
        maxDeg: 360,
        onChanged: (v) => updateParam('theta', v),
      ),
      LambdaSlider(
        value: params['lambda']!,
        onChanged: (v) => updateParam('lambda', v),
      ),
      PeriodTSlider(
        value: params['periodT']!,
        onChanged: (v) => updateParam('periodT', v),
      ),
      ...buildObsSliders(params, updateParam),
    ];
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    final field = PlaneWaveField(
      theta: params['theta']!,
      lambda: params['lambda']!,
      periodT: params['periodT']!,
      amplitude: 0.4,
    );
    return CustomPaint(
      size: Size.infinite,
      painter: WaveSurfacePainter(
        time: time,
        field: field,
        azimuth: azimuth,
        tilt: tilt,
        activeComponentIds: activeIds,
        scale: scale,
        markers: [
          getObsMarker(params, label: '観測点 (a, b)'),
        ],
      ),
    );
  }
}
