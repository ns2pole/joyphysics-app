import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'coupled_oscillator_transverse_physics.dart';

final coupledOscillatorLongitudinal1D = createWaveVideo(
  title: '縦波,疎密波(N体バネ)',
  height: 920,
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>両端を壁に固定した $N$ 個の質点を、ばねで一直線につなぐ。縦変位 $u_j$（平衡位置からの左右のずれ）は横波と同じ基準振動の重ね合わせで厳密に書ける。</p>
  <p>$$\begin{aligned}
  u_j(t)
  &=\sum_{n=1}^{N}\bigl(A_n\cos\omega_n t+B_n\sin\omega_n t\bigr)\\
  &\quad\times\sin\dfrac{n\pi j}{N+1}
  \end{aligned}$$</p>
  <p>$$\omega_n=2\sqrt{\dfrac{k}{m}}\,\sin\dfrac{n\pi}{2(N+1)}$$</p>
  <p>密なところ（圧縮）と疎なところ（伸長）が交互に進むのが縦波である。$N$ を大きくすると連続な媒質の疎密波に近づく。</p>
  """,
  simulation: CoupledOscillatorLongitudinal1DSimulation(),
);

class CoupledOscillatorLongitudinal1DSimulation extends PhysicsSimulation {
  CoupledOscillatorLongitudinal1DSimulation()
      : super(
          title: '縦波,疎密波(N体バネ)',
          formula: const FormulaDisplay(
            r'\omega_n=2\sqrt{\frac{k}{m}}\,\sin\frac{n\pi}{2(N+1)}',
          ),
          aspectRatio: 4 / 3,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> simTime = ValueNotifier(0.0);

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    simTime.value += dt;
  });

  ValueNotifier<bool> get running => _loop.running;

  CoupledOscillatorModes? _frozen;
  CoupledOscillatorSnapshot? _pausedSnapshot;
  Map<String, double> _latestParams = {};
  void Function(String key, double value)? _updateParam;
  int _dragIndex = -1;

  @override
  Map<String, double> get initialParameters {
    final params = <String, double>{
      'n': kCoupledOscillatorLongitudinalDefaultN.toDouble(),
      'mode': 0,
    };
    for (int j = 1; j <= kCoupledOscillatorLongitudinalMaxN; j++) {
      params['u$j'] =
          j == 1 ? kCoupledOscillatorLongitudinalAmplitude : 0.0;
      params['v$j'] = 0.0;
    }
    return params;
  }

  void _rememberParams(Map<String, double> params) {
    _latestParams = Map<String, double>.from(params);
  }

  Map<String, double> get _params {
    if (_latestParams.isEmpty) return initialParameters;
    return _latestParams;
  }

  int _nMassesOf(Map<String, double> params) {
    return params['n']!.round().clamp(
          kCoupledOscillatorMinN,
          kCoupledOscillatorLongitudinalMaxN,
        );
  }

  List<double> _usOf(Map<String, double> params) {
    final n = _nMassesOf(params);
    return [for (int j = 1; j <= n; j++) params['u$j'] ?? 0.0];
  }

  List<double> _vsOf(Map<String, double> params) {
    final n = _nMassesOf(params);
    return [for (int j = 1; j <= n; j++) params['v$j'] ?? 0.0];
  }

  CoupledOscillatorModes _modesOf(Map<String, double> params) {
    return projectCoupledOscillator(y0: _usOf(params), v0: _vsOf(params));
  }

  bool get _inSession => _frozen != null;

  void start() {
    if (running.value) return;
    if (_frozen == null) {
      _frozen = _modesOf(_params);
      simTime.value = 0.0;
    }
    _pausedSnapshot = null;
    _loop.start();
  }

  void pause() {
    if (!running.value || _frozen == null) return;
    _pausedSnapshot = evolveCoupledOscillator(_frozen!, simTime.value);
    _loop.pause();
  }

  void resetMotion() {
    _loop.reset();
    simTime.value = 0.0;
    _frozen = null;
    _pausedSnapshot = null;
  }

  void _setN(
    double raw,
    void Function(String, double) updateParam,
  ) {
    if (running.value) return;
    final next = raw.round().clamp(
          kCoupledOscillatorMinN,
          kCoupledOscillatorLongitudinalMaxN,
        );
    // 一時停止中に N を変えたらセッションを閉じて、新しい質点数が絵に反映されるようにする。
    if (_inSession) resetMotion();
    updateParam('n', next.toDouble());
    updateParam('mode', 0);
  }

  @override
  Widget? buildFormulaOverlay(Map<String, double> parameters) {
    _rememberParams(parameters);
    final n = _nMassesOf(parameters);
    return Column(
      children: [
        const FormulaDisplay(
          r'\omega_n=2\sqrt{\frac{k}{m}}\,\sin\frac{n\pi}{2(N+1)}',
        ),
        const SizedBox(height: 4),
        Text(
          'N = $n',
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
        final inSession = _inSession;
        return PlayPauseResetButtons(
          playing: isRunning,
          onPlayPause: isRunning ? pause : start,
          onReset: resetMotion,
          playTooltip: inSession ? '再開' : '再生',
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
    final n = _nMassesOf(parameters);
    return [
      ValueListenableBuilder<bool>(
        valueListenable: running,
        builder: (context, isRunning, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '質点数 N',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              _IntegerStepperSlider(
                label: 'N',
                value: n,
                min: kCoupledOscillatorMinN,
                max: kCoupledOscillatorLongitudinalMaxN,
                enabled: !isRunning,
                onChanged: (v) => _setN(v, updateParam),
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
        final live = _modesOf(parameters);
        final inSession = _inSession;
        final paused = inSession && !running.value;
        final modes = (inSession && _frozen != null) ? _frozen! : live;
        final t = inSession ? simTime.value : 0.0;
        final snap = (paused && _pausedSnapshot != null)
            ? _pausedSnapshot!
            : evolveCoupledOscillator(modes, t);
        final longCanvas = CustomPaint(
          size: Size.infinite,
          painter: _LongitudinalPainter(
            snapshot: snap,
            nMasses: modes.nMasses,
            time: t,
            running: running.value,
            paused: paused,
          ),
        );
        final transverseGraph = CustomPaint(
          size: Size.infinite,
          painter: _TransverseDisplacementGraphPainter(
            snapshot: snap,
            nMasses: modes.nMasses,
            showDensityLabels: true,
          ),
        );
        return Column(
          children: [
            Expanded(
              flex: kLongitudinalChainFlex,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final sized = SizedBox.expand(child: longCanvas);
                  if (inSession) return sized;
                  return RawGestureDetector(
                    behavior: HitTestBehavior.opaque,
                    gestures: {
                      _EagerPanGestureRecognizer:
                          GestureRecognizerFactoryWithHandlers<
                              _EagerPanGestureRecognizer>(
                        () => _EagerPanGestureRecognizer(),
                        (instance) {
                          instance.onStart = (d) =>
                              _onPanStart(d, constraints.biggest, snap);
                          instance.onUpdate =
                              (d) => _onPanUpdate(d, constraints.biggest);
                          instance.onEnd = (_) => _dragIndex = -1;
                          instance.onCancel = () => _dragIndex = -1;
                        },
                      ),
                    },
                    child: sized,
                  );
                },
              ),
            ),
            Expanded(
              flex: kTransverseDisplacementGraphFlex,
              child: Container(
                margin: const EdgeInsets.fromLTRB(5, 6, 5, 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFC5DCE8),
                  border: Border.all(
                    color: const Color(0xFF004D56),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00363A).withValues(alpha: 0.38),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: SizedBox.expand(child: transverseGraph),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onPanStart(
    DragStartDetails details,
    Size size,
    CoupledOscillatorSnapshot snap,
  ) {
    final layout = LongitudinalChainLayout(size, snap.y.length);
    var best = -1;
    var bestDist = math.max(36.0, layout.massRadius() + 20);
    for (int i = 0; i < snap.y.length; i++) {
      final p = layout.massOffset(i, snap.y[i]);
      final d = (p - details.localPosition).distance;
      if (d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    _dragIndex = best;
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (_dragIndex < 0 || _updateParam == null) return;
    final n = _nMassesOf(_params);
    final layout = LongitudinalChainLayout(size, n);
    final u = layout.worldU(details.localPosition.dx, _dragIndex).clamp(-1.0, 1.0);
    _updateParam!('mode', 0);
    _updateParam!('u${_dragIndex + 1}', u.toDouble());
  }
}

class _IntegerStepperSlider extends StatelessWidget {
  const _IntegerStepperSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: '$label を減らす',
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: EdgeInsets.zero,
          onPressed: enabled && value > min
              ? () => onChanged((value - 1).toDouble())
              : null,
          icon: const Icon(Icons.remove),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max).toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            label: '$value',
            onChanged: enabled
                ? (v) => onChanged(v.round().toDouble())
                : null,
          ),
        ),
        IconButton(
          tooltip: '$label を増やす',
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: EdgeInsets.zero,
          onPressed: enabled && value < max
              ? () => onChanged((value + 1).toDouble())
              : null,
          icon: const Icon(Icons.add),
        ),
        SizedBox(
          width: 40,
          child: Text(
            '$value',
            style: const TextStyle(fontSize: 12, fontFamily: 'Courier'),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class LongitudinalChainLayout {
  LongitudinalChainLayout(this.size, this.nMasses);

  final Size size;
  final int nMasses;

  static const double padX = kCoupledOscillatorLongitudinalPadX;
  static const double wallW = 8;
  static const double top = 36;
  static const double bottom = 28;

  double get leftInner => padX + wallW;
  double get rightInner => size.width - padX - wallW;
  double get _spanX => rightInner - leftInner;
  double get _midY => top + (size.height - top - bottom) * 0.52;
  double get spacing => _spanX / (nMasses + 1);
  /// 左右ドラッグの視覚幅（従来 0.40×spacing の約 1.3 倍）
  double get ampPx => spacing * 0.52;

  Offset wallLeft() => Offset(padX, _midY);
  Offset wallRight() => Offset(size.width - padX, _midY);

  double xEq(int index) => leftInner + spacing * (index + 1);

  Offset massOffset(int index, double u) {
    return Offset(xEq(index) + u * ampPx, _midY);
  }

  double worldU(double screenX, int index) => (screenX - xEq(index)) / ampPx;

  double massRadius() {
    return (spacing * 0.24).clamp(2.0, 14.0);
  }
}

class _LongitudinalPainter extends CustomPainter {
  _LongitudinalPainter({
    required this.snapshot,
    required this.nMasses,
    required this.time,
    required this.running,
    required this.paused,
  });

  final CoupledOscillatorSnapshot snapshot;
  final int nMasses;
  final double time;
  final bool running;
  final bool paused;

  static const _mass = Color(0xFF1565C0);
  static const _wall = Color(0xFF546E7A);
  static const _spring = Color(0xFF00838F);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF7FAFC),
    );

    final layout = LongitudinalChainLayout(size, nMasses);

    _drawRail(canvas, layout);
    paintEquilibriumPositionTicks(
      canvas,
      xs: [for (int i = 0; i < nMasses; i++) layout.xEq(i)],
      midY: layout._midY,
    );
    _drawString(canvas, layout);
    _drawWall(canvas, layout, facingRight: true);
    _drawWall(canvas, layout, facingRight: false);
    for (int i = 0; i < nMasses; i++) {
      _drawMass(
        canvas,
        layout.massOffset(i, snapshot.y[i]),
        layout.massRadius(),
      );
    }
    if (paused) {
      _paintDensityMarksWithGuides(
        canvas,
        u: snapshot.y,
        equilibriumXs: [
          layout.leftInner,
          for (int i = 0; i < nMasses; i++) layout.xEq(i),
          layout.rightInner,
        ],
        lineStartY: layout._midY + layout.massRadius(),
        canvasBottom: size.height,
      );
    }
    _drawHud(canvas, size);
  }

  void _drawRail(Canvas canvas, LongitudinalChainLayout layout) {
    final paint = Paint()
      ..color = const Color(0xFFB0BEC5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(layout.wallLeft(), layout.wallRight(), paint);
  }

  void _drawString(Canvas canvas, LongitudinalChainLayout layout) {
    final path = Path()
      ..moveTo(layout.leftInner, layout._midY);
    for (int i = 0; i < nMasses; i++) {
      final p = layout.massOffset(i, snapshot.y[i]);
      path.lineTo(p.dx, p.dy);
    }
    path.lineTo(layout.rightInner, layout._midY);
    canvas.drawPath(
      path,
      Paint()
        ..color = _spring
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawWall(
    Canvas canvas,
    LongitudinalChainLayout layout, {
    required bool facingRight,
  }) {
    final h = 52.0;
    final rect = facingRight
        ? Rect.fromLTWH(
            LongitudinalChainLayout.padX,
            layout._midY - h / 2,
            LongitudinalChainLayout.wallW,
            h,
          )
        : Rect.fromLTWH(
            layout.size.width -
                LongitudinalChainLayout.padX -
                LongitudinalChainLayout.wallW,
            layout._midY - h / 2,
            LongitudinalChainLayout.wallW,
            h,
          );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(1)),
      Paint()..color = _wall,
    );
    final hatch = Paint()
      ..color = const Color(0xFF90A4AE)
      ..strokeWidth = 1.2;
    final dir = facingRight ? -1.0 : 1.0;
    for (int i = 0; i < 6; i++) {
      final y = rect.top + 6 + i * 8;
      canvas.drawLine(
        Offset(rect.center.dx, y),
        Offset(rect.center.dx + 6 * dir, y + 5),
        hatch,
      );
    }
  }

  void _drawMass(Canvas canvas, Offset c, double r) {
    canvas.drawCircle(
      c.translate(0, 1.5),
      r,
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
    canvas.drawCircle(c, r, Paint()..color = _mass);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
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
            text: 't = ${time.toStringAsFixed(2)}    N = $nMasses\n',
            style: numStyle,
          ),
          if (running || paused)
            TextSpan(
              text: running ? '運動中' : '一時停止',
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
  bool shouldRepaint(covariant _LongitudinalPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.running != running ||
        oldDelegate.paused != paused ||
        oldDelegate.nMasses != nMasses ||
        oldDelegate.snapshot.y.length != snapshot.y.length ||
        !_listEq(oldDelegate.snapshot.y, snapshot.y);
  }

  bool _listEq(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// わずかな伸び縮みは無視し、はっきりした疎密だけを残す。
const double kLongitudinalDensityAbsThreshold = 0.18;
const double kLongitudinalDensityRelThreshold = 0.55;

/// 隣り合う点の相対変位 Δu = u_右 − u_左（両端壁は u=0）。
/// 正なら伸長＝疎、負なら圧縮＝密。|Δu| が閾値以下なら null。
String? longitudinalDensityLabel(
  double deltaU, {
  double threshold = kLongitudinalDensityAbsThreshold,
}) {
  if (deltaU > threshold) return '疎';
  if (deltaU < -threshold) return '密';
  return null;
}

/// 壁込みの各区間（N+1 本）の疎/密ラベル。
/// 最大 |Δu| に対して弱い区間は落とし、[peaksOnly] なら局所ピークだけ残す。
List<String?> longitudinalDensityLabels(
  List<double> u, {
  double threshold = kLongitudinalDensityAbsThreshold,
  double relativeThreshold = kLongitudinalDensityRelThreshold,
  bool peaksOnly = false,
}) {
  if (u.isEmpty) return const [];
  final dus = <double>[u.first];
  for (int i = 0; i < u.length - 1; i++) {
    dus.add(u[i + 1] - u[i]);
  }
  dus.add(-u.last);

  final maxAbs = dus.fold<double>(0.0, (m, e) => math.max(m, e.abs()));
  final cut = math.max(threshold, maxAbs * relativeThreshold);
  final labels = [
    for (final du in dus) longitudinalDensityLabel(du, threshold: cut),
  ];
  if (!peaksOnly) return labels;

  final out = List<String?>.filled(labels.length, null);
  for (int i = 0; i < dus.length; i++) {
    final lab = labels[i];
    if (lab == null) continue;
    final left = i > 0 ? dus[i - 1] : dus[i];
    final right = i + 1 < dus.length ? dus[i + 1] : dus[i];
    if (lab == '密' && dus[i] <= left && dus[i] <= right) {
      out[i] = lab;
    } else if (lab == '疎' && dus[i] >= left && dus[i] >= right) {
      out[i] = lab;
    }
  }
  return out;
}

/// 区間 [intervalIndex]（0=左壁〜質点1, N=質点N〜右壁）の
/// 平衡位置での中点。点線の x は質点の現在位置ではなく、区間の中央。
double longitudinalDensityGuideX(
  int intervalIndex,
  List<double> equilibriumXs,
) {
  return (equilibriumXs[intervalIndex] + equilibriumXs[intervalIndex + 1]) / 2;
}

/// 点線の真下に置く疎密マーク。重なるときは [y] を下げて点線を伸ばす。
class LongitudinalDensityMarkLayout {
  const LongitudinalDensityMarkLayout({
    required this.intervalIndex,
    required this.x,
    required this.y,
    required this.text,
  });

  final int intervalIndex;
  final double x;
  final double y;
  final String text;
}

/// 各区間の平衡位置中点にマークを置き、円が重なるときは下段へずらす。
List<LongitudinalDensityMarkLayout> layoutLongitudinalDensityMarks({
  required List<String?> labels,
  required List<double> equilibriumXs,
  required double radius,
  required double baseY,
  required double maxY,
}) {
  final step = 2 * radius + 6;
  final minDist2 = (2 * radius + 2) * (2 * radius + 2);
  final raw = <LongitudinalDensityMarkLayout>[];
  for (int s = 0; s < labels.length; s++) {
    final text = labels[s];
    if (text == null) continue;
    if (s + 1 >= equilibriumXs.length) continue;
    raw.add(
      LongitudinalDensityMarkLayout(
        intervalIndex: s,
        x: longitudinalDensityGuideX(s, equilibriumXs),
        y: baseY,
        text: text,
      ),
    );
  }
  raw.sort((a, b) {
    final byX = a.x.compareTo(b.x);
    if (byX != 0) return byX;
    return a.intervalIndex.compareTo(b.intervalIndex);
  });

  final placed = <LongitudinalDensityMarkLayout>[];
  for (final mark in raw) {
    var y = baseY;
    while (true) {
      final overlaps = placed.any((p) {
        final dx = p.x - mark.x;
        final dy = p.y - y;
        return dx * dx + dy * dy < minDist2;
      });
      if (!overlaps) break;
      final next = math.min(y + step, maxY);
      if (next <= y) break;
      y = next;
    }
    placed.add(
      LongitudinalDensityMarkLayout(
        intervalIndex: mark.intervalIndex,
        x: mark.x,
        y: y.clamp(baseY, maxY),
        text: mark.text,
      ),
    );
  }
  return placed;
}

const _kDensityDenseColor = Color(0xFFC62828);
const _kDensityRareColor = Color(0xFF1565C0);

TextPainter _densityMarkTextPainter(String text, Color color) {
  return TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        height: 1.0,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
}

void _paintDensityMarksWithGuides(
  Canvas canvas, {
  required List<double> u,
  required List<double> equilibriumXs,
  required double lineStartY,
  required double canvasBottom,
  double? labelBaseY,
}) {
  final n = u.length;
  if (n == 0 || equilibriumXs.length != n + 2) return;
  final labels = longitudinalDensityLabels(
    u,
    peaksOnly: true,
  );
  final sample = _densityMarkTextPainter('密', _kDensityDenseColor);
  final radius = math.max(sample.width, sample.height) * 0.5 + 4.5;
  final maxY = math.max(radius + 2, canvasBottom - radius - 4);
  final autoBaseY = math.min(maxY, lineStartY + radius + 12);
  final baseY = (labelBaseY ?? autoBaseY).clamp(radius + 2, maxY);

  final marks = layoutLongitudinalDensityMarks(
    labels: labels,
    equilibriumXs: equilibriumXs,
    radius: radius,
    baseY: baseY,
    maxY: maxY,
  );
  for (final mark in marks) {
    final color =
        mark.text == '密' ? _kDensityDenseColor : _kDensityRareColor;
    _drawVerticalDashedLine(
      canvas,
      mark.x,
      lineStartY,
      mark.y - radius,
      color,
    );
    _paintCircledDensityLabel(
      canvas,
      Offset(mark.x, mark.y),
      _densityMarkTextPainter(mark.text, color),
      radius,
      color,
    );
  }
}

void _drawVerticalDashedLine(
  Canvas canvas,
  double x,
  double yStart,
  double yEnd,
  Color color,
) {
  if (yEnd <= yStart + 1.0) return;
  final paint = Paint()
    ..color = color.withValues(alpha: 0.92)
    ..strokeWidth = 1.8
    ..style = PaintingStyle.stroke;
  const dash = 4.0;
  const gap = 2.4;
  var y = yStart;
  while (y < yEnd) {
    final y2 = math.min(y + dash, yEnd);
    canvas.drawLine(Offset(x, y), Offset(x, y2), paint);
    y += dash + gap;
  }
}

void _paintCircledDensityLabel(
  Canvas canvas,
  Offset center,
  TextPainter tp,
  double radius,
  Color color,
) {
  canvas.drawCircle(
    center,
    radius,
    Paint()..color = Colors.white.withValues(alpha: 0.92),
  );
  canvas.drawCircle(
    center,
    radius,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5,
  );
  tp.paint(
    canvas,
    Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
  );
}

/// 質点の平衡位置（元の位置）を示す刻み。
void paintEquilibriumPositionTicks(
  Canvas canvas, {
  required Iterable<double> xs,
  required double midY,
  double above = 5,
  double below = 5,
}) {
  final paint = Paint()
    ..color = const Color(0xFF546E7A)
    ..strokeWidth = 1.2;
  for (final x in xs) {
    canvas.drawLine(
      Offset(x, midY - above),
      Offset(x, midY + below),
      paint,
    );
  }
}

/// 縦波の変位 $u_j$ を、同じ時刻で横波（上下変位）として描く同期グラフ。
/// 下余白は最初からラベル・縦点線用を取り、Pause しても縮尺を変えない。
const int kLongitudinalChainFlex = 5;
const int kTransverseDisplacementGraphFlex = 8;
const double kTransverseDisplacementGraphPadX = 8;
const double kTransverseDisplacementGraphTop = 28;
const double kTransverseDisplacementGraphBottom = 58;
const double kTransverseDisplacementGraphAmpFrac = 0.42;
const double kTransverseDisplacementGraphMidFrac = 0.32;
/// 横波表示の縦方向強調（変位 u に掛ける係数）。
const double kTransverseDisplacementGraphExaggerate = 4.0;
const double kTransverseDisplacementGraphExaggerateClamp = 2.4;

double transverseDisplacementGraphAmpPx(Size size) {
  return (size.height -
          kTransverseDisplacementGraphTop -
          kTransverseDisplacementGraphBottom) *
      kTransverseDisplacementGraphAmpFrac;
}

double transverseDisplacementGraphMidY(Size size) {
  return kTransverseDisplacementGraphTop +
      (size.height -
          kTransverseDisplacementGraphTop -
          kTransverseDisplacementGraphBottom) *
          kTransverseDisplacementGraphMidFrac;
}

/// 横波表示の質点 x（平衡位置。縦波の刻みと同じ）。
List<double> transverseDisplacementGraphMassXs(Size size, int nMasses) {
  final left = kTransverseDisplacementGraphPadX;
  final spanX = size.width - 2 * kTransverseDisplacementGraphPadX;
  return [
    for (int i = 0; i < nMasses; i++)
      left + spanX * (i + 1) / (nMasses + 1),
  ];
}

class _TransverseDisplacementGraphPainter extends CustomPainter {
  _TransverseDisplacementGraphPainter({
    required this.snapshot,
    required this.nMasses,
    this.showDensityLabels = false,
  });

  final CoupledOscillatorSnapshot snapshot;
  final int nMasses;
  final bool showDensityLabels;

  static const _mass = Color(0xFF1565C0);
  static const _string = Color(0xFF00838F);
  static const double _padX = kTransverseDisplacementGraphPadX;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFC5DCE8),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, 5),
      Paint()..color = const Color(0xFF004D56),
    );

    final midY = transverseDisplacementGraphMidY(size);
    final ampPx = transverseDisplacementGraphAmpPx(size);
    final left = Offset(_padX, midY);
    final right = Offset(size.width - _padX, midY);
    final spanX = right.dx - left.dx;
    final massXs = transverseDisplacementGraphMassXs(size, nMasses);

    Offset massAt(int i, double u) {
      final scaled = (u * kTransverseDisplacementGraphExaggerate).clamp(
        -kTransverseDisplacementGraphExaggerateClamp,
        kTransverseDisplacementGraphExaggerateClamp,
      );
      return Offset(massXs[i], midY - scaled * ampPx);
    }

    // baseline
    final basePaint = Paint()
      ..color = const Color(0xFF78909C)
      ..strokeWidth = 1.3;
    const dash = 6.0;
    var x = left.dx;
    while (x < right.dx) {
      final x2 = math.min(x + 3.5, right.dx);
      canvas.drawLine(Offset(x, midY), Offset(x2, midY), basePaint);
      x += dash;
    }

    paintEquilibriumPositionTicks(
      canvas,
      xs: massXs,
      midY: midY,
      above: 5,
      below: 8,
    );

    final path = Path()..moveTo(left.dx, left.dy);
    for (int i = 0; i < nMasses; i++) {
      final p = massAt(i, snapshot.y[i]);
      path.lineTo(p.dx, p.dy);
    }
    path.lineTo(right.dx, right.dy);
    canvas.drawPath(
      path,
      Paint()
        ..color = _string
        ..strokeWidth = 2.6
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    final r = (spanX / (nMasses + 1) * 0.22).clamp(2.0, 10.0);
    for (int i = 0; i < nMasses; i++) {
      final p = massAt(i, snapshot.y[i]);
      canvas.drawCircle(p, r, Paint()..color = _mass);
    }

    if (showDensityLabels) {
      _paintDensityMarksWithGuides(
        canvas,
        u: snapshot.y,
        equilibriumXs: [
          left.dx,
          ...massXs,
          right.dx,
        ],
        lineStartY: midY,
        canvasBottom: size.height,
        labelBaseY: size.height - 22,
      );
    }

    final label = TextPainter(
      text: TextSpan(
        text: showDensityLabels
            ? '同じ変位の横波表示（×4・区間中央の疎／密）'
            : '同じ変位の横波表示（×4）',
        style: const TextStyle(
          color: Color(0xFF102027),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas, const Offset(10, 10));
  }

  @override
  bool shouldRepaint(covariant _TransverseDisplacementGraphPainter old) {
    return old.nMasses != nMasses ||
        old.showDensityLabels != showDensityLabels ||
        old.snapshot.y.length != snapshot.y.length ||
        !_eq(old.snapshot.y, snapshot.y);
  }

  bool _eq(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class _EagerPanGestureRecognizer extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}
