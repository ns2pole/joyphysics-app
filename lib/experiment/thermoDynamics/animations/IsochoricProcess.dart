import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import './common.dart';

/// 定積変化（等積変化）のシミュレーション
final isochoricProcess = createWaveVideo(
  title: "定積変化",
  latex: r"""
  <div class="common-box">定積変化（等積変化）</div>
  <p>気体の体積 $V$ を一定に保ったまま状態を変化させることを定積変化といいます。</p>
  <p>ボイル・シャルルの法則 $\frac{PV}{T} = \text{一定}$ より、$V$ が一定のとき、圧力 $P$ は絶対温度 $T$ に比例します。</p>
  <p>$$P \propto T \quad \text{または} \quad \frac{P}{T} = \text{一定}$$</p>
  <p>熱力学第一法則 $Q = \Delta U + W$ において、体積が変化しないため仕事 $W = P\Delta V = 0$ となり、加えた熱 $Q$ はすべて内部エネルギーの増加（温度上昇）に使われます。</p>
  """,
  simulation: IsochoricSimulation(),
  height: 974,
);

class IsochoricSimulation extends PhysicsSimulation {
  IsochoricSimulation()
      : super(
          title: "定積変化",
          formula: const FormulaDisplay(r'V = \text{const.}, \quad \frac{P}{T} = \text{const.}'),
          aspectRatio: 0.66,
        );

  @override
  Map<String, double> get initialParameters => {
        'baseTemp': 300.0,
      };

  @override
  List<Widget> buildControls(context, params, updateParam) {
    return [
      const Text("設定", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text("下の「加熱」で温度が上がり、「冷却」で温度が下がります。"),
      ),
    ];
  }

  @override
  Widget? buildExtraControls(context, parameters, activeIds, updateActiveIds) {
    return Wrap(
      spacing: 8,
      children: [
        buildChip("加熱", "heating", Colors.orange, activeIds, (ids) {
          if (ids.contains('heating')) ids.remove('cooling');
          updateActiveIds(ids);
        }),
        buildChip("冷却", "cooling", Colors.blue, activeIds, (ids) {
          if (ids.contains('cooling')) ids.remove('heating');
          updateActiveIds(ids);
        }),
      ],
    );
  }

  @override
  Widget buildAnimation(context, time, azimuth, tilt, scale, params, activeIds) {
    final bool isHeating = activeIds.contains('heating');
    final bool isCooling = activeIds.contains('cooling');
    return IsochoricAnimationWidget(time: time, isHeating: isHeating, isCooling: isCooling, scale: scale);
  }
}

class IsochoricAnimationWidget extends StatefulWidget {
  final double time;
  final bool isHeating;
  final bool isCooling;
  final double scale;
  const IsochoricAnimationWidget({super.key, required this.time, required this.isHeating, required this.isCooling, this.scale = 1.0});
  @override
  State<IsochoricAnimationWidget> createState() => _IsochoricAnimationWidgetState();
}

class _IsochoricAnimationWidgetState extends State<IsochoricAnimationWidget> {
  late List<ThermodynamicParticle> particles;
  double temperature = 300.0;
  double lastTime = 0.0;
  final int particleCount = 20;

  @override
  void initState() {
    super.initState();
    lastTime = widget.time;
    _initParticles();
  }

  void _initParticles() {
    final random = math.Random();
    particles = List.generate(particleCount, (index) => ThermodynamicParticle(
      position: Offset(random.nextDouble(), random.nextDouble()),
      velocity: Offset((random.nextDouble() - 0.5) * 0.06, (random.nextDouble() - 0.5) * 0.06),
    ));
  }

  @override
  void didUpdateWidget(IsochoricAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    double dt = widget.time - lastTime;
    if (dt < 0) dt = 0;
    if (dt > 0.1) dt = 0.02;

    if (widget.isHeating) {
      temperature += 200.0 * dt;
    } else if (widget.isCooling) {
      temperature -= 150.0 * dt;
    } else {
      if (temperature > 300.0) {
        temperature -= 50.0 * dt;
        if (temperature < 300.0) temperature = 300.0;
      } else if (temperature < 300.0) {
        temperature += 50.0 * dt;
        if (temperature > 300.0) temperature = 300.0;
      }
    }
    temperature = temperature.clamp(275.0, 1000.0);
    double speedScale = math.sqrt(temperature / 300.0);
    for (var p in particles) p.update(dt, speedScale);
    lastTime = widget.time;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 9,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomPaint(
              size: Size.infinite,
              painter: BasePVPainter(
                volume: 0.4, // 定積変化 V=0.4相当
                pressure: 0.9 * temperature / 1000.0,
                temperature: temperature,
                label: "T = ${temperature.toStringAsFixed(0)} K",
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: Colors.black26),
        Expanded(
          flex: 11,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomPaint(
              size: Size.infinite,
              painter: BaseGasPainter(
                particles: particles,
                volume: 0.4, // V固定
                temperature: temperature,
                isHeating: widget.isHeating,
                isCooling: widget.isCooling,
                showBottomStoppers: false,
                showTopStoppers: true, // ピストンを止めるためのストッパー
              ),
            ),
          ),
        ),
      ],
    );
  }
}
