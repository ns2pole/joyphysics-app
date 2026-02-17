import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/waves/animations/widgets/wave_slider.dart';
import './common.dart';

/// 断熱変化（断熱過程）のシミュレーション
final adiabaticProcess = createWaveVideo(
  title: "断熱変化",
  latex: r"""
  <div class="common-box">断熱変化（断熱過程）</div>
  <p>外部と熱のやり取りがない状態（断熱状態）で気体の状態を変化させることを断熱変化といいます。</p>
  <p>単原子分子理想気体の場合、ポアソンの法則により以下の関係が成り立ちます。</p>
  <p>$$PV^{5/3} = \text{一定} \quad \text{または} \quad TV^{2/3} = \text{一定}$$</p>
  <p>熱力学第一法則 $Q = \Delta U + W$ において、$Q = 0$ となるため、気体が外部へ仕事 $W$ を行うと内部エネルギーがその分だけ減少し（温度低下）、逆に外部から仕事をされると内部エネルギーが増加します（断熱圧縮による温度上昇）。</p>
  """,
  simulation: AdiabaticSimulation(),
  height: 974,
);

class AdiabaticSimulation extends PhysicsSimulation {
  AdiabaticSimulation()
      : super(
          title: "断熱変化",
          formula: const FormulaDisplay(r'Q = 0, \quad PV^{\gamma} = \text{const.} \ (\gamma=5/3)'),
          aspectRatio: 0.66,
        );

  @override
  Map<String, double> get initialParameters => {
        'volume': 0.5, // 0.25 to 1.0 (初期値 0.5 の 1/2 ~ 2倍)
      };

  @override
  List<Widget> buildControls(context, params, updateParam) {
    return [
      const Text("操作", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      WaveParameterSlider(
        label: "ピストンの押し引き (体積 V)",
        value: params['volume']!,
        min: 0.25,
        max: 1.0,
        onChanged: (v) => updateParam('volume', v),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Text("スライダーを動かして、ピストンを押し引きしてください。"),
      ),
    ];
  }

  @override
  Widget buildAnimation(context, time, azimuth, tilt, scale, params, activeIds) {
    return AdiabaticAnimationWidget(
      time: time,
      volume: params['volume']!,
      scale: scale,
    );
  }
}

class AdiabaticAnimationWidget extends StatefulWidget {
  final double time;
  final double volume;
  final double scale;

  const AdiabaticAnimationWidget({
    super.key,
    required this.time,
    required this.volume,
    this.scale = 1.0,
  });

  @override
  State<AdiabaticAnimationWidget> createState() => _AdiabaticAnimationWidgetState();
}

class _AdiabaticAnimationWidgetState extends State<AdiabaticAnimationWidget> {
  late List<ThermodynamicParticle> particles;
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
  void didUpdateWidget(AdiabaticAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    double dt = widget.time - lastTime;
    if (dt < 0) dt = 0;
    if (dt > 0.1) dt = 0.02;

    // 温度 T の計算 (TV^{2/3} = const)
    double temperature = 300.0 * math.pow(0.5 / widget.volume, 2.0 / 3.0);
    double speedScale = math.sqrt(temperature / 300.0);
    
    for (var p in particles) p.update(dt, speedScale);
    lastTime = widget.time;
  }

  @override
  Widget build(BuildContext context) {
    double temperature = 300.0 * math.pow(0.5 / widget.volume, 2.0 / 3.0);
    final double kAdia = 0.4 * math.pow(0.5, 5.0 / 3.0);
    double pressure = kAdia / math.pow(widget.volume, 5.0 / 3.0);

    return Column(
      children: [
        Expanded(
          flex: 9,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomPaint(
              size: Size.infinite,
              painter: AdiabaticPVPainter(
                volume: widget.volume,
                pressure: pressure,
                temperature: temperature,
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
                volume: widget.volume,
                temperature: temperature,
                wallColor: Colors.black, // 断熱容器
                cylinderWidthFactor: 0.233,
                cylinderHeightFactor: 0.66,
                personFeetPos: const Offset(0,0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AdiabaticPVPainter extends BasePVPainter {
  AdiabaticPVPainter({required double volume, required double pressure, required double temperature})
      : super(volume: volume, pressure: pressure, temperature: temperature, label: "T = ${temperature.toStringAsFixed(0)} K");

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);
    double padding = 35.0;
    double w = size.width - padding * 2;
    double h = size.height - padding * 2;

    const double vRef = 0.5;
    const double pRef = 0.4;
    
    // 等温曲線 (比較用)
    final isoPath = Path();
    bool isoStarted = false;
    for (double v = 0.15; v <= 1.0; v += 0.01) {
      double p = (pRef * vRef) / v;
      double x = padding + v * w;
      double y = size.height - padding - p * h;
      if (y < padding || y > size.height - padding) continue;
      if (!isoStarted) { isoPath.moveTo(x, y); isoStarted = true; } else { isoPath.lineTo(x, y); }
    }
    canvas.drawPath(isoPath, Paint()..color = Colors.blue.withOpacity(0.15)..strokeWidth = 2.0..style = PaintingStyle.stroke);

    // 断熱曲線
    final adiaPath = Path();
    bool adiaStarted = false;
    final double kAdia = pRef * math.pow(vRef, 5.0 / 3.0);
    for (double v = 0.15; v <= 1.0; v += 0.01) {
      double p = kAdia / math.pow(v, 5.0 / 3.0);
      double x = padding + v * w;
      double y = size.height - padding - p * h;
      if (y < padding || y > size.height - padding) continue;
      if (!adiaStarted) { adiaPath.moveTo(x, y); adiaStarted = true; } else { adiaPath.lineTo(x, y); }
    }
    canvas.drawPath(adiaPath, Paint()..color = Colors.red.withOpacity(0.3)..strokeWidth = 3.0..style = PaintingStyle.stroke);
  }
}
