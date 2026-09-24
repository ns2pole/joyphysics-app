import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/energy_gauge.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// 上向き正。物体はエレベータ内で静止している。$g=9.8\,\mathrm{m/s^2}$。
const double kElevatorG = 9.8;
const double kElevatorMinA = 0.0;
const double kElevatorMaxA = 8.0;
const double kElevatorDefaultA = 3.0;
const double kElevatorMinM = 0.5;
const double kElevatorMaxM = 4.0;
const double kElevatorDefaultM = 1.0;
const double kElevatorDuration = 1.6;
const double kElevatorSideBySideWidth = 640.0;

enum ElevatorMotionKind { up, down }

class ElevatorInertialParams {
  const ElevatorInertialParams({required this.accel, required this.mass});

  final double accel;
  final double mass;

  factory ElevatorInertialParams.fromMap(Map<String, double> params) {
    return ElevatorInertialParams(
      accel: params['A']!.clamp(kElevatorMinA, kElevatorMaxA).toDouble(),
      mass: params['m']!.clamp(kElevatorMinM, kElevatorMaxM).toDouble(),
    );
  }
}

class ElevatorInertialSample {
  const ElevatorInertialSample({
    required this.t,
    required this.y,
    required this.v,
    required this.a,
    required this.tension,
  });

  final double t;
  final double y;
  final double v;
  final double a;
  final double tension;
}

double elevatorSignedAccel(ElevatorMotionKind kind, ElevatorInertialParams params) {
  return kind == ElevatorMotionKind.up ? params.accel : -params.accel;
}

/// 上向き正の加速度 $a$ に対し $\displaystyle T=m(g+a)$。
double elevatorTension(ElevatorMotionKind kind, ElevatorInertialParams params) {
  return params.mass * (kElevatorG + elevatorSignedAccel(kind, params));
}

ElevatorInertialSample elevatorInertialAt(
  ElevatorMotionKind kind,
  ElevatorInertialParams params,
  double t,
) {
  final time = math.max(0.0, t).clamp(0.0, kElevatorDuration).toDouble();
  final a = elevatorSignedAccel(kind, params);
  return ElevatorInertialSample(
    t: time,
    y: 0.5 * a * time * time,
    v: a * time,
    a: a,
    tension: elevatorTension(kind, params),
  );
}

String elevatorCaption(ElevatorMotionKind kind) {
  switch (kind) {
    case ElevatorMotionKind.up:
      return '上昇しながら加速する。エレベータ内では物体は静止したまま。\n'
          '地上では張力が重力より大きく、その差が ma。\n'
          'エレベータ内では下向きの慣性力を足すと、つり合う。';
    case ElevatorMotionKind.down:
      return '下降しながら加速する。エレベータ内では物体は静止したまま。\n'
          '地上では張力が重力より小さく、差の大きさが ma。\n'
          'エレベータ内では上向きの慣性力を足すと、つり合う。';
  }
}

final elevatorInertial1D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: 'エレベータの上昇・下降',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>エレベータの天井から紐で物体を吊ります。物体はエレベータ内で静止しているので、地上から見るとエレベータと同じ加速度 $a$ です。上向きを正にすると</p>
  <p>$$T-mg=ma,\quad T=m(g+a)$$</p>
  <p>上昇で加速するときは $a=+A$ で、張力は重力より大きくなります。下降で加速するときは $a=-A$ で、張力は</p>
  <p>$$T=m(g-A)$$</p>
  <p>エレベータとともに動く人から見ると、物体は静止しています。加速度と逆向きの慣性力 $ma$ を加えると、張力・重力・慣性力がつり合います。地上で出した $T$ と同じです。</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: ElevatorInertialSimulation(),
      height: 980,
    ),
  ],
);

class ElevatorInertialSimulation extends PhysicsSimulation {
  ElevatorInertialSimulation()
      : super(
          title: 'エレベータの上昇・下降',
          formula: const FormulaDisplay(
            r'\displaystyle T=m(g+a)',
          ),
          aspectRatio: 0.72,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> simTime = ValueNotifier(0.0);
  ElevatorMotionKind _kind = ElevatorMotionKind.up;

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    final next = math.min(kElevatorDuration, simTime.value + dt * _playback);
    simTime.value = next;
    if (next >= kElevatorDuration - 1e-4) _loop.pause();
  });

  @override
  String? get situation => '慣性系で見ると、エレベータと同じ加速度で動く物体';

  ValueNotifier<bool> get running => _loop.running;

  Map<String, double> _latestParams = {};

  static const double _playback = 0.40;

  @override
  double aspectRatioForWidth(double width) {
    return width >= kElevatorSideBySideWidth ? 1.85 : 0.72;
  }

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'A': kElevatorDefaultA,
        'm': kElevatorDefaultM,
      };

  ElevatorInertialParams get _params {
    if (_latestParams.isEmpty) {
      return ElevatorInertialParams.fromMap(initialParameters);
    }
    return ElevatorInertialParams.fromMap(_latestParams);
  }

  void _rememberParams(Map<String, double> params) {
    _latestParams = Map<String, double>.from(params);
  }

  void start() {
    if (running.value) return;
    if (simTime.value >= kElevatorDuration - 1e-3) simTime.value = 0.0;
    _loop.start();
  }

  void pause() => _loop.pause();

  void resetMotion() {
    _loop.reset();
    simTime.value = 0.0;
  }

  void applyKind(ElevatorMotionKind kind) {
    _kind = kind;
    resetMotion();
  }

  String _formulaTex() {
    switch (_kind) {
      case ElevatorMotionKind.up:
        return r'\displaystyle T=m(g+A)';
      case ElevatorMotionKind.down:
        return r'\displaystyle T=m(g-A)';
    }
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
            Text(
              elevatorCaption(_kind),
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
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                _kindButton('上昇', ElevatorMotionKind.up, updateActiveIds),
                _kindButton('下降', ElevatorMotionKind.down, updateActiveIds),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _kindButton(
    String label,
    ElevatorMotionKind kind,
    void Function(Set<String> ids) updateActiveIds,
  ) {
    final selected = _kind == kind;
    final onPressed = () {
      applyKind(kind);
      updateActiveIds({kind.name});
    };
    if (selected) {
      return FilledButton(onPressed: onPressed, child: Text(label));
    }
    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }

  @override
  List<Widget> buildControls(
    BuildContext context,
    Map<String, double> parameters,
    void Function(String key, double value) updateParam,
  ) {
    _rememberParams(parameters);
    final p = _params;
    final a = elevatorSignedAccel(_kind, p);
    final tension = elevatorTension(_kind, p);
    return [
      const Text(
        '加速度の大きさ A（上向き正、g = 9.8 m/s²）',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _ElevatorSlider(
        label: 'A',
        value: p.accel,
        min: kElevatorMinA,
        max: kElevatorMaxA,
        onChanged: (v) => updateParam('A', v),
        semanticLabel: '加速度の大きさ A',
      ),
      _ElevatorSlider(
        label: 'm',
        value: p.mass,
        min: kElevatorMinM,
        max: kElevatorMaxM,
        onChanged: (v) => updateParam('m', v),
        semanticLabel: '物体の質量 m',
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'a = ${a.toStringAsFixed(2)} m/s²    T = ${tension.toStringAsFixed(2)} N',
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
        final p = ElevatorInertialParams.fromMap(parameters);
        final sample = elevatorInertialAt(_kind, p, simTime.value);
        return CustomPaint(
          size: Size.infinite,
          painter: _ElevatorPainter(kind: _kind, params: p, sample: sample),
        );
      },
    );
  }
}

class _ElevatorSlider extends StatelessWidget {
  const _ElevatorSlider({
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
          width: 48,
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

class _ElevatorPainter extends CustomPainter {
  _ElevatorPainter({
    required this.kind,
    required this.params,
    required this.sample,
  });

  final ElevatorMotionKind kind;
  final ElevatorInertialParams params;
  final ElevatorInertialSample sample;

  static const _bg = Color(0xFFF7FAFC);
  static const _cabin = Color(0xFF90A4AE);
  static const _mass = Color(0xFF1E88E5);
  static const _gravity = Color(0xFFEF6C00);
  static const _tension = Color(0xFF1565C0);
  static const _inertial = Color(0xFF2E7D32);
  static const _person = Color(0xFF6D4C41);
  static const _ink = Color(0xFF37474F);

  static const double _cabinH = 2.2;
  static const double _hang = 0.85;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final sideBySide = size.width >= kElevatorSideBySideWidth && size.width > size.height;
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
    canvas.drawRect(panel, Paint()..color = Colors.white);
    canvas.drawRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFCFD8DC),
    );
    _text(
      canvas,
      Offset(panel.left + 8, panel.top + 6),
      ground ? '地上（慣性系）' : 'エレベータ内（非慣性系）',
      _ink,
      alignLeft: true,
    );
    final plot = Rect.fromLTRB(panel.left + 10, panel.top + 28, panel.right - 10, panel.bottom - 36);
    _scene(canvas, plot, ground: ground);
    _text(
      canvas,
      Offset(panel.center.dx, panel.bottom - 24),
      ground ? '物体はエレベータと同じ加速度で動く。' : '人から見ると物体は静止している。',
      const Color(0xFF546E7A),
    );
    canvas.restore();
  }

  void _scene(Canvas canvas, Rect plot, {required bool ground}) {
    final travel = 0.5 * params.accel * kElevatorDuration * kElevatorDuration;
    final yLo = ground ? -travel - 0.25 : -0.35;
    final yHi = ground ? travel + _cabinH + 0.45 : _cabinH + 0.55;
    final scale = math.min(plot.width / 2.4, plot.height / (yHi - yLo));
    final floor0 = ground
        ? (kind == ElevatorMotionKind.up ? 0.0 : travel)
        : 0.0;
    final floor = floor0 + (ground ? sample.y : 0.0);
    final left = plot.center.dx - 0.55 * scale;
    final right = plot.center.dx + 0.55 * scale;
    double yOf(double y) => plot.bottom - (y - yLo) * scale - (plot.height - (yHi - yLo) * scale) / 2;

    final floorY = yOf(floor);
    final ceilY = yOf(floor + _cabinH);
    final cabin = RRect.fromRectAndRadius(
      Rect.fromLTRB(left, ceilY, right, floorY),
      const Radius.circular(4),
    );
    canvas.drawRRect(cabin, Paint()..color = const Color(0xFFECEFF1));
    canvas.drawRRect(
      cabin,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = _cabin,
    );

    final hook = Offset((left + right) / 2, ceilY);
    final massCenter = Offset(hook.dx, yOf(floor + _cabinH - _hang));
    canvas.drawLine(
      hook,
      massCenter + const Offset(0, -8),
      Paint()
        ..color = _ink
        ..strokeWidth = 1.6,
    );
    canvas.drawCircle(massCenter, 8, Paint()..color = _mass);

    _drawPerson(canvas, Offset(right - 18, floorY));

    final mg = 42.0;
    final tLen = mg * sample.tension / (params.mass * kElevatorG);
    _arrow(canvas, massCenter + const Offset(16, 0), const Offset(0, -1), tLen.clamp(10, 78), _tension, 'T');
    _arrow(canvas, massCenter + const Offset(-18, 0), const Offset(0, 1), mg, _gravity, '重力');
    if (!ground && sample.a.abs() > 0.05) {
      final downward = sample.a > 0;
      final dir = downward ? const Offset(0, 1) : const Offset(0, -1);
      final iLen = mg * sample.a.abs() / kElevatorG;
      _arrow(
        canvas,
        massCenter + Offset(downward ? -40 : -18, 0),
        dir,
        iLen.clamp(10, 70),
        _inertial,
        'ma',
        dashed: true,
      );
    }

    final lines = 't = ${sample.t.toStringAsFixed(2)} s\n'
        'v = ${sample.v.toStringAsFixed(2)} m/s\n'
        'T = ${sample.tension.toStringAsFixed(2)} N';
    _text(canvas, plot.topLeft + const Offset(0, 0), lines, _ink, alignLeft: true);
  }

  void _drawPerson(Canvas canvas, Offset feet) {
    final paint = Paint()
      ..color = _person
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final hip = feet + const Offset(0, -16);
    final neck = feet + const Offset(0, -32);
    canvas.drawLine(feet + const Offset(-6, 0), hip, paint);
    canvas.drawLine(feet + const Offset(6, 0), hip, paint);
    canvas.drawLine(hip, neck, paint);
    canvas.drawLine(neck, neck + const Offset(-8, 8), paint);
    canvas.drawLine(neck, neck + const Offset(8, 8), paint);
    canvas.drawCircle(neck + const Offset(0, -6), 4.5, Paint()..color = _person);
  }

  void _arrow(
    Canvas canvas,
    Offset origin,
    Offset dir,
    double length,
    Color color,
    String label, {
    bool dashed = false,
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
    _text(canvas, tip + n * 12, label, color);
  }

  void _text(
    Canvas canvas,
    Offset o,
    String text,
    Color color, {
    bool alignLeft = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700, height: 1.3),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(alignLeft ? o.dx : o.dx - tp.width / 2, o.dy));
  }

  @override
  bool shouldRepaint(covariant _ElevatorPainter oldDelegate) {
    return oldDelegate.sample.t != sample.t ||
        oldDelegate.sample.a != sample.a ||
        oldDelegate.kind != kind ||
        oldDelegate.params.mass != params.mass ||
        oldDelegate.params.accel != params.accel;
  }
}
