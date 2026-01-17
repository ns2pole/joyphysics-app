import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:joyphysics/model.dart';
import '../../../PhysicsAnimationScaffold.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';
import 'dart:math' as math;

final reflectionLaw2D = Video(
  category: 'waves',
  iconName: "wave",
  title: "反射の法則 (自由端・2次元)",
  videoURL: "",
  equipment: ["スマホ"],
  costRating: "★",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>反射の法則: 入射角 = 反射角</p>
  <p>自由端反射では、位相の変化はありません。</p>
  """,
  experimentWidgets: [
    const ReflectionLaw2D(),
  ],
);

class ReflectionLaw2D extends StatefulWidget with HasHeight {
  const ReflectionLaw2D({super.key});

  @override
  double get widgetHeight => 550;

  @override
  State<ReflectionLaw2D> createState() => _ReflectionLaw2DState();
}

class _ReflectionLaw2DState extends State<ReflectionLaw2D> {
  double _theta = 30 * math.pi / 180;
  double _lambda = 2.5;
  double _periodT = 1.0;
  Set<String> _activeIds = {'incident', 'reflected', 'combined'};

  final Color _incidentColor = const Color(0xFFB38CFF);
  final Color _reflectedColor = const Color(0xFF8CFFB3);
  final Color _combinedColor = const Color(0xFF8CCBFF);

  @override
  Widget build(BuildContext context) {
    final thetaDeg = (_theta * 180 / math.pi);
    return PhysicsAnimationScaffold(
      title: '反射の法則 (自由端)',
      is3D: true,
      formula: Column(
        children: [
          Math.tex(
            r'\theta_{incident} = \theta_{reflected}',
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      sliders: [
        Text(
          'θ = ${thetaDeg.toStringAsFixed(0)}°   λ = ${_lambda.toStringAsFixed(2)}   T = ${_periodT.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 12),
        ),
        ThetaSlider(
          value: _theta,
          maxDeg: 80,
          onChanged: (v) => setState(() => _theta = v),
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
      extraControls: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilterChip(
            label: const Text('入射', style: TextStyle(fontSize: 11)),
            selected: _activeIds.contains('incident'),
            onSelected: (val) => setState(() {
              _activeIds = Set.from(_activeIds);
              val ? _activeIds.add('incident') : _activeIds.remove('incident');
            }),
            selectedColor: _incidentColor.withOpacity(0.3),
            checkmarkColor: _incidentColor,
          ),
          const SizedBox(width: 4),
          FilterChip(
            label: const Text('反射', style: TextStyle(fontSize: 11)),
            selected: _activeIds.contains('reflected'),
            onSelected: (val) => setState(() {
              _activeIds = Set.from(_activeIds);
              val ? _activeIds.add('reflected') : _activeIds.remove('reflected');
            }),
            selectedColor: _reflectedColor.withOpacity(0.3),
            checkmarkColor: _reflectedColor,
          ),
          const SizedBox(width: 4),
          FilterChip(
            label: const Text('合成', style: TextStyle(fontSize: 11)),
            selected: _activeIds.contains('combined'),
            onSelected: (val) => setState(() {
              _activeIds = Set.from(_activeIds);
              val ? _activeIds.add('combined') : _activeIds.remove('combined');
            }),
            selectedColor: _combinedColor.withOpacity(0.3),
            checkmarkColor: _combinedColor,
          ),
        ],
      ),
      animationBuilder: (context, time, azimuth, tilt) {
        final field = ReflectionWaveField(
          theta: _theta,
          lambda: _lambda,
          periodT: _periodT,
          mode: ReflectionMode.combined,
          isFixedEnd: false,
          amplitude: 0.4,
        );
        return CustomPaint(
          size: Size.infinite,
          painter: WaveSurfacePainter(
            time: time,
            field: field,
            azimuth: azimuth,
            tilt: tilt,
            activeComponentIds: _activeIds,
            mediumSlab: const MediumSlabOverlay(
              xStart: 0.0,
              xEnd: 10.0,
              color: Colors.yellow,
              opacity: 0.4,
            ),
          ),
        );
      },
    );
  }
}

