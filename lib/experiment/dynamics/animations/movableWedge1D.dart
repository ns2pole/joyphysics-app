import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/energy_gauge.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// 右向き正、上向き正。斜面は左下がり。至るところ摩擦なし。$g=9.8\,\mathrm{m/s^2}$。
const double kWedgeG = 9.8;
const double kWedgeMinTheta = 20.0;
const double kWedgeMaxTheta = 60.0;
const double kWedgeDefaultTheta = 30.0;
const double kWedgeMinM = 0.5;
const double kWedgeMaxM = 8.0;
const double kWedgeDefaultM = 2.0;
const double kWedgeMinBlock = 0.2;
const double kWedgeMaxBlock = 4.0;
const double kWedgeDefaultBlock = 1.0;
const double kWedgeMinLength = 0.8;
const double kWedgeMaxLength = 3.0;
const double kWedgeDefaultLength = 1.5;
const double kWedgeSideBySideWidth = 640.0;

class MovableWedgeParams {
  const MovableWedgeParams({
    required this.thetaDeg,
    required this.cartMass,
    required this.blockMass,
    required this.length,
  });

  final double thetaDeg;
  final double cartMass;
  final double blockMass;
  final double length;

  double get theta => thetaDeg * math.pi / 180.0;

  factory MovableWedgeParams.fromMap(Map<String, double> params) {
    return MovableWedgeParams(
      thetaDeg: params['theta']!.clamp(kWedgeMinTheta, kWedgeMaxTheta).toDouble(),
      cartMass: params['M']!.clamp(kWedgeMinM, kWedgeMaxM).toDouble(),
      blockMass: params['m']!.clamp(kWedgeMinBlock, kWedgeMaxBlock).toDouble(),
      length: params['l']!.clamp(kWedgeMinLength, kWedgeMaxLength).toDouble(),
    );
  }
}

class MovableWedgeSample {
  const MovableWedgeSample({
    required this.t,
    required this.s,
    required this.xCart,
    required this.xBlock,
    required this.yBlock,
    required this.landed,
  });

  final double t;
  final double s;
  final double xCart;
  final double xBlock;
  final double yBlock;
  final bool landed;
}

const Color _kWedgeBlockEnergy = Color(0xFF7B1FA2);
const Color _kWedgeCartEnergy = Color(0xFFAD1457);

/// 摩擦なし。小物体と台の運動エネルギーと、小物体の重力位置エネルギー。
EnergyLedger movableWedgeEnergy(
  MovableWedgeParams params,
  MovableWedgeSample sample,
) {
  final th = params.theta;
  final vRel = wedgeRelativeAcceleration(params) * sample.t;
  final vCart = wedgeCartAcceleration(params) * sample.t;
  final vx = vCart - vRel * math.cos(th);
  final vy = -vRel * math.sin(th);
  final blockKinetic = 0.5 * params.blockMass * (vx * vx + vy * vy);
  final cartKinetic = 0.5 * params.cartMass * vCart * vCart;
  final potential = params.blockMass * kWedgeG * math.max(0.0, sample.yBlock);
  return EnergyLedger(
    kinetic: blockKinetic + cartKinetic,
    potential: potential,
    dissipated: 0,
    scale: params.blockMass * kWedgeG * params.length * math.sin(th),
    potentialLabel: kLabelGravity,
    kineticPortions: [
      EnergyPortion(
        value: blockKinetic,
        label: 'm の運動エネルギー',
        color: _kWedgeBlockEnergy,
      ),
      EnergyPortion(
        value: cartKinetic,
        label: 'M の運動エネルギー',
        color: _kWedgeCartEnergy,
      ),
    ],
  );
}

double wedgeCartAcceleration(MovableWedgeParams params) {
  final s = math.sin(params.theta);
  final c = math.cos(params.theta);
  final m = params.blockMass;
  final big = params.cartMass;
  return m * kWedgeG * s * c / (big + m * s * s);
}

double wedgeRelativeAcceleration(MovableWedgeParams params) {
  final th = params.theta;
  return kWedgeG * math.sin(th) + wedgeCartAcceleration(params) * math.cos(th);
}

double wedgeNormal(MovableWedgeParams params) {
  final th = params.theta;
  return params.blockMass *
      (kWedgeG * math.cos(th) - wedgeCartAcceleration(params) * math.sin(th));
}

double wedgeSlideDuration(MovableWedgeParams params) {
  return math.sqrt(2 * params.length / wedgeRelativeAcceleration(params));
}

double wedgeCartDistance(MovableWedgeParams params) {
  return params.blockMass *
      params.length *
      math.cos(params.theta) /
      (params.cartMass + params.blockMass);
}

MovableWedgeSample movableWedgeAt(MovableWedgeParams params, double t) {
  final duration = wedgeSlideDuration(params);
  final time = math.max(0.0, t);
  final landed = time >= duration;
  final used = landed ? duration : time;
  final a = wedgeRelativeAcceleration(params);
  final cartA = wedgeCartAcceleration(params);
  final s = 0.5 * a * used * used;
  final xCart = 0.5 * cartA * used * used;
  final along = params.length - s;
  return MovableWedgeSample(
    t: used,
    s: s,
    xCart: xCart,
    xBlock: xCart + along * math.cos(params.theta),
    yBlock: along * math.sin(params.theta),
    landed: landed,
  );
}

final movableWedge1D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '動く斜面と慣性力',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>なめらかな水平面上に、傾角 $\theta$、質量 $M$ の台がある。斜面もなめらかで、長さは $l$ です。上端に質量 $m$ の小物体を静かに置くと、台は回転せず右向きに加速度 $A$ で動きます。</p>
  <p>地上では、小物体の水平方向の力は垂直抗力の成分だけです。台が受けるのはその反作用です。</p>
  <p>$$m\ddot x=-N\sin\theta,\quad MA=N\sin\theta$$</p>
  <p>小物体が斜面から離れない条件と合わせると</p>
  <p>$$A=\frac{mg\sin\theta\cos\theta}{M+m\sin^{2}\theta}$$</p>
  <p>斜面に沿った相対加速度は $a=g\sin\theta+A\cos\theta$ で、滑り切る時間は</p>
  <p>$$t=\sqrt{\frac{2l}{a}}$$</p>
  <p>台とともに動く系では、左向きの慣性力 $mA$ を加えて小物体の運動を見ます。働く力の一覧は違いますが、$A$、$t$、台の移動距離 $L$ は同じです。水平方向の外力がないので重心は水平に動かず、</p>
  <p>$$L=\frac{ml\cos\theta}{M+m}$$</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: MovableWedgeSimulation(),
      height: 980,
    ),
  ],
);

class MovableWedgeSimulation extends PhysicsSimulation {
  MovableWedgeSimulation()
      : super(
          title: '動く斜面と慣性力',
          formula: const FormulaDisplay(
            r'\displaystyle A=\frac{mg\sin\theta\cos\theta}{M+m\sin^{2}\theta},\quad L=\frac{ml\cos\theta}{M+m}',
          ),
          aspectRatio: 0.72,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> simTime = ValueNotifier(0.0);

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    final duration = wedgeSlideDuration(_params);
    final next = math.min(duration, simTime.value + dt * _playback);
    simTime.value = next;
    if (next >= duration - 1e-4) _loop.pause();
  });

  @override
  String? get situation =>
      '慣性系で見ると、水平な床の上を動ける斜面の上端に静かに置かれた物体';

  ValueNotifier<bool> get running => _loop.running;

  Map<String, double> _latestParams = {};

  static const double _playback = 0.25;

  @override
  double aspectRatioForWidth(double width) {
    return width >= kWedgeSideBySideWidth ? 1.85 : 0.72;
  }

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'theta': kWedgeDefaultTheta,
        'M': kWedgeDefaultM,
        'm': kWedgeDefaultBlock,
        'l': kWedgeDefaultLength,
      };

  MovableWedgeParams get _params {
    if (_latestParams.isEmpty) {
      return MovableWedgeParams.fromMap(initialParameters);
    }
    return MovableWedgeParams.fromMap(_latestParams);
  }

  void _rememberParams(Map<String, double> params) {
    _latestParams = Map<String, double>.from(params);
  }

  void start() {
    if (running.value) return;
    final duration = wedgeSlideDuration(_params);
    if (simTime.value >= duration - 1e-3) simTime.value = 0.0;
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
        return PlayPauseResetButtons(
          playing: isRunning,
          onPlayPause: isRunning ? pause : start,
          onReset: resetMotion,
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
    final cartA = wedgeCartAcceleration(p);
    final duration = wedgeSlideDuration(p);
    final distance = wedgeCartDistance(p);
    return [
      const Text(
        '初期条件（g = 9.8 m/s²、摩擦なし）',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _WedgeSlider(
        label: 'θ',
        value: p.thetaDeg,
        min: kWedgeMinTheta,
        max: kWedgeMaxTheta,
        digits: 0,
        onChanged: (v) => updateParam('theta', v),
        semanticLabel: '傾角 θ',
      ),
      _WedgeSlider(
        label: 'M',
        value: p.cartMass,
        min: kWedgeMinM,
        max: kWedgeMaxM,
        onChanged: (v) => updateParam('M', v),
        semanticLabel: '台の質量 M',
      ),
      _WedgeSlider(
        label: 'm',
        value: p.blockMass,
        min: kWedgeMinBlock,
        max: kWedgeMaxBlock,
        onChanged: (v) => updateParam('m', v),
        semanticLabel: '小物体の質量 m',
      ),
      _WedgeSlider(
        label: 'l',
        value: p.length,
        min: kWedgeMinLength,
        max: kWedgeMaxLength,
        onChanged: (v) => updateParam('l', v),
        semanticLabel: '斜面の長さ l',
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'A = ${cartA.toStringAsFixed(2)} m/s²    '
          't = ${duration.toStringAsFixed(2)} s    '
          'L = ${distance.toStringAsFixed(2)} m',
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
        final p = MovableWedgeParams.fromMap(parameters);
        final sample = movableWedgeAt(p, simTime.value);
        return CustomPaint(
          size: Size.infinite,
          painter: _WedgePainter(params: p, sample: sample),
        );
      },
    );
  }
}

class _WedgeSlider extends StatelessWidget {
  const _WedgeSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.semanticLabel,
    this.digits = 2,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String semanticLabel;
  final int digits;

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
                  '$semanticLabel ${v.toStringAsFixed(digits)}',
            ),
          ),
        ),
        SizedBox(
          width: 48,
          child: Text(
            value.toStringAsFixed(digits),
            style: const TextStyle(fontSize: 12, fontFamily: 'Courier'),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _WedgePainter extends CustomPainter {
  _WedgePainter({required this.params, required this.sample});

  final MovableWedgeParams params;
  final MovableWedgeSample sample;

  static const _bg = Color(0xFFF7FAFC);
  static const _wedge = Color(0xFFB0BEC5);
  static const _block = Color(0xFF1E88E5);
  static const _gravity = Color(0xFFEF6C00);
  static const _normal = Color(0xFF1565C0);
  static const _inertial = Color(0xFF2E7D32);
  static const _ground = Color(0xFF8D6E63);
  static const _ink = Color(0xFF37474F);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final lines = 't = ${sample.t.toStringAsFixed(2)} s\n'
        's = ${sample.s.toStringAsFixed(2)} m';
    final ledger = movableWedgeEnergy(params, sample);
    const textColumnWidth = 168.0;
    final card = dynamicsReadoutCard(
      lines,
      ledger,
      textColumnWidth: textColumnWidth,
      bounds: size,
    );
    paintDynamicsReadout(
      canvas,
      lines,
      ledger,
      textColumnWidth: textColumnWidth,
      bounds: size,
    );
    final top = card.bottom + 6;
    final body = Rect.fromLTWH(0, top, size.width, math.max(1.0, size.height - top));
    final sideBySide = size.width >= kWedgeSideBySideWidth && size.width > size.height;
    if (sideBySide) {
      const gap = 8.0;
      final w = (body.width - gap) / 2;
      _paintPanel(canvas, Rect.fromLTWH(body.left, body.top, w, body.height), ground: true);
      _paintPanel(
        canvas,
        Rect.fromLTWH(body.left + w + gap, body.top, w, body.height),
        ground: false,
      );
    } else {
      const gap = 8.0;
      final h = (body.height - gap) / 2;
      _paintPanel(canvas, Rect.fromLTWH(body.left, body.top, body.width, h), ground: true);
      _paintPanel(
        canvas,
        Rect.fromLTWH(body.left, body.top + h + gap, body.width, h),
        ground: false,
      );
    }
  }

  void _paintPanel(Canvas canvas, Rect panel, {required bool ground}) {
    canvas.save();
    canvas.clipRect(panel);
    canvas.drawRect(panel, Paint()..color = Colors.white);
    canvas.drawRect(
      panel,
      Paint()
        ..color = const Color(0xFFCFD8DC)
        ..style = PaintingStyle.stroke,
    );
    _label(
      canvas,
      Offset(panel.left + 8, panel.top + 6),
      ground ? '地上（慣性系）' : '台と共に動く系（非慣性系）',
      _ink,
      alignLeft: true,
    );
    final plot = Rect.fromLTRB(
      panel.left + 8,
      panel.top + 26,
      panel.right - 8,
      panel.bottom - 8,
    );
    _drawScene(canvas, plot, ground: ground);
    canvas.restore();
  }

  void _drawScene(Canvas canvas, Rect plot, {required bool ground}) {
    final length = params.length;
    final th = params.theta;
    final distance = wedgeCartDistance(params);
    final x0 = ground ? -0.15 : -0.35;
    final x1 = ground ? distance + length * math.cos(th) + 0.35 : length * math.cos(th) + 0.55;
    final y0 = -0.08;
    final y1 = length * math.sin(th) + 0.55;
    final spanX = x1 - x0;
    final spanY = y1 - y0;
    final scale = math.min(plot.width / spanX, plot.height / spanY);
    final left = plot.left + (plot.width - spanX * scale) / 2;
    final bottom = plot.bottom - (plot.height - spanY * scale) / 2;
    Offset world(double x, double y) =>
        Offset(left + (x - x0) * scale, bottom - (y - y0) * scale);

    final shift = ground ? sample.xCart : 0.0;
    final tip = world(shift, 0);
    final backBottom = world(shift + length * math.cos(th), 0);
    final top = world(shift + length * math.cos(th), length * math.sin(th));
    final groundY = world(0, 0).dy;

    canvas.drawLine(
      Offset(plot.left, groundY),
      Offset(plot.right, groundY),
      Paint()
        ..color = _ground
        ..strokeWidth = 2.4,
    );

    if (ground) {
      _drawGhostWedge(canvas, world, 0, before: true);
      _drawGhostWedge(canvas, world, wedgeCartDistance(params), before: false);
    }

    final wedge = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(backBottom.dx, backBottom.dy)
      ..lineTo(top.dx, top.dy)
      ..close();
    canvas.drawPath(wedge, Paint()..color = _wedge);
    canvas.drawPath(
      wedge,
      Paint()
        ..color = const Color(0xFF607D8B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    final along = length - sample.s;
    final center = _blockCenter(world, shift, along);
    if (ground) _drawCenterTrail(canvas, world);
    final normal = Offset(-math.sin(th), math.cos(th));
    canvas.drawCircle(center.translate(0, 1.5), 9, Paint()..color = Colors.black12);
    canvas.drawCircle(center, 8, Paint()..color = _block);

    final gLen = 68.0;
    _arrow(canvas, center, const Offset(0, 1), gLen, _gravity, '重力', dashed: false);
    final nScale = (wedgeNormal(params) / (params.blockMass * kWedgeG)).clamp(0.25, 1.4);
    final nDir = Offset(normal.dx, -normal.dy);
    _arrow(canvas, center, nDir, 56 * nScale, _normal, 'N', dashed: false);
    if (!ground) {
      final aScale = (wedgeCartAcceleration(params) / kWedgeG).clamp(0.35, 1.6);
      final inertialLen = 96 * aScale;
      _arrow(canvas, center, const Offset(-1, 0), inertialLen, _inertial, '', dashed: true);
      _label(canvas, center + Offset(-inertialLen - 22, -8), '慣性力', _inertial);
    }
    _drawWedgeForces(canvas, world, shift, ground: ground);
  }

  void _drawWedgeForces(
    Canvas canvas,
    Offset Function(double, double) world,
    double shift, {
    required bool ground,
  }) {
    final th = params.theta;
    final length = params.length;
    final cm = world(
      shift + (2 / 3) * length * math.cos(th),
      length * math.sin(th) / 3,
    );
    final n = wedgeNormal(params);
    final weight = params.cartMass * kWedgeG;
    final floorNormal = weight + n * math.cos(th);
    final inertial = params.cartMass * wedgeCartAcceleration(params);
    final biggest = math.max(
      weight,
      math.max(floorNormal, math.max(n, ground ? 0.0 : inertial)),
    );
    final unit = 70 / biggest;
    canvas.drawCircle(cm, 2.4, Paint()..color = _ink);
    _arrow(canvas, cm, const Offset(0, 1), weight * unit, _gravity, '重力', dashed: false);
    _arrow(canvas, cm, const Offset(0, -1), floorNormal * unit, _normal, '垂直抗力', dashed: false);
    _arrow(
      canvas,
      cm,
      Offset(math.sin(th), math.cos(th)),
      n * unit,
      _normal,
      'N',
      dashed: false,
    );
    if (!ground && inertial > 1e-6) {
      _arrow(canvas, cm, const Offset(-1, 0), inertial * unit, _inertial, '慣性力', dashed: true);
    }
  }

  Offset _blockCenter(
    Offset Function(double, double) world,
    double shift,
    double along,
  ) {
    final th = params.theta;
    final contact = world(shift + along * math.cos(th), along * math.sin(th));
    final normal = Offset(-math.sin(th), math.cos(th));
    return contact + Offset(normal.dx, -normal.dy) * 10;
  }

  void _drawGhostWedge(
    Canvas canvas,
    Offset Function(double, double) world,
    double shift, {
    required bool before,
  }) {
    final length = params.length;
    final c = math.cos(params.theta);
    final s = math.sin(params.theta);
    final tip = world(shift, 0);
    final back = world(shift + length * c, 0);
    final top = world(shift + length * c, length * s);
    final paint = Paint()
      ..color = const Color(0xFF78909C)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    _dashed(canvas, tip, back, paint);
    _dashed(canvas, back, top, paint);
    _dashed(canvas, top, tip, paint);
    _label(
      canvas,
      top + Offset(before ? -14 : 8, -18),
      before ? '前' : '後',
      const Color(0xFF546E7A),
      alignLeft: !before,
      size: 10,
    );
  }

  void _drawCenterTrail(Canvas canvas, Offset Function(double, double) world) {
    if (sample.s < 1e-4) return;
    const steps = 32;
    final paint = Paint()
      ..color = _block.withValues(alpha: 0.9)
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round;
    var prev = _blockCenter(world, 0, params.length);
    canvas.drawCircle(prev, 2.5, Paint()..color = _block.withValues(alpha: 0.75));
    for (var i = 1; i <= steps; i++) {
      final snap = movableWedgeAt(params, sample.t * i / steps);
      final point = _blockCenter(world, snap.xCart, params.length - snap.s);
      if ((point - prev).distance >= 0.4) {
        canvas.drawLine(prev, point, paint);
      }
      prev = point;
    }
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 4.0;
    const gap = 3.0;
    final delta = b - a;
    final len = delta.distance;
    if (len < 1) return;
    final step = delta / len;
    var d = 0.0;
    while (d < len) {
      final end = math.min(d + dash, len);
      canvas.drawLine(a + step * d, a + step * end, paint);
      d += dash + gap;
    }
  }

  void _arrow(
    Canvas canvas,
    Offset origin,
    Offset dir,
    double length,
    Color color,
    String label, {
    required bool dashed,
  }) {
    final tip = origin + dir * length;
    const headLen = 9.0;
    const headHalf = 4.5;
    final shaftEnd = tip - dir * (headLen * 0.7);
    final n = Offset(-dir.dy, dir.dx);
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
          final end = math.min(d + 4, len);
          canvas.drawLine(origin + step * d, origin + step * end, shaft);
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
    _label(canvas, tip + n * 11, label, color);
  }

  void _label(
    Canvas canvas,
    Offset o,
    String text,
    Color color, {
    bool alignLeft = false,
    double size = 11,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = alignLeft ? o.dx : o.dx - tp.width / 2;
    tp.paint(canvas, Offset(dx, o.dy));
  }

  @override
  bool shouldRepaint(covariant _WedgePainter oldDelegate) {
    return oldDelegate.sample.t != sample.t ||
        oldDelegate.sample.s != sample.s ||
        oldDelegate.params.thetaDeg != params.thetaDeg ||
        oldDelegate.params.cartMass != params.cartMass ||
        oldDelegate.params.blockMass != params.blockMass ||
        oldDelegate.params.length != params.length;
  }
}
