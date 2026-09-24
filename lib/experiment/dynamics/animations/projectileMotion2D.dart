import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/energy_gauge.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// 上向き正、水平右向き正。$g=9.8\,\mathrm{m/s^2}$。再生だけ遅くする。
const double kProjectileG = 9.8;
const double kProjectileMinG = 1.6;
const double kProjectileMaxG = 19.6;
const double kProjectileMinV0 = 6.0;
const double kProjectileMaxV0 = 20.0;
const double kProjectileDefaultV0 = 12.0;
const double kProjectileMinDeg = -75.0;
const double kProjectileMaxDeg = 75.0;
const double kProjectileDefaultDeg = 45.0;
const double kProjectileMinH = 2.0;
const double kProjectileMaxH = 12.0;
const double kProjectileDefaultH = 6.0;
const double kProjectileStrobeDt = 0.10;

class ProjectileParams {
  const ProjectileParams({
    required this.v0,
    required this.deg,
    this.h = 0,
    this.g = kProjectileG,
  });

  final double v0;
  final double deg;
  final double h;
  final double g;

  double get rad => deg * math.pi / 180.0;
  double get vx0 => v0 * math.cos(rad);
  double get vy0 => v0 * math.sin(rad);

  factory ProjectileParams.fromMap(Map<String, double> params) {
    return ProjectileParams(
      v0: params['v0']!.clamp(kProjectileMinV0, kProjectileMaxV0).toDouble(),
      deg: params['deg']!.clamp(kProjectileMinDeg, kProjectileMaxDeg).toDouble(),
      h: (params['h'] ?? kProjectileDefaultH)
          .clamp(kProjectileMinH, kProjectileMaxH)
          .toDouble(),
      g: (params['g'] ?? kProjectileG)
          .clamp(kProjectileMinG, kProjectileMaxG)
          .toDouble(),
    );
  }
}

class ProjectileSample {
  const ProjectileSample({
    required this.t,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
  });

  final double t;
  final double x;
  final double y;
  final double vx;
  final double vy;

  double get speed => math.sqrt(vx * vx + vy * vy);
}

/// 質量 1 kg。地面を位置エネルギーの基準にする。空気抵抗はない。
EnergyLedger projectileEnergy(ProjectileParams params, ProjectileSample sample) {
  const mass = 1.0;
  final y = math.max(0.0, sample.y);
  return EnergyLedger(
    kinetic: 0.5 * mass * sample.speed * sample.speed,
    potential: mass * params.g * y,
    dissipated: 0,
    scale: 0.5 * mass * params.v0 * params.v0 + mass * params.g * params.h,
    potentialLabel: kLabelGravity,
  );
}

ProjectileSample projectileAt(ProjectileParams params, double t) {
  final g = params.g;
  final time = math.max(0.0, t);
  return ProjectileSample(
    t: time,
    x: params.vx0 * time,
    y: params.h + params.vy0 * time - 0.5 * g * time * time,
    vx: params.vx0,
    vy: params.vy0 - g * time,
  );
}

double projectileFlightDuration(ProjectileParams params) {
  final g = params.g;
  final vy = params.vy0;
  return (vy + math.sqrt(vy * vy + 2 * g * params.h)) / g;
}

double projectileRange(ProjectileParams params) {
  return params.vx0 * projectileFlightDuration(params);
}

double projectileApexHeight(ProjectileParams params) {
  final vy = params.vy0;
  if (vy <= 0) return params.h;
  return params.h + vy * vy / (2 * params.g);
}

String projectileCaption() {
  return '水平速度は一定。鉛直速度だけが重力で変わる。\n'
      'θ は水平から。正は上向き、負は下向き。\n'
      '上向きなら最高点で鉛直速度は 0。水平速度は残る。\n'
      '下向きなら最高点は投げ出し。着地しても水平速度はそのまま。';
}

List<ProjectileSample> projectileStrobe(
  ProjectileParams params,
  double t, {
  double dt = kProjectileStrobeDt,
}) {
  if (t <= 1e-9 || dt <= 0) return const [];
  final samples = <ProjectileSample>[];
  for (double ti = dt; ti < t - 1e-9; ti += dt) {
    final s = projectileAt(params, ti);
    if (s.y < -1e-6) break;
    samples.add(s);
  }
  return samples;
}

final projectileMotion2D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '斜方投射',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>高さ $h$ の高台から、速さ $v_0$、水平から角度 $\theta$ で投げる。$\theta$ は上向きが正、下向きが負です。空気抵抗を無視すると、水平方向は等速、鉛直方向は重力だけです。</p>
  <p>$$\displaystyle x=(v_0\cos\theta)\,t$$</p>
  <p>$$\displaystyle y=h+(v_0\sin\theta)\,t-\frac{1}{2}gt^{2}$$</p>
  <p>$$\displaystyle v_x=v_0\cos\theta,\quad v_y=v_0\sin\theta-gt$$</p>
  <p>地面 $y=0$ に着くまでの時間は</p>
  <p>$$\displaystyle T=\frac{v_0\sin\theta+\sqrt{(v_0\sin\theta)^{2}+2gh}}{g}$$</p>
  <p>上向き（$\theta>0$）の最高点は $\displaystyle H=h+\frac{(v_0\sin\theta)^{2}}{2g}$ です。下向き（$\theta\le 0$）では投げ出しが最高点で、高さは $h$ のままです。</p>
  """,
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: ProjectileMotion2DSimulation(),
      height: 860,
    ),
  ],
);

class ProjectileMotion2DSimulation extends PhysicsSimulation {
  ProjectileMotion2DSimulation()
      : super(
          title: '斜方投射',
          formula: const FormulaDisplay(
            r'\displaystyle y=h+(v_0\sin\theta)t-\frac{1}{2}gt^{2},\quad v_x=v_0\cos\theta',
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

  Map<String, double> _latestParams = {};

  static const double _playback = 0.5;

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'v0': kProjectileDefaultV0,
        'deg': kProjectileDefaultDeg,
        'h': kProjectileDefaultH,
        'g': kProjectileG,
      };

  ProjectileParams get _params {
    if (_latestParams.isEmpty) {
      return ProjectileParams.fromMap(initialParameters);
    }
    return ProjectileParams.fromMap(_latestParams);
  }

  void _rememberParams(Map<String, double> params) {
    _latestParams = Map<String, double>.from(params);
  }

  double get _duration => projectileFlightDuration(_params);

  void start() {
    if (running.value) return;
    if (simTime.value >= _duration - 1e-3) {
      simTime.value = 0.0;
    }
    _loop.start();
  }

  void pause() => _loop.pause();

  void resetMotion() {
    _loop.reset();
    simTime.value = 0.0;
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
              projectileCaption(),
              textAlign: TextAlign.center,
              style: const TextStyle(
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
    final range = projectileRange(p);
    final apex = projectileApexHeight(p);
    final duration = projectileFlightDuration(p);
    return [
      const Text(
        '初期条件',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _ProjectileSlider(
        label: 'g',
        value: p.g,
        min: kProjectileMinG,
        max: kProjectileMaxG,
        onChanged: (v) => updateParam('g', v),
        semanticLabel: '重力加速度 g',
      ),
      _ProjectileSlider(
        label: 'v0',
        value: p.v0,
        min: kProjectileMinV0,
        max: kProjectileMaxV0,
        onChanged: (v) => updateParam('v0', v),
        semanticLabel: '初速度 v0',
      ),
      _ProjectileSlider(
        label: 'h',
        value: p.h,
        min: kProjectileMinH,
        max: kProjectileMaxH,
        onChanged: (v) => updateParam('h', v),
        semanticLabel: '高台の高さ h',
      ),
      _ProjectileSlider(
        label: 'θ',
        value: p.deg,
        min: kProjectileMinDeg,
        max: kProjectileMaxDeg,
        onChanged: (v) => updateParam('deg', v),
        semanticLabel: '投射角 θ',
        fractionDigits: 0,
        suffix: '°',
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '到達 ${range.toStringAsFixed(2)} m    '
          '最高 ${apex.toStringAsFixed(2)} m    '
          '着地まで ${duration.toStringAsFixed(2)} s',
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
        final p = ProjectileParams.fromMap(parameters);
        final duration = projectileFlightDuration(p);
        final landed = simTime.value >= duration - 1e-4 && simTime.value > 0;
        final t = landed ? duration : math.min(simTime.value, duration);
        final sample = projectileAt(p, t);
        final shown = landed
            ? ProjectileSample(
                t: sample.t,
                x: sample.x,
                y: 0,
                vx: sample.vx,
                vy: sample.vy,
              )
            : sample;
        return CustomPaint(
          size: Size.infinite,
          painter: _ProjectilePainter(
            params: p,
            sample: shown,
            strobes: projectileStrobe(p, shown.t),
          ),
        );
      },
    );
  }
}

class _ProjectileSlider extends StatelessWidget {
  const _ProjectileSlider({
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
          width: 32,
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
                  '$semanticLabel ${v.toStringAsFixed(fractionDigits)}$suffix',
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

class _ProjectilePainter extends CustomPainter {
  _ProjectilePainter({
    required this.params,
    required this.sample,
    required this.strobes,
  });

  final ProjectileParams params;
  final ProjectileSample sample;
  final List<ProjectileSample> strobes;

  static const _bg = Color(0xFFF7FAFC);
  static const _ball = Color(0xFF1E88E5);
  static const _vx = Color(0xFF00897B);
  static const _vy = Color(0xFF5E35B1);
  static const _force = Color(0xFFEF6C00);
  static const _trail = Color(0xFF78909C);
  static const _ground = Color(0xFF8D6E63);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final lines = _hudLines();
    final ledger = projectileEnergy(params, sample);
    final cardBottom = dynamicsReadoutCard(
      lines,
      ledger,
      textColumnWidth: 248,
      bounds: size,
    ).bottom;
    final map = _mapper(size, cardBottom);
    _drawGround(canvas, size, map);
    _drawTrail(canvas, map);
    _drawBall(canvas, map);
    paintDynamicsReadout(
      canvas,
      lines,
      ledger,
      textColumnWidth: 248,
      bounds: size,
    );
  }

  String _hudLines() {
    return 't = ${sample.t.toStringAsFixed(2)} s\n'
        'x = ${sample.x.toStringAsFixed(2)} m    y = ${sample.y.toStringAsFixed(2)} m\n'
        'vx = ${sample.vx.toStringAsFixed(2)}    vy = ${sample.vy.toStringAsFixed(2)} m/s';
  }

  _Map _mapper(Size size, double cardBottom) {
    final range = math.max(projectileRange(params), 1.0);
    final apex = math.max(projectileApexHeight(params), params.h);
    final xMin = -math.max(2.2, range * 0.1);
    final xMax = range + 0.7;
    const yMin = -0.25;
    final yMax = apex + 0.45;
    const margin = 16.0;
    final top = math.max(margin + 100.0, cardBottom + 12);
    final sx = (size.width - margin * 2) / (xMax - xMin);
    final sy = (size.height - top - margin) / (yMax - yMin);
    final s = math.min(sx, sy);
    final ox = margin - xMin * s + (size.width - margin * 2 - (xMax - xMin) * s) / 2;
    final oy = size.height - margin + yMin * s -
        (size.height - top - margin - (yMax - yMin) * s) / 2;
    return _Map(
      of: (x, y) => Offset(ox + x * s, oy - y * s),
      pxPerSpeed: math.min(5.5, 70 / math.max(params.v0, 1)),
    );
  }

  void _drawGround(Canvas canvas, Size size, _Map map) {
    final lip = map.of(0, params.h);
    final foot = map.of(0, 0);
    final back = map.of(-math.max(2.2, projectileRange(params) * 0.1), params.h);
    final groundEnd = map.of(projectileRange(params) + 0.7, 0);
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
      groundEnd,
      Paint()
        ..color = _ground
        ..strokeWidth = 3,
    );
    _label(canvas, lip + const Offset(-18, -16), '高台', _ground);
  }

  void _drawTrail(Canvas canvas, _Map map) {
    final pts = <Offset>[map.of(0, params.h)];
    for (final s in strobes) {
      pts.add(map.of(s.x, math.max(0, s.y)));
    }
    pts.add(map.of(sample.x, math.max(0, sample.y)));
    final paint = Paint()
      ..color = _trail
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    const dash = 5.0;
    const gap = 4.0;
    for (int i = 0; i < pts.length - 1; i++) {
      final a = pts[i];
      final b = pts[i + 1];
      final delta = b - a;
      final len = delta.distance;
      if (len < 1) continue;
      final dir = delta / len;
      double d = 0;
      var draw = i.isEven;
      while (d < len) {
        final end = math.min(d + (draw ? dash : gap), len);
        if (draw) {
          canvas.drawLine(a + dir * d, a + dir * end, paint);
        }
        d = end;
        if (d < len) draw = !draw;
      }
    }
    for (final s in strobes) {
      canvas.drawCircle(map.of(s.x, math.max(0, s.y)), 3.1, Paint()..color = _trail);
    }
  }

  void _drawBall(Canvas canvas, _Map map) {
    final c = map.of(sample.x, math.max(0, sample.y));
    canvas.drawCircle(c.translate(0, 2), 11, Paint()..color = Colors.black12);
    canvas.drawCircle(c, 10, Paint()..color = _ball);
    final gLen = (46 * params.g / kProjectileG).clamp(18.0, 92.0);
    _arrow(canvas, c + const Offset(-14, 0), const Offset(0, 1), gLen, _force, '重力');
    final scale = map.pxPerSpeed;
    if (sample.vx.abs() > 0.2) {
      _arrow(
        canvas,
        c,
        const Offset(1, 0),
        (sample.vx.abs() * scale).clamp(14.0, 78.0),
        _vx,
        'vx',
      );
    }
    if (sample.vy.abs() < 0.4) {
      _label(canvas, c + const Offset(22, -18), 'vy = 0', _vy);
    } else {
      final dir = sample.vy >= 0 ? const Offset(0, -1) : const Offset(0, 1);
      _arrow(
        canvas,
        c,
        dir,
        (sample.vy.abs() * scale).clamp(12.0, 78.0),
        _vy,
        'vy',
      );
    }
    if (sample.speed > 0.3) {
      final screenDir = Offset(sample.vx, -sample.vy);
      final len = screenDir.distance;
      if (len > 1e-6) {
        _arrow(
          canvas,
          c,
          screenDir / len,
          (sample.speed * scale).clamp(16.0, 88.0),
          _ball,
          'v',
        );
      }
    }
  }

  void _arrow(
    Canvas canvas,
    Offset origin,
    Offset dir,
    double length,
    Color color,
    String label,
  ) {
    final tip = origin + dir * length;
    const headLen = 10.0;
    const headHalf = 5.0;
    final shaftEnd = tip - dir * (headLen * 0.72);
    final n = Offset(-dir.dy, dir.dx);
    canvas.drawLine(
      origin,
      shaftEnd,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 4.4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      origin,
      shaftEnd,
      Paint()
        ..color = color
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    final head = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo((tip - dir * headLen + n * headHalf).dx, (tip - dir * headLen + n * headHalf).dy)
      ..lineTo((tip - dir * headLen - n * headHalf).dx, (tip - dir * headLen - n * headHalf).dy)
      ..close();
    canvas.drawPath(head, Paint()..color = color);
    _label(canvas, tip + n * 11, label, color);
  }

  void _label(Canvas canvas, Offset o, String text, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(o.dx - tp.width / 2, o.dy));
  }

  @override
  bool shouldRepaint(covariant _ProjectilePainter oldDelegate) {
    return oldDelegate.sample.t != sample.t ||
        oldDelegate.sample.x != sample.x ||
        oldDelegate.sample.y != sample.y ||
        oldDelegate.params.v0 != params.v0 ||
        oldDelegate.params.deg != params.deg ||
        oldDelegate.params.h != params.h ||
        oldDelegate.params.g != params.g;
  }
}

class _Map {
  const _Map({required this.of, required this.pxPerSpeed});

  final Offset Function(double x, double y) of;
  final double pxPerSpeed;
}
