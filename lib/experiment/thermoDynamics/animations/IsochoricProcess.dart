import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import './common.dart';
import './thermo_process_auto.dart';

/// 定積変化（等積変化）のシミュレーション
final isochoricProcess = createWaveVideo(
  title: "定積変化",
  latex: r"""
  <div class="common-box">定積変化（等積変化）</div>
  <p>気体の体積 $V$ を一定に保ったまま状態を変化させることを定積変化といいます。</p>
  <p>ボイル・シャルルの法則 $\frac{PV}{T} = \text{一定}$ より、$V$ が一定のとき、圧力 $P$ は絶対温度 $T$ に比例します。</p>
  <p>$$P \propto T$$</p>
  <p>$$\dfrac{P}{T} = \text{一定}$$</p>
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

  final ValueNotifier<double> temperature = ValueNotifier(300.0);
  final ValueNotifier<bool> autoCycle = ValueNotifier(false);

  static const double minTemp = 273.0;
  static const double maxTemp = 1000.0;
  static const double iceBathTemp = 273.0;
  static const double ambientTemp = 300.0;

  void Function(Set<String>)? _updateActiveIds;
  Set<String> _latestActiveIds = {};
  bool _autoTickScheduled = false;
  DateTime? _lastAutoTickAt;

  final ThermoTempAutoSession _autoSession = ThermoTempAutoSession(
    ambientTemp: ambientTemp,
    maxTemp: maxTemp,
    temperature: ambientTemp,
  );

  @override
  Map<String, double> get initialParameters => {
        'baseTemp': 300.0,
      };

  @override
  Set<String> get initialActiveIds => {};

  void _setAuto(bool enabled) {
    if (autoCycle.value == enabled) return;
    autoCycle.value = enabled;
    if (enabled) {
      _autoSession.reset();
      _latestActiveIds = {};
      _updateActiveIds?.call({});
      temperature.value = ambientTemp;
      _scheduleAutoTick();
    } else {
      _latestActiveIds = {};
      _updateActiveIds?.call({});
    }
  }

  void _scheduleAutoTick() {
    if (!autoCycle.value || _autoTickScheduled) return;
    if (_updateActiveIds == null) return;
    _autoTickScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoTickScheduled = false;
      if (!autoCycle.value || _updateActiveIds == null) return;
      _tickAuto();
      if (autoCycle.value) _scheduleAutoTick();
    });
  }

  void _tickAuto() {
    _autoSession.insulated = _latestActiveIds.contains('insulated');
    _autoSession.heating = _latestActiveIds.contains('heating');
    _autoSession.cooling = _latestActiveIds.contains('cooling');
    final now = DateTime.now();
    final dt = _lastAutoTickAt == null
        ? 1 / 60
        : (now.difference(_lastAutoTickAt!).inMicroseconds / 1e6)
            .clamp(0.0, 0.1)
            .toDouble();
    _lastAutoTickAt = now;
    final cmd = _autoSession.onPhysicsSample(temperature.value, dt: dt);
    if (cmd == null) return;
    final next = Set<String>.from(_latestActiveIds);
    if (_autoSession.insulated) {
      next.add('insulated');
    } else {
      next.remove('insulated');
    }
    if (_autoSession.heating) {
      next.add('heating');
    } else {
      next.remove('heating');
    }
    if (_autoSession.cooling) {
      next.add('cooling');
    } else {
      next.remove('cooling');
    }
    _latestActiveIds = next;
    _updateActiveIds!(next);
  }

  @override
  List<Widget> buildControls(context, params, updateParam) {
    return [
      const Text("設定", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          "内容器は薄い伝熱壁で、側面・底の断熱材ごと薄い外容器にスッポリ入っています。"
          "「断熱」をオンにすると外容器内に断熱材が付き、加熱で温度を上げられます。"
          "断熱を外したときだけ「冷却」ができ、外容器に 0℃ の水が満ちます。"
          "断熱なし・冷却なしでは外気温へゆっくり戻ります。"
          "Auto では加熱→上限→冷却→外気温付近、の往復を繰り返します。",
        ),
      ),
    ];
  }

  @override
  Widget? buildExtraControls(context, activeIds, updateActiveIds) {
    _updateActiveIds = updateActiveIds;
    _latestActiveIds = Set<String>.from(activeIds);

    return AnimatedBuilder(
      animation: Listenable.merge([temperature, autoCycle]),
      builder: (context, _) {
        final temp = temperature.value;
        final autoOn = autoCycle.value;
        final atMax = temp >= maxTemp - 0.5;
        final atMin = temp <= minTemp + 0.5;

        if (autoOn) {
          _latestActiveIds = Set<String>.from(activeIds);
          _scheduleAutoTick();
        } else {
          if (atMax && activeIds.contains('heating')) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!activeIds.contains('heating')) return;
              updateActiveIds(Set<String>.from(activeIds)..remove('heating'));
            });
          }
          if (!activeIds.contains('insulated') &&
              activeIds.contains('heating')) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!activeIds.contains('heating')) return;
              updateActiveIds(Set<String>.from(activeIds)..remove('heating'));
            });
          }
        }

        return buildThermoInsulationHeatControls(
          activeIds: activeIds,
          updateActiveIds: updateActiveIds,
          atMaxTemp: atMax,
          atMinTemp: atMin,
          coolingRequiresUninsulated: true,
          heatingRequiresInsulation: true,
          controlsEnabled: !autoOn,
          autoOn: autoOn,
          onAutoChanged: _setAuto,
          statusLabel: autoOn ? _autoSession.statusLabel : null,
        );
      },
    );
  }

  @override
  Widget buildAnimation(context, time, azimuth, tilt, scale, params, activeIds) {
    _latestActiveIds = Set<String>.from(activeIds);
    final bool isHeating = activeIds.contains('heating');
    final bool isCooling = activeIds.contains('cooling');
    final bool isInsulated = activeIds.contains('insulated');
    return IsochoricAnimationWidget(
      time: time,
      isHeating: isHeating,
      isCooling: isCooling,
      isInsulated: isInsulated,
      scale: scale,
      onTemperatureChanged: (t) {
        final thresh = autoCycle.value ? 0.05 : 0.25;
        if ((temperature.value - t).abs() > thresh) {
          temperature.value = t;
        } else if (autoCycle.value) {
          temperature.value = t;
        }
        if (autoCycle.value) _scheduleAutoTick();
      },
    );
  }
}

class IsochoricAnimationWidget extends StatefulWidget {
  final double time;
  final bool isHeating;
  final bool isCooling;
  final bool isInsulated;
  final double scale;
  final ValueChanged<double>? onTemperatureChanged;

  const IsochoricAnimationWidget({
    super.key,
    required this.time,
    required this.isHeating,
    required this.isCooling,
    required this.isInsulated,
    this.scale = 1.0,
    this.onTemperatureChanged,
  });

  @override
  State<IsochoricAnimationWidget> createState() => _IsochoricAnimationWidgetState();
}

class _IsochoricAnimationWidgetState extends State<IsochoricAnimationWidget> {
  late List<ThermodynamicParticle> particles;
  double temperature = 300.0;
  double lastTime = 0.0;
  final int particleCount = 24;
  final PvHistoryTracker pvHistory = PvHistoryTracker();
  static const double fixedVolume = 0.4;
  static const double ambientTemp = 300.0;
  static const double _vAxisMaxL = IdealGasRef.vVisMaxL * 1.05;
  static final double _pAxisMaxHPa =
      IdealGasRef.p0HPa * (IsochoricSimulation.maxTemp / IdealGasRef.t0K) * 1.08;

  @override
  void initState() {
    super.initState();
    lastTime = widget.time;
    _initParticles();
    pvHistory.record(
      IdealGasRef.v0L,
      IdealGasRef.p0HPa * (temperature / IdealGasRef.t0K),
    );
    widget.onTemperatureChanged?.call(temperature);
  }

  void _initParticles() {
    final random = math.Random();
    // 初期速度を大きめにして、温度差による運動の差を見やすくする
    particles = List.generate(particleCount, (index) => ThermodynamicParticle(
      position: Offset(random.nextDouble(), random.nextDouble()),
      velocity: Offset((random.nextDouble() - 0.5) * 0.1, (random.nextDouble() - 0.5) * 0.1),
    ));
  }

  @override
  void didUpdateWidget(IsochoricAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    double dt = widget.time - lastTime;
    if (dt < 0) dt = 0;
    if (dt > 0.1) dt = 0.02;

    if (!widget.isInsulated) {
      if (widget.isCooling) {
        temperature +=
            (IsochoricSimulation.iceBathTemp - temperature) *
            math.min(1.0, 2.8 * dt);
      } else {
        // 断熱なし: 外気温へゆっくり収束
        temperature += (ambientTemp - temperature) * math.min(1.0, 2.2 * dt);
      }
    } else if (widget.isHeating) {
      temperature += 220.0 * dt;
    }
    temperature = temperature.clamp(
      IsochoricSimulation.minTemp,
      IsochoricSimulation.maxTemp,
    );

    // 温度差が運動に露骨に出るように、sqrt ではなく強めのスケール
    // T=300 → 約1.6、T=1000 → 約7.4
    final double speedScale =
        math.pow(temperature / 300.0, 1.35).toDouble() * 1.6;
    for (var p in particles) {
      p.update(dt, speedScale);
    }
    pvHistory.record(
      IdealGasRef.v0L,
      IdealGasRef.p0HPa * (temperature / IdealGasRef.t0K),
    );
    lastTime = widget.time;
    widget.onTemperatureChanged?.call(temperature);
  }

  @override
  Widget build(BuildContext context) {
    final bool heatingActive =
        widget.isHeating && temperature < IsochoricSimulation.maxTemp - 0.5;
    final bool coolingActive =
        widget.isCooling && !widget.isInsulated;
    final bool insulated = widget.isInsulated;

    // 壁矢印は外気／氷水とのやりとりのみ。断熱中の内部加熱では出さない。
    final double heatFlux;
    if (insulated) {
      heatFlux = 0.0;
    } else if (coolingActive) {
      heatFlux = temperature > IsochoricSimulation.iceBathTemp + 2
          ? -0.55
          : 0.0;
    } else {
      heatFlux = wallAmbientHeatFlux(
        sideInsulated: false,
        temperature: temperature,
        ambientTemp: ambientTemp,
        heatingWithoutSideInsulation: widget.isHeating,
      );
    }

    // 定積: V=V0、P ∝ T
    const double volumeL = IdealGasRef.v0L;
    final double pressureHPa =
        IdealGasRef.p0HPa * (temperature / IdealGasRef.t0K);

    return Column(
      children: [
        Expanded(
          flex: 9,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomPaint(
              size: Size.infinite,
              painter: BasePVPainter(
                volume: volumeL,
                pressure: pressureHPa,
                temperature: temperature,
                history: pvHistory.points,
                volumeAxisMax: _vAxisMaxL,
                pressureAxisMax: _pAxisMaxHPa,
                volumeUnit: 'L',
                pressureUnit: 'hPa',
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
                    volume: fixedVolume,
                    temperature: temperature,
                    isHeating: heatingActive,
                    isCooling: coolingActive,
                    heatFlux: heatFlux,
                    wallColor: Colors.grey,
                    showHeater: true,
                    showInsulationCovers: insulated,
                    showOuterVessel: true,
                    fillOuterVesselWithIceWater: coolingActive,
                    showBottomStoppers: true,
                    showTopStoppers: true,
                    topStopperVolume: fixedVolume,
                    bottomStopperVolume: fixedVolume,
                  ),
                ),
                buildGasStateHud(
                  volumeL: volumeL,
                  pressureHPa: pressureHPa,
                  temperatureK: temperature,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (insulated) ...[
                        buildAmbientInsulationBadge(),
                        const SizedBox(height: 8),
                      ],
                      if (coolingActive) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1F5FE).withOpacity(0.95),
                            border: Border.all(
                                color: const Color(0xFF0277BD), width: 1.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '氷水冷却中',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0277BD),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
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