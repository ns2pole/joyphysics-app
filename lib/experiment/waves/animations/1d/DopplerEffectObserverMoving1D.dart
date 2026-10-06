import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_line_painter.dart';
import '../widgets/wave_slider.dart';
import 'package:joyphysics/l10n/anim_ui.dart';

final dopplerEffectObserverMoving1D = createWaveVideo(
  title: "1次元ドップラー効果(観測者移動)",
  titleEn: '1D Doppler effect (moving observer)',
  latex: r"""
  <div class="common-box">ドップラー効果 (1次元)</div>
  <p>音源が静止していても、観測者が波に向かって（または波から遠ざかるように）移動すると、観測される周波数が変化します。</p>
  <p>音速を $V$、観測者の速度を $u$（波源に向かう向きを正）、音源の周波数を $f_0$ とすると、観測される周波数 $f$ は：</p>
  <p>$$f = \frac{V + u}{V} f_0$$</p>
  <p>となります。</p>
  """,
  latexEn: r"""
  <div class="common-box">Doppler effect (1D)</div>
  <p>Even if the source is at rest, the observed frequency changes when the observer moves toward (or away from) the waves.</p>
  <p>With sound speed $V$, observer speed $u$ (positive toward the source), and source frequency $f_0$, the observed frequency $f$ is</p>
  <p>$$f = \frac{V + u}{V} f_0$$</p>
  <p>.</p>
  """,
  simulation: DopplerEffectObserverMoving1DSimulation(),
);

class DopplerEffectObserverMoving1DSimulation extends WaveSimulation {
  DopplerEffectObserverMoving1DSimulation()
      : super(
          title: animL("1次元ドップラー効果(観測者移動)", "1D Doppler effect (moving observer)"),
          is3D: false,
          formula: Column(
            children: [
              FormulaDisplay(
                  r'y = A \sin \left\{ 2\pi \left( f_0 t \mp \frac{x}{\lambda} \right) \right\}'),
              SizedBox(height: 8),
              FormulaDisplay(r'\displaystyle f = \frac{V - u_{\parallel}}{V} f_0'),
              SizedBox(height: 4),
              Text(animL('u∥ は波の進む向きの速度。波に向かうと周波数は上がる。', 'u∥ is the velocity along the wave direction. Approaching the wave raises the frequency.'),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        );

  @override
  Map<String, double> get initialParameters => getInitialParamsWithObs(
        baseParams: {
          'lambda': 2.0,
          'periodT': 0.7,
          'vObserver': 0.8,
        },
        obsX: -4.0,
      );

  @override
  List<Widget> buildControls(context, params, updateParam) {
    final V = params['lambda']! / params['periodT']!;
    return [
      Text(
        animL('波の速さ V = ${V.toStringAsFixed(2)}', 'Wave speed V = ${V.toStringAsFixed(2)}'),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      LambdaSlider(
        label: animL('波長 λ', 'Wavelength λ'),
        value: params['lambda']!,
        onChanged: (v) => updateParam('lambda', v),
      ),
      PeriodTSlider(
        label: animL('周期 T', 'Period T'),
        value: params['periodT']!,
        onChanged: (v) => updateParam('periodT', v),
      ),
      WaveParameterSlider(
        label: animL('観測者速度 u', 'Observer velocity u'),
        value: params['vObserver']!,
        min: -V * 2,
        max: V * 2,
        onChanged: (v) => updateParam('vObserver', v),
      ),
      ...buildObsSliders(params, updateParam, is2D: false, labelX: animL('初期位置 x0', 'Initial position x0')),
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
    final obsX = params['obsX']! + params['vObserver']! * time;

    final u = params['vObserver']!;
    final waveSpeed = params['lambda']! / params['periodT']!;
    // 原点の音源から外へ進む波。obsX の符号が進む向き。
    final waveDir = obsX >= 0 ? 1.0 : -1.0;
    final ratio = observerDopplerRatio(
      waveSpeed: waveSpeed,
      uParallel: u * waveDir,
    );

    return CustomPaint(
      size: Size.infinite,
      painter: WaveLinePainter(
        time: time,
        field: field,
        surfaceColor: Colors.blue,
        showTicks: true,
        scale: scale,
        markers: [
          WaveMarker(
              point: math.Point(0.0, 0.0), color: Colors.yellow, label: animL('音源', 'Source')),
          WaveMarker(
              point: math.Point(obsX, 0.0),
              color: Colors.red,
              label: animL('観測者  f/f0=${ratio.toStringAsFixed(2)}', 'Observer  f/f0=${ratio.toStringAsFixed(2)}')),
        ],
      ),
    );
  }

  @override
  List<WaveMarker> getMarkers(Map<String, double> parameters, double time) {
    final v = parameters['vObserver']!;
    final obsX = parameters['obsX']! + v * time;
    return [
      WaveMarker(
          point: math.Point(0.0, 0.0), color: Colors.yellow, label: animL('音源', 'Source')),
      WaveMarker(point: math.Point(obsX, 0.0), color: Colors.red, label: animL('観測者', 'Observer')),
    ];
  }

  @override
  void onMarkerDragged(
    Map<String, double> parameters,
    void Function(String key, double value) updateParam,
    int markerIndex,
    math.Point<double> newPoint,
    double time,
  ) {
    if (markerIndex == 1) {
      final v = parameters['vObserver']!;
      updateParam('obsX', (newPoint.x - v * time).clamp(-5.0, 5.0));
    }
  }
}

