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

class CircularWaveSimulation extends PhysicsSimulation {
  CircularWaveSimulation()
      : super(
          title: "円形波",
          is3D: true,
          formula: const FormulaDisplay(r'z(x,y,t)=A\sin\left(2\pi\left(\frac{t}{T} - \frac{\sqrt{x^2+y^2}}{\lambda}\right)\right)'),
        );

  @override
  Map<String, double> get initialParameters => {
        'lambda': 2.0,
        'periodT': 1.0,
        'obsX': 2.0,
        'obsY': 0.0,
      };

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
      const Divider(),
      const Text('観測点 (a, b)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      WaveParameterSlider(
        label: 'a',
        value: params['obsX']!,
        min: -5.0,
        max: 5.0,
        onChanged: (v) => updateParam('obsX', v),
      ),
      WaveParameterSlider(
        label: 'b',
        value: params['obsY']!,
        min: -5.0,
        max: 5.0,
        onChanged: (v) => updateParam('obsY', v),
      ),
    ];
  }

  @override
  Widget buildAnimation(context, time, azimuth, tilt, scale, params, activeIds) {
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
          WaveMarker(point: math.Point(params['obsX']!, params['obsY']!), color: Colors.red),
        ],
      ),
    );
  }
}
