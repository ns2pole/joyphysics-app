import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_line_painter.dart';
import '../widgets/wave_slider.dart';

final fixedEndReflection1D = createWaveVideo(
  title: "1次元の定在波(固定端反射)",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>固定端では、反射波は入射波に対して位相が$\pi$（逆位相）ずれます。</p>
  <p>合成波は端で常に変位が0となります（節）。</p>
  """,
  simulation: FixedEndReflection1DSimulation(),
);

class FixedEndReflection1DSimulation extends PhysicsSimulation {
  FixedEndReflection1DSimulation()
      : super(
          title: "1次元の定在波(固定端反射)",
          is3D: false,
          formula: const Column(
            children: [
              FormulaDisplay(r'\color{#B38CFF}{z_i = A \sin\left(2\pi\left(\frac{t}{T} - \frac{x - x_0}{\lambda}\right)\right)}'),
              SizedBox(height: 4),
              FormulaDisplay(r'\color{#8CFFB3}{z_r = -A \sin\left(2\pi\left(\frac{t}{T} - \frac{2L - x - x_0}{\lambda}\right)\right)}'),
            ],
          ),
        );

  @override
  Map<String, double> get initialParameters => {
        'lambda': 2.0,
        'periodT': 1.0,
        'obsX': 2.0,
      };

  @override
  Set<String> get initialActiveIds => {'incident', 'reflected', 'combined'};

  @override
  List<Widget> buildControls(context, params, updateParam) {
    return [
      Text(
        'λ = ${params['lambda']!.toStringAsFixed(2)}   T = ${params['periodT']!.toStringAsFixed(2)}',
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
        _buildModeButton('入射波', 'incident', activeIds, updateActiveIds),
        _buildModeButton('反射波', 'reflected', activeIds, updateActiveIds),
        _buildModeButton('合成波', 'combined', activeIds, updateActiveIds),
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
  Widget buildAnimation(context, time, azimuth, tilt, scale, params, activeIds) {
    final field = OneDimensionReflectionField(
      lambda: params['lambda']!,
      periodT: params['periodT']!,
      mode: ReflectionMode.combined,
      isFixedEnd: true,
      boundaryX: 5.0,
      amplitude: 0.6,
    );
    return CustomPaint(
      size: Size.infinite,
      painter: WaveLinePainter(
        time: time,
        field: field,
        surfaceColor: Colors.blue,
        showTicks: true,
        boundaryX: 5.0,
        showBoundaryLine: true,
        activeComponentIds: activeIds,
        scale: scale,
        markers: [
          WaveMarker(point: math.Point(params['obsX']!, 0.0), color: Colors.red),
        ],
      ),
    );
  }
}
