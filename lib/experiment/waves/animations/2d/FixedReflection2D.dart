import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';
import 'dart:math' as math;

final fixedReflection2D = createWaveVideo(
  title: "反射の法則 (固定端・2次元)",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>固定端反射では、反射時に位相が$\pi$（逆位相）ずれます。</p>
  <p>境界（x=0）では入射波と反射波が打ち消し合い、常に変位が0となります。</p>
  """,
  simulation: FixedReflection2DSimulation(),
);

class FixedReflection2DSimulation extends PhysicsSimulation {
  FixedReflection2DSimulation()
      : super(
          title: "反射の法則 (固定端)",
          is3D: true,
          formula: Column(
            children: [
              Math.tex(
                r'z_{reflected} = -z_{incident}(at\ x=0)',
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );

  @override
  Map<String, double> get initialParameters => {
        'theta': 30 * math.pi / 180,
        'lambda': 2.5,
        'periodT': 1.0,
      };

  @override
  Set<String> get initialActiveIds => {'incident', 'reflected', 'combined'};

  @override
  List<Widget> buildControls(context, params, updateParam) {
    final thetaDeg = (params['theta']! * 180 / math.pi);
    return [
      Text(
        'θ = ${thetaDeg.toStringAsFixed(0)}°   λ = ${params['lambda']!.toStringAsFixed(2)}   T = ${params['periodT']!.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 12),
      ),
      ThetaSlider(
        value: params['theta']!,
        maxDeg: 80,
        onChanged: (v) => updateParam('theta', v),
      ),
      LambdaSlider(
        value: params['lambda']!,
        onChanged: (v) => updateParam('lambda', v),
      ),
      PeriodTSlider(
        value: params['periodT']!,
        onChanged: (v) => updateParam('periodT', v),
      ),
    ];
  }

  @override
  Widget buildExtraControls(context, activeIds, updateActiveIds) {
    const incidentColor = Color(0xFFB38CFF);
    const reflectedColor = Color(0xFF8CFFB3);
    const combinedColor = Color(0xFF8CCBFF);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildChip('入射', 'incident', incidentColor, activeIds, updateActiveIds),
        const SizedBox(width: 4),
        _buildChip('反射', 'reflected', reflectedColor, activeIds, updateActiveIds),
        const SizedBox(width: 4),
        _buildChip('合成', 'combined', combinedColor, activeIds, updateActiveIds),
      ],
    );
  }

  Widget _buildChip(String label, String id, Color color, Set<String> activeIds, void Function(Set<String>) update) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: activeIds.contains(id),
      onSelected: (val) {
        final next = Set<String>.from(activeIds);
        val ? next.add(id) : next.remove(id);
        update(next);
      },
      selectedColor: color.withOpacity(0.3),
      checkmarkColor: color,
      padding: EdgeInsets.zero,
    );
  }

  @override
  Widget buildAnimation(context, time, azimuth, tilt, params, activeIds) {
    final field = ReflectionWaveField(
      theta: params['theta']!,
      lambda: params['lambda']!,
      periodT: params['periodT']!,
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
        activeComponentIds: activeIds,
        mediumSlab: const MediumSlabOverlay(
          xStart: 0.0,
          xEnd: 10.0,
          color: Colors.yellow,
          opacity: 0.4,
        ),
      ),
    );
  }
}
