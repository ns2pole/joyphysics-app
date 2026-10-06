import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';
import 'package:joyphysics/l10n/anim_ui.dart';

final dopplerEffectObserverMoving = createWaveVideo(
  title: "2次元ドップラー効果(観測者移動)",
  titleEn: '2D Doppler effect (moving observer)',
  latex: r"""
  <div class="common-box">ドップラー効果 (観測者が動く場合)</div>
  <p>音源が静止していても、観測者が波に向かって（または波から遠ざかるように）移動すると、観測される周波数が変化します。</p>
  <p>観測者が波に向かって進む場合、単位時間あたりに出会う波の数が増えるため、周波数は高く聞こえます。逆に遠ざかる場合は低く聞こえます。</p>
  <p>このシミュレーションでは、原点に静止した音源から円形波が広がり、観測者（赤丸）が $x = -4$ から正の向きに速度 $u$ で移動する様子を描いています。</p>
  <p>観測される周波数 $f$ は以下のようになります：</p>
  <p>$$\displaystyle f = \frac{V - u \cos\theta}{V} f_0$$</p>
  <p>ここで $V$ は波の速さ、$u$ は観測者の速さ、$\theta$ は観測者の移動方向と波の進行方向のなす角です。波と同じ向き（$\theta=0$）では低く、波に向かう向き（$\theta=\pi$）では高くなります。</p>
  """,
  latexEn: r"""
  <div class="common-box">Doppler effect (moving observer)</div>
  <p>Even if the source is at rest, the observed frequency changes when the observer moves toward (or away from) the waves.</p>
  <p>When the observer moves toward the waves, more wave crests are encountered per unit time, so the frequency sounds higher. When moving away, it sounds lower.</p>
  <p>In this simulation, circular waves spread from a stationary source at the origin, and the observer (red circle) moves from $x = -4$ in the positive direction at speed $u$.</p>
  <p>The observed frequency $f$ is</p>
  <p>$$\displaystyle f = \frac{V - u \cos\theta}{V} f_0$$</p>
  <p>Here $V$ is the wave speed, $u$ is the observer's speed, and $\theta$ is the angle between the observer's velocity and the wave's propagation direction. In the same direction as the wave ($\theta=0$) the frequency is lower; toward the wave ($\theta=\pi$) it is higher.</p>
  """,
  simulation: DopplerEffectObserverMovingSimulation(),
);

class DopplerEffectObserverMovingSimulation extends WaveSimulation {
  DopplerEffectObserverMovingSimulation()
      : super(
          title: animL("2次元ドップラー効果(観測者移動)", "2D Doppler effect (moving observer)"),
          is3D: true,
          formula: Column(
            children: [
              FormulaDisplay(r'\displaystyle f = \frac{V - u \cos\theta}{V} f_0'),
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
        obsY: 0.0,
      );

  @override
  Set<String> get initialActiveIds => {'total', 'showCrossSection'};

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
        min: 0.0,
        max: V * 1.5, // 観測者の場合は波の速さを超えても物理的に意味がある
        onChanged: (v) => updateParam('vObserver', v),
      ),
      ...buildObsSliders(params, updateParam, labelX: animL('初期位置 x0', 'Initial position x0')),
    ];
  }

  @override
  Widget buildExtraControls(context, activeIds, updateActiveIds) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildChip(
          animL('断面', 'Cross section'),
          'showCrossSection',
          Colors.deepPurple,
          activeIds,
          updateActiveIds,
        ),
      ],
    );
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    final field = DopplerEffectObserverMovingField(
      lambda: params['lambda']!,
      periodT: params['periodT']!,
      amplitude: 0.4,
    );

    // 観測者の位置 (x = obsX0 + u*t, 0)
    final obs = math.Point(
      params['obsX']! + params['vObserver']! * time,
      params['obsY'] ?? 0.0,
    );
    const source = math.Point(0.0, 0.0);

    final ux = params['vObserver']!;
    final waveSpeed = params['lambda']! / params['periodT']!;
    final r = math.sqrt(obs.x * obs.x + obs.y * obs.y);
    final along = r < 1e-6 ? 0.0 : ux * obs.x / r;
    final ratio = observerDopplerRatio(waveSpeed: waveSpeed, uParallel: along);

    return CustomPaint(
      size: Size.infinite,
      painter: WaveSurfacePainter(
        time: time,
        field: field,
        azimuth: azimuth,
        tilt: tilt,
        activeComponentIds: activeIds,
        scale: scale,
        markers: [
          // 音源は原点に固定 (黄色)
          WaveMarker(point: source, color: Colors.yellow),
          // 観測者が移動 (赤色)
          WaveMarker(
            point: obs,
            color: Colors.red,
            label: animL('観測者  f/f0=${ratio.toStringAsFixed(2)}', 'Observer  f/f0=${ratio.toStringAsFixed(2)}'),
            showZDisplacement: true,
          ),
        ],
        radialCrossSections: [
          if (activeIds.contains('showCrossSection'))
            RadialCrossSectionSpec(
              start: source,
              end: obs,
              color: Colors.deepPurple,
              zAt: (x, y) => field.z(x, y, time),
            ),
        ],
      ),
    );
  }

  @override
  List<WaveMarker> getMarkers(Map<String, double> parameters, double time) {
    final v = parameters['vObserver']!;
    final obsX = parameters['obsX']! + v * time;
    final obsY = parameters['obsY'] ?? 0.0;
    return [
      WaveMarker(point: math.Point(0.0, 0.0), color: Colors.yellow),
      WaveMarker(
        point: math.Point(obsX, obsY),
        color: Colors.red,
        label: animL('観測者', 'Observer'),
        showZDisplacement: true,
      ),
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
      updateParam('obsY', newPoint.y.clamp(-5.0, 5.0));
    }
  }
}

