import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/energy_gauge.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/experiment/dynamics/animations/kepler_ellipse.dart';
import 'package:joyphysics/model.dart';

final twoBodyKepler2D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '2体問題(重力・連星)',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>外力のない2質点は共通の重心のまわりを回る。原点を重心に取ると、相対ベクトル $\mathbf{r}=\mathbf{r}_2-\mathbf{r}_1$ は質量 $M=m_1+m_2$ の固定中心ケプラー問題になり、束縛なら楕円である。各星の軌道はそれと相似で、半長軸 $a_1,a_2$ はてこで決まる。</p>
  <p>$$\displaystyle a=a_1+a_2,\quad \frac{m_1}{m_2}=\frac{a_2}{a_1}$$</p>
  <p>$$\displaystyle \mathbf{r}_1=-\frac{a_1}{a}\mathbf{r},\quad \mathbf{r}_2=\frac{a_2}{a}\mathbf{r}$$</p>
  <p>近点で速度は半径に垂直なら、$(a_i,e)$ と $(r_i,v_i)$ は一対一である。第3法則は相対半長軸について</p>
  <p>$$\displaystyle \frac{T^{2}}{a^{3}}=\frac{4\pi^{2}}{G(m_1+m_2)}$$</p>
  <p>質量比が近いと重心は主星の外に出ます。地球と月、太陽と地球では重心は主星の中にあります。</p>
  """,
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: TwoBodyKepler2DSimulation(),
      height: 760,
    ),
  ],
);

const Color kTwoBodyKeplerStar1 = Color(0xFFFFB300);
const Color kTwoBodyKeplerStar2 = Color(0xFF1E88E5);

const double kTwoBodyKeplerG = 1.0;
const double kTwoBodyKeplerM = 1.0;
const double kTwoBodyKeplerGM = kTwoBodyKeplerG * kTwoBodyKeplerM;
const double kTwoBodyKeplerMinA = 0.003;
const double kTwoBodyKeplerMaxA = 1.2;
const double kTwoBodyKeplerMaxE = 0.85;
const double kTwoBodyKeplerDefaultA1 = 0.5;
const double kTwoBodyKeplerDefaultA2 = 0.5;
const double kTwoBodyKeplerDefaultE = 0.0;
const double kTwoBodyKeplerViewScale = 1.8;
const double kTwoBodyKeplerPlayback = 1.8;
const double kTwoBodyKeplerDiskScale = 0.10;
const double kTwoBodyKeplerDiskMin = 0.022;
const double kDaysPerJulianYear = 365.25;
const double kEarthSiderealMonthDays = 27.321661;
const double kPlutoCharonPeriodDays = 6.387230;
const double kSunPerEarthMass = 332946.0487;

double twoEarthsAtOneAuPeriodYears() => math.sqrt(kSunPerEarthMass / 2);

double twoBodyKeplerReferencePeriodYears(TwoBodyKeplerPreset preset) {
  switch (preset) {
    case TwoBodyKeplerPreset.equalCircle:
    case TwoBodyKeplerPreset.equalEllipse:
      return twoEarthsAtOneAuPeriodYears();
    case TwoBodyKeplerPreset.sunEarth:
      return 1.0;
    case TwoBodyKeplerPreset.earthMoon:
      return kEarthSiderealMonthDays / kDaysPerJulianYear;
    case TwoBodyKeplerPreset.charon:
      return kPlutoCharonPeriodDays / kDaysPerJulianYear;
  }
}

double twoBodyKeplerPeriodYears({
  required double a,
  required TwoBodyKeplerPreset preset,
}) {
  final aRef = applyTwoBodyKeplerPreset(preset);
  final a0 = aRef['a1']! + aRef['a2']!;
  return twoBodyKeplerReferencePeriodYears(preset) *
      math.pow(a / a0, 1.5).toDouble();
}

bool twoBodyKeplerTimeInDays(TwoBodyKeplerPreset preset) =>
    preset == TwoBodyKeplerPreset.earthMoon ||
    preset == TwoBodyKeplerPreset.charon;

String formatBinaryStarTime(double years, TwoBodyKeplerPreset preset) {
  if (!twoBodyKeplerTimeInDays(preset)) return formatBinaryStarYears(years);
  final days = years * kDaysPerJulianYear;
  final abs = days.abs();
  final digits = abs >= 100
      ? 1
      : abs >= 10
          ? 2
          : abs >= 1
              ? 3
              : 4;
  return '${days.toStringAsFixed(digits)} 日';
}

String formatBinaryStarYears(double years) {
  final abs = years.abs();
  final digits = abs >= 100
      ? 0
      : abs >= 10
          ? 1
          : abs >= 1
              ? 2
              : abs >= 0.1
                  ? 3
                  : 4;
  return '${years.toStringAsFixed(digits)} 年';
}

double twoBodyKeplerMass1(double a1, double a2) => a2 / (a1 + a2);

double twoBodyKeplerMass2(double a1, double a2) => a1 / (a1 + a2);

double binaryStarDiskRadius(double mass) => math.max(
      kTwoBodyKeplerDiskMin,
      kTwoBodyKeplerDiskScale * math.pow(mass, 1 / 3).toDouble(),
    );

enum TwoBodyKeplerPreset { equalCircle, charon, earthMoon, sunEarth, equalEllipse }

class TwoBodyKeplerParams {
  const TwoBodyKeplerParams({
    required this.a1,
    required this.a2,
    required this.e,
  });

  final double a1;
  final double a2;
  final double e;

  factory TwoBodyKeplerParams.fromMap(Map<String, double> params) {
    return TwoBodyKeplerParams(
      a1: params['a1']!.clamp(kTwoBodyKeplerMinA, kTwoBodyKeplerMaxA).toDouble(),
      a2: params['a2']!.clamp(kTwoBodyKeplerMinA, kTwoBodyKeplerMaxA).toDouble(),
      e: params['e']!.clamp(0.0, kTwoBodyKeplerMaxE).toDouble(),
    );
  }

  double get a => a1 + a2;
  double get m1 => twoBodyKeplerMass1(a1, a2);
  double get m2 => twoBodyKeplerMass2(a1, a2);
  double get disk1 => binaryStarDiskRadius(m1);
  double get disk2 => binaryStarDiskRadius(m2);
}

class TwoBodyKeplerState {
  const TwoBodyKeplerState({
    required this.params,
    required this.relative,
    required this.x1,
    required this.y1,
    required this.vx1,
    required this.vy1,
    required this.x2,
    required this.y2,
    required this.vx2,
    required this.vy2,
  });

  final TwoBodyKeplerParams params;
  final KeplerOrbitState relative;
  final double x1;
  final double y1;
  final double vx1;
  final double vy1;
  final double x2;
  final double y2;
  final double vx2;
  final double vy2;

  double get r1 => math.sqrt(x1 * x1 + y1 * y1);
  double get r2 => math.sqrt(x2 * x2 + y2 * y2);
  double get speed1 => math.sqrt(vx1 * vx1 + vy1 * vy1);
  double get speed2 => math.sqrt(vx2 * vx2 + vy2 * vy2);
  double get cmx => params.m1 * x1 + params.m2 * x2;
  double get cmy => params.m1 * y1 + params.m2 * y2;
}

EnergyLedger twoBodyKeplerEnergy(TwoBodyKeplerState state) {
  final total = state.params.m1 + state.params.m2;
  final mu = state.params.m1 * state.params.m2 / total;
  final combined = keplerMechanicalLedger(state.relative, mass: mu);
  final k1 = 0.5 * state.params.m1 * state.speed1 * state.speed1;
  final k2 = 0.5 * state.params.m2 * state.speed2 * state.speed2;
  return EnergyLedger(
    kinetic: k1 + k2,
    potential: combined.potential,
    dissipated: 0,
    scale: combined.scale,
    potentialLabel: kLabelGravitation,
    kineticPortions: [
      EnergyPortion(
        value: k1,
        label: kLabelKinetic1,
        color: kTwoBodyKeplerStar1,
      ),
      EnergyPortion(
        value: k2,
        label: kLabelKinetic2,
        color: kTwoBodyKeplerStar2,
      ),
    ],
  );
}

TwoBodyKeplerState evolveTwoBodyKepler({
  required double a1,
  required double a2,
  required double e,
  required double phase,
}) {
  final p = TwoBodyKeplerParams(a1: a1, a2: a2, e: e);
  final rel = evolveKeplerEllipse(
    a: p.a,
    e: e,
    phase: phase,
    gm: kTwoBodyKeplerGM,
  );
  final s1 = a1 / p.a;
  final s2 = a2 / p.a;
  return TwoBodyKeplerState(
    params: p,
    relative: rel,
    x1: -s1 * rel.x,
    y1: -s1 * rel.y,
    vx1: -s1 * rel.vx,
    vy1: -s1 * rel.vy,
    x2: s2 * rel.x,
    y2: s2 * rel.y,
    vx2: s2 * rel.vx,
    vy2: s2 * rel.vy,
  );
}

Map<String, double> applyTwoBodyKeplerPreset(TwoBodyKeplerPreset preset) {
  switch (preset) {
    case TwoBodyKeplerPreset.equalCircle:
      return {'a1': 0.5, 'a2': 0.5, 'e': 0.0};
    case TwoBodyKeplerPreset.charon:
      return {'a1': 1 / 9, 'a2': 8 / 9, 'e': 0.0};
    case TwoBodyKeplerPreset.earthMoon:
      return {'a1': 1 / 82, 'a2': 81 / 82, 'e': 0.0};
    case TwoBodyKeplerPreset.sunEarth:
      return {'a1': 1 / 301, 'a2': 300 / 301, 'e': 0.0};
    case TwoBodyKeplerPreset.equalEllipse:
      return {'a1': 0.5, 'a2': 0.5, 'e': 0.6};
  }
}

class TwoBodyKepler2DSimulation extends PhysicsSimulation {
  TwoBodyKepler2DSimulation()
      : super(
          title: '2体問題(重力・連星)',
          formula: const FormulaDisplay(
            r'\displaystyle a=a_1+a_2,\quad \frac{m_1}{m_2}=\frac{a_2}{a_1}',
          ),
          aspectRatio: (16 / 9) / kTwoBodyKeplerViewScale,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> phase = ValueNotifier(0.0);

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    phase.value +=
        kTwoBodyKeplerPlayback * dt / keplerPeriod(_params.a, gm: kTwoBodyKeplerGM);
  });

  ValueNotifier<bool> get running => _loop.running;

  Map<String, double> _latestParams = {};
  TwoBodyKeplerPreset _selected = TwoBodyKeplerPreset.equalCircle;
  void Function(String key, double value)? _updateParam;

  @override
  Map<String, double> get initialParameters => {
        'a1': kTwoBodyKeplerDefaultA1,
        'a2': kTwoBodyKeplerDefaultA2,
        'e': kTwoBodyKeplerDefaultE,
      };

  TwoBodyKeplerParams get _params {
    if (_latestParams.isEmpty) {
      return TwoBodyKeplerParams.fromMap(initialParameters);
    }
    return TwoBodyKeplerParams.fromMap(_latestParams);
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
    phase.value = 0.0;
  }

  void _pushParams(Map<String, double> next) {
    if (_updateParam == null) return;
    final current = Map<String, double>.from(
      _latestParams.isEmpty ? initialParameters : _latestParams,
    );
    for (final entry in next.entries) {
      if (current[entry.key] != entry.value) {
        _updateParam!(entry.key, entry.value);
      }
    }
  }

  void applyPreset(TwoBodyKeplerPreset preset) {
    resetMotion();
    _selected = preset;
    _pushParams(applyTwoBodyKeplerPreset(preset));
  }

  @override
  Widget? buildFormulaOverlay(Map<String, double> parameters) {
    _rememberParams(parameters);
    final p = _params;
    final t = keplerPeriod(p.a, gm: kTwoBodyKeplerGM);
    final ratio = t * t / (p.a * p.a * p.a);
    final years = twoBodyKeplerPeriodYears(a: p.a, preset: _selected);
    return Column(
      children: [
        const FormulaDisplay(
          r'\displaystyle \frac{T^{2}}{a^{3}}=\frac{4\pi^{2}}{GM}',
        ),
        const SizedBox(height: 4),
        Text(
          'T = ${formatBinaryStarTime(years, _selected)}    '
          'm₁:m₂ = ${p.m1.toStringAsFixed(3)} : ${p.m2.toStringAsFixed(3)}    '
          'T²/a³ = ${ratio.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 13, fontFamily: 'Courier'),
        ),
      ],
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
                _presetButton('等質量', TwoBodyKeplerPreset.equalCircle),
                _presetButton('冥王星-カロン', TwoBodyKeplerPreset.charon),
                _presetButton('地球-月', TwoBodyKeplerPreset.earthMoon),
                _presetButton('太陽-地球', TwoBodyKeplerPreset.sunEarth),
                _presetButton('楕円交差', TwoBodyKeplerPreset.equalEllipse),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _presetButton(String label, TwoBodyKeplerPreset preset) {
    final selected = _selected == preset;
    final child = Text(label);
    final onPressed = () => applyPreset(preset);
    if (selected) {
      return FilledButton(onPressed: onPressed, child: child);
    }
    return OutlinedButton(onPressed: onPressed, child: child);
  }

  @override
  List<Widget> buildControls(
    BuildContext context,
    Map<String, double> parameters,
    void Function(String key, double value) updateParam,
  ) {
    _rememberParams(parameters);
    _updateParam = updateParam;
    final p = TwoBodyKeplerParams.fromMap(parameters);
    return [
      const Text(
        '軌道要素',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _BinarySlider(
        label: 'a₁',
        value: p.a1,
        min: kTwoBodyKeplerMinA,
        max: kTwoBodyKeplerMaxA,
        onChanged: (v) => updateParam('a1', v),
        semanticLabel: '半長軸 a1',
      ),
      _BinarySlider(
        label: 'a₂',
        value: p.a2,
        min: kTwoBodyKeplerMinA,
        max: kTwoBodyKeplerMaxA,
        onChanged: (v) => updateParam('a2', v),
        semanticLabel: '半長軸 a2',
      ),
      _BinarySlider(
        label: 'e',
        value: p.e,
        min: 0.0,
        max: kTwoBodyKeplerMaxE,
        onChanged: (v) => updateParam('e', v),
        semanticLabel: '離心率 e',
      ),
      const SizedBox(height: 6),
      DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4F8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: DefaultTextStyle(
            style: const TextStyle(
              fontSize: 12,
              height: 1.45,
              color: Color(0xFF37474F),
              fontFamily: 'Courier',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '近点（aᵢ, e と一対一）',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: null,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'r₁ = ${keplerPeriapsisRadius(p.a1, p.e).toStringAsFixed(3)}    '
                  'v₁ = ${((p.a1 / p.a) * keplerPeriapsisSpeed(p.a, p.e, gm: kTwoBodyKeplerGM)).toStringAsFixed(3)}',
                ),
                Text(
                  'r₂ = ${keplerPeriapsisRadius(p.a2, p.e).toStringAsFixed(3)}    '
                  'v₂ = ${((p.a2 / p.a) * keplerPeriapsisSpeed(p.a, p.e, gm: kTwoBodyKeplerGM)).toStringAsFixed(3)}',
                ),
              ],
            ),
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
      animation: Listenable.merge([running, phase]),
      builder: (context, _) {
        final p = TwoBodyKeplerParams.fromMap(parameters);
        final s = evolveTwoBodyKepler(
          a1: p.a1,
          a2: p.a2,
          e: p.e,
          phase: phase.value,
        );
        final periodYears =
            twoBodyKeplerPeriodYears(a: p.a, preset: _selected);
        return CustomPaint(
          size: Size.infinite,
          painter: _TwoBodyKeplerPainter(
            state: s,
            preset: _selected,
            timeYears: phase.value * periodYears,
            periodYears: periodYears,
          ),
        );
      },
    );
  }
}

class _BinarySlider extends StatelessWidget {
  const _BinarySlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.semanticLabel,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String semanticLabel;

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
                  '$semanticLabel ${v.toStringAsFixed(3)}',
            ),
          ),
        ),
        SizedBox(
          width: 52,
          child: Text(
            value.toStringAsFixed(3),
            style: const TextStyle(fontSize: 12, fontFamily: 'Courier'),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _TwoBodyKeplerPainter extends CustomPainter {
  _TwoBodyKeplerPainter({
    required this.state,
    required this.preset,
    required this.timeYears,
    required this.periodYears,
  });

  final TwoBodyKeplerState state;
  final TwoBodyKeplerPreset preset;
  final double timeYears;
  final double periodYears;

  static const _bg = Color(0xFFF7FAFC);
  static const _orbit = Color(0xFF90A4AE);
  static const _link = Color(0xFFB0BEC5);
  static const _cm = Color(0xFFE53935);
  static const _star1 = kTwoBodyKeplerStar1;
  static const _star2 = kTwoBodyKeplerStar2;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final toScreen = _fitView(size);
    final p = state.params;

    _drawOrbit(canvas, toScreen, p.a1, p.e, flipped: true);
    _drawOrbit(canvas, toScreen, p.a2, p.e, flipped: false);

    final c1 = toScreen(state.x1, state.y1);
    final c2 = toScreen(state.x2, state.y2);
    canvas.drawLine(
      c1,
      c2,
      Paint()
        ..color = _link
        ..strokeWidth = 1.2,
    );

    _drawBarycenter(canvas, toScreen(0, 0));
    _drawStar(
      canvas,
      toScreen,
      state.x1,
      state.y1,
      state.vx1,
      state.vy1,
      p.disk1,
      _star1,
    );
    _drawStar(
      canvas,
      toScreen,
      state.x2,
      state.y2,
      state.vx2,
      state.vy2,
      p.disk2,
      _star2,
    );
    _drawHud(canvas, size);
  }

  Offset Function(double, double) _fitView(Size size) {
    final p = state.params;
    final reach = math.max(
          math.max(p.a1, p.a2) * (1 + p.e),
          math.max(p.disk1, p.disk2),
        ) +
        0.35;
    final world = 2 * reach;
    final text =
        't = ${formatBinaryStarTime(timeYears, preset)}    T = ${formatBinaryStarTime(periodYears, preset)}';
    final clear = dynamicsReadoutCard(
      text,
      twoBodyKeplerEnergy(state),
      textColumnWidth: 280,
      bounds: size,
    ).bottom + 8;
    final plotH = math.max(48.0, size.height - clear);
    final s = math.min(size.width / world, plotH / world);
    final ox = size.width / 2;
    final oy = clear + plotH / 2;
    return (x, y) => Offset(ox + x * s, oy - y * s);
  }

  void _drawOrbit(
    Canvas canvas,
    Offset Function(double, double) toScreen,
    double ai,
    double e, {
    required bool flipped,
  }) {
    final b = keplerSemiMinor(ai, e);
    final sign = flipped ? -1.0 : 1.0;
    final path = Path();
    const samples = 180;
    for (int i = 0; i <= samples; i++) {
      final u = 2 * math.pi * i / samples;
      final p = toScreen(
        sign * ai * (math.cos(u) - e),
        sign * b * math.sin(u),
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = _orbit
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  void _drawBarycenter(Canvas canvas, Offset c) {
    const arm = 7.0;
    final halo = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;
    final paint = Paint()
      ..color = _cm
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(c.translate(-arm, 0), c.translate(arm, 0), halo);
    canvas.drawLine(c.translate(0, -arm), c.translate(0, arm), halo);
    canvas.drawLine(c.translate(-arm, 0), c.translate(arm, 0), paint);
    canvas.drawLine(c.translate(0, -arm), c.translate(0, arm), paint);
  }

  void _drawStar(
    Canvas canvas,
    Offset Function(double, double) toScreen,
    double x,
    double y,
    double vx,
    double vy,
    double disk,
    Color color,
  ) {
    final c = toScreen(x, y);
    final edge = toScreen(x + disk, y);
    final rPx = (edge - c).distance;
    canvas.drawCircle(c.translate(0, 2), rPx, Paint()..color = Colors.black12);
    canvas.drawCircle(c, rPx, Paint()..color = color);
    canvas.drawCircle(
      c,
      rPx,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _drawVelocity(canvas, toScreen, x, y, vx, vy, rPx, color);
  }

  void _drawVelocity(
    Canvas canvas,
    Offset Function(double, double) toScreen,
    double x,
    double y,
    double vx,
    double vy,
    double planetR,
    Color color,
  ) {
    final speed = math.sqrt(vx * vx + vy * vy);
    if (speed < 1e-6) return;
    final p = toScreen(x, y);
    final tip = toScreen(
      x + vx * kKeplerVelocityArrowScale,
      y + vy * kKeplerVelocityArrowScale,
    );
    final delta = tip - p;
    final len = delta.distance;
    if (len < 1) return;
    final dir = delta / len;
    const headLen = 13.0;
    const headHalf = 6.5;
    final start = p + dir * planetR;
    var end = tip;
    if ((end - start).distance < headLen + 6) {
      end = start + dir * (headLen + 10);
    }
    final shaftEnd = end - dir * (headLen * 0.82);
    final n = Offset(-dir.dy, dir.dx);
    canvas.drawLine(
      start,
      shaftEnd,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 4.6
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      start,
      shaftEnd,
      Paint()
        ..color = color
        ..strokeWidth = 2.8
        ..strokeCap = StrokeCap.round,
    );
    final head = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        (end - dir * headLen + n * headHalf).dx,
        (end - dir * headLen + n * headHalf).dy,
      )
      ..lineTo(
        (end - dir * headLen - n * headHalf).dx,
        (end - dir * headLen - n * headHalf).dy,
      )
      ..close();
    canvas.drawPath(
      head,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 3.2,
    );
    canvas.drawPath(head, Paint()..color = color);
    _label(canvas, end + dir * 11 + n * 8, 'v', color);
  }

  void _label(Canvas canvas, Offset o, String text, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(o.dx - tp.width / 2, o.dy));
  }

  void _drawHud(Canvas canvas, Size size) {
    final text =
        't = ${formatBinaryStarTime(timeYears, preset)}    T = ${formatBinaryStarTime(periodYears, preset)}';
    paintDynamicsReadout(
      canvas,
      text,
      twoBodyKeplerEnergy(state),
      textColumnWidth: 280,
      bounds: size,
    );
  }

  @override
  bool shouldRepaint(covariant _TwoBodyKeplerPainter oldDelegate) {
    return oldDelegate.state.x1 != state.x1 ||
        oldDelegate.state.y1 != state.y1 ||
        oldDelegate.state.x2 != state.x2 ||
        oldDelegate.state.params.a1 != state.params.a1 ||
        oldDelegate.state.params.a2 != state.params.a2 ||
        oldDelegate.state.params.e != state.params.e;
  }
}
