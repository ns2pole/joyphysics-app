import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
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
  <div class="common-box">使い方</div>
  <p>単位は $G=1$, $M=m_1+m_2=1$ です。赤い十字が重心（両楕円の焦点）です。スライダーの $a_1,a_2$ は各星の半長軸、$e$ は共通の離心率です。$t=0$ は近点です。</p>
  <p>「等質量」「冥王星-カロン」「地球-月」「太陽-地球」「楕円交差」は Wikipedia の重心アニメ (a)–(e) に対応します。カロンは冥王星の衛星で、質量比が近く重心が主星ディスクの外に出る連星の例です。地球-月・太陽-地球では重心が主星の中にあります。Start で動き、リセットで近点に戻ります。</p>
  """,
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: TwoBodyKepler2DSimulation(),
      height: 760,
    ),
  ],
);

const double kTwoBodyKeplerG = 1.0;
const double kTwoBodyKeplerM = 1.0;
const double kTwoBodyKeplerGM = kTwoBodyKeplerG * kTwoBodyKeplerM;
const double kTwoBodyKeplerMinA = 0.003;
const double kTwoBodyKeplerMaxA = 1.2;
const double kTwoBodyKeplerMaxE = 0.85;
const double kTwoBodyKeplerDefaultA1 = 0.5;
const double kTwoBodyKeplerDefaultA2 = 0.5;
const double kTwoBodyKeplerDefaultE = 0.0;
const double kTwoBodyKeplerDiskScale = 0.10;
const double kTwoBodyKeplerDiskMin = 0.022;

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
          aspectRatio: 16 / 9,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<bool> running = ValueNotifier(false);
  final ValueNotifier<double> phase = ValueNotifier(0.0);

  Map<String, double> _latestParams = {};
  TwoBodyKeplerPreset _selected = TwoBodyKeplerPreset.equalCircle;
  void Function(String key, double value)? _updateParam;
  bool _tickScheduled = false;
  DateTime? _lastTickAt;

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
    _lastTickAt = null;
    running.value = true;
    _scheduleTick();
  }

  void resetMotion() {
    running.value = false;
    phase.value = 0.0;
    _lastTickAt = null;
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

  void _scheduleTick() {
    if (!running.value || _tickScheduled) return;
    _tickScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tickScheduled = false;
      if (!running.value) return;
      final now = DateTime.now();
      final dt = _lastTickAt == null
          ? 1 / 60
          : (now.difference(_lastTickAt!).inMicroseconds / 1e6)
              .clamp(0.0, 0.05)
              .toDouble();
      _lastTickAt = now;
      final tPeriod = keplerPeriod(_params.a, gm: kTwoBodyKeplerGM);
      phase.value += dt / tPeriod;
      if (running.value) _scheduleTick();
    });
  }

  @override
  Widget? buildFormulaOverlay(Map<String, double> parameters) {
    _rememberParams(parameters);
    final p = _params;
    final t = keplerPeriod(p.a, gm: kTwoBodyKeplerGM);
    final ratio = t * t / (p.a * p.a * p.a);
    return Column(
      children: [
        const FormulaDisplay(
          r'\displaystyle \frac{T^{2}}{a^{3}}=\frac{4\pi^{2}}{GM}',
        ),
        const SizedBox(height: 4),
        Text(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: isRunning ? null : start,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: resetMotion,
                  icon: const Icon(Icons.restore),
                  label: const Text('リセット'),
                ),
              ],
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
        return CustomPaint(
          size: Size.infinite,
          painter: _TwoBodyKeplerPainter(state: s),
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
  _TwoBodyKeplerPainter({required this.state});

  final TwoBodyKeplerState state;

  static const _bg = Color(0xFF000000);
  static const _orbit = Color(0xFFE53935);
  static const _cm = Color(0xFFE53935);
  static const _star = Color(0xFFF5F5F5);
  static const _v = Color(0xFFFFD54F);
  static const _ink = Color(0xFFECEFF1);

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
        ..color = const Color(0x55FFFFFF)
        ..strokeWidth = 1,
    );

    _drawBarycenter(canvas, toScreen(0, 0));
    _drawStar(canvas, toScreen, state.x1, state.y1, state.vx1, state.vy1, p.disk1);
    _drawStar(canvas, toScreen, state.x2, state.y2, state.vx2, state.vy2, p.disk2);
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
    final s = math.min(size.width / world, size.height / world);
    final ox = size.width / 2;
    final oy = size.height / 2;
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
        ..strokeWidth = 0.6,
    );
  }

  void _drawBarycenter(Canvas canvas, Offset c) {
    const arm = 8.0 * 2 / 3;
    final paint = Paint()
      ..color = _cm
      ..strokeWidth = 2.2 * 2 / 3
      ..strokeCap = StrokeCap.round;
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
  ) {
    final c = toScreen(x, y);
    final edge = toScreen(x + disk, y);
    final rPx = (edge - c).distance;
    canvas.drawCircle(c, rPx, Paint()..color = _star);
    _drawVelocity(canvas, toScreen, x, y, vx, vy, rPx);
  }

  void _drawVelocity(
    Canvas canvas,
    Offset Function(double, double) toScreen,
    double x,
    double y,
    double vx,
    double vy,
    double planetR,
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
    const headLen = 11.0;
    const headHalf = 5.5;
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
        ..color = _v
        ..strokeWidth = 2.4
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
    canvas.drawPath(head, Paint()..color = _v);
    _label(canvas, end + dir * 10 + n * 8, 'v', _v);
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
    final t = state.relative.time;
    final text =
        't = ${t.toStringAsFixed(2)}    T = ${state.relative.period.toStringAsFixed(2)}';
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: _ink,
          fontSize: 11,
          fontFamily: 'Courier',
          height: 1.35,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 8, tp.width + 16, tp.height + 10),
      const Radius.circular(8),
    );
    canvas.drawRRect(
        rect, Paint()..color = const Color(0xCC263238));
    tp.paint(canvas, const Offset(16, 13));
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
