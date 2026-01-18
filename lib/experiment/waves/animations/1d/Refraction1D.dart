import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_line_painter.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';

final refraction1D = createWaveVideo(
  title: "屈折 (1次元)",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>異なる媒質の境界で波の速さが変わると、波長も変化します。周波数は変化しません。</p>
  <p>$n = \frac{v_1}{v_2} = \frac{\lambda_1}{\lambda_2}$</p>
  """,
  simulation: Refraction1DSimulation(),
);

class Refraction1DSimulation extends PhysicsSimulation {
  Refraction1DSimulation()
      : super(
          title: "屈折 (1次元)",
          is3D: false,
          formula: const Column(
            children: [
              FormulaDisplay(r'\color{#B38CFF}{z_1 = A \sin\left(2\pi\left(\frac{t}{T} - \frac{x}{\lambda_1}\right)\right)}'),
              SizedBox(height: 4),
              FormulaDisplay(r'\color{#FFB800}{z_2 = A \sin\left(2\pi\left(\frac{t}{T} - \frac{x}{\lambda_1/n}\right)\right)}'),
            ],
          ),
        );

  @override
  Map<String, double> get initialParameters => {
        'lambda': 2.0,
        'periodT': 1.0,
        'n': 1.5,
      };

  @override
  Set<String> get initialActiveIds => {'total'};

  @override
  List<Widget> buildControls(context, params, updateParam) {
    return [
      Text(
        'λ = ${params['lambda']!.toStringAsFixed(2)}   T = ${params['periodT']!.toStringAsFixed(2)}   n = ${params['n']!.toStringAsFixed(2)}',
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
      RefractiveIndexSlider(
        value: params['n']!,
        onChanged: (v) => updateParam('n', v),
      ),
    ];
  }

  @override
  Widget buildExtraControls(context, activeIds, updateActiveIds) {
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: const Text('合成波', style: TextStyle(fontSize: 12)),
          selected: activeIds.contains('total'),
          onSelected: (selected) {
            final next = Set<String>.from(activeIds);
            selected ? next.add('total') : next.remove('total');
            updateActiveIds(next);
          },
        ),
      ],
    );
  }

  @override
  Widget buildAnimation(context, time, azimuth, tilt, params, activeIds) {
    final field = OneDimensionSlabRefractionField(
      lambda: params['lambda']!,
      periodT: params['periodT']!,
      n: params['n']!,
      slabStart: 0.0,
      slabEnd: 5.0,
      amplitude: 0.6,
    );
    return CustomPaint(
      size: Size.infinite,
      painter: WaveLinePainter(
        time: time,
        field: field,
        surfaceColor: Colors.blue,
        showTicks: true,
        activeComponentIds: activeIds,
        mediumSlab: const MediumSlabOverlay(
          xStart: 0.0,
          xEnd: 5.0,
          color: Colors.yellow,
          opacity: 0.4,
        ),
      ),
    );
  }
}
