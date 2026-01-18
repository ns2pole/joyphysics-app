import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';

final circularWave = createWaveVideo(
  title: "円形波",
  latex: r"""
  <div class="common-box">解説</div>
  <p>点源から周囲に円形に広がる波です。</p>
  """,
  simulation: CircularWaveSimulation(),
);

class CircularWaveSimulation extends WaveSimulation {
  CircularWaveSimulation()
      : super(
          title: "円形波",
          is3D: true,
          formula: const FormulaDisplay(
              r'z(x,y,t)=A\sin\left(2\pi\left(\frac{t}{T} - \frac{\sqrt{x^2+y^2}}{\lambda}\right)\right)'),
        );

  @override
  Map<String, double> get initialParameters => getInitialParamsWithObs(
        baseParams: {
          'lambda': 2.0,
          'periodT': 1.0,
        },
        obsX: 2.0,
        obsY: 0.0,
      );

  @override
  List<Widget> buildControls(context, params, updateParam) {
    return [
      Text(
        'λ = ${params['lambda']!.toStringAsFixed(2)}   T = ${params['periodT']!.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 12),
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
    final field = CircularWaveField(
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
          WaveMarker(point: const math.Point(0.0, 0.0), color: Colors.yellow),
          getObsMarker(params, label: '観測点 (a, b)'),
        ],
      ),
    );
  }
}
