import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'coupled_oscillator_transverse_physics.dart';

final coupledOscillatorTransverse1D = createWaveVideo(
  title: '横波(N体バネ)',
  height: 720,
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>両端を壁に固定した $N$ 個の質点を、ばねで横につなぐ。横変位 $y_j$ は基準振動の重ね合わせで厳密に書ける。</p>
  <p>$$\begin{aligned}
  y_j(t)
  &=\sum_{n=1}^{N}\bigl(A_n\cos\omega_n t+B_n\sin\omega_n t\bigr)\\
  &\quad\times\sin\dfrac{n\pi j}{N+1}
  \end{aligned}$$</p>
  <p>$$\omega_n=2\sqrt{\dfrac{k}{m}}\,\sin\dfrac{n\pi}{2(N+1)}$$</p>
  <p>各モードの形は固定端の定在波と同じで、両端は常に節である。$N$ を大きくすると、連続な弦の固定端定在波に近づく。</p>
  <div class="common-box">使い方</div>
  <p>初期は1つの質点だけを上にずらしてある。停止中に $N$（2〜100）を変え、質点を上下にドラッグして初期形を決め、Start で運動が始まる。</p>
  """,
  simulation: CoupledOscillatorTransverse1DSimulation(),
);

class CoupledOscillatorTransverse1DSimulation extends PhysicsSimulation {
  CoupledOscillatorTransverse1DSimulation()
      : super(
          title: '横波(N体バネ)',
          formula: const FormulaDisplay(
            r'\omega_n=2\sqrt{\frac{k}{m}}\,\sin\frac{n\pi}{2(N+1)}',
          ),
          aspectRatio: 16 / 9,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<bool> running = ValueNotifier(false);
  final ValueNotifier<double> simTime = ValueNotifier(0.0);

  CoupledOscillatorModes? _frozen;
  Map<String, double> _latestParams = {};
  void Function(String key, double value)? _updateParam;
  bool _tickScheduled = false;
  DateTime? _lastTickAt;
  int _dragIndex = -1;

  @override
  Map<String, double> get initialParameters {
    final params = <String, double>{
      'n': kCoupledOscillatorDefaultN.toDouble(),
      'mode': 0,
    };
    for (int j = 1; j <= kCoupledOscillatorMaxN; j++) {
      params['y$j'] = j == 1 ? kCoupledOscillatorAmplitude : 0.0;
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
          kCoupledOscillatorMaxN,
        );
  }

  List<double> _ysOf(Map<String, double> params) {
    final n = _nMassesOf(params);
    return [for (int j = 1; j <= n; j++) params['y$j'] ?? 0.0];
  }

  List<double> _vsOf(Map<String, double> params) {
    final n = _nMassesOf(params);
    return [for (int j = 1; j <= n; j++) params['v$j'] ?? 0.0];
  }

  CoupledOscillatorModes _modesOf(Map<String, double> params) {
    return projectCoupledOscillator(y0: _ysOf(params), v0: _vsOf(params));
  }

  void start() {
    if (running.value) return;
    _frozen = _modesOf(_params);
    simTime.value = 0.0;
    _lastTickAt = null;
    running.value = true;
    _scheduleTick();
  }

  void resetMotion() {
    running.value = false;
    simTime.value = 0.0;
    _frozen = null;
    _lastTickAt = null;
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

  void _setN(
    double raw,
    void Function(String, double) updateParam,
  ) {
    final next = raw.round().clamp(
          kCoupledOscillatorMinN,
          kCoupledOscillatorMaxN,
        );
    updateParam('n', next.toDouble());
    updateParam('mode', 0);
  }

  @override
  Widget? buildFormulaOverlay(Map<String, double> parameters) {
    _rememberParams(parameters);
    final n = _nMassesOf(parameters);
    final mode = parameters['mode']!.round();
    final showMode = mode >= 1 && mode <= n;
    final omega = showMode ? coupledModeOmega(mode, n) : null;
    return Column(
      children: [
        const FormulaDisplay(
          r'\omega_n=2\sqrt{\frac{k}{m}}\,\sin\frac{n\pi}{2(N+1)}',
        ),
        const SizedBox(height: 4),
        Text(
          showMode
              ? 'N = $n    ω = ${omega!.toStringAsFixed(2)}    '
                  'T = ${(2 * math.pi / omega).toStringAsFixed(2)}'
              : 'N = $n',
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
        return Row(
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
                max: kCoupledOscillatorMaxN,
                enabled: !isRunning,
                onChanged: (v) => _setN(v, updateParam),
              ),
              if (isRunning)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    '運動中は N と初期形をロックしています。リセット後に変更できます。',
                    style: TextStyle(fontSize: 11, color: Color(0xFF546E7A)),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    '質点を上下にドラッグして初期形を変えられます。',
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
        final live = _modesOf(parameters);
        final modes = (running.value && _frozen != null) ? _frozen! : live;
        final t = running.value ? simTime.value : 0.0;
        final snap = evolveCoupledOscillator(modes, t);
        final mode = running.value
            ? dominantModeIndex(modes)
            : parameters['mode']!.round().clamp(0, modes.nMasses);
        final pureMode = (mode != null && mode >= 1) ? mode : 0;
        final canvas = CustomPaint(
          size: Size.infinite,
          painter: _CoupledOscillatorPainter(
            snapshot: snap,
            nMasses: modes.nMasses,
            time: t,
            running: running.value,
            mode: pureMode,
          ),
        );
        return LayoutBuilder(
          builder: (context, constraints) {
            final sized = SizedBox.expand(child: canvas);
            if (running.value) return sized;
            return RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                _EagerPanGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<
                        _EagerPanGestureRecognizer>(
                  () => _EagerPanGestureRecognizer(),
                  (instance) {
                    instance.onStart =
                        (d) => _onPanStart(d, constraints.biggest, snap);
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
        );
      },
    );
  }

  void _onPanStart(
    DragStartDetails details,
    Size size,
    CoupledOscillatorSnapshot snap,
  ) {
    final layout = _ChainLayout(size, snap.y.length);
    var best = -1;
    var bestDist = math.max(40.0, layout.massRadius() + 24);
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
    final layout = _ChainLayout(size, n);
    final y = layout.worldY(details.localPosition.dy).clamp(-1.0, 1.0);
    _updateParam!('mode', 0);
    _updateParam!('y${_dragIndex + 1}', y.toDouble());
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
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            label: '$value',
            onChanged: enabled ? onChanged : null,
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

class _ChainLayout {
  _ChainLayout(this.size, this.nMasses);

  final Size size;
  final int nMasses;

  static const double padX = 8;
  static const double top = 36;
  static const double bottom = 28;

  double get _spanX => size.width - 2 * padX;
  double get _midY => top + (size.height - top - bottom) * 0.52;
  double get _ampPx => (size.height - top - bottom) * 0.32;

  Offset wallLeft() => Offset(padX, _midY);
  Offset wallRight() => Offset(size.width - padX, _midY);

  Offset massOffset(int index, double y) {
    final x = padX + _spanX * (index + 1) / (nMasses + 1);
    return Offset(x, _midY - y * _ampPx);
  }

  double worldY(double screenY) => (_midY - screenY) / _ampPx;

  double massRadius() {
    final spacing = _spanX / (nMasses + 1);
    return (spacing * 0.28).clamp(2.2, 16.0);
  }
}

class _CoupledOscillatorPainter extends CustomPainter {
  _CoupledOscillatorPainter({
    required this.snapshot,
    required this.nMasses,
    required this.time,
    required this.running,
    required this.mode,
  });

  final CoupledOscillatorSnapshot snapshot;
  final int nMasses;
  final double time;
  final bool running;
  final int mode;

  static const _mass = Color(0xFF1565C0);
  static const _wall = Color(0xFF546E7A);
  static const _string = Color(0xFF00838F);
  static const _node = Color(0xFFC62828);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF7FAFC),
    );

    final layout = _ChainLayout(size, nMasses);
    final left = layout.wallLeft();
    final right = layout.wallRight();

    _drawEquilibrium(canvas, left, right);
    if (mode >= 1) {
      _drawNodes(canvas, layout, mode);
    }
    _drawString(canvas, layout, left, right);
    _drawWall(canvas, left, facingRight: true);
    _drawWall(canvas, right, facingRight: false);
    for (int i = 0; i < nMasses; i++) {
      _drawMass(canvas, layout.massOffset(i, snapshot.y[i]), layout.massRadius());
    }
    _drawHud(canvas, size);
  }

  void _drawEquilibrium(Canvas canvas, Offset left, Offset right) {
    final paint = Paint()
      ..color = const Color(0xFFB0BEC5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    const dash = 7.0;
    var x = left.dx;
    while (x < right.dx) {
      final x2 = math.min(x + 4, right.dx);
      canvas.drawLine(Offset(x, left.dy), Offset(x2, left.dy), paint);
      x += dash;
    }
  }

  void _drawNodes(Canvas canvas, _ChainLayout layout, int n) {
    final paint = Paint()
      ..color = _node
      ..strokeWidth = 1.4;
    for (int p = 1; p < n; p++) {
      final frac = p / n;
      final x = layout.wallLeft().dx +
          (layout.wallRight().dx - layout.wallLeft().dx) * frac;
      canvas.drawLine(
        Offset(x, layout._midY - 16),
        Offset(x, layout._midY + 16),
        paint,
      );
      final tp = TextPainter(
        text: const TextSpan(
          text: '節',
          style: TextStyle(color: _node, fontSize: 10, fontWeight: FontWeight.w700),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, layout._midY + 18));
    }
  }

  void _drawString(
    Canvas canvas,
    _ChainLayout layout,
    Offset left,
    Offset right,
  ) {
    final path = Path()..moveTo(left.dx, left.dy);
    for (int i = 0; i < nMasses; i++) {
      final p = layout.massOffset(i, snapshot.y[i]);
      path.lineTo(p.dx, p.dy);
    }
    path.lineTo(right.dx, right.dy);
    canvas.drawPath(
      path,
      Paint()
        ..color = _string
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawWall(Canvas canvas, Offset center, {required bool facingRight}) {
    final w = 10.0;
    final h = 52.0;
    final rect = Rect.fromCenter(
      center: center.translate(facingRight ? -4 : 4, 0),
      width: w,
      height: h,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
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
        Offset(rect.center.dx + 8 * dir, y + 6),
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
        ..strokeWidth = 1.6,
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
    final modeLine = mode >= 1 ? 'モード n = $mode（固定端の定在波）\n' : '';
    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: 't = ${time.toStringAsFixed(2)}    N = $nMasses\n$modeLine',
            style: numStyle,
          ),
          TextSpan(
            text: running ? '運動中' : '質点をドラッグして Start',
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
  bool shouldRepaint(covariant _CoupledOscillatorPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.running != running ||
        oldDelegate.nMasses != nMasses ||
        oldDelegate.mode != mode ||
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

class _EagerPanGestureRecognizer extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}
