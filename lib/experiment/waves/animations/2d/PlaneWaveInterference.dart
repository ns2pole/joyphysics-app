import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';
import 'dart:math' as math;

final planeWaveInterference = createWaveVideo(
  title: "直線波干渉",
  latex: r"""
  <div class="common-box">解説</div>
  <p>2つの異なる方向へ進む直線波が重なり合うことで干渉縞が生じます。</p>
  <p>合成波の変位 $z$ は、個々の波の変位 $z_1, z_2$ の和で表されます：</p>
  <p>\[ z = z_1 + z_2 \]</p>
  <p>周期 $T_1 = T_2$ のとき、「節線」（オレンジ・点線）で弱め合い、「腹線」（オレンジ・実線）で強め合いの曲線を表示できます（周期が異なると定常な節線・腹線はないため描画しません）。</p>
  """,
  simulation: PlaneWaveInterferenceSimulation(),
);

class PlaneWaveInterferenceSimulation extends WaveSimulation {
  PlaneWaveInterferenceSimulation()
      : super(
          title: "直線波干渉",
          is3D: true,
          formula: const Column(
            children: [
              FormulaDisplay(
                  r'\color{#B38CFF}{z_1 = A \sin(2\pi(\frac{t}{T_1} - \frac{x\cos\theta_1+y\sin\theta_1}{\lambda_1}))}'),
              SizedBox(height: 4),
              FormulaDisplay(
                  r'\color{#8CFFB3}{z_2 = A \sin(2\pi(\frac{t}{T_2} - \frac{x\cos\theta_2+y\sin\theta_2}{\lambda_2}))}'),
              SizedBox(height: 4),
              FormulaDisplay(r'\color{#00BFFF}{z = z_1 + z_2}'),
            ],
          ),
        );

  @override
  Map<String, double> get initialParameters => getInitialParamsWithObs(
        baseParams: {
          'theta1': 0.0,
          'lambda1': 1.0,
          'periodT1': 0.7,
          'theta2': math.pi / 4,
          'lambda2': 1.0,
          'periodT2': 0.7,
        },
        obsX: 0.0,
        obsY: 0.0,
      );

  @override
  Set<String> get initialActiveIds =>
      {'combined', 'showNodalLines', 'showAntinodalLines'};

  @override
  List<WavefrontLayer> get wavefrontLayers => const [
        WavefrontLayer(id: 'wave1', label: '波1', color: Colors.purpleAccent),
        WavefrontLayer(id: 'wave2', label: '波2', color: Colors.greenAccent),
      ];

  bool _samePeriod(Map<String, double> params) =>
      (params['periodT1']! - params['periodT2']!).abs() < 1e-9;

  @override
  List<Widget> buildControls(context, params, updateParam) {
    return [
      const Text('波1のパラメータ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ThetaSlider(
        value: params['theta1']!,
        maxDeg: 360,
        onChanged: (v) => updateParam('theta1', v),
      ),
      LambdaSlider(
        value: params['lambda1']!,
        onChanged: (v) => updateParam('lambda1', v),
      ),
      PeriodTSlider(
        value: params['periodT1']!,
        onChanged: (v) => updateParam('periodT1', v),
      ),
      const SizedBox(height: 8),
      const Text('波2のパラメータ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ThetaSlider(
        value: params['theta2']!,
        maxDeg: 360,
        onChanged: (v) => updateParam('theta2', v),
      ),
      LambdaSlider(
        value: params['lambda2']!,
        onChanged: (v) => updateParam('lambda2', v),
      ),
      PeriodTSlider(
        value: params['periodT2']!,
        onChanged: (v) => updateParam('periodT2', v),
      ),
      ...buildObsSliders(params, updateParam),
    ];
  }

  @override
  Widget buildExtraControls(context, activeIds, updateActiveIds) {
    return Wrap(
      spacing: 8,
      alignment: WrapAlignment.center,
      children: [
        buildChip('波1', 'wave1', Colors.purpleAccent, activeIds, updateActiveIds,
            fontSize: 12),
        buildChip('波2', 'wave2', Colors.greenAccent, activeIds, updateActiveIds,
            fontSize: 12),
        buildChip('合成', 'combined', Colors.blueAccent, activeIds, updateActiveIds,
            fontSize: 12),
        buildChip('節線', 'showNodalLines', Colors.orangeAccent, activeIds,
            updateActiveIds,
            fontSize: 12),
        buildChip('腹線', 'showAntinodalLines', Colors.orangeAccent, activeIds,
            updateActiveIds,
            fontSize: 12),
      ],
    );
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    final field = PlaneWaveInterferenceField(
      theta1: params['theta1']!,
      lambda1: params['lambda1']!,
      periodT1: params['periodT1']!,
      theta2: params['theta2']!,
      lambda2: params['lambda2']!,
      periodT2: params['periodT2']!,
      amplitude: 0.3,
    );
    final canNodal = _samePeriod(params);
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
          getObsMarker(params, label: '観測点'),
        ],
        showNodalLines: canNodal && activeIds.contains('showNodalLines'),
        nodalMetric: canNodal ? field.nodalMetric : null,
        showAntinodalLines:
            canNodal && activeIds.contains('showAntinodalLines'),
        antinodalMetric: canNodal ? field.antinodalMetric : null,
      ),
    );
  }
}
