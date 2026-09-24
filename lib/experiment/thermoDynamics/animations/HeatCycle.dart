import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import './common.dart';
import './heat_cycle_auto.dart';
import './heat_cycle_energy.dart';

final heatCycleProcess = createWaveVideo(
  title: "熱機関と熱サイクル",
  latex: r"""
  <div class="common-box">熱機関と熱サイクル</div>
  <p>理想気体の状態方程式 \(\frac{PV}{T}=\text{一定}\) のもとで、ピストンに \(+300\,\mathrm{hPa}\) 相当の荷物を載せ、加熱して持ち上げるサイクルを観察します。</p>
  <p>はじめは定積で昇圧し、\(1313\,\mathrm{hPa}\) で釣り合うと定圧で持ち上がります。体積が上端まで増えると加熱は自動で止まります。荷物を取り外すと、厚い壁からの放熱で体積が戻り、下端で荷物を載せ直して一周します。</p>
  <p>一周すると内部エネルギーの変化は \(0\) なので、気体がした仕事 \(W\) は、与えた熱 \(Q\) と捨てた熱 \(Q'\) の差になります。</p>
  <p>$$W = Q - Q'$$</p>
  <p>熱効率は、与えた熱のうち仕事になった割合です。</p>
  <p>$$\eta = \frac{W}{Q} = 1 - \frac{Q'}{Q}$$</p>
  <ol>
    <li><b>断熱ON・荷物あり・加熱</b>：定積で \(1313\,\mathrm{hPa}\) まで昇圧したあと、定圧で上ストッパーまで持ち上がります。</li>
    <li><b>上端で加熱停止</b>：体積が増えなくなったら加熱を止めます。</li>
    <li><b>荷物を取る</b>：荷重が外気圧相当に戻ります。</li>
    <li><b>断熱OFF</b>：厚い壁を通じて外気へゆっくり放熱し、体積が下ストッパーまで戻ります。</li>
    <li><b>下端で荷物を載せる</b>：初期状態へ閉じ、次の一周に入れます。</li>
  </ol>
  """,
  simulation: HeatCycleSimulation(),
  height: 974,
);

class HeatCycleSimulation extends PhysicsSimulation {
  HeatCycleSimulation()
      : super(
          title: "熱機関と熱サイクル",
          formula: const FormulaDisplay(r'\frac{PV}{T} = \text{const.}'),
          aspectRatio: 0.66,
        );

  /// アニメ側の温度・体積・圧力（荷物ボタンの有効条件用）
  final ValueNotifier<double> temperature = ValueNotifier(300.0);
  final ValueNotifier<double> volume = ValueNotifier(HeatCycleAnimationWidget.vMin);
  final ValueNotifier<double> pressure = ValueNotifier(HeatCycleAnimationWidget.p0);
  /// 荷物がピストンに載っているか（開始時は true）
  final ValueNotifier<bool> cargoOn = ValueNotifier(true);
  /// 自動ループ
  final ValueNotifier<bool> autoCycle = ValueNotifier(false);

  /// Reset ボタンで内部状態を初期化するための世代番号
  final ValueNotifier<int> resetEpoch = ValueNotifier(0);

  static const double minTemp = 300.0;
  static const double maxTemp = 1200.0;

  void Function(Set<String>)? _updateActiveIds;
  Set<String> _latestActiveIds = {'insulated'};
  bool _autoTickScheduled = false;
  DateTime? _lastAutoTickAt;

  final HeatCycleAutoSession _autoSession = HeatCycleAutoSession(
    minTemp: minTemp,
    temperature: minTemp,
    cargoOn: true,
    insulated: true,
    heating: false,
    volume: HeatCycleAnimationWidget.vMin,
    vMin: HeatCycleAnimationWidget.vMin,
    vMax: HeatCycleAnimationWidget.vMax,
    actionHoldSec: 2.0,
  );

  @override
  Map<String, double> get initialParameters => {};

  @override
  Set<String> get initialActiveIds => {'insulated'};

  void _syncSessionFromUi() {
    _autoSession.temperature = temperature.value;
    _autoSession.volume = volume.value;
    _autoSession.cargoOn = cargoOn.value;
    _autoSession.insulated = _latestActiveIds.contains('insulated');
    _autoSession.heating = _latestActiveIds.contains('heating');
  }

  void _applySessionToUi(void Function(Set<String>) updateActiveIds) {
    if (cargoOn.value != _autoSession.cargoOn) {
      cargoOn.value = _autoSession.cargoOn;
    }
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
    next.remove('cooling');
    if (!_setEquals(next, _latestActiveIds)) {
      _latestActiveIds = next;
      updateActiveIds(next);
    }
  }

  static bool _setEquals(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);

  void _resetAll({bool keepAuto = false}) {
    if (!keepAuto) {
      autoCycle.value = false;
    }
    _latestActiveIds = Set<String>.from(initialActiveIds);
    _updateActiveIds?.call(Set<String>.from(initialActiveIds));
    temperature.value = minTemp;
    volume.value = HeatCycleAnimationWidget.vMin;
    pressure.value = HeatCycleAnimationWidget.p0;
    cargoOn.value = true;
    _autoSession
      ..temperature = minTemp
      ..volume = HeatCycleAnimationWidget.vMin
      ..insulated = true
      ..heating = false
      ..cargoOn = true
      ..holdRemainingSec = 0
      ..holdStatusLabel = null;
    resetEpoch.value++;
  }

  void _setAuto(bool enabled) {
    if (autoCycle.value == enabled) return;
    if (enabled) {
      autoCycle.value = true;
      _resetAll(keepAuto: true);
      _scheduleAutoTick();
    } else {
      autoCycle.value = false;
      _latestActiveIds = {'insulated'};
      _updateActiveIds?.call({'insulated'});
    }
  }

  void _scheduleAutoTick() {
    if (!autoCycle.value || _autoTickScheduled) return;
    if (_updateActiveIds == null) return;
    _autoTickScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoTickScheduled = false;
      if (!autoCycle.value || _updateActiveIds == null) return;
      _tickAutoCycle(_latestActiveIds, _updateActiveIds!);
      if (autoCycle.value) _scheduleAutoTick();
    });
  }

  void _tickAutoCycle(
    Set<String> activeIds,
    void Function(Set<String>) updateActiveIds,
  ) {
    if (!autoCycle.value) return;
    _latestActiveIds = Set<String>.from(activeIds);
    _syncSessionFromUi();

    final now = DateTime.now();
    final dt = _lastAutoTickAt == null
        ? 1 / 60
        : (now.difference(_lastAutoTickAt!).inMicroseconds / 1e6)
            .clamp(0.0, 0.1);
    _lastAutoTickAt = now;

    final cmd = _autoSession.onPhysicsSample(
      temperature.value,
      sampleVolume: volume.value,
      dt: dt.toDouble(),
    );
    if (cmd == null) return;
    _applySessionToUi(updateActiveIds);
  }

  @override
  List<Widget> buildControls(context, params, updateParam) {
    return [
      const Text("操作説明", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          "1. 荷物（+300 hPa）あり・荷重 1313 hPa から開始。\n"
          "2. 加熱すると定積で昇圧し、約 1313 hPa で定圧持ち上げ。\n"
          "3. 体積が上端まで増えたら加熱は自動で止まり、加熱ボタンも外れます。\n"
          "4. 荷物を取り、断熱をOFFにすると体積が戻り、下端で荷物を載せ直すと一周。\n"
          "Auto をONにすると自動循環します。右下の Reset で初期化できます。",
        ),
      ),
    ];
  }

  @override
  Widget? buildExtraControls(context, activeIds, updateActiveIds) {
    _updateActiveIds = updateActiveIds;
    _latestActiveIds = Set<String>.from(activeIds);

    return AnimatedBuilder(
      animation: Listenable.merge([
        temperature,
        volume,
        pressure,
        cargoOn,
        autoCycle,
      ]),
      builder: (context, _) {
        final vol = volume.value;
        final pGas = pressure.value;
        final bool hasCargo = cargoOn.value;
        final bool autoOn = autoCycle.value;
        final atMin = temperature.value <= minTemp + 0.5;
        final bool atTop = vol >= HeatCycleAnimationWidget.vMax - 0.02;
        final bool atBottom = vol <= HeatCycleAnimationWidget.vMin + 0.02;
        final bool heatingDone = atTop;

        if (autoOn) {
          _latestActiveIds = Set<String>.from(activeIds);
          _scheduleAutoTick();
        }

        if (!autoOn) {
          if (heatingDone && activeIds.contains('heating')) {
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

        final bool canUnloadCargo = !autoOn && hasCargo;
        final bool canLoadCargo = !autoOn &&
            !hasCargo &&
            atBottom &&
            pGas <= HeatCycleAnimationWidget.p0 + 0.08;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildThermoInsulationHeatControls(
              activeIds: activeIds,
              updateActiveIds: updateActiveIds,
              atMaxTemp: heatingDone,
              atMinTemp: atMin,
              showCooling: false,
              heatingRequiresInsulation: true,
              controlsEnabled: !autoOn,
              autoOn: autoOn,
              onAutoChanged: _setAuto,
              statusLabel: autoOn ? _autoSession.statusLabel : null,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  hasCargo ? '荷物: あり' : '荷物: なし',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: canLoadCargo
                      ? () {
                          cargoOn.value = true;
                        }
                      : null,
                  child: const Text('荷物を載せる'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: canUnloadCargo
                      ? () {
                          cargoOn.value = false;
                        }
                      : null,
                  child: const Text('荷物を取る'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget buildAnimation(context, time, azimuth, tilt, scale, params, activeIds) {
    _latestActiveIds = Set<String>.from(activeIds);
    return ValueListenableBuilder<int>(
      valueListenable: resetEpoch,
      builder: (context, epoch, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: cargoOn,
          builder: (context, hasCargo, _) {
            return HeatCycleAnimationWidget(
              time: time,
              isHeating: activeIds.contains('heating'),
              isInsulated: activeIds.contains('insulated'),
              cargoOn: hasCargo,
              scale: scale,
              resetEpoch: epoch,
              onReset: () => _resetAll(),
              onTemperatureChanged: (t) {
                final thresh = autoCycle.value ? 0.05 : 0.25;
                if ((temperature.value - t).abs() > thresh) {
                  temperature.value = t;
                } else if (autoCycle.value) {
                  temperature.value = t;
                }
                if (autoCycle.value) {
                  _scheduleAutoTick();
                }
              },
              onStateChanged: (v, p) {
                if ((volume.value - v).abs() > 0.005) volume.value = v;
                if ((pressure.value - p).abs() > 0.01) {
                  pressure.value = p;
                }
              },
            );
          },
        );
      },
    );
  }
}

class HeatCycleAnimationWidget extends StatefulWidget {
  final double time;
  final bool isHeating;
  final bool isInsulated;
  final bool cargoOn;
  final double scale;
  final int resetEpoch;
  final VoidCallback? onReset;
  final ValueChanged<double>? onTemperatureChanged;
  final void Function(double volume, double pressure)? onStateChanged;

  static const double ambientTemp = 300.0;
  static const double vMin = 0.25;
  static const double vMax = 0.70;
  /// 荷物なしの荷重圧（Vmin・300 K で気体と平衡）= 1013 hPa
  static const double p0 = 1.0;
  /// 荷物 +300 hPa → 荷重 1313 hPa
  static const double pCargoLoad = 1313.0 / IdealGasRef.p0HPa;
  static const double wallThickness = 12.0;
  static const double wallCoolRate = 0.32;
  static const double cargoRodBias = -0.22;

  const HeatCycleAnimationWidget({
    super.key,
    required this.time,
    required this.isHeating,
    required this.isInsulated,
    required this.cargoOn,
    this.scale = 1.0,
    this.resetEpoch = 0,
    this.onReset,
    this.onTemperatureChanged,
    this.onStateChanged,
  });

  @override
  State<HeatCycleAnimationWidget> createState() => _HeatCycleAnimationWidgetState();
}

class _HeatCycleAnimationWidgetState extends State<HeatCycleAnimationWidget> {
  late List<ThermodynamicParticle> particles;
  double temperature = HeatCycleAnimationWidget.ambientTemp;
  double volume = HeatCycleAnimationWidget.vMin;
  double pressure = HeatCycleAnimationWidget.p0;
  double heatFlux = 0.0;
  double lastTime = 0.0;
  final PvHistoryTracker pvHistory = PvHistoryTracker(maxPoints: 0);
  final HeatCycleEnergyLedger energy = HeatCycleEnergyLedger();

  static const double ambientTemp = HeatCycleAnimationWidget.ambientTemp;
  static const double vMin = HeatCycleAnimationWidget.vMin;
  static const double vMax = HeatCycleAnimationWidget.vMax;
  static const double p0 = HeatCycleAnimationWidget.p0;
  static final double _vAxisMaxL =
      IdealGasRef.v0L * (vMax / vMin) * 1.05;
  static final double _pAxisMaxHPa =
      IdealGasRef.p0HPa * HeatCycleAnimationWidget.pCargoLoad * 1.2;

  double get _volumeL => IdealGasRef.v0L * (volume / vMin);
  double get _pressureHPa => pressure * IdealGasRef.p0HPa;

  double get _pLoad =>
      widget.cargoOn ? HeatCycleAnimationWidget.pCargoLoad : p0;

  double _pGas(double t, double v) => (t / ambientTemp) * (vMin / v) * p0;

  void _resetInternalState() {
    temperature = ambientTemp;
    volume = vMin;
    pressure = _pGas(temperature, volume);
    heatFlux = 0.0;
    pvHistory.clear();
    energy.reset();
    lastTime = widget.time;
    _initParticles();
    widget.onTemperatureChanged?.call(temperature);
    widget.onStateChanged?.call(volume, pressure);
  }

  @override
  void initState() {
    super.initState();
    lastTime = widget.time;
    _initParticles();
    pressure = _pGas(temperature, volume);
    pvHistory.record(_volumeL, _pressureHPa);
    widget.onTemperatureChanged?.call(temperature);
    widget.onStateChanged?.call(volume, pressure);
  }

  void _initParticles() {
    final random = math.Random();
    particles = List.generate(
      20,
      (index) => ThermodynamicParticle(
        position: Offset(random.nextDouble(), random.nextDouble()),
        velocity: Offset(
          (random.nextDouble() - 0.5) * 0.06,
          (random.nextDouble() - 0.5) * 0.06,
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(HeatCycleAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resetEpoch != oldWidget.resetEpoch) {
      _resetInternalState();
      return;
    }

    double dt = widget.time - lastTime;
    if (dt < 0) dt = 0;
    if (dt > 0.1) dt = 0.02;

    final bool insulated = widget.isInsulated;
    final bool atTopVol = volume >= vMax - 0.02;
    if (insulated && widget.isHeating && !atTopVol) {
      temperature += 160.0 * dt;
    } else if (!insulated) {
      temperature += (ambientTemp - temperature) *
          math.min(1.0, HeatCycleAnimationWidget.wallCoolRate * dt);
    }
    temperature = temperature.clamp(
      HeatCycleSimulation.minTemp,
      HeatCycleSimulation.maxTemp,
    );

    final double pLoad = _pLoad;
    final double vEq = (vMin * (temperature / ambientTemp) * (p0 / pLoad))
        .clamp(vMin, vMax);
    final double catchUp = math.min(1.0, 8.0 * dt);
    volume = volume + (vEq - volume) * catchUp;
    volume = volume.clamp(vMin, vMax);
    pressure = _pGas(temperature, volume);

    heatFlux = wallAmbientHeatFlux(
      sideInsulated: insulated,
      temperature: temperature,
      ambientTemp: ambientTemp,
      heatingWithoutSideInsulation: !insulated && widget.isHeating,
    ) * 0.55;

    pvHistory.record(_volumeL, _pressureHPa);
    energy.sample(
      temperatureK: temperature,
      volumeL: _volumeL,
      pressureHPa: _pressureHPa,
      cargoOn: widget.cargoOn,
    );

    final double speedScale = math.sqrt(temperature / ambientTemp);
    for (var p in particles) {
      p.update(dt, speedScale);
    }

    lastTime = widget.time;
    widget.onTemperatureChanged?.call(temperature);
    widget.onStateChanged?.call(volume, pressure);
  }

  @override
  Widget build(BuildContext context) {
    final bool insulated = widget.isInsulated;
    final bool hasCargo = widget.cargoOn;
    final bool heatingActive = widget.isHeating && volume < vMax - 0.02;

    final double volumeL = IdealGasRef.v0L * (volume / vMin);
    final double pressureHPa = IdealGasRef.pressureHPa(
      tK: temperature,
      vL: volumeL,
    );

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
        if (energy.completed > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: _HeatCycleEnergyReadout(ledger: energy),
          ),
        const Divider(height: 1, color: Colors.black26),
        Expanded(
          flex: 11,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
            child: Stack(
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: BaseGasPainter(
                    particles: particles,
                    volume: volume,
                    temperature: temperature,
                    isHeating: heatingActive,
                    heatFlux: heatFlux,
                    weights: 0,
                    showCargo: hasCargo,
                    rodCenterBias: hasCargo
                        ? HeatCycleAnimationWidget.cargoRodBias
                        : 0.0,
                    showHeater: true,
                    showInsulationCovers: insulated,
                    showOuterVessel: true,
                    showTopStoppers: true,
                    showBottomStoppers: true,
                    topStopperVolume: vMax,
                    bottomStopperVolume: vMin,
                    wallThickness: HeatCycleAnimationWidget.wallThickness,
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
                      if (hasCargo) ...[
                        const Text(
                          "荷物 +300 hPa",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      if (insulated) ...[
                        buildAmbientInsulationBadge(),
                        const SizedBox(height: 8),
                      ],
                      buildAmbientTpLabels(),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: TextButton.icon(
                    onPressed: widget.onReset,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reset'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black87,
                      backgroundColor: Colors.white.withOpacity(0.85),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                    ),
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

class _HeatCycleEnergyReadout extends StatelessWidget {
  const _HeatCycleEnergyReadout({required this.ledger});

  final HeatCycleEnergyLedger ledger;

  @override
  Widget build(BuildContext context) {
    final q = ledger.closedHeatInJ ?? 0;
    final qp = ledger.closedHeatOutJ ?? 0;
    final w = ledger.closedWorkJ;
    final eta = ledger.closedEfficiency ?? 0;
    String j(double v) => '${v.toStringAsFixed(1)} J';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '一周  Q = ${j(q)}（与えた熱）   Q\' = ${j(qp)}（捨てた熱）\n'
        'W = Q − Q\' = ${j(w)}    熱効率 η = W/Q = ${(eta * 100).toStringAsFixed(1)} %',
        style: const TextStyle(
          fontSize: 12,
          height: 1.35,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
