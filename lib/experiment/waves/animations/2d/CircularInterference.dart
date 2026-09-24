import 'package:flutter/material.dart';
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
  <p>弱め合いの条件: $|r_1 - r_2| = \bigl(m + \frac{1}{2}\bigr)\lambda$</p>
  <p>観測点の変位は、2つの波の変位の和です。</p>
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
          'periodT': 0.7,
          'a': 2.0,
          'phi': 0.0,
        },
        obsX: 2.0,
        obsY: 0.0,
      );

  @override
  Set<String> get initialActiveIds =>
      {'combined', 'cross1', 'cross2', 'showNodalLines', 'showAntinodalLines'};

  @override
  List<WavefrontLayer> get wavefrontLayers => const [
        WavefrontLayer(id: 'wave1', label: '波1', color: Colors.purpleAccent),
        WavefrontLayer(id: 'wave2', label: '波2', color: Colors.greenAccent),
      ];

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          alignment: WrapAlignment.center,
          children: [
            buildChip('波1', 'wave1', Colors.purpleAccent, activeIds,
                updateActiveIds,
                fontSize: 12),
            buildChip('波2', 'wave2', Colors.greenAccent, activeIds,
                updateActiveIds,
                fontSize: 12),
            buildChip('合成', 'combined', Colors.blueAccent, activeIds,
                updateActiveIds,
                fontSize: 12),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          alignment: WrapAlignment.center,
          children: [
            buildChip('節線', 'showNodalLines', Colors.orangeAccent, activeIds,
                updateActiveIds,
                fontSize: 12),
            buildChip('腹線', 'showAntinodalLines', Colors.orangeAccent, activeIds,
                updateActiveIds,
                fontSize: 12),
            buildChip('断面1', 'cross1', Colors.purpleAccent, activeIds,
                updateActiveIds,
                fontSize: 12),
            buildChip('断面2', 'cross2', Colors.greenAccent, activeIds,
                updateActiveIds,
                fontSize: 12),
          ],
        ),
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
    final a = params['a']!;
    final obs = math.Point(params['obsX']!, params['obsY']!);
    final sections = <RadialCrossSectionSpec>[
      if (activeIds.contains('cross1'))
        RadialCrossSectionSpec(
          start: math.Point(0.0, a),
          end: obs,
          color: Colors.purpleAccent,
          zAt: (x, y) => field.z1(x, y, time),
        ),
      if (activeIds.contains('cross2'))
        RadialCrossSectionSpec(
          start: math.Point(0.0, -a),
          end: obs,
          color: Colors.greenAccent,
          zAt: (x, y) => field.z2(x, y, time),
        ),
    ];
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
          WaveMarker(point: math.Point(0.0, a), color: Colors.yellow),
          WaveMarker(point: math.Point(0.0, -a), color: Colors.yellow),
          getObsMarker(params, label: '合成波の観測点'),
        ],
        radialCrossSections: sections,
        showCrossSectionSum: true,
        showNodalLines: activeIds.contains('showNodalLines'),
        nodalMetric: field.nodalMetric,
        showAntinodalLines: activeIds.contains('showAntinodalLines'),
        antinodalMetric: field.antinodalMetric,
      ),
    );
  }
}
