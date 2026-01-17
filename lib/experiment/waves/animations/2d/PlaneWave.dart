import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:joyphysics/model.dart';
import '../../../PhysicsAnimationScaffold.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';
import 'dart:math' as math;

final planeWave = Video(
  category: 'waves',
  iconName: "wave",
  title: "平面波",
  videoURL: "",
  equipment: ["スマホ"],
  costRating: "★",
  latex: r"""
  <div class="common-box">解説</div>
  <p>進行方向に垂直な平面上で位相が等しい波です。</p>
  """,
  experimentWidgets: [
    const PlaneWave(),
  ],
);

class PlaneWave extends StatefulWidget with HasHeight {
  const PlaneWave({super.key});

  @override
  double get widgetHeight => 550;

  @override
  State<PlaneWave> createState() => _PlaneWaveState();
}

class _PlaneWaveState extends State<PlaneWave> {
  double _theta = 0.0;
  double _lambda = 2.0;
  double _periodT = 1.0;
  Set<String> _activeIds = {'total'};

  @override
  Widget build(BuildContext context) {
    final thetaDeg = (_theta * 180 / math.pi) % 360;
    return PhysicsAnimationScaffold(
      title: '平面波',
      is3D: true,
      formula: Math.tex(
        r'z(x,y,t)=A\sin\left(2\pi\left(\frac{t}{T} - \frac{x\cos\theta+y\sin\theta}{\lambda}\right)\right)',
        textStyle: const TextStyle(fontSize: 14),
      ),
      sliders: [
        Text(
          'θ = ${thetaDeg.toStringAsFixed(0)}°   λ = ${_lambda.toStringAsFixed(2)}   T = ${_periodT.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 12),
        ),
        ThetaSlider(
          value: _theta,
          maxDeg: 360,
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
        final field = PlaneWaveField(
          theta: _theta,
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

