import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:joyphysics/model.dart';
import '../../../PhysicsAnimationScaffold.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';
import 'dart:math' as math;

final circularInterference = Video(
  category: 'waves',
  iconName: "wave",
  title: "円形波干渉",
  videoURL: "",
  equipment: ["スマホ"],
  costRating: "★",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>2つの波源からの距離の差が、波長の整数倍なら強め合い、半波長の奇数倍なら弱め合います。</p>
  <p>強め合いの条件: $|r_1 - r_2| = m\lambda$</p>
  <p>弱め合いの条件: $|r_1 - r_2| = (m + 1/2)\lambda$</p>
  """,
  experimentWidgets: [
    const CircularInterference(),
  ],
);

class CircularInterference extends StatefulWidget with HasHeight {
  const CircularInterference({super.key});

  @override
  double get widgetHeight => 550;

  @override
  State<CircularInterference> createState() => _CircularInterferenceState();
}

class _CircularInterferenceState extends State<CircularInterference> {
  double _lambda = 2.0;
  double _periodT = 1.0;
  double _a = 2.0;
  double _phi = 0.0;
  Set<String> _activeIds = {'combined'};

  @override
  Widget build(BuildContext context) {
    return PhysicsAnimationScaffold(
      title: '円形波干渉',
      is3D: true,
      formula: Math.tex(
        r'|r_1 - r_2| = m\lambda',
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      sliders: [
        Text(
          'λ = ${_lambda.toStringAsFixed(2)}  a = ${_a.toStringAsFixed(2)}  φ = ${(_phi / math.pi).toStringAsFixed(2)}π',
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
        ThicknessLSlider(
          label: 'a',
          value: _a,
          onChanged: (v) => setState(() => _a = v),
        ),
        PhiSlider(
          value: _phi,
          onChanged: (v) => setState(() => _phi = v),
        ),
      ],
      extraControls: Wrap(
        spacing: 8,
        children: [
          _buildChip('波1', 'wave1', Colors.purpleAccent),
          _buildChip('波2', 'wave2', Colors.greenAccent),
          _buildChip('合成', 'combined', Colors.blueAccent),
        ],
      ),
      animationBuilder: (context, time, azimuth, tilt) {
        final field = CircularInterferenceField(
          lambda: _lambda,
          periodT: _periodT,
          a: _a,
          phi: _phi,
          amplitude: 0.3,
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
              math.Point(0.0, _a),
              math.Point(0.0, -_a),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip(String label, String id, Color color) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: _activeIds.contains(id),
      onSelected: (val) => setState(() {
        _activeIds = Set.from(_activeIds);
        val ? _activeIds.add(id) : _activeIds.remove(id);
      }),
      selectedColor: color.withOpacity(0.3),
      checkmarkColor: color,
    );
  }
}

