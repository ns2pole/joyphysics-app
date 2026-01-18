import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';
import 'dart:math' as math;

final youngDoubleSlit = createWaveVideo(
  title: "ヤングの実験",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>2つのスリットを通過した光が干渉し、スクリーン上に明暗の縞模様（干渉縞）を作ります。</p>
  <p>明線の条件: $d \sin \theta = m\lambda$</p>
  <p>明線間隔: $\Delta x = \frac{L\lambda}{d}$</p>
  """,
  simulation: YoungDoubleSlitSimulation(),
);

class YoungDoubleSlitSimulation extends WaveSimulation {
  YoungDoubleSlitSimulation()
      : super(
          title: "ヤングの実験",
          is3D: true,
          formula: const FormulaDisplay(r'\Delta x = \frac{L\lambda}{d}'),
        );

  @override
  Map<String, double> get initialParameters => getInitialParamsWithObs(
        baseParams: {
          'lambda': 0.8,
          'periodT': 1.0,
          'a': 1.0,
          'phi': 0.0,
          'showIntersectionLine': 1.0, // 1.0 for true, 0.0 for false
          'showIntensityLine': 0.0,
        },
        obsX: 2.0,
        obsY: 0.0,
      );

  @override
  Set<String> get initialActiveIds => {'combined', 'showIntersectionLine'};

  @override
  List<Widget> buildControls(context, params, updateParam) {
    return [
      Text(
        'λ = ${params['lambda']!.toStringAsFixed(2)}  a = ${params['a']!.toStringAsFixed(2)}  φ = ${(params['phi']! / math.pi).toStringAsFixed(2)}π',
        style: const TextStyle(fontSize: 12),
      ),
      LambdaSlider(
        value: params['lambda']!,
        onChanged: (val) => updateParam('lambda', val),
      ),
      PeriodTSlider(
        value: params['periodT']!,
        onChanged: (val) => updateParam('periodT', val),
      ),
      ThicknessLSlider(
        label: 'a (間隔)',
        value: params['a']!,
        onChanged: (val) => updateParam('a', val),
      ),
      PhiSlider(
        value: params['phi']!,
        onChanged: (val) => updateParam('phi', val),
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
        buildChip('波1', 'wave1', Colors.purpleAccent, activeIds, updateActiveIds,
            fontSize: 10),
        buildChip('波2', 'wave2', Colors.greenAccent, activeIds, updateActiveIds,
            fontSize: 10),
        buildChip('合成', 'combined', Colors.yellow, activeIds, updateActiveIds,
            fontSize: 10),
        const SizedBox(width: 8),
        _buildIconButton(Icons.show_chart, 'showIntersectionLine', activeIds,
            updateActiveIds, '交線', Colors.deepPurple),
        _buildIconButton(Icons.bar_chart, 'showIntensityLine', activeIds,
            updateActiveIds, '強度', Colors.green),
      ],
    );
  }

  Widget _buildIconButton(
      IconData icon,
      String id,
      Set<String> activeIds,
      void Function(Set<String>) update,
      String tooltip,
      Color activeColor) {
    final isActive = activeIds.contains(id);
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: () {
        final next = Set<String>.from(activeIds);
        isActive ? next.remove(id) : next.add(id);
        update(next);
      },
      tooltip: tooltip,
      color: isActive ? activeColor : Colors.grey,
    );
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    final field = YoungDoubleSlitField(
      lambda: params['lambda']!,
      periodT: params['periodT']!,
      a: params['a']!,
      phi: params['phi']!,
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
          WaveMarker(point: math.Point(-4.0, params['a']!), color: Colors.yellow),
          WaveMarker(
              point: math.Point(-4.0, -params['a']!), color: Colors.yellow),
          getObsMarker(params, label: '合成波の観測点'),
        ],
        showYoungDoubleSlitExtras: true,
        slitA: params['a']!,
        screenX: 4.0,
        showIntersectionLine: activeIds.contains('showIntersectionLine'),
        showIntensityLine: activeIds.contains('showIntensityLine'),
      ),
    );
  }
}
