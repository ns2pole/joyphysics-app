import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';
import 'package:joyphysics/l10n/anim_ui.dart';

/// 台上の距離 $R$ に固定された物体。台は角速度 0 から角加速度 $\alpha$ で回り始める。
const double kEulerMinR = 0.60;
const double kEulerMaxR = 1.40;
const double kEulerDefaultR = 1.00;
const double kEulerMinA = 0.40;
const double kEulerMaxA = 1.60;
const double kEulerDefaultA = 0.80;
const double kEulerMinM = 0.50;
const double kEulerMaxM = 4.00;
const double kEulerDefaultM = 1.00;
const double kEulerSideBySideWidth = 640.0;

class EulerParams {
  const EulerParams({required this.r, required this.alpha, required this.mass});

  final double r;
  final double alpha;
  final double mass;

  /// 3回転するまでの時間。$\theta=\frac{1}{2}\alpha t^{2}=6\pi$。
  double get duration => math.sqrt(12 * math.pi / alpha);

  factory EulerParams.fromMap(Map<String, double> params) {
    return EulerParams(
      r: params['r']!.clamp(kEulerMinR, kEulerMaxR).toDouble(),
      alpha: params['A']!.clamp(kEulerMinA, kEulerMaxA).toDouble(),
      mass: params['m']!.clamp(kEulerMinM, kEulerMaxM).toDouble(),
    );
  }
}

class EulerSample {
  const EulerSample({
    required this.t,
    required this.theta,
    required this.omega,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.realRadial,
    required this.realTangential,
    required this.centrifugal,
    required this.euler,
  });

  final double t;
  final double theta;
  final double omega;
  final double x;
  final double y;
  final double vx;
  final double vy;

  /// 外向き正。台上では物体は静止する。
  final double realRadial;
  final double realTangential;
  final double centrifugal;
  final double euler;

  double get speed => math.sqrt(vx * vx + vy * vy);
}

EulerSample eulerAt(EulerParams params, double t) {
  final time = math.max(0.0, t).clamp(0.0, params.duration).toDouble();
  final theta = 0.5 * params.alpha * time * time;
  final omega = params.alpha * time;
  final c = math.cos(theta);
  final s = math.sin(theta);
  final radial = params.mass * omega * omega * params.r;
  final tangential = params.mass * params.alpha * params.r;
  return EulerSample(
    t: time,
    theta: theta,
    omega: omega,
    x: params.r * c,
    y: params.r * s,
    vx: -params.r * omega * s,
    vy: params.r * omega * c,
    realRadial: -radial,
    realTangential: tangential,
    centrifugal: radial,
    euler: -tangential,
  );
}

String eulerCaption() {
  return animL('台上の物体は、台といっしょに角速度 0 から回り始める。\n地上では静止摩擦が、中心向きと接線方向に働く。\n台上では物体は静止し、オイラー力と遠心力を足すとつり合う。', 'The object on the platform starts rotating with the platform from angular velocity 0.\nOn the ground, static friction acts toward the center and tangentially.\nOn the platform the object is at rest; adding the Euler force and centrifugal force restores equilibrium.');
}

final eulerForce2D = Video(
  isNew: false,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: 'オイラー力',
  titleEn: 'Euler force',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>水平な台の上で、中心から距離 $R$ の物体が台に固定されています。台は止まっている状態から、一定の角加速度 $\alpha$ で回り始めます。広い画面では左右、狭い画面では上下です。上または左が地上、下または右が台上です。</p>
  <p>$$ \omega=\alpha t,\quad \theta=\frac{1}{2}\alpha t^{2} $$</p>
  <p>物体は台の上に置いてあるだけで、働く力は静止摩擦です。地上から見ると、物体は円周上を速さを増しながら動きます。静止摩擦は、中心向きの $\displaystyle m\omega^{2}R$ と、回転が速くなる向きの $\displaystyle m\alpha R$ に分かれます。</p>
  <p>台といっしょに回る人から見ると、物体は止まっています。この座標系での速度は $0$ なので、コリオリ力は出ません。外向きの遠心力 $\displaystyle m\omega^{2}R$ が中心向きの摩擦と、接線の逆向きのオイラー力 $\displaystyle m\alpha R$ が接線方向の摩擦と、それぞれつり合います。$t=0$ では遠心力はまだ $0$ で、慣性力はオイラー力だけです。</p>
""",
  latexEn: r"""
  <div class="common-box">Key points</div>
  <p>On a horizontal platform, an object at distance $R$ from the center is fixed to the platform. Starting from rest, the platform begins to rotate with constant angular acceleration $\alpha$. On a wide screen the views are side by side; on a narrow screen they are stacked. Top or left is the lab frame; bottom or right is the platform frame.</p>
  <p>$$ \omega=\alpha t,\quad \theta=\frac{1}{2}\alpha t^{2} $$</p>
  <p>The object rests on the platform, so the force acting is static friction. In the lab frame the object moves on a circle with increasing speed. Static friction splits into a centripetal part $\displaystyle m\omega^{2}R$ and a tangential part $\displaystyle m\alpha R$ in the sense of speeding up.</p>
  <p>Relative to a person rotating with the platform, the object is at rest. The velocity in this frame is $0$, so there is no Coriolis force. The outward centrifugal force $\displaystyle m\omega^{2}R$ balances the inward friction, and the Euler force $\displaystyle m\alpha R$ opposite to the tangential direction balances the tangential friction. At $t=0$ the centrifugal force is still $0$, so the only inertial force is the Euler force.</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: EulerForce2DSimulation(),
      height: 980,
    ),
  ],
);

class EulerForce2DSimulation extends PhysicsSimulation {
  EulerForce2DSimulation()
      : super(
          title: animL('オイラー力', 'Euler force'),
          formula: const FormulaDisplay(
            r'\displaystyle F_{\mathrm{E}}=m\alpha R',
          ),
          aspectRatio: 0.72,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> simTime = ValueNotifier(0.0);
  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    final limit = _params.duration;
    final next = math.min(limit, simTime.value + dt * 0.70);
    simTime.value = next;
    if (next >= limit - 1e-4) _loop.pause();
  });

  @override
  String? get situation =>
      animL('慣性系で見ると、回転速度が上昇する台の上に滑らず乗っている物体', 'In the inertial frame: an object riding without slipping on a platform whose rotation rate is increasing');

  ValueNotifier<bool> get running => _loop.running;
  Map<String, double> _latestParams = {};

  @override
  double aspectRatioForWidth(double width) {
    return width >= kEulerSideBySideWidth ? 1.85 : 0.72;
  }

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'r': kEulerDefaultR,
        'A': kEulerDefaultA,
        'm': kEulerDefaultM,
      };

  EulerParams get _params {
    if (_latestParams.isEmpty) return EulerParams.fromMap(initialParameters);
    return EulerParams.fromMap(_latestParams);
  }

  @override
  void startPlayback() => start();

  void start() {
    if (running.value) return;
    if (simTime.value >= _params.duration - 1e-3) simTime.value = 0.0;
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
              eulerCaption(),
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
    _latestParams = Map<String, double>.from(parameters);
    final p = _params;
    final s = eulerAt(p, simTime.value);
    return [
      Text(
        animL('台上に固定。角速度 0 から角加速度 α で回る', 'Fixed on the platform. Rotates from angular velocity 0 with angular acceleration α'),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _EulerSlider(
        label: 'R',
        value: p.r,
        min: kEulerMinR,
        max: kEulerMaxR,
        onChanged: (v) => updateParam('r', v),
        semanticLabel: animL('中心からの距離 R', 'Distance from center R'),
      ),
      _EulerSlider(
        label: 'α',
        value: p.alpha,
        min: kEulerMinA,
        max: kEulerMaxA,
        onChanged: (v) => updateParam('A', v),
        semanticLabel: animL('角加速度 α', 'Angular acceleration α'),
      ),
      _EulerSlider(
        label: 'm',
        value: p.mass,
        min: kEulerMinM,
        max: kEulerMaxM,
        onChanged: (v) => updateParam('m', v),
        semanticLabel: animL('質量 m', 'Mass m'),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'ω = ${s.omega.toStringAsFixed(2)} rad/s\n' +
          animL('摩擦（中心） ${(-s.realRadial).toStringAsFixed(2)} N    摩擦（接線） ${s.realTangential.toStringAsFixed(2)} N\n遠心力 ${s.centrifugal.toStringAsFixed(2)} N    オイラー力 ${(-s.euler).toStringAsFixed(2)} N', 'Friction (radial) ${(-s.realRadial).toStringAsFixed(2)} N    Friction (tangential) ${s.realTangential.toStringAsFixed(2)} N\nCentrifugal force ${s.centrifugal.toStringAsFixed(2)} N    Euler force ${(-s.euler).toStringAsFixed(2)} N'),
          style: const TextStyle(fontSize: 12, fontFamily: 'Courier', color: Color(0xFF37474F)),
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
    _latestParams = Map<String, double>.from(parameters);
    return AnimatedBuilder(
      animation: Listenable.merge([running, simTime]),
      builder: (context, _) {
        final p = EulerParams.fromMap(parameters);
        return CustomPaint(
          size: Size.infinite,
          painter: _EulerPainter(params: p, sample: eulerAt(p, simTime.value)),
        );
      },
    );
  }
}

class _EulerSlider extends StatelessWidget {
  const _EulerSlider({
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
              semanticFormatterCallback: (v) => '$semanticLabel ${v.toStringAsFixed(2)}',
            ),
          ),
        ),
        SizedBox(
          width: 52,
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

class _EulerPainter extends CustomPainter {
  _EulerPainter({required this.params, required this.sample});

  final EulerParams params;
  final EulerSample sample;

  static const _bg = Color(0xFFF7FAFC);
  static const _ball = Color(0xFF1E88E5);
  static const _real = Color(0xFFEF6C00);
  static const _velocity = Color(0xFF5D4037);
  static const _centrifugal = Color(0xFF2E7D32);
  static const _euler = Color(0xFFC62828);
  static const _orbit = Color(0xFF90A4AE);
  static const _floorA = Color(0xFFE7DFD2);
  static const _floorB = Color(0xFFD2C3B0);
  static const _person = Color(0xFF6D4C41);
  static const _ink = Color(0xFF37474F);
  static const _maxArrow = 72.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final sideBySide = size.width >= kEulerSideBySideWidth && size.width > size.height;
    if (sideBySide) {
      const gap = 8.0;
      final w = (size.width - gap) / 2;
      _panel(canvas, Rect.fromLTWH(0, 0, w, size.height), ground: true);
      _panel(canvas, Rect.fromLTWH(w + gap, 0, w, size.height), ground: false);
    } else {
      const gap = 8.0;
      final h = (size.height - gap) / 2;
      _panel(canvas, Rect.fromLTWH(0, 0, size.width, h), ground: true);
      _panel(canvas, Rect.fromLTWH(0, h + gap, size.width, h), ground: false);
    }
  }

  void _panel(Canvas canvas, Rect panel, {required bool ground}) {
    canvas.save();
    canvas.clipRect(panel);
    final plot = Rect.fromLTRB(panel.left + 8, panel.top + 26, panel.right - 8, panel.bottom - 28);
    final reach = kEulerMaxR * (1.85 / 1.75);
    final scale = math.min(plot.width, plot.height) / (2 * reach);
    Offset of(double x, double y) => Offset(plot.center.dx + x * scale, plot.center.dy - y * scale);
    _drawFloor(canvas, panel, of, scale, ground: ground);
    canvas.drawRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFCFD8DC),
    );
    _text(
      canvas,
      Offset(panel.left + 8, panel.top + 6),
      ground ? animL('地上（慣性系）', 'Ground (inertial frame)') : animL('台上（非慣性系）', 'On platform (non-inertial)'),
      _ink,
      alignLeft: true,
    );
    _scene(canvas, of, ground: ground);
    _text(
      canvas,
      Offset(panel.center.dx, panel.bottom - 18),
      ground ? animL('速さを増しながら円を描く。', 'Traces a circle while speeding up.') : animL('物体は静止し、力はつり合う。', 'The object is at rest; forces balance.'),
      const Color(0xFF546E7A),
    );
    canvas.restore();
  }

  void _scene(Canvas canvas, Offset Function(double x, double y) of, {required bool ground}) {
    final pin = of(0, 0);
    final ball = ground ? of(sample.x, sample.y) : of(params.r, 0);
    canvas.drawCircle(
      pin,
      (ball - pin).distance,
      Paint()
        ..color = _orbit
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    final nose = ground ? sample.theta : 0.0;
    canvas.drawCircle(pin, 7, Paint()..color = _person);
    canvas.drawLine(
      pin,
      pin + Offset(16 * math.cos(nose), -16 * math.sin(nose)),
      Paint()
        ..color = _person
        ..strokeWidth = 2,
    );
    _text(canvas, pin + Offset(0, 10), animL('人', 'Person'), _person);
    canvas.drawCircle(ball.translate(1.2, 1.4), 9, Paint()..color = Colors.black12);
    canvas.drawCircle(ball, 8, Paint()..color = _ball);
    _forces(canvas, pin, ball, of, ground: ground);
  }

  void _forces(
    Canvas canvas,
    Offset pin,
    Offset ball,
    Offset Function(double x, double y) of, {
    required bool ground,
  }) {
    final inward = pin - ball;
    final inwardLen = inward.distance;
    if (inwardLen <= 8) return;
    final inDir = inward / inwardLen;
    final side = Offset(-inDir.dy, inDir.dx);
    _arrow(canvas, ball, inDir, _px(sample.realRadial.abs()), _real, animL('摩擦', 'Friction'));
    _arrow(canvas, ball, side, _px(sample.realTangential), _real, animL('摩擦', 'Friction'));
    if (!ground) {
      _arrow(
        canvas,
        ball,
        -inDir,
        _px(sample.centrifugal),
        _centrifugal,
        animL('遠心力', 'Centrifugal force'),
        dashed: true,
        labelDir: side,
      );
      _arrow(
        canvas,
        ball,
        -side,
        _px(sample.euler.abs()),
        _euler,
        animL('オイラー', 'Euler'),
        dashed: true,
        labelDir: inDir,
      );
    } else if (sample.speed > 0.05) {
      final velDir = _unit(sample.vx, sample.vy, of);
      if (velDir != null) {
        _arrow(canvas, ball, velDir, (sample.speed * 16).clamp(18.0, 64.0), _velocity, 'v');
      }
    }
  }

  /// いま描いている力のうち最大を画面上限にする。中心向きと接線は同じ尺度。
  double _px(double newtons) {
    final tangent = params.mass * params.alpha * params.r;
    final peak = math.max(sample.centrifugal.abs(), tangent.abs());
    if (peak < 1e-9) return 0;
    return newtons / peak * _maxArrow;
  }

  Offset? _unit(double vx, double vy, Offset Function(double x, double y) of) {
    final ahead = of(vx, vy) - of(0, 0);
    if (ahead.distance < 1e-6) return null;
    return ahead / ahead.distance;
  }

  void _drawFloor(
    Canvas canvas,
    Rect panel,
    Offset Function(double x, double y) of,
    double scale, {
    required bool ground,
  }) {
    final spacing = (28 / scale).clamp(0.28, 1.2);
    final origin = of(0, 0);
    var radius = spacing;
    for (final corner in [panel.topLeft, panel.topRight, panel.bottomLeft, panel.bottomRight]) {
      final dx = (corner.dx - origin.dx) / scale;
      final dy = (origin.dy - corner.dy) / scale;
      radius = math.max(radius, math.sqrt(dx * dx + dy * dy));
    }
    radius += spacing;
    final n = (radius / spacing).ceil() + 1;
    for (var ix = -n; ix < n; ix++) {
      for (var iy = -n; iy < n; iy++) {
        final x0 = ix * spacing.toDouble();
        final y0 = iy * spacing.toDouble();
        final corners = [
          _floorPoint(x0, y0, ground),
          _floorPoint(x0 + spacing, y0, ground),
          _floorPoint(x0 + spacing, y0 + spacing, ground),
          _floorPoint(x0, y0 + spacing, ground),
        ];
        final path = Path();
        for (var i = 0; i < corners.length; i++) {
          final p = of(corners[i].dx, corners[i].dy);
          if (i == 0) {
            path.moveTo(p.dx, p.dy);
          } else {
            path.lineTo(p.dx, p.dy);
          }
        }
        path.close();
        canvas.drawPath(path, Paint()..color = (ix + iy).isEven ? _floorA : _floorB);
      }
    }
  }

  /// 模様は台に固定。地上では $\theta$ だけ回り、台上では止まって見える。
  Offset _floorPoint(double x, double y, bool ground) {
    if (!ground) return Offset(x, y);
    final c = math.cos(sample.theta);
    final s = math.sin(sample.theta);
    return Offset(x * c - y * s, x * s + y * c);
  }

  void _arrow(
    Canvas canvas,
    Offset origin,
    Offset dir,
    double length,
    Color color,
    String label, {
    bool dashed = false,
    Offset? labelDir,
  }) {
    if (length < 2) return;
    final tip = origin + dir * length;
    const headLen = 9.0;
    const headHalf = 4.5;
    final shaftEnd = tip - dir * (headLen * 0.7);
    final n = labelDir ?? Offset(-dir.dy, dir.dx);
    final shaft = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    if (!dashed) {
      canvas.drawLine(origin, shaftEnd, shaft);
    } else {
      final delta = shaftEnd - origin;
      final len = delta.distance;
      if (len > 1) {
        final step = delta / len;
        var d = 0.0;
        while (d < len) {
          canvas.drawLine(origin + step * d, origin + step * math.min(d + 4, len), shaft);
          d += 7;
        }
      }
    }
    final head = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo((tip - dir * headLen + n * headHalf).dx, (tip - dir * headLen + n * headHalf).dy)
      ..lineTo((tip - dir * headLen - n * headHalf).dx, (tip - dir * headLen - n * headHalf).dy)
      ..close();
    canvas.drawPath(head, Paint()..color = color);
    final labelN = n.distance < 1e-6 ? n : n / n.distance;
    _text(canvas, tip + labelN * 13, label, color);
  }

  void _text(Canvas canvas, Offset o, String text, Color color, {bool alignLeft = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700, height: 1.25),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(alignLeft ? o.dx : o.dx - tp.width / 2, o.dy));
  }

  @override
  bool shouldRepaint(covariant _EulerPainter oldDelegate) {
    return oldDelegate.sample.t != sample.t ||
        oldDelegate.params.r != params.r ||
        oldDelegate.params.alpha != params.alpha ||
        oldDelegate.params.mass != params.mass;
  }
}
