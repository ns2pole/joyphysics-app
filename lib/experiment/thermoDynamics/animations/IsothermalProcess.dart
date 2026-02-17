import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/waves/animations/widgets/wave_slider.dart';
import './common.dart';

/// 等温変化（等温過程）のシミュレーション
final isothermalProcess = createWaveVideo(
  title: "等温変化",
  latex: r"""
  <div class="common-box">等温変化（等温過程）</div>
  <p>気体の温度 $T$ を一定に保ったまま状態を変化させることを等温変化といいます。</p>
  <p>ボイルの法則より、温度が一定のとき、気体の圧力 $P$ は体積 $V$ に反比例します。</p>
  <p>$$PV = \text{一定} \quad \text{または} \quad P \propto \frac{1}{V}$$</p>
  <p>熱力学第一法則 $Q = \Delta U + W$ において、温度が変わらないため内部エネルギーの変化 $\Delta U = 0$ となり、外部から加えた熱 $Q$ はすべて気体が外部へ行う仕事 $W$ に等しくなります（あるいは外部から仕事を受けると、その分だけ熱を放出します）。</p>
  """,
  simulation: IsothermalSimulation(),
  height: 974,
);

class IsothermalSimulation extends PhysicsSimulation {
  IsothermalSimulation()
      : super(
          title: "等温変化",
          formula: const FormulaDisplay(r'T = \text{const.}, \quad PV = \text{const.}'),
          aspectRatio: 0.66,
        );

  @override
  Map<String, double> get initialParameters => {
        'volume': 0.5, // 0.2 to 1.0
      };

  @override
  List<Widget> buildControls(context, params, updateParam) {
    return [
      const Text("操作", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      WaveParameterSlider(
        label: "ピストンの押し引き (体積 V)",
        value: params['volume']!,
        min: 0.2,
        max: 1.0,
        onChanged: (v) => updateParam('volume', v),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Text("スライダーを動かして、ゆっくりピストンを押し引きしてください。"),
      ),
    ];
  }

  @override
  Widget buildAnimation(context, time, azimuth, tilt, scale, params, activeIds) {
    return IsothermalAnimationWidget(
      time: time,
      volume: params['volume']!,
      scale: scale,
    );
  }
}

class IsothermalAnimationWidget extends StatefulWidget {
  final double time;
  final double volume;
  final double scale;

  const IsothermalAnimationWidget({
    super.key,
    required this.time,
    required this.volume,
    this.scale = 1.0,
  });

  @override
  State<IsothermalAnimationWidget> createState() => _IsothermalAnimationWidgetState();
}

class _IsothermalAnimationWidgetState extends State<IsothermalAnimationWidget> {
  late List<ThermodynamicParticle> particles;
  double lastTime = 0.0;
  final int particleCount = 20;
  double lastVolume = 0.5;
  double heatFlux = 0.0; // 正: 吸熱 (膨張), 負: 放熱 (圧縮)

  @override
  void initState() {
    super.initState();
    lastTime = widget.time;
    lastVolume = widget.volume;
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
  void didUpdateWidget(IsothermalAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    double dt = widget.time - lastTime;
    if (dt < 0) dt = 0;
    if (dt > 0.1) dt = 0.02;

    // 体積変化から熱流を計算 (Q = W = PΔV)
    double dV = widget.volume - lastVolume;
    if (dt > 0) {
      double velocity = dV / dt;
      heatFlux = (heatFlux * 0.8) + (velocity * 0.2 * 15.0);
    }
    heatFlux *= 0.95;
    if (heatFlux.abs() < 0.01) heatFlux = 0.0;

    // 等温なので T=300K 固定
    double speedScale = 1.0;
    for (var p in particles) p.update(dt, speedScale);
    lastTime = widget.time;
    lastVolume = widget.volume;
  }

  @override
  Widget build(BuildContext context) {
    const double k = 0.5 * 0.4;
    double currentP = k / widget.volume;

    return Column(
      children: [
        Expanded(
          flex: 9,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomPaint(
              size: Size.infinite,
              painter: IsothermalPVPainter(
                volume: widget.volume,
                pressure: currentP,
                temperature: 300.0,
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
                temperature: 300.0,
                heatFlux: heatFlux,
                cylinderWidthFactor: 0.233,
                cylinderHeightFactor: 0.66,
                personFeetPos: const Offset(0,0), // ダミー。BaseGasPainter内でnullチェック
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class IsothermalPVPainter extends BasePVPainter {
  IsothermalPVPainter({required double volume, required double pressure, required double temperature}) 
      : super(volume: volume, pressure: pressure, temperature: temperature, label: "T = 300 K (const.)");

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);
    double padding = 35.0;
    double w = size.width - padding * 2;
    double h = size.height - padding * 2;

    // 等温曲線の描画
    const double k = 0.5 * 0.4;
    final curvePath = Path();
    bool started = false;
    for (double v = 0.15; v <= 1.0; v += 0.01) {
      double p = k / v;
      double x = padding + v * w;
      double y = size.height - padding - p * h;
      if (y < padding) continue;
      if (!started) { curvePath.moveTo(x, y); started = true; } else { curvePath.lineTo(x, y); }
    }
    canvas.drawPath(curvePath, Paint()..color = Colors.blue.withOpacity(0.3)..strokeWidth = 3.0..style = PaintingStyle.stroke);
  }
}
