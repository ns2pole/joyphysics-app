import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_line_painter.dart';
import '../widgets/wave_slider.dart';
import 'package:joyphysics/l10n/anim_ui.dart';

final twoSource1D = createWaveVideo(
  title: "1次元干渉",
  titleEn: '1D interference',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>一直線上の二つの音源から、同じ振幅・同じ周期の波が出ます。媒質の変位は重ね合わせで</p>
  <p>$$y=y_1+y_2$$</p>
  <p>音源1・2までの距離を $r_1$、$r_2$、音源2の初期位相を $\phi$ とすると、位相差は</p>
  <p>$$\Delta\varphi=2\pi\frac{r_1-r_2}{\lambda}+\phi$$</p>
  <p>強め合いは $\displaystyle \frac{\Delta\varphi}{2\pi}=m$、弱め合いは $\displaystyle \frac{\Delta\varphi}{2\pi}=m+\frac{1}{2}$（$m$ は整数）です。波は速さ $\displaystyle v=\frac{\lambda}{T}$ で届くまで変位は 0 です。</p>
  """,
  latexEn: r"""
  <div class="common-box">Key points</div>
  <p>Two sources on a line emit waves of the same amplitude and period. The medium displacement is the superposition</p>
  <p>$$y=y_1+y_2$$</p>
  <p>With distances $r_1$ and $r_2$ to sources 1 and 2, and initial phase $\phi$ of source 2, the phase difference is</p>
  <p>$$\Delta\varphi=2\pi\frac{r_1-r_2}{\lambda}+\phi$$</p>
  <p>Constructive interference when $\displaystyle \frac{\Delta\varphi}{2\pi}=m$, destructive when $\displaystyle \frac{\Delta\varphi}{2\pi}=m+\frac{1}{2}$ ($m$ an integer). Until the wave arrives at speed $\displaystyle v=\frac{\lambda}{T}$, the displacement is 0.</p>
  """,
  simulation: TwoSource1DSimulation(),
);

class TwoSource1DSimulation extends WaveSimulation {
  TwoSource1DSimulation()
      : super(
          title: animL("1次元干渉", "1D interference"),
          is3D: false,
          formula: Column(
            children: [
              FormulaDisplay(
                  r'\displaystyle y=y_1+y_2,\quad \frac{\Delta\varphi}{2\pi}=\frac{r_1-r_2}{\lambda}+\frac{\phi}{2\pi}'),
            ],
          ),
        );

  @override
  Map<String, double> get initialParameters => getInitialParamsWithObs(
        baseParams: {
          'lambda': 1.0,
          'periodT': 0.7,
          'distanceD': 2.0,
          'phaseShift': 0.0,
        },
        obsX: 0.0,
      );

  @override
  Set<String> get initialActiveIds => {'wave1', 'wave2', 'combined'};

  @override
  List<Widget> buildControls(context, params, updateParam) {
    return [
      LambdaSlider(
        label: animL('波長', 'Wavelength'),
        value: params['lambda']!,
        onChanged: (v) => updateParam('lambda', v),
      ),
      PeriodTSlider(
        label: animL('周期', 'Period'),
        value: params['periodT']!,
        onChanged: (v) => updateParam('periodT', v),
      ),
      ThicknessLSlider(
        label: animL('音源間距離D', 'Source separation D'),
        value: params['distanceD']!,
        min: 0.1,
        max: 8.0,
        onChanged: (v) => updateParam('distanceD', v),
      ),
      WaveParameterSlider(
        label: animL('位相ずれ', 'Phase shift'),
        value: params['phaseShift']!,
        min: 0.0,
        max: 2 * math.pi,
        onChanged: (v) => updateParam('phaseShift', v),
      ),
      ...buildObsSliders(params, updateParam, is2D: false),
    ];
  }

  @override
  Widget buildExtraControls(context, activeIds, updateActiveIds) {
    return Wrap(
      spacing: 8,
      children: [
        buildChip(animL('音源1', 'Source 1'), 'wave1', Colors.purpleAccent, activeIds, updateActiveIds,
            fontSize: 14),
        buildChip(animL('音源2', 'Source 2'), 'wave2', Colors.greenAccent, activeIds, updateActiveIds,
            fontSize: 14),
        buildChip(animL('合成波', 'Resultant wave'), 'combined', Colors.blueAccent, activeIds, updateActiveIds,
            fontSize: 14),
      ],
    );
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    final field = TwoSource1DField(
      lambda: params['lambda']!,
      periodT: params['periodT']!,
      distanceD: params['distanceD']!,
      phaseShift: params['phaseShift']!,
      amplitude: 0.4,
    );
    return CustomPaint(
      size: Size.infinite,
      painter: WaveLinePainter(
        time: time,
        field: field,
        surfaceColor: Colors.blue,
        showTicks: true,
        activeComponentIds: activeIds,
        scale: scale,
        markers: [
          WaveMarker(
            point: math.Point(-params['distanceD']! / 2, 0),
            color: Colors.purple,
            label: 'S1',
          ),
          WaveMarker(
            point: math.Point(params['distanceD']! / 2, 0),
            color: Colors.green,
            label: 'S2',
          ),
          getObsMarker(params, label: animL('観測点', 'Observation point')),
        ],
      ),
    );
  }
}
