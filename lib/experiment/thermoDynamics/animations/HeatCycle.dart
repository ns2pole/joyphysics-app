import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import './common.dart';

final heatCycleProcess = createWaveVideo(
  title: "熱サイクル",
  latex: r"""
  <div class="common-box">熱サイクル</div>
  <p>加熱・冷却と、重りの載せ降ろしを組み合わせた熱サイクルのシミュレーションです。</p>
  <p>1. 錘を載せた状態で加熱すると、圧力が上昇し、ある時点でピストンが上昇を始めます（等圧変化）。</p>
  <p>2. 上端のストッパーに到達したら錘を取り除きます。</p>
  <p>3. 冷却するとピストンが下降し、元の体積に戻ります。</p>
  <p>4. 再び錘を載せることでサイクルが完結します。</p>
  """,
  simulation: HeatCycleSimulation(),
  height: 974,
);

class HeatCycleSimulation extends PhysicsSimulation {
  HeatCycleSimulation()
      : super(
          title: "熱サイクル",
          formula: const FormulaDisplay(r'Q = \Delta U + W'),
          aspectRatio: 0.66,
        );

  @override
  Map<String, double> get initialParameters => {
        'weights': 1.0, // 初期状態で錘1つ
      };

  @override
  List<Widget> buildControls(context, params, updateParam) {
    final int currentWeights = (params['weights'] ?? 0).round().clamp(0, 3);
    return [
      const Text("操作説明", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Text("1. 加熱ボタンで温度を上げます。\n2. 上端到達後に「錘を取る」を押します。\n3. 加熱を切り、温度を下げます。\n4. 下端で「錘を載せる」を押します。"),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Text('錘: $currentWeights / 3', style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          ElevatedButton(
            onPressed: currentWeights < 3 ? () => updateParam('weights', (currentWeights + 1).toDouble()) : null,
            child: const Text('錘を載せる'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: currentWeights > 0 ? () => updateParam('weights', (currentWeights - 1).toDouble()) : null,
            child: const Text('錘を取る'),
          ),
        ],
      ),
    ];
  }

  @override
  Widget? buildExtraControls(context, parameters, activeIds, updateActiveIds) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        buildChip("加熱", "heating", Colors.orange, activeIds, (ids) => updateActiveIds(ids)),
      ],
    );
  }

  @override
  Widget buildAnimation(context, time, azimuth, tilt, scale, params, activeIds) {
    return HeatCycleAnimationWidget(
      time: time,
      isHeating: activeIds.contains('heating'),
      weights: params['weights']?.toInt() ?? 0,
      scale: scale,
    );
  }
}

class HeatCycleAnimationWidget extends StatefulWidget {
  final double time;
  final bool isHeating;
  final int weights;
  final double scale;

  const HeatCycleAnimationWidget({
    super.key,
    required this.time,
    required this.isHeating,
    required this.weights,
    this.scale = 1.0,
  });

  @override
  State<HeatCycleAnimationWidget> createState() => _HeatCycleAnimationWidgetState();
}

class _HeatCycleAnimationWidgetState extends State<HeatCycleAnimationWidget> {
  late List<ThermodynamicParticle> particles;
  double temperature = 300.0;
  double volume = 0.3; // 初期体積 (下端ストッパー位置)
  double pressure = 1.0;
  double heatFlux = 0.0;
  double lastTime = 0.0;
  List<Offset> pvHistory = [];
  Offset? _lastHistoryPoint;

  final double ambientTemp = 300.0;
  final double vMin = 0.3; // 下端ストッパー
  final double vMax = 0.8; // 上端ストッパー
  final double pAtm = 1.0; // 大気圧相当
  final double pWeightUnit = 0.5; // 錘1つあたりの圧力増加

  @override
  void initState() {
    super.initState();
    lastTime = widget.time;
    _initParticles();
    // 初期圧力計算
    pressure = temperature / (volume * 1000.0); // 簡易化された状態方程式
  }

  void _initParticles() {
    final random = math.Random();
    particles = List.generate(20, (index) => ThermodynamicParticle(
      position: Offset(random.nextDouble(), random.nextDouble()),
      velocity: Offset((random.nextDouble() - 0.5) * 0.06, (random.nextDouble() - 0.5) * 0.06),
    ));
  }

  @override
  void didUpdateWidget(HeatCycleAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    double dt = widget.time - lastTime;
    if (dt < 0) dt = 0;
    if (dt > 0.1) dt = 0.02;

    // 1. 温度の更新
    if (widget.isHeating) {
      temperature += 150.0 * dt;
    }
    // 自然冷却/熱交換
    double coolingRate = 40.0 * (temperature - ambientTemp) / 300.0;
    temperature -= coolingRate * dt;
    temperature = temperature.clamp(275.0, 1500.0);

    // 熱流の計算 (表示用)
    heatFlux = (widget.isHeating ? 0.3 : 0.0) - (coolingRate * 0.002);

    // 2. 圧力の計算 (P = T / V)
    // 正規化された単位を使用。V=0.3, T=300 で P=1.0 になるように。
    double pGas = (temperature / 300.0) * (0.3 / volume);
    pressure = pGas;

    // 3. 負荷圧力の計算
    double pLoad = pAtm + (widget.weights * pWeightUnit);

    // 4. ピストンの移動
    double dV = 0.0;
    if (pGas > pLoad + 0.01) {
      dV = 0.2 * dt; // 上昇
    } else if (pGas < pLoad - 0.01) {
      dV = -0.2 * dt; // 下降
    }

    double oldVolume = volume;
    volume = (volume + dV).clamp(vMin, vMax);

    // 履歴の更新
    // PV値を正規化して履歴に追加（必要以上に増えないように間引く）
    final point = Offset(volume, pressure / 4.0);
    if (_lastHistoryPoint == null || (_lastHistoryPoint! - point).distance > 0.01) {
      pvHistory.add(point);
      _lastHistoryPoint = point;
      if (pvHistory.length > 500) pvHistory.removeAt(0);
    }

    // 粒子の更新
    double speedScale = math.sqrt(temperature / 300.0);
    for (var p in particles) p.update(dt, speedScale);

    lastTime = widget.time;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PV図エリア
        Expanded(
          flex: 9,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomPaint(
              size: Size.infinite,
              painter: BasePVPainter(
                volume: volume,
                pressure: pressure / 4.0, // 4.0はP軸の最大想定値
                temperature: temperature,
                label: "T = ${temperature.toStringAsFixed(0)} K",
                history: pvHistory,
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: Colors.black26),
        // アニメーションエリア
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
                heatFlux: heatFlux,
                weights: widget.weights,
                showTopStoppers: true,
                showBottomStoppers: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
