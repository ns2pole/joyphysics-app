import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../widgets/wave_slider.dart';

final closedPipeWaterResonance1D = createWaveVideo(
  title: "気柱の共鳴（閉管・水位）",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>水面が閉口（変位の節）、上端が開口（変位の腹）です。開口は圧力駆動 $p(0)=\varepsilon\sin(2\pi f t)$ で、変位そのものは固定しません。</p>
  <p>開口端補正 $\Delta l$ だけ実際の反射位置が管の外に出ます。共振条件は</p>
  <p>$$L+\Delta l=(2n-1)\dfrac{\lambda}{4},\quad
  f_n=\dfrac{(2n-1)v}{4(L+\Delta l)},\quad
  \Delta l=0.6r\ \text{または}\ 0.8r$$</p>
  <p>変位は開口から入り、水面（固定端）と開口（自由端）で反射して積み上がります。音速が速いので画面はスロー再生です。破線は管の外の仮想腹（$\Delta l$）です。</p>
  """,
  simulation: ClosedPipeWaterResonance1DSimulation(),
  height: 720,
);

const double _soundSpeed = 340.0;
const double _resonanceTol = 0.02;

double _deltaL(double radiusM, double coeff) => coeff * radiusM;

double _leff(double length, double radiusM, double coeff) =>
    length + _deltaL(radiusM, coeff);

double _f1(double length, double radiusM, double coeff) =>
    _soundSpeed / (4 * _leff(length, radiusM, coeff));

int? _nearestClosedMode(double f, double f1) {
  if (f1 <= 0) return null;
  final ratio = f / f1;
  var odd = ratio.round();
  if (odd % 2 == 0) {
    odd = (ratio - odd) >= 0 ? odd + 1 : odd - 1;
  }
  if (odd < 1) return null;
  if ((ratio - odd).abs() < _resonanceTol) return (odd + 1) ~/ 2;
  return null;
}

/// 最も近い奇数倍共振までの近さ（0=遠い, 1=ちょうど共鳴）
double _resonanceCloseness(double f, double f1) {
  if (f1 <= 0) return 0.0;
  final ratio = f / f1;
  var odd = ratio.round();
  if (odd % 2 == 0) {
    odd = (ratio - odd) >= 0 ? odd + 1 : odd - 1;
  }
  if (odd < 1) odd = 1;
  const width = 0.10;
  final x = ((ratio - odd).abs() / width).clamp(0.0, 1.0);
  return (1 - x) * (1 - x);
}

double _toneVolume(double f, double f1) =>
    0.22 + 0.38 * _resonanceCloseness(f, f1);

class ClosedPipeWaterResonance1DSimulation extends WaveSimulation {
  ClosedPipeWaterResonance1DSimulation()
      : super(
          title: "気柱の共鳴（閉管・水位）",
          is3D: false,
          showTimeOverlay: false,
          formula: const Column(
            children: [
              FormulaDisplay(r'L+\Delta l=(2n-1)\lambda/4'),
              SizedBox(height: 4),
              FormulaDisplay(r'\Delta l = 0.6r\ \mathrm{or}\ 0.8r'),
            ],
          ),
        );

  @override
  Map<String, double> get initialParameters => {
        // L=0.20 m, r=1.1 cm, Δl=0.6r → Leff≈0.207 m, f1≈411 Hz
        'freq': 411.0,
        'length': 0.20,
        'radiusCm': 1.10,
        'deltaCoeff': 0.6,
        'slowMo': 2000.0,
      };

  @override
  List<Widget> buildControls(context, params, updateParam) {
    final L = params['length']!;
    final f = params['freq']!;
    final rCm = params['radiusCm']!;
    final coeff = params['deltaCoeff']!;
    final r = rCm / 100.0;
    final dl = _deltaL(r, coeff);
    final leff = _leff(L, r, coeff);
    final lambda = _soundSpeed / f;
    final f1 = _f1(L, r, coeff);
    final mode = _nearestClosedMode(f, f1);
    final ratio = f / f1;
    final slowMo = params['slowMo']!;

    return [
      Text(
        'v = ${_soundSpeed.toStringAsFixed(0)} m/s   '
        'λ = ${lambda.toStringAsFixed(3)} m\n'
        'L = ${(L * 100).toStringAsFixed(1)} cm   '
        'Δl = ${(dl * 100).toStringAsFixed(2)} cm   '
        'L+Δl = ${(leff * 100).toStringAsFixed(1)} cm\n'
        'f₁ = ${f1.toStringAsFixed(0)} Hz   '
        'f/f₁ = ${ratio.toStringAsFixed(2)}'
        '${mode != null ? '  ★第$mode 共鳴' : ''}   '
        '（×${slowMo.toStringAsFixed(0)} スロー）',
        style: TextStyle(
          fontSize: 12,
          fontWeight: mode != null ? FontWeight.bold : FontWeight.normal,
          color: mode != null ? Colors.deepOrange : null,
          height: 1.35,
        ),
      ),
      WaveParameterSlider(
        label: 'f[Hz]',
        value: params['freq']!,
        min: 200.0,
        max: 800.0,
        onChanged: (val) => updateParam('freq', val),
      ),
      WaveParameterSlider(
        label: 'L[m]',
        value: params['length']!,
        min: 0.10,
        max: 0.70,
        onChanged: (val) => updateParam('length', val),
      ),
      WaveParameterSlider(
        label: 'r[cm]',
        value: params['radiusCm']!,
        min: 0.50,
        max: 2.00,
        onChanged: (val) => updateParam('radiusCm', val),
      ),
      WaveParameterSlider(
        label: 'スロー',
        value: params['slowMo']!,
        min: 50.0,
        max: 5000.0,
        onChanged: (val) => updateParam('slowMo', val),
      ),
      _ClosedPipeToneControl(key: const ValueKey('closedPipeTone'), freq: f, f1: f1),
      const SizedBox(height: 4),
      const Text('開口端補正 Δl',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: const Text('0.6 r', style: TextStyle(fontSize: 12)),
            selected: (coeff - 0.6).abs() < 0.05,
            onSelected: (_) => updateParam('deltaCoeff', 0.6),
            visualDensity: VisualDensity.compact,
          ),
          ChoiceChip(
            label: const Text('0.8 r', style: TextStyle(fontSize: 12)),
            selected: (coeff - 0.8).abs() < 0.05,
            onSelected: (_) => updateParam('deltaCoeff', 0.8),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    ];
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    return ClosedPipeWaterBoard(
      time: time,
      freq: params['freq']!,
      length: params['length']!,
      radiusCm: params['radiusCm']!,
      deltaCoeff: params['deltaCoeff']!,
      slowMo: params['slowMo']!,
      scale: scale,
    );
  }
}

class ClosedPipeWaterBoard extends StatefulWidget {
  final double time;
  final double freq;
  final double length;
  final double radiusCm;
  final double deltaCoeff;
  final double slowMo;
  final double scale;

  const ClosedPipeWaterBoard({
    super.key,
    required this.time,
    required this.freq,
    required this.length,
    required this.radiusCm,
    required this.deltaCoeff,
    required this.slowMo,
    required this.scale,
  });

  @override
  State<ClosedPipeWaterBoard> createState() => _ClosedPipeWaterBoardState();
}

class _ClosedPipeWaterBoardState extends State<ClosedPipeWaterBoard> {
  double? _lastTime;
  double _simTime = 0.0;
  double _cachedFreq = -1;
  double _cachedLength = -1;
  double _cachedRadius = -1;
  double _cachedCoeff = -1;

  @override
  void initState() {
    super.initState();
    _lastTime = widget.time;
    _cache();
  }

  void _cache() {
    _cachedFreq = widget.freq;
    _cachedLength = widget.length;
    _cachedRadius = widget.radiusCm;
    _cachedCoeff = widget.deltaCoeff;
  }

  @override
  void didUpdateWidget(covariant ClosedPipeWaterBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.freq != _cachedFreq ||
        widget.length != _cachedLength ||
        widget.radiusCm != _cachedRadius ||
        widget.deltaCoeff != _cachedCoeff) {
      _simTime = 0.0;
      _cache();
    }
    final t = widget.time;
    if (_lastTime == null) {
      _lastTime = t;
      return;
    }
    var wallDt = t - _lastTime!;
    if (wallDt < 0) {
      _simTime = 0.0;
      _lastTime = t;
      return;
    }
    if (wallDt > 0.2) wallDt = 1.0 / 60.0;
    if (wallDt > 0) {
      _simTime += wallDt / widget.slowMo.clamp(50.0, 5000.0);
    }
    _lastTime = t;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: ClosedPipeWaterPainter(
        simTime: _simTime,
        freq: widget.freq,
        length: widget.length,
        radiusCm: widget.radiusCm,
        deltaCoeff: widget.deltaCoeff,
        scale: widget.scale,
      ),
    );
  }
}

class ClosedPipeWaterPainter extends CustomPainter {
  final double simTime;
  final double freq;
  final double length;
  final double radiusCm;
  final double deltaCoeff;
  final double scale;

  ClosedPipeWaterPainter({
    required this.simTime,
    required this.freq,
    required this.length,
    required this.radiusCm,
    required this.deltaCoeff,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = radiusCm / 100.0;
    final dl = _deltaL(r, deltaCoeff);
    final leff = _leff(length, r, deltaCoeff);
    final lambda = _soundSpeed / freq;
    final f1 = _f1(length, r, deltaCoeff);
    final mode = _nearestClosedMode(freq, f1);
    final near = mode != null;

    final tubeW = (28.0 + radiusCm * 10.0).clamp(36.0, 56.0) * 5.0;
    final cx = w * 0.5;
    final tubeLeft = cx - tubeW / 2;
    final tubeRight = cx + tubeW / 2;

    final openY = h * 0.18;
    final tubeBottom = h * 0.90;
    final maxAirPx = tubeBottom - openY - 8;
    final Lmax = 0.70;
    final airPx = (length / Lmax) * maxAirPx;
    final waterY = openY + airPx;
    final dlPx = (dl / Lmax) * maxAirPx;
    final virtY = openY - dlPx;

    _drawHatchedWater(
      canvas,
      Rect.fromLTRB(tubeLeft, waterY, tubeRight, tubeBottom),
    );

    // Glass tube
    final glass = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawLine(Offset(tubeLeft, openY), Offset(tubeLeft, tubeBottom), glass);
    canvas.drawLine(
        Offset(tubeRight, openY), Offset(tubeRight, tubeBottom), glass);
    canvas.drawLine(
        Offset(tubeLeft, tubeBottom), Offset(tubeRight, tubeBottom), glass);

    // Water surface
    canvas.drawLine(
      Offset(tubeLeft + 1, waterY),
      Offset(tubeRight - 1, waterY),
      Paint()
        ..color = const Color(0xFF1565C0)
        ..strokeWidth = 2,
    );

    // Δl dashed tube extension
    final dashPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    _drawDashedLine(canvas, Offset(tubeLeft, virtY), Offset(tubeLeft, openY), dashPaint);
    _drawDashedLine(
        canvas, Offset(tubeRight, virtY), Offset(tubeRight, openY), dashPaint);
    _drawDashedLine(
        canvas, Offset(tubeLeft, virtY), Offset(tubeRight, virtY), dashPaint);

    // Speaker / driver above opening
    final sp = Rect.fromCenter(
      center: Offset(cx, openY - dlPx - 22),
      width: 34,
      height: 18,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(sp, const Radius.circular(3)),
      Paint()..color = const Color(0xFF546E7A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(sp, const Radius.circular(3)),
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawCircle(
      Offset(cx, openY - 4),
      4,
      Paint()..color = const Color(0xFFFF8A65),
    );

    _drawLabel(canvas, Offset(cx + 24, openY - dlPx - 30),
        '${freq.toStringAsFixed(0)} Hz');
    _drawLabel(canvas, Offset(cx + 24, openY - dlPx - 16), '音源（圧力駆動）');

    // 開口から入射し、水面で固定端反射・開口で自由端反射する多重反射
    final waveAmp = (16.0 / 3.0) * scale;
    final wavePaint = Paint()
      ..color = near ? const Color(0xFFE65100) : const Color(0xFFC62828)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final dashWave = Paint()
      ..color = near
          ? const Color(0xFFE65100).withValues(alpha: 0.85)
          : const Color(0xFFC62828).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final inside = Path();
    final outside = Path();
    const nPts = 80;
    Offset? lastInside;
    var startedOut = false;
    var xiTop = 0.0;
    for (var i = 0; i <= nPts; i++) {
      final tt = i / nPts;
      final xPhys = tt * leff;
      final yPix = waterY - tt * (waterY - virtY);
      final xi = waveAmp * _displacement(xPhys, simTime, leff, freq);
      final px = cx + xi;
      if (i == nPts) xiTop = xi;
      if (yPix >= openY - 0.5) {
        if (i == 0) {
          inside.moveTo(px, yPix);
        } else {
          inside.lineTo(px, yPix);
        }
        lastInside = Offset(px, yPix);
      } else {
        if (!startedOut) {
          if (lastInside != null) outside.moveTo(lastInside.dx, lastInside.dy);
          outside.lineTo(px, yPix);
          startedOut = true;
        } else {
          outside.lineTo(px, yPix);
        }
      }
    }
    canvas.drawPath(inside, wavePaint);
    _drawDashedPath(canvas, outside, dashWave);

    canvas.drawCircle(Offset(cx, waterY), 3, Paint()..color = Colors.black87);
    canvas.drawCircle(
        Offset(cx + xiTop, virtY), 3, Paint()..color = const Color(0xFFE65100));

    // Dimension labels
    _drawVDim(
      canvas,
      tubeRight + 10,
      waterY,
      openY,
      'L = ${(length * 100).toStringAsFixed(1)} cm',
    );
    _drawVDim(
      canvas,
      tubeRight + 10,
      openY,
      virtY,
      'Δl = ${(dl * 100).toStringAsFixed(2)} cm',
    );

    _drawLabel(canvas, Offset(tubeLeft - 18, waterY - 4), '節');
    _drawLabel(canvas, Offset(tubeLeft - 18, virtY - 4), '腹');
    _drawLabel(canvas, Offset(tubeLeft - 4, (openY + waterY) / 2), '気柱');
    _drawLabel(canvas, Offset(tubeLeft + 6, (waterY + tubeBottom) / 2), '水');

    final info =
        'λ=${lambda.toStringAsFixed(3)} m  '
        'λ/4=${(lambda / 4 * 100).toStringAsFixed(1)} cm  '
        '${near ? '第$mode 共鳴' : ''}';
    final tp = TextPainter(
      text: TextSpan(
        text: info,
        style: TextStyle(
          fontSize: 11,
          color: near ? Colors.deepOrange : Colors.black54,
          fontWeight: near ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w - 24);
    tp.paint(canvas, Offset(w - tp.width - 12, 8));
  }

  double _drive(double tau, double freq) {
    if (tau < 0) return 0.0;
    return math.sin(2 * math.pi * freq * tau);
  }

  /// x=0 水面（固定端）、x=Leff 仮想開口（自由端）。開口から入射。
  double _displacement(double x, double t, double leff, double freq) {
    final v = _soundSpeed;
    if (t <= 0 || v <= 0 || leff <= 0) return 0.0;
    final roundTrip = 2 * leff / v;
    final gamma = math.log(2) / (3.0 * roundTrip);
    final maxN = math.min(40, (v * t / (2 * leff)).floor() + 1);
    var y = 0.0;
    for (var n = 0; n <= maxN; n++) {
      final sign = (n % 2 == 0) ? 1.0 : -1.0;
      final delayDown = ((2 * n + 1) * leff - x) / v;
      final delayUp = ((2 * n + 1) * leff + x) / v;
      y += sign * math.exp(-gamma * delayDown) * _drive(t - delayDown, freq);
      y -= sign * math.exp(-gamma * delayUp) * _drive(t - delayUp, freq);
    }
    return y;
  }

  void _drawHatchedWater(Canvas canvas, Rect rect) {
    canvas.drawRect(rect, Paint()..color = const Color(0xFFBBDEFB));
    canvas.save();
    canvas.clipRect(rect);
    final hatch = Paint()
      ..color = const Color(0xFF64B5F6)
      ..strokeWidth = 1.0;
    const step = 7.0;
    for (var x = rect.left - rect.height; x < rect.right; x += step) {
      canvas.drawLine(
        Offset(x, rect.top),
        Offset(x + rect.height, rect.bottom),
        hatch,
      );
    }
    canvas.restore();
    canvas.drawRect(
      rect,
      Paint()
        ..color = const Color(0xFF1565C0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy);
    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      const dash = 4.0;
      const gap = 3.0;
      while (d < metric.length) {
        final next = math.min(d + dash, metric.length);
        canvas.drawPath(metric.extractPath(d, next), paint);
        d = next + gap;
      }
    }
  }

  void _drawVDim(Canvas canvas, double x, double y0, double y1, String text) {
    final top = math.min(y0, y1);
    final bot = math.max(y0, y1);
    final p = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1;
    canvas.drawLine(Offset(x, top), Offset(x, bot), p);
    canvas.drawLine(Offset(x - 3, top), Offset(x + 3, top), p);
    canvas.drawLine(Offset(x - 3, bot), Offset(x + 3, bot), p);
    _drawLabel(canvas, Offset(x + 6, (top + bot) / 2 - 6), text);
  }

  void _drawLabel(Canvas canvas, Offset pos, String text) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 11, color: Colors.black87),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant ClosedPipeWaterPainter oldDelegate) => true;
}

class _ClosedPipeToneControl extends StatefulWidget {
  final double freq;
  final double f1;

  const _ClosedPipeToneControl({
    super.key,
    required this.freq,
    required this.f1,
  });

  @override
  State<_ClosedPipeToneControl> createState() => _ClosedPipeToneControlState();
}

class _ClosedPipeToneControlState extends State<_ClosedPipeToneControl> {
  static const int _sampleRate = 22050;
  static const int _durationSec = 600;

  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _on = false;
  bool _ready = false;
  int _gen = 0;
  double _playingFreq = -1;
  Timer? _freqDebounce;

  @override
  void didUpdateWidget(covariant _ClosedPipeToneControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_on) return;
    _applyVolume();
    if ((widget.freq - _playingFreq).abs() < 0.25) return;
    _freqDebounce?.cancel();
    _freqDebounce = Timer(const Duration(milliseconds: 140), () {
      if (mounted && _on) _startTone();
    });
  }

  @override
  void dispose() {
    _freqDebounce?.cancel();
    _on = false;
    _gen++;
    final player = _player;
    player.stopPlayer().then((_) => player.closePlayer()).catchError((_) {});
    super.dispose();
  }

  Future<void> _ensureOpen() async {
    if (_ready) return;
    await _player.openPlayer();
    _ready = true;
  }

  double _volume() => _toneVolume(widget.freq, widget.f1);

  Future<void> _applyVolume() async {
    if (!_ready || !_on) return;
    try {
      await _player.setVolume(_volume());
    } catch (_) {}
  }

  /// 周期数を整数にして、始点・終点がゼロ交差になる正弦波（約4分）
  Uint8List _sine(double freq) {
    final cycles = math.max(1, (freq * _durationSec).round());
    final n = math.max(_sampleRate, (cycles * _sampleRate / freq).round());
    final fade = 900;
    final buf = Int16List(n);
    final step = 2 * math.pi * freq / _sampleRate;
    var phase = 0.0;
    for (var i = 0; i < n; i++) {
      var env = 1.0;
      if (i < fade) env = i / fade;
      buf[i] = (math.sin(phase) * env * 0.38 * 32767).toInt();
      phase += step;
    }
    return Uint8List.view(buf.buffer);
  }

  Future<void> _startTone() async {
    final gen = ++_gen;
    try {
      await _ensureOpen();
      if (!mounted || !_on || gen != _gen) return;
      if (_player.isPlaying) {
        await _player.stopPlayer();
      }
      if (!mounted || !_on || gen != _gen) return;
      _playingFreq = widget.freq;
      await _player.setVolume(_volume());
      if (!mounted || !_on || gen != _gen) return;
      await _player.startPlayer(
        fromDataBuffer: _sine(widget.freq),
        codec: Codec.pcm16,
        sampleRate: _sampleRate,
        numChannels: 1,
        whenFinished: () {
          if (mounted && _on && gen == _gen) _startTone();
        },
      );
    } catch (_) {}
  }

  Future<void> _stopTone() async {
    _gen++;
    _playingFreq = -1;
    _freqDebounce?.cancel();
    try {
      if (_ready && _player.isPlaying) {
        await _player.stopPlayer();
      }
    } catch (_) {}
  }

  Future<void> _setOn(bool on) async {
    setState(() => _on = on);
    if (on) {
      await _startTone();
    } else {
      await _stopTone();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '音も出す',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(
          _on ? '共鳴付近で少し大きくなります' : '',
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
        const Spacer(),
        Switch.adaptive(
          value: _on,
          onChanged: _setOn,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}
