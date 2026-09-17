import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/waves/animations/widgets/wave_slider.dart';
import './common.dart';
import './thermo_process_auto.dart';

/// 断熱変化（断熱過程）のシミュレーション
final adiabaticProcess = createWaveVideo(
  title: "断熱変化",
  latex: r"""
  <div class="common-box">断熱変化（断熱過程）</div>
  <p>外部と熱のやり取りがない状態（断熱状態）で気体の状態を変化させることを断熱変化といいます。</p>
  <p>薄い伝熱壁の容器でも、側面・底面を断熱材で覆えば外気と熱をやり取りせず、断熱過程になります。</p>
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

  final ValueNotifier<bool> autoCycle = ValueNotifier(false);
  void Function(String key, double value)? _updateParam;
  bool _autoTickScheduled = false;
  DateTime? _lastAutoTickAt;

  final ThermoVolumeAutoSession _autoSession = ThermoVolumeAutoSession(
    homeVolume: IdealGasRef.v0L,
    farVolume: IdealGasRef.vVisMaxL,
    speedLps: 0.45,
  );

  @override
  Map<String, double> get initialParameters => {
        'volume': IdealGasRef.v0L,
      };

  void _setAuto(bool enabled) {
    if (autoCycle.value == enabled) return;
    autoCycle.value = enabled;
    if (enabled) {
      _autoSession.reset();
      _updateParam?.call('volume', IdealGasRef.v0L);
      _scheduleAutoTick();
    }
  }

  void _scheduleAutoTick() {
    if (!autoCycle.value || _autoTickScheduled) return;
    if (_updateParam == null) return;
    _autoTickScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoTickScheduled = false;
      if (!autoCycle.value || _updateParam == null) return;
      final now = DateTime.now();
      final dt = _lastAutoTickAt == null
          ? 1 / 60
          : (now.difference(_lastAutoTickAt!).inMicroseconds / 1e6)
              .clamp(0.0, 0.1)
              .toDouble();
      _lastAutoTickAt = now;
      final cur = _autoSession.volume;
      final next = _autoSession.onPhysicsSample(cur, dt: dt);
      if ((next - cur).abs() > 1e-6) {
        _updateParam!('volume', next);
      }
      if (autoCycle.value) _scheduleAutoTick();
    });
  }

  @override
  List<Widget> buildControls(context, params, updateParam) {
    _updateParam = updateParam;
    return [
      const Text("操作", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ValueListenableBuilder<bool>(
        valueListenable: autoCycle,
        builder: (context, autoOn, _) {
          return SizedBox(
            height: 72,
            child: autoOn
                ? const SizedBox.shrink()
                : WaveParameterSlider(
                    label: "ピストンの押し引き (体積 V [L])",
                    value: params['volume']!,
                    min: IdealGasRef.vMinL,
                    max: IdealGasRef.vVisMaxL,
                    onChanged: (v) => updateParam('volume', v),
                  ),
          );
        },
      ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          "容器本体は薄い伝熱壁ですが、側面・底面を断熱材で覆っているため外気と熱のやり取りがありません（断熱過程）。"
          "スライダーでピストンを押し引きしてください。"
          "初期状態は単原子分子理想気体・1.0 L・300 K・1013 hPa です。"
          "Auto では 1.0 L ⇄ 2.0 L の往復（端で約2秒停止）を繰り返します。",
        ),
      ),
    ];
  }

  @override
  Widget buildAnimation(context, time, azimuth, tilt, scale, params, activeIds) {
    if (autoCycle.value) {
      _autoSession.volume = params['volume']!;
      _scheduleAutoTick();
    }
    return Column(
      children: [
        Expanded(
          child: AdiabaticAnimationWidget(
            time: time,
            volumeL: params['volume']!,
            scale: scale,
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: autoCycle,
          builder: (context, autoOn, _) {
            return buildThermoAutoToggle(
              autoOn: autoOn,
              onChanged: _setAuto,
              statusLabel: autoOn
                  ? _autoSession.statusLabel
                  : null,
            );
          },
        ),
      ],
    );
  }
}

class AdiabaticAnimationWidget extends StatefulWidget {
  final double time;
  final double volumeL;
  final double scale;

  const AdiabaticAnimationWidget({
    super.key,
    required this.time,
    required this.volumeL,
    this.scale = 1.0,
  });

  @override
  State<AdiabaticAnimationWidget> createState() => _AdiabaticAnimationWidgetState();
}

class _AdiabaticAnimationWidgetState extends State<AdiabaticAnimationWidget> {
  late List<ThermodynamicParticle> particles;
  double lastTime = 0.0;
  final int particleCount = 20;
  final PvHistoryTracker pvHistory = PvHistoryTracker();

  /// 圧縮端でも状態点が枠内に収まるよう、軸最大をわずかに余裕を持たせる
  static final double _vAxisMaxL = IdealGasRef.vVisMaxL * 1.05;
  static final double _pAxisMaxHPa =
      IdealGasRef.adiabaticPressureHPa(IdealGasRef.vMinL) * 1.08;

  @override
  void initState() {
    super.initState();
    lastTime = widget.time;
    _initParticles();
    pvHistory.record(
      widget.volumeL,
      IdealGasRef.adiabaticPressureHPa(widget.volumeL),
    );
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

    final double temperature = IdealGasRef.adiabaticTemperatureK(widget.volumeL);
    final double speedScale = math.sqrt(temperature / IdealGasRef.t0K);

    for (var p in particles) {
      p.update(dt, speedScale);
    }
    pvHistory.record(
      widget.volumeL,
      IdealGasRef.adiabaticPressureHPa(widget.volumeL),
    );
    lastTime = widget.time;
  }

  @override
  Widget build(BuildContext context) {
    final double volumeL = widget.volumeL;
    final double temperature = IdealGasRef.adiabaticTemperatureK(volumeL);
    final double pressure = IdealGasRef.adiabaticPressureHPa(volumeL);
    final double cylinderVolume = IdealGasRef.cylinderVolumeFromVL(volumeL);

    return Column(
      children: [
        Expanded(
          flex: 9,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomPaint(
              size: Size.infinite,
              painter: AdiabaticPVPainter(
                volumeL: volumeL,
                pressureHPa: pressure,
                temperatureK: temperature,
                volumeAxisMaxL: _vAxisMaxL,
                pressureAxisMaxHPa: _pAxisMaxHPa,
                history: pvHistory.points,
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: Colors.black26),
        Expanded(
          flex: 11,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: BaseGasPainter(
                    particles: particles,
                    volume: cylinderVolume,
                    temperature: temperature,
                    // 薄い外容器の中に断熱材がスッポリ（左下・右下も一体）
                    wallColor: Colors.grey,
                    wallThickness: 4.0,
                    showHeater: false,
                    showInsulationCovers: true,
                    showOuterVessel: true,
                    cylinderWidthFactor: 0.233,
                    cylinderHeightFactor: 0.66,
                    personFeetPos: const Offset(0, 0),
                  ),
                ),
                buildGasStateHud(
                  volumeL: volumeL,
                  pressureHPa: pressure,
                  temperatureK: temperature,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      buildAmbientInsulationBadge(),
                      const SizedBox(height: 8),
                      buildAmbientTpLabels(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AdiabaticPVPainter extends BasePVPainter {
  AdiabaticPVPainter({
    required double volumeL,
    required double pressureHPa,
    required double temperatureK,
    required double volumeAxisMaxL,
    required double pressureAxisMaxHPa,
    List<Offset>? history,
  }) : super(
          volume: volumeL,
          pressure: pressureHPa,
          temperature: temperatureK,
          volumeAxisMax: volumeAxisMaxL,
          pressureAxisMax: pressureAxisMaxHPa,
          history: history,
        );

  @override
  void drawExtraCurves(Canvas canvas, Size size, double padding, double w, double h) {
    final double vMax = volumeAxisMax;
    final double pMax = pressureAxisMax;

    // 等温曲線 (初期温度 300 K 比較用)
    final isoPath = Path();
    bool isoStarted = false;
    for (double vL = IdealGasRef.vMinL; vL <= IdealGasRef.vVisMaxL; vL += 0.02) {
      final double p = IdealGasRef.isothermalPressureHPa(vL);
      final double x = padding + (vL / vMax) * w;
      final double y = size.height - padding - (p / pMax) * h;
      if (y < padding || y > size.height - padding) continue;
      if (!isoStarted) {
        isoPath.moveTo(x, y);
        isoStarted = true;
      } else {
        isoPath.lineTo(x, y);
      }
    }
    canvas.drawPath(
      isoPath,
      Paint()
        ..color = Colors.blue.withOpacity(0.15)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );

    // 断熱曲線
    final adiaPath = Path();
    bool adiaStarted = false;
    for (double vL = IdealGasRef.vMinL; vL <= IdealGasRef.vVisMaxL; vL += 0.02) {
      final double p = IdealGasRef.adiabaticPressureHPa(vL);
      final double x = padding + (vL / vMax) * w;
      final double y = size.height - padding - (p / pMax) * h;
      if (y < padding || y > size.height - padding) continue;
      if (!adiaStarted) {
        adiaPath.moveTo(x, y);
        adiaStarted = true;
      } else {
        adiaPath.lineTo(x, y);
      }
    }
    canvas.drawPath(
      adiaPath,
      Paint()
        ..color = Colors.red.withOpacity(0.3)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke,
    );
  }
}
