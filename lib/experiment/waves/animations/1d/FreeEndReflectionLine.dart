import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:joyphysics/model.dart';
import '../../../PhysicsAnimationScaffold.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_line_painter.dart';
import '../widgets/wave_slider.dart';

final freeEndReflectionLine = Video(
  category: 'waves',
  iconName: "wave",
  title: "自由端反射 (線モデル)",
  videoURL: "",
  equipment: ["スマホ"],
  costRating: "★",
  latex: r"""
  <div class="common-box">解説</div>
  <p>1次元の媒質上の波の反射を線で表したモデルです。</p>
  """,
  experimentWidgets: [
    const FreeEndReflectionLine(),
  ],
);

class FreeEndReflectionLine extends StatefulWidget with HasHeight {
  const FreeEndReflectionLine({super.key});

  @override
  double get widgetHeight => 550;

  @override
  State<FreeEndReflectionLine> createState() => _FreeEndReflectionLineState();
}

class _FreeEndReflectionLineState extends State<FreeEndReflectionLine> {
  double _lambda = 4.0;
  double _periodT = 1.0;
  Set<String> _activeIds = {'incident', 'reflected', 'combined'};

  @override
  Widget build(BuildContext context) {
    return PhysicsAnimationScaffold(
      title: '自由端反射 (線モデル)',
      is3D: false,
      formula: Column(
        children: [
          Math.tex(
            r'\color{#B38CFF}{z_i = A \sin\left(2\pi\left(\frac{t}{T} - \frac{x - x_0}{\lambda}\right)\right)}',
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Math.tex(
            r'\color{#8CFFB3}{z_r = A \sin\left(2\pi\left(\frac{t}{T} - \frac{2L - x - x_0}{\lambda}\right)\right)}',
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      sliders: [
        Text(
          'λ = ${_lambda.toStringAsFixed(2)}   T = ${_periodT.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 12),
        ),
        LambdaSlider(
          value: _lambda,
          onChanged: (v) => setState(() => _lambda = v),
        ),
        PeriodTSlider(
          value: _periodT,
          onChanged: (v) => setState(() => _periodT = v),
        ),
      ],
      extraControls: Wrap(
        spacing: 8,
        children: [
          _buildModeButton('入射波', 'incident'),
          _buildModeButton('反射波', 'reflected'),
          _buildModeButton('合成波', 'combined'),
        ],
      ),
      animationBuilder: (context, time, azimuth, tilt) {
        final field = OneDimensionReflectionField(
          lambda: _lambda,
          periodT: _periodT,
          mode: ReflectionMode.combined,
          isFixedEnd: false,
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
            activeComponentIds: _activeIds,
          ),
        );
      },
    );
  }

  Widget _buildModeButton(String label, String id) {
    final isSelected = _activeIds.contains(id);
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _activeIds.add(id);
          } else {
            _activeIds.remove(id);
          }
          _activeIds = Set.from(_activeIds);
        });
      },
    );
  }
}

