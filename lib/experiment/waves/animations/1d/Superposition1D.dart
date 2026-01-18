import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_line_painter.dart';
import '../widgets/wave_slider.dart';

final superposition1D = createWaveVideo(
  title: "重ね合わせの原理",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>2つの波が重なり合うとき、その場所での変位は、それぞれの波が単独でそこに到達したときの変位の和になります。</p>
  <p>これを<b>重ね合わせの原理</b>と呼びます。重なり合った後、それぞれの波は互いに影響を受けることなく通り過ぎていきます（独立性）。</p>
  """,
  simulation: Superposition1DSimulation(),
);

class Superposition1DSimulation extends PhysicsSimulation {
  Superposition1DSimulation()
      : super(
          title: "重ね合わせの原理",
          is3D: false,
          formula: const Column(
            children: [
              FormulaDisplay(r'y = y_1 + y_2'),
            ],
          ),
        );

  @override
  Map<String, double> get initialParameters => {
        'lambda': 2.0,
        'periodT': 1.0,
        'pulseWidth': 2.0,
        'isTriangle': 0.0, // 0 for sine, 1 for triangle
        'obsX': 0.0,
      };

  @override
  Set<String> get initialActiveIds => {'wave1', 'wave2', 'combined'};

  @override
  List<Widget> buildControls(context, params, updateParam) {
    return [
      Text(
        '速度 v = ${(params['lambda']! / params['periodT']!).toStringAsFixed(2)}   幅 W = ${params['pulseWidth']!.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 12),
      ),
      LambdaSlider(
        label: '速度',
        value: params['lambda']!,
        onChanged: (v) => updateParam('lambda', v),
      ),
      ThicknessLSlider(
        label: 'パルス幅',
        value: params['pulseWidth']!,
        min: 0.5,
        max: 4.0,
        onChanged: (v) => updateParam('pulseWidth', v),
      ),
      Row(
        children: [
          const Text('波形: ', style: TextStyle(fontSize: 12)),
          ChoiceChip(
            label: const Text('sin', style: TextStyle(fontSize: 12)),
            selected: params['isTriangle'] == 0.0,
            onSelected: (val) => updateParam('isTriangle', 0.0),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          const SizedBox(width: 4),
          ChoiceChip(
            label: const Text('三角波', style: TextStyle(fontSize: 12)),
            selected: params['isTriangle'] == 1.0,
            onSelected: (val) => updateParam('isTriangle', 1.0),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ],
      ),
      const Divider(),
      const Text('観測点 a', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      WaveParameterSlider(
        label: 'a',
        value: params['obsX']!,
        min: -5.0,
        max: 5.0,
        onChanged: (v) => updateParam('obsX', v),
      ),
    ];
  }

  @override
  Widget buildExtraControls(context, activeIds, updateActiveIds) {
    return Wrap(
      spacing: 8,
      children: [
        _buildChip('波1', 'wave1', Colors.purpleAccent, activeIds, updateActiveIds),
        _buildChip('波2', 'wave2', Colors.greenAccent, activeIds, updateActiveIds),
        _buildChip('合成', 'combined', Colors.blueAccent, activeIds, updateActiveIds),
      ],
    );
  }

  Widget _buildChip(String label, String id, Color color, Set<String> activeIds, void Function(Set<String>) update) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 14)),
      selected: activeIds.contains(id),
      onSelected: (val) {
        final next = Set<String>.from(activeIds);
        val ? next.add(id) : next.remove(id);
        update(next);
      },
      selectedColor: color.withOpacity(0.3),
      checkmarkColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  @override
  Widget buildAnimation(context, time, azimuth, tilt, scale, params, activeIds) {
    final field = PulseSuperpositionField(
      lambda: params['lambda']!,
      periodT: params['periodT']!,
      pulseWidth: params['pulseWidth']!,
      shape: params['isTriangle'] == 1.0 ? PulseShape.triangle : PulseShape.sine,
      amplitude: 0.6,
    );
    return CustomPaint(
      size: Size.infinite,
      painter: WaveLinePainter(
        time: time,
        field: field,
        surfaceColor: Colors.blue,
        showTicks: true,
        activeComponentIds: activeIds,
        scale: scale,
        markers: [
          WaveMarker(point: math.Point(params['obsX']!, 0.0), color: Colors.red),
        ],
      ),
    );
  }
}

