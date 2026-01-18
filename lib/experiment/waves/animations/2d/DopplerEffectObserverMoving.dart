import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';

final dopplerEffectObserverMoving = createWaveVideo(
  title: "2次元ドップラー効果(観測者移動)",
  latex: r"""
  <div class="common-box">ドップラー効果 (観測者が動く場合)</div>
  <p>音源が静止していても、観測者が波に向かって（または波から遠ざかるように）移動すると、観測される周波数が変化します。</p>
  <p>観測者が波に向かって進む場合、単位時間あたりに出会う波の数が増えるため、周波数は高く聞こえます。逆に遠ざかる場合は低く聞こえます。</p>
  <p>このシミュレーションでは、原点に静止した音源から円形波が広がり、観測者（赤丸）が $x = -4$ から正の向きに速度 $u$ で移動する様子を描いています。</p>
  <p>観測される周波数 $f$ は以下のようになります：</p>
  <p>$$f = \frac{V + u \cos\theta}{V} f_0$$</p>
  <p>ここで $V$ は波の速さ、$u$ は観測者の速度、$\theta$ は観測者の移動方向と波の進行方向のなす角です。</p>
  """,
  simulation: DopplerEffectObserverMovingSimulation(),
);

class DopplerEffectObserverMovingSimulation extends WaveSimulation {
  DopplerEffectObserverMovingSimulation()
      : super(
          title: "2次元ドップラー効果(観測者移動)",
          is3D: true,
          formula: const Column(
            children: [
              FormulaDisplay(r'f = \frac{V + u \cos\theta}{V} f_0'),
            ],
          ),
        );

  @override
  Map<String, double> get initialParameters => {
        'lambda': 2.0,
        'periodT': 1.0,
        'vObserver': 0.8,
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
        min: 0.0,
        max: V * 1.5, // 観測者の場合は波の速さを超えても物理的に意味がある
        onChanged: (v) => updateParam('vObserver', v),
      ),
    ];
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    final field = DopplerEffectObserverMovingField(
      lambda: params['lambda']!,
      periodT: params['periodT']!,
      amplitude: 0.4,
    );

    // 観測者の位置 (x = -4.0 + u*t, 0)
    final obsX = -4.0 + params['vObserver']! * time;

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
          const WaveMarker(point: math.Point(0.0, 0.0), color: Colors.yellow),
          // 観測者が移動 (赤色)
          WaveMarker(
              point: math.Point(obsX, 0.0), color: Colors.red, label: '観測者'),
        ],
      ),
    );
  }
}

