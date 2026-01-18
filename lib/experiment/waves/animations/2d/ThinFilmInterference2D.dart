import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';
import 'dart:math' as math;

final thinFilmInterference2D = createWaveVideo(
  title: "薄膜干渉 (2次元)",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>光路差: $\Delta = 2nd \cos \theta_2$</p>
  <p>反射時に位相がずれる条件（固定端・自由端）に注意して、強め合い・弱め合いの条件が決まります。</p>
  """,
  simulation: ThinFilmInterference2DSimulation(),
);

class ThinFilmInterference2DSimulation extends PhysicsSimulation {
  ThinFilmInterference2DSimulation()
      : super(
          title: "薄膜干渉 (2次元)",
          is3D: true,
          formula: const FormulaDisplay(r'\Delta = 2nd \cos \theta_2'),
        );

  @override
  Map<String, double> get initialParameters => {
        'theta': 30 * math.pi / 180,
        'lambda': 2.0,
        'periodT': 1.0,
        'n': 1.5,
        'thicknessL': 2.0,
      };

  @override
  Set<String> get initialActiveIds => {'incident', 'reflected1', 'reflected2', 'combined'};

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
    ];
  }

  @override
  Widget buildExtraControls(context, activeIds, updateActiveIds) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        _buildChip('入射', 'incident', Colors.purpleAccent, activeIds, updateActiveIds),
        _buildChip('反射1', 'reflected1', Colors.greenAccent, activeIds, updateActiveIds),
        _buildChip('反射2', 'reflected2', Colors.orangeAccent, activeIds, updateActiveIds),
        _buildChip('合成', 'combined', Colors.blueAccent, activeIds, updateActiveIds),
      ],
    );
  }

  Widget _buildChip(String label, String id, Color color, Set<String> activeIds, void Function(Set<String>) update) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 10)),
      selected: activeIds.contains(id),
      onSelected: (val) {
        final next = Set<String>.from(activeIds);
        val ? next.add(id) : next.remove(id);
        update(next);
      },
      selectedColor: color.withOpacity(0.3),
      checkmarkColor: color,
      padding: EdgeInsets.zero,
    );
  }

  @override
  Widget buildAnimation(context, time, azimuth, tilt, scale, params, activeIds) {
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
