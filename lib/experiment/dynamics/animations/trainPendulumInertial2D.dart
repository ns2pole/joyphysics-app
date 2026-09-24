import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// 右向き正。$g=9.8\,\mathrm{m/s^2}$。角 $\theta$ は鉛直下から加速度の向きを正。
const double kTrainG = 9.8;
const double kTrainMinA = 0.0;
const double kTrainMaxA = 8.0;
const double kTrainDefaultA = 2.5;
const double kTrainCabinH = 1.295;
const double kTrainCabinW = 1.715;
const double kTrainMinL = 0.40;
const double kTrainMaxL = 1.05;
const double kTrainDefaultL = 0.75 * kTrainCabinH;
const double kTrainMinM = 0.5;
const double kTrainMaxM = 4.0;
const double kTrainDefaultM = 1.0;
const double kTrainMinAmpDeg = 0.0;
const double kTrainMaxAmpDeg = 50.0;
const double kTrainDefaultAmpDeg = 28.0;
const double kTrainSideBySideWidth = 640.0;
const double kTrainGroundXMin = -1.3;
const double kTrainGroundXMax = 6.4;
const double kTrainGroundRecordMax = 16.0;
const double kTrainStrobeDt = 0.10;

enum TrainPendulumKind { rest, swing }

class TrainPendulumParams {
  const TrainPendulumParams({
    required this.accel,
    required this.length,
    required this.mass,
    required this.amplitudeDeg,
  });

  final double accel;
  final double length;
  final double mass;
  final double amplitudeDeg;

  factory TrainPendulumParams.fromMap(Map<String, double> params) {
    return TrainPendulumParams(
      accel: params['A']!.clamp(kTrainMinA, kTrainMaxA).toDouble(),
      length: params['l']!.clamp(kTrainMinL, kTrainMaxL).toDouble(),
      mass: params['m']!.clamp(kTrainMinM, kTrainMaxM).toDouble(),
      amplitudeDeg: params['amp']!.clamp(kTrainMinAmpDeg, kTrainMaxAmpDeg).toDouble(),
    );
  }

  double get amplitude => amplitudeDeg * math.pi / 180.0;
}

class TrainPendulumSample {
  const TrainPendulumSample({
    required this.t,
    required this.cycle,
    required this.theta,
    required this.omega,
    required this.cartX,
    required this.cartV,
    required this.tension,
    required this.lean,
  });

  final double t;
  final double cycle;
  final double theta;
  final double omega;
  final double cartX;
  final double cartV;
  final double tension;
  final double lean;
}

double trainGEff(double accel) => math.sqrt(kTrainG * kTrainG + accel * accel);

/// 鉛直から加速度と逆向きの傾き $a$。$\displaystyle \tan a=\frac{A}{g}$。
double trainEquilibriumLean(double accel) => math.atan(accel / kTrainG);

double trainEquilibriumTheta(double accel) => -trainEquilibriumLean(accel);

double trainEquilibriumTension(double mass, double accel) => mass * trainGEff(accel);

double trainPendulumPeriod(double length, double accel) =>
    2 * math.pi * math.sqrt(length / trainGEff(accel));

/// $\displaystyle l\ddot\theta=-g\sin\theta-A\cos\theta$。
double trainThetaAccel(double theta, double length, double accel) =>
    -(kTrainG / length) * math.sin(theta) - (accel / length) * math.cos(theta);

/// 慣性系の動径成分。$\displaystyle T=m(g\cos\theta-A\sin\theta+l\dot\theta^{2})$。
double trainTension({
  required double mass,
  required double theta,
  required double omega,
  required double length,
  required double accel,
}) {
  return mass * (kTrainG * math.cos(theta) - accel * math.sin(theta) + length * omega * omega);
}

class TrainBobPosition {
  const TrainBobPosition(this.x, this.y);

  final double x;
  final double y;
}

/// 支点は $\displaystyle x=\frac{1}{2}At^{2}$。上向き正で $\displaystyle y=-l\cos\theta$。
TrainBobPosition trainBobGround(double accel, double t, double length, double theta) {
  return TrainBobPosition(
    0.5 * accel * t * t + length * math.sin(theta),
    -length * math.cos(theta),
  );
}

/// 電車内は支点を原点にした円弧。
TrainBobPosition trainBobTrain(double length, double theta) {
  return TrainBobPosition(length * math.sin(theta), -length * math.cos(theta));
}

class _Phase {
  _Phase(this.theta, this.omega);

  double theta;
  double omega;
}

_Phase trainPendulumStep(_Phase phase, TrainPendulumParams params, double dt) {
  List<double> deriv(double theta, double omega) {
    return [omega, trainThetaAccel(theta, params.length, params.accel)];
  }

  final k1 = deriv(phase.theta, phase.omega);
  final k2 = deriv(phase.theta + 0.5 * dt * k1[0], phase.omega + 0.5 * dt * k1[1]);
  final k3 = deriv(phase.theta + 0.5 * dt * k2[0], phase.omega + 0.5 * dt * k2[1]);
  final k4 = deriv(phase.theta + dt * k3[0], phase.omega + dt * k3[1]);
  return _Phase(
    phase.theta + (dt / 6) * (k1[0] + 2 * k2[0] + 2 * k3[0] + k4[0]),
    phase.omega + (dt / 6) * (k1[1] + 2 * k2[1] + 2 * k3[1] + k4[1]),
  );
}

/// テスト用。静止から振幅だけずらして、$dt$ で [steps] 回進める。
TrainPendulumSample trainPendulumIntegrate(
  TrainPendulumKind kind,
  TrainPendulumParams params,
  double dt,
  int steps,
) {
  final eq = trainEquilibriumTheta(params.accel);
  var phase = _Phase(kind == TrainPendulumKind.rest ? eq : eq + params.amplitude, 0);
  var t = 0.0;
  for (var i = 0; i < steps; i++) {
    if (kind == TrainPendulumKind.swing) {
      phase = trainPendulumStep(phase, params, dt);
    }
    t += dt;
  }
  return _sample(kind, params, phase, t);
}

TrainPendulumSample _sample(
  TrainPendulumKind kind,
  TrainPendulumParams params,
  _Phase phase,
  double t,
) {
  final theta = kind == TrainPendulumKind.rest ? trainEquilibriumTheta(params.accel) : phase.theta;
  final omega = kind == TrainPendulumKind.rest ? 0.0 : phase.omega;
  return TrainPendulumSample(
    t: t,
    cycle: t,
    theta: theta,
    omega: omega,
    cartX: 0.5 * params.accel * t * t,
    cartV: params.accel * t,
    tension: trainTension(
      mass: params.mass,
      theta: theta,
      omega: omega,
      length: params.length,
      accel: params.accel,
    ),
    lean: trainEquilibriumLean(params.accel),
  );
}

String trainPendulumCaption(TrainPendulumKind kind) {
  switch (kind) {
    case TrainPendulumKind.rest:
      return '電車に対して静止。地上では張力の水平成分が mA になり、物体は電車と同じ加速度で進む。\n'
          '軌跡は高さが一定の直線。電車内では慣性力を足すとつり合い、軌跡は一点。';
    case TrainPendulumKind.swing:
      return 'つり合いの傾きのまわりに揺れる。地上の軌跡は進みながら上下する。\n'
          '電車内では支点を中心にした円弧で、慣性力を足すと見かけの重力の方向を軸に振れる。';
  }
}

final trainPendulumInertial2D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '加速する電車の振り子',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>電車が右向きに一定の加速度 $A$ で走ります。天井から長さ $l$ の糸で質量 $m$ を吊ります。角 $\theta$ は鉛直下から、加速度の向きを正にします。</p>
  <p>物体が電車に対して静止しているとき、地上から見ると物体も加速度 $A$ です。働くのは重力と張力だけで、糸は加速度と逆向きに角 $a$ だけ傾きます。</p>
  <p>$$T\sin a=mA,\quad T\cos a=mg,\quad \tan a=\frac{A}{g},\quad T=m\sqrt{g^{2}+A^{2}}$$</p>
  <p>電車の中では物体は静止しています。加速度と逆向きの慣性力 $mA$ を足すと、同じ $a$ と $T$ でつり合います。</p>
  <p>揺れているとき、地上でも電車内でも角の式は同じです。</p>
  <p>$$l\ddot{\theta}=-g\sin\theta-A\cos\theta$$</p>
  <p>つり合いのまわりの小さな揺れの周期は、普通の振り子の $g$ を $\displaystyle g_{\mathrm{eff}}=\sqrt{g^{2}+A^{2}}$ に替えたものです。</p>
  <p>$$T_{\mathrm{周期}}=2\pi\sqrt{\frac{l}{\sqrt{g^{2}+A^{2}}}}$$</p>
  <p>支点の位置を $\displaystyle \frac{1}{2}At^{2}$ とすると、地上の軌跡は</p>
  <p>$$x=\frac{1}{2}At^{2}+l\sin\theta,\quad y=-l\cos\theta$$</p>
  <p>電車内の軌跡は、支点を中心にした円弧です。</p>
  <p>$$x=l\sin\theta,\quad y=-l\cos\theta$$</p>
  <p>静止しているときは $\theta$ が一定なので、地上では高さが一定の直線、電車内では一点です。</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: TrainPendulumSimulation(),
      height: 980,
    ),
  ],
);

class TrainPendulumSimulation extends PhysicsSimulation {
  TrainPendulumSimulation()
      : super(
          title: '加速する電車の振り子',
          formula: const FormulaDisplay(
            r'\displaystyle \tan a=\frac{A}{g}',
          ),
          aspectRatio: 0.72,
          enableTime: false,
          showTimeOverlay: false,
        );

  TrainPendulumKind _kind = TrainPendulumKind.rest;
  _Phase _phase = _Phase(trainEquilibriumTheta(kTrainDefaultA), 0);
  double _time = 0;
  Map<String, double> _latestParams = {};
  final ValueNotifier<int> _frame = ValueNotifier(0);
  final List<TrainBobPosition> groundTrail = [];
  final List<TrainBobPosition> trainTrail = [];
  final List<TrainBobPosition> groundStrobes = [];
  final List<TrainBobPosition> trainStrobes = [];
  double _nextStrobe = 0;

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    final step = math.min(dt, 1 / 30) * _playback;
    final p = _params;
    if (_kind == TrainPendulumKind.swing) {
      _phase = trainPendulumStep(_phase, p, step);
    } else {
      _phase = _Phase(trainEquilibriumTheta(p.accel), 0);
    }
    _time += step;
    _pushTrail(p);
    _frame.value++;
  });

  static const double _playback = 0.55;

  ValueNotifier<bool> get running => _loop.running;

  @override
  bool get showZoomButtons => true;

  @override
  String? get situation => '慣性系では重力と張力だけ。非慣性系では慣性力を足して見る';

  @override
  double aspectRatioForWidth(double width) {
    return width >= kTrainSideBySideWidth ? 1.7 : 0.72;
  }

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'A': kTrainDefaultA,
        'l': kTrainDefaultL,
        'm': kTrainDefaultM,
        'amp': kTrainDefaultAmpDeg,
      };

  TrainPendulumParams get _params {
    if (_latestParams.isEmpty) return TrainPendulumParams.fromMap(initialParameters);
    return TrainPendulumParams.fromMap(_latestParams);
  }

  void _rememberParams(Map<String, double> params) {
    final next = TrainPendulumParams.fromMap(params);
    final prev = _latestParams.isEmpty ? null : TrainPendulumParams.fromMap(_latestParams);
    _latestParams = Map<String, double>.from(params);
    final dynamicsChanged = prev == null ||
        prev.accel != next.accel ||
        prev.length != next.length ||
        prev.amplitudeDeg != next.amplitudeDeg;
    final anyChanged = dynamicsChanged || (prev != null && prev.mass != next.mass);
    if (dynamicsChanged) {
      _resetPhase(next);
    } else if (anyChanged) {
      _clearTrail(next);
    }
  }

  void _clearTrail(TrainPendulumParams params) {
    groundTrail.clear();
    trainTrail.clear();
    groundStrobes.clear();
    trainStrobes.clear();
    _nextStrobe = 0;
    _pushTrail(params);
  }

  void _pushTrail(TrainPendulumParams params) {
    final theta = _kind == TrainPendulumKind.rest ? trainEquilibriumTheta(params.accel) : _phase.theta;
    final ground = trainBobGround(params.accel, _time, params.length, theta);
    final train = trainBobTrain(params.length, theta);
    if (ground.x <= kTrainGroundRecordMax && _farFromLast(groundTrail, ground)) {
      groundTrail.add(ground);
    }
    if (_farFromTrail(trainTrail, train)) trainTrail.add(train);
    if (_time + 1e-9 < _nextStrobe) return;
    if (ground.x <= kTrainGroundRecordMax) groundStrobes.add(ground);
    trainStrobes.add(train);
    do {
      _nextStrobe += kTrainStrobeDt;
    } while (_nextStrobe <= _time);
  }

  bool _farFromLast(List<TrainBobPosition> pts, TrainBobPosition p) {
    if (pts.isEmpty) return true;
    final last = pts.last;
    return (p.x - last.x).abs() + (p.y - last.y).abs() >= 0.012;
  }

  /// 同じ円弧を往復しても点を重ねず、消して描き直さない。
  bool _farFromTrail(List<TrainBobPosition> pts, TrainBobPosition p) {
    for (final q in pts) {
      if ((p.x - q.x).abs() + (p.y - q.y).abs() < 0.012) return false;
    }
    return true;
  }

  void _resetPhase(TrainPendulumParams params) {
    final eq = trainEquilibriumTheta(params.accel);
    _phase = _Phase(_kind == TrainPendulumKind.rest ? eq : eq + params.amplitude, 0);
    _time = 0;
    _clearTrail(params);
    _frame.value++;
  }

  void start() {
    if (running.value) return;
    _loop.start();
  }

  void pause() => _loop.pause();

  void resetMotion() {
    _loop.reset();
    _resetPhase(_params);
  }

  void applyKind(TrainPendulumKind kind) {
    _kind = kind;
    resetMotion();
  }

  String _formulaTex() {
    switch (_kind) {
      case TrainPendulumKind.rest:
        return r'\displaystyle \tan a=\frac{A}{g},\quad T=m\sqrt{g^{2}+A^{2}}';
      case TrainPendulumKind.swing:
        return r'\displaystyle T_{\mathrm{周期}}=2\pi\sqrt{\frac{l}{\sqrt{g^{2}+A^{2}}}}';
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
              trainPendulumCaption(_kind),
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
              children: [
                _kindButton('静止', TrainPendulumKind.rest, updateActiveIds),
                _kindButton('振り子', TrainPendulumKind.swing, updateActiveIds),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _kindButton(
    String label,
    TrainPendulumKind kind,
    void Function(Set<String> ids) updateActiveIds,
  ) {
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
    _rememberParams(parameters);
    final p = _params;
    final leanDeg = trainEquilibriumLean(p.accel) * 180 / math.pi;
    final tension = trainEquilibriumTension(p.mass, p.accel);
    final period = trainPendulumPeriod(p.length, p.accel);
    return [
      const Text(
        '電車の加速度 A（右向き、g = 9.8 m/s²）',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _TrainSlider(
        label: 'A',
        value: p.accel,
        min: kTrainMinA,
        max: kTrainMaxA,
        onChanged: (v) => updateParam('A', v),
        semanticLabel: '電車の加速度 A',
      ),
      _TrainSlider(
        label: 'l',
        value: p.length,
        min: kTrainMinL,
        max: kTrainMaxL,
        onChanged: (v) => updateParam('l', v),
        semanticLabel: '糸の長さ l',
      ),
      _TrainSlider(
        label: 'm',
        value: p.mass,
        min: kTrainMinM,
        max: kTrainMaxM,
        onChanged: (v) => updateParam('m', v),
        semanticLabel: '物体の質量 m',
      ),
      if (_kind == TrainPendulumKind.swing)
        _TrainSlider(
          label: '振れ',
          value: p.amplitudeDeg,
          min: kTrainMinAmpDeg,
          max: kTrainMaxAmpDeg,
          onChanged: (v) => updateParam('amp', v),
          semanticLabel: 'つり合いからの振れ角',
        ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          _kind == TrainPendulumKind.rest
              ? 'a = ${leanDeg.toStringAsFixed(1)} °    T = ${tension.toStringAsFixed(2)} N'
              : 'a = ${leanDeg.toStringAsFixed(1)} °    周期 ≈ ${period.toStringAsFixed(2)} s',
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
    _rememberParams(parameters);
    return AnimatedBuilder(
      animation: Listenable.merge([running, _frame]),
      builder: (context, _) {
        final p = TrainPendulumParams.fromMap(parameters);
        final sample = _sample(_kind, p, _phase, _time);
        return CustomPaint(
          size: Size.infinite,
          painter: _TrainPendulumPainter(
            kind: _kind,
            params: p,
            sample: sample,
            groundTrail: List<TrainBobPosition>.from(groundTrail),
            trainTrail: List<TrainBobPosition>.from(trainTrail),
            groundStrobes: List<TrainBobPosition>.from(groundStrobes),
            trainStrobes: List<TrainBobPosition>.from(trainStrobes),
            zoom: scale,
          ),
        );
      },
    );
  }
}

class _TrainSlider extends StatelessWidget {
  const _TrainSlider({
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
          width: 36,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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

class _TrainPendulumPainter extends CustomPainter {
  _TrainPendulumPainter({
    required this.kind,
    required this.params,
    required this.sample,
    required this.groundTrail,
    required this.trainTrail,
    required this.groundStrobes,
    required this.trainStrobes,
    required this.zoom,
  });

  final TrainPendulumKind kind;
  final TrainPendulumParams params;
  final TrainPendulumSample sample;
  final List<TrainBobPosition> groundTrail;
  final List<TrainBobPosition> trainTrail;
  final List<TrainBobPosition> groundStrobes;
  final List<TrainBobPosition> trainStrobes;
  final double zoom;

  static const _bg = Color(0xFFF7FAFC);
  static const _cabin = Color(0xFF90A4AE);
  static const _mass = Color(0xFF1E88E5);
  static const _gravity = Color(0xFFEF6C00);
  static const _tension = Color(0xFF1565C0);
  static const _inertial = Color(0xFF2E7D32);
  static const _accel = Color(0xFF6A1B9A);
  static const _ink = Color(0xFF37474F);
  static const _rail = Color(0xFF78909C);
  static const _trail = Color(0xFF78909C);

  static const double _cabinH = kTrainCabinH;
  static const double _cabinW = kTrainCabinW;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final sideBySide = size.width >= kTrainSideBySideWidth && size.width > size.height;
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
      ground ? '地上（慣性系）' : '電車内（非慣性系）',
      _ink,
      alignLeft: true,
    );
    final plot = Rect.fromLTRB(panel.left + 8, panel.top + 26, panel.right - 8, panel.bottom - 28);
    _scene(canvas, plot, ground: ground);
    _text(
      canvas,
      Offset(panel.center.dx, panel.bottom - 20),
      ground ? '力は重力と張力だけ。張力の水平成分が物体を加速する。' : '加速度と逆向きの慣性力 mA を足して見る。',
      const Color(0xFF546E7A),
    );
    canvas.restore();
  }

  void _scene(Canvas canvas, Rect plot, {required bool ground}) {
    final yLo = -0.4;
    final yHi = _cabinH + 0.5;
    final xSpan = kTrainGroundXMax - kTrainGroundXMin;
    final scale = math.min(plot.width / xSpan, plot.height / (yHi - yLo)) * zoom;
    final pivotX = ground ? sample.cartX : 0.0;
    final yOrigin = plot.bottom - (plot.height - (yHi - yLo) * scale) / 2 + yLo * scale;
    final origin = ground
        ? Offset(plot.left + 8 + (_cabinW / 2) * scale, yOrigin)
        : Offset(plot.center.dx, plot.center.dy + (_cabinH / 2) * scale);
    Offset world(double x, double y) => Offset(origin.dx + x * scale, origin.dy - y * scale);

    final left = pivotX - _cabinW / 2;
    final right = pivotX + _cabinW / 2;
    final floor = 0.0;
    final ceil = _cabinH;
    final cabin = RRect.fromRectAndRadius(
      Rect.fromPoints(world(left, ceil), world(right, floor)),
      const Radius.circular(4),
    );
    if (ground) {
      final railY = world(0, floor).dy + 7;
      canvas.drawLine(Offset(plot.left, railY), Offset(plot.right, railY), Paint()..color = _rail..strokeWidth = 2);
      final xLeft = (plot.left - origin.dx) / scale;
      final xRight = (plot.right - origin.dx) / scale;
      final first = (xLeft / 0.8).floor() * 0.8;
      for (var mark = first; mark < xRight; mark += 0.8) {
        final p = world(mark, floor);
        canvas.drawLine(Offset(p.dx, railY), Offset(p.dx, railY + 6), Paint()..color = _rail..strokeWidth = 1.2);
      }
    }
    canvas.drawRRect(cabin, Paint()..color = const Color(0xFFECEFF1));
    canvas.drawRRect(
      cabin,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = _cabin,
    );
    _wheel(canvas, world(left + 0.28, floor));
    _wheel(canvas, world(right - 0.28, floor));

    final pivot = world((left + right) / 2, ceil - 0.08);
    final pivotY = ceil - 0.08;
    _drawTrail(
      canvas,
      world,
      ground ? groundTrail : trainTrail,
      ground ? groundStrobes : trainStrobes,
      pivotY,
    );
    final theta = sample.theta;
    final bob = pivot + Offset(math.sin(theta), math.cos(theta)) * params.length * scale;
    final eq = trainEquilibriumTheta(params.accel);
    final eqEnd = pivot + Offset(math.sin(eq), math.cos(eq)) * params.length * scale;
    _dashed(canvas, pivot, eqEnd, const Color(0xFFB0BEC5));
    canvas.drawLine(pivot, bob + Offset(-math.sin(theta), -math.cos(theta)) * 9, Paint()..color = _ink..strokeWidth = 1.6);
    canvas.drawCircle(pivot, 3.2, Paint()..color = _ink);
    canvas.drawCircle(bob, 8, Paint()..color = _mass);

    if (ground && params.accel > 0.05) {
      _arrow(canvas, world(right - 0.15, ceil + 0.02), const Offset(1, 0), 36, _accel, 'A');
    }

    final mg = 36.0;
    final tScale = sample.tension / (params.mass * kTrainG);
    final tLen = (mg * tScale).clamp(12.0, 78.0);
    final toPivot = Offset(-math.sin(theta), -math.cos(theta));
    _arrow(canvas, bob, toPivot, tLen, _tension, 'T');
    _arrow(canvas, bob + const Offset(-16, 0), const Offset(0, 1), mg, _gravity, '重力');
    if (!ground && params.accel > 0.05) {
      final iLen = (mg * params.accel / kTrainG).clamp(10.0, 70.0);
      _arrow(canvas, bob + const Offset(0, 16), const Offset(-1, 0), iLen, _inertial, '慣性力', dashed: true);
    }

    final leanDeg = sample.lean * 180 / math.pi;
    final lines = ground
        ? 'v = ${sample.cartV.toStringAsFixed(2)} m/s\nT = ${sample.tension.toStringAsFixed(2)} N'
        : 'a = ${leanDeg.toStringAsFixed(1)} °\nT = ${sample.tension.toStringAsFixed(2)} N';
    _text(canvas, plot.topLeft, lines, _ink, alignLeft: true);
  }

  void _drawTrail(
    Canvas canvas,
    Offset Function(double x, double y) world,
    List<TrainBobPosition> pts,
    List<TrainBobPosition> strobes,
    double pivotY,
  ) {
    if (pts.isEmpty) return;
    Offset at(TrainBobPosition p) => world(p.x, pivotY + p.y);

    final paint = Paint()
      ..color = _trail
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    var along = 0.0;
    for (var i = 0; i < pts.length - 1; i++) {
      final a = at(pts[i]);
      final b = at(pts[i + 1]);
      final delta = b - a;
      final len = delta.distance;
      if (len < 0.5) {
        along += len;
        continue;
      }
      final dir = delta / len;
      var d = 0.0;
      while (d < len) {
        final phase = (along + d) % 9.0;
        final room = phase < 5.0 ? 5.0 - phase : 9.0 - phase;
        final end = math.min(d + room, len);
        if (phase < 5.0) canvas.drawLine(a + dir * d, a + dir * end, paint);
        d = end;
      }
      along += len;
    }
    final dot = Paint()..color = _trail;
    for (final p in strobes) {
      canvas.drawCircle(at(p), 2.6, dot);
    }
  }

  void _wheel(Canvas canvas, Offset center) {
    canvas.drawCircle(center + const Offset(0, 5), 5, Paint()..color = _cabin);
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Color color) {
    final delta = b - a;
    final len = delta.distance;
    if (len < 1) return;
    final step = delta / len;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    var d = 0.0;
    while (d < len) {
      canvas.drawLine(a + step * d, a + step * math.min(d + 4, len), paint);
      d += 7;
    }
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
    final nrm = dir.distance == 0 ? const Offset(0, 1) : dir / dir.distance;
    final tip = origin + nrm * length;
    const headLen = 8.0;
    const headHalf = 4.0;
    final shaftEnd = tip - nrm * (headLen * 0.65);
    final n = Offset(-nrm.dy, nrm.dx);
    final shaft = Paint()
      ..color = color
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round;
    if (!dashed) {
      canvas.drawLine(origin, shaftEnd, shaft);
    } else {
      _dashed(canvas, origin, shaftEnd, color);
    }
    final head = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo((tip - nrm * headLen + n * headHalf).dx, (tip - nrm * headLen + n * headHalf).dy)
      ..lineTo((tip - nrm * headLen - n * headHalf).dx, (tip - nrm * headLen - n * headHalf).dy)
      ..close();
    canvas.drawPath(head, Paint()..color = color);
    _text(canvas, tip + n * 11, label, color);
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
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700, height: 1.25),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(alignLeft ? o.dx : o.dx - tp.width / 2, o.dy));
  }

  @override
  bool shouldRepaint(covariant _TrainPendulumPainter oldDelegate) {
    return oldDelegate.sample.t != sample.t ||
        oldDelegate.sample.theta != sample.theta ||
        oldDelegate.groundTrail.length != groundTrail.length ||
        oldDelegate.kind != kind ||
        oldDelegate.params.accel != params.accel ||
        oldDelegate.params.length != params.length ||
        oldDelegate.params.mass != params.mass ||
        oldDelegate.zoom != zoom;
  }
}
