import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../painters/thin_film_stack_painter.dart';
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

class ThinFilmInterference1DSimulation extends WaveSimulation {
  ThinFilmInterference1DSimulation()
      : super(
          title: "薄膜干渉 (1次元)",
          is3D: false,
          formula: const Column(
            children: [
              FormulaDisplay(
                  r'\color{#B38CFF}{z_i = A \sin\left(2\pi\left(\frac{t}{T} - \frac{x}{\lambda_1}\right)\right)}'),
              FormulaDisplay(
                  r'\color{#8CFFB3}{z_{r1} = -A \sin\left(2\pi\left(\frac{t}{T} + \frac{x}{\lambda_1}\right)\right)}'),
              FormulaDisplay(
                  r'\color{#FFB38C}{z_{r2} = A \sin\left(2\pi\left(\frac{t}{T} + \frac{x - 2nL}{\lambda_1}\right)\right)}'),
            ],
          ),
        );

  @override
  Map<String, double> get initialParameters => {
        // 屈折率
        'n': 1.50,
        // nm 風のスケール（表示用）。内部計算は scaleFactor で割って [-5,5] スケールへ落とす。
        'Lnm': 500.0,
      };

  @override
  Set<String> get initialActiveIds => {
        'incident',
        'reflected1',
        'reflected2',
        'combinedReflected',
      };

  @override
  List<Widget> buildControls(context, params, updateParam) {
    final n = params['n']!;
    final lnm = params['Lnm']!;
    final opdNm = 2 * n * lnm;
    return [
      Text(
        'n = ${n.toStringAsFixed(2)}   L = ${lnm.toStringAsFixed(0)}   2nL = ${opdNm.toStringAsFixed(0)}',
        style: const TextStyle(fontSize: 12),
      ),
      RefractiveIndexSlider(
        value: n,
        onChanged: (v) => updateParam('n', v),
      ),
      WaveParameterSlider(
        label: 'L',
        value: lnm,
        min: 0.0,
        max: 1000.0,
        onChanged: (v) => updateParam('Lnm', v),
      ),
    ];
  }

  @override
  Widget? buildExtraControls(context, activeIds, updateActiveIds) {
    return Wrap(
      spacing: 8,
      children: [
        buildChip(
          '入射波',
          'incident',
          Colors.purpleAccent,
          activeIds,
          updateActiveIds,
          fontSize: 12,
        ),
        buildChip(
          '反射1',
          'reflected1',
          Colors.greenAccent,
          activeIds,
          updateActiveIds,
          fontSize: 12,
        ),
        buildChip(
          '反射2',
          'reflected2',
          Colors.orangeAccent,
          activeIds,
          updateActiveIds,
          fontSize: 12,
        ),
        buildChip(
          '合成反射',
          'combinedReflected',
          Colors.blueAccent,
          activeIds,
          updateActiveIds,
          fontSize: 12,
        ),
      ],
    );
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    const scaleFactor = 250.0;
    final thicknessLInternal = (params['Lnm']! / scaleFactor).clamp(0.0, 5.0);

    return CustomPaint(
      size: Size.infinite,
      painter: ThinFilmStackPainter(
        time: time,
        n: params['n']!,
        thicknessLInternal: thicknessLInternal,
        scale: scale,
        activeComponentIds: activeIds,
        scaleFactor: scaleFactor,
        baseSpeed: 2.0 / kDefaultWavePeriodT,
        rows: const [
          ThinFilmWavelengthRow(lambdaNm: 650, color: Color(0xFFE53935)), // red
          ThinFilmWavelengthRow(lambdaNm: 600, color: Color(0xFFFB8C00)), // orange
          ThinFilmWavelengthRow(lambdaNm: 570, color: Color(0xFFFDD835)), // yellow
          ThinFilmWavelengthRow(lambdaNm: 530, color: Color(0xFF43A047)), // green
          ThinFilmWavelengthRow(lambdaNm: 500, color: Color(0xFF1E88E5)), // cyan/blue
          ThinFilmWavelengthRow(lambdaNm: 450, color: Color(0xFF3949AB)), // indigo
          ThinFilmWavelengthRow(lambdaNm: 400, color: Color(0xFF8E24AA)), // violet
        ],
      ),
    );
  }
}
