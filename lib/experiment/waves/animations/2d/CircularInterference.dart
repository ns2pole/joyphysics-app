import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';
import 'dart:math' as math;

final circularInterference = createWaveVideo(
  title: "円形波干渉",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>2つの波源からの距離の差が、波長の整数倍なら強め合い、半波長の奇数倍なら弱め合います。</p>
  <p>強め合いの条件: $|r_1 - r_2| = m\lambda$</p>
  <p>弱め合いの条件: $|r_1 - r_2| = (m + 1/2)\lambda$</p>
  """,
  simulation: CircularInterferenceSimulation(),
);

class CircularInterferenceSimulation extends WaveSimulation {
  CircularInterferenceSimulation()
      : super(
          title: "円形波干渉",
          is3D: true,
          formula: const Column(
            children: [
              FormulaDisplay(
                  r'\color{#B38CFF}{z_1 = A \sin\left(2\pi\left(\frac{t}{T} - \frac{r_1}{\lambda}\right)\right)}'),
              SizedBox(height: 4),
              FormulaDisplay(
                  r'\color{#8CFFB3}{z_2 = A \sin\left(2\pi\left(\frac{t}{T} - \frac{r_2}{\lambda}\right) + \phi\right)}'),
              SizedBox(height: 4),
              FormulaDisplay(r'\color{#00BFFF}{z = z_1 + z_2}'),
            ],
          ),
        );

  @override
  Map<String, double> get initialParameters => getInitialParamsWithObs(
        baseParams: {
          'lambda': 2.0,
          'periodT': 1.0,
          'a': 2.0,
          'phi': 0.0,
        },
        obsX: 2.0,
        obsY: 0.0,
      );

  @override
  Set<String> get initialActiveIds => {'combined'};

  @override
  List<Widget> buildControls(context, params, updateParam) {
    return [
      Text(
        'λ = ${params['lambda']!.toStringAsFixed(2)}  a = ${params['a']!.toStringAsFixed(2)}  φ = ${(params['phi']! / math.pi).toStringAsFixed(2)}π',
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
      ThicknessLSlider(
        label: 'a',
        value: params['a']!,
        onChanged: (v) => updateParam('a', v),
      ),
      PhiSlider(
        value: params['phi']!,
        onChanged: (v) => updateParam('phi', v),
      ),
      ...buildObsSliders(params, updateParam),
    ];
  }

  @override
  Widget buildExtraControls(context, activeIds, updateActiveIds) {
    return Wrap(
      spacing: 8,
      children: [
        buildChip('波1', 'wave1', Colors.purpleAccent, activeIds, updateActiveIds,
            fontSize: 12),
        buildChip('波2', 'wave2', Colors.greenAccent, activeIds, updateActiveIds,
            fontSize: 12),
        buildChip('合成', 'combined', Colors.blueAccent, activeIds, updateActiveIds,
            fontSize: 12),
      ],
    );
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    final field = CircularInterferenceField(
      lambda: params['lambda']!,
      periodT: params['periodT']!,
      a: params['a']!,
      phi: params['phi']!,
      amplitude: 0.3,
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
          WaveMarker(point: math.Point(0.0, params['a']!), color: Colors.yellow),
          WaveMarker(
              point: math.Point(0.0, -params['a']!), color: Colors.yellow),
          getObsMarker(params, label: '合成波の観測点'),
        ],
      ),
    );
  }
}
