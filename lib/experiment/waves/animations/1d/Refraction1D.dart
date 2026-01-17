import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:joyphysics/model.dart';
import '../../../PhysicsAnimationScaffold.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_line_painter.dart';
import '../widgets/wave_slider.dart';
import '../painters/wave_surface_painter.dart';

final refraction1D = Video(
  category: 'waves',
  iconName: "wave",
  title: "屈折 (1次元)",
  videoURL: "",
  equipment: ["スマホ"],
  costRating: "★",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>異なる媒質の境界で波の速さが変わると、波長も変化します。周波数は変化しません。</p>
  <p>$n = \frac{v_1}{v_2} = \frac{\lambda_1}{\lambda_2}$</p>
  """,
  experimentWidgets: [
    const Refraction1D(),
  ],
);

class Refraction1D extends StatefulWidget with HasHeight {
  const Refraction1D({super.key});

  @override
  double get widgetHeight => 550;

  @override
  State<Refraction1D> createState() => _Refraction1DState();
}

class _Refraction1DState extends State<Refraction1D> {
  double _lambda = 4.0;
  double _periodT = 1.0;
  double _n = 1.5;
  Set<String> _activeIds = {'total'};

  @override
  Widget build(BuildContext context) {
    return PhysicsAnimationScaffold(
      title: '屈折 (1次元)',
      is3D: false,
      formula: Column(
        children: [
          Math.tex(
            r'\color{#B38CFF}{z_1 = A \sin\left(2\pi\left(\frac{t}{T} - \frac{x}{\lambda_1}\right)\right)}',
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Math.tex(
            r'\color{#FFB800}{z_2 = A \sin\left(2\pi\left(\frac{t}{T} - \frac{x}{\lambda_2}\right)\right), \quad \lambda_2 = \lambda_1/n}',
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      sliders: [
        Text(
          'λ = ${_lambda.toStringAsFixed(2)}   T = ${_periodT.toStringAsFixed(2)}   n = ${_n.toStringAsFixed(2)}',
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
      ],
      extraControls: Wrap(
        spacing: 8,
        children: [
          _buildModeButton('合成波', 'total'),
        ],
      ),
      animationBuilder: (context, time, azimuth, tilt) {
        final field = OneDimensionSlabRefractionField(
          lambda: _lambda,
          periodT: _periodT,
          n: _n,
          slabStart: 0.0,
          slabEnd: 5.0,
          amplitude: 0.6,
        );
        return CustomPaint(
          size: Size.infinite,
          painter: WaveLinePainter(
            time: time,
            field: field,
            surfaceColor: Colors.blue,
            showTicks: true,
            activeComponentIds: _activeIds,
            mediumSlab: const MediumSlabOverlay(
              xStart: 0.0,
              xEnd: 5.0,
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

