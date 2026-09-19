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
  Map<String, double> get initialParameters => {
        'lambda': 0.8,
        'periodT': 1.0,
        'a': 1.0,
        'phi': 0.0,
        'showIntersectionLine': 1.0, // 1.0 for true, 0.0 for false
        'showIntensityLine': 0.0,
      };

  @override
  Set<String> get initialActiveIds =>
      {'combined', 'showIntersectionLine', 'showScreen'};

  @override
  List<WavefrontLayer> get wavefrontLayers => const [
        WavefrontLayer(id: 'wave1', label: '波1', color: Colors.purpleAccent),
        WavefrontLayer(id: 'wave2', label: '波2', color: Colors.greenAccent),
      ];

  @override
  List<Widget> buildControls(context, params, updateParam) {
    final double lambda = params['lambda']!;
    final double a = params['a']!;
    final double d = 2 * a;
    final double L = 8.0; // Distance from x=-4 to x=4
    final double deltaX = (L * lambda) / d;

    return [
      Text(
        'λ = ${lambda.toStringAsFixed(2)}  a = ${a.toStringAsFixed(2)}  φ = ${(params['phi']! / math.pi).toStringAsFixed(2)}π',
        style: const TextStyle(fontSize: 12),
      ),
      const SizedBox(height: 4),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Math.tex(
          '\\Delta x = \\frac{L \\lambda}{d} = \\frac{${L.toStringAsFixed(1)} \\times ${lambda.toStringAsFixed(2)}}{${d.toStringAsFixed(2)}} = ${deltaX.toStringAsFixed(2)}',
          textStyle: const TextStyle(fontSize: 14),
        ),
      ),
      const SizedBox(height: 8),
      LambdaSlider(
        value: lambda,
        onChanged: (val) => updateParam('lambda', val),
      ),
      PeriodTSlider(
        value: params['periodT']!,
        onChanged: (val) => updateParam('periodT', val),
      ),
      ThicknessLSlider(
        label: 'a (間隔)',
        value: a,
        min: 0.1,
        max: 1.0,
        onChanged: (val) => updateParam('a', val),
      ),
      PhiSlider(
        value: params['phi']!,
        onChanged: (val) => updateParam('phi', val),
      ),
    ];
  }

  @override
  Widget buildExtraControls(context, activeIds, updateActiveIds) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildChip('波1', 'wave1', Colors.purpleAccent, activeIds,
                updateActiveIds,
                fontSize: 10),
            const SizedBox(width: 4),
            buildChip('波2', 'wave2', Colors.greenAccent, activeIds,
                updateActiveIds,
                fontSize: 10),
            const SizedBox(width: 4),
            buildChip('合成', 'combined', Colors.yellow, activeIds,
                updateActiveIds,
                fontSize: 10),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildToggleButton(Icons.screenshot_monitor, 'showScreen', activeIds,
                updateActiveIds, 'スクリーン', Colors.purple),
            const SizedBox(width: 8),
            _buildToggleButton(Icons.bar_chart, 'showIntensityLine', activeIds,
                updateActiveIds, '強度', Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleButton(
      IconData icon,
      String id,
      Set<String> activeIds,
      void Function(Set<String>) update,
      String label,
      Color activeColor) {
    final isActive = activeIds.contains(id);
    return ElevatedButton.icon(
      onPressed: () {
        final next = Set<String>.from(activeIds);
        isActive ? next.remove(id) : next.add(id);
        update(next);
      },
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? activeColor : Colors.grey[300],
        foregroundColor: isActive ? Colors.white : Colors.black54,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(60, 32),
      ),
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
          WaveMarker(
              point: math.Point(-4.0, params['a']!), color: Colors.yellow),
          WaveMarker(
              point: math.Point(-4.0, -params['a']!), color: Colors.yellow),
        ],
        showYoungDoubleSlitExtras: true,
        slitA: params['a']!,
        screenX: 4.0,
        showIntersectionLine: activeIds.contains('showIntersectionLine'),
        showIntensityLine: activeIds.contains('showIntensityLine'),
        showScreen: activeIds.contains('showScreen'),
      ),
    );
  }
}
