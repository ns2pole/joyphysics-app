import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:joyphysics/model.dart';
import '../../../PhysicsAnimationScaffold.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';
import 'dart:math' as math;

final refractionLaw = Video(
  category: 'waves',
  iconName: "wave",
  title: "屈折の法則 (2次元)",
  videoURL: "",
  equipment: ["スマホ"],
  costRating: "★",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>スネルの法則: $n_1 \sin \theta_1 = n_2 \sin \theta_2$</p>
  <p>屈折率の大きい媒質に入ると、波長が短くなり、進む方向が法線に近づきます。</p>
  """,
  experimentWidgets: [
    const RefractionLaw(),
  ],
);

class RefractionLaw extends StatefulWidget with HasHeight {
  const RefractionLaw({super.key});

  @override
  double get widgetHeight => 550;

  @override
  State<RefractionLaw> createState() => _RefractionLawState();
}

class _RefractionLawState extends State<RefractionLaw> {
  double _theta = 25 * math.pi / 180;
  double _lambda = 2.0;
  double _periodT = 1.0;
  double _n2 = 1.5;
  double _slabWidth = 1.0;
  Set<String> _activeIds = {'total'};

  @override
  Widget build(BuildContext context) {
    final thetaDeg = (_theta * 180 / math.pi);
    return PhysicsAnimationScaffold(
      title: '屈折の法則 (2次元)',
      is3D: true,
      formula: Column(
        children: [
          Math.tex(
            r'n_1\sin\theta_1=n_2\sin\theta_2',
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      sliders: [
        Text(
          'θ = ${thetaDeg.toStringAsFixed(0)}°  λ = ${_lambda.toStringAsFixed(2)}  n = ${_n2.toStringAsFixed(2)}  L = ${_slabWidth.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 12),
        ),
        ThetaSlider(
          value: _theta,
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
        RefractiveIndexSlider(
          value: _n2,
          onChanged: (v) => setState(() => _n2 = v),
        ),
        ThicknessLSlider(
          value: _slabWidth,
          onChanged: (v) => setState(() => _slabWidth = v),
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
        final field = SlabRefractionWaveField(
          theta: _theta,
          lambda: _lambda,
          periodT: _periodT,
          n: _n2,
          slabWidth: _slabWidth,
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
            mediumSlab: MediumSlabOverlay(
              xStart: 0.0,
              xEnd: _slabWidth,
              color: Colors.yellow,
              opacity: 0.45,
            ),
          ),
        );
      },
    );
  }
}

