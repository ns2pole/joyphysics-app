import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_line_painter.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';

final thinFilmInterference1D = createWaveVideo(
  title: "薄膜干渉 (1次元)",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>表面での反射と裏面での反射が干渉します。</p>
  <p>屈折率の大きい媒質から小さい媒質への反射は自由端反射（位相変化なし）、小さい媒質から大きい媒質への反射は固定端反射（位相変化$\pi$）となります。</p>
  <p>光路差: $2nL$</p>
  """,
  simulation: ThinFilmInterference1DSimulation(),
);

class ThinFilmInterference1DSimulation extends PhysicsSimulation {
  ThinFilmInterference1DSimulation()
      : super(
          title: "薄膜干渉 (1次元)",
          is3D: false,
          formula: Column(
            children: [
              Math.tex(
                r'\color{#B38CFF}{z_i = A \sin\left(2\pi\left(\frac{t}{T} - \frac{x}{\lambda_1}\right)\right)}',
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Math.tex(
                r'\color{#8CFFB3}{z_{r1} = -A \sin\left(2\pi\left(\frac{t}{T} + \frac{x}{\lambda_1}\right)\right)}',
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Math.tex(
                r'\color{#FFB38C}{z_{r2} = A \sin\left(2\pi\left(\frac{t}{T} + \frac{x - 2nL}{\lambda_1}\right)\right)}',
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );

  @override
  Map<String, double> get initialParameters => {
        'lambda': 4.0,
        'periodT': 1.0,
        'n': 1.5,
        'thicknessL': 1.0,
      };

  @override
  Set<String> get initialActiveIds => {'incident', 'combinedReflected'};

  @override
  List<Widget> buildControls(context, params, updateParam) {
    final opd = 2 * params['n']! * params['thicknessL']!;
    return [
      Text(
        'λ = ${params['lambda']!.toStringAsFixed(2)}  n = ${params['n']!.toStringAsFixed(2)}  L = ${params['thicknessL']!.toStringAsFixed(2)}  2nL = ${opd.toStringAsFixed(3)}',
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
      spacing: 8,
      children: [
        _buildModeButton('入射波', 'incident', activeIds, updateActiveIds),
        _buildModeButton('反射1', 'reflected1', activeIds, updateActiveIds),
        _buildModeButton('反射2', 'reflected2', activeIds, updateActiveIds),
        _buildModeButton('合成反射', 'combinedReflected', activeIds, updateActiveIds),
      ],
    );
  }

  Widget _buildModeButton(String label, String id, Set<String> activeIds, void Function(Set<String>) update) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: activeIds.contains(id),
      onSelected: (selected) {
        final next = Set<String>.from(activeIds);
        selected ? next.add(id) : next.remove(id);
        update(next);
      },
    );
  }

  @override
  Widget buildAnimation(context, time, azimuth, tilt, params, activeIds) {
    final field = ThinFilmInterferenceField(
      lambda: params['lambda']!,
      periodT: params['periodT']!,
      n: params['n']!,
      thicknessL: params['thicknessL']!,
      mode: ThinFilmMode.combinedReflected,
      amplitude: 0.5,
    );
    return CustomPaint(
      size: Size.infinite,
      painter: WaveLinePainter(
        time: time,
        field: field,
        surfaceColor: Colors.blue,
        showTicks: true,
        boundaryX: params['thicknessL']!,
        activeComponentIds: activeIds,
        mediumSlab: MediumSlabOverlay(
          xStart: 0.0,
          xEnd: params['thicknessL']!,
          color: Colors.yellow,
          opacity: 0.4,
        ),
      ),
    );
  }
}
