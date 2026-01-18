import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_line_painter.dart';
import '../widgets/wave_slider.dart';

final dopplerEffectObserverMoving1D = createWaveVideo(
  title: "1次元ドップラー効果(観測者移動)",
  latex: r"""
  <div class="common-box">ドップラー効果 (1次元)</div>
  <p>音源が静止していても、観測者が波に向かって（または波から遠ざかるように）移動すると、観測される周波数が変化します。</p>
  <p>音速を $V$、観測者の速度を $u$（波源に向かう向きを正）、音源の周波数を $f_0$ とすると、観測される周波数 $f$ は：</p>
  <p>$$f = \frac{V + u}{V} f_0$$</p>
  <p>となります。</p>
  """,
  simulation: DopplerEffectObserverMoving1DSimulation(),
);

class DopplerEffectObserverMoving1DSimulation extends WaveSimulation {
  DopplerEffectObserverMoving1DSimulation()
      : super(
          title: "1次元ドップラー効果(観測者移動)",
          is3D: false,
          formula: const Column(
            children: [
              FormulaDisplay(
                  r'y = A \sin \left\{ 2\pi \left( f_0 t \mp \frac{x}{\lambda} \right) \right\}'),
              SizedBox(height: 8),
              FormulaDisplay(r'f = \frac{V \pm u}{V} f_0'),
              SizedBox(height: 4),
              Text('(複号：音源に近づく時 +, - 、遠ざかる時 -, +)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        );

  @override
  Map<String, double> get initialParameters => {
        'lambda': 2.0,
        'periodT': 1.0,
        'vObserver': 0.8,
        'obsX0': -4.0,
      };

  @override
  List<Widget> buildControls(context, params, updateParam) {
    final V = params['lambda']! / params['periodT']!;
    return [
      Text(
        '波の速さ V = ${V.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      LambdaSlider(
        label: '波長 λ',
        value: params['lambda']!,
        onChanged: (v) => updateParam('lambda', v),
      ),
      PeriodTSlider(
        label: '周期 T',
        value: params['periodT']!,
        onChanged: (v) => updateParam('periodT', v),
      ),
      WaveParameterSlider(
        label: '観測者速度 u',
        value: params['vObserver']!,
        min: -V * 2,
        max: V * 2,
        onChanged: (v) => updateParam('vObserver', v),
      ),
    ];
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    final field = StaticSource1DField(
      lambda: params['lambda']!,
      periodT: params['periodT']!,
      amplitude: 0.4,
    );

    // 観測者の位置 (x = x0 + u*t)
    final obsX = params['obsX0']! + params['vObserver']! * time;

    return CustomPaint(
      size: Size.infinite,
      painter: WaveLinePainter(
        time: time,
        field: field,
        surfaceColor: Colors.blue,
        showTicks: true,
        scale: scale,
        markers: [
          const WaveMarker(point: math.Point(0.0, 0.0), color: Colors.yellow, label: '音源'),
          WaveMarker(point: math.Point(obsX, 0.0), color: Colors.red, label: '観測者'),
        ],
      ),
    );
  }
}

