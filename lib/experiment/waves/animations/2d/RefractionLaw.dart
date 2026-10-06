import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';
import 'dart:math' as math;
import 'package:joyphysics/l10n/anim_ui.dart';

final refractionLaw = createWaveVideo(
  title: "2次元直線波の屈折",
  titleEn: 'Refraction of a 2D plane wave',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>スネルの法則: $n_1 \sin \theta_1 = n_2 \sin \theta_2$</p>
  <p>屈折率の大きい媒質に入ると、波長が短くなり、進む方向が法線に近づきます。</p>
  <div class="common-box">注意</div>
  <p>実際には、屈折率が異なる境界面では透過（屈折）と同時に反射も起きます。このシミュレーションでは、波長と進行方向の変化を見やすくするため、反射波は描いていません。</p>
  """,
  latexEn: r"""
  <div class="common-box">Key points</div>
  <p>Snell's law: $n_1 \sin \theta_1 = n_2 \sin \theta_2$</p>
  <p>When the wave enters a medium with larger refractive index, the wavelength shortens and the direction of travel bends toward the normal.</p>
  <div class="common-box">Note</div>
  <p>In reality, both transmission (refraction) and reflection occur at an interface between different refractive indices. This simulation omits the reflected wave so that the changes in wavelength and direction are easier to see.</p>
  """,
  simulation: RefractionLawSimulation(),
);

class RefractionLawSimulation extends WaveSimulation {
  RefractionLawSimulation()
      : super(
          title: animL("2次元直線波の屈折", "Refraction of a 2D plane wave"),
          is3D: true,
          formula: const FormulaDisplay(r'n_1\sin\theta_1=n_2\sin\theta_2'),
        );

  @override
  Map<String, double> get initialParameters => getInitialParamsWithObs(
        baseParams: {
          'theta': 25 * math.pi / 180,
          'lambda': 2.0,
          'periodT': 0.7,
          'n2': 1.5,
          'slabWidth': 3.0,
        },
        obsX: 2.0,
        obsY: 0.0,
      );

  @override
  List<Widget> buildControls(context, params, updateParam) {
    final thetaDeg = (params['theta']! * 180 / math.pi);
    return [
      Text(
        'θ = ${thetaDeg.toStringAsFixed(0)}°  λ = ${params['lambda']!.toStringAsFixed(2)}  n = ${params['n2']!.toStringAsFixed(2)}  L = ${params['slabWidth']!.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 12),
      ),
      ThetaSlider(
        value: params['theta']!,
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
        value: params['n2']!,
        onChanged: (v) => updateParam('n2', v),
      ),
      ThicknessLSlider(
        value: params['slabWidth']!,
        onChanged: (v) => updateParam('slabWidth', v),
      ),
      ...buildObsSliders(params, updateParam),
    ];
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    final field = SlabRefractionWaveField(
      theta: params['theta']!,
      lambda: params['lambda']!,
      periodT: params['periodT']!,
      n: params['n2']!,
      slabWidth: params['slabWidth']!,
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
          getObsMarker(params, label: animL('観測点 (a, b)', 'Observation point (a, b)')),
        ],
        mediumSlab: MediumSlabOverlay(
          xStart: 0.0,
          xEnd: params['slabWidth']!,
          color: Colors.yellow,
          opacity: 0.45,
        ),
      ),
    );
  }
}
