import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:joyphysics/model.dart';
import '../../../PhysicsAnimationScaffold.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';
import 'dart:math' as math;

final thinFilmInterference2D = Video(
  category: 'waves',
  iconName: "wave",
  title: "薄膜干渉 (2次元)",
  videoURL: "",
  equipment: ["スマホ"],
  costRating: "★",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>光路差: $\Delta = 2nd \cos \theta_2$</p>
  <p>反射時に位相がずれる条件（固定端・自由端）に注意して、強め合い・弱め合いの条件が決まります。</p>
  """,
  experimentWidgets: [
    const ThinFilmInterference2D(),
  ],
);

class ThinFilmInterference2D extends StatefulWidget with HasHeight {
  const ThinFilmInterference2D({super.key});

  @override
  double get widgetHeight => 550;

  @override
  State<ThinFilmInterference2D> createState() => _ThinFilmInterference2DState();
}

class _ThinFilmInterference2DState extends State<ThinFilmInterference2D> {
  double _theta = 30 * math.pi / 180;
  double _lambda = 2.0;
  double _periodT = 1.0;
  double _n = 1.5;
  double _thicknessL = 2.0;
  Set<String> _activeIds = {'incident', 'reflected1', 'reflected2', 'combined'};

  @override
  Widget build(BuildContext context) {
    final thetaDeg = (_theta * 180 / math.pi);
    final sinTheta2 = math.sin(_theta) / _n;
    final cosTheta2 = math.sqrt(math.max(0.0, 1.0 - sinTheta2 * sinTheta2));
    final opd = 2 * _n * _thicknessL * cosTheta2;

    return PhysicsAnimationScaffold(
      title: '薄膜干渉 (2次元)',
      is3D: true,
      formula: Column(
        children: [
          Math.tex(
            r'\Delta = 2nd \cos \theta_2',
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      sliders: [
        Text(
          'θ = ${thetaDeg.toStringAsFixed(0)}°  λ = ${_lambda.toStringAsFixed(2)}  n = ${_n.toStringAsFixed(2)}  L = ${_thicknessL.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 11),
        ),
        Text(
          '2nd cos θ₂ = ${opd.toStringAsFixed(3)}',
          style: const TextStyle(fontSize: 11),
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
        RefractiveIndexSlider(
          value: _n,
          onChanged: (v) => setState(() => _n = v),
        ),
        ThicknessLSlider(
          value: _thicknessL,
          onChanged: (v) => setState(() => _thicknessL = v),
        ),
      ],
      extraControls: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          _buildChip('入射', 'incident', Colors.purpleAccent),
          _buildChip('反射1', 'reflected1', Colors.greenAccent),
          _buildChip('反射2', 'reflected2', Colors.orangeAccent),
          _buildChip('合成', 'combined', Colors.blueAccent),
        ],
      ),
      animationBuilder: (context, time, azimuth, tilt) {
        final field = ThinFilmInterference2DField(
          theta: _theta,
          lambda: _lambda,
          periodT: _periodT,
          n: _n,
          thicknessL: _thicknessL,
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
              xEnd: _thicknessL,
              color: Colors.yellow,
              opacity: 0.3,
            ),
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

