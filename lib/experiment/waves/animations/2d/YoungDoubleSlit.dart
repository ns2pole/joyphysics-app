import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:joyphysics/model.dart';
import '../../../PhysicsAnimationScaffold.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';
import 'dart:math' as math;

final youngDoubleSlit = Video(
  category: 'waves',
  iconName: "wave",
  title: "ヤングの実験",
  videoURL: "",
  equipment: ["スマホ"],
  costRating: "★",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>2つのスリットを通過した光が干渉し、スクリーン上に明暗の縞模様（干渉縞）を作ります。</p>
  <p>明線の条件: $d \sin \theta = m\lambda$</p>
  <p>明線間隔: $\Delta x = \frac{L\lambda}{d}$</p>
  """,
  experimentWidgets: [
    const YoungDoubleSlit(),
  ],
);

class YoungDoubleSlit extends StatefulWidget with HasHeight {
  const YoungDoubleSlit({super.key});

  @override
  double get widgetHeight => 550;

  @override
  State<YoungDoubleSlit> createState() => _YoungDoubleSlitState();
}

class _YoungDoubleSlitState extends State<YoungDoubleSlit> {
  double _lambda = 0.8;
  double _periodT = 1.0;
  double _a = 1.0;
  double _phi = 0.0;
  Set<String> _activeIds = {'combined'};
  bool _showIntersectionLine = true;
  bool _showIntensityLine = false;

  @override
  Widget build(BuildContext context) {
    return PhysicsAnimationScaffold(
      title: 'ヤングの実験',
      is3D: true,
      formula: Math.tex(
        r'\Delta x = \frac{L\lambda}{d}',
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      sliders: [
        Text(
          'λ = ${_lambda.toStringAsFixed(2)}  a = ${_a.toStringAsFixed(2)}  φ = ${(_phi / math.pi).toStringAsFixed(2)}π',
          style: const TextStyle(fontSize: 12),
        ),
        LambdaSlider(
          value: _lambda,
          onChanged: (val) => setState(() => _lambda = val),
        ),
        PeriodTSlider(
          value: _periodT,
          onChanged: (val) => setState(() => _periodT = val),
        ),
        ThicknessLSlider(
          label: 'a (間隔)',
          value: _a,
          onChanged: (val) => setState(() => _a = val),
        ),
        PhiSlider(
          value: _phi,
          onChanged: (val) => setState(() => _phi = val),
        ),
      ],
      extraControls: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          _buildChip('波1', 'wave1', Colors.purpleAccent),
          _buildChip('波2', 'wave2', Colors.greenAccent),
          _buildChip('合成', 'combined', Colors.yellow),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(_showIntersectionLine ? Icons.show_chart : Icons.multiline_chart, size: 20),
            onPressed: () => setState(() => _showIntersectionLine = !_showIntersectionLine),
            tooltip: '交線',
            color: _showIntersectionLine ? Colors.deepPurple : Colors.grey,
          ),
          IconButton(
            icon: Icon(Icons.bar_chart, size: 20),
            onPressed: () => setState(() => _showIntensityLine = !_showIntensityLine),
            tooltip: '強度',
            color: _showIntensityLine ? Colors.green : Colors.grey,
          ),
        ],
      ),
      animationBuilder: (context, time, azimuth, tilt) {
        final field = YoungDoubleSlitField(
          lambda: _lambda,
          periodT: _periodT,
          a: _a,
          phi: _phi,
        );
        return CustomPaint(
          size: Size.infinite,
          painter: WaveSurfacePainter(
            time: time,
            field: field,
            azimuth: azimuth,
            tilt: tilt,
            activeComponentIds: _activeIds,
            markers: [
              math.Point(-8.0, _a),
              math.Point(-8.0, -_a),
            ],
            showYoungDoubleSlitExtras: true,
            slitA: _a,
            screenX: 8.0,
            showIntersectionLine: _showIntersectionLine,
            showIntensityLine: _showIntensityLine,
          ),
        );
      },
    );
  }

  Widget _buildChip(String label, String id, Color color) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 10)),
      selected: _activeIds.contains(id),
      onSelected: (val) => setState(() {
        _activeIds = Set.from(_activeIds);
        val ? _activeIds.add(id) : _activeIds.remove(id);
      }),
      selectedColor: color.withOpacity(0.3),
      checkmarkColor: color,
      padding: EdgeInsets.zero,
    );
  }
}

