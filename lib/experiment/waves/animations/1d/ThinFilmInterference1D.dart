import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:joyphysics/model.dart';
import '../../../PhysicsAnimationScaffold.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_line_painter.dart';
import '../widgets/wave_slider.dart';
import '../painters/wave_surface_painter.dart';

final thinFilmInterference1D = Video(
  category: 'waves',
  iconName: "wave",
  title: "薄膜干渉 (1次元)",
  videoURL: "",
  equipment: ["スマホ"],
  costRating: "★",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>表面での反射と裏面での反射が干渉します。</p>
  <p>屈折率の大きい媒質から小さい媒質への反射は自由端反射（位相変化なし）、小さい媒質から大きい媒質への反射は固定端反射（位相変化$\pi$）となります。</p>
  <p>光路差: $2nL$</p>
  """,
  experimentWidgets: [
    const ThinFilmInterference1D(),
  ],
);

class ThinFilmInterference1D extends StatefulWidget with HasHeight {
  const ThinFilmInterference1D({super.key});

  @override
  double get widgetHeight => 550;

  @override
  State<ThinFilmInterference1D> createState() => _ThinFilmInterference1DState();
}

class _ThinFilmInterference1DState extends State<ThinFilmInterference1D> {
  double _lambda = 4.0;
  double _periodT = 1.0;
  double _n = 1.5;
  double _thicknessL = 1.0;
  Set<String> _activeIds = {'incident', 'combinedReflected'};

  @override
  Widget build(BuildContext context) {
    final opd = 2 * _n * _thicknessL;
    return PhysicsAnimationScaffold(
      title: '薄膜干渉 (1次元)',
      is3D: false,
      formula: Column(
        children: [
          Math.tex(
            r'\color{#B38CFF}{z_i = A \sin\left(2\pi\left(\frac{t}{T} - \frac{x}{\lambda_1}\right)\right)}',
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          Math.tex(
            r'\color{#8CFFB3}{z_{r1} = -A \sin\left(2\pi\left(\frac{t}{T} + \frac{x}{\lambda_1}\right)\right)}',
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          Math.tex(
            r'\color{#FFB38C}{z_{r2} = A \sin\left(2\pi\left(\frac{t}{T} + \frac{x - 2nL}{\lambda_1}\right)\right)}',
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      sliders: [
        Text(
          'λ = ${_lambda.toStringAsFixed(2)}  n = ${_n.toStringAsFixed(2)}  L = ${_thicknessL.toStringAsFixed(2)}  2nL = ${opd.toStringAsFixed(3)}',
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
        spacing: 8,
        children: [
          _buildModeButton('入射波', 'incident'),
          _buildModeButton('反射1', 'reflected1'),
          _buildModeButton('反射2', 'reflected2'),
          _buildModeButton('合成反射', 'combinedReflected'),
        ],
      ),
      animationBuilder: (context, time, azimuth, tilt) {
        final field = ThinFilmInterferenceField(
          lambda: _lambda,
          periodT: _periodT,
          n: _n,
          thicknessL: _thicknessL,
          mode: ThinFilmMode.combinedReflected,
          amplitude: 0.5,
        );
        return CustomPaint(
          size: Size.infinite,
          painter: WaveLinePainter(
            time: time,
            field: field,
            surfaceColor: Colors.blue,
            showTicks: true,
            boundaryX: _thicknessL,
            activeComponentIds: _activeIds,
            mediumSlab: MediumSlabOverlay(
              xStart: 0.0,
              xEnd: _thicknessL,
              color: Colors.yellow,
              opacity: 0.4,
            ),
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

