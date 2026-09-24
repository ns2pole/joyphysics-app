import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/energy_gauge.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/experiment/dynamics/animations/kepler_ellipse.dart';
import 'package:joyphysics/model.dart';

export 'package:joyphysics/experiment/dynamics/animations/kepler_ellipse.dart';

final keplerLaws2D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: 'ケプラーの3法則',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>中心星が十分重いとき、原点に固定した質量のまわりの束縛軌道は楕円になる。近点から出発し、速度が半径に垂直なら、半長軸 $a$ と離心率 $e$ は近点の $r,v$ と一対一である。</p>
  <p>$$r_{\min}=a(1-e),\quad v_{\mathrm{peri}}=\sqrt{\frac{GM(1+e)}{a(1-e)}}$$</p>
  <p>軌道の形（第1法則）</p>
  <p>$$r=\frac{a(1-e^{2})}{1+e\cos\theta}$$</p>
  <p>時間は離心近点離角 $u$ への変数変換 $\displaystyle r=a(1-e\cos u)$ で閉じ、ケプラー方程式になる。</p>
  <p>$$nt=u-e\sin u,\quad n=\sqrt{\frac{GM}{a^{3}}}$$</p>
  <p>位置は $\displaystyle x=a(\cos u-e),\; y=a\sqrt{1-e^{2}}\sin u$。</p>
  <p>$$T=2\pi\sqrt{\frac{a^{3}}{GM}}$$</p>
  <p>より第3法則</p>
  <p>$$\frac{T^{2}}{a^{3}}=\frac{4\pi^{2}}{GM}$$</p>
  <p>面積速度は $\displaystyle \frac{h}{2}$ で一定（第2法則）。</p>
  <p>$a=1$ は1天文単位で、$\displaystyle T=365.25$ 日です。$a$ を変えると $\displaystyle T\propto a^{3/2}$ で、半長軸を2倍にすると周期は $\displaystyle 2\sqrt{2}$ 倍です。</p>
  """,
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: KeplerLaws2DSimulation(),
      height: 760,
    ),
  ],
);

const double kKeplerMinA = 0.5;
const double kKeplerMaxA = 2.0;
const double kKeplerMaxE = 0.85;
const double kKeplerDefaultA = 1.0;
const double kKeplerDefaultE = 0.65;
const double kKeplerSemiMajorRatio = 2.0;
final double kKeplerPeriodRatio = 2 * math.sqrt(2);

double keplerCompareSemiMajor(double a) => a * kKeplerSemiMajorRatio;

enum KeplerLawsPreset { second, third }

class KeplerLawsParams {
  const KeplerLawsParams({
    required this.a,
    required this.e,
  });

  final double a;
  final double e;

  factory KeplerLawsParams.fromMap(Map<String, double> params) {
    return KeplerLawsParams(
      a: params['a']!.clamp(kKeplerMinA, kKeplerMaxA).toDouble(),
      e: params['e']!.clamp(0.0, kKeplerMaxE).toDouble(),
    );
  }
}

const double kKeplerEarthYearDays = 365.25;
const double kSecondsPerDay = 86400.0;
const double kMetersPerAu = 149597870700.0;

/// $a=1$（1天文単位）を地球の公転周期 365.25 日に合わせる。$\displaystyle T\propto a^{3/2}$。
double keplerLawsPeriodDays(double a) =>
    kKeplerEarthYearDays * math.pow(a, 1.5).toDouble();

/// $T$ は秒、$a$ はメートル。単位は $\mathrm{s^{2}/m^{3}}$。
double keplerLawsRatioMks(double aAu) {
  final seconds = keplerLawsPeriodDays(aAu) * kSecondsPerDay;
  final meters = aAu * kMetersPerAu;
  return seconds * seconds / (meters * meters * meters);
}

/// 指数表記にせず、普通の小数で書く。$0.01$ 以上は小数第2位。それより小さいときは有効数字2桁。
String formatMksFixed(double value) {
  if (value == 0) return '0.00';
  final abs = value.abs();
  if (abs >= 0.005) return value.toStringAsFixed(2);
  final places = (-(math.log(abs) / math.ln10)).ceil() + 1;
  return value.toStringAsFixed(places);
}

String formatKeplerDays(double days) {
  final digits = days.abs() >= 1 ? 2 : 3;
  return '${days.toStringAsFixed(digits)} 日';
}

const double kKeplerAreaSliceDt = 30.0;

class KeplerAreaSlice {
  const KeplerAreaSlice({
    required this.t0,
    required this.t1,
    required this.colorIndex,
  });

  final double t0;
  final double t1;
  final int colorIndex;
}

/// 時刻 $t$ までを $\Delta t$ ごとの扇形に分ける。新しいスライスが後ろ（上塗り順）。
List<KeplerAreaSlice> keplerEqualTimeSlices(
  double t, {
  double dt = kKeplerAreaSliceDt,
  required int keep,
}) {
  if (t <= 1e-12 || dt <= 0 || keep <= 0) return const [];
  final lastStart = (t / dt).floor();
  final firstStart = math.max(0, lastStart - keep + 1);
  final slices = <KeplerAreaSlice>[];
  for (int i = firstStart; i <= lastStart; i++) {
    final t0 = i * dt;
    final t1 = math.min(t, (i + 1) * dt);
    if (t1 - t0 <= 1e-12) continue;
    slices.add(KeplerAreaSlice(t0: t0, t1: t1, colorIndex: i));
  }
  return slices;
}

class KeplerLaws2DSimulation extends PhysicsSimulation {
  KeplerLaws2DSimulation()
      : super(
          title: 'ケプラーの3法則',
          formula: const FormulaDisplay(
            r'\displaystyle nt=u-e\sin u,\quad \frac{T^{2}}{a^{3}}=\frac{4\pi^{2}}{GM}',
          ),
          aspectRatio: (16 / 9) / 1.5,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> phase = ValueNotifier(0.0);

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    phase.value += dt / keplerPeriod(_params.a);
  });

  ValueNotifier<bool> get running => _loop.running;

  Map<String, double> _latestParams = {};
  Set<String> _activeIds = {};
  KeplerLawsPreset? _selectedLaw;
  void Function(Set<String> ids)? _updateActiveIds;

  static const String idEqualArea = 'equalArea';
  static const String idCompareOrbit = 'compareOrbit';

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'a': kKeplerDefaultA,
        'e': kKeplerDefaultE,
      };

  KeplerLawsParams get _params {
    if (_latestParams.isEmpty) {
      return KeplerLawsParams.fromMap(initialParameters);
    }
    return KeplerLawsParams.fromMap(_latestParams);
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

  void applyPreset(KeplerLawsPreset preset) {
    resetMotion();
    if (_selectedLaw == preset) {
      _selectedLaw = null;
      _updateActiveIds?.call({});
      return;
    }
    _selectedLaw = preset;
    final next = <String>{};
    switch (preset) {
      case KeplerLawsPreset.second:
        next.add(idEqualArea);
        break;
      case KeplerLawsPreset.third:
        next.add(idCompareOrbit);
        break;
    }
    _updateActiveIds?.call(next);
  }

  @override
  Widget? buildFormulaOverlay(Map<String, double> parameters) {
    _rememberParams(parameters);
    final p = _params;
    final days = keplerLawsPeriodDays(p.a);
    final ratio = keplerLawsRatioMks(p.a);
    return Column(
      children: [
        const FormulaDisplay(
          r'\displaystyle \frac{T^{2}}{a^{3}}=\frac{4\pi^{2}}{GM}',
        ),
        const SizedBox(height: 4),
        Text(
          'T = ${formatKeplerDays(days)}    '
          'T²/a³ = ${formatMksFixed(ratio)} s²/m³',
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
    _activeIds = Set<String>.from(activeIds);
    _updateActiveIds = updateActiveIds;
    return ValueListenableBuilder<bool>(
      valueListenable: running,
      builder: (context, isRunning, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedLaw == KeplerLawsPreset.second) ...[
              const Text(
                '30日ごとに面積を塗っています。',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF546E7A)),
              ),
              const SizedBox(height: 8),
            ],
            if (_selectedLaw == KeplerLawsPreset.third) ...[
              const Text(
                '外側は a を2倍。周期は 2√2 倍なので、内側が3周いかないうちに外側が1周します。',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF546E7A)),
              ),
              const SizedBox(height: 8),
            ],
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
                _lawButton('第2法則', KeplerLawsPreset.second),
                _lawButton('第3法則', KeplerLawsPreset.third),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _lawButton(String label, KeplerLawsPreset preset) {
    final selected = _selectedLaw == preset;
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
    final p = KeplerLawsParams.fromMap(parameters);
    final rMin = keplerPeriapsisRadius(p.a, p.e);
    final vPeri = keplerPeriapsisSpeed(p.a, p.e);
    final days = keplerLawsPeriodDays(p.a);
    return [
      const Text(
        '軌道要素',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _KeplerSlider(
        label: 'a',
        value: p.a,
        min: kKeplerMinA,
        max: kKeplerMaxA,
        onChanged: (v) => updateParam('a', v),
        semanticLabel: '半長軸 a',
      ),
      _KeplerSlider(
        label: 'e',
        value: p.e,
        min: 0.0,
        max: kKeplerMaxE,
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
                  '近点の初期条件（a, e と一対一）',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: null,
                    fontSize: 12,
                  ),
                ),
                Text('r_min = ${rMin.toStringAsFixed(2)}'),
                Text('v_peri = ${vPeri.toStringAsFixed(2)}'),
                Text('T = ${formatKeplerDays(days)}'),
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
    _activeIds = Set<String>.from(activeIds);
    return AnimatedBuilder(
      animation: Listenable.merge([running, phase]),
      builder: (context, _) {
        final p = KeplerLawsParams.fromMap(parameters);
        final main = evolveKeplerEllipse(a: p.a, e: p.e, phase: phase.value);
        KeplerOrbitState? compare;
        if (activeIds.contains(idCompareOrbit)) {
          final a2 = keplerCompareSemiMajor(p.a);
          compare = evolveKeplerEllipse(
            a: a2,
            e: p.e,
            phase: phase.value / kKeplerPeriodRatio,
          );
        }
        return CustomPaint(
          size: Size.infinite,
          painter: _KeplerLaws2DPainter(
            main: main,
            compare: compare,
            running: running.value,
            showEqualArea: activeIds.contains(idEqualArea),
          ),
        );
      },
    );
  }
}

class _KeplerSlider extends StatelessWidget {
  const _KeplerSlider({
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
                  '$semanticLabel ${v.toStringAsFixed(2)}',
            ),
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            value.toStringAsFixed(2),
            style: const TextStyle(fontSize: 12, fontFamily: 'Courier'),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _KeplerLaws2DPainter extends CustomPainter {
  _KeplerLaws2DPainter({
    required this.main,
    required this.compare,
    required this.running,
    required this.showEqualArea,
  });

  final KeplerOrbitState main;
  final KeplerOrbitState? compare;
  final bool running;
  final bool showEqualArea;

  static const _bg = Color(0xFFF7FAFC);
  static const _sun = Color(0xFFFFB300);
  static const _planet = Color(0xFF1E88E5);
  static const _compareColor = Color(0xFF8E24AA);
  static const _orbit = Color(0xFF90A4AE);
  static const _force = Color(0xFFEF6C00);
  static const _sliceColors = [
    Color(0xFF1E88E5),
    Color(0xFFFB8C00),
    Color(0xFF8E24AA),
    Color(0xFF43A047),
    Color(0xFFE53935),
    Color(0xFF00ACC1),
    Color(0xFFFDD835),
    Color(0xFF7C4DFF),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);

    final toScreen = _fitView(size);

    if (showEqualArea) {
      _drawEqualTimeSectors(canvas, toScreen);
    }
    _drawOrbit(canvas, toScreen, main, _orbit, 2.0);
    if (compare != null) {
      _drawOrbit(canvas, toScreen, compare!, _compareColor, 1.6);
    }

    _drawFocus(canvas, toScreen(0, 0), _sun, filled: true, label: '太陽');
    if (main.e > 0.04) {
      _drawFocus(
        canvas,
        toScreen(main.emptyFocusX, 0),
        const Color(0xFF546E7A),
        filled: false,
        label: '空の焦点',
      );
    }

    _drawAxisMarks(canvas, toScreen);
    if (compare != null) {
      _drawPlanet(canvas, toScreen, compare!, _compareColor, '2a');
    }
    _drawPlanet(canvas, toScreen, main, _planet, '惑星');
    _drawHud(canvas, size);
  }

  Offset Function(double, double) _fitView(Size size) {
    var xMin = main.apoapsisX;
    var xMax = main.periapsisX;
    var yMax = main.b;
    if (compare != null) {
      xMin = math.min(xMin, compare!.apoapsisX);
      xMax = math.max(xMax, compare!.periapsisX);
      yMax = math.max(yMax, compare!.b);
    }
    const pad = 0.55;
    xMin -= pad;
    xMax += pad;
    final yMin = -yMax - pad;
    yMax += pad;
    final worldW = xMax - xMin;
    final worldH = yMax - yMin;
    final hudClear = dynamicsReadoutCard(
      _hudLines(),
      keplerMechanicalLedger(main),
      textColumnWidth: 360,
      bounds: size,
    ).bottom + 8;
    final s = math.min(size.width / worldW, (size.height - hudClear) / worldH);
    final ox = (size.width - (xMin + xMax) * s) / 2;
    final oy = hudClear + (size.height - hudClear - (-yMin - yMax) * s) / 2;
    return (x, y) => Offset(ox + x * s, oy - y * s);
  }

  void _drawOrbit(
    Canvas canvas,
    Offset Function(double, double) toScreen,
    KeplerOrbitState orbit,
    Color color,
    double stroke,
  ) {
    final path = Path();
    const samples = 180;
    for (int i = 0; i <= samples; i++) {
      final u = 2 * math.pi * i / samples;
      final p = toScreen(
        orbit.a * (math.cos(u) - orbit.e),
        orbit.b * math.sin(u),
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
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
  }

  void _drawEqualTimeSectors(
    Canvas canvas,
    Offset Function(double, double) toScreen,
  ) {
    final periodDays = keplerLawsPeriodDays(main.a);
    if (periodDays <= 1e-9) return;
    final timeDays = main.phase * periodDays;
    final keep = math.max(8, (2 * periodDays / kKeplerAreaSliceDt).ceil() + 1);
    final slices = keplerEqualTimeSlices(timeDays, keep: keep);
    for (final slice in slices) {
      final color = _sliceColors[slice.colorIndex % _sliceColors.length];
      _fillSector(
        canvas,
        toScreen,
        slice.t0 / periodDays,
        slice.t1 / periodDays,
        color,
      );
    }
  }

  void _fillSector(
    Canvas canvas,
    Offset Function(double, double) toScreen,
    double phase0,
    double phase1,
    Color color,
  ) {
    final origin = toScreen(0, 0);
    final path = Path()..moveTo(origin.dx, origin.dy);
    const n = 32;
    for (int i = 0; i <= n; i++) {
      final ph = phase0 + (phase1 - phase0) * i / n;
      final s = evolveKeplerEllipse(a: main.a, e: main.e, phase: ph);
      final p = toScreen(s.x, s.y);
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..blendMode = BlendMode.srcOver
        ..isAntiAlias = false,
    );
  }

  void _drawFocus(
    Canvas canvas,
    Offset c,
    Color color, {
    required bool filled,
    required String label,
  }) {
    const r = 8.0;
    if (filled) {
      canvas.drawCircle(c, r + 3, Paint()..color = color.withValues(alpha: 0.25));
      canvas.drawCircle(c, r, Paint()..color = color);
    } else {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    _label(canvas, c.translate(0, 14), label, color);
  }

  void _drawAxisMarks(
    Canvas canvas,
    Offset Function(double, double) toScreen,
  ) {
    final peri = toScreen(main.periapsisX, 0);
    final apo = toScreen(main.apoapsisX, 0);
    _label(canvas, peri.translate(0, 22), '近日点', const Color(0xFF1565C0));
    _label(canvas, apo.translate(0, 22), '遠日点', const Color(0xFFEF6C00));
  }

  void _drawPlanet(
    Canvas canvas,
    Offset Function(double, double) toScreen,
    KeplerOrbitState orbit,
    Color color,
    String label,
  ) {
    final p = toScreen(orbit.x, orbit.y);
    canvas.drawCircle(p.translate(0, 2), 11, Paint()..color = Colors.black12);
    canvas.drawCircle(p, 10, Paint()..color = color);
    canvas.drawCircle(
      p,
      10,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _drawForceArrow(canvas, toScreen, orbit);
    _drawVelocityArrow(canvas, toScreen, orbit, color);
    final sun = toScreen(0, 0);
    final inward = sun - p;
    final labelAt = inward.distance > 1
        ? p + inward / inward.distance * 22
        : p.translate(0, -18);
    _label(canvas, labelAt, label, color);
  }

  void _drawForceArrow(
    Canvas canvas,
    Offset Function(double, double) toScreen,
    KeplerOrbitState orbit,
  ) {
    final acc = keplerAcceleration(orbit);
    final mag = math.sqrt(acc.x * acc.x + acc.y * acc.y);
    if (mag < 1e-8) return;
    final p = toScreen(orbit.x, orbit.y);
    final sun = toScreen(0, 0);
    final toward = sun - p;
    final dist = toward.distance;
    if (dist < 1) return;
    final dir = toward / dist;
    const planetR = 12.0;
    const headLen = 12.0;
    const minPx = 28.0;
    const maxPx = 84.0;
    final len = (mag * 52.0).clamp(minPx, maxPx);
    final room = dist - planetR - 16;
    final drawLen = math.min(len, math.max(headLen + 8, room));
    final start = p + dir * planetR;
    final end = start + dir * drawLen;
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
        ..color = _force
        ..strokeWidth = 2.8
        ..strokeCap = StrokeCap.round,
    );
    final head = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        (end - dir * headLen + n * 6.0).dx,
        (end - dir * headLen + n * 6.0).dy,
      )
      ..lineTo(
        (end - dir * headLen - n * 6.0).dx,
        (end - dir * headLen - n * 6.0).dy,
      )
      ..close();
    canvas.drawPath(head, Paint()..color = _force);
    _label(canvas, end + n * 12, '重力', _force);
  }

  void _drawVelocityArrow(
    Canvas canvas,
    Offset Function(double, double) toScreen,
    KeplerOrbitState orbit,
    Color color,
  ) {
    if (orbit.speed < 1e-6) return;
    final p = toScreen(orbit.x, orbit.y);
    final arrow = keplerVelocityArrowOffset(orbit);
    final tip = toScreen(orbit.x + arrow.x, orbit.y + arrow.y);
    final delta = tip - p;
    final len = delta.distance;
    if (len < 1) return;
    final dir = delta / len;
    const planetR = 10.0;
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

  String _hudLines() {
    final periodDays = keplerLawsPeriodDays(main.a);
    final tDays = main.phase * periodDays;
    final area = keplerSweptAreaFromPeriapsis(main.a, main.e, main.phase);
    final rows = <String>[
      't = ${formatKeplerDays(tDays)}    T = ${formatKeplerDays(periodDays)}',
      'r = ${main.r.toStringAsFixed(2)}    v = ${main.speed.toStringAsFixed(2)}',
      '掃いた面積 = ${area.toStringAsFixed(2)}    (∝ t)',
    ];
    if (compare != null) {
      rows.add(
        '比較軌道 T₂ = ${formatKeplerDays(keplerLawsPeriodDays(compare!.a))}  (= 2√2 T)',
      );
    }
    if (running) rows.add('運動中');
    return rows.join('\n');
  }

  void _drawHud(Canvas canvas, Size size) {
    final lines = _hudLines();
    paintDynamicsReadout(
      canvas,
      lines,
      keplerMechanicalLedger(main),
      textColumnWidth: 360,
      bounds: size,
    );
  }

  @override
  bool shouldRepaint(covariant _KeplerLaws2DPainter oldDelegate) {
    return oldDelegate.main.x != main.x ||
        oldDelegate.main.y != main.y ||
        oldDelegate.main.a != main.a ||
        oldDelegate.main.e != main.e ||
        oldDelegate.running != running ||
        oldDelegate.showEqualArea != showEqualArea ||
        oldDelegate.compare?.x != compare?.x ||
        oldDelegate.compare?.a != compare?.a;
  }
}
