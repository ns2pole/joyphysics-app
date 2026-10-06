import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';
import 'dart:math' as math;
import 'package:joyphysics/l10n/anim_ui.dart';

final reflectionLaw2D = createWaveVideo(
  title: "反射の法則 (自由端・2次元)",
  titleEn: 'Law of reflection (free end, 2D)',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>反射の法則: 入射角 = 反射角</p>
  <p>自由端反射では、位相の変化はありません。</p>
  """,
  latexEn: r"""
  <div class="common-box">Key points</div>
  <p>Law of reflection: angle of incidence = angle of reflection</p>
  <p>In free-end reflection there is no phase change.</p>
  """,
  simulation: ReflectionLaw2DSimulation(),
);

class ReflectionLaw2DSimulation extends WaveSimulation {
  ReflectionLaw2DSimulation()
      : super(
          title: animL("反射の法則 (自由端)", "Law of reflection (free end)"),
          is3D: true,
          formula:
              const FormulaDisplay(r'\theta_{incident} = \theta_{reflected}'),
        );

  @override
  Map<String, double> get initialParameters => getInitialParamsWithObs(
        baseParams: {
          'theta': 30 * math.pi / 180,
          'lambda': 2.5,
          'periodT': 0.7,
        },
        obsX: -2.0,
        obsY: 0.0,
      );

  @override
  Set<String> get initialActiveIds => {'incident', 'reflected', 'combined'};

  @override
  List<WavefrontLayer> get wavefrontLayers => [
        WavefrontLayer(
            id: 'incident', label: animL('入射', 'Incident'), color: Colors.purpleAccent),
        WavefrontLayer(
            id: 'reflected', label: animL('反射', 'Reflected'), color: Colors.greenAccent),
      ];

  @override
  List<Widget> buildControls(context, params, updateParam) {
    final thetaDeg = (params['theta']! * 180 / math.pi);
    return [
      Text(
        'θ = ${thetaDeg.toStringAsFixed(0)}°   λ = ${params['lambda']!.toStringAsFixed(2)}   T = ${params['periodT']!.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 12),
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
      ...buildObsSliders(params, updateParam),
    ];
  }

  @override
  Widget buildExtraControls(context, activeIds, updateActiveIds) {
    const incidentColor = Color(0xFFB38CFF);
    const reflectedColor = Color(0xFF8CFFB3);
    const combinedColor = Color(0xFF8CCBFF);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildChip(animL('入射', 'Incident'), 'incident', incidentColor, activeIds, updateActiveIds),
        const SizedBox(width: 4),
        buildChip(animL('反射', 'Reflected'), 'reflected', reflectedColor, activeIds, updateActiveIds),
        const SizedBox(width: 4),
        buildChip(animL('合成', 'Combined'), 'combined', combinedColor, activeIds, updateActiveIds),
      ],
    );
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    final field = ReflectionWaveField(
      theta: params['theta']!,
      lambda: params['lambda']!,
      periodT: params['periodT']!,
      mode: ReflectionMode.combined,
      isFixedEnd: false,
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
