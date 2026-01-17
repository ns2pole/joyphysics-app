import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:joyphysics/model.dart';
import '../../../PhysicsAnimationScaffold.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';
import 'dart:math' as math;

final fixedReflection2D = Video(
  category: 'waves',
  iconName: "wave",
  title: "反射の法則 (固定端・2次元)",
  videoURL: "",
  equipment: ["スマホ"],
  costRating: "★",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>固定端反射では、反射時に位相が$\pi$（逆位相）ずれます。</p>
  <p>境界（x=0）では入射波と反射波が打ち消し合い、常に変位が0となります。</p>
  """,
  experimentWidgets: [
    const FixedReflection2D(),
  ],
);

class FixedReflection2D extends StatefulWidget with HasHeight {
  const FixedReflection2D({super.key});

  @override
  double get widgetHeight => 550;

  @override
  State<FixedReflection2D> createState() => _FixedReflection2DState();
}

class _FixedReflection2DState extends State<FixedReflection2D> {
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
      title: '反射の法則 (固定端)',
      is3D: true,
      formula: Column(
        children: [
          Math.tex(
            r'z_{reflected} = -z_{incident}(at\ x=0)',
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
          isFixedEnd: true,
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

