import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_line_painter.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';

final thinFilmInterference1D = createWaveVideo(
  title: "薄膜干渉 (1次元)",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>表面での反射と裏面での反射が干渉します。</p>
  <p>屈折率の大きい媒質から小さい媒質への反射は自由端反射（位相変化なし）、小さい媒質から大きい媒質への反射は固定端反射（位相変化$\pi$）となります。</p>
  <p>光路差: $2nL$</p>
  """,
  simulation: ThinFilmInterference1DSimulation(),
);

class ThinFilmInterference1DSimulation extends WaveSimulation {
  ThinFilmInterference1DSimulation()
      : super(
          title: "薄膜干渉 (1次元)",
          is3D: false,
          formula: const Column(
            children: [
              FormulaDisplay(
                  r'\color{#B38CFF}{z_i = A \sin\left(2\pi\left(\frac{t}{T} - \frac{x}{\lambda_1}\right)\right)}'),
              FormulaDisplay(
                  r'\color{#8CFFB3}{z_{r1} = -A \sin\left(2\pi\left(\frac{t}{T} + \frac{x}{\lambda_1}\right)\right)}'),
              FormulaDisplay(
                  r'\color{#FFB38C}{z_{r2} = A \sin\left(2\pi\left(\frac{t}{T} + \frac{x - 2nL}{\lambda_1}\right)\right)}'),
            ],
          ),
        );

  @override
  Map<String, double> get initialParameters => getInitialParamsWithObs(
        baseParams: {
          'lambda': 2.0,
          'periodT': 1.0,
          'n': 1.5,
          'thicknessL': 1.0,
        },
        obsX: 2.0,
      );

  @override
  Set<String> get initialActiveIds => {'incident', 'combinedReflected'};

  @override
  List<Widget> buildControls(context, params, updateParam) {
    final opd = 2 * params['n']! * params['thicknessL']!;
    return [
      Text(
        'λ = ${params['lambda']!.toStringAsFixed(2)}  n = ${params['n']!.toStringAsFixed(2)}  L = ${params['thicknessL']!.toStringAsFixed(2)}  2nL = ${opd.toStringAsFixed(3)}',
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
      ThicknessLSlider(
        value: params['thicknessL']!,
        onChanged: (v) => updateParam('thicknessL', v),
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
        buildChip('反射1', 'reflected1', Colors.greenAccent, activeIds,
            updateActiveIds,
            fontSize: 12),
        buildChip('反射2', 'reflected2', Colors.orangeAccent, activeIds,
            updateActiveIds,
            fontSize: 12),
        buildChip('合成反射', 'combinedReflected', Colors.blueAccent, activeIds,
            updateActiveIds,
            fontSize: 12),
      ],
    );
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    final field = ThinFilmInterferenceField(
      lambda: params['lambda']!,
      periodT: params['periodT']!,
      n: params['n']!,
      thicknessL: params['thicknessL']!,
      mode: ThinFilmMode.combinedReflected,
      amplitude: 0.5,
    );
    return CustomPaint(
      size: Size.infinite,
      painter: WaveLinePainter(
        time: time,
        field: field,
        surfaceColor: Colors.blue,
        showTicks: true,
        boundaryX: params['thicknessL']!,
        activeComponentIds: activeIds,
        scale: scale,
        markers: [
          getObsMarker(params, label: '合成波の観測点'),
        ],
        mediumSlab: MediumSlabOverlay(
          xStart: 0.0,
          xEnd: params['thicknessL']!,
          color: Colors.yellow,
          opacity: 0.4,
        ),
      ),
    );
  }
}
