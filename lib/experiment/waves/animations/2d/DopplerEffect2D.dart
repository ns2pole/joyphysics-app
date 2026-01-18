import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';

final dopplerEffect2D = createWaveVideo(
  title: "2次元ドップラー効果",
  latex: r"""
  <div class="common-box">ドップラー効果 (2次元)</div>
  <p>音源が移動しながら波を放出すると、音源の進行方向では波長が短くなり（周波数が高くなり）、逆方向では波長が長くなります（周波数が低くなります）。</p>
  <p>時刻 $t$、位置 $(x, y)$ で観測される波は、それより前の時刻 $\tau$（放射時刻：retarded time）に音源から放出されたものです。</p>
  <p>この $\tau$ は以下の関係式を満たします：</p>
  <p>$$t - \tau = \frac{\sqrt{(x - v\tau)^2 + y^2}}{V}$$</p>
  <p>ここで $V = \lambda / T$ は波の速さ、$v$ は音源の速度です。このシミュレーションでは、音源が原点を出発して $x$ 軸上を正の向きに移動する様子を描いています。</p>
  """,
  simulation: DopplerEffect2DSimulation(),
);

class DopplerEffect2DSimulation extends PhysicsSimulation {
  DopplerEffect2DSimulation()
      : super(
          title: "2次元ドップラー効果",
          is3D: true,
          formula: const Column(
            children: [
              FormulaDisplay(r'z(x, y, t) = A \sin(\omega_0 \tau(x, y, t))'),
              SizedBox(height: 4),
              FormulaDisplay(r't - \tau = \frac{\sqrt{(x - v\tau)^2 + y^2}}{V}'),
            ],
          ),
        );

  @override
  Map<String, double> get initialParameters => {
        'lambda': 2.0,
        'periodT': 1.0,
        'vSource': 0.8,
        'obsX': 2.0,
        'obsY': 0.0,
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
        label: '音源速度 v',
        value: params['vSource']!,
        min: 0.0,
        max: V * 0.95, // マッハ数 < 1 に制限
        onChanged: (v) => updateParam('vSource', v),
      ),
      const Divider(),
      const Text('観測点 (a, b)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      WaveParameterSlider(
        label: 'a',
        value: params['obsX']!,
        min: -5.0,
        max: 5.0,
        onChanged: (v) => updateParam('obsX', v),
      ),
      WaveParameterSlider(
        label: 'b',
        value: params['obsY']!,
        min: -5.0,
        max: 5.0,
        onChanged: (v) => updateParam('obsY', v),
      ),
    ];
  }

  @override
  Widget buildAnimation(context, time, azimuth, tilt, scale, params, activeIds) {
    final field = DopplerEffect2DField(
      lambda: params['lambda']!,
      periodT: params['periodT']!,
      vSource: params['vSource']!,
      amplitude: 0.4,
    );

    final sourceX = params['vSource']! * time;

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
          WaveMarker(point: math.Point(sourceX, 0.0), color: Colors.yellow),
          WaveMarker(point: math.Point(params['obsX']!, params['obsY']!), color: Colors.red),
        ],
      ),
    );
  }
}

