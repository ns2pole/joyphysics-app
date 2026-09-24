import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/energy_gauge.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// 実験室のばねとおもり。自然長から右へずらして放す水平ばね。摩擦なし。
const double kHorizontalSpringEll = 0.40;
const double kHorizontalSpringAmplitude = 0.10;
const double kSpringMinM = 0.10;
const double kSpringMaxM = 0.30;
const double kSpringDefaultM = 0.20;
const double kSpringMinK = 10.0;
const double kSpringMaxK = 25.0;
const double kSpringDefaultK = 16.0;
const double kVerticalSpringEll = 0.35;
const double kVerticalSpringMinG = 0.0;
const double kVerticalSpringMaxG = 9.8;
const double kVerticalSpringDefaultG = 9.8;

/// 初速度。水平は右が正、鉛直は下が正。0 で静かに放す。
const double kSpringMinV0 = -3.0;
const double kSpringMaxV0 = 3.0;
const double kSpringDefaultV0 = 0.0;

/// 水平ばねの初期位置。つりあい（自然長）から右が正。
const double kHorizontalSpringMinX0 = -0.20;
const double kHorizontalSpringMaxX0 = 0.25;
const double kHorizontalSpringDefaultX0 = kHorizontalSpringAmplitude;

/// 鉛直ばねの初期位置。天井から下向き。初期値は自然長。
const double kVerticalSpringMinY0 = 0.15;
const double kVerticalSpringMaxY0 = 0.75;
const double kVerticalSpringDefaultY0 = kVerticalSpringEll;

double springOmega(double m, double k) => math.sqrt(k / m);

double springPeriod(double m, double k) => 2 * math.pi * math.sqrt(m / k);

class HorizontalSpringParams {
  const HorizontalSpringParams({
    required this.m,
    required this.k,
    this.x0 = kHorizontalSpringDefaultX0,
    this.v0 = kSpringDefaultV0,
  });

  final double m;
  final double k;

  /// つりあいからの初期位置。右向き正。
  final double x0;

  /// 右向き正。
  final double v0;

  double get omega => springOmega(m, k);
  double get period => springPeriod(m, k);

  factory HorizontalSpringParams.fromMap(Map<String, double> params) {
    return HorizontalSpringParams(
      m: params['m']!.clamp(kSpringMinM, kSpringMaxM).toDouble(),
      k: params['k']!.clamp(kSpringMinK, kSpringMaxK).toDouble(),
      x0: (params['x0'] ?? kHorizontalSpringDefaultX0)
          .clamp(kHorizontalSpringMinX0, kHorizontalSpringMaxX0)
          .toDouble(),
      v0: (params['v0'] ?? kSpringDefaultV0)
          .clamp(kSpringMinV0, kSpringMaxV0)
          .toDouble(),
    );
  }
}

class VerticalSpringParams {
  const VerticalSpringParams({
    required this.m,
    required this.k,
    required this.g,
    this.y0 = kVerticalSpringDefaultY0,
    this.v0 = kSpringDefaultV0,
  });

  final double m;
  final double k;
  final double g;

  /// 天井から下向きの初期位置。
  final double y0;

  /// 下向き正。
  final double v0;

  double get omega => springOmega(m, k);
  double get period => springPeriod(m, k);

  /// つりあいの伸び $\delta=mg/k$。下向き正。
  double get delta => m * g / k;

  /// つりあいの位置。天井から下向き。
  double get yEq => kVerticalSpringEll + delta;

  /// つりあいからの初期変位。下向き正。
  double get xi0 => y0 - yEq;

  factory VerticalSpringParams.fromMap(Map<String, double> params) {
    return VerticalSpringParams(
      m: params['m']!.clamp(kSpringMinM, kSpringMaxM).toDouble(),
      k: params['k']!.clamp(kSpringMinK, kSpringMaxK).toDouble(),
      g: params['g']!.clamp(kVerticalSpringMinG, kVerticalSpringMaxG).toDouble(),
      y0: (params['y0'] ?? kVerticalSpringDefaultY0)
          .clamp(kVerticalSpringMinY0, kVerticalSpringMaxY0)
          .toDouble(),
      v0: (params['v0'] ?? kSpringDefaultV0)
          .clamp(kSpringMinV0, kSpringMaxV0)
          .toDouble(),
    );
  }
}

class HorizontalSpringSample {
  const HorizontalSpringSample({
    required this.t,
    required this.xi,
    required this.v,
    required this.a,
  });

  final double t;

  /// つりあいからの変位。右向き正。
  final double xi;
  final double v;
  final double a;

  double get x => kHorizontalSpringEll + xi;
}

class VerticalSpringSample {
  const VerticalSpringSample({
    required this.t,
    required this.y,
    required this.xi,
    required this.v,
    required this.a,
  });

  final double t;

  /// 天井から下向きの位置。
  final double y;

  /// つりあいからの変位。下向き正。
  final double xi;
  final double v;
  final double a;

  double extensionOf(VerticalSpringParams params) => y - kVerticalSpringEll;
}

double _springEnergy(double m, double v, double k, double xi) =>
    0.5 * m * v * v + 0.5 * k * xi * xi;

EnergyLedger horizontalSpringEnergy(
  HorizontalSpringParams params,
  HorizontalSpringSample sample,
) {
  return EnergyLedger(
    kinetic: 0.5 * params.m * sample.v * sample.v,
    potential: 0.5 * params.k * sample.xi * sample.xi,
    dissipated: 0,
    scale: _springEnergy(
      params.m,
      params.v0,
      params.k,
      params.x0,
    ),
    potentialLabel: kLabelElastic,
  );
}

EnergyLedger verticalSpringEnergy(
  VerticalSpringParams params,
  VerticalSpringSample sample,
) {
  return EnergyLedger(
    kinetic: 0.5 * params.m * sample.v * sample.v,
    potential: 0.5 * params.k * sample.xi * sample.xi,
    dissipated: 0,
    scale: _springEnergy(params.m, params.v0, params.k, params.xi0),
    potentialLabel: kLabelElastic,
  );
}

/// つりあいからの振幅。$\displaystyle \sqrt{\xi_0^{2}+(v_0/\omega)^{2}}$。
double springMotionAmplitude(double xi0, double v0, double omega) {
  final phase = v0 / omega;
  return math.sqrt(xi0 * xi0 + phase * phase);
}

/// つりあいから $x_0$ の位置で初速度 $v_0$。右向き正。
/// $\displaystyle \xi=x_0\cos\omega t+\frac{v_0}{\omega}\sin\omega t$。
HorizontalSpringSample horizontalSpringAt(HorizontalSpringParams params, double t) {
  final time = math.max(0.0, t);
  final w = params.omega;
  final x0 = params.x0;
  final v0 = params.v0;
  final xi = x0 * math.cos(w * time) + (v0 / w) * math.sin(w * time);
  return HorizontalSpringSample(
    t: time,
    xi: xi,
    v: -x0 * w * math.sin(w * time) + v0 * math.cos(w * time),
    a: -w * w * xi,
  );
}

/// 天井から $y_0$ で初速度 $v_0$。下向き正。周期は $g$ にも初期条件にもよらない。
/// $\displaystyle y=y_{\mathrm{eq}}+(y_0-y_{\mathrm{eq}})\cos\omega t+\frac{v_0}{\omega}\sin\omega t$。
VerticalSpringSample verticalSpringAt(VerticalSpringParams params, double t) {
  final time = math.max(0.0, t);
  final w = params.omega;
  final xi0 = params.xi0;
  final v0 = params.v0;
  final xi = xi0 * math.cos(w * time) + (v0 / w) * math.sin(w * time);
  return VerticalSpringSample(
    t: time,
    y: params.yEq + xi,
    xi: xi,
    v: -xi0 * w * math.sin(w * time) + v0 * math.cos(w * time),
    a: -w * w * xi,
  );
}

/// 速度の数値と向き。ほぼ 0 のときは向きを付けない。
String springVelocityReadout(double v, {required bool downwardPositive}) {
  final n = v.toStringAsFixed(2);
  if (v.abs() < 0.005) return n;
  final dir = downwardPositive ? (v > 0 ? '下' : '上') : (v > 0 ? '右' : '左');
  return '$n $dir';
}

const String kHorizontalSpringCaption =
    '初期位置はつりあい（自然長）から。右が正、左が負。初速度も右が正。\n'
    'どちらも 0 なら、つりあいで止めたまま。つりあいではばねの力は 0。';

const String kVerticalSpringCaption =
    '初期位置は天井からの距離。初速度は下が正。周期は m と k だけ。\n'
    '自然長から静かに放すと、つりあい mg/k の上下に振れる。';

final horizontalSpring1D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '水平バネ',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>なめらかな水平面では、働く力はばねの力だけです。つりあい（自然長）からの変位を $x$ とすると</p>
  <p>$$\displaystyle m\ddot x=-kx,\quad \omega=\sqrt{\frac{k}{m}}$$</p>
  <p>つりあいから初期位置 $x_0$、初速度 $v_0$ で放すと、右向きを正にして</p>
  <p>$$\displaystyle x=x_0\cos\omega t+\frac{v_0}{\omega}\sin\omega t$$</p>
  <p>周期は初期位置にも初速度にもよりません。</p>
  <p>$$\displaystyle T=2\pi\sqrt{\frac{m}{k}}$$</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: HorizontalSpring1DSimulation(),
      height: 900,
    ),
  ],
);

final verticalSpring1D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '鉛直バネ',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>鉛直に吊るしたばねは、自然長より $\displaystyle \delta=\frac{mg}{k}$ だけ下がった位置でつりあいます。つりあいからの変位を $x$ とすると</p>
  <p>$$\displaystyle m\ddot x=-kx,\quad \omega=\sqrt{\frac{k}{m}}$$</p>
  <p>重力はつりあいの位置をずらすだけで、周期には入りません。</p>
  <p>$$\displaystyle T=2\pi\sqrt{\frac{m}{k}}$$</p>
  <p>天井から $y_0$ の位置で初速度 $v_0$ を与えると、つりあい $\displaystyle y_{\mathrm{eq}}=\ell+\delta$ から下向きを正にして</p>
  <p>$$\displaystyle y=y_{\mathrm{eq}}+(y_0-y_{\mathrm{eq}})\cos\omega t+\frac{v_0}{\omega}\sin\omega t$$</p>
  <p>自然長 $y_0=\ell$ から静かに放すと、振幅は $\delta$ そのものです。</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: VerticalSpring1DSimulation(),
      height: 1040,
    ),
  ],
);

class HorizontalSpring1DSimulation extends PhysicsSimulation {
  HorizontalSpring1DSimulation()
      : super(
          title: '水平バネ',
          formula: const FormulaDisplay(
            r'\displaystyle x=x_0\cos\omega t+\frac{v_0}{\omega}\sin\omega t',
          ),
          aspectRatio: 16 / 10,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> simTime = ValueNotifier(0.0);

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    simTime.value += dt * _playback;
  });

  ValueNotifier<bool> get running => _loop.running;

  Map<String, double> _latestParams = {};

  static const double _playback = 0.45;

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'm': kSpringDefaultM,
        'k': kSpringDefaultK,
        'x0': kHorizontalSpringDefaultX0,
        'v0': kSpringDefaultV0,
      };

  HorizontalSpringParams get _params {
    if (_latestParams.isEmpty) {
      return HorizontalSpringParams.fromMap(initialParameters);
    }
    return HorizontalSpringParams.fromMap(_latestParams);
  }

  void _rememberParams(Map<String, double> params) {
    _latestParams = Map<String, double>.from(params);
  }

  void start() {
    if (running.value) return;
    _loop.start();
  }

  void pause() => _loop.pause();

  void resetMotion() {
    _loop.reset();
    simTime.value = 0.0;
  }

  @override
  Widget? buildFormulaOverlay(Map<String, double> parameters) {
    _rememberParams(parameters);
    return const FormulaDisplay(
      r'\displaystyle x=x_0\cos\omega t+\frac{v_0}{\omega}\sin\omega t',
    );
  }

  @override
  Widget? buildExtraControls(
    BuildContext context,
    Set<String> activeIds,
    void Function(Set<String> ids) updateActiveIds,
  ) {
    return ValueListenableBuilder<bool>(
      valueListenable: running,
      builder: (context, isRunning, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              kHorizontalSpringCaption,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Color(0xFF546E7A),
              ),
            ),
            const SizedBox(height: 8),
            PlayPauseResetButtons(
              playing: isRunning,
              onPlayPause: isRunning ? pause : start,
              onReset: resetMotion,
            ),
          ],
        );
      },
    );
  }

  @override
  List<Widget> buildControls(
    BuildContext context,
    Map<String, double> parameters,
    void Function(String key, double value) updateParam,
  ) {
    _rememberParams(parameters);
    final p = _params;
    return [
      const Text(
        '質量・ばね・初期位置・初速度（右が正）',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _SpringSlider(
        label: 'm',
        value: p.m,
        min: kSpringMinM,
        max: kSpringMaxM,
        onChanged: (v) => updateParam('m', v),
        semanticLabel: '質量 m',
      ),
      _SpringSlider(
        label: 'k',
        value: p.k,
        min: kSpringMinK,
        max: kSpringMaxK,
        onChanged: (v) => updateParam('k', v),
        semanticLabel: 'ばね定数 k',
      ),
      _SpringSlider(
        label: 'x0',
        value: p.x0,
        min: kHorizontalSpringMinX0,
        max: kHorizontalSpringMaxX0,
        onChanged: (v) => updateParam('x0', v),
        semanticLabel: '初期位置 右が正',
        readout: springVelocityReadout(p.x0, downwardPositive: false),
      ),
      _SpringSlider(
        label: 'v0',
        value: p.v0,
        min: kSpringMinV0,
        max: kSpringMaxV0,
        onChanged: (v) => updateParam('v0', v),
        semanticLabel: '初速度 右が正',
        readout: springVelocityReadout(p.v0, downwardPositive: false),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'ω = ${p.omega.toStringAsFixed(2)} rad/s    '
          'T = ${p.period.toStringAsFixed(2)} s',
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Courier',
            color: Color(0xFF37474F),
          ),
        ),
      ),
    ];
  }

  @override
  Widget buildAnimation(
    BuildContext context,
    double time,
    double azimuth,
    double tilt,
    double scale,
    Map<String, double> parameters,
    Set<String> activeIds,
  ) {
    _rememberParams(parameters);
    return AnimatedBuilder(
      animation: Listenable.merge([running, simTime]),
      builder: (context, _) {
        final p = HorizontalSpringParams.fromMap(parameters);
        final t = simTime.value;
        final sample = horizontalSpringAt(p, t);
        return CustomPaint(
          size: Size.infinite,
          painter: _HorizontalSpringPainter(
            params: p,
            sample: sample,
            running: running.value,
          ),
        );
      },
    );
  }
}

class VerticalSpring1DSimulation extends PhysicsSimulation {
  VerticalSpring1DSimulation()
      : super(
          title: '鉛直バネ',
          formula: const FormulaDisplay(
            r'\displaystyle y=y_{\mathrm{eq}}+(y_0-y_{\mathrm{eq}})\cos\omega t+\frac{v_0}{\omega}\sin\omega t',
          ),
          aspectRatio: 4 / 5,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> simTime = ValueNotifier(0.0);

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    simTime.value += dt * _playback;
  });

  ValueNotifier<bool> get running => _loop.running;

  Map<String, double> _latestParams = {};

  static const double _playback = 0.45;

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'm': kSpringDefaultM,
        'k': kSpringDefaultK,
        'g': kVerticalSpringDefaultG,
        'y0': kVerticalSpringDefaultY0,
        'v0': kSpringDefaultV0,
      };

  VerticalSpringParams get _params {
    if (_latestParams.isEmpty) {
      return VerticalSpringParams.fromMap(initialParameters);
    }
    return VerticalSpringParams.fromMap(_latestParams);
  }

  void _rememberParams(Map<String, double> params) {
    _latestParams = Map<String, double>.from(params);
  }

  void start() {
    if (running.value) return;
    _loop.start();
  }

  void pause() => _loop.pause();

  void resetMotion() {
    _loop.reset();
    simTime.value = 0.0;
  }

  @override
  Widget? buildFormulaOverlay(Map<String, double> parameters) {
    _rememberParams(parameters);
    return const FormulaDisplay(
      r'\displaystyle y=y_{\mathrm{eq}}+(y_0-y_{\mathrm{eq}})\cos\omega t+\frac{v_0}{\omega}\sin\omega t',
    );
  }

  @override
  Widget? buildExtraControls(
    BuildContext context,
    Set<String> activeIds,
    void Function(Set<String> ids) updateActiveIds,
  ) {
    return ValueListenableBuilder<bool>(
      valueListenable: running,
      builder: (context, isRunning, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              kVerticalSpringCaption,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Color(0xFF546E7A),
              ),
            ),
            const SizedBox(height: 8),
            PlayPauseResetButtons(
              playing: isRunning,
              onPlayPause: isRunning ? pause : start,
              onReset: resetMotion,
            ),
          ],
        );
      },
    );
  }

  @override
  List<Widget> buildControls(
    BuildContext context,
    Map<String, double> parameters,
    void Function(String key, double value) updateParam,
  ) {
    _rememberParams(parameters);
    final p = _params;
    return [
      const Text(
        '質量・ばね・重力・初期位置・初速度（下が正）',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _SpringSlider(
        label: 'm',
        value: p.m,
        min: kSpringMinM,
        max: kSpringMaxM,
        onChanged: (v) => updateParam('m', v),
        semanticLabel: '質量 m',
      ),
      _SpringSlider(
        label: 'k',
        value: p.k,
        min: kSpringMinK,
        max: kSpringMaxK,
        onChanged: (v) => updateParam('k', v),
        semanticLabel: 'ばね定数 k',
      ),
      _SpringSlider(
        label: 'g',
        value: p.g,
        min: kVerticalSpringMinG,
        max: kVerticalSpringMaxG,
        onChanged: (v) => updateParam('g', v),
        semanticLabel: '重力加速度 g',
      ),
      _SpringSlider(
        label: 'y0',
        value: p.y0,
        min: kVerticalSpringMinY0,
        max: kVerticalSpringMaxY0,
        onChanged: (v) => updateParam('y0', v),
        semanticLabel: '初期位置 天井から下',
      ),
      _SpringSlider(
        label: 'v0',
        value: p.v0,
        min: kSpringMinV0,
        max: kSpringMaxV0,
        onChanged: (v) => updateParam('v0', v),
        semanticLabel: '初速度 下が正',
        readout: springVelocityReadout(p.v0, downwardPositive: true),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'δ = ${p.delta.toStringAsFixed(2)} m    '
          'T = ${p.period.toStringAsFixed(2)} s',
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Courier',
            color: Color(0xFF37474F),
          ),
        ),
      ),
    ];
  }

  @override
  Widget buildAnimation(
    BuildContext context,
    double time,
    double azimuth,
    double tilt,
    double scale,
    Map<String, double> parameters,
    Set<String> activeIds,
  ) {
    _rememberParams(parameters);
    return AnimatedBuilder(
      animation: Listenable.merge([running, simTime]),
      builder: (context, _) {
        final p = VerticalSpringParams.fromMap(parameters);
        final t = simTime.value;
        final sample = verticalSpringAt(p, t);
        return CustomPaint(
          size: Size.infinite,
          painter: _VerticalSpringPainter(
            params: p,
            sample: sample,
            running: running.value,
          ),
        );
      },
    );
  }
}

class _SpringSlider extends StatelessWidget {
  const _SpringSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.semanticLabel,
    this.readout,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String semanticLabel;
  final String? readout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Semantics(
            label: semanticLabel,
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
              semanticFormatterCallback: (v) =>
                  '$semanticLabel ${v.toStringAsFixed(2)}',
            ),
          ),
        ),
        SizedBox(
          width: readout == null ? 44 : 72,
          child: Text(
            readout ?? value.toStringAsFixed(2),
            style: const TextStyle(fontSize: 12, fontFamily: 'Courier'),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

double _sliderT(double value, double min, double max) =>
    ((value - min) / (max - min)).clamp(0.0, 1.0);

/// スライダーの端で大きさがはっきり変わるように、質量を半径へ線形に対応させる。
double springMassRadius(double m) => 11 + 16 * _sliderT(m, kSpringMinM, kSpringMaxM);

double springWireWidth(double k) => 1.15 + 3.2 * _sliderT(k, kSpringMinK, kSpringMaxK);

double springCoilAmp(double k) => 6.0 + 8.0 * _sliderT(k, kSpringMinK, kSpringMaxK);

void paintCoilSpring(Canvas canvas, Offset start, Offset end, double k) {
  final dir = end - start;
  final len = dir.distance;
  if (len < 1) return;
  final u = dir / len;
  final perp = Offset(-u.dy, u.dx);
  final paint = Paint()
    ..color = const Color(0xFF37474F)
    ..strokeWidth = springWireWidth(k)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  if (len < 8) {
    canvas.drawLine(start, end, paint);
    return;
  }
  const coils = 12;
  final amp = springCoilAmp(k);
  const loop = 0.48;
  final stubLen = math.min(10.0, len * 0.1);
  final coilStart = start + u * stubLen;
  final coilEnd = end - u * stubLen;
  final body = (coilEnd - coilStart).distance;
  final path = Path()..moveTo(start.dx, start.dy);
  path.lineTo(coilStart.dx, coilStart.dy);
  const samplesPerCoil = 16;
  final samples = coils * samplesPerCoil;
  for (var i = 1; i <= samples; i++) {
    final t = i / samples;
    final theta = t * coils * 2 * math.pi;
    final along = t * body + amp * loop * (math.cos(theta) - 1);
    final p = coilStart + u * along + perp * (amp * math.sin(theta));
    path.lineTo(p.dx, p.dy);
  }
  path.lineTo(end.dx, end.dy);
  canvas.drawPath(path, paint);
}

class _HorizontalSpringPainter extends CustomPainter {
  _HorizontalSpringPainter({
    required this.params,
    required this.sample,
    required this.running,
  });

  final HorizontalSpringParams params;
  final HorizontalSpringSample sample;
  final bool running;

  static const _bg = Color(0xFFF7FAFC);
  static const _ball = Color(0xFF1E88E5);
  static const _force = Color(0xFFEF6C00);
  static const _velocity = Color(0xFF1565C0);
  static const _worldMax = 0.95;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final hud = 't = ${sample.t.toStringAsFixed(2)} s\n'
        'x = ${sample.xi.toStringAsFixed(3)} m\n'
        'v = ${springVelocityReadout(sample.v, downwardPositive: false)} m/s\n'
        'T = ${params.period.toStringAsFixed(2)} s';
    final ceiling = dynamicsReadoutCard(
      hud,
      horizontalSpringEnergy(params, sample),
      textColumnWidth: 196,
      bounds: size,
    ).bottom;
    final railY = math.max(size.height * 0.62, ceiling + 100);
    final left = 36.0;
    final right = size.width - 16;
    final amp = springMotionAmplitude(params.x0, params.v0, params.omega);
    final xMin = math.min(0.0, kHorizontalSpringEll - amp - 0.05);
    final xMax = math.max(_worldMax, kHorizontalSpringEll + amp + 0.12);
    double sx(double x) => left + ((x - xMin) / (xMax - xMin)) * (right - left);
    final wallRight = sx(0);

    final axis = Paint()
      ..color = const Color(0xFF90A4AE)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(left, railY), Offset(right, railY), axis);

    final wall = RRect.fromRectAndRadius(
      Rect.fromLTWH(wallRight - 22, railY - 46, 22, 92),
      const Radius.circular(3),
    );
    canvas.drawRRect(wall, Paint()..color = const Color(0xFF78909C));

    _dashedV(canvas, sx(kHorizontalSpringEll), railY - 78, railY + 16, const Color(0xFFEF6C00));
    _label(
      canvas,
      'つりあい(自然長)',
      sx(kHorizontalSpringEll),
      railY - 92,
      const Color(0xFFEF6C00),
      center: true,
    );

    final mass = Offset(sx(sample.x), railY);
    final r = springMassRadius(params.m);
    paintCoilSpring(canvas, Offset(wallRight, railY), mass - Offset(r, 0), params.k);
    _mass(canvas, mass, r, _ball, 'm');

    final vMax = math.max(amp * params.omega, 1e-6);
    final fMax = math.max(params.k * amp, 1e-6);
    _arrow(
      canvas,
      mass + const Offset(0, -46),
      sample.v / vMax * 70,
      _velocity,
    );
    _arrow(
      canvas,
      mass + const Offset(0, -68),
      (-params.k * sample.xi) / fMax * 70,
      _force,
    );
    _label(canvas, 'v', mass.dx - 18, railY - 58, _velocity);
    _label(canvas, 'F', mass.dx - 18, railY - 80, _force);
    _hud(canvas, hud, horizontalSpringEnergy(params, sample));
  }

  @override
  bool shouldRepaint(covariant _HorizontalSpringPainter oldDelegate) {
    return oldDelegate.sample.t != sample.t ||
        oldDelegate.sample.xi != sample.xi ||
        oldDelegate.sample.v != sample.v ||
        oldDelegate.params.m != params.m ||
        oldDelegate.params.k != params.k ||
        oldDelegate.params.x0 != params.x0 ||
        oldDelegate.params.v0 != params.v0 ||
        oldDelegate.running != running;
  }
}

class _VerticalSpringPainter extends CustomPainter {
  _VerticalSpringPainter({
    required this.params,
    required this.sample,
    required this.running,
  });

  final VerticalSpringParams params;
  final VerticalSpringSample sample;
  final bool running;

  static const _bg = Color(0xFFF7FAFC);
  static const _ball = Color(0xFF1E88E5);
  static const _gravity = Color(0xFFEF6C00);
  static const _springForce = Color(0xFF00897B);
  static const _velocity = Color(0xFF1565C0);
  static const _eq = Color(0xFFEF6C00);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final hud = 't = ${sample.t.toStringAsFixed(2)} s\n'
        'y = ${sample.y.toStringAsFixed(3)} m\n'
        'v = ${springVelocityReadout(sample.v, downwardPositive: true)} m/s\n'
        'δ = ${params.delta.toStringAsFixed(3)} m\n'
        'T = ${params.period.toStringAsFixed(2)} s';
    final ceiling = dynamicsReadoutCard(
      hud,
      verticalSpringEnergy(params, sample),
      textColumnWidth: 196,
      bounds: size,
    ).bottom;
    final top = ceiling + 8;
    final bottom = size.height - 24;
    final amp = springMotionAmplitude(params.xi0, params.v0, params.omega);
    final yTop = math.min(0.0, params.yEq - amp - 0.04);
    final yMax = math.max(params.yEq + amp + 0.12, 0.70);
    final hang = top + 16;
    double sy(double y) => hang + ((y - yTop) / (yMax - yTop)) * (bottom - hang);
    final cx = size.width * 0.42;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 70, top, 140, 16),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF78909C),
    );

    _dashedH(canvas, 24, size.width - 24, sy(kVerticalSpringEll), const Color(0xFF90A4AE));
    _label(canvas, '自然長', 28, sy(kVerticalSpringEll) - 16, const Color(0xFF607D8B));

    final yEq = kVerticalSpringEll + params.delta;
    _dashedH(canvas, 24, size.width - 24, sy(yEq), _eq);
    _label(canvas, 'つりあい', size.width - 78, sy(yEq) - 16, _eq);

    final r = springMassRadius(params.m);
    final mass = Offset(cx, sy(sample.y));
    paintCoilSpring(canvas, Offset(cx, hang), mass - Offset(0, r), params.k);
    _mass(canvas, mass, r, _ball, 'm');

    final extension = sample.extensionOf(params);
    final springF = params.k * extension;
    const pxPerWeight = 46.0;
    final weightScale = params.m * kVerticalSpringDefaultG;
    final gravLen = params.g / kVerticalSpringDefaultG * pxPerWeight;
    final springLen = springF.abs() / weightScale * pxPerWeight;
    final origin = mass + Offset(r + 18, 0);
    final vMax = math.max(amp * params.omega, 1e-6);
    _arrowY(
      canvas,
      mass + Offset(-r - 16, 0),
      sample.v / vMax * 64,
      _velocity,
    );
    _label(canvas, 'v', mass.dx - r - 36, mass.dy - 18, _velocity);
    _arrowDown(canvas, origin, gravLen, _gravity);
    if (extension >= 0) {
      _arrowUp(canvas, origin + const Offset(22, 0), springLen, _springForce);
    } else {
      _arrowDown(canvas, origin + const Offset(22, 0), springLen, _springForce);
    }
    _label(canvas, 'mg', origin.dx - 8, origin.dy + gravLen + 4, _gravity);
    _label(
      canvas,
      'kx',
      origin.dx + 10,
      extension >= 0 ? origin.dy - springLen - 16 : origin.dy + springLen + 4,
      _springForce,
    );

    _hud(canvas, hud, verticalSpringEnergy(params, sample));
  }

  @override
  bool shouldRepaint(covariant _VerticalSpringPainter oldDelegate) {
    return oldDelegate.sample.t != sample.t ||
        oldDelegate.sample.y != sample.y ||
        oldDelegate.sample.v != sample.v ||
        oldDelegate.params.m != params.m ||
        oldDelegate.params.k != params.k ||
        oldDelegate.params.g != params.g ||
        oldDelegate.params.y0 != params.y0 ||
        oldDelegate.params.v0 != params.v0 ||
        oldDelegate.running != running;
  }
}

void _mass(Canvas canvas, Offset c, double r, Color color, String label) {
  canvas.drawCircle(
    c.translate(1.5, 2),
    r,
    Paint()..color = Colors.black.withValues(alpha: 0.12),
  );
  canvas.drawCircle(c, r, Paint()..color = color);
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2,
  );
  final tp = TextPainter(
    text: TextSpan(
      text: label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2));
}

void _label(
  Canvas canvas,
  String text,
  double x,
  double y,
  Color color, {
  bool center = false,
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(canvas, Offset(center ? x - tp.width / 2 : x, y));
}

void _arrow(Canvas canvas, Offset origin, double dx, Color color) {
  if (dx.abs() < 2) return;
  final end = origin.translate(dx, 0);
  final paint = Paint()
    ..color = color
    ..strokeWidth = 2.4
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(origin, end, paint);
  final sign = dx >= 0 ? 1.0 : -1.0;
  canvas.drawPath(
    Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(end.dx - 8 * sign, end.dy - 4)
      ..lineTo(end.dx - 8 * sign, end.dy + 4)
      ..close(),
    Paint()..color = color,
  );
}

void _arrowY(Canvas canvas, Offset origin, double dy, Color color) {
  if (dy.abs() < 2) return;
  final end = origin.translate(0, dy);
  final paint = Paint()
    ..color = color
    ..strokeWidth = 2.4
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(origin, end, paint);
  final sign = dy >= 0 ? 1.0 : -1.0;
  canvas.drawPath(
    Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(end.dx - 4, end.dy - 8 * sign)
      ..lineTo(end.dx + 4, end.dy - 8 * sign)
      ..close(),
    Paint()..color = color,
  );
}

void _arrowDown(Canvas canvas, Offset origin, double len, Color color) {
  if (len < 2) return;
  final end = origin.translate(0, len);
  final paint = Paint()
    ..color = color
    ..strokeWidth = 2.4
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(origin, end, paint);
  canvas.drawPath(
    Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(end.dx - 4, end.dy - 8)
      ..lineTo(end.dx + 4, end.dy - 8)
      ..close(),
    Paint()..color = color,
  );
}

void _arrowUp(Canvas canvas, Offset origin, double len, Color color) {
  if (len < 2) return;
  final end = origin.translate(0, -len);
  final paint = Paint()
    ..color = color
    ..strokeWidth = 2.4
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(origin, end, paint);
  canvas.drawPath(
    Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(end.dx - 4, end.dy + 8)
      ..lineTo(end.dx + 4, end.dy + 8)
      ..close(),
    Paint()..color = color,
  );
}

void _dashedV(Canvas canvas, double x, double y0, double y1, Color color) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = 1.4;
  var y = y0;
  while (y < y1) {
    canvas.drawLine(Offset(x, y), Offset(x, math.min(y + 6, y1)), paint);
    y += 10;
  }
}

void _dashedH(Canvas canvas, double x0, double x1, double y, Color color) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = 1.4;
  var x = x0;
  while (x < x1) {
    canvas.drawLine(Offset(x, y), Offset(math.min(x + 6, x1), y), paint);
    x += 10;
  }
}

void _hud(Canvas canvas, String text, EnergyLedger ledger) {
  paintDynamicsReadout(canvas, text, ledger, textColumnWidth: 196);
}
