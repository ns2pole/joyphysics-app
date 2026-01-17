import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:joyphysics/model.dart';
import '../../../PhysicsAnimationScaffold.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';

final freeEndReflection1D = Video(
  category: 'waves',
  iconName: "wave",
  title: "自由端反射 (1次元)",
  videoURL: "",
  equipment: ["スマホ"],
  costRating: "★",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>自由端では、反射波は入射波と同位相で反射します。</p>
  <p>合成波は端で常に振幅が最大となります（腹）。</p>
  """,
  experimentWidgets: [
    const FreeEndReflection1D(),
  ],
);

class FreeEndReflection1D extends StatefulWidget with HasHeight {
  const FreeEndReflection1D({super.key});

  @override
  double get widgetHeight => 550;

  @override
  State<FreeEndReflection1D> createState() => _FreeEndReflection1DState();
}

class _FreeEndReflection1DState extends State<FreeEndReflection1D> {
  double _lambda = 4.0;
  double _periodT = 1.0;
  Set<String> _activeIds = {'incident', 'reflected', 'combined'};

  final Color _incidentColor = const Color(0xFFB38CFF);
  final Color _reflectedColor = const Color(0xFF8CFFB3);
  final Color _combinedColor = const Color(0xFF8CCBFF);

  @override
  Widget build(BuildContext context) {
    return PhysicsAnimationScaffold(
      title: '自由端反射 (1次元)',
      is3D: true,
      formula: Column(
        children: [
          Math.tex(
            r'\color{#B38CFF}{y_i = A \sin\left(2\pi\left(\frac{t}{T} - \frac{x - x_0}{\lambda}\right)\right)}',
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Math.tex(
            r'\color{#8CFFB3}{y_r = A \sin\left(2\pi\left(\frac{t}{T} - \frac{2L - x - x_0}{\lambda}\right)\right)}',
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
      extraControls: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilterChip(
            label: const Text('入射波', style: TextStyle(fontSize: 12)),
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
            label: const Text('反射波', style: TextStyle(fontSize: 12)),
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
            label: const Text('合成波', style: TextStyle(fontSize: 12)),
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
          painter: WaveSurfacePainter(
            time: time,
            field: field,
            azimuth: azimuth,
            tilt: tilt,
            showTicks: true,
            xAxisLabel: 'x',
            yAxisLabel: '',
            zAxisLabel: 'y',
            activeComponentIds: _activeIds,
          ),
        );
      },
    );
  }
}

