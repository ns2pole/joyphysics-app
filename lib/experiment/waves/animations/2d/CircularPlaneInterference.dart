import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';
import 'dart:math' as math;

final circularPlaneInterference = createWaveVideo(
  title: "円形波と直線波の干渉",
  latex: r"""
  <div class="common-box">解説</div>
  <p>中心から広がる円形波と、一方向に進む直線波が重なり合うことで干渉縞が生じます。</p>
  <p>直線波は $x$ 軸の負の方向からやってくるように設定されています。</p>
  <p>合成波の変位 $z$ は、円形波の変位 $z_C$ と直線波の変位 $z_P$ の和です：</p>
  <p>\[ z = z_C + z_P \]</p>
  <p>周期 $T_C = T_P$ のとき、「節線」（オレンジ・点線）で弱め合い、「腹線」（オレンジ・実線）で強め合いの曲線を表示できます（周期が異なると定常な節線・腹線はないため描画しません）。</p>
  """,
  simulation: CircularPlaneInterferenceSimulation(),
);

class CircularPlaneInterferenceSimulation extends WaveSimulation {
  CircularPlaneInterferenceSimulation()
      : super(
          title: "円形波と直線波の干渉",
          is3D: true,
          formula: const Column(
            children: [
              FormulaDisplay(
                  r'\color{#B38CFF}{z_C = A \sin(2\pi(\frac{t}{T_C} - \frac{r}{\lambda_C}))}'),
              SizedBox(height: 4),
              FormulaDisplay(
                  r'\color{#8CFFB3}{z_P = A \sin(2\pi(\frac{t}{T_P} - \frac{x\cos\theta+y\sin\theta}{\lambda_P}))}'),
              SizedBox(height: 4),
              FormulaDisplay(r'\color{#00BFFF}{z = z_C + z_P}'),
            ],
          ),
        );

  @override
  Map<String, double> get initialParameters => getInitialParamsWithObs(
        baseParams: {
          'lambdaC': 1.0,
          'periodTC': 0.7,
          'thetaP': 0.0, // X軸に垂直な波面（X正方向へ進行）
          'lambdaP': 1.0,
          'periodTP': 0.7,
        },
        obsX: 0.0,
        obsY: 0.0,
      );

  @override
  Set<String> get initialActiveIds =>
      {'combined', 'showNodalLines', 'showAntinodalLines'};

  @override
  List<WavefrontLayer> get wavefrontLayers => const [
        WavefrontLayer(
            id: 'waveC', label: '円形波', color: Colors.purpleAccent),
        WavefrontLayer(
            id: 'waveP', label: '直線波', color: Colors.greenAccent),
      ];

  bool _samePeriod(Map<String, double> params) =>
      (params['periodTC']! - params['periodTP']!).abs() < 1e-9;

  @override
  List<Widget> buildControls(context, params, updateParam) {
    return [
      const Text('円形波のパラメータ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      LambdaSlider(
        label: 'λC',
        value: params['lambdaC']!,
        onChanged: (v) => updateParam('lambdaC', v),
      ),
      PeriodTSlider(
        label: 'TC',
        value: params['periodTC']!,
        onChanged: (v) => updateParam('periodTC', v),
      ),
      const SizedBox(height: 8),
      const Text('直線波のパラメータ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ThetaSlider(
        value: params['thetaP']!,
        maxDeg: 360,
        onChanged: (v) => updateParam('thetaP', v),
      ),
      LambdaSlider(
        label: 'λP',
        value: params['lambdaP']!,
        onChanged: (v) => updateParam('lambdaP', v),
      ),
      PeriodTSlider(
        label: 'TP',
        value: params['periodTP']!,
        onChanged: (v) => updateParam('periodTP', v),
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
        buildChip('円形波', 'waveC', Colors.purpleAccent, activeIds, updateActiveIds,
            fontSize: 12),
        buildChip('直線波', 'waveP', Colors.greenAccent, activeIds, updateActiveIds,
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
    final field = CircularPlaneInterferenceField(
      lambdaC: params['lambdaC']!,
      periodTC: params['periodTC']!,
      thetaP: params['thetaP']!,
      lambdaP: params['lambdaP']!,
      periodTP: params['periodTP']!,
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
          WaveMarker(point: const math.Point(0.0, 0.0), color: Colors.yellow, label: '円形波源'),
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
