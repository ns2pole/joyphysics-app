import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_line_painter.dart';
import '../widgets/wave_slider.dart';

final freeEndReflection1D = createWaveVideo(
  title: "1次元の定在波(自由端反射)",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>自由端では、反射波は入射波と同位相で反射します。</p>
  <p>合成波は端で常に振幅が最大となります（腹）。</p>
  """,
  simulation: FreeEndReflection1DSimulation(),
);

class FreeEndReflection1DSimulation extends WaveSimulation {
  FreeEndReflection1DSimulation()
      : super(
          title: "1次元の定在波(自由端反射)",
          is3D: false,
          formula: const Column(
            children: [
              FormulaDisplay(
                  r'\color{#B38CFF}{z_i = A \sin\left(2\pi\left(\frac{t}{T} - \frac{x - x_0}{\lambda}\right)\right)}'),
              SizedBox(height: 4),
              FormulaDisplay(
                  r'\color{#8CFFB3}{z_r = A \sin\left(2\pi\left(\frac{t}{T} - \frac{2L - x - x_0}{\lambda}\right)\right)}'),
            ],
          ),
        );

  @override
  Map<String, double> get initialParameters => getInitialParamsWithObs(
        baseParams: {
          'lambda': 2.0,
          'periodT': 1.0,
        },
        obsX: 2.0,
      );

  @override
  Set<String> get initialActiveIds => {'incident', 'reflected', 'combined'};

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
      ...buildObsSliders(params, updateParam, is2D: false),
    ];
  }

  @override
  Widget buildExtraControls(context, activeIds, updateActiveIds) {
    return Wrap(
      spacing: 8,
      children: [
        buildChip('入射波', 'incident', Colors.purpleAccent, activeIds,
            updateActiveIds,
            fontSize: 12),
        buildChip('反射波', 'reflected', Colors.greenAccent, activeIds,
            updateActiveIds,
            fontSize: 12),
        buildChip('合成波', 'combined', Colors.blueAccent, activeIds,
            updateActiveIds,
            fontSize: 12),
      ],
    );
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    final field = OneDimensionReflectionField(
      lambda: params['lambda']!,
      periodT: params['periodT']!,
      mode: ReflectionMode.combined,
      isFixedEnd: false,
      boundaryX: 5.0,
      amplitude: 0.6,
    );
    return CustomPaint(
      size: Size.infinite,
      painter: WaveLinePainter(
        time: time,
        field: field,
        surfaceColor: Colors.blue,
        showTicks: true,
        boundaryX: 5.0,
        showBoundaryLine: true,
        activeComponentIds: activeIds,
        scale: scale,
        markers: [
          getObsMarker(params, label: '合成波の観測点'),
        ],
      ),
    );
  }
}
