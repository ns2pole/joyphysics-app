import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/energy_gauge.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// 動滑車と、そこから下がる質量は一体で $m$。自由端のおもりは $M$。
/// 動滑車の上向きを正にすると、おもり $M$ の下向き変位はその 2 倍。
/// $g=9.8\,\mathrm{m/s^2}$。滑車は軽く、糸は伸びない。
const double kMovablePulleyG = 9.8;
const double kMovablePulleyMinMass = 0.50;
const double kMovablePulleyMaxMass = 4.00;
const double kMovablePulleyDefaultM = 2.00;
const double kMovablePulleyDefaultLoad = 2.00;

/// 止めるまでの、動滑車の変位の大きさ。おもり $M$ はその 2 倍動く。
const double kMovablePulleyTravel = 0.40;

class MovablePulleyParams {
  const MovablePulleyParams({required this.m, required this.M});

  final double m;
  final double M;

  factory MovablePulleyParams.fromMap(Map<String, double> params) {
    return MovablePulleyParams(
      m: params['m']!.clamp(kMovablePulleyMinMass, kMovablePulleyMaxMass).toDouble(),
      M: params['M']!.clamp(kMovablePulleyMinMass, kMovablePulleyMaxMass).toDouble(),
    );
  }

  /// 動滑車（質量 $m$）の上向き加速度。
  double get alpha => (2 * M - m) * kMovablePulleyG / (m + 4 * M);

  /// おもり $M$ の下向き加速度。
  double get beta => 2 * alpha;

  double get tension => 3 * m * M * kMovablePulleyG / (m + 4 * M);

  bool get balanced => alpha.abs() <= 1e-9;

  bool get pulleyRises => alpha > 1e-9;
}

class MovablePulleySample {
  const MovablePulleySample({
    required this.t,
    required this.sPulleyUp,
    required this.vPulleyUp,
    required this.aPulleyUp,
    required this.tension,
    required this.stopped,
  });

  final double t;

  /// 動滑車の上向き変位。下がるときは負。
  final double sPulleyUp;
  final double vPulleyUp;
  final double aPulleyUp;
  final double tension;

  /// 見せる区間の端まで来て止めている。床には当たっていない。
  final bool stopped;

  /// おもり $M$ の下向き変位。上がるときは負。
  double get sLoadDown => 2 * sPulleyUp;

  double get vLoadDown => 2 * vPulleyUp;
}

double? movablePulleyStopTime(MovablePulleyParams params) {
  final a = params.alpha.abs();
  if (a <= 1e-12) return null;
  return math.sqrt(2 * kMovablePulleyTravel / a);
}

MovablePulleySample movablePulleyAt(MovablePulleyParams params, double t) {
  final time = math.max(0.0, t);
  final a = params.alpha;
  if (a.abs() <= 1e-12) {
    return MovablePulleySample(
      t: time,
      sPulleyUp: 0,
      vPulleyUp: 0,
      aPulleyUp: 0,
      tension: params.tension,
      stopped: false,
    );
  }
  final tStop = math.sqrt(2 * kMovablePulleyTravel / a.abs());
  if (time >= tStop) {
    final speed = math.sqrt(2 * a.abs() * kMovablePulleyTravel);
    return MovablePulleySample(
      t: tStop,
      sPulleyUp: a.sign * kMovablePulleyTravel,
      vPulleyUp: a.sign * speed,
      aPulleyUp: a,
      tension: params.tension,
      stopped: true,
    );
  }
  return MovablePulleySample(
    t: time,
    sPulleyUp: 0.5 * a * time * time,
    vPulleyUp: a * time,
    aPulleyUp: a,
    tension: params.tension,
    stopped: false,
  );
}

/// 動滑車が最も低い位置、おもり $M$ が最も低い位置を位置エネルギーの基準にする。
EnergyLedger movablePulleyEnergy(
  MovablePulleyParams params,
  MovablePulleySample sample,
) {
  const travel = kMovablePulleyTravel;
  if (params.balanced) {
    final u = (params.m + params.M) * kMovablePulleyG * travel;
    return EnergyLedger(
      kinetic: 0,
      potential: u,
      dissipated: 0,
      scale: u,
      potentialLabel: kLabelGravity,
    );
  }
  final sFinal = params.alpha.sign * travel;
  final s = sample.sPulleyUp;
  final heightPulley = s - math.min(0.0, sFinal);
  final heightLoad = -2 * s + math.max(0.0, 2 * sFinal);
  final potential =
      params.m * kMovablePulleyG * heightPulley + params.M * kMovablePulleyG * heightLoad;
  final kinetic = 0.5 * (params.m + 4 * params.M) * sample.vPulleyUp * sample.vPulleyUp;
  final scale = params.pulleyRises
      ? 2 * params.M * kMovablePulleyG * travel
      : params.m * kMovablePulleyG * travel;
  return EnergyLedger(
    kinetic: kinetic,
    potential: potential,
    dissipated: 0,
    scale: scale,
    potentialLabel: kLabelGravity,
  );
}

/// 画面上の配置。落ちる側を少し高くし、定滑車には触れないところで止める。
class MovablePulleyLayout {
  const MovablePulleyLayout({
    required this.fixed,
    required this.fixedR,
    required this.movableX,
    required this.movableR,
    required this.axleY0,
    required this.axleY,
    required this.bobR,
    required this.bobY0,
    required this.bobY,
    required this.loadX,
    required this.loadR,
    required this.loadY0,
    required this.loadY,
    required this.ceilingY,
    required this.groundY,
    required this.risingLayout,
  });

  final Offset fixed;
  final double fixedR;
  final double movableX;
  final double movableR;
  final double axleY0;
  final double axleY;
  final double bobR;
  final double bobY0;
  final double bobY;
  final double loadX;
  final double loadR;
  final double loadY0;
  final double loadY;
  final double ceilingY;
  final double groundY;
  final bool risingLayout;

  double get fixedBottom => fixed.dy + fixedR;

  double get axleTop => axleY - movableR;

  double get loadTop => loadY - loadR;

  Offset get axle => Offset(movableX, axleY);

  Offset get axle0 => Offset(movableX, axleY0);

  Offset get bob => Offset(movableX, bobY);

  Offset get load => Offset(loadX, loadY);

  Offset get load0 => Offset(loadX, loadY0);
}

double movablePulleyBobRadius(double mass) {
  final t = ((mass - kMovablePulleyMinMass) /
          (kMovablePulleyMaxMass - kMovablePulleyMinMass))
      .clamp(0.0, 1.0);
  return 15 + 10 * t;
}

MovablePulleyLayout layoutMovablePulley({
  required double width,
  required double height,
  required double hudBottom,
  required MovablePulleyParams params,
  required double sPulleyUp,
}) {
  final fixedR = math.min(28.0, width * 0.078);
  final movableR = math.min(15.0, fixedR * 0.56);
  final bobR = movablePulleyBobRadius(params.m);
  final loadR = movablePulleyBobRadius(params.M);
  final fixedX = width * 0.50;
  final fixedY = hudBottom + 10 + fixedR;
  final movableX = fixedX - fixedR - movableR;
  final loadX = fixedX + fixedR;
  final stem = 6.0;
  final groundY = height - 22;
  const groundGap = 12.0;
  const gapPulley = 30.0;
  const gapLoad = 22.0;

  final minAxleY = fixedY + fixedR + gapPulley + movableR;
  final minLoadY = fixedY + fixedR + gapLoad + loadR;
  final maxBobBottom = groundY - groundGap;
  final maxAxleY = maxBobBottom - stem - 2 * bobR - movableR;
  final maxLoadY = groundY - groundGap - loadR;

  // 釣り合いは教科書の絵（おもり M が少し上）に揃える。
  final risingLayout = params.balanced || params.pulleyRises;

  var pulleyPx = 72.0;
  var higherBy = 48.0;

  bool fits(double travelPx, double lift) {
    final loadPx = 2 * travelPx;
    if (risingLayout) {
      final axle0 = minAxleY + travelPx;
      final bob0 = axle0 + movableR + stem + bobR;
      final load0 = bob0 - lift;
      final load1 = load0 + loadPx;
      final axle1 = axle0 - travelPx;
      if (axle0 > maxAxleY || axle1 < minAxleY - 0.5) return false;
      if (load0 < minLoadY || load1 > maxLoadY) return false;
      if (bob0 + bobR > maxBobBottom) return false;
      return true;
    }
    final load1 = minLoadY;
    final load0 = load1 + loadPx;
    final bob0 = load0 - lift;
    final axle0 = bob0 - movableR - stem - bobR;
    final axle1 = axle0 + travelPx;
    final bob1 = axle1 + movableR + stem + bobR;
    if (axle0 < minAxleY || axle1 > maxAxleY) return false;
    if (load0 > maxLoadY || load1 < minLoadY - 0.5) return false;
    if (bob1 + bobR > maxBobBottom) return false;
    return true;
  }

  var ok = fits(pulleyPx, higherBy);
  while (!ok && pulleyPx > 36) {
    pulleyPx -= 4;
    ok = fits(pulleyPx, higherBy);
  }
  while (!ok && higherBy > 24) {
    higherBy -= 4;
    ok = fits(pulleyPx, higherBy);
  }
  while (!ok && pulleyPx > 16) {
    pulleyPx -= 4;
    ok = fits(pulleyPx, higherBy);
  }

  late final double axleY0;
  late final double loadY0;
  if (risingLayout) {
    axleY0 = minAxleY + pulleyPx;
    final bob0 = axleY0 + movableR + stem + bobR;
    loadY0 = bob0 - higherBy;
  } else {
    loadY0 = minLoadY + 2 * pulleyPx;
    final bob0 = loadY0 - higherBy;
    axleY0 = bob0 - movableR - stem - bobR;
  }

  final pxPerMeter = pulleyPx / kMovablePulleyTravel;
  final axleY = axleY0 - sPulleyUp * pxPerMeter;
  final loadY = loadY0 + 2 * sPulleyUp * pxPerMeter;
  final bobY0 = axleY0 + movableR + stem + bobR;
  final bobY = axleY + movableR + stem + bobR;

  return MovablePulleyLayout(
    fixed: Offset(fixedX, fixedY),
    fixedR: fixedR,
    movableX: movableX,
    movableR: movableR,
    axleY0: axleY0,
    axleY: axleY,
    bobR: bobR,
    bobY0: bobY0,
    bobY: bobY,
    loadX: loadX,
    loadR: loadR,
    loadY0: loadY0,
    loadY: loadY,
    ceilingY: hudBottom + 4,
    groundY: groundY,
    risingLayout: risingLayout,
  );
}

const String kMovablePulleyCaption =
    '動滑車と質量 m は一体。おもり M が x 動くと、動滑車は x/2 動く。\n'
    '2M > m なら動滑車は上がり、おもり M は下がる。m > 2M なら逆。\n'
    '落ちる側を少し高くしてある。定滑車に当たる前で止める。\n'
    '2M = m なら加速度は 0 で、放しても動かない。';

final movablePulley1D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '動滑車',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>定滑車にかけた糸の一端におもり $M$、もう一端側に動滑車をかけます。動滑車と、そこから下がる物体はまとめて質量 $m$ とします。滑車の慣性と摩擦はなく、糸は伸びません。</p>
  <p>動滑車を支える糸は 2 本なので、おもり $M$ が $x$ だけ下がると動滑車は $\displaystyle \frac{x}{2}$ だけ上がります。動滑車の上向き加速度を $\alpha$、おもり $M$ の下向き加速度を $\beta$ とすると $\beta=2\alpha$ です。</p>
  <p>$$m\alpha=2T-mg,\quad M\beta=Mg-T$$</p>
  <p>$$ \alpha=\frac{(2M-m)g}{m+4M},\quad \beta=\frac{2(2M-m)g}{m+4M},\quad T=\frac{3mMg}{m+4M} $$</p>
  <p>$2M>m$ なら動滑車は上がり、おもり $M$ は下がります。$m>2M$ なら動滑車が下がります。$2M=m$ なら $\alpha=0$ で、張力は $\displaystyle T=\frac{1}{2}mg$ です。</p>
  <p>静かに放して、動滑車が距離 $\displaystyle \frac{h}{2}$（$h$ はおもり $M$ の変位の大きさ）だけ動いたときの、おもり $M$ の速さは</p>
  <p>$$v=2\sqrt{\frac{|2M-m|gh}{m+4M}}$$</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: MovablePulley1DSimulation(),
      height: 980,
    ),
  ],
);

class MovablePulley1DSimulation extends PhysicsSimulation {
  MovablePulley1DSimulation()
      : super(
          title: '動滑車',
          formula: const FormulaDisplay(
            r'\displaystyle \alpha=\frac{(2M-m)g}{m+4M},\quad \beta=2\alpha,\quad T=\frac{3mMg}{m+4M}',
          ),
          aspectRatio: 3 / 5,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> simTime = ValueNotifier(0.0);

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    final stop = movablePulleyStopTime(_params);
    if (stop == null) {
      _loop.pause();
      return;
    }
    final next = math.min(stop, simTime.value + dt * _playback);
    simTime.value = next;
    if (next >= stop - 1e-4) _loop.pause();
  });

  ValueNotifier<bool> get running => _loop.running;

  Map<String, double> _latestParams = {};

  static const double _playback = 0.22;

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'm': kMovablePulleyDefaultM,
        'M': kMovablePulleyDefaultLoad,
      };

  MovablePulleyParams get _params {
    if (_latestParams.isEmpty) {
      return MovablePulleyParams.fromMap(initialParameters);
    }
    return MovablePulleyParams.fromMap(_latestParams);
  }

  void _rememberParams(Map<String, double> params) {
    _latestParams = Map<String, double>.from(params);
  }

  void start() {
    if (running.value || _params.balanced) return;
    final stop = movablePulleyStopTime(_params);
    if (stop != null && simTime.value >= stop - 1e-3) {
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
      return r'\displaystyle \alpha=0,\quad \beta=0,\quad T=\frac{1}{2}mg';
    }
    return r'\displaystyle \alpha=\frac{(2M-m)g}{m+4M},\quad \beta=2\alpha,\quad T=\frac{3mMg}{m+4M}';
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
              kMovablePulleyCaption,
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
    final way = p.balanced
        ? '釣り合い'
        : p.pulleyRises
            ? '動滑車は上へ、おもり M は下へ'
            : '動滑車は下へ、おもり M は上へ';
    return [
      const Text(
        '初期条件（g = 9.8 m/s²、静かに放す）',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _MassSlider(
        label: 'm',
        value: p.m,
        semanticLabel: '動滑車側の質量 m',
        onChanged: (v) {
          updateParam('m', v);
          resetMotion();
        },
      ),
      _MassSlider(
        label: 'M',
        value: p.M,
        semanticLabel: 'おもりの質量 M',
        onChanged: (v) {
          updateParam('M', v);
          resetMotion();
        },
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '$way    α ${p.alpha.toStringAsFixed(2)} m/s²    T ${p.tension.toStringAsFixed(2)} N',
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
        final p = MovablePulleyParams.fromMap(parameters);
        final sample = movablePulleyAt(p, simTime.value);
        return CustomPaint(
          size: Size.infinite,
          painter: _MovablePulleyPainter(params: p, sample: sample),
        );
      },
    );
  }
}

class _MassSlider extends StatelessWidget {
  const _MassSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 22,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Semantics(
            label: semanticLabel,
            child: Slider(
              value: value.clamp(kMovablePulleyMinMass, kMovablePulleyMaxMass),
              min: kMovablePulleyMinMass,
              max: kMovablePulleyMaxMass,
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

class _MovablePulleyPainter extends CustomPainter {
  _MovablePulleyPainter({required this.params, required this.sample});

  final MovablePulleyParams params;
  final MovablePulleySample sample;

  static const _bg = Color(0xFFF7FAFC);
  static const _bob = Color(0xFF1E88E5);
  static const _load = Color(0xFFE53935);
  static const _gravity = Color(0xFFEF6C00);
  static const _tension = Color(0xFFAD1457);
  static const _velocity = Color(0xFF1565C0);
  static const _ink = Color(0xFF37474F);
  static const _pulley = Color(0xFF546E7A);
  static const _ground = Color(0xFF8D6E63);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final lines = _hudLines();
    final hudBottom = dynamicsReadoutCard(
      lines,
      movablePulleyEnergy(params, sample),
      textColumnWidth: 188,
      bounds: size,
    ).bottom;
    final layout = layoutMovablePulley(
      width: size.width,
      height: size.height,
      hudBottom: hudBottom,
      params: params,
      sPulleyUp: sample.sPulleyUp,
    );
    _drawGround(canvas, size, layout.groundY);
    _drawBeforeLines(canvas, size, layout);
    if (sample.stopped) {
      _drawAfterLines(canvas, size, layout);
    }
    _drawRig(canvas, layout);
    _drawMasses(canvas, layout);
    if (!sample.stopped && sample.vPulleyUp.abs() > 0.04) {
      _drawVelocity(canvas, layout);
    }
    if (sample.stopped) {
      _drawDisplacement(canvas, size, layout);
    }
    paintDynamicsReadout(
      canvas,
      lines,
      movablePulleyEnergy(params, sample),
      textColumnWidth: 188,
      bounds: size,
    );
  }

  String _hudLines() {
    final pulleyWay = _way(sample.sPulleyUp, up: '上', down: '下');
    final loadWay = _way(sample.sLoadDown, up: '下', down: '上');
    final tail = params.balanced
        ? '動かない'
        : sample.stopped
            ? '止めた'
            : '動滑車は${params.pulleyRises ? '上' : '下'}へ';
    return 't = ${sample.t.toStringAsFixed(2)} s\n'
        '動滑車 $pulleyWay ${sample.sPulleyUp.abs().toStringAsFixed(2)} m\n'
        'おもり $loadWay ${sample.sLoadDown.abs().toStringAsFixed(2)} m\n'
        'α = ${sample.aPulleyUp.toStringAsFixed(2)} m/s²\n'
        'β = ${params.beta.toStringAsFixed(2)} m/s²\n'
        'T = ${sample.tension.toStringAsFixed(2)} N\n'
        '$tail';
  }

  String _way(double signed, {required String up, required String down}) {
    if (signed.abs() < 1e-4) return '　';
    return signed > 0 ? up : down;
  }

  void _drawGround(Canvas canvas, Size size, double groundY) {
    final left = 14.0;
    final right = size.width - 14;
    canvas.drawLine(
      Offset(left, groundY),
      Offset(right, groundY),
      Paint()
        ..color = _ground
        ..strokeWidth = 2.8
        ..strokeCap = StrokeCap.square,
    );
    final hatch = Paint()
      ..color = _ground
      ..strokeWidth = 1.35;
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(left, groundY, right, groundY + 16));
    for (var x = left - 8; x < right + 16; x += 9) {
      canvas.drawLine(Offset(x, groundY), Offset(x - 14, groundY + 16), hatch);
    }
    canvas.restore();
    _label(canvas, Offset(right - 22, groundY - 14), '地面', _ground, size: 10);
  }

  void _drawBeforeLines(Canvas canvas, Size size, MovablePulleyLayout layout) {
    _levelLine(
      canvas,
      y: layout.axleY0,
      x0: 12,
      x1: layout.movableX + layout.movableR + 8,
      color: _bob,
      dotted: true,
      tag: '前',
      tagOnRight: false,
    );
    _levelLine(
      canvas,
      y: layout.loadY0,
      x0: layout.loadX - layout.loadR - 8,
      x1: size.width - 12,
      color: _load,
      dotted: true,
      tag: '前',
      tagOnRight: true,
    );
  }

  void _drawAfterLines(Canvas canvas, Size size, MovablePulleyLayout layout) {
    _levelLine(
      canvas,
      y: layout.axleY,
      x0: 12,
      x1: layout.movableX + layout.movableR + 8,
      color: _bob,
      dotted: false,
      tag: '後',
      tagOnRight: false,
    );
    _levelLine(
      canvas,
      y: layout.loadY,
      x0: layout.loadX - layout.loadR - 8,
      x1: size.width - 12,
      color: _load,
      dotted: false,
      tag: '後',
      tagOnRight: true,
    );
  }

  void _drawDisplacement(Canvas canvas, Size size, MovablePulleyLayout layout) {
    final pulleyUp = sample.sPulleyUp > 0;
    _span(
      canvas,
      x: 36,
      y0: layout.axleY0,
      y1: layout.axleY,
      color: _bob,
      label: '${sample.sPulleyUp.abs().toStringAsFixed(2)} m\n${pulleyUp ? '上' : '下'}',
      labelRight: true,
    );
    final loadDown = sample.sLoadDown > 0;
    _span(
      canvas,
      x: size.width - 36,
      y0: layout.loadY0,
      y1: layout.loadY,
      color: _load,
      label: '${sample.sLoadDown.abs().toStringAsFixed(2)} m\n${loadDown ? '下' : '上'}',
      labelRight: false,
    );
  }

  void _levelLine(
    Canvas canvas, {
    required double y,
    required double x0,
    required double x1,
    required Color color,
    required bool dotted,
    required String tag,
    required bool tagOnRight,
  }) {
    final paint = Paint()
      ..color = color.withValues(alpha: dotted ? 0.85 : 1)
      ..strokeWidth = dotted ? 1.15 : 1.35;
    if (dotted) {
      _dashed(canvas, Offset(x0, y), Offset(x1, y), paint, dash: 2.2, gap: 3.2);
    } else {
      canvas.drawLine(Offset(x0, y), Offset(x1, y), paint);
    }
    final tagX = tagOnRight ? x1 - 10 : x0 + 10;
    _label(canvas, Offset(tagX, y - 9), tag, color, size: 9);
  }

  void _span(
    Canvas canvas, {
    required double x,
    required double y0,
    required double y1,
    required Color color,
    required String label,
    required bool labelRight,
  }) {
    if ((y1 - y0).abs() < 4) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    _dashed(canvas, Offset(x, y0), Offset(x, y1), paint, dash: 2.4, gap: 3.0);
    final dir = y1 >= y0 ? 1.0 : -1.0;
    final tip = Offset(x, y1);
    final head = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - 4, tip.dy - dir * 8)
      ..lineTo(tip.dx + 4, tip.dy - dir * 8)
      ..close();
    canvas.drawPath(head, Paint()..color = color);
    final midY = (y0 + y1) / 2;
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          height: 1.15,
          fontWeight: FontWeight.w800,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = labelRight ? 6.0 : -tp.width - 6;
    tp.paint(canvas, Offset(x + dx, midY - tp.height / 2));
  }

  void _dashed(
    Canvas canvas,
    Offset a,
    Offset b,
    Paint paint, {
    required double dash,
    required double gap,
  }) {
    final delta = b - a;
    final length = delta.distance;
    if (length < 1) return;
    final step = delta / length;
    var drawn = 0.0;
    while (drawn < length) {
      final start = a + step * drawn;
      final endAt = math.min(length, drawn + dash);
      canvas.drawLine(start, a + step * endAt, paint);
      drawn = endAt + gap;
    }
  }

  void _drawRig(Canvas canvas, MovablePulleyLayout layout) {
    final bar = RRect.fromRectAndRadius(
      Rect.fromLTWH(layout.movableX - layout.movableR - 18, layout.ceilingY, layout.fixed.dx + layout.fixedR + 28, 12),
      const Radius.circular(3),
    );
    canvas.drawRRect(bar, Paint()..color = const Color(0xFF78909C));

    final anchor = Offset(layout.movableX - layout.movableR, layout.ceilingY + 12);
    canvas.drawCircle(anchor, 3.2, Paint()..color = _ink);

    final leftX = layout.movableX - layout.movableR;
    final rightX = layout.movableX + layout.movableR;
    final fixedLeft = Offset(layout.fixed.dx - layout.fixedR, layout.fixed.dy);
    final fixedRight = Offset(layout.fixed.dx + layout.fixedR, layout.fixed.dy);
    final loadTop = layout.load.dy - layout.loadR;

    final string = Paint()
      ..color = _ink
      ..strokeWidth = 2.1
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(anchor.dx, anchor.dy)
      ..lineTo(leftX, layout.axleY)
      ..arcToPoint(
        Offset(rightX, layout.axleY),
        radius: Radius.circular(layout.movableR),
        clockwise: true,
      )
      ..lineTo(fixedLeft.dx, fixedLeft.dy)
      ..arcToPoint(
        fixedRight,
        radius: Radius.circular(layout.fixedR),
        clockwise: false,
      )
      ..lineTo(fixedRight.dx, loadTop);
    canvas.drawPath(path, string);

    _wheel(canvas, layout.fixed, layout.fixedR, _pulley);
    _wheel(canvas, layout.axle, layout.movableR, const Color(0xFF455A64));
    canvas.drawLine(
      layout.axle,
      layout.bob.translate(0, -layout.bobR),
      Paint()
        ..color = _ink
        ..strokeWidth = 2.1,
    );
  }

  void _wheel(Canvas canvas, Offset c, double r, Color color) {
    canvas.drawCircle(c.translate(1.2, 1.6), r, Paint()..color = Colors.black12);
    canvas.drawCircle(c, r, Paint()..color = color);
    canvas.drawCircle(
      c,
      r * 0.34,
      Paint()..color = const Color(0xFFECEFF1),
    );
  }

  void _drawMasses(Canvas canvas, MovablePulleyLayout layout) {
    _bobCircle(canvas, layout.bob, layout.bobR, _bob, 'm');
    _bobCircle(canvas, layout.load, layout.loadR, _load, 'M');

    const pxPerNewton = 1.6;
    final mg = params.m * kMovablePulleyG * pxPerNewton;
    final Mg = params.M * kMovablePulleyG * pxPerNewton;
    _arrow(
      canvas,
      layout.bob + Offset(layout.bobR + 8, 0),
      mg,
      _gravity,
      'mg',
    );
    _arrow(
      canvas,
      layout.load + Offset(-layout.loadR - 8, 0),
      Mg,
      _gravity,
      'Mg',
    );
    final tLen = sample.tension * pxPerNewton;
    _arrow(canvas, layout.load + Offset(layout.loadR + 8, 0), -tLen, _tension, 'T');
    _arrow(
      canvas,
      layout.axle + Offset(0, -layout.movableR),
      -math.min(2 * tLen, 48).toDouble(),
      _tension,
      '2T',
    );
  }

  void _drawVelocity(Canvas canvas, MovablePulleyLayout layout) {
    final endSpeed = math.sqrt(2 * params.alpha.abs() * kMovablePulleyTravel);
    final pulleyLen = (sample.vPulleyUp.abs() / math.max(endSpeed, 0.3) * 36).clamp(10.0, 42.0);
    final loadLen = (pulleyLen * 2).clamp(12.0, 64.0);
    final pulleyDown = sample.vPulleyUp < 0;
    final loadDown = sample.vLoadDown > 0;
    _arrow(
      canvas,
      layout.bob.translate(0, pulleyDown ? layout.bobR : -layout.bobR),
      pulleyDown ? pulleyLen : -pulleyLen,
      _velocity,
      'α',
    );
    _arrow(
      canvas,
      layout.load.translate(0, loadDown ? layout.loadR : -layout.loadR),
      loadDown ? loadLen : -loadLen,
      _velocity,
      'β',
    );
  }

  void _bobCircle(Canvas canvas, Offset c, double r, Color color, String label) {
    canvas.drawCircle(c.translate(1.4, 1.8), r, Paint()..color = Colors.black12);
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

  void _arrow(Canvas canvas, Offset origin, double dy, Color color, String label) {
    if (dy.abs() < 2) return;
    final tip = origin.translate(0, dy);
    final dir = dy >= 0 ? 1.0 : -1.0;
    const headLen = 8.0;
    canvas.drawLine(
      origin,
      tip.translate(0, -dir * headLen * 0.65),
      Paint()
        ..color = color
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx - 4.2, tip.dy - dir * headLen)
        ..lineTo(tip.dx + 4.2, tip.dy - dir * headLen)
        ..close(),
      Paint()..color = color,
    );
    final labelAt = dy >= 0 ? tip + const Offset(8, -2) : tip + const Offset(8, -10);
    _label(canvas, labelAt, label, color, size: 10);
  }

  void _label(Canvas canvas, Offset o, String text, Color color, {double size = 11}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(o.dx - tp.width / 2, o.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _MovablePulleyPainter oldDelegate) {
    return oldDelegate.sample.t != sample.t ||
        oldDelegate.sample.sPulleyUp != sample.sPulleyUp ||
        oldDelegate.sample.stopped != sample.stopped ||
        oldDelegate.params.m != params.m ||
        oldDelegate.params.M != params.M;
  }
}
