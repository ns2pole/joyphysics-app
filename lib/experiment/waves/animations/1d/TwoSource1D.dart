import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_line_painter.dart';
import '../widgets/wave_slider.dart';

final twoSource1D = createWaveVideo(
  title: "1次元干渉",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>2つの音源から発生した波が重なり合う様子を観察します。</p>
  <p>2つの音源の距離、波長、周期、位相のずれを変化させて、合成波がどのように変化するかを確認しましょう。</p>
  """,
  simulation: TwoSource1DSimulation(),
);

class TwoSource1DSimulation extends WaveSimulation {
  TwoSource1DSimulation()
      : super(
          title: "1次元干渉",
          is3D: false,
          formula: const Column(
            children: [
              FormulaDisplay(r'y = y_1 + y_2'),
            ],
          ),
        );

  @override
  Map<String, double> get initialParameters => getInitialParamsWithObs(
        baseParams: {
          'lambda': 1.0,
          'periodT': 0.7,
          'distanceD': 2.0,
          'phaseShift': 0.0,
        },
        obsX: 0.0,
      );

  @override
  Set<String> get initialActiveIds => {'wave1', 'wave2', 'combined'};

  @override
  List<Widget> buildControls(context, params, updateParam) {
    return [
      LambdaSlider(
        label: '波長',
        value: params['lambda']!,
        onChanged: (v) => updateParam('lambda', v),
      ),
      PeriodTSlider(
        label: '周期',
        value: params['periodT']!,
        onChanged: (v) => updateParam('periodT', v),
      ),
      ThicknessLSlider(
        label: '音源間距離D',
        value: params['distanceD']!,
        min: 0.1,
        max: 8.0,
        onChanged: (v) => updateParam('distanceD', v),
      ),
      WaveParameterSlider(
        label: '位相ずれ',
        value: params['phaseShift']!,
        min: 0.0,
        max: 2 * math.pi,
        onChanged: (v) => updateParam('phaseShift', v),
      ),
      ...buildObsSliders(params, updateParam, is2D: false),
    ];
  }

  @override
  Widget buildExtraControls(context, activeIds, updateActiveIds) {
    return Wrap(
      spacing: 8,
      children: [
        buildChip('音源1', 'wave1', Colors.purpleAccent, activeIds, updateActiveIds,
            fontSize: 14),
        buildChip('音源2', 'wave2', Colors.greenAccent, activeIds, updateActiveIds,
            fontSize: 14),
        buildChip('合成波', 'combined', Colors.blueAccent, activeIds, updateActiveIds,
            fontSize: 14),
      ],
    );
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    final field = TwoSource1DField(
      lambda: params['lambda']!,
      periodT: params['periodT']!,
      distanceD: params['distanceD']!,
      phaseShift: params['phaseShift']!,
      amplitude: 0.4,
    );
    return CustomPaint(
      size: Size.infinite,
      painter: WaveLinePainter(
        time: time,
        field: field,
        surfaceColor: Colors.blue,
        showTicks: true,
        activeComponentIds: activeIds,
        scale: scale,
        markers: [
          WaveMarker(
            point: math.Point(-params['distanceD']! / 2, 0),
            color: Colors.purple,
            label: 'S1',
          ),
          WaveMarker(
            point: math.Point(params['distanceD']! / 2, 0),
            color: Colors.green,
            label: 'S2',
          ),
          getObsMarker(params, label: '観測点'),
        ],
      ),
    );
  }
}
