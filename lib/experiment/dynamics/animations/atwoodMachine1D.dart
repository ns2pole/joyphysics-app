import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/energy_gauge.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// 左のおもりの下向きを正。滑車は軽く、摩擦も軸の慣性もない。$g=9.8\,\mathrm{m/s^2}$。
const double kAtwoodG = 9.8;
const double kAtwoodMinM = 0.50;
const double kAtwoodMaxM = 4.00;
const double kAtwoodDefaultM1 = 2.00;
const double kAtwoodDefaultM2 = 1.00;
const double kAtwoodMinH = 0.40;
const double kAtwoodMaxH = 2.00;
const double kAtwoodDefaultH = 1.20;
const double kAtwoodStrobeDt = 0.10;

class AtwoodParams {
  const AtwoodParams({
    required this.m1,
    required this.m2,
    required this.h,
  });

  final double m1;
  final double m2;
  final double h;

  factory AtwoodParams.fromMap(Map<String, double> params) {
    return AtwoodParams(
      m1: params['m1']!.clamp(kAtwoodMinM, kAtwoodMaxM).toDouble(),
      m2: params['m2']!.clamp(kAtwoodMinM, kAtwoodMaxM).toDouble(),
      h: params['h']!.clamp(kAtwoodMinH, kAtwoodMaxH).toDouble(),
    );
  }

  double get totalMass => m1 + m2;

  /// 左のおもりの下向き加速度。右が重いと負。
  double get acceleration => (m1 - m2) * kAtwoodG / totalMass;

  double get tension => 2 * m1 * m2 * kAtwoodG / totalMass;

  bool get balanced => acceleration.abs() <= 1e-9;
}

class AtwoodSample {
  const AtwoodSample({
    required this.t,
    required this.s,
    required this.v,
    required this.a,
    required this.tension,
    required this.stopped,
  });

  /// 左のおもりの下向き変位。右のおもりは $-s$。
  final double t;
  final double s;
  final double v;
  final double a;
  final double tension;
  final bool stopped;
}

/// 床に着くまでの時間。質量が等しいときは null。
double? atwoodHitTime(AtwoodParams params) {
  final a = params.acceleration.abs();
  if (a <= 1e-12) return null;
  return math.sqrt(2 * params.h / a);
}

/// 着地の速さ。質量が等しいときは null。
double? atwoodHitSpeed(AtwoodParams params) {
  final a = params.acceleration.abs();
  if (a <= 1e-12) return null;
  return math.sqrt(2 * a * params.h);
}

AtwoodSample atwoodAt(AtwoodParams params, double t) {
  final time = math.max(0.0, t);
  final a = params.acceleration;
  if (a.abs() <= 1e-12) {
    return AtwoodSample(
      t: time,
      s: 0,
      v: 0,
      a: 0,
      tension: params.tension,
      stopped: false,
    );
  }
  final tHit = math.sqrt(2 * params.h / a.abs());
  if (time >= tHit) {
    return AtwoodSample(
      t: tHit,
      s: a.sign * params.h,
      v: 0,
      a: 0,
      tension: 0,
      stopped: true,
    );
  }
  return AtwoodSample(
    t: time,
    s: 0.5 * a * time * time,
    v: a * time,
    a: a,
    tension: params.tension,
    stopped: false,
  );
}

/// 床を位置エネルギーの基準にする。着地で失った運動エネルギーは熱にする。
EnergyLedger atwoodEnergy(AtwoodParams params, AtwoodSample sample) {
  final scale = params.totalMass * kAtwoodG * params.h;
  final potential = params.m1 * kAtwoodG * (params.h - sample.s) +
      params.m2 * kAtwoodG * (params.h + sample.s);
  if (sample.stopped) {
    final heat = math.max(0.0, scale - potential);
    return EnergyLedger(
      kinetic: 0,
      potential: potential,
      dissipated: heat,
      scale: scale,
      legendHeat: heat > 1e-6,
      potentialLabel: kLabelGravity,
    );
  }
  final kinetic = 0.5 * params.totalMass * sample.v * sample.v;
  return EnergyLedger(
    kinetic: kinetic,
    potential: math.max(0.0, potential),
    dissipated: 0,
    scale: scale,
    potentialLabel: kLabelGravity,
  );
}

List<AtwoodSample> atwoodStrobe(
  AtwoodParams params,
  double t, {
  double dt = kAtwoodStrobeDt,
}) {
  if (t <= 1e-9 || dt <= 0) return const [];
  final samples = <AtwoodSample>[];
  for (double ti = dt; ti < t - 1e-9; ti += dt) {
    final s = atwoodAt(params, ti);
    if (s.stopped) break;
    samples.add(s);
  }
  return samples;
}

const String kAtwoodCaption =
    '定滑車の両端を、伸びない糸でつなぐ。滑車は軽く、摩擦もない。\n'
    '重いほうが下り、軽いほうが同じだけ上がる。加速度の大きさは同じ。\n'
    '張力は両側で同じ。質量が等しいと加速度は 0 で、動かない。\n'
    '床に着いたところで止める。着地のあとの糸のたるみは扱わない。';

final atwoodMachine1D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '定滑車(アトウッドの器械)',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>定滑車は軽く、軸の摩擦も慣性もないとします。糸は伸びず、質量もありません。左の質量を $m_1$、右を $m_2$ とします。</p>
  <p>糸が伸びないので、左が $s$ だけ下がると右は $s$ だけ上がります。加速度の大きさは両側で同じです。左の下向きを正にすると</p>
  <p>$$a=\frac{(m_1-m_2)g}{m_1+m_2}$$</p>
  <p>張力は両側で同じで</p>
  <p>$$T=\frac{2m_1 m_2 g}{m_1+m_2}$$</p>
  <p>静かに放すと、床に着くまで</p>
  <p>$$s=\frac{1}{2}at^{2},\quad v=at$$</p>
  <p>$m_1>m_2$ なら左が下り、$m_1<m_2$ なら右が下ります。$m_1=m_2$ なら $a=0$、$T=m_1 g$ で、放しても動きません。</p>
  <p>下りる側が距離 $h$ の床に着くまでの時間と速さは</p>
  <p>$$t=\sqrt{\frac{2h}{|a|}},\quad |v|=\sqrt{2|a|h}$$</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: AtwoodMachine1DSimulation(),
      height: 860,
    ),
  ],
);

class AtwoodMachine1DSimulation extends PhysicsSimulation {
  AtwoodMachine1DSimulation()
      : super(
          title: '定滑車(アトウッドの器械)',
          formula: const FormulaDisplay(
            r'\displaystyle a=\frac{(m_1-m_2)g}{m_1+m_2},\quad T=\frac{2m_1 m_2 g}{m_1+m_2}',
          ),
          aspectRatio: 4 / 5,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> simTime = ValueNotifier(0.0);

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    final hit = atwoodHitTime(_params);
    if (hit == null) {
      simTime.value += dt * _playback;
      return;
    }
    final next = math.min(hit, simTime.value + dt * _playback);
    simTime.value = next;
    if (next >= hit - 1e-4) _loop.pause();
  });

  ValueNotifier<bool> get running => _loop.running;

  Map<String, double> _latestParams = {};

  static const double _playback = 0.35;

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'm1': kAtwoodDefaultM1,
        'm2': kAtwoodDefaultM2,
        'h': kAtwoodDefaultH,
      };

  AtwoodParams get _params {
    if (_latestParams.isEmpty) {
      return AtwoodParams.fromMap(initialParameters);
    }
    return AtwoodParams.fromMap(_latestParams);
  }

  void _rememberParams(Map<String, double> params) {
    _latestParams = Map<String, double>.from(params);
  }

  void start() {
    if (running.value) return;
    final hit = atwoodHitTime(_params);
    if (hit != null && simTime.value >= hit - 1e-3) {
      simTime.value = 0.0;
    }
    _loop.start();
  }

  void pause() => _loop.pause();

  void resetMotion() {
    _loop.reset();
    simTime.value = 0.0;
  }

  String _formulaTex() {
    if (_params.balanced) {
      return r'\displaystyle a=0,\quad T=m_1 g';
    }
    return r'\displaystyle a=\frac{(m_1-m_2)g}{m_1+m_2},\quad T=\frac{2m_1 m_2 g}{m_1+m_2}';
  }

  @override
  Widget? buildFormulaOverlay(Map<String, double> parameters) {
    _rememberParams(parameters);
    return FormulaDisplay(_formulaTex());
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
              kAtwoodCaption,
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
    final hit = atwoodHitTime(p);
    final speed = atwoodHitSpeed(p);
    final summary = hit == null
        ? '加速度 0    張力 ${p.tension.toStringAsFixed(2)} N'
        : '着地まで ${hit.toStringAsFixed(2)} s    着地の速さ ${speed!.toStringAsFixed(2)} m/s';
    return [
      const Text(
        '初期条件（g = 9.8 m/s²、静かに放す）',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _AtwoodSlider(
        label: 'm1',
        value: p.m1,
        min: kAtwoodMinM,
        max: kAtwoodMaxM,
        onChanged: (v) => updateParam('m1', v),
        semanticLabel: '左の質量 m1',
      ),
      _AtwoodSlider(
        label: 'm2',
        value: p.m2,
        min: kAtwoodMinM,
        max: kAtwoodMaxM,
        onChanged: (v) => updateParam('m2', v),
        semanticLabel: '右の質量 m2',
      ),
      _AtwoodSlider(
        label: 'h',
        value: p.h,
        min: kAtwoodMinH,
        max: kAtwoodMaxH,
        onChanged: (v) => updateParam('h', v),
        semanticLabel: '床までの距離 h',
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          summary,
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
        final p = AtwoodParams.fromMap(parameters);
        final sample = atwoodAt(p, simTime.value);
        return CustomPaint(
          size: Size.infinite,
          painter: _AtwoodPainter(
            params: p,
            sample: sample,
            strobes: atwoodStrobe(p, sample.t),
            running: running.value,
          ),
        );
      },
    );
  }
}

class _AtwoodSlider extends StatelessWidget {
  const _AtwoodSlider({
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

class _AtwoodPainter extends CustomPainter {
  _AtwoodPainter({
    required this.params,
    required this.sample,
    required this.strobes,
    required this.running,
  });

  final AtwoodParams params;
  final AtwoodSample sample;
  final List<AtwoodSample> strobes;
  final bool running;

  static const _bg = Color(0xFFF7FAFC);
  static const _left = Color(0xFF1E88E5);
  static const _right = Color(0xFF00897B);
  static const _gravity = Color(0xFFEF6C00);
  static const _tension = Color(0xFFAD1457);
  static const _velocity = Color(0xFF1565C0);
  static const _trail = Color(0xFF78909C);
  static const _ink = Color(0xFF37474F);
  static const _floor = Color(0xFF8D6E63);
  static const _pulley = Color(0xFF546E7A);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final layout = _layout(size);
    _drawSupport(canvas, layout);
    _drawFloor(canvas, size, layout);
    _drawString(canvas, layout);
    _drawStrobes(canvas, layout);
    _drawMasses(canvas, layout);
    _drawHud(canvas, size);
  }

  _AtwoodLayout _layout(Size size) {
    final cx = size.width * 0.46;
    final pulleyR = math.min(22.0, size.width * 0.055);
    final lines = _hudLines();
    final ceiling = dynamicsReadoutCard(
      lines,
      atwoodEnergy(params, sample),
      textColumnWidth: 210,
      bounds: size,
    ).bottom;
    final pulley = Offset(cx, ceiling + 8 + pulleyR);
    final r1 = _radius(params.m1);
    final r2 = _radius(params.m2);
    final rMax = math.max(r1, r2);
    final floorY = size.height - 22;
    final topClear = pulley.dy + pulleyR + 12;
    final travel = math.max(24.0, (floorY - topClear - 2 * rMax - 4) / 2);
    final y0 = topClear + rMax + travel;
    return _AtwoodLayout(
      pulley: pulley,
      pulleyR: pulleyR,
      floorY: floorY,
      y0: y0,
      travel: travel,
      r1: r1,
      r2: r2,
    );
  }

  double _radius(double mass) {
    final t = ((mass - kAtwoodMinM) / (kAtwoodMaxM - kAtwoodMinM)).clamp(0.0, 1.0);
    return 16 + 14 * t;
  }

  void _drawSupport(Canvas canvas, _AtwoodLayout layout) {
    final bar = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(layout.pulley.dx, layout.pulley.dy - layout.pulleyR - 12),
        width: 150,
        height: 14,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(bar, Paint()..color = const Color(0xFF78909C));
    canvas.drawCircle(
      layout.pulley.translate(1.5, 2),
      layout.pulleyR,
      Paint()..color = Colors.black12,
    );
    canvas.drawCircle(layout.pulley, layout.pulleyR, Paint()..color = _pulley);
    canvas.drawCircle(
      layout.pulley,
      layout.pulleyR * 0.28,
      Paint()..color = const Color(0xFFECEFF1),
    );
  }

  void _drawFloor(Canvas canvas, Size size, _AtwoodLayout layout) {
    canvas.drawLine(
      Offset(16, layout.floorY),
      Offset(size.width - 12, layout.floorY),
      Paint()
        ..color = _floor
        ..strokeWidth = 3,
    );
    _label(canvas, Offset(28, layout.floorY - 16), '床', _floor);
  }

  void _drawString(Canvas canvas, _AtwoodLayout layout) {
    final leftX = layout.pulley.dx - layout.pulleyR;
    final rightX = layout.pulley.dx + layout.pulleyR;
    final y1 = _massCenter(layout, sample.s, left: true).dy - layout.r1;
    final y2 = _massCenter(layout, sample.s, left: false).dy - layout.r2;
    final paint = Paint()
      ..color = _ink
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(leftX, y1)
      ..lineTo(leftX, layout.pulley.dy)
      ..arcToPoint(
        Offset(rightX, layout.pulley.dy),
        radius: Radius.circular(layout.pulleyR),
        clockwise: false,
      )
      ..lineTo(rightX, y2);
    canvas.drawPath(path, paint);
  }

  Offset _massCenter(_AtwoodLayout layout, double s, {required bool left}) {
    final pixels = (s / params.h) * layout.travel;
    if (left) {
      return Offset(layout.pulley.dx - layout.pulleyR, layout.y0 + pixels);
    }
    return Offset(
      layout.pulley.dx + layout.pulleyR,
      layout.y0 - pixels,
    );
  }

  void _drawStrobes(Canvas canvas, _AtwoodLayout layout) {
    for (final s in strobes) {
      canvas.drawCircle(
        _massCenter(layout, s.s, left: true),
        3.0,
        Paint()..color = _trail.withValues(alpha: 0.85),
      );
      canvas.drawCircle(
        _massCenter(layout, s.s, left: false),
        3.0,
        Paint()..color = _trail.withValues(alpha: 0.85),
      );
    }
  }

  void _drawMasses(Canvas canvas, _AtwoodLayout layout) {
    final c1 = _massCenter(layout, sample.s, left: true);
    final c2 = _massCenter(layout, sample.s, left: false);
    _mass(canvas, c1, layout.r1, _left, 'm1');
    _mass(canvas, c2, layout.r2, _right, 'm2');

    const pxPerNewton = 2.4;
    final g1 = params.m1 * kAtwoodG * pxPerNewton;
    final g2 = params.m2 * kAtwoodG * pxPerNewton;
    _arrowDown(canvas, c1 + Offset(layout.r1 + 10, 0), g1, _gravity, 'm1g');
    _arrowDown(canvas, c2 + Offset(layout.r2 + 10, 0), g2, _gravity, 'm2g');
    if (!sample.stopped && sample.tension > 1e-6) {
      final tLen = sample.tension * pxPerNewton;
      _arrowUp(canvas, c1 + Offset(-layout.r1 - 10, 0), tLen, _tension, 'T');
      _arrowUp(canvas, c2 + Offset(-layout.r2 - 10, 0), tLen, _tension, 'T');
    }
    if (sample.v.abs() > 0.05) {
      final vLen = (sample.v.abs() / math.max(atwoodHitSpeed(params) ?? 1, 0.4) * 48)
          .clamp(12.0, 52.0);
      final down = sample.v > 0;
      _arrowSigned(
        canvas,
        c1.translate(0, down ? layout.r1 : -layout.r1),
        (down ? 1 : -1) * vLen,
        _velocity,
        'v',
      );
      _arrowSigned(
        canvas,
        c2.translate(0, down ? -layout.r2 : layout.r2),
        (down ? -1 : 1) * vLen,
        _velocity,
        'v',
      );
    }
  }

  void _mass(Canvas canvas, Offset c, double r, Color color, String label) {
    canvas.drawCircle(c.translate(1.5, 2), r, Paint()..color = Colors.black12);
    canvas.drawCircle(c, r, Paint()..color = color);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _label(canvas, c, label, Colors.white);
  }

  void _arrowDown(Canvas canvas, Offset origin, double length, Color color, String label) {
    _arrowSigned(canvas, origin, length, color, label);
  }

  void _arrowUp(Canvas canvas, Offset origin, double length, Color color, String label) {
    _arrowSigned(canvas, origin, -length, color, label);
  }

  void _arrowSigned(
    Canvas canvas,
    Offset origin,
    double dy,
    Color color,
    String label,
  ) {
    if (dy.abs() < 2) return;
    final tip = origin.translate(0, dy);
    final dir = dy >= 0 ? 1.0 : -1.0;
    const headLen = 9.0;
    final shaftEnd = tip.translate(0, -dir * headLen * 0.7);
    canvas.drawLine(
      origin,
      shaftEnd,
      Paint()
        ..color = color
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx - 4.5, tip.dy - dir * headLen)
        ..lineTo(tip.dx + 4.5, tip.dy - dir * headLen)
        ..close(),
      Paint()..color = color,
    );
    final labelAt = dy >= 0 ? tip + const Offset(0, 2) : tip + const Offset(0, -14);
    _label(canvas, labelAt, label, color);
  }

  String _hudLines() {
    final hit = atwoodHitTime(params);
    final tail = hit == null
        ? '動かない'
        : sample.stopped
            ? '床に着いた'
            : '着地まで ${hit.toStringAsFixed(2)} s';
    return 't = ${sample.t.toStringAsFixed(2)} s\n'
        's = ${sample.s.toStringAsFixed(2)} m\n'
        'v = ${sample.v.toStringAsFixed(2)} m/s\n'
        'a = ${sample.a.toStringAsFixed(2)} m/s²\n'
        'T = ${sample.tension.toStringAsFixed(2)} N\n'
        '$tail';
  }

  void _drawHud(Canvas canvas, Size size) {
    final lines = _hudLines();
    paintDynamicsReadout(
      canvas,
      lines,
      atwoodEnergy(params, sample),
      textColumnWidth: 210,
      bounds: size,
    );
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
    tp.paint(canvas, Offset(o.dx - tp.width / 2, o.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _AtwoodPainter oldDelegate) {
    return oldDelegate.sample.t != sample.t ||
        oldDelegate.sample.s != sample.s ||
        oldDelegate.sample.v != sample.v ||
        oldDelegate.params.m1 != params.m1 ||
        oldDelegate.params.m2 != params.m2 ||
        oldDelegate.params.h != params.h ||
        oldDelegate.running != running;
  }
}

class _AtwoodLayout {
  const _AtwoodLayout({
    required this.pulley,
    required this.pulleyR,
    required this.floorY,
    required this.y0,
    required this.travel,
    required this.r1,
    required this.r2,
  });

  final Offset pulley;
  final double pulleyR;
  final double floorY;
  final double y0;
  final double travel;
  final double r1;
  final double r2;
}
