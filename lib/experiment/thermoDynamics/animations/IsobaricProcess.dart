import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import './common.dart';

/// 定圧変化（等圧変化）のシミュレーション
final isobaricProcess = createWaveVideo(
  title: "定圧変化",
  latex: r"""
  <div class="common-box">定圧変化（等圧変化）</div>
  <p>気体の圧力を一定に保ったまま状態を変化させることを定圧変化といいます。</p>
  <p>シャルルの法則より、圧力が一定のとき、気体の体積 $V$ は絶対温度 $T$ に比例します。</p>
  <p>$$V \propto T \quad \text{または} \frac{V}{T} = \text{一定}$$</p>
  <p>熱力学第一法則 $Q = \Delta U + W$ において、熱を加えると温度が上がって内部エネルギーが増加するとともに、気体が膨張して外部に仕事 $W = P\Delta V$ を行います。</p>
  """,
  simulation: IsobaricSimulation(),
  height: 974,
);

class IsobaricSimulation extends PhysicsSimulation {
  IsobaricSimulation()
      : super(
          title: "定圧変化",
          formula: const FormulaDisplay(r'P = \text{const.}, \quad \frac{V}{T} = \text{const.}'),
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
    return IsobaricAnimationWidget(time: time, isHeating: isHeating, isCooling: isCooling, scale: scale);
  }
}

class IsobaricAnimationWidget extends StatefulWidget {
  final double time;
  final bool isHeating;
  final bool isCooling;
  final double scale;
  const IsobaricAnimationWidget({super.key, required this.time, required this.isHeating, required this.isCooling, this.scale = 1.0});
  @override
  State<IsobaricAnimationWidget> createState() => _IsobaricAnimationWidgetState();
}

class _IsobaricAnimationWidgetState extends State<IsobaricAnimationWidget> {
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
  void didUpdateWidget(IsobaricAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    double dt = widget.time - lastTime;
    if (dt < 0) dt = 0;
    if (dt > 0.1) dt = 0.02;

    if (widget.isHeating) {
      temperature += 150.0 * dt;
    } else if (widget.isCooling) {
      temperature -= 100.0 * dt;
    } else {
      if (temperature > 300.0) {
        temperature -= 40.0 * dt;
        if (temperature < 300.0) temperature = 300.0;
      } else if (temperature < 300.0) {
        temperature += 40.0 * dt;
        if (temperature > 300.0) temperature = 300.0;
      }
    }
    temperature = temperature.clamp(275.0, 900.0);
    double speedScale = math.sqrt(temperature / 300.0);
    for (var p in particles) p.update(dt, speedScale);
    lastTime = widget.time;
  }

  @override
  Widget build(BuildContext context) {
    double volume = 0.3 * (temperature / 300.0); // 定圧変化 V ∝ T
    return Column(
      children: [
        Expanded(
          flex: 9,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomPaint(
              size: Size.infinite,
              painter: BasePVPainter(
                volume: volume,
                pressure: 0.4, // P固定
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
                volume: volume,
                temperature: temperature,
                isHeating: widget.isHeating,
                isCooling: widget.isCooling,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
