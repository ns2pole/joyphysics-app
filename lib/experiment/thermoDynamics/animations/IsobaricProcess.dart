import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import './common.dart';
import './thermo_process_auto.dart';

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

  final ValueNotifier<double> temperature = ValueNotifier(300.0);
  final ValueNotifier<bool> autoCycle = ValueNotifier(false);

  static const double minTemp = 273.0;
  static const double maxTemp = 900.0;
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
          return const SizedBox(height: 118);
        }

        if (atMax && activeIds.contains('heating')) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!activeIds.contains('heating')) return;
            updateActiveIds(Set<String>.from(activeIds)..remove('heating'));
          });
        }
        if (!activeIds.contains('insulated') && activeIds.contains('heating')) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!activeIds.contains('heating')) return;
            updateActiveIds(Set<String>.from(activeIds)..remove('heating'));
          });
        }

        return SizedBox(
          height: 118,
          child: Align(
            alignment: Alignment.topCenter,
            child: buildThermoInsulationHeatControls(
              activeIds: activeIds,
              updateActiveIds: updateActiveIds,
              atMaxTemp: atMax,
              atMinTemp: atMin,
              coolingRequiresUninsulated: true,
              heatingRequiresInsulation: true,
            ),
          ),
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
    return Column(
      children: [
        Expanded(
          child: IsobaricAnimationWidget(
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
          ),
        ),
        AnimatedBuilder(
          animation: Listenable.merge([autoCycle, temperature]),
          builder: (context, _) {
            final autoOn = autoCycle.value;
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

class IsobaricAnimationWidget extends StatefulWidget {
  final double time;
  final bool isHeating;
  final bool isCooling;
  final bool isInsulated;
  final double scale;
  final ValueChanged<double>? onTemperatureChanged;

  const IsobaricAnimationWidget({
    super.key,
    required this.time,
    required this.isHeating,
    required this.isCooling,
    required this.isInsulated,
    this.scale = 1.0,
    this.onTemperatureChanged,
  });

  @override
  State<IsobaricAnimationWidget> createState() => _IsobaricAnimationWidgetState();
}

class _IsobaricAnimationWidgetState extends State<IsobaricAnimationWidget> {
  late List<ThermodynamicParticle> particles;
  double temperature = 300.0;
  double lastTime = 0.0;
  final int particleCount = 24;
  final PvHistoryTracker pvHistory = PvHistoryTracker();
  static const double pressure = 0.4; // P固定
  static const double ambientTemp = 300.0;

  double get _volume => 0.3 * (temperature / 300.0);

  @override
  void initState() {
    super.initState();
    lastTime = widget.time;
    _initParticles();
    pvHistory.record(_volume, pressure);
    widget.onTemperatureChanged?.call(temperature);
  }

  void _initParticles() {
    final random = math.Random();
    particles = List.generate(particleCount, (index) => ThermodynamicParticle(
      position: Offset(random.nextDouble(), random.nextDouble()),
      velocity: Offset((random.nextDouble() - 0.5) * 0.1, (random.nextDouble() - 0.5) * 0.1),
    ));
  }

  @override
  void didUpdateWidget(IsobaricAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    double dt = widget.time - lastTime;
    if (dt < 0) dt = 0;
    if (dt > 0.1) dt = 0.02;

    if (!widget.isInsulated) {
      if (widget.isCooling) {
        // 外容器の 0℃ 水へ緩和（空気よりはやや速いが、以前よりゆっくり）
        temperature +=
            (IsobaricSimulation.iceBathTemp - temperature) *
            math.min(1.0, 2.8 * dt);
      } else {
        // 断熱なし: 外気温へゆっくり収束
        temperature += (ambientTemp - temperature) * math.min(1.0, 2.2 * dt);
      }
    } else if (widget.isHeating) {
      temperature += 180.0 * dt;
    }
    temperature = temperature.clamp(
      IsobaricSimulation.minTemp,
      IsobaricSimulation.maxTemp,
    );

    final double speedScale =
        math.pow(temperature / 300.0, 1.35).toDouble() * 1.6;
    for (var p in particles) {
      p.update(dt, speedScale);
    }
    pvHistory.record(_volume, pressure);
    lastTime = widget.time;
    widget.onTemperatureChanged?.call(temperature);
  }

  @override
  Widget build(BuildContext context) {
    final double volume = _volume;
    final bool heatingActive =
        widget.isHeating && temperature < IsobaricSimulation.maxTemp - 0.5;
    final bool coolingActive =
        widget.isCooling && !widget.isInsulated;
    final bool insulated = widget.isInsulated;

    // 壁矢印は外気／氷水とのやりとりのみ。断熱中の内部加熱では出さない。
    final double heatFlux;
    if (insulated) {
      heatFlux = 0.0;
    } else if (coolingActive) {
      // 気体 → 0℃ 水へ放熱
      heatFlux = temperature > IsobaricSimulation.iceBathTemp + 2
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

    // 定圧: P=P0、V ∝ T（初期 1.0 L / 300 K）
    final double volumeL = IdealGasRef.v0L * (temperature / IdealGasRef.t0K);
    const double pressureHPa = IdealGasRef.p0HPa;

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
                pressure: pressure,
                temperature: temperature,
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
                    volume: volume,
                    temperature: temperature,
                    isHeating: heatingActive,
                    isCooling: coolingActive,
                    heatFlux: heatFlux,
                    wallColor: Colors.grey,
                    showHeater: true,
                    showInsulationCovers: insulated,
                    showOuterVessel: true,
                    fillOuterVesselWithIceWater: coolingActive,
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
