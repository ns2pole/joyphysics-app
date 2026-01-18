import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_line_painter.dart';
import '../widgets/wave_slider.dart';

final pulseReflection1D = createWaveVideo(
  title: "1次元パルスの反射",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>パルス波が境界で反射するとき、端の条件によって反射の仕方が異なります。</p>
  <ul>
    <li><b>自由端反射</b>：端が自由に動ける場合、パルスは同じ向き（正の変位なら正のまま）で反射します。位相同士が強め合い、端での変位は最大で入射波の2倍になります。</li>
    <li><b>固定端反射</b>：端が固定されている場合、パルスは逆向き（正の変位なら負に反転）で反射します。端での変位は常に0になります。</li>
  </ul>
  """,
  simulation: PulseReflection1DSimulation(),
);

class PulseReflection1DSimulation extends WaveSimulation {
  PulseReflection1DSimulation()
      : super(
          title: "1次元パルスの反射",
          is3D: false,
          formula: const Column(
            children: [
              FormulaDisplay(r'y = y_{incident} + y_{reflected}'),
            ],
          ),
        );

  @override
  Map<String, double> get initialParameters => getInitialParamsWithObs(
        baseParams: {
          'lambda': 2.0,
          'periodT': 1.0,
          'pulseWidth': 2.0,
          'isFixedEnd': 1.0, // 1 for fixed, 0 for free
          'shapeType': 0.0, // 0: sine(half), 1: sine(full), 2: triangle
        },
        obsX: 0.0,
      );

  @override
  Set<String> get initialActiveIds => {'incident', 'reflected', 'combined'};

  @override
  List<Widget> buildControls(context, params, updateParam) {
    return [
      Text(
        '速度 v = ${(params['lambda']! / params['periodT']!).toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 12),
      ),
      WaveParameterSlider(
        label: '速度',
        value: params['lambda']!,
        min: 0.1,
        max: 5.0,
        onChanged: (v) => updateParam('lambda', v),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          const Text('波形: ', style: TextStyle(fontSize: 12)),
          ChoiceChip(
            label: const Text('sin(半波)', style: TextStyle(fontSize: 12)),
            selected: params['shapeType'] == 0.0,
            onSelected: (val) => updateParam('shapeType', 0.0),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          const SizedBox(width: 4),
          ChoiceChip(
            label: const Text('sin(1周期)', style: TextStyle(fontSize: 12)),
            selected: params['shapeType'] == 1.0,
            onSelected: (val) => updateParam('shapeType', 1.0),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          const SizedBox(width: 4),
          ChoiceChip(
            label: const Text('三角波', style: TextStyle(fontSize: 12)),
            selected: params['shapeType'] == 2.0,
            onSelected: (val) => updateParam('shapeType', 2.0),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          const Text('端条件: ', style: TextStyle(fontSize: 12)),
          ChoiceChip(
            label: const Text('固定端', style: TextStyle(fontSize: 12)),
            selected: params['isFixedEnd'] == 1.0,
            onSelected: (val) => updateParam('isFixedEnd', 1.0),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          const SizedBox(width: 4),
          ChoiceChip(
            label: const Text('自由端', style: TextStyle(fontSize: 12)),
            selected: params['isFixedEnd'] == 0.0,
            onSelected: (val) => updateParam('isFixedEnd', 0.0),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ],
      ),
      ...buildObsSliders(params, updateParam, is2D: false),
    ];
  }

  @override
  Widget buildExtraControls(context, activeIds, updateActiveIds) {
    return Wrap(
      spacing: 8,
      children: [
        buildChip('入射', 'incident', Colors.purpleAccent, activeIds,
            updateActiveIds,
            fontSize: 14),
        buildChip('反射', 'reflected', Colors.greenAccent, activeIds,
            updateActiveIds,
            fontSize: 14),
        buildChip('合成', 'combined', Colors.blueAccent, activeIds,
            updateActiveIds,
            fontSize: 14),
      ],
    );
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    PulseShape shape;
    if (params['shapeType'] == 0.0) {
      shape = PulseShape.sine;
    } else if (params['shapeType'] == 1.0) {
      shape = PulseShape.fullSine;
    } else {
      shape = PulseShape.triangle;
    }

    final field = PulseReflectionField(
      lambda: params['lambda']!,
      periodT: params['periodT']!,
      pulseWidth: params['pulseWidth']!,
      shape: shape,
      amplitude: 0.6,
      isFixedEnd: params['isFixedEnd'] == 1.0,
      boundaryX: 5.0,
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

