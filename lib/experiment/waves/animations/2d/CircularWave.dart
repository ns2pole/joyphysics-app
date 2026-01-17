import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:joyphysics/model.dart';
import '../../../PhysicsAnimationScaffold.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';

final circularWave = Video(
  category: 'waves',
  iconName: "wave",
  title: "円形波",
  videoURL: "",
  equipment: ["スマホ"],
  costRating: "★",
  latex: r"""
  <div class="common-box">解説</div>
  <p>点源から周囲に円形に広がる波です。</p>
  """,
  experimentWidgets: [
    const CircularWave(),
  ],
);

class CircularWave extends StatefulWidget with HasHeight {
  const CircularWave({super.key});

  @override
  double get widgetHeight => 550;

  @override
  State<CircularWave> createState() => _CircularWaveState();
}

class _CircularWaveState extends State<CircularWave> {
  double _lambda = 2.0;
  double _periodT = 1.0;
  Set<String> _activeIds = {'total'};

  @override
  Widget build(BuildContext context) {
    return PhysicsAnimationScaffold(
      title: '円形波',
      is3D: true,
      formula: Math.tex(
        r'z(x,y,t)=A\sin\left(2\pi\left(\frac{t}{T} - \frac{\sqrt{x^2+y^2}}{\lambda}\right)\right)',
        textStyle: const TextStyle(fontSize: 14),
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
            label: const Text('波面', style: TextStyle(fontSize: 12)),
            selected: _activeIds.contains('total'),
            onSelected: (val) => setState(() {
              _activeIds = Set.from(_activeIds);
              val ? _activeIds.add('total') : _activeIds.remove('total');
            }),
            selectedColor: Colors.blue.withOpacity(0.3),
            checkmarkColor: Colors.blue,
          ),
        ],
      ),
      animationBuilder: (context, time, azimuth, tilt) {
        final field = CircularWaveField(
          lambda: _lambda,
          periodT: _periodT,
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
          ),
        );
      },
    );
  }
}

