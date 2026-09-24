import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/energy_gauge.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// 鉛直ループ。$g=9.8\,\mathrm{m/s^2}$、半径 $R=1\,\mathrm{m}$。再生だけ遅くする。
const double kLoopG = 9.8;
const double kLoopR = 1.0;
const double kLoopMinH = 0.40;
const double kLoopMaxH = 3.20;
const double kLoopDefaultH = 1.75;
const double kLoopStep = 1.0e-4;
const double kLoopRightStopX = 4.0;
const int kLoopMaxTrips = 100;

const double kLoopReturnH = 0.6;
const double kLoopBottomH = 1.75;
final double kLoopCenterH = 1 + math.sqrt(3) / 2;
const double kLoopAlmostH = 2.4;
const double kLoopFullH = 3.0;

enum LoopPhase { ramp, flatLeft, circle, flight, flatRight, stopped }

class LoopSample {
  const LoopSample({
    required this.t,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.phase,
    required this.theta,
    required this.energy,
    required this.normal,
    required this.roundTrips,
    required this.finished,
    required this.leftTheta,
    required this.landX,
    required this.landY,
    required this.landT,
    required this.leaveT,
    required this.minCenter,
    required this.minNormal,
    required this.turnTheta,
    required this.entrySpeed,
  });

  final double t;
  final double x;
  final double y;
  final double vx;
  final double vy;
  final LoopPhase phase;
  final double theta;
  final double energy;
  final double normal;
  final int roundTrips;
  final bool finished;
  final double? leftTheta;
  final double? landX;
  final double? landY;
  final double? landT;
  final double? leaveT;
  final double minCenter;
  final double minNormal;
  final double? turnTheta;
  final double? entrySpeed;

  double get speed => math.sqrt(vx * vx + vy * vy);
}

/// 質量 1 kg。出発点の高さが初期エネルギー。着地で失った分を熱にする。
EnergyLedger verticalLoopEnergy(double releaseHeight, LoopSample sample) {
  final scale = kLoopG * math.max(0.0, releaseHeight);
  final kinetic = 0.5 * sample.speed * sample.speed;
  final potential = kLoopG * math.max(0.0, sample.y);
  final heat = math.max(0.0, scale - kinetic - potential);
  return EnergyLedger(
    kinetic: kinetic,
    potential: potential,
    dissipated: heat,
    scale: scale,
    legendHeat: heat > 1e-2,
    potentialLabel: kLabelGravity,
  );
}

/// 斜面は $\xi=0$ が高さ $h$、$\xi=1$ で水平路に接する。
class LoopSim {
  LoopSim({required double heightRatio, this.dt = kLoopStep}) {
    reset(heightRatio);
  }

  final double dt;
  late double heightRatio;

  double get h => heightRatio * kLoopR;
  double get run => 1.8 * kLoopR;
  double get xJoin => -0.75 * kLoopR;
  double get xTop => xJoin - run;

  LoopPhase phase = LoopPhase.ramp;
  double t = 0;
  double xi = 0;
  double xiDot = 0;
  double theta = 0;
  double thetaDot = 0;
  double x = 0;
  double y = 0;
  double vx = 0;
  double vy = 0;
  bool flightArmed = false;
  bool finished = false;
  int roundTrips = 0;
  bool _leftTop = false;
  bool _tripLatched = false;

  double? leftTheta;
  double? landX;
  double? landY;
  double? landT;
  double? leaveT;
  double minCenter = double.infinity;
  double minNormal = double.infinity;
  double? turnTheta;
  double? entrySpeed;

  final List<Offset> trail = [];

  void reset(double nextH) {
    heightRatio = nextH.clamp(kLoopMinH, kLoopMaxH).toDouble();
    phase = LoopPhase.ramp;
    t = 0;
    xi = 0;
    xiDot = 0;
    theta = 0;
    thetaDot = 0;
    x = xTop;
    y = h;
    vx = 0;
    vy = 0;
    flightArmed = false;
    finished = false;
    roundTrips = 0;
    _leftTop = false;
    _tripLatched = false;
    leftTheta = null;
    landX = null;
    landY = null;
    landT = null;
    leaveT = null;
    minCenter = double.infinity;
    minNormal = double.infinity;
    turnTheta = null;
    entrySpeed = null;
    trail
      ..clear()
      ..add(Offset(x, y));
  }

  LoopSample snapshot() {
    return LoopSample(
      t: t,
      x: x,
      y: y,
      vx: vx,
      vy: vy,
      phase: phase,
      theta: theta,
      energy: energy,
      normal: normalAccel,
      roundTrips: roundTrips,
      finished: finished,
      leftTheta: leftTheta,
      landX: landX,
      landY: landY,
      landT: landT,
      leaveT: leaveT,
      minCenter: minCenter,
      minNormal: minNormal,
      turnTheta: turnTheta,
      entrySpeed: entrySpeed,
    );
  }

  double get speed => math.sqrt(vx * vx + vy * vy);

  double get energy {
    return 0.5 * (vx * vx + vy * vy) + kLoopG * y;
  }

  /// 円レール上の $N/m$。レール上でないときは 0。
  double get normalAccel {
    if (phase != LoopPhase.circle) return 0;
    return kLoopR * thetaDot * thetaDot + kLoopG * math.cos(theta);
  }

  void advance(double elapsed) {
    if (elapsed <= 0 || finished) return;
    var left = elapsed;
    while (left > 1e-12 && !finished) {
      final stepDt = math.min(dt, left);
      step(stepDt);
      left -= stepDt;
    }
  }

  void step(double stepDt) {
    if (finished || stepDt <= 0) return;
    switch (phase) {
      case LoopPhase.ramp:
        _stepRamp(stepDt);
      case LoopPhase.flatLeft:
        _stepFlatLeft(stepDt);
      case LoopPhase.circle:
        _stepCircle(stepDt);
      case LoopPhase.flight:
        _stepFlight(stepDt);
      case LoopPhase.flatRight:
        _stepFlatRight(stepDt);
      case LoopPhase.stopped:
        break;
    }
    t += stepDt;
    _pushTrail();
  }

  void _pushTrail() {
    final last = trail.last;
    if ((last.dx - x).abs() + (last.dy - y).abs() < 0.01) return;
    trail.add(Offset(x, y));
    if (trail.length > 700) trail.removeAt(0);
  }

  void _syncRampKinematics() {
    final yp = -2 * h * (1 - xi);
    x = xTop + run * xi;
    y = h * (1 - xi) * (1 - xi);
    vx = run * xiDot;
    vy = yp * xiDot;
  }

  void _stepRamp(double stepDt) {
    final one = 1 - xi;
    final yp = -2 * h * one;
    final speed2 = run * run + yp * yp;
    final xiDdot = (2 * kLoopG * h * one + 4 * h * h * one * xiDot * xiDot) /
        speed2;
    final prev = xiDot;
    xiDot += xiDdot * stepDt;
    xi += xiDot * stepDt;
    if (xi <= 0 && prev < 0) {
      xi = 0;
      xiDot = 0;
      _countTrip();
    } else if (!_tripLatched &&
        _leftTop &&
        prev < 0 &&
        xiDot >= 0 &&
        xi > 0 &&
        xi < 1) {
      _countTrip();
    }
    if (xiDot > 0.05) _tripLatched = false;
    if (xi >= 1 && xiDot >= 0) {
      final extra = xi - 1;
      xi = 1;
      vx = run * xiDot;
      vy = 0;
      x = xJoin + run * extra;
      y = 0;
      phase = LoopPhase.flatLeft;
      _leftTop = true;
      return;
    }
    _syncRampKinematics();
  }

  void _countTrip() {
    _tripLatched = true;
    roundTrips += 1;
    if (roundTrips >= kLoopMaxTrips) {
      finished = true;
      phase = LoopPhase.stopped;
    }
  }

  void _stepFlatLeft(double stepDt) {
    x += vx * stepDt;
    y = 0;
    vy = 0;
    if (vx >= 0 && x >= 0) {
      theta = 0;
      thetaDot = vx / kLoopR;
      entrySpeed ??= vx;
      x = 0;
      y = 0;
      phase = LoopPhase.circle;
      return;
    }
    if (vx < 0 && x <= xJoin) {
      xi = 1;
      xiDot = vx / run;
      phase = LoopPhase.ramp;
      _syncRampKinematics();
    }
  }

  void _stepCircle(double stepDt) {
    final n = kLoopR * thetaDot * thetaDot + kLoopG * math.cos(theta);
    if (n < minNormal) minNormal = n;
    // 頂上の N=0 は一周の臨界。刻み誤差のごく小さな負は離脱にしない。
    if (math.cos(theta) < 0 && n < -0.06) {
      _leaveCircle();
      return;
    }
    final prevTheta = theta;
    final prevDot = thetaDot;
    thetaDot += -(kLoopG / kLoopR) * math.sin(theta) * stepDt;
    theta += thetaDot * stepDt;
    if (prevDot > 0 && thetaDot <= 0 && leftTheta == null && theta > 0 && theta < math.pi) {
      turnTheta = theta;
    }
    if (theta < 0 && prevTheta >= 0 && thetaDot < 0) {
      vx = kLoopR * thetaDot;
      vy = 0;
      x = 0;
      y = 0;
      phase = LoopPhase.flatLeft;
      return;
    }
    if (theta >= 2 * math.pi && thetaDot > 0) {
      vx = kLoopR * thetaDot;
      vy = 0;
      x = 0;
      y = 0;
      phase = LoopPhase.flatRight;
      return;
    }
    x = kLoopR * math.sin(theta);
    y = kLoopR * (1 - math.cos(theta));
    vx = kLoopR * thetaDot * math.cos(theta);
    vy = kLoopR * thetaDot * math.sin(theta);
  }

  void _leaveCircle() {
    x = kLoopR * math.sin(theta);
    y = kLoopR * (1 - math.cos(theta));
    vx = kLoopR * thetaDot * math.cos(theta);
    vy = kLoopR * thetaDot * math.sin(theta);
    leftTheta = theta;
    leaveT = t;
    flightArmed = false;
    phase = LoopPhase.flight;
  }

  void _stepFlight(double stepDt) {
    final x0 = x;
    final y0 = y;
    final r0 = _radius(x0, y0);
    vy -= kLoopG * stepDt;
    x += vx * stepDt;
    y += vy * stepDt;
    final r1 = _radius(x, y);
    final center = math.sqrt(x * x + (y - kLoopR) * (y - kLoopR));
    if (center < minCenter) minCenter = center;
    if (!flightArmed && r1 < kLoopR - 1e-4) flightArmed = true;
    if (flightArmed && r0 < kLoopR && r1 >= kLoopR) {
      final denom = r1 - r0;
      final frac = denom.abs() < 1e-12 ? 1.0 : ((kLoopR - r0) / denom).clamp(0.0, 1.0);
      x = x0 + (x - x0) * frac;
      y = y0 + (y - y0) * frac;
      _landOnCircle();
      return;
    }
    if (y < 0) {
      y = 0;
      vx = 0;
      vy = 0;
      phase = LoopPhase.stopped;
      finished = true;
    }
  }

  void _landOnCircle() {
    var th = math.atan2(x / kLoopR, -(y - kLoopR) / kLoopR);
    if (th < 0) th += 2 * math.pi;
    final nearBottom = y < 0.03 && x.abs() < 0.05;
    theta = nearBottom ? 0 : th;
    thetaDot = 0;
    vx = 0;
    vy = 0;
    if (nearBottom) {
      x = 0;
      y = 0;
      phase = LoopPhase.stopped;
      finished = true;
    } else {
      x = kLoopR * math.sin(theta);
      y = kLoopR * (1 - math.cos(theta));
      phase = LoopPhase.circle;
    }
    landX = x;
    landY = y;
    landT = t;
  }

  void _stepFlatRight(double stepDt) {
    x += vx * stepDt;
    y = 0;
    vy = 0;
    if (x >= kLoopRightStopX * kLoopR) finished = true;
  }

  double _radius(double px, double py) {
    final dx = px;
    final dy = py - kLoopR;
    return math.sqrt(dx * dx + dy * dy);
  }

  String get status {
    if (finished && roundTrips >= kLoopMaxTrips) return '100往復で停止';
    if (finished && phase == LoopPhase.stopped && (landY ?? 1) < 0.03) {
      return '最下点で停止';
    }
    if (finished && phase == LoopPhase.flatRight) return '右の地面の先で停止';
    switch (phase) {
      case LoopPhase.ramp:
      case LoopPhase.flatLeft:
        return vx < -0.05 || xiDot < 0 ? '斜面へ戻る' : '斜面を下る';
      case LoopPhase.circle:
        if (speed < 0.05 && landT != null) return '着地して停止';
        return theta > math.pi ? '円の左側を滑る' : '円レール上';
      case LoopPhase.flight:
        return '放物運動';
      case LoopPhase.flatRight:
        return '右の地面へ進む';
      case LoopPhase.stopped:
        return '停止';
    }
  }
}

String loopCaption(double heightRatio) {
  final hText = heightRatio.toStringAsFixed(2);
  if (heightRatio <= 1) {
    return 'H = $hText。下半分で止まり、来た道を戻る。';
  }
  if (heightRatio < 2.5) {
    return 'H = $hText。上半分で離れ、着地で速度は 0 になる。';
  }
  return 'H = $hText。一周し、右の地面へ出る。';
}

final verticalLoop2D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '鉛直ループ',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>点 A の高さ $h$ から、半径 $R$ の滑らかな鉛直円へ入る。角度 $\theta$ は最下点から測る。</p>
  <p>$$\displaystyle \frac{N}{m}=\frac{v^{2}}{R}+g\cos\theta$$</p>
  <p>離れるのは上半分だけで、その角度は</p>
  <p>$$\displaystyle \cos\theta=\frac{2(R-h)}{3R}$$</p>
  <p>$\displaystyle h\le R$ なら戻る。$\displaystyle R&lt;h&lt;\frac{5}{2}R$ なら放物運動のあと着地する。$\displaystyle h\ge\frac{5}{2}R$ なら一周して右へ進む。</p>
  <p>着地は完全非弾性で、速度はいったん 0 になる。</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: VerticalLoopSimulation(),
      height: 920,
    ),
  ],
);

class VerticalLoopSimulation extends PhysicsSimulation {
  VerticalLoopSimulation()
      : super(
          title: '鉛直ループ',
          formula: const FormulaDisplay(
            r'\displaystyle \frac{N}{m}=\frac{v^{2}}{R}+g\cos\theta',
          ),
          aspectRatio: 2,
          enableTime: false,
          showTimeOverlay: false,
        );

  final LoopSim sim = LoopSim(heightRatio: kLoopDefaultH);

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    sim.advance(dt * _playback);
    simTime.value = sim.t;
    if (sim.finished) _loop.pause();
  });

  final ValueNotifier<double> simTime = ValueNotifier(0.0);
  ValueNotifier<bool> get running => _loop.running;

  static const double _playback = 0.45;
  double _seenH = kLoopDefaultH;

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {'H': kLoopDefaultH};

  void _syncHeight(double nextH) {
    if ((nextH - _seenH).abs() < 1e-9 && (nextH - sim.heightRatio).abs() < 1e-9) {
      return;
    }
    _seenH = nextH;
    final was = running.value;
    sim.reset(nextH);
    simTime.value = 0;
    if (!was) _loop.pause();
  }

  void start() {
    if (running.value) return;
    if (sim.finished) {
      sim.reset(_seenH);
      simTime.value = 0;
    }
    _loop.start();
  }

  void pause() => _loop.pause();

  void resetMotion() {
    _loop.reset();
    sim.reset(_seenH);
    simTime.value = 0;
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
              loopCaption(sim.heightRatio),
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
    final hValue = (parameters['H'] ?? kLoopDefaultH)
        .clamp(kLoopMinH, kLoopMaxH)
        .toDouble();
    _syncHeight(hValue);
    return [
      const Text(
        '初期条件（R = 1 m、滑らか）',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      Row(
        children: [
          const SizedBox(
            width: 28,
            child: Text('H', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Semantics(
              label: '高さ比 H',
              child: Slider(
                value: hValue,
                min: kLoopMinH,
                max: kLoopMaxH,
                onChanged: (v) => updateParam('H', v),
                semanticFormatterCallback: (v) =>
                    '高さ比 H ${v.toStringAsFixed(2)}',
              ),
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              hValue.toStringAsFixed(2),
              style: const TextStyle(fontSize: 12, fontFamily: 'Courier'),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
      Wrap(
        spacing: 6,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: [
          _preset(context, '戻る', kLoopReturnH, hValue, updateParam),
          _preset(context, 'Bに着地', kLoopBottomH, hValue, updateParam),
          _preset(context, '中心を通る', kLoopCenterH, hValue, updateParam),
          _preset(context, '一周の直前', kLoopAlmostH, hValue, updateParam),
          _preset(context, '一周', kLoopFullH, hValue, updateParam),
        ],
      ),
    ];
  }

  Widget _preset(
    BuildContext context,
    String label,
    double value,
    double current,
    void Function(String key, double value) updateParam,
  ) {
    final selected = (current - value).abs() < 0.02;
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      backgroundColor: selected ? const Color(0xFFBBDEFB) : null,
      onPressed: () => updateParam('H', value),
    );
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
    final hValue = (parameters['H'] ?? kLoopDefaultH)
        .clamp(kLoopMinH, kLoopMaxH)
        .toDouble();
    _syncHeight(hValue);
    return AnimatedBuilder(
      animation: Listenable.merge([running, simTime]),
      builder: (context, _) {
        return CustomPaint(
          size: Size.infinite,
          painter: _LoopPainter(sim: sim, sample: sim.snapshot()),
        );
      },
    );
  }
}

class _LoopPainter extends CustomPainter {
  _LoopPainter({required this.sim, required this.sample});

  final LoopSim sim;
  final LoopSample sample;

  static const _bg = Color(0xFFF7FAFC);
  static const _ink = Color(0xFF37474F);
  static const _track = Color(0xFF546E7A);
  static const _ball = Color(0xFF1E88E5);
  static const _trail = Color(0xFF90A4AE);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final lines = '${sim.status}\n'
        't = ${sample.t.toStringAsFixed(2)} s    '
        'v = ${sample.speed.toStringAsFixed(2)} m/s';
    final ledger = verticalLoopEnergy(sim.h, sample);
    final cardBottom = dynamicsReadoutCard(
      lines,
      ledger,
      textColumnWidth: 220,
      bounds: size,
    ).bottom;
    final map = _mapper(size, cardBottom + 8);
    _drawGround(canvas, map);
    _drawRamp(canvas, map);
    _drawCircle(canvas, map);
    _drawTrail(canvas, map);
    _drawBall(canvas, map);
    paintDynamicsReadout(
      canvas,
      lines,
      ledger,
      textColumnWidth: 220,
      bounds: size,
    );
  }

  _LoopMap _mapper(Size size, double hud) {
    const margin = 16.0;
    final left = sim.xTop - 0.2;
    final right = kLoopRightStopX * kLoopR + 0.3;
    final bottom = -0.25;
    final top = math.max(sim.h, 2 * kLoopR) + 0.35;
    final scale = math.min(
      (size.width - 2 * margin) / (right - left),
      (size.height - hud - margin) / (top - bottom),
    );
    return _LoopMap(
      scale: scale,
      of: (x, y) => Offset(
        margin + (x - left) * scale,
        hud + (top - y) * scale,
      ),
    );
  }

  void _drawGround(Canvas canvas, _LoopMap map) {
    final paint = Paint()
      ..color = _track
      ..strokeWidth = 2;
    canvas.drawLine(map.of(sim.xJoin, 0), map.of(0, 0), paint);
    canvas.drawLine(
      map.of(0, 0),
      map.of(kLoopRightStopX * kLoopR, 0),
      paint,
    );
  }

  void _drawRamp(Canvas canvas, _LoopMap map) {
    final path = Path();
    const n = 24;
    for (var i = 0; i <= n; i++) {
      final xi = i / n;
      final x = sim.xTop + sim.run * xi;
      final y = sim.h * (1 - xi) * (1 - xi);
      final p = map.of(x, y);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = _track
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawCircle(Canvas canvas, _LoopMap map) {
    final c = map.of(0, kLoopR);
    canvas.drawCircle(
      c,
      kLoopR * map.scale,
      Paint()
        ..color = _track
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final o = map.of(0, kLoopR);
    canvas.drawCircle(o, 2.2, Paint()..color = _ink);
  }

  void _drawTrail(Canvas canvas, _LoopMap map) {
    if (sim.trail.length < 2) return;
    final path = Path();
    final first = map.of(sim.trail.first.dx, sim.trail.first.dy);
    path.moveTo(first.dx, first.dy);
    for (final p in sim.trail.skip(1)) {
      final q = map.of(p.dx, p.dy);
      path.lineTo(q.dx, q.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = _trail
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  void _drawBall(Canvas canvas, _LoopMap map) {
    canvas.drawCircle(
      map.of(sample.x, sample.y),
      math.max(4.0, 0.07 * kLoopR * map.scale),
      Paint()..color = _ball,
    );
  }

  @override
  bool shouldRepaint(covariant _LoopPainter oldDelegate) => true;
}

class _LoopMap {
  const _LoopMap({required this.of, required this.scale});

  final Offset Function(double x, double y) of;
  final double scale;
}
