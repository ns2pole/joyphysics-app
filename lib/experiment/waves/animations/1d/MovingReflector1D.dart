import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_line_painter.dart';
import '../widgets/wave_slider.dart';
import 'package:joyphysics/l10n/anim_ui.dart';

/// 入射を上・反射を下に少しずらして軸分けする。
const kMovingReflectorIncidentAxisY = 0.9;
const kMovingReflectorReflectedAxisY = -0.9;
const kMovingReflectorAxisOffsets = <String, double>{
  'incident': kMovingReflectorIncidentAxisY,
  'reflected': kMovingReflectorReflectedAxisY,
};
Map<String, String> get kMovingReflectorAxisLabels => <String, String>{
  'incident': animL('入射', 'Incident'),
  'reflected': animL('反射', 'Reflected'),
};

final movingReflector1D = createWaveVideo(
  title: "動く物体による反射",
  titleEn: 'Reflection from a moving object',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>反射体が動いている場合、反射波には<b>2回のドップラー効果</b>がかかります。</p>
  <p>1. 反射体が受ける入射波の周波数が変化する（観測者の移動）</p>
  <p>2. 反射体が波源として波を放出する際の周波数が変化する（音源の移動）</p>
  <p>結果として、反射波の周波数 $f_r$ は元の周波数 $f$ に対して次のように変化します：</p>
  <p>$$f_r = f \frac{c - v}{c + v}$$</p>
  <p>ここで $c$ は波の速さ、$v$ は反射体の速度（波の進行方向を正）です。</p>
  """,
  latexEn: r"""
  <div class="common-box">Key points</div>
  <p>When the reflector is moving, the reflected wave undergoes the <b>Doppler effect twice</b>.</p>
  <p>1. The frequency of the incident wave received by the reflector changes (moving observer).</p>
  <p>2. The frequency of the wave re-emitted by the reflector as a source changes (moving source).</p>
  <p>As a result, the reflected frequency $f_r$ relative to the original frequency $f$ is</p>
  <p>$$f_r = f \frac{c - v}{c + v}$$</p>
  <p>Here $c$ is the wave speed and $v$ is the reflector velocity (positive in the wave's travel direction).</p>
  """,
  simulation: MovingReflector1DSimulation(),
);

class MovingReflector1DSimulation extends WaveSimulation {
  MovingReflector1DSimulation()
      : super(
          title: animL("動く物体による反射", "Reflection from a moving object"),
          is3D: false,
          formula: const Column(
            children: [
              FormulaDisplay(r'\displaystyle y_i = A \sin \left\{ 2\pi \left( \frac{t}{T} - \frac{x - x_s}{\lambda} \right) \right\}'),
              SizedBox(height: 4),
              FormulaDisplay(r'\displaystyle y_r = \pm A \sin \left\{ 2\pi \left( \frac{t}{T_r} + \frac{x}{\lambda_r} \right) + \phi \right\}'),
              SizedBox(height: 8),
              FormulaDisplay(r'\displaystyle f_r = f \frac{c - v}{c + v}, \quad \lambda_r = \lambda \frac{c + v}{c - v}'),
            ],
          ),
        );

  @override
  Map<String, double> get initialParameters => {
        'lambda': 2.0,
        'periodT': 0.7,
        'vReflector': 0.4,
        'x0': 2.0,
        'isFixedEnd': 1.0, // 1 for fixed, 0 for free
      };

  @override
  Set<String> get initialActiveIds => {'incident', 'reflected'};

  @override
  List<Widget> buildControls(context, params, updateParam) {
    final c = params['lambda']! / params['periodT']!;
    return [
      Text(
        animL(
          "波の速さ c = ${c.toStringAsFixed(2)}   速度 v = ${params['vReflector']!.toStringAsFixed(2)}",
          "Wave speed c = ${c.toStringAsFixed(2)}   velocity v = ${params['vReflector']!.toStringAsFixed(2)}",
        ),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      LambdaSlider(
        label: animL('波長 λ', 'Wavelength λ'),
        value: params['lambda']!,
        onChanged: (v) => updateParam('lambda', v),
      ),
      PeriodTSlider(
        label: animL('周期 T', 'Period T'),
        value: params['periodT']!,
        onChanged: (v) => updateParam('periodT', v),
      ),
      WaveParameterSlider(
        label: animL('速度 v', 'Velocity v'),
        value: params['vReflector']!,
        min: -c * 0.8,
        max: c * 0.8,
        onChanged: (v) => updateParam('vReflector', v),
      ),
      WaveParameterSlider(
        label: animL('初期位置 x₀', 'Initial position x₀'),
        value: params['x0']!,
        min: -5.0,
        max: 5.0,
        labelWidth: 92,
        onChanged: (v) => updateParam('x0', v),
      ),
      Row(
        children: [
          Text(animL('端条件: ', 'End condition: '), style: TextStyle(fontSize: 12)),
          ChoiceChip(
            label: Text(animL('固定端', 'Fixed end'), style: TextStyle(fontSize: 12)),
            selected: params['isFixedEnd'] == 1.0,
            onSelected: (val) => updateParam('isFixedEnd', 1.0),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          const SizedBox(width: 4),
          ChoiceChip(
            label: Text(animL('自由端', 'Free end'), style: TextStyle(fontSize: 12)),
            selected: params['isFixedEnd'] == 0.0,
            onSelected: (val) => updateParam('isFixedEnd', 0.0),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ],
      ),
    ];
  }

  @override
  Widget buildExtraControls(context, activeIds, updateActiveIds) {
    return Wrap(
      spacing: 8,
      children: [
        buildChip(animL('入射波', 'Incident wave'), 'incident', Colors.purpleAccent, activeIds,
            updateActiveIds,
            fontSize: 14),
        buildChip(animL('反射波', 'Reflected wave'), 'reflected', Colors.greenAccent, activeIds,
            updateActiveIds,
            fontSize: 14),
      ],
    );
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    final field = MovingReflectorField(
      lambda: params['lambda']!,
      periodT: params['periodT']!,
      v: params['vReflector']!,
      x0: params['x0']!,
      isFixedEnd: params['isFixedEnd'] == 1.0,
      amplitude: 0.6,
    );

    final xm = params['x0']! + params['vReflector']! * time;

    return CustomPaint(
      size: Size.infinite,
      painter: WaveLinePainter(
        time: time,
        field: field,
        surfaceColor: Colors.blue,
        showTicks: true,
        boundaryX: xm,
        showBoundaryLine: true,
        activeComponentIds: activeIds,
        scale: scale,
        componentAxisOffsets: kMovingReflectorAxisOffsets,
        componentAxisLabels: kMovingReflectorAxisLabels,
      ),
    );
  }
}

