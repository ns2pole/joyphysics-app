import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_surface_painter.dart';
import '../widgets/wave_slider.dart';
import 'dart:math' as math;
import 'package:joyphysics/l10n/anim_ui.dart';

final youngDoubleSlit = createWaveVideo(
  title: "ヤングの実験",
  titleEn: 'Young\'s double-slit experiment',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>2つのスリットを通過した光が干渉し、スクリーン上に明暗の縞模様（干渉縞）を作ります。</p>
  <p>描いている強め合いは経路差そのものです。位相差 $\phi$ を含めて</p>
  <p>$$\displaystyle \frac{r_1-r_2}{\lambda}+\frac{\phi}{2\pi}=m$$</p>
  <p>$\phi=0$ でスクリーンが十分遠いときは、明線間隔を $\displaystyle \Delta x=\frac{L\lambda}{d}$ と近似できます。この画面は $L$ が $d$ の数倍なので、その間隔は腹線の位置と一致しません。</p>
  """,
  latexEn: r"""
  <div class="common-box">Key points</div>
  <p>Light that passes through two slits interferes and forms a pattern of bright and dark fringes (an interference pattern) on the screen.</p>
  <p>The constructive interference drawn here is based on the path difference itself. Including a phase difference $\phi$,</p>
  <p>$$\displaystyle \frac{r_1-r_2}{\lambda}+\frac{\phi}{2\pi}=m$$</p>
  <p>When $\phi=0$ and the screen is far enough away, the fringe spacing can be approximated as $\displaystyle \Delta x=\frac{L\lambda}{d}$. In this view $L$ is only a few times $d$, so that spacing does not match the positions of the antinodal lines.</p>
  """,
  simulation: YoungDoubleSlitSimulation(),
);

class YoungDoubleSlitSimulation extends WaveSimulation {
  YoungDoubleSlitSimulation()
      : super(
          title: animL("ヤングの実験", "Young's double-slit experiment"),
          is3D: true,
          formula: const FormulaDisplay(
            r'\displaystyle \frac{r_1-r_2}{\lambda}+\frac{\phi}{2\pi}=m',
          ),
        );

  @override
  Map<String, double> get initialParameters => {
        'lambda': 0.8,
        'periodT': 0.7,
        'a': 1.0,
        'phi': 0.0,
        'showIntersectionLine': 1.0, // 1.0 for true, 0.0 for false
        'showIntensityLine': 0.0,
      };

  @override
  Set<String> get initialActiveIds =>
      {
        'combined',
        'showIntersectionLine',
        'showScreen',
        'showNodalLines',
        'showAntinodalLines'
      };

  @override
  List<WavefrontLayer> get wavefrontLayers => [
        WavefrontLayer(id: 'wave1', label: animL('波1', 'Wave 1'), color: Colors.purpleAccent),
        WavefrontLayer(id: 'wave2', label: animL('波2', 'Wave 2'), color: Colors.greenAccent),
      ];

  @override
  List<Widget> buildControls(context, params, updateParam) {
    final double lambda = params['lambda']!;
    final double a = params['a']!;
    final double d = 2 * a;
    final double L = 8.0; // Distance from x=-4 to x=4
    final double deltaX = (L * lambda) / d;

    return [
      Text(
        'λ = ${lambda.toStringAsFixed(2)}  a = ${a.toStringAsFixed(2)}  φ = ${(params['phi']! / math.pi).toStringAsFixed(2)}π',
        style: const TextStyle(fontSize: 12),
      ),
      const SizedBox(height: 4),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Math.tex(
          r'\displaystyle \frac{r_1-r_2}{\lambda}+\frac{\phi}{2\pi}=m',
          textStyle: const TextStyle(fontSize: 14),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        animL('遠いスクリーンの近似 Δx = Lλ/d = ${deltaX.toStringAsFixed(2)}。この画面の腹線とは一致しない。', 'Far-screen approximation Δx = Lλ/d = ${deltaX.toStringAsFixed(2)}. Does not match the antinodal lines on this screen.'),
        style: const TextStyle(fontSize: 11, color: Color(0xFF546E7A)),
      ),
      const SizedBox(height: 8),
      LambdaSlider(
        value: lambda,
        onChanged: (val) => updateParam('lambda', val),
      ),
      PeriodTSlider(
        value: params['periodT']!,
        onChanged: (val) => updateParam('periodT', val),
      ),
      ThicknessLSlider(
        label: animL('a (間隔)', 'a (spacing)'),
        value: a,
        min: 0.1,
        max: 1.0,
        onChanged: (val) => updateParam('a', val),
      ),
      PhiSlider(
        value: params['phi']!,
        onChanged: (val) => updateParam('phi', val),
      ),
    ];
  }

  @override
  Widget buildExtraControls(context, activeIds, updateActiveIds) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 4,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            buildChip(animL('波1', 'Wave 1'), 'wave1', Colors.purpleAccent, activeIds,
                updateActiveIds,
                fontSize: 10),
            buildChip(animL('波2', 'Wave 2'), 'wave2', Colors.greenAccent, activeIds,
                updateActiveIds,
                fontSize: 10),
            buildChip(animL('合成', 'Combined'), 'combined', Colors.yellow, activeIds,
                updateActiveIds,
                fontSize: 10),
            buildChip(animL('節線', 'Nodal lines'), 'showNodalLines', Colors.orangeAccent, activeIds,
                updateActiveIds,
                fontSize: 10),
            buildChip(animL('腹線', 'Antinodal lines'), 'showAntinodalLines', Colors.orangeAccent, activeIds,
                updateActiveIds,
                fontSize: 10),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildToggleButton(Icons.screenshot_monitor, 'showScreen', activeIds,
                updateActiveIds, animL('スクリーン', 'Screen'), Colors.purple),
            const SizedBox(width: 8),
            _buildToggleButton(Icons.bar_chart, 'showIntensityLine', activeIds,
                updateActiveIds, animL('強度', 'Intensity'), Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleButton(
      IconData icon,
      String id,
      Set<String> activeIds,
      void Function(Set<String>) update,
      String label,
      Color activeColor) {
    final isActive = activeIds.contains(id);
    return ElevatedButton.icon(
      onPressed: () {
        final next = Set<String>.from(activeIds);
        isActive ? next.remove(id) : next.add(id);
        update(next);
      },
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? activeColor : Colors.grey[300],
        foregroundColor: isActive ? Colors.white : Colors.black54,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(60, 32),
      ),
    );
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    final field = YoungDoubleSlitField(
      lambda: params['lambda']!,
      periodT: params['periodT']!,
      a: params['a']!,
      phi: params['phi']!,
    );
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
          WaveMarker(
              point: math.Point(-4.0, params['a']!), color: Colors.yellow),
          WaveMarker(
              point: math.Point(-4.0, -params['a']!), color: Colors.yellow),
        ],
        showYoungDoubleSlitExtras: true,
        slitA: params['a']!,
        screenX: 4.0,
        showIntersectionLine: activeIds.contains('showIntersectionLine'),
        showIntensityLine: activeIds.contains('showIntensityLine'),
        showScreen: activeIds.contains('showScreen'),
        showNodalLines: activeIds.contains('showNodalLines'),
        nodalMetric: field.nodalMetric,
        showAntinodalLines: activeIds.contains('showAntinodalLines'),
        antinodalMetric: field.antinodalMetric,
      ),
    );
  }
}
