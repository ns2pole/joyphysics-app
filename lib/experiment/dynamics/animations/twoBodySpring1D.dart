import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/model.dart';

final twoBodySpring1D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '2体問題(ばね・1次元)',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>外力のない2質点をばねでつなぐと、重心は等速直線運動、相対運動は換算質量の単振動になる。</p>
  <p>$$\mu = \dfrac{m_1 m_2}{m_1+m_2}$$</p>
  <p>$$\mu\,\ddot R = -k(R-\ell)$$</p>
  <p>$$\omega=\sqrt{\dfrac{k}{\mu}}$$</p>
  <p>相対座標 $R=x_2-x_1$ の厳密解は</p>
  <p>$$\begin{aligned}
  R(t)&=\ell+(R(0)-\ell)\cos\omega t\\
  &\quad+\dfrac{\dot R(0)}{\omega}\sin\omega t
  \end{aligned}$$</p>
  <p>各質点の位置は、重心 $R_G(t)=R_G(0)+V_G t$ から</p>
  <p>$$x_1(t)=R_G(t)-\dfrac{m_2}{m_1+m_2}R(t)$$</p>
  <p>$$x_2(t)=R_G(t)+\dfrac{m_1}{m_1+m_2}R(t)$$</p>
  <p>質点が交差しない条件は、振幅 $A=\sqrt{(R(0)-\ell)^2+\bigl(\dfrac{\dot R(0)}{\omega}\bigr)^2}$ に対して $A<\ell$（すなわち $R_{\min}=\ell-A>0$）である。</p>
  <div class="common-box">使い方</div>
  <p>初期配置は原点対称の自然長 $x_1=-\dfrac{\ell}{2},\,x_2=\dfrac{\ell}{2}$ です。$\ell$ を変えるとこの配置に戻します。</p>
  <p>「遠ざけて配置」「近づけて配置」「片方のみ初期速度あり」で典型的な初期条件に切り替えられます。停止中に初期条件を動かし Start で運動を開始します。交差する初期条件は厳密解から除外しています。リセットで $t=0$ の配置に戻ります。全パラメータ初期化ですべての初期条件を最初の値に戻します。</p>
  """,
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: TwoBodySpring1DSimulation(),
      height: 820,
    ),
  ],
);

class TwoBodySpring1DIcs {
  const TwoBodySpring1DIcs({
    required this.x1,
    required this.x2,
    required this.v1,
    required this.v2,
    required this.m1,
    required this.m2,
    required this.k,
    required this.ell,
  });

  final double x1;
  final double x2;
  final double v1;
  final double v2;
  final double m1;
  final double m2;
  final double k;
  final double ell;

  factory TwoBodySpring1DIcs.fromParams(Map<String, double> params) {
    return TwoBodySpring1DIcs(
      x1: params['x1']!,
      x2: params['x2']!,
      v1: params['v1']!,
      v2: params['v2']!,
      m1: params['m1']!,
      m2: params['m2']!,
      k: params['k']!,
      ell: params['ell']!,
    );
  }

  double get massSum => m1 + m2;
  double get mu => m1 * m2 / massSum;
  double get omega => math.sqrt(k / mu);
  double get rg0 => (m1 * x1 + m2 * x2) / massSum;
  double get vg => (m1 * v1 + m2 * v2) / massSum;
  double get r0 => x2 - x1;
  double get rDot0 => v2 - v1;
  double get xi0 => r0 - ell;
  double get eta0 => rDot0 / omega;
  double get amplitude => math.sqrt(xi0 * xi0 + eta0 * eta0);
  double get rMin => ell - amplitude;
}

/// $R(t)$ が 0 以下になると質点が交差する。厳密解の振幅 $A<\ell$ を要求する。
const double kTwoBodySpringCrossingEps = 1e-3;

double twoBodySpringAllowedAmplitude(double ell) =>
    math.max(0.0, ell - kTwoBodySpringCrossingEps);

bool twoBodySpringIcsAvoidCrossing(TwoBodySpring1DIcs ics) => ics.rMin > 0;

enum TwoBodySpring1DPreset { far, close, oneVelocity }

/// 自然長に対する遠方配置・近接配置の間隔比。交差しないよう $0<R<2\ell$ に収める。
const double kTwoBodySpringFarSeparationFactor = 1.5;
const double kTwoBodySpringCloseSeparationFactor = 0.5;
const double kTwoBodySpringOneVelocityV1 = 2.0;

Map<String, double> applyTwoBodySpring1DPreset(
  Map<String, double> current,
  TwoBodySpring1DPreset preset,
) {
  final p = Map<String, double>.from(current);
  final ell = p['ell']!.clamp(0.5, 6.0).toDouble();
  p['ell'] = ell;
  switch (preset) {
    case TwoBodySpring1DPreset.far:
      final r = kTwoBodySpringFarSeparationFactor * ell;
      p['x1'] = (-r / 2).clamp(-6.0, 6.0).toDouble();
      p['x2'] = (r / 2).clamp(-6.0, 6.0).toDouble();
      p['v1'] = 0.0;
      p['v2'] = 0.0;
      break;
    case TwoBodySpring1DPreset.close:
      final r = kTwoBodySpringCloseSeparationFactor * ell;
      p['x1'] = (-r / 2).clamp(-6.0, 6.0).toDouble();
      p['x2'] = (r / 2).clamp(-6.0, 6.0).toDouble();
      p['v1'] = 0.0;
      p['v2'] = 0.0;
      break;
    case TwoBodySpring1DPreset.oneVelocity:
      p['x1'] = (-ell / 2).clamp(-6.0, 6.0).toDouble();
      p['x2'] = (ell / 2).clamp(-6.0, 6.0).toDouble();
      p['v1'] = kTwoBodySpringOneVelocityV1;
      p['v2'] = 0.0;
      break;
  }
  return _clampRelativeVelocityToNoCrossing(
    _clampSeparationToNoCrossing(p, moved: 'x2'),
  );
}

Map<String, double> applyTwoBodySpring1DParam(
  Map<String, double> current,
  String key,
  double value,
) {
  final p = Map<String, double>.from(current);
  if (key == 'ell') {
    final ell = value.clamp(0.5, 6.0).toDouble();
    p['ell'] = ell;
    p['x1'] = -ell / 2;
    p['x2'] = ell / 2;
    return _clampRelativeVelocityToNoCrossing(p);
  }
  if (key == 'x1' || key == 'x2') {
    p[key] = value.clamp(-6.0, 6.0).toDouble();
    return _clampSeparationToNoCrossing(p, moved: key);
  }
  if (key == 'v1' || key == 'v2') {
    p[key] = value.clamp(-3.0, 3.0).toDouble();
    return _clampMovedVelocityToNoCrossing(p, moved: key);
  }
  if (key == 'm1' || key == 'm2') {
    p[key] = value.clamp(0.4, 5.0).toDouble();
    return _clampRelativeVelocityToNoCrossing(p);
  }
  if (key == 'k') {
    p['k'] = value.clamp(0.5, 12.0).toDouble();
    return _clampRelativeVelocityToNoCrossing(p);
  }
  p[key] = value;
  return p;
}

Map<String, double> _clampSeparationToNoCrossing(
  Map<String, double> p, {
  required String moved,
}) {
  final ics = TwoBodySpring1DIcs.fromParams(p);
  final disk = twoBodySpringAllowedAmplitude(ics.ell);
  final room = disk * disk - ics.eta0 * ics.eta0;
  final xiMax = room <= 0 ? 0.0 : math.sqrt(room);
  final xi = ics.xi0.clamp(-xiMax, xiMax).toDouble();
  final r0 = ics.ell + xi;
  if (moved == 'x1') {
    p['x1'] = (p['x2']! - r0).clamp(-6.0, 6.0).toDouble();
  } else {
    p['x2'] = (p['x1']! + r0).clamp(-6.0, 6.0).toDouble();
  }
  return p;
}

Map<String, double> _clampMovedVelocityToNoCrossing(
  Map<String, double> p, {
  required String moved,
}) {
  final ics = TwoBodySpring1DIcs.fromParams(p);
  final disk = twoBodySpringAllowedAmplitude(ics.ell);
  final room = disk * disk - ics.xi0 * ics.xi0;
  final etaMax = room <= 0 ? 0.0 : math.sqrt(room);
  final eta = ics.eta0.clamp(-etaMax, etaMax).toDouble();
  final rDot = eta * ics.omega;
  if (moved == 'v1') {
    p['v1'] = (p['v2']! - rDot).clamp(-3.0, 3.0).toDouble();
  } else {
    p['v2'] = (p['v1']! + rDot).clamp(-3.0, 3.0).toDouble();
  }
  return p;
}

Map<String, double> _clampRelativeVelocityToNoCrossing(Map<String, double> p) {
  final ics = TwoBodySpring1DIcs.fromParams(p);
  final disk = twoBodySpringAllowedAmplitude(ics.ell);
  final room = disk * disk - ics.xi0 * ics.xi0;
  final etaMax = room <= 0 ? 0.0 : math.sqrt(room);
  if (ics.eta0.abs() <= etaMax) return p;
  final rDot = etaMax * ics.eta0.sign * ics.omega;
  final m = ics.massSum;
  p['v1'] = (ics.vg - (ics.m2 / m) * rDot).clamp(-3.0, 3.0).toDouble();
  p['v2'] = (ics.vg + (ics.m1 / m) * rDot).clamp(-3.0, 3.0).toDouble();
  return p;
}

class TwoBodySpring1DSnapshot {
  const TwoBodySpring1DSnapshot({
    required this.x1,
    required this.x2,
    required this.v1,
    required this.v2,
    required this.rg,
    required this.r,
    required this.rDot,
  });

  final double x1;
  final double x2;
  final double v1;
  final double v2;
  final double rg;
  final double r;
  final double rDot;
}

TwoBodySpring1DSnapshot evolveTwoBodySpring1D(
  TwoBodySpring1DIcs ics,
  double t,
) {
  final omega = ics.omega;
  final xi0 = ics.r0 - ics.ell;
  final c = math.cos(omega * t);
  final s = math.sin(omega * t);
  final xi = xi0 * c + (ics.rDot0 / omega) * s;
  final rDot = -xi0 * omega * s + ics.rDot0 * c;
  final r = ics.ell + xi;
  final rg = ics.rg0 + ics.vg * t;
  final m = ics.massSum;
  return TwoBodySpring1DSnapshot(
    x1: rg - (ics.m2 / m) * r,
    x2: rg + (ics.m1 / m) * r,
    v1: ics.vg - (ics.m2 / m) * rDot,
    v2: ics.vg + (ics.m1 / m) * rDot,
    rg: rg,
    r: r,
    rDot: rDot,
  );
}

class TwoBodySpring1DSimulation extends PhysicsSimulation {
  TwoBodySpring1DSimulation()
      : super(
          title: '2体問題(ばね・1次元)',
          formula: const FormulaDisplay(
            r'\mu\ddot{R}=-k(R-\ell),\quad R=x_2-x_1',
          ),
          aspectRatio: 16 / 9,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<bool> running = ValueNotifier(false);
  final ValueNotifier<double> simTime = ValueNotifier(0.0);

  TwoBodySpring1DIcs? _frozen;
  Map<String, double> _latestParams = {};
  void Function(String key, double value)? _updateParam;
  bool _tickScheduled = false;
  DateTime? _lastTickAt;
  int _dragIndex = -1;

  static const double worldXMin = -8.0;
  static const double worldXMax = 8.0;

  @override
  Map<String, double> get initialParameters => {
        'x1': -2.0,
        'x2': 2.0,
        'v1': 0.0,
        'v2': 0.0,
        'm1': 1.0,
        'm2': 1.0,
        'k': 4.0,
        'ell': 4.0,
      };

  TwoBodySpring1DIcs get _liveIcs {
    if (_latestParams.isEmpty) {
      return TwoBodySpring1DIcs.fromParams(initialParameters);
    }
    return TwoBodySpring1DIcs.fromParams(_latestParams);
  }

  TwoBodySpring1DIcs get _activeIcs =>
      (running.value && _frozen != null) ? _frozen! : _liveIcs;

  void _rememberParams(Map<String, double> params) {
    _latestParams = Map<String, double>.from(params);
  }

  void start() {
    if (running.value) return;
    final params = _latestParams.isEmpty ? initialParameters : _latestParams;
    _frozen = TwoBodySpring1DIcs.fromParams(
      _clampRelativeVelocityToNoCrossing(Map<String, double>.from(params)),
    );
    simTime.value = 0.0;
    _lastTickAt = null;
    running.value = true;
    _scheduleTick();
  }

  void _applyParam(String key, double value) {
    if (_updateParam == null) return;
    final current = _latestParams.isEmpty
        ? Map<String, double>.from(initialParameters)
        : Map<String, double>.from(_latestParams);
    _pushParams(applyTwoBodySpring1DParam(current, key, value));
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

  void applyPreset(TwoBodySpring1DPreset preset) {
    resetMotion();
    final current = Map<String, double>.from(
      _latestParams.isEmpty ? initialParameters : _latestParams,
    );
    _pushParams(applyTwoBodySpring1DPreset(current, preset));
  }

  void resetMotion() {
    running.value = false;
    simTime.value = 0.0;
    _frozen = null;
    _lastTickAt = null;
  }

  void resetAllParameters() {
    resetMotion();
    _pushParams(initialParameters);
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
      simTime.value += dt;
      if (running.value) _scheduleTick();
    });
  }

  @override
  Widget? buildFormulaOverlay(Map<String, double> parameters) {
    _rememberParams(parameters);
    final ics = _liveIcs;
    return Column(
      children: [
        const FormulaDisplay(r'\mu\ddot{R}=-k(R-\ell),\quad \omega=\sqrt{\frac{k}{\mu}}'),
        const SizedBox(height: 4),
        Text(
          'ω = ${ics.omega.toStringAsFixed(2)}    '
          'T = ${(2 * math.pi / ics.omega).toStringAsFixed(2)}',
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
    return ValueListenableBuilder<bool>(
      valueListenable: running,
      builder: (context, isRunning, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                OutlinedButton(
                  onPressed: isRunning
                      ? null
                      : () => applyPreset(TwoBodySpring1DPreset.far),
                  child: const Text('遠ざけて配置'),
                ),
                OutlinedButton(
                  onPressed: isRunning
                      ? null
                      : () => applyPreset(TwoBodySpring1DPreset.close),
                  child: const Text('近づけて配置'),
                ),
                OutlinedButton(
                  onPressed: isRunning
                      ? null
                      : () => applyPreset(TwoBodySpring1DPreset.oneVelocity),
                  child: const Text('片方のみ初期速度あり'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: resetAllParameters,
              icon: const Icon(Icons.restart_alt),
              label: const Text('全パラメータ初期化'),
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
    _updateParam = updateParam;
    return [
      ValueListenableBuilder<bool>(
        valueListenable: running,
        builder: (context, isRunning, _) {
          void Function(String, double)? onChange =
              isRunning ? null : _applyParam;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '初期条件',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              _IcSlider(
                label: 'x1',
                value: parameters['x1']!,
                min: -6.0,
                max: 6.0,
                onChanged: onChange == null ? null : (v) => onChange('x1', v),
                semanticLabel: 'x1',
              ),
              _IcSlider(
                label: 'x2',
                value: parameters['x2']!,
                min: -6.0,
                max: 6.0,
                onChanged: onChange == null ? null : (v) => onChange('x2', v),
                semanticLabel: 'x2',
              ),
              _IcSlider(
                label: 'v1',
                value: parameters['v1']!,
                min: -3.0,
                max: 3.0,
                onChanged: onChange == null ? null : (v) => onChange('v1', v),
                semanticLabel: 'v1',
              ),
              _IcSlider(
                label: 'v2',
                value: parameters['v2']!,
                min: -3.0,
                max: 3.0,
                onChanged: onChange == null ? null : (v) => onChange('v2', v),
                semanticLabel: 'v2',
              ),
              const Divider(),
              const Text(
                '質量・ばね',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              _IcSlider(
                label: 'm1',
                value: parameters['m1']!,
                min: 0.4,
                max: 5.0,
                onChanged: onChange == null ? null : (v) => onChange('m1', v),
                semanticLabel: 'm1',
              ),
              _IcSlider(
                label: 'm2',
                value: parameters['m2']!,
                min: 0.4,
                max: 5.0,
                onChanged: onChange == null ? null : (v) => onChange('m2', v),
                semanticLabel: 'm2',
              ),
              _IcSlider(
                label: 'k',
                value: parameters['k']!,
                min: 0.5,
                max: 12.0,
                onChanged: onChange == null ? null : (v) => onChange('k', v),
                semanticLabel: 'k',
              ),
              _IcSlider(
                label: 'ℓ',
                value: parameters['ell']!,
                min: 0.5,
                max: 6.0,
                onChanged: onChange == null ? null : (v) => onChange('ell', v),
                semanticLabel: 'ell',
              ),
              if (isRunning)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    '運動中は初期条件をロックしています。リセット後に変更できます。',
                    style: TextStyle(fontSize: 11, color: Color(0xFF546E7A)),
                  ),
                ),
            ],
          );
        },
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
        final ics = _activeIcs;
        final t = running.value ? simTime.value : 0.0;
        final snap = evolveTwoBodySpring1D(ics, t);
        return LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onPanStart: running.value
                  ? null
                  : (details) => _onPanStart(details, constraints.biggest, snap),
              onPanUpdate: running.value
                  ? null
                  : (details) => _onPanUpdate(details, constraints.biggest),
              onPanEnd: (_) => _dragIndex = -1,
              child: CustomPaint(
                size: Size.infinite,
                painter: _TwoBodySpring1DPainter(
                  snapshot: snap,
                  ics: ics,
                  time: t,
                  running: running.value,
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _onPanStart(
    DragStartDetails details,
    Size size,
    TwoBodySpring1DSnapshot snap,
  ) {
    final p1 = _toScreen(snap.x1, size);
    final p2 = _toScreen(snap.x2, size);
    final local = details.localPosition;
    final r1 = _massRadius(snap, 1, size);
    final r2 = _massRadius(snap, 2, size);
    final d1 = (local - p1).distance;
    final d2 = (local - p2).distance;
    if (d1 <= r1 + 16 && d1 <= d2) {
      _dragIndex = 1;
    } else if (d2 <= r2 + 16) {
      _dragIndex = 2;
    } else {
      _dragIndex = -1;
    }
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (_dragIndex < 0 || _updateParam == null) return;
    final x = _toWorldX(details.localPosition.dx, size)
        .clamp(-6.0, 6.0)
        .toDouble();
    _applyParam(_dragIndex == 1 ? 'x1' : 'x2', x);
  }

  double _massRadius(TwoBodySpring1DSnapshot snap, int i, Size size) {
    final m = i == 1 ? _activeIcs.m1 : _activeIcs.m2;
    final pxPerUnit = size.width / (worldXMax - worldXMin);
    return (0.28 * math.sqrt(m) * pxPerUnit).clamp(12.0, 34.0);
  }

  Offset _toScreen(double x, Size size) {
    final railY = size.height * 0.58;
    final sx = (x - worldXMin) / (worldXMax - worldXMin) * size.width;
    return Offset(sx, railY);
  }

  double _toWorldX(double screenX, Size size) {
    return worldXMin + screenX / size.width * (worldXMax - worldXMin);
  }
}

class _IcSlider extends StatelessWidget {
  const _IcSlider({
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
  final ValueChanged<double>? onChanged;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 36,
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

class _TwoBodySpring1DPainter extends CustomPainter {
  _TwoBodySpring1DPainter({
    required this.snapshot,
    required this.ics,
    required this.time,
    required this.running,
  });

  final TwoBodySpring1DSnapshot snapshot;
  final TwoBodySpring1DIcs ics;
  final double time;
  final bool running;

  static const _mass1 = Color(0xFF1E88E5);
  static const _mass2 = Color(0xFFFB8C00);
  static const _cm = Color(0xFFE53935);

  @override
  void paint(Canvas canvas, Size size) {
    final railY = size.height * 0.58;
    Offset toScreen(double x) {
      final sx = (x - TwoBodySpring1DSimulation.worldXMin) /
          (TwoBodySpring1DSimulation.worldXMax -
              TwoBodySpring1DSimulation.worldXMin) *
          size.width;
      return Offset(sx, railY);
    }

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF7FAFC),
    );

    _drawNumberLine(canvas, size, railY, toScreen);

    final p1 = toScreen(snapshot.x1);
    final p2 = toScreen(snapshot.x2);
    final pg = toScreen(snapshot.rg);
    final r1 = _radiusFor(ics.m1, size);
    final r2 = _radiusFor(ics.m2, size);

    _drawSpring(canvas, p1, p2, r1, r2);
    _drawMass(canvas, p1, r1, _mass1, 'm1');
    _drawMass(canvas, p2, r2, _mass2, 'm2');
    _drawCm(canvas, pg, railY);
    _drawVelocityArrow(canvas, p1, snapshot.v1, _mass1);
    _drawVelocityArrow(canvas, p2, snapshot.v2, _mass2);
    _drawHud(canvas, size);
  }

  double _radiusFor(double m, Size size) {
    final pxPerUnit = size.width /
        (TwoBodySpring1DSimulation.worldXMax -
            TwoBodySpring1DSimulation.worldXMin);
    return (0.28 * math.sqrt(m) * pxPerUnit).clamp(12.0, 34.0);
  }

  void _drawNumberLine(
    Canvas canvas,
    Size size,
    double railY,
    Offset Function(double) toScreen,
  ) {
    final axis = Paint()
      ..color = const Color(0xFF90A4AE)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(8, railY), Offset(size.width - 8, railY), axis);

    final textStyle = TextStyle(
      color: const Color(0xFF607D8B),
      fontSize: 10,
      fontFamily: 'Courier',
    );
    for (int x = -6; x <= 6; x += 2) {
      final p = toScreen(x.toDouble());
      if (p.dx < 18 || p.dx > size.width - 18) continue;
      canvas.drawLine(
        Offset(p.dx, railY - 6),
        Offset(p.dx, railY + 6),
        axis,
      );
      final tp = TextPainter(
        text: TextSpan(text: '$x', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(p.dx - tp.width / 2, railY + 10));
    }
  }

  void _drawCm(Canvas canvas, Offset pg, double railY) {
    const r = 5.0;
    canvas.drawCircle(pg, r, Paint()..color = _cm);
    canvas.drawCircle(
      pg,
      r,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: '重心',
        style: TextStyle(
          color: _cm,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pg.dx - tp.width / 2, railY + 22));
  }

  void _drawSpring(Canvas canvas, Offset p1, Offset p2, double r1, double r2) {
    final dir = p2 - p1;
    final len = dir.distance;
    if (len < 1) return;
    final u = dir / len;
    final perp = Offset(-u.dy, u.dx);
    final start = p1 + u * r1;
    final end = p2 - u * r2;
    final coilLen = (end - start).distance;
    final paint = Paint()
      ..color = const Color(0xFF37474F)
      ..strokeWidth = 1.7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (coilLen < 8) {
      canvas.drawLine(start, end, paint);
      return;
    }

    // Textbook coil: constant radius, straight end stubs, slight axial
    // projection so each turn looks like a loop rather than a sine wave.
    const coils = 12;
    const amp = 10.0;
    const loop = 0.48;
    final stubLen = math.min(11.0, coilLen * 0.12);
    final coilStart = start + u * stubLen;
    final coilEnd = end - u * stubLen;
    final body = (coilEnd - coilStart).distance;
    final path = Path()..moveTo(start.dx, start.dy);
    path.lineTo(coilStart.dx, coilStart.dy);

    const samplesPerCoil = 18;
    final samples = coils * samplesPerCoil;
    for (int i = 1; i <= samples; i++) {
      final t = i / samples;
      final theta = t * coils * 2 * math.pi;
      final along = t * body + amp * loop * (math.cos(theta) - 1);
      final p = coilStart + u * along + perp * (amp * math.sin(theta));
      path.lineTo(p.dx, p.dy);
    }
    path.lineTo(end.dx, end.dy);
    canvas.drawPath(path, paint);
  }

  void _drawMass(Canvas canvas, Offset c, double r, Color color, String label) {
    canvas.drawCircle(
      c.translate(0, 2),
      r,
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
    canvas.drawCircle(c, r, Paint()..color = color);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2));
  }

  void _drawVelocityArrow(Canvas canvas, Offset origin, double v, Color color) {
    if (v.abs() < 1e-3) return;
    final len = v * 18.0;
    final end = origin.translate(len, -42);
    final start = origin.translate(0, -42);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, paint);
    final sign = v >= 0 ? 1.0 : -1.0;
    final tip = end;
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx - 8 * sign, tip.dy - 4)
        ..lineTo(tip.dx - 8 * sign, tip.dy + 4)
        ..close(),
      Paint()..color = color,
    );
  }

  void _drawHud(Canvas canvas, Size size) {
    const numStyle = TextStyle(
      color: Color(0xFF37474F),
      fontSize: 11,
      fontFamily: 'Courier',
      height: 1.35,
    );
    const statusStyle = TextStyle(
      color: Color(0xFF37474F),
      fontSize: 11,
      height: 1.35,
    );
    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text:
                't = ${time.toStringAsFixed(2)}\n'
                'x1 = ${snapshot.x1.toStringAsFixed(2)}   v1 = ${snapshot.v1.toStringAsFixed(2)}\n'
                'x2 = ${snapshot.x2.toStringAsFixed(2)}   v2 = ${snapshot.v2.toStringAsFixed(2)}\n'
                'R = ${snapshot.r.toStringAsFixed(2)}   RG = ${snapshot.rg.toStringAsFixed(2)}\n',
            style: numStyle,
          ),
          TextSpan(
            text: running ? '運動中' : '初期条件を設定して Start',
            style: statusStyle,
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 8, tp.width + 16, tp.height + 10),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = Colors.white.withValues(alpha: 0.88),
    );
    tp.paint(canvas, const Offset(16, 13));
  }

  @override
  bool shouldRepaint(covariant _TwoBodySpring1DPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.running != running ||
        oldDelegate.snapshot.x1 != snapshot.x1 ||
        oldDelegate.snapshot.x2 != snapshot.x2 ||
        oldDelegate.ics.m1 != ics.m1 ||
        oldDelegate.ics.m2 != ics.m2 ||
        oldDelegate.ics.k != ics.k ||
        oldDelegate.ics.ell != ics.ell;
  }
}
