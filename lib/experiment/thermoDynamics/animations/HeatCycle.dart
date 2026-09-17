import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import './common.dart';
import './heat_cycle_auto.dart';

final heatCycleProcess = createWaveVideo(
  title: "熱サイクル",
  latex: r"""
  <div class="common-box">熱サイクル</div>
  <p>理想気体の状態方程式 \(PV/T=\text{一定}\) のもとで、定圧膨張→定積昇圧（最大約 \(2026\,\mathrm{hPa}\)）→おもり追加→厚い壁からのゆっくりした放熱による準静的な定圧収縮→おもり除去、というサイクルを観察します。</p>
  <p>「荷物持ち上げ」モードでは、ピストン右に \(+300\,\mathrm{hPa}\) 相当の荷物を載せた状態から加熱し、はじめは定積で昇圧し、\(1313\,\mathrm{hPa}\) で釣り合うと定圧で持ち上がります。荷物を取り外したあとは、通常どおり錘の載せ取りで熱サイクルに戻れます。</p>
  <ol>
    <li><b>断熱ON・おもり0・加熱</b>：荷重圧 \(P_0\) のもとで定圧膨張し、上ストッパーまで体積が増えます。</li>
    <li><b>上端で加熱継続</b>：体積固定の定積加熱となり、\(P\) が約 \(2026\,\mathrm{hPa}\) まで上がります。</li>
    <li><b>おもりを載せる</b>：荷重を \(P_1\approx 2026\,\mathrm{hPa}\) に上げます（気体圧が十分高いとき）。</li>
    <li><b>断熱OFF</b>：厚い壁を通じて外気へゆっくり放熱し、\(P_1\) の定圧で体積が下ストッパーまで戻ります（準静的）。</li>
    <li><b>下端で十分冷えたらおもりを取る</b>：荷重を \(P_0\) に戻し、初期状態へ閉じます。</li>
  </ol>
  """,
  simulation: HeatCycleSimulation(),
  height: 974,
);

class HeatCycleSimulation extends PhysicsSimulation {
  HeatCycleSimulation()
      : super(
          title: "熱サイクル",
          formula: const FormulaDisplay(r'PV/T = \text{const.}'),
          aspectRatio: 0.66,
        );

  /// アニメ側の温度・体積・圧力・錘（錘ボタンの有効条件用）
  final ValueNotifier<double> temperature = ValueNotifier(300.0);
  final ValueNotifier<double> volume = ValueNotifier(HeatCycleAnimationWidget.vMin);
  final ValueNotifier<double> pressure = ValueNotifier(HeatCycleAnimationWidget.p0);
  final ValueNotifier<int> weightCount = ValueNotifier(0);
  /// 荷物持ち上げモード（切替で状態・履歴リセット）
  final ValueNotifier<bool> cargoLiftMode = ValueNotifier(false);
  /// 荷物がピストンに載っているか（持ち上げモード開始時は true）
  final ValueNotifier<bool> cargoOn = ValueNotifier(false);
  /// 通常サイクルの自動ループ
  final ValueNotifier<bool> autoCycle = ValueNotifier(false);

  /// Reset ボタンで内部状態を初期化するための世代番号
  final ValueNotifier<int> resetEpoch = ValueNotifier(0);

  static const double minTemp = 300.0;
  /// 上端定積で P≈2026 hPa: T = T0·2·(Vmax/Vmin) = 300·2·2.8 = 1680 K
  static const double maxTemp = 1680.0;

  void Function(String key, double value)? _updateParam;
  void Function(Set<String>)? _updateActiveIds;
  /// buildAnimation / ExtraControls が渡す最新の activeIds（post-frame 用）
  Set<String> _latestActiveIds = {'insulated'};
  /// Auto の post-frame が同一ビルドで多重発火しないようにする
  bool _autoTickScheduled = false;
  DateTime? _lastAutoTickAt;

  /// UI 非依存 Session。物理フレームごとに [onPhysicsSample] する。
  final HeatCycleAutoSession _autoSession = HeatCycleAutoSession(
    minTemp: minTemp,
    maxTemp: maxTemp,
    temperature: minTemp,
    weights: 0,
    insulated: true,
    heating: false,
    volume: HeatCycleAnimationWidget.vMin,
    vMin: HeatCycleAnimationWidget.vMin,
    vMax: HeatCycleAnimationWidget.vMax,
    actionHoldSec: 2.0,
  );

  @override
  Map<String, double> get initialParameters => {
        'weights': 0.0,
      };

  @override
  Set<String> get initialActiveIds => {'insulated'};

  void _syncSessionFromUi() {
    _autoSession.temperature = temperature.value;
    _autoSession.volume = volume.value;
    _autoSession.cargoLiftMode = cargoLiftMode.value;
    _autoSession.cargoOn = cargoOn.value;
    _autoSession.weights = weightCount.value.clamp(0, 1);
    _autoSession.insulated = _latestActiveIds.contains('insulated');
    _autoSession.heating = _latestActiveIds.contains('heating');
  }

  void _applySessionToUi(void Function(Set<String>) updateActiveIds) {
    if (weightCount.value != _autoSession.weights) {
      _setWeights(_autoSession.weights);
    }
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

  void _setWeights(int count) {
    final c = count.clamp(0, 1);
    weightCount.value = c;
    _updateParam?.call('weights', c.toDouble());
  }

  void _resetAll({bool keepAuto = false}) {
    if (!keepAuto) {
      autoCycle.value = false;
    }
    _setWeights(0);
    _latestActiveIds = Set<String>.from(initialActiveIds);
    _updateActiveIds?.call(Set<String>.from(initialActiveIds));
    temperature.value = minTemp;
    volume.value = HeatCycleAnimationWidget.vMin;
    pressure.value = HeatCycleAnimationWidget.p0;
    cargoOn.value = cargoLiftMode.value;
    _autoSession
      ..temperature = minTemp
      ..volume = HeatCycleAnimationWidget.vMin
      ..weights = 0
      ..insulated = true
      ..heating = false
      ..cargoLiftMode = cargoLiftMode.value
      ..cargoOn = cargoLiftMode.value
      ..holdRemainingSec = 0
      ..holdStatusLabel = null;
    resetEpoch.value++;
  }

  void _setCargoLiftMode(bool enabled) {
    if (cargoLiftMode.value == enabled) return;
    cargoLiftMode.value = enabled;
    _resetAll(keepAuto: autoCycle.value);
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

  /// 温度が上限で張り付くと ValueNotifier が止むため、
  /// ExtraControls の AnimatedBuilder だけだと Auto が再評価されない。
  /// 物理ステップ（毎フレーム）から呼ぶ。
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

  /// Auto: Session で評価（温度非変化フレームでも進む。見える操作は 2s ホールド）
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
    _updateParam = updateParam;
    final w = (params['weights'] ?? 0.0).round().clamp(0, 1);
    // Auto 中は weightCount が操作の真実。params で上書きしない
    if (!autoCycle.value && weightCount.value != w) {
      weightCount.value = w;
    }
    return [
      const Text("操作説明", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ValueListenableBuilder<bool>(
        valueListenable: cargoLiftMode,
        builder: (context, lift, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              lift
                  ? "【荷物持ち上げモード】\n"
                      "1. 荷物（+300 hPa）あり・荷重 1313 hPa から開始。\n"
                      "2. 加熱すると定積で昇圧し、約 1313 hPa で定圧持ち上げ。\n"
                      "3. 上端で約 2026 hPa まで上げたら荷物を取り、錘を載せて定圧収縮。\n"
                      "4. 下端で錘を取り、荷物を載せ直すと一周。Auto でも同じ流れを自動実行。\n"
                      "モード切替・Reset で初期化。"
                  : "1. 断熱ON・おもり0のまま加熱し、定圧で上ストッパーまで膨張させます。\n"
                      "2. 上端のまま加熱を続け、定積で約 2026 hPa まで圧力を上げます。\n"
                      "3. 十分上がったら「錘を載せる」（上端でのみ可）。\n"
                      "4. 断熱をOFFにすると、厚い壁からゆっくり放熱し、定圧で下まで戻ります。\n"
                      "5. 下端で十分冷えてから「錘を取る」と初期状態に閉じます。\n"
                      "アニメ直下の Auto をONにすると、通常／荷物モードどちらでも自動循環します。\n"
                      "右下の Reset でいつでも初期化できます。",
            ),
          );
        },
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
        weightCount,
        cargoLiftMode,
        cargoOn,
        autoCycle,
      ]),
      builder: (context, _) {
        final temp = temperature.value;
        final vol = volume.value;
        final pGas = pressure.value;
        final currentWeights = weightCount.value.clamp(0, 1);
        final bool lift = cargoLiftMode.value;
        final bool hasCargo = cargoOn.value;
        final bool autoOn = autoCycle.value;
        final atMax = temp >= maxTemp - 0.5;
        final atMin = temp <= minTemp + 0.5;

        // Auto は物理フレーム側で連続評価。ここでは最新 activeIds を渡すだけ。
        if (autoOn) {
          _latestActiveIds = Set<String>.from(activeIds);
          _scheduleAutoTick();
        }

        // 手動操作時のみ: 上限で加熱チップOFF / 非断熱時の加熱禁止。
        // Auto 中は FSM が「錘＋断熱OFF＋加熱OFF」を一括で出す。
        if (!autoOn) {
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

        final bool atTop =
            vol >= HeatCycleAnimationWidget.vMax - 0.02;
        final bool atBottom =
            vol <= HeatCycleAnimationWidget.vMin + 0.02;

        // 荷物とサイクル錘は同時搭載しない（荷重の意味が曖昧になるため）
        final bool canAdd = !autoOn &&
            !hasCargo &&
            currentWeights == 0 &&
            atTop &&
            pGas >= HeatCycleAnimationWidget.p1 - 0.08 &&
            _updateParam != null;
        final bool canRemove = !autoOn &&
            !hasCargo &&
            currentWeights == 1 &&
            atBottom &&
            pGas <= HeatCycleAnimationWidget.p0 + 0.08 &&
            _updateParam != null;
        final bool canUnloadCargo =
            !autoOn && lift && hasCargo && currentWeights == 0;
        final bool canLoadCargo = !autoOn &&
            lift &&
            !hasCargo &&
            currentWeights == 0 &&
            atBottom &&
            pGas <= HeatCycleAnimationWidget.p0 + 0.08;

        // Auto 中はチップ／ボタンの selected がチカチカして煩いので出さない。
        // 高さは常に確保して Auto ON/OFF でレイアウトが跳ねないようにする。
        // 断熱+加熱 ≈118 / 荷物行+錘行 ≈8+40+10+40 → lift 時は 220 必要
        final double panelHeight = lift ? 220.0 : 118.0;
        if (autoOn) {
          return SizedBox(height: panelHeight);
        }

        return SizedBox(
          height: panelHeight,
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildThermoInsulationHeatControls(
                  activeIds: activeIds,
                  updateActiveIds: updateActiveIds,
                  atMaxTemp: atMax,
                  atMinTemp: atMin,
                  showCooling: false,
                  heatingRequiresInsulation: true,
                  controlsEnabled: true,
                ),
                if (lift) ...[
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
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '錘: $currentWeights / 1',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: canAdd
                          ? () {
                              _setWeights(1);
                            }
                          : null,
                      child: const Text('錘を載せる'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: canRemove
                          ? () {
                              _setWeights(0);
                            }
                          : null,
                      child: const Text('錘を取る'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildAnimation(context, time, azimuth, tilt, scale, params, activeIds) {
    _latestActiveIds = Set<String>.from(activeIds);
    final wParam = (params['weights'] ?? 0).round().clamp(0, 1);
    // Auto 中は weightCount を優先し、params へ書き戻す
    final int w = autoCycle.value ? weightCount.value.clamp(0, 1) : wParam;
    if (autoCycle.value && wParam != w) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateParam?.call('weights', w.toDouble());
      });
    } else if (!autoCycle.value && weightCount.value != wParam) {
      weightCount.value = wParam;
    }
    return Column(
      children: [
        Expanded(
          child: ValueListenableBuilder<int>(
            valueListenable: resetEpoch,
            builder: (context, epoch, _) {
              return AnimatedBuilder(
                animation:
                    Listenable.merge([cargoLiftMode, cargoOn, weightCount]),
                builder: (context, _) {
                  final lift = cargoLiftMode.value;
                  final hasCargo = cargoOn.value;
                  final weights =
                      autoCycle.value ? weightCount.value.clamp(0, 1) : w;
                  return HeatCycleAnimationWidget(
                    time: time,
                    isHeating: activeIds.contains('heating'),
                    isInsulated: activeIds.contains('insulated'),
                    weights: weights,
                    cargoLiftMode: lift,
                    cargoOn: hasCargo,
                    scale: scale,
                    resetEpoch: epoch,
                    onReset: () => _resetAll(),
                    onTemperatureChanged: (t) {
                      // Auto 中は小さな変化も反映（冷却の HUD / Session 入力）
                      final thresh = autoCycle.value ? 0.05 : 0.25;
                      if ((temperature.value - t).abs() > thresh) {
                        temperature.value = t;
                      } else if (autoCycle.value) {
                        // 上限張り付きでも Session を回す（notifier は同値で止む）
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
          ),
        ),
        // アニメ直下・中央寄せ（荷物持ち上げ / Auto は併用可）
        AnimatedBuilder(
          animation: Listenable.merge([
            autoCycle,
            cargoLiftMode,
            temperature,
            volume,
            weightCount,
            cargoOn,
          ]),
          builder: (context, _) {
            final autoOn = autoCycle.value;
            final lift = cargoLiftMode.value;
            // Session を UI 状態に合わせてからラベル取得
            if (autoOn) {
              _syncSessionFromUi();
            }
            final status = autoOn ? _autoSession.statusLabel : null;
            return Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildThermoAutoStatusBox(status),
                  const SizedBox(height: 4),
                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      runSpacing: 0,
                      children: [
                        const Text(
                          '荷物持ち上げ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Switch(
                          value: lift,
                          onChanged: autoOn ? null : _setCargoLiftMode,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Auto',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Switch(
                          value: autoOn,
                          onChanged: _setAuto,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class HeatCycleAnimationWidget extends StatefulWidget {
  final double time;
  final bool isHeating;
  final bool isInsulated;
  final int weights;
  final bool cargoLiftMode;
  final bool cargoOn;
  final double scale;
  final int resetEpoch;
  final VoidCallback? onReset;
  final ValueChanged<double>? onTemperatureChanged;
  final void Function(double volume, double pressure)? onStateChanged;

  static const double ambientTemp = 300.0;
  static const double vMin = 0.25;
  static const double vMax = 0.70;
  /// おもり0の荷重圧（Vmin・300 K で気体と平衡）= 1013 hPa
  static const double p0 = 1.0;
  /// おもり1の荷重圧（上端定積加熱後）≈ 2026 hPa
  static const double p1 = 2026.0 / IdealGasRef.p0HPa;
  /// 荷物 +300 hPa → 荷重 1313 hPa
  static const double pCargoLoad = 1313.0 / IdealGasRef.p0HPa;
  /// PV図用。P≲2 でも余白を残す
  static const double pDisplayScale = 2.5;
  /// 厚い伝熱壁（見た目）。放熱もこれに合わせて遅くする
  static const double wallThickness = 12.0;
  /// 厚い壁の外気温緩和レート（大きいほど速い）。薄い壁想定の ~2.2 よりかなり遅く
  static const double wallCoolRate = 0.32;
  /// 取っ手ロッドを中央から少し左へ（荷物あり時）
  static const double cargoRodBias = -0.22;

  const HeatCycleAnimationWidget({
    super.key,
    required this.time,
    required this.isHeating,
    required this.isInsulated,
    required this.weights,
    this.cargoLiftMode = false,
    this.cargoOn = false,
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
  final PvHistoryTracker pvHistory = PvHistoryTracker();

  static const double ambientTemp = HeatCycleAnimationWidget.ambientTemp;
  static const double vMin = HeatCycleAnimationWidget.vMin;
  static const double vMax = HeatCycleAnimationWidget.vMax;
  static const double p0 = HeatCycleAnimationWidget.p0;
  static const double p1 = HeatCycleAnimationWidget.p1;
  static const double pDisplayScale = HeatCycleAnimationWidget.pDisplayScale;

  /// 荷物あり → 1313 hPa。なしなら錘サイクル（P0 / P1）。同時搭載しない。
  double get _pLoad {
    if (widget.cargoOn) return HeatCycleAnimationWidget.pCargoLoad;
    return widget.weights <= 0 ? p0 : p1;
  }

  /// 状態方程式: P ∝ T/V（基準 Vmin・T0 で P=P0）
  double _pGas(double t, double v) => (t / ambientTemp) * (vMin / v) * p0;

  void _resetInternalState() {
    temperature = ambientTemp;
    volume = vMin;
    pressure = _pGas(temperature, volume);
    heatFlux = 0.0;
    pvHistory.points.clear();
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
    pvHistory.record(volume, pressure / pDisplayScale);
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
    if (widget.resetEpoch != oldWidget.resetEpoch ||
        widget.cargoLiftMode != oldWidget.cargoLiftMode) {
      _resetInternalState();
      return;
    }

    double dt = widget.time - lastTime;
    if (dt < 0) dt = 0;
    if (dt > 0.1) dt = 0.02;

    final bool insulated = widget.isInsulated;

    // 温度（状態方程式の T）
    if (insulated && widget.isHeating) {
      temperature += 160.0 * dt;
    } else if (!insulated) {
      // 厚い壁: 外気温へゆっくり緩和 → 準静的な定圧収縮／定積冷却
      temperature += (ambientTemp - temperature) *
          math.min(1.0, HeatCycleAnimationWidget.wallCoolRate * dt);
    }
    temperature = temperature.clamp(
      HeatCycleSimulation.minTemp,
      HeatCycleSimulation.maxTemp,
    );

    final double pLoad = _pLoad;

    // 準静的ピストン: PV/T=const かつ P→P_load となる体積へ追従
    // 荷物ON・下端では Pgas < Pload のあいだ V 固定（定積昇圧）→ 釣り合い後に定圧上昇
    // 荷物を外すと P_load→P0。錘を載せると P_load→P1（サイクル継続）
    final double vEq = (vMin * (temperature / ambientTemp) * (p0 / pLoad))
        .clamp(vMin, vMax);
    final double catchUp = math.min(1.0, 8.0 * dt);
    volume = volume + (vEq - volume) * catchUp;
    volume = volume.clamp(vMin, vMax);

    final double pGas = _pGas(temperature, volume);
    pressure = pGas;

    // 厚い壁なので矢印は控えめ（見た目の熱流も弱め）
    heatFlux = wallAmbientHeatFlux(
      sideInsulated: insulated,
      temperature: temperature,
      ambientTemp: ambientTemp,
      heatingWithoutSideInsulation: !insulated && widget.isHeating,
    ) * 0.55;

    pvHistory.record(volume, pressure / pDisplayScale);

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
    final bool heatingActive =
        widget.isHeating && temperature < HeatCycleSimulation.maxTemp - 0.5;

    // 表示: Vmin で 1.0 L / 300 K / 1013 hPa
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
                volume: volume,
                pressure: pressure / pDisplayScale,
                temperature: temperature,
                history: pvHistory.points,
                volumeAxisMax: 1.0,
                pressureAxisMax: 1.0,
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: Colors.black26),
        Expanded(
          flex: 11,
          child: Padding(
            // 右を狭くして外気温・外気圧ラベルを容器から離す
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
                    weights: hasCargo ? 0 : widget.weights.clamp(0, 1),
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
