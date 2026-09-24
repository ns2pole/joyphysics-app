import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/energy_gauge.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';
import 'projectileMotion2D.dart';

/// 上向き正。$g=9.8\,\mathrm{m/s^2}$ 固定。地面で $v'=-ev$。
const double kBounceG = 9.8;
const double kBounceMinH = 0.5;
const double kBounceMaxH = 6.0;
const double kBounceDefaultH = 3.0;
const double kBounceMinV = 4.0;
const double kBounceMaxV = 12.0;
const double kBounceDefaultV = 8.0;
const double kBounceMinE = 0.0;
const double kBounceMaxE = 1.0;
const double kBounceDefaultE = 0.8;
const double kBounceMinDeg = -75.0;
const double kBounceMaxDeg = 75.0;
const double kBounceDefaultDeg = 45.0;
const double kBounceMinV0 = 6.0;
const double kBounceMaxV0 = 16.0;
const double kBounceDefaultV0 = 12.0;
const int kBounceMaxBounces = 100;
const double kBounceRestSpeed = 0.15;
const double kBounceStrobeDt = 0.10;

enum Bounce1DKind { freeFall, throwUp, throwDown }

class BounceLeg {
  const BounceLeg({
    required this.t0,
    required this.x0,
    required this.y0,
    required this.vx,
    required this.vy0,
    required this.dt,
  });

  final double t0;
  final double x0;
  final double y0;
  final double vx;
  final double vy0;
  final double dt;

  double get t1 => t0 + dt;
}

class BounceSample {
  const BounceSample({
    required this.t,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.bounces,
    required this.resting,
  });

  final double t;
  final double x;
  final double y;
  final double vx;
  final double vy;
  final int bounces;
  final bool resting;
}

/// 質量 1 kg。地面を基準にした力学的エネルギー。
double bounceMechanical(double y, double vx, double vy) {
  return 0.5 * (vx * vx + vy * vy) + kBounceG * math.max(0.0, y);
}

/// 跳ね返るたびに減った分を熱にする。$e=1$ では熱は増えない。
EnergyLedger bounceEnergy({
  required double y,
  required double vx,
  required double vy,
  required double initial,
}) {
  final kinetic = 0.5 * (vx * vx + vy * vy);
  final potential = kBounceG * math.max(0.0, y);
  final heat = math.max(0.0, initial - kinetic - potential);
  return EnergyLedger(
    kinetic: kinetic,
    potential: potential,
    dissipated: heat,
    scale: math.max(0.0, initial),
    legendHeat: heat > 1e-6,
    potentialLabel: kLabelGravity,
  );
}

double bounceFlightTime(double y, double vy, {double g = kBounceG}) {
  final disc = math.max(0.0, vy * vy + 2 * g * math.max(0.0, y));
  return (vy + math.sqrt(disc)) / g;
}

List<BounceLeg> bounceLegs({
  required double y0,
  required double vy0,
  required double e,
  double x0 = 0,
  double vx = 0,
  double g = kBounceG,
}) {
  final legs = <BounceLeg>[];
  var t = 0.0;
  var y = math.max(0.0, y0);
  var vy = vy0;
  var x = x0;
  final restitution = e.clamp(0.0, 1.0).toDouble();
  for (var n = 0; n < kBounceMaxBounces; n++) {
    if (y <= 1e-8 && vy <= kBounceRestSpeed) break;
    final dt = bounceFlightTime(y, vy, g: g);
    if (dt < 1e-6) break;
    legs.add(BounceLeg(t0: t, x0: x, y0: y, vx: vx, vy0: vy, dt: dt));
    final impact = vy - g * dt;
    x += vx * dt;
    y = 0;
    vy = -restitution * impact;
    t += dt;
    if (vy <= kBounceRestSpeed) break;
  }
  return legs;
}

double bounceDuration(List<BounceLeg> legs) {
  if (legs.isEmpty) return 0;
  return legs.last.t1;
}

BounceSample bounceAt(List<BounceLeg> legs, double t, {double g = kBounceG}) {
  if (legs.isEmpty) {
    return const BounceSample(
      t: 0,
      x: 0,
      y: 0,
      vx: 0,
      vy: 0,
      bounces: 0,
      resting: true,
    );
  }
  final time = math.max(0.0, t);
  if (time >= bounceDuration(legs) - 1e-9) {
    final last = legs.last;
    return BounceSample(
      t: last.t1,
      x: last.x0 + last.vx * last.dt,
      y: 0,
      vx: last.vx,
      vy: 0,
      bounces: legs.length,
      resting: true,
    );
  }
  var index = 0;
  for (var i = 0; i < legs.length; i++) {
    if (time < legs[i].t1) {
      index = i;
      break;
    }
  }
  final leg = legs[index];
  final local = time - leg.t0;
  final y = leg.y0 + leg.vy0 * local - 0.5 * g * local * local;
  return BounceSample(
    t: time,
    x: leg.x0 + leg.vx * local,
    y: math.max(0.0, y),
    vx: leg.vx,
    vy: leg.vy0 - g * local,
    bounces: index,
    resting: false,
  );
}

List<BounceSample> bounceStrobe(
  List<BounceLeg> legs,
  double t, {
  double dt = kBounceStrobeDt,
  double g = kBounceG,
}) {
  if (t <= 1e-9) return const [];
  final samples = <BounceSample>[];
  for (var ti = dt; ti < t - 1e-9; ti += dt) {
    samples.add(bounceAt(legs, ti, g: g));
  }
  return samples;
}

double bounce1DReleaseY(Bounce1DKind kind, double h) => h;

double bounce1DReleaseV(Bounce1DKind kind, double v) {
  switch (kind) {
    case Bounce1DKind.freeFall:
      return 0;
    case Bounce1DKind.throwUp:
      return v;
    case Bounce1DKind.throwDown:
      return -v;
  }
}

List<BounceLeg> bounce1DLegs(Bounce1DKind kind, double h, double v, double e) {
  return bounceLegs(
    y0: bounce1DReleaseY(kind, h),
    vy0: bounce1DReleaseV(kind, v),
    e: e,
  );
}

List<BounceLeg> bounce2DLegs(double deg, double v0, double e, {double h = 0}) {
  final rad = deg * math.pi / 180.0;
  return bounceLegs(
    y0: h,
    vy0: v0 * math.sin(rad),
    vx: v0 * math.cos(rad),
    e: e,
  );
}

String bounce1DCaption(Bounce1DKind kind) {
  switch (kind) {
    case Bounce1DKind.freeFall:
      return '高さ H から静かに放す。初速度は 0。\n'
          '落ちているあいだの加速度は g。\n'
          '跳ね返った直後の上向きの速さは、着く直前の e 倍。\n'
          '次に上がる高さは e² 倍。e = 0 なら着いたら止まり、e = 1 なら高さが戻る。';
    case Bounce1DKind.throwUp:
      return '上向きに投げる。最高点では速度は 0 でも、重力は残る。\n'
          '下降中に地面に着くと、上向きの速さは着く直前の e 倍。\n'
          '次に上がる高さは e² 倍。e = 0 なら着いたら止まり、e = 1 なら高さが戻る。';
    case Bounce1DKind.throwDown:
      return '高さ H から下向きに投げる。\n'
          '下向きの初速度があるぶん、着く直前の速さは大きい。\n'
          '跳ね返った直後の上向きの速さは、着く直前の e 倍。\n'
          '次に上がる高さは e² 倍。e = 0 なら着いたら止まり、e = 1 なら高さが戻る。';
  }
}

String bounce2DCaption() {
  return '水平速度は一定。鉛直速度だけが重力で変わる。\n'
      'θ は水平から。正は上向き、負は下向き。\n'
      '着地すると vy だけが -e 倍になる。vx はそのまま。\n'
      '山の高さは跳ねるたびに e² 倍。e = 0 なら最初の着地で止まり、e = 1 なら高さが戻る。';
}

final bounce1D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '跳ね返り1次元',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>地面に当たる直前の速度を $v$、直後を $v'$ とします。跳ね返り係数を $e$（$0\le e\le 1$）とすると</p>
  <p>$$\displaystyle v'=-ev$$</p>
  <p>自由落下で高さ $H$ から落とすと、次に上がる高さは</p>
  <p>$$\displaystyle H'=e^{2}H$$</p>
  <p>落ちているあいだの加速度は、投げ上げでも投げ下げでも下向きの $g$ のままです。</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: Bounce1DSimulation(),
      height: 920,
    ),
  ],
);

final bounce2D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '跳ね返り2次元',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>なめらかな水平な地面では、水平方向の速度は着地でも変わりません。鉛直方向だけが跳ね返り係数 $e$ で折り返します。</p>
  <p>$$\displaystyle v_x'=v_x,\quad v_y'=-ev_y$$</p>
  <p>高さ $h$ の高台から角度 $\theta$、速さ $v_0$ で投げます。$\theta$ は上向きが正、下向きが負です。地面で跳ね返ったあとの山の高さは、直前の山の $e^{2}$ 倍になります。</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: Bounce2DSimulation(),
      height: 860,
    ),
  ],
);

class Bounce1DSimulation extends PhysicsSimulation {
  Bounce1DSimulation()
      : super(
          title: '跳ね返り1次元',
          formula: const FormulaDisplay(r'\displaystyle v^{\prime}=-ev'),
          aspectRatio: 4 / 5,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> simTime = ValueNotifier(0.0);
  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    final next = math.min(_duration, simTime.value + dt * _playback);
    simTime.value = next;
    if (next >= _duration - 1e-4) _loop.pause();
  });
  ValueNotifier<bool> get running => _loop.running;

  Map<String, double> _latest = {};
  Bounce1DKind _kind = Bounce1DKind.freeFall;
  static const double _playback = 0.56;

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'h': kBounceDefaultH,
        'v': kBounceDefaultV,
        'e': kBounceDefaultE,
      };

  double get _h => (_latest['h'] ?? kBounceDefaultH).clamp(kBounceMinH, kBounceMaxH).toDouble();
  double get _v => (_latest['v'] ?? kBounceDefaultV).clamp(kBounceMinV, kBounceMaxV).toDouble();
  double get _e => (_latest['e'] ?? kBounceDefaultE).clamp(kBounceMinE, kBounceMaxE).toDouble();

  List<BounceLeg> get _legs => bounce1DLegs(_kind, _h, _v, _e);
  double get _duration => bounceDuration(_legs);

  void _remember(Map<String, double> params) {
    _latest = Map<String, double>.from(params);
  }

  void start() {
    if (running.value || _duration < 1e-4) return;
    if (simTime.value >= _duration - 1e-3) simTime.value = 0;
    _loop.start();
  }

  void pause() => _loop.pause();

  void resetMotion() {
    _loop.reset();
    simTime.value = 0;
  }

  void applyKind(Bounce1DKind kind) {
    _kind = kind;
    resetMotion();
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
            Text(
              bounce1DCaption(_kind),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF546E7A)),
            ),
            const SizedBox(height: 8),
            PlayPauseResetButtons(
              playing: isRunning,
              onPlayPause: isRunning ? pause : start,
              onReset: resetMotion,
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final kind in Bounce1DKind.values)
                  _kindButton(kind, updateActiveIds),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _kindButton(Bounce1DKind kind, void Function(Set<String> ids) updateActiveIds) {
    final label = switch (kind) {
      Bounce1DKind.freeFall => '自由落下',
      Bounce1DKind.throwUp => '鉛直投げ上げ',
      Bounce1DKind.throwDown => '鉛直投げ下げ',
    };
    final selected = _kind == kind;
    final onPressed = () {
      applyKind(kind);
      updateActiveIds({kind.name});
    };
    if (selected) return FilledButton(onPressed: onPressed, child: Text(label));
    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }

  @override
  List<Widget> buildControls(
    BuildContext context,
    Map<String, double> parameters,
    void Function(String key, double value) updateParam,
  ) {
    _remember(parameters);
    return [
      const Text('初期条件（g = 9.8 m/s²）', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      _BounceSlider(
        label: 'H',
        value: _h,
        min: kBounceMinH,
        max: kBounceMaxH,
        onChanged: (v) => updateParam('h', v),
        semanticLabel: '高さ H',
      ),
      if (_kind != Bounce1DKind.freeFall)
        _BounceSlider(
          label: 'v',
          value: _v,
          min: kBounceMinV,
          max: kBounceMaxV,
          onChanged: (v) => updateParam('v', v),
          semanticLabel: '初速度 v',
        ),
      _BounceSlider(
        label: 'e',
        value: _e,
        min: kBounceMinE,
        max: kBounceMaxE,
        onChanged: (v) => updateParam('e', v),
        semanticLabel: '跳ね返り係数 e',
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
    _remember(parameters);
    return AnimatedBuilder(
      animation: Listenable.merge([running, simTime]),
      builder: (context, _) {
        final legs = _legs;
        final duration = bounceDuration(legs);
        final t = math.min(simTime.value, duration);
        final sample = bounceAt(legs, t);
        final initial = legs.isEmpty
            ? 0.0
            : bounceMechanical(legs.first.y0, legs.first.vx, legs.first.vy0);
        return CustomPaint(
          size: Size.infinite,
          painter: _Bounce1DPainter(
            sample: sample,
            strobes: bounceStrobe(legs, sample.t),
            ceiling: math.max(_h + _v * _v / (2 * kBounceG), _h) + 0.4,
            initialEnergy: initial,
          ),
        );
      },
    );
  }
}

class Bounce2DSimulation extends PhysicsSimulation {
  Bounce2DSimulation()
      : super(
          title: '跳ね返り2次元',
          formula: const FormulaDisplay(
            r'\displaystyle v_x^{\prime}=v_x,\quad v_y^{\prime}=-ev_y',
          ),
          aspectRatio: 16 / 9,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> simTime = ValueNotifier(0.0);
  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    final next = math.min(_duration, simTime.value + dt * _playback);
    simTime.value = next;
    if (next >= _duration - 1e-4) _loop.pause();
  });
  ValueNotifier<bool> get running => _loop.running;

  Map<String, double> _latest = {};
  static const double _playback = 1.4;

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'deg': kProjectileDefaultDeg,
        'v0': kProjectileDefaultV0,
        'h': kProjectileDefaultH,
        'e': kBounceDefaultE,
      };

  double get _deg =>
      (_latest['deg'] ?? kProjectileDefaultDeg).clamp(kProjectileMinDeg, kProjectileMaxDeg).toDouble();
  double get _v0 =>
      (_latest['v0'] ?? kProjectileDefaultV0).clamp(kProjectileMinV0, kProjectileMaxV0).toDouble();
  double get _e => (_latest['e'] ?? kBounceDefaultE).clamp(kBounceMinE, kBounceMaxE).toDouble();
  double get _h =>
      (_latest['h'] ?? kProjectileDefaultH).clamp(kProjectileMinH, kProjectileMaxH).toDouble();

  List<BounceLeg> get _legs => bounce2DLegs(_deg, _v0, _e, h: _h);
  double get _duration => bounceDuration(_legs);

  void _remember(Map<String, double> params) {
    _latest = Map<String, double>.from(params);
  }

  void start() {
    if (running.value || _duration < 1e-4) return;
    if (simTime.value >= _duration - 1e-3) simTime.value = 0;
    _loop.start();
  }

  void pause() => _loop.pause();

  void resetMotion() {
    _loop.reset();
    simTime.value = 0;
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
            Text(
              bounce2DCaption(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF546E7A)),
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
    _remember(parameters);
    return [
      const Text('初期条件（g = 9.8 m/s²）', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      _BounceSlider(
        label: 'v0',
        value: _v0,
        min: kProjectileMinV0,
        max: kProjectileMaxV0,
        onChanged: (v) => updateParam('v0', v),
        semanticLabel: '初速度 v0',
      ),
      _BounceSlider(
        label: 'h',
        value: _h,
        min: kProjectileMinH,
        max: kProjectileMaxH,
        onChanged: (v) => updateParam('h', v),
        semanticLabel: '高台の高さ h',
      ),
      _BounceSlider(
        label: 'θ',
        value: _deg,
        min: kProjectileMinDeg,
        max: kProjectileMaxDeg,
        onChanged: (v) => updateParam('deg', v),
        semanticLabel: '投射角 θ',
        fractionDigits: 0,
        suffix: '°',
      ),
      _BounceSlider(
        label: 'e',
        value: _e,
        min: kBounceMinE,
        max: kBounceMaxE,
        onChanged: (v) => updateParam('e', v),
        semanticLabel: '跳ね返り係数 e',
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
    _remember(parameters);
    return AnimatedBuilder(
      animation: Listenable.merge([running, simTime]),
      builder: (context, _) {
        final legs = _legs;
        final duration = bounceDuration(legs);
        final sample = bounceAt(legs, math.min(simTime.value, duration));
        final initial = legs.isEmpty
            ? 0.0
            : bounceMechanical(legs.first.y0, legs.first.vx, legs.first.vy0);
        return CustomPaint(
          size: Size.infinite,
          painter: _Bounce2DPainter(
            sample: sample,
            strobes: bounceStrobe(legs, sample.t),
            legs: legs,
            platformH: _h,
            initialEnergy: initial,
          ),
        );
      },
    );
  }
}

class _BounceSlider extends StatelessWidget {
  const _BounceSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.semanticLabel,
    this.fractionDigits = 2,
    this.suffix = '',
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String semanticLabel;
  final int fractionDigits;
  final String suffix;

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
            ),
          ),
        ),
        SizedBox(
          width: 52,
          child: Text(
            '${value.toStringAsFixed(fractionDigits)}$suffix',
            style: const TextStyle(fontSize: 12, fontFamily: 'Courier'),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

const _bg = Color(0xFFF7FAFC);
const _ball = Color(0xFF1E88E5);
const _force = Color(0xFFEF6C00);
const _trail = Color(0xFF78909C);
const _ground = Color(0xFF8D6E63);
const _vx = Color(0xFF00897B);
const _vy = Color(0xFF5E35B1);

class _Bounce1DPainter extends CustomPainter {
  _Bounce1DPainter({
    required this.sample,
    required this.strobes,
    required this.ceiling,
    required this.initialEnergy,
  });

  final BounceSample sample;
  final List<BounceSample> strobes;
  final double ceiling;
  final double initialEnergy;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final lines =
        't = ${sample.t.toStringAsFixed(2)} s\ny = ${sample.y.toStringAsFixed(2)} m\nv = ${sample.vy.toStringAsFixed(2)} m/s';
    final ledger = bounceEnergy(
      y: sample.y,
      vx: sample.vx,
      vy: sample.vy,
      initial: initialEnergy,
    );
    final cardBottom = dynamicsReadoutCard(
      lines,
      ledger,
      textColumnWidth: 168,
      bounds: size,
    ).bottom;
    const yMin = -0.2;
    final yMax = math.max(ceiling, 0.8);
    final marginTop = math.max(78.0, cardBottom + 12);
    const marginBottom = 28.0;
    final s = (size.height - marginTop - marginBottom) / (yMax - yMin);
    final x = size.width * 0.48;
    double yOf(double y) => size.height - marginBottom - (y - yMin) * s;
    final groundY = yOf(0);
    canvas.drawLine(
      Offset(16, groundY),
      Offset(size.width - 16, groundY),
      Paint()
        ..color = _ground
        ..strokeWidth = 3,
    );
    for (final p in strobes) {
      canvas.drawCircle(Offset(x, yOf(p.y)), 3.2, Paint()..color = _trail);
    }
    final c = Offset(x, yOf(sample.y));
    canvas.drawCircle(c, 11, Paint()..color = _ball);
    _arrow(canvas, c + const Offset(-16, 0), const Offset(0, 1), 48, _force, '重力');
    if (sample.vy.abs() > 0.35) {
      final dir = sample.vy >= 0 ? const Offset(0, -1) : const Offset(0, 1);
      _arrow(
        canvas,
        c + const Offset(16, 0),
        dir,
        (sample.vy.abs() * 6).clamp(12.0, 90.0),
        _ball,
        'v',
      );
    }
    _hud(canvas, lines, ledger, size, textColumnWidth: 168);
  }

  @override
  bool shouldRepaint(covariant _Bounce1DPainter oldDelegate) =>
      oldDelegate.sample.t != sample.t || oldDelegate.ceiling != ceiling;
}

class _Bounce2DPainter extends CustomPainter {
  _Bounce2DPainter({
    required this.sample,
    required this.strobes,
    required this.legs,
    required this.platformH,
    required this.initialEnergy,
  });

  final BounceSample sample;
  final List<BounceSample> strobes;
  final List<BounceLeg> legs;
  final double platformH;
  final double initialEnergy;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final lines = 't = ${sample.t.toStringAsFixed(2)} s\n'
        'x = ${sample.x.toStringAsFixed(2)} m    y = ${sample.y.toStringAsFixed(2)} m\n'
        'vx = ${sample.vx.toStringAsFixed(2)}    vy = ${sample.vy.toStringAsFixed(2)} m/s';
    final ledger = bounceEnergy(
      y: sample.y,
      vx: sample.vx,
      vy: sample.vy,
      initial: initialEnergy,
    );
    var xMax = 1.0;
    var yMax = 0.8;
    for (final leg in legs) {
      xMax = math.max(xMax, leg.x0 + leg.vx * leg.dt);
      final apexT = leg.vy0 > 0 ? leg.vy0 / kBounceG : 0.0;
      if (apexT <= leg.dt) {
        final apex = leg.y0 + leg.vy0 * apexT - 0.5 * kBounceG * apexT * apexT;
        yMax = math.max(yMax, apex);
      }
    }
    xMax = math.max(xMax, sample.x) + 0.7;
    yMax = math.max(yMax, platformH) + 0.45;
    final xBack = -math.max(2.2, xMax * 0.1);
    const yMin = -0.25;
    const margin = 16.0;
    final cardBottom = dynamicsReadoutCard(
      lines,
      ledger,
      textColumnWidth: 248,
      bounds: size,
    ).bottom;
    final top = math.max(margin + 100.0, cardBottom + 12);
    // 横は跳ね返りの全長、縦は斜方投射と同じく高さで合わせる。矢印は画面上の長さのまま。
    final scaleX = (size.width - margin * 2) / (xMax - xBack);
    final scaleY = (size.height - top - margin) / (yMax - yMin);
    final ox = margin - xBack * scaleX;
    final oy = size.height - margin + yMin * scaleY;
    Offset of(double x, double y) => Offset(ox + x * scaleX, oy - y * scaleY);
    final lip = of(0, platformH);
    final foot = of(0, 0);
    final back = of(xBack, platformH);
    final cliff = Path()
      ..moveTo(back.dx, back.dy)
      ..lineTo(lip.dx, lip.dy)
      ..lineTo(foot.dx, foot.dy)
      ..lineTo(back.dx, foot.dy)
      ..close();
    canvas.drawPath(cliff, Paint()..color = const Color(0xFFD7CCC8));
    canvas.drawPath(
      cliff,
      Paint()
        ..color = _ground
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
    canvas.drawLine(
      foot,
      of(xMax, 0),
      Paint()
        ..color = _ground
        ..strokeWidth = 3,
    );
    final platformLabel = TextPainter(
      text: const TextSpan(
        text: '高台',
        style: TextStyle(color: _ground, fontSize: 11, fontWeight: FontWeight.w800),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    platformLabel.paint(canvas, lip + const Offset(-18, -16) - Offset(platformLabel.width / 2, 0));
    for (final p in strobes) {
      canvas.drawCircle(of(p.x, p.y), 3.0, Paint()..color = _trail);
    }
    final c = of(sample.x, sample.y);
    canvas.drawCircle(c, 9, Paint()..color = _ball);
    _arrow(canvas, c + const Offset(-12, 0), const Offset(0, 1), 36, _force, 'g');
    final px = math.min(4.2, 64 / math.max(sample.vx.abs(), 1));
    if (sample.vx.abs() > 0.2) {
      _arrow(canvas, c, const Offset(1, 0), (sample.vx.abs() * px).clamp(12.0, 70.0), _vx, 'vx');
    }
    if (sample.vy.abs() > 0.35) {
      final dir = sample.vy >= 0 ? const Offset(0, -1) : const Offset(0, 1);
      _arrow(canvas, c, dir, (sample.vy.abs() * px).clamp(12.0, 70.0), _vy, 'vy');
    }
    _hud(canvas, lines, ledger, size, textColumnWidth: 248);
  }

  @override
  bool shouldRepaint(covariant _Bounce2DPainter oldDelegate) =>
      oldDelegate.sample.t != sample.t ||
      oldDelegate.legs.length != legs.length ||
      oldDelegate.platformH != platformH;
}

void _arrow(Canvas canvas, Offset origin, Offset dir, double length, Color color, String label) {
  final tip = origin + dir * length;
  const head = 9.0;
  final n = Offset(-dir.dy, dir.dx);
  canvas.drawLine(
    origin,
    tip - dir * 6,
    Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round,
  );
  final path = Path()
    ..moveTo(tip.dx, tip.dy)
    ..lineTo((tip - dir * head + n * 4.5).dx, (tip - dir * head + n * 4.5).dy)
    ..lineTo((tip - dir * head - n * 4.5).dx, (tip - dir * head - n * 4.5).dy)
    ..close();
  canvas.drawPath(path, Paint()..color = color);
  final tp = TextPainter(
    text: TextSpan(
      text: label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(canvas, tip + n * 12 - Offset(tp.width / 2, tp.height / 2));
}

void _hud(
  Canvas canvas,
  String lines,
  EnergyLedger ledger,
  Size size, {
  required double textColumnWidth,
}) {
  paintDynamicsReadout(
    canvas,
    lines,
    ledger,
    textColumnWidth: textColumnWidth,
    bounds: size,
  );
}
