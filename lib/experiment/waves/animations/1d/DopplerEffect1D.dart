import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_line_painter.dart';
import '../widgets/wave_slider.dart';

final dopplerEffect1D = createWaveVideo(
  title: "1次元ドップラー効果(音源移動)",
  latex: r"""
  <div class="common-box">ドップラー効果 (1次元)</div>
  <p>音源が移動しながら波を放出すると、音源の進行方向では波長が短くなり（周波数が高くなり）、逆方向では波長が長くなります（周波数が低くなります）。</p>
  <p>音速を $V$、音源の速度を $v$、音源の周波数を $f_0$ とすると、音源の進行方向で観測される周波数 $f$ は：</p>
  <p>$$f = \frac{V}{V - v} f_0$$</p>
  <p>となります。</p>
  """,
  simulation: DopplerEffect1DSimulation(),
);

class DopplerEffect1DSimulation extends WaveSimulation {
  DopplerEffect1DSimulation()
      : super(
          title: "1次元ドップラー効果(音源移動)",
          is3D: false,
          formula: const Column(
            children: [
              FormulaDisplay(
                  r'y = A \sin \left\{ 2\pi \left( f_\pm t \mp \frac{x}{\lambda_\pm} \right) \right\}'),
              SizedBox(height: 8),
              FormulaDisplay(
                  r'f_\pm = \frac{V}{V \mp v} f_0, \quad \lambda_\pm = \frac{V \mp v}{V} \lambda_0'),
              SizedBox(height: 4),
              Text('(複号：進行方向の前方で上、後方で下)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        );

  @override
  Map<String, double> get initialParameters => getInitialParamsWithObs(
        baseParams: {
          'lambda': 2.0,
          'periodT': 1.0,
          'vSource': 0.8,
        },
        obsX: 2.0,
      );

  @override
  List<Widget> buildControls(context, params, updateParam) {
    final V = params['lambda']! / params['periodT']!;
    
    void safeUpdateParam(String key, double value) {
      updateParam(key, value);
      if (key == 'lambda' || key == 'periodT') {
        final newV = params['lambda']! / params['periodT']!;
        if (params['vSource']!.abs() > newV) {
          updateParam('vSource', params['vSource']!.sign * newV);
        }
      }
    }

    return [
      Text(
        '波の速さ V = ${V.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      LambdaSlider(
        label: '波長 λ',
        value: params['lambda']!,
        onChanged: (v) => safeUpdateParam('lambda', v),
      ),
      PeriodTSlider(
        label: '周期 T',
        value: params['periodT']!,
        onChanged: (v) => safeUpdateParam('periodT', v),
      ),
      WaveParameterSlider(
        label: '音源速度 v',
        value: params['vSource']!,
        min: -V,
        max: V,
        onChanged: (v) => updateParam('vSource', v),
      ),
      ...buildObsSliders(params, updateParam, is2D: false, labelX: 'a'),
    ];
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    final field = DopplerEffect1DField(
      lambda: params['lambda']!,
      periodT: params['periodT']!,
      vSource: params['vSource']!,
      amplitude: 0.4,
    );

    final sourceX = params['vSource']! * time;

    return CustomPaint(
      size: Size.infinite,
      painter: WaveLinePainter(
        time: time,
        field: field,
        surfaceColor: Colors.blue,
        showTicks: true,
        scale: scale,
        markers: [
          WaveMarker(point: math.Point(sourceX, 0.0), color: Colors.yellow, label: '音源'),
          getObsMarker(params, label: '観測点 a'),
        ],
      ),
    );
  }
}

