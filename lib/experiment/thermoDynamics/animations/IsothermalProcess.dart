import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/waves/animations/widgets/wave_slider.dart';
import './common.dart';
import './thermo_process_auto.dart';
import 'package:joyphysics/l10n/anim_ui.dart';

/// 等温変化（等温過程）のシミュレーション
final isothermalProcess = createWaveVideo(
  title: "等温変化",
  titleEn: 'Isothermal process',
  category: 'thermoDynamics',
  iconName: 'boyleLaw',
  latex: r"""
  <div class="common-box">等温変化（等温過程）</div>
  <p>気体の温度 $T$ を一定に保ったまま状態を変化させることを等温変化といいます。</p>
  <p>薄い伝熱壁の容器を外気に触れさせておくと、気体は外気温と同じ温度に保たれるため等温過程になります。</p>
  <p>ボイルの法則より、温度が一定のとき、気体の圧力 $P$ は体積 $V$ に反比例します。</p>
  <p>$$PV = \text{一定}$$</p>
  <p>$$P \propto \frac{1}{V}$$</p>
  <p>熱力学第一法則 $Q = \Delta U + W$ において、温度が変わらないため内部エネルギーの変化 $\Delta U = 0$ となり、外部から加えた熱 $Q$ はすべて気体が外部へ行う仕事 $W$ に等しくなります（あるいは外部から仕事を受けると、その分だけ熱を放出します）。</p>
  """,
  latexEn: r"""
  <div class="common-box">Isothermal process (constant temperature)</div>
  <p>An isothermal process is a change of state with the gas temperature $T$ held constant.</p>
  <p>If a vessel with thin heat-conducting walls is left in contact with the ambient air, the gas stays at the ambient temperature, so the process is isothermal.</p>
  <p>By Boyle's law, at constant temperature the gas pressure $P$ is inversely proportional to the volume $V$.</p>
  <p>$$PV = \text{constant}$$</p>
  <p>$$P \propto \frac{1}{V}$$</p>
  <p>In the first law of thermodynamics $Q = \Delta U + W$, the temperature does not change so $\Delta U = 0$, and the heat $Q$ added equals the work $W$ done by the gas on the surroundings (or, when work is done on the gas, an equal amount of heat is released).</p>
  """,
  simulation: IsothermalSimulation(),
  height: 974,
);

class IsothermalSimulation extends PhysicsSimulation {
  IsothermalSimulation()
      : super(
          title: animL("等温変化", "Isothermal process"),
          formula: const FormulaDisplay(
              r'\displaystyle T = \text{const.},\quad PV = \text{const.}'),
          aspectRatio: 0.66,
        );

  final ValueNotifier<bool> autoCycle = ValueNotifier(true);
  void Function(String key, double value)? _updateParam;
  bool _autoTickScheduled = false;
  DateTime? _lastAutoTickAt;

  final ThermoVolumeAutoSession _autoSession = ThermoVolumeAutoSession(
    homeVolume: IdealGasRef.v0L,
    farVolume: IdealGasRef.vVisMaxL,
    // 等温は熱が追いつくようゆっくり
    speedLps: 0.25,
  );

  @override
  Map<String, double> get initialParameters => {
        'volume': IdealGasRef.v0L,
      };

  /// 記事を開いた瞬間から Auto を回す（力学の playOnOpen と同じタイミング）
  @override
  void startPlayback() => _setAuto(true, force: true);

  void _setAuto(bool enabled, {bool force = false}) {
    if (!force && autoCycle.value == enabled) return;
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
      Text(animL("操作", "Controls"), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ValueListenableBuilder<bool>(
        valueListenable: autoCycle,
        builder: (context, autoOn, _) {
          return Visibility(
            visible: !autoOn,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: WaveParameterSlider(
              label: animL("ピストンの押し引き\n(体積 V [L])", "Push/pull the piston\n(volume V [L])"),
              maxLines: 2,
              labelAlign: TextAlign.center,
              labelAbove: true,
              value: params['volume']!,
              min: IdealGasRef.vMinL,
              max: IdealGasRef.vVisMaxL,
              onChanged: (v) {
                final cur = params['volume']!;
                const maxStepL = 0.012;
                final next = v <= cur
                    ? math.max(v, cur - maxStepL)
                    : math.min(v, cur + maxStepL);
                updateParam(
                  'volume',
                  next.clamp(IdealGasRef.vMinL, IdealGasRef.vVisMaxL),
                );
              },
            ),
          );
        },
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          animL("容器は薄い伝熱壁で、外気（300 K）に触れているため気体も常に同じ温度に保たれます（等温過程）。一気に動かすと温度が変わってしまうので、ピストンはゆっくりしか動かせません。初期状態は 1.0 L・300 K・1013 hPa です。Auto では 1.0 L ⇄ 2.0 L のゆっくりした往復を繰り返します。", "The vessel is a thin conducting wall in contact with outside air (300 K), so the gas stays at the same temperature (isothermal process). Moving too fast would change temperature, so the piston can only move slowly. Initial state is 1.0 L, 300 K, 1013 hPa. In Auto, slowly cycles between 1.0 L ⇄ 2.0 L."),
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
          child: IsothermalAnimationWidget(
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

class IsothermalAnimationWidget extends StatefulWidget {
  final double time;
  final double volumeL;
  final double scale;

  const IsothermalAnimationWidget({
    super.key,
    required this.time,
    required this.volumeL,
    this.scale = 1.0,
  });

  @override
  State<IsothermalAnimationWidget> createState() => _IsothermalAnimationWidgetState();
}

class _IsothermalAnimationWidgetState extends State<IsothermalAnimationWidget> {
  late List<ThermodynamicParticle> particles;
  double lastTime = 0.0;
  final int particleCount = 20;
  double lastVolumeL = IdealGasRef.v0L;
  double heatFlux = 0.0; // 正: 吸熱 (膨張), 負: 放熱 (圧縮)
  final PvHistoryTracker pvHistory = PvHistoryTracker();

  static final double _vAxisMaxL = IdealGasRef.vVisMaxL * 1.05;
  static final double _pAxisMaxHPa =
      IdealGasRef.isothermalPressureHPa(IdealGasRef.vMinL) * 1.08;

  @override
  void initState() {
    super.initState();
    lastTime = widget.time;
    lastVolumeL = widget.volumeL;
    _initParticles();
    pvHistory.record(
      widget.volumeL,
      IdealGasRef.isothermalPressureHPa(widget.volumeL),
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
  void didUpdateWidget(IsothermalAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    double dt = widget.time - lastTime;
    if (dt < 0) dt = 0;
    if (dt > 0.1) dt = 0.02;

    // 体積変化から熱流を計算 (Q = W = PΔV)。L 単位なので係数を少し抑える
    final double dV = widget.volumeL - lastVolumeL;
    if (dt > 0) {
      final double velocity = dV / dt;
      heatFlux = (heatFlux * 0.8) + (velocity * 0.2 * 8.0);
    }
    heatFlux *= 0.95;
    if (heatFlux.abs() < 0.01) heatFlux = 0.0;

    // 等温なので T=300K 固定
    for (var p in particles) {
      p.update(dt, 1.0);
    }
    pvHistory.record(
      widget.volumeL,
      IdealGasRef.isothermalPressureHPa(widget.volumeL),
    );
    lastTime = widget.time;
    lastVolumeL = widget.volumeL;
  }

  @override
  Widget build(BuildContext context) {
    final double volumeL = widget.volumeL;
    final double pressureHPa = IdealGasRef.isothermalPressureHPa(volumeL);
    const double temperatureK = IdealGasRef.t0K;
    final double cylinderVolume = IdealGasRef.cylinderVolumeFromVL(volumeL);

    return Column(
      children: [
        Expanded(
          flex: 9,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomPaint(
              size: Size.infinite,
              painter: IsothermalPVPainter(
                volumeL: volumeL,
                pressureHPa: pressureHPa,
                temperatureK: temperatureK,
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
                    temperature: temperatureK,
                    // 薄い伝熱壁で外気と接触 → 常に外気温＝等温。電熱線なし
                    showHeater: false,
                    wallColor: Colors.grey,
                    wallThickness: 4.0,
                    // 体積変化に応じて外気との熱交換を可視化
                    heatFlux: heatFlux,
                    cylinderWidthFactor: 0.233,
                    cylinderHeightFactor: 0.66,
                    personFeetPos: const Offset(0, 0),
                  ),
                ),
                buildGasStateHud(
                  volumeL: volumeL,
                  pressureHPa: pressureHPa,
                  temperatureK: temperatureK,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: buildAmbientTpLabels(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class IsothermalPVPainter extends BasePVPainter {
  IsothermalPVPainter({
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
          volumeUnit: 'L',
          pressureUnit: 'hPa',
          history: history,
        );

  @override
  void drawExtraCurves(Canvas canvas, Size size, double padding, double w, double h) {
    final double vMax = volumeAxisMax;
    final double pMax = pressureAxisMax;
    final curvePath = Path();
    bool started = false;
    for (double vL = IdealGasRef.vMinL; vL <= IdealGasRef.vVisMaxL; vL += 0.02) {
      final double p = IdealGasRef.isothermalPressureHPa(vL);
      final double x = padding + (vL / vMax) * w;
      final double y = size.height - padding - (p / pMax) * h;
      if (y < padding || y > size.height - padding) continue;
      if (!started) {
        curvePath.moveTo(x, y);
        started = true;
      } else {
        curvePath.lineTo(x, y);
      }
    }
    canvas.drawPath(
      curvePath,
      Paint()
        ..color = Colors.blue.withOpacity(0.3)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke,
    );
  }
}
