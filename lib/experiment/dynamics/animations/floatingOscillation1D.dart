import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// 下向き正。水面を 0、物体の底の深さを y。物体の密度は固定。
const double kFloatG = 9.8;
const double kFloatObjectH = 0.20;
const double kFloatRhoObject = 500.0;
const double kFloatTank = 0.80;
const double kFloatMinRho = 400.0;
const double kFloatMaxRho = 2000.0;
const double kFloatDefaultRho = 1000.0;
const double kFloatMinY0 = 0.02;
const double kFloatMaxY0 = 0.75;
const double kFloatDefaultY0 = 0.14;

/// 物体密度 / 液体密度。1 未満で浮く。
double floatSigma(double rhoLiquid) => kFloatRhoObject / rhoLiquid;

/// つりあいの喫水。液体より重いときは物体の高さより深くなる。
double floatDraft(double rhoLiquid) => floatSigma(rhoLiquid) * kFloatObjectH;

double floatOmega(double rhoLiquid) {
  final h = floatDraft(rhoLiquid);
  return math.sqrt(kFloatG / h);
}

/// 部分没水の単振動が続くときの周期。喫水 h だけで決まる。
double floatPeriod(double rhoLiquid) => 2 * math.pi / floatOmega(rhoLiquid);

enum FloatRegime { harmonic, rises, jumps, sinks, neutral }

class FloatParams {
  const FloatParams({required this.rho, required this.y0});

  final double rho;
  final double y0;

  double get sigma => floatSigma(rho);
  double get draft => floatDraft(rho);

  factory FloatParams.fromMap(Map<String, double> params) {
    return FloatParams(
      rho: params['rho']!.clamp(kFloatMinRho, kFloatMaxRho).toDouble(),
      y0: params['y0']!.clamp(kFloatMinY0, kFloatMaxY0).toDouble(),
    );
  }
}

class FloatSample {
  const FloatSample({
    required this.t,
    required this.y,
    required this.v,
    required this.a,
  });

  final double t;
  final double y;
  final double v;
  final double a;

  bool get inAir => y < -1e-8;
  bool get fullySubmerged => y > kFloatObjectH + 1e-8;
  bool get onFloor => y >= kFloatTank - 1e-6 && v.abs() < 1e-6;
}

/// 底の深さ y での加速度。下向き正。
double floatAccel(double y, double rhoLiquid) {
  final sigma = floatSigma(rhoLiquid);
  final h = sigma * kFloatObjectH;
  if (y <= 0) return kFloatG;
  if (y >= kFloatObjectH) return kFloatG * (1 - 1 / sigma);
  return -(kFloatG / h) * (y - h);
}

FloatRegime floatRegime(FloatParams params) {
  final sigma = params.sigma;
  if ((sigma - 1).abs() < 1e-9) return FloatRegime.neutral;
  if (sigma > 1) return FloatRegime.sinks;
  final h = params.draft;
  final room = math.min(h, kFloatObjectH - h);
  final amp = (params.y0 - h).abs();
  if (params.y0 > 1e-9 &&
      params.y0 < kFloatObjectH - 1e-9 &&
      amp <= room + 1e-9) {
    return FloatRegime.harmonic;
  }
  var minY = params.y0;
  const tend = 6.0;
  for (var i = 0; i <= 240; i++) {
    final y = floatAt(params, tend * i / 240).y;
    if (y < minY) minY = y;
  }
  if (minY < -1e-4) return FloatRegime.jumps;
  return FloatRegime.rises;
}

String floatCaption(FloatRegime regime, FloatParams params) {
  final h = params.draft;
  switch (regime) {
    case FloatRegime.harmonic:
      return '一部だけ水中。復元力は変位に比例し、単振動です。\n'
          '周期は喫水 h = ${h.toStringAsFixed(3)} m だけで決まり、液体の密度は式から消えます。\n'
          '水面から出ず、全部も沈みません。';
    case FloatRegime.rises:
      return '全部沈んだ状態から浮かび上がります。\n'
          '全没のあいだ加速度は一定で、上面が水面に出てから復元力のある領域に入ります。\n'
          'この初期深さでは、水面から飛び出すまでのエネルギーはありません。';
    case FloatRegime.jumps:
      return '水面に着いたとき上向きの速度が残るので、空中へ出ます。\n'
          '空中では重力だけ。落ちて再び水に入ります。\n'
          '物体が液体の半分より軽いと、ちょうど全没から離しただけでも飛びます。';
    case FloatRegime.sinks:
      return '物体のほうが重いので、つりあいの喫水は物体の高さより深く、実在しません。\n'
          '全没のあと下向きの加速度が残り、水底で止まります。';
    case FloatRegime.neutral:
      return '密度が等しいと、全部沈んでいるあいだは合力がゼロです。\n'
          'ちょうど全没で静かに置くと、止まったままです。\n'
          '一部だけ水中から離すと、全没に入った時点で下向きの速度が残るので、水底まで進みます。';
  }
}

FloatSample floatAt(FloatParams params, double t) {
  final time = math.max(0.0, t);
  var y = params.y0;
  var v = 0.0;
  var elapsed = 0.0;
  for (var n = 0; n < 48 && elapsed < time - 1e-12; n++) {
    final step = _advance(y, v, params.rho, time - elapsed);
    if (step.dt <= 1e-12) break;
    y = step.y;
    v = step.v;
    elapsed += step.dt;
  }
  return FloatSample(
    t: time,
    y: y,
    v: v,
    a: floatAccel(y, params.rho),
  );
}

class _Step {
  const _Step(this.y, this.v, this.dt);
  final double y;
  final double v;
  final double dt;
}

_Step _advance(double y, double v, double rho, double limit) {
  final sigma = floatSigma(rho);
  final aFull = kFloatG * (1 - 1 / sigma);
  if (y >= kFloatTank - 1e-8 && v >= -1e-8 && aFull >= -1e-10) {
    return _Step(kFloatTank, 0, limit);
  }
  final atSurface = y.abs() <= 1e-8;
  final atFull = (y - kFloatObjectH).abs() <= 1e-8;
  final leavingUp = v < -1e-8;
  final goingDeeper = v > 1e-8 || (v.abs() <= 1e-8 && aFull > 1e-8);
  if (y < -1e-8 || (atSurface && leavingUp)) {
    return _air(y, v, limit);
  }
  if (y > kFloatObjectH + 1e-8 || (atFull && goingDeeper)) {
    return _coast(y, v, aFull, limit, up: kFloatObjectH, down: kFloatTank);
  }
  return _partial(y, v, floatDraft(rho), limit);
}

_Step _air(double y, double v, double limit) {
  final hit = _quadTime(0.5 * kFloatG, v, y, limit);
  final dt = hit ?? limit;
  final nextY = y + v * dt + 0.5 * kFloatG * dt * dt;
  final nextV = v + kFloatG * dt;
  if (hit != null) return _Step(0, nextV, dt);
  return _Step(nextY, nextV, dt);
}

_Step _coast(
  double y,
  double v,
  double a,
  double limit, {
  required double up,
  required double down,
}) {
  double? hit;
  double? bound;
  final upT = _quadTime(0.5 * a, v, y - up, limit);
  final downT = _quadTime(0.5 * a, v, y - down, limit);
  if (upT != null && (v < 0 || a < 0)) {
    hit = upT;
    bound = up;
  }
  if (downT != null && (hit == null || downT < hit)) {
    hit = downT;
    bound = down;
  }
  final dt = hit ?? limit;
  final nextV = v + a * dt;
  if (bound != null) {
    final stopped = (bound - down).abs() < 1e-12 && nextV >= -1e-9;
    return _Step(bound, stopped ? 0 : nextV, dt);
  }
  return _Step(y + v * dt + 0.5 * a * dt * dt, nextV, dt);
}

_Step _partial(double y, double v, double h, double limit) {
  final omega = math.sqrt(kFloatG / h);
  final t0 = _shmHit(y, v, h, omega, 0, limit);
  final tH = _shmHit(y, v, h, omega, kFloatObjectH, limit);
  double? hit;
  double? bound;
  if (t0 != null) {
    hit = t0;
    bound = 0;
  }
  if (tH != null && (hit == null || tH < hit)) {
    hit = tH;
    bound = kFloatObjectH;
  }
  final dt = hit ?? limit;
  final next = _shmState(y, v, h, omega, dt);
  if (bound != null) return _Step(bound, next.v, dt);
  return _Step(next.y, next.v, dt);
}

class _Phase {
  const _Phase(this.y, this.v);
  final double y;
  final double v;
}

_Phase _shmState(double y0, double v0, double h, double omega, double t) {
  final a = y0 - h;
  final b = v0 / omega;
  final c = math.cos(omega * t);
  final s = math.sin(omega * t);
  return _Phase(h + a * c + b * s, -a * omega * s + v0 * c);
}

/// A cos θ + B sin θ = C の最小の θ/ω > 0。
double? _shmHit(
  double y0,
  double v0,
  double h,
  double omega,
  double target,
  double limit,
) {
  final ampCos = y0 - h;
  final ampSin = v0 / omega;
  final level = target - h;
  final radius = math.sqrt(ampCos * ampCos + ampSin * ampSin);
  if (radius < 1e-12 || level.abs() > radius + 1e-8) return null;
  final alpha = math.atan2(ampSin, ampCos);
  final delta = math.acos((level / radius).clamp(-1.0, 1.0));
  double? best;
  for (var k = 0; k <= 3; k++) {
    for (final sign in const [1.0, -1.0]) {
      final theta = alpha + sign * delta + 2 * math.pi * k;
      if (theta <= 1e-8) continue;
      final time = theta / omega;
      if (time <= limit + 1e-9 && (best == null || time < best)) {
        best = time;
      }
    }
  }
  if (best == null || best > limit) return null;
  return best;
}

/// 0.5 を a に入れた二次式 a t^2 + b t + c = 0 の、区間 (0, limit] の最小根。
double? _quadTime(double a, double b, double c, double limit) {
  if (c.abs() < 1e-12 && b.abs() < 1e-12) return null;
  if (a.abs() < 1e-14) {
    if (b.abs() < 1e-14) return null;
    final t = -c / b;
    if (t > 1e-10 && t <= limit + 1e-9) return t.clamp(0.0, limit);
    return null;
  }
  final disc = b * b - 4 * a * c;
  if (disc < -1e-12) return null;
  final root = math.sqrt(math.max(0.0, disc));
  double? best;
  for (final t in [(-b - root) / (2 * a), (-b + root) / (2 * a)]) {
    if (t > 1e-10 && t <= limit + 1e-9 && (best == null || t < best)) {
      best = t;
    }
  }
  if (best == null) return null;
  return best.clamp(0.0, limit);
}

final floatingOscillation1D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '浮体の単振動',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>水平断面が一定の物体が液体に浮くとき、つりあいの喫水を $h$ とします。下向きを正、つりあいからの変位を $x$ とすると、水面から出ず全部も沈まないあいだは</p>
  <p>$$\displaystyle x''=-\frac{g}{h}x,\quad T=2\pi\sqrt{\frac{h}{g}}$$</p>
  <p>重さと浮力のつりあい $m=\rho S h$ から、液体の密度 $\rho$ と断面積 $S$ は周期の式から消えます。物体を固定して $\rho$ を変えると $h$ が変わり、周期は $\sqrt{h}$ に従います。</p>
  <p>全部沈むと浮力は一定、空中では重力だけです。密度比と初期の沈め深さで、単振動・浮上・飛び出し・沈降に分かれます。</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: FloatingOscillation1DSimulation(),
      height: 980,
    ),
  ],
);

class FloatingOscillation1DSimulation extends PhysicsSimulation {
  FloatingOscillation1DSimulation()
      : super(
          title: '浮体の単振動',
          formula: const FormulaDisplay(
            r'\displaystyle T=2\pi\sqrt{\frac{h}{g}}',
          ),
          aspectRatio: 4 / 5,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> simTime = ValueNotifier(0.0);

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    simTime.value += dt * _playback;
  });

  ValueNotifier<bool> get running => _loop.running;

  Map<String, double> _latestParams = {};

  static const double _playback = 0.45;

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'rho': kFloatDefaultRho,
        'y0': kFloatDefaultY0,
      };

  FloatParams get _params {
    if (_latestParams.isEmpty) {
      return FloatParams.fromMap(initialParameters);
    }
    return FloatParams.fromMap(_latestParams);
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
    simTime.value = 0.0;
  }

  @override
  Widget? buildFormulaOverlay(Map<String, double> parameters) {
    _rememberParams(parameters);
    final regime = floatRegime(_params);
    final tex = regime == FloatRegime.harmonic || _params.sigma < 1
        ? r'\displaystyle T=2\pi\sqrt{\frac{h}{g}}'
        : r'\displaystyle a=g\left(1-\frac{\rho}{\rho_0}\right)';
    return FormulaDisplay(tex);
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
        final regime = floatRegime(_params);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              floatCaption(regime, _params),
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
    final regime = floatRegime(p);
    final periodText = regime == FloatRegime.harmonic
        ? '周期 ${floatPeriod(p.rho).toStringAsFixed(2)} s'
        : '単振動の範囲の外';
    return [
      const Text(
        '物体の密度 500 kg/m³、高さ 0.20 m。静かに離す。',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _FloatSlider(
        label: 'ρ',
        value: p.rho,
        min: kFloatMinRho,
        max: kFloatMaxRho,
        onChanged: (v) => updateParam('rho', v),
        semanticLabel: '液体の密度',
        digits: 0,
      ),
      _FloatSlider(
        label: 'y0',
        value: p.y0,
        min: kFloatMinY0,
        max: kFloatMaxY0,
        onChanged: (v) => updateParam('y0', v),
        semanticLabel: '初期の底の深さ',
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '喫水 ${p.draft.toStringAsFixed(3)} m    $periodText',
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
        final p = FloatParams.fromMap(parameters);
        final sample = floatAt(p, simTime.value);
        return CustomPaint(
          size: Size.infinite,
          painter: _FloatPainter(params: p, sample: sample),
        );
      },
    );
  }
}

class _FloatSlider extends StatelessWidget {
  const _FloatSlider({
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
          width: 52,
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

class _FloatPainter extends CustomPainter {
  _FloatPainter({required this.params, required this.sample});

  final FloatParams params;
  final FloatSample sample;

  @override
  void paint(Canvas canvas, Size size) {
    final span = kFloatTank + 0.28;
    final top = size.height * 0.08;
    final scale = size.height * 0.84 / span;
    double py(double depth) => top + (depth + 0.22) * scale;

    final surface = py(0);
    final floor = py(kFloatTank);
    final water = Paint()..color = const Color(0xFFB3D4E8);
    canvas.drawRect(Rect.fromLTRB(0, surface, size.width, size.height), water);
    canvas.drawLine(
      Offset(0, floor),
      Offset(size.width, floor),
      Paint()
        ..color = const Color(0xFF5D4037)
        ..strokeWidth = 3,
    );

    final eq = params.draft.clamp(0.0, kFloatObjectH);
    final guide = Paint()
      ..color = const Color(0xFF607D8B)
      ..strokeWidth = 1.5;
    _drawDashedLine(canvas, py(eq), size.width, guide);

    final bodyW = size.width * 0.34;
    final left = (size.width - bodyW) / 2;
    final bodyTop = py(sample.y - kFloatObjectH);
    final bodyBottom = py(sample.y);
    final body = RRect.fromRectAndRadius(
      Rect.fromLTRB(left, bodyTop, left + bodyW, bodyBottom),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      body,
      Paint()..color = const Color(0xFF8D6E63),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..color = const Color(0xFF4E342E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final label = TextPainter(
      text: const TextSpan(
        text: '水面',
        style: TextStyle(color: Color(0xFF01579B), fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas, Offset(8, surface - 16));
  }

  @override
  bool shouldRepaint(covariant _FloatPainter oldDelegate) {
    return oldDelegate.sample.y != sample.y ||
        oldDelegate.params.rho != params.rho ||
        oldDelegate.params.y0 != params.y0;
  }
}

void _drawDashedLine(Canvas canvas, double y, double width, Paint paint) {
  const dash = 7.0;
  const gap = 5.0;
  var x = 0.0;
  while (x < width) {
    final next = math.min(x + dash, width);
    canvas.drawLine(Offset(x, y), Offset(next, y), paint);
    x += dash + gap;
  }
}
