import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';
import 'dart:math' as math;
import 'package:joyphysics/l10n/anim_ui.dart';

final thinFilmInterference2D = createWaveVideo(
  title: "薄膜干渉 (2次元)",
  titleEn: 'Thin-film interference (2D)',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>膜の中を往復する光路差は $\displaystyle \Delta=2nd\cos\theta_2$ です。$\theta_2$ は膜の中の角です。</p>
  <p>表面（屈折率が小さい側から大きい側）だけ位相が $\pi$ ずれるとき、反射の弱め合いは $\displaystyle \frac{\Delta}{\lambda}=m$、強め合いは $\displaystyle \frac{\Delta}{\lambda}=m+\frac{1}{2}$ です。</p>
  """,
  latexEn: r"""
  <div class="common-box">Key points</div>
  <p>The optical path difference for a round trip inside the film is $\displaystyle \Delta=2nd\cos\theta_2$. Here $\theta_2$ is the angle inside the film.</p>
  <p>When only the front surface (from lower to higher refractive index) shifts the phase by $\pi$, destructive interference in reflection occurs for $\displaystyle \frac{\Delta}{\lambda}=m$, and constructive interference for $\displaystyle \frac{\Delta}{\lambda}=m+\frac{1}{2}$.</p>
  """,
  simulation: ThinFilmInterference2DSimulation(),
);

class ThinFilmInterference2DSimulation extends WaveSimulation {
  ThinFilmInterference2DSimulation()
      : super(
          title: animL("薄膜干渉 (2次元)", "Thin-film interference (2D)"),
          is3D: true,
          formula: const FormulaDisplay(r'\Delta = 2nd \cos \theta_2'),
        );

  @override
  Map<String, double> get initialParameters => getInitialParamsWithObs(
        baseParams: {
          'theta': 30 * math.pi / 180,
          'lambda': 2.0,
          'periodT': 0.7,
          'n': 1.5,
          'thicknessL': 2.0,
        },
        obsX: 2.0,
        obsY: 0.0,
      );

  @override
  Set<String> get initialActiveIds =>
      {'incident', 'reflected1', 'reflected2', 'combined'};

  @override
  List<WavefrontLayer> get wavefrontLayers => [
        WavefrontLayer(
            id: 'incident', label: animL('入射', 'Incident'), color: Colors.purpleAccent),
        WavefrontLayer(
            id: 'reflected1', label: animL('反射1', 'Reflection 1'), color: Colors.greenAccent),
        WavefrontLayer(
            id: 'reflected2', label: animL('反射2', 'Reflection 2'), color: Colors.orangeAccent),
      ];

  @override
  List<Widget> buildControls(context, params, updateParam) {
    final thetaDeg = (params['theta']! * 180 / math.pi);
    final sinTheta2 = math.sin(params['theta']!) / params['n']!;
    final cosTheta2 = math.sqrt(math.max(0.0, 1.0 - sinTheta2 * sinTheta2));
    final opd = 2 * params['n']! * params['thicknessL']! * cosTheta2;

    return [
      Text(
        'θ = ${thetaDeg.toStringAsFixed(0)}°  λ = ${params['lambda']!.toStringAsFixed(2)}  n = ${params['n']!.toStringAsFixed(2)}  L = ${params['thicknessL']!.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 11),
      ),
      Text(
        '2nd cos θ₂ = ${opd.toStringAsFixed(3)}',
        style: const TextStyle(fontSize: 11),
      ),
      ThetaSlider(
        value: params['theta']!,
        maxDeg: 80,
        onChanged: (v) => updateParam('theta', v),
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
      ...buildObsSliders(params, updateParam),
    ];
  }

  @override
  Widget buildExtraControls(context, activeIds, updateActiveIds) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        buildChip(animL('入射', 'Incident'), 'incident', Colors.purpleAccent, activeIds,
            updateActiveIds,
            fontSize: 10),
        buildChip(animL('反射1', 'Reflection 1'), 'reflected1', Colors.greenAccent, activeIds,
            updateActiveIds,
            fontSize: 10),
        buildChip(animL('反射2', 'Reflection 2'), 'reflected2', Colors.orangeAccent, activeIds,
            updateActiveIds,
            fontSize: 10),
        buildChip(animL('合成', 'Combined'), 'combined', Colors.blueAccent, activeIds,
            updateActiveIds,
            fontSize: 10),
      ],
    );
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    final field = ThinFilmInterference2DField(
      theta: params['theta']!,
      lambda: params['lambda']!,
      periodT: params['periodT']!,
      n: params['n']!,
      thicknessL: params['thicknessL']!,
      amplitude: 0.4,
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
          getObsMarker(params, label: animL('合成波の観測点', 'Observation point of resultant wave')),
        ],
        mediumSlab: MediumSlabOverlay(
          xStart: 0.0,
          xEnd: params['thicknessL']!,
          color: Colors.yellow,
          opacity: 0.3,
        ),
      ),
    );
  }
}
