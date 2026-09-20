import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
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
  <div class="common-box">使い方</div>
  <p>アニメだけ $GM=1$ にしています。スライダーで半長軸 $a$ と離心率 $e$ を変えられます。</p>
  <p>「第1法則」は空の焦点、「第2法則」は1秒ごとに掃いた面積を色分け、「第3法則」は半長軸を2倍にした軌道です。周期は $\displaystyle 2\sqrt{2}$ 倍なので、内側が3周いかないうちに外側が1周します。Start で動き、リセットで近点に戻ります。</p>
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

enum KeplerLawsPreset { first, second, third }

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

Map<String, double> applyKeplerLawsPreset(
  Map<String, double> current,
  KeplerLawsPreset preset,
) {
  switch (preset) {
    case KeplerLawsPreset.first:
    case KeplerLawsPreset.second:
      return {'a': kKeplerDefaultA, 'e': kKeplerDefaultE};
    case KeplerLawsPreset.third:
      return {
        'a': current['a']?.clamp(kKeplerMinA, kKeplerMaxA).toDouble() ??
            kKeplerDefaultA,
        'e': 0.4,
      };
  }
}

const double kKeplerAreaSliceDt = 1.0;

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
          aspectRatio: 16 / 9,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<bool> running = ValueNotifier(false);
  final ValueNotifier<double> phase = ValueNotifier(0.0);

  Map<String, double> _latestParams = {};
  Set<String> _activeIds = {'emptyFocus'};
  KeplerLawsPreset _selectedLaw = KeplerLawsPreset.first;
  void Function(String key, double value)? _updateParam;
  void Function(Set<String> ids)? _updateActiveIds;
  bool _tickScheduled = false;
  DateTime? _lastTickAt;

  static const String idEmptyFocus = 'emptyFocus';
  static const String idEqualArea = 'equalArea';
  static const String idCompareOrbit = 'compareOrbit';

  @override
  Set<String> get initialActiveIds => {'emptyFocus'};

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

  void applyPreset(KeplerLawsPreset preset) {
    resetMotion();
    _selectedLaw = preset;
    final current = Map<String, double>.from(
      _latestParams.isEmpty ? initialParameters : _latestParams,
    );
    _pushParams(applyKeplerLawsPreset(current, preset));
    final next = <String>{};
    switch (preset) {
      case KeplerLawsPreset.first:
        next.add(idEmptyFocus);
        break;
      case KeplerLawsPreset.second:
        next.add(idEqualArea);
        break;
      case KeplerLawsPreset.third:
        next.add(idCompareOrbit);
        break;
    }
    _updateActiveIds?.call(next);
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
      final tPeriod = keplerPeriod(_params.a);
      phase.value += dt / tPeriod;
      if (running.value) _scheduleTick();
    });
  }

  @override
  Widget? buildFormulaOverlay(Map<String, double> parameters) {
    _rememberParams(parameters);
    final p = _params;
    final t = keplerPeriod(p.a);
    final ratio = t * t / (p.a * p.a * p.a);
    return Column(
      children: [
        const FormulaDisplay(
          r'\displaystyle \frac{T^{2}}{a^{3}}=\frac{4\pi^{2}}{GM}',
        ),
        const SizedBox(height: 4),
        Text(
          'T = ${t.toStringAsFixed(2)}    '
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
                '1秒ごとに面積を塗っています。',
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
                _lawButton('第1法則', KeplerLawsPreset.first),
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
    _updateParam = updateParam;
    final p = KeplerLawsParams.fromMap(parameters);
    final rMin = keplerPeriapsisRadius(p.a, p.e);
    final vPeri = keplerPeriapsisSpeed(p.a, p.e);
    final t = keplerPeriod(p.a);
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
                Text('T = ${t.toStringAsFixed(2)}'),
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
            showEmptyFocus: activeIds.contains(idEmptyFocus),
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
    required this.showEmptyFocus,
    required this.showEqualArea,
  });

  final KeplerOrbitState main;
  final KeplerOrbitState? compare;
  final bool running;
  final bool showEmptyFocus;
  final bool showEqualArea;

  static const _bg = Color(0xFFF7FAFC);
  static const _sun = Color(0xFFFFB300);
  static const _planet = Color(0xFF1E88E5);
  static const _compareColor = Color(0xFF8E24AA);
  static const _orbit = Color(0xFF90A4AE);
  static const _ink = Color(0xFF37474F);
  static const _sliceColors = [
    Color(0x991E88E5),
    Color(0x99FB8C00),
    Color(0x998E24AA),
    Color(0x9943A047),
    Color(0x99E53935),
    Color(0x9900ACC1),
    Color(0x99FDD835),
    Color(0x937C4DFF),
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

    _drawFocus(canvas, toScreen(0, 0), _sun, filled: true, label: '焦点');
    if (showEmptyFocus && main.e > 0.04) {
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
    final s = math.min(size.width / worldW, size.height / worldH);
    final ox = (size.width - (xMin + xMax) * s) / 2;
    final oy = (size.height - (-yMin - yMax) * s) / 2;
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
    final period = main.period;
    if (period <= 1e-9) return;
    final keep = math.max(8, (2 * period / kKeplerAreaSliceDt).ceil() + 1);
    final slices = keplerEqualTimeSlices(main.time, keep: keep);
    for (final slice in slices) {
      final color = _sliceColors[slice.colorIndex % _sliceColors.length];
      _fillSector(
        canvas,
        toScreen,
        slice.t0 / period,
        slice.t1 / period,
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
    canvas.drawPath(path, Paint()..color = color);
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
    _drawVelocityArrow(canvas, toScreen, orbit, color);
    final sun = toScreen(0, 0);
    final inward = sun - p;
    final labelAt = inward.distance > 1
        ? p + inward / inward.distance * 22
        : p.translate(0, -18);
    _label(canvas, labelAt, label, color);
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

  void _drawHud(Canvas canvas, Size size) {
    final t = main.time;
    final area = keplerSweptAreaFromPeriapsis(main.a, main.e, main.phase);
    final lines = StringBuffer()
      ..writeln(
          't = ${t.toStringAsFixed(2)}    T = ${main.period.toStringAsFixed(2)}')
      ..writeln(
          'r = ${main.r.toStringAsFixed(2)}    v = ${main.speed.toStringAsFixed(2)}')
      ..writeln('掃いた面積 = ${area.toStringAsFixed(2)}    (∝ t)');
    if (compare != null) {
      lines.writeln(
        '比較軌道 T₂ = ${compare!.period.toStringAsFixed(2)}  (= 2√2 T)',
      );
    }
    lines.write(running ? '運動中' : 'Start で公転を開始');
    final tp = TextPainter(
      text: TextSpan(
        text: lines.toString(),
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
    canvas.drawRRect(rect, Paint()..color = Colors.white.withValues(alpha: 0.9));
    tp.paint(canvas, const Offset(16, 13));
  }

  @override
  bool shouldRepaint(covariant _KeplerLaws2DPainter oldDelegate) {
    return oldDelegate.main.x != main.x ||
        oldDelegate.main.y != main.y ||
        oldDelegate.main.a != main.a ||
        oldDelegate.main.e != main.e ||
        oldDelegate.running != running ||
        oldDelegate.showEmptyFocus != showEmptyFocus ||
        oldDelegate.showEqualArea != showEqualArea ||
        oldDelegate.compare?.x != compare?.x ||
        oldDelegate.compare?.a != compare?.a;
  }
}
