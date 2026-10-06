import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';
import 'dart:math' as math;
import 'package:joyphysics/l10n/anim_ui.dart';

final circularPlaneInterference = createWaveVideo(
  title: "円形波と直線波の干渉",
  titleEn: 'Interference of a circular wave and a plane wave',
  latex: r"""
  <div class="common-box">解説</div>
  <p>中心から広がる円形波と、一方向に進む直線波が重なり合うことで干渉縞が生じます。</p>
  <p>直線波は $x$ 軸の負の方向からやってくるように設定されています。</p>
  <p>合成波の変位 $z$ は、円形波の変位 $z_C$ と直線波の変位 $z_P$ の和です：</p>
  <p>\[ z = z_C + z_P \]</p>
  <p>周期が異なると、定常な節線・腹線はありません。</p>
  """,
  latexEn: r"""
  <div class="common-box">Explanation</div>
  <p>Interference fringes form when a circular wave spreading from a center overlaps a plane wave traveling in one direction.</p>
  <p>The plane wave is set to arrive from the negative $x$ direction.</p>
  <p>The displacement $z$ of the resultant wave is the sum of the circular-wave displacement $z_C$ and the plane-wave displacement $z_P$:</p>
  <p>\[ z = z_C + z_P \]</p>
  <p>If the periods differ, there are no stationary nodal or antinodal lines.</p>
  """,
  simulation: CircularPlaneInterferenceSimulation(),
);

class CircularPlaneInterferenceSimulation extends WaveSimulation {
  CircularPlaneInterferenceSimulation()
      : super(
          title: animL("円形波と直線波の干渉", "Interference of a circular wave and a plane wave"),
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
  List<WavefrontLayer> get wavefrontLayers => [
        WavefrontLayer(
            id: 'waveC', label: animL('円形波', 'Circular wave'), color: Colors.purpleAccent),
        WavefrontLayer(
            id: 'waveP', label: animL('直線波', 'Plane wave'), color: Colors.greenAccent),
      ];

  bool _samePeriod(Map<String, double> params) =>
      (params['periodTC']! - params['periodTP']!).abs() < 1e-9;

  @override
  List<Widget> buildControls(context, params, updateParam) {
    return [
      Text(animL('円形波のパラメータ', 'Circular wave parameters'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
      Text(animL('直線波のパラメータ', 'Plane wave parameters'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
        buildChip(animL('円形波', 'Circular wave'), 'waveC', Colors.purpleAccent, activeIds, updateActiveIds,
            fontSize: 12),
        buildChip(animL('直線波', 'Plane wave'), 'waveP', Colors.greenAccent, activeIds, updateActiveIds,
            fontSize: 12),
        buildChip(animL('合成', 'Combined'), 'combined', Colors.blueAccent, activeIds, updateActiveIds,
            fontSize: 12),
        buildChip(animL('節線', 'Nodal lines'), 'showNodalLines', Colors.orangeAccent, activeIds,
            updateActiveIds,
            fontSize: 12),
        buildChip(animL('腹線', 'Antinodal lines'), 'showAntinodalLines', Colors.orangeAccent, activeIds,
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
          WaveMarker(point: math.Point(0.0, 0.0), color: Colors.yellow, label: animL('円形波源', 'Circular source')),
          getObsMarker(params, label: animL('観測点', 'Observation point')),
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
