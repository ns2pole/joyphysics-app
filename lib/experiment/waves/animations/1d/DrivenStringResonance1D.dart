import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../widgets/wave_slider.dart';

final drivenStringResonance1D = createWaveVideo(
  title: "駆動弦の定在波（反射の積み上がり）",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>左端はバイブレータによる<strong>駆動</strong>（$y(0,t)=g(t)$）、右端は<strong>固定端</strong>（$y(L)=0$）です。</p>
  <p>進行波の多重反射の合成（$g(\tau)=A\sin(2\pi\tau/T)$、$\tau&lt;0$ では $0$）：</p>
  <p>
  $$y=\sum_{n=0}\Big[
  g\!\left(t-\frac{2nL+x}{v}\right)
  -g\!\left(t-\frac{2(n+1)L-x}{v}\right)
  \Big]$$
  </p>
  <p>右端固定のたびに符号が反転し、左端では駆動条件を満たす次の右向き波が足されます。共振は $f\approx n\,v/(2L)$（$f/f_1\approx 1,2,3,\ldots$）です。</p>
  """,
  simulation: DrivenStringResonance1DSimulation(),
  height: 720,
);

/// f/f₁ が整数からどれだけ近いとき「共振付近」とみなすか／そこにスナップするか
const double _resonanceTol = 0.01;

/// 線密度 ρ [kg/m] の5段階（細い→太い）
const List<double> _rhoLevels = [0.0004, 0.0008, 0.0015, 0.0030, 0.0060];

double _waveSpeed(double tension, double rho) => math.sqrt(tension / rho);

double _fundamentalFreq(double tension, double rho, double length) =>
    _waveSpeed(tension, rho) / (2 * length);

/// |f/f₁ − n| < tol なら整数モード n、否则 null
int? _nearestResonanceMode(double ratio) {
  if (ratio < 0.5) return null;
  final n = ratio.round();
  if (n < 1) return null;
  if ((ratio - n).abs() < _resonanceTol) return n;
  return null;
}

class DrivenStringResonance1DSimulation extends WaveSimulation {
  DrivenStringResonance1DSimulation()
      : super(
          title: "駆動弦の定在波（反射の積み上がり）",
          is3D: false,
          showTimeOverlay: false,
          formula: const Column(
            children: [
              FormulaDisplay(
                  r'g(\tau)=A\sin(2\pi\tau/T)\ (\tau\ge0)'),
              SizedBox(height: 4),
              FormulaDisplay(
                  r'y=\sum_n\big[g(t-\tfrac{2nL+x}{v})-g(t-\tfrac{2(n+1)L-x}{v})\big]'),
            ],
          ),
        );

  @override
  Map<String, double> get initialParameters => {
        // L=0.70 m, T=50 N, ρ=0.0015 → v≈183 m/s, f₁≈131 Hz
        // f=262 ≈ 2 f₁ → λ≈L（弦長と同程度）
        'freq': 262.0,
        'length': 0.70,
        'tension': 50.0,
        'rhoLevel': 3.0,
        'slowMo': 25.0,
      };

  @override
  List<Widget> buildControls(context, params, updateParam) {
    final rhoIdx = params['rhoLevel']!.round().clamp(1, 5);
    final rho = _rhoLevels[rhoIdx - 1];
    final tension = params['tension']!;
    final L = params['length']!;
    final f = params['freq']!;
    final v = _waveSpeed(tension, rho);
    final lambda = v / f;
    final f1 = _fundamentalFreq(tension, rho, L);
    final ratio = f / f1;
    final nearResonance = _nearestResonanceMode(ratio) != null;
    final slowMo = params['slowMo']!;

    void setFreqSnapped(double raw) {
      final mode = _nearestResonanceMode(raw / f1);
      if (mode != null) {
        updateParam('freq', (mode * f1).clamp(80.0, 500.0));
      } else {
        updateParam('freq', raw);
      }
    }

    void setLengthSnapped(double raw) {
      final mode = _nearestResonanceMode(f * 2 * raw / v);
      if (mode != null) {
        final snapped = (mode * v / (2 * f)).clamp(0.40, 1.00);
        updateParam('length', snapped);
      } else {
        updateParam('length', raw);
      }
    }

    void setTensionSnapped(double raw) {
      final vRaw = _waveSpeed(raw, rho);
      final mode = _nearestResonanceMode(f / (vRaw / (2 * L)));
      if (mode != null) {
        final vSnap = f * 2 * L / mode;
        final snapped = (rho * vSnap * vSnap).clamp(10.0, 100.0);
        updateParam('tension', snapped);
      } else {
        updateParam('tension', raw);
      }
    }

    void setRhoSnapped(int level) {
      updateParam('rhoLevel', level.toDouble());
      final newRho = _rhoLevels[level - 1];
      final newF1 = _fundamentalFreq(tension, newRho, L);
      final ratio = f / newF1;
      // ρは離散なので、一番近い整数モードの共振周波数へ寄せる
      final mode =
          _nearestResonanceMode(ratio) ?? ratio.round().clamp(1, 20).toInt();
      updateParam('freq', (mode * newF1).clamp(80.0, 500.0));
    }

    return [
      Text(
        'v = ${v.toStringAsFixed(0)} m/s   '
        'λ = ${lambda.toStringAsFixed(3)} m   '
        'λ/L = ${(lambda / L).toStringAsFixed(2)}\n'
        'f₁ = ${f1.toStringAsFixed(0)} Hz   '
        'f/f₁ = ${ratio.toStringAsFixed(2)}'
        '${nearResonance ? '  ★共振' : ''}   '
        '（×${slowMo.toStringAsFixed(0)} スロー）',
        style: TextStyle(
          fontSize: 12,
          fontWeight: nearResonance ? FontWeight.bold : FontWeight.normal,
          color: nearResonance ? Colors.deepOrange : null,
          height: 1.35,
        ),
      ),
      WaveParameterSlider(
        label: 'f[Hz]',
        value: params['freq']!,
        min: 80.0,
        max: 500.0,
        onChanged: setFreqSnapped,
      ),
      WaveParameterSlider(
        label: 'L[m]',
        value: params['length']!,
        min: 0.40,
        max: 1.00,
        onChanged: setLengthSnapped,
      ),
      WaveParameterSlider(
        label: 'T[N]',
        value: params['tension']!,
        min: 10.0,
        max: 100.0,
        onChanged: setTensionSnapped,
      ),
      WaveParameterSlider(
        label: 'スロー',
        value: params['slowMo']!,
        min: 5.0,
        max: 500.0,
        onChanged: (val) => updateParam('slowMo', val),
      ),
      const SizedBox(height: 4),
      const Text('糸の太さ ρ（細い→太い）',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      Wrap(
        spacing: 4,
        children: List.generate(5, (i) {
          final level = i + 1;
          return ChoiceChip(
            label: Text('$level', style: const TextStyle(fontSize: 12)),
            selected: rhoIdx == level,
            onSelected: (_) => setRhoSnapped(level),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            labelPadding: const EdgeInsets.symmetric(horizontal: 6),
            visualDensity: VisualDensity.compact,
          );
        }),
      ),
    ];
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    return DrivenStringBoard(
      time: time,
      freq: params['freq']!,
      length: params['length']!,
      tension: params['tension']!,
      rhoLevel: params['rhoLevel']!.round().clamp(1, 5),
      slowMo: params['slowMo']!,
      scale: scale,
    );
  }
}

class DrivenStringBoard extends StatefulWidget {
  final double time;
  final double freq;
  final double length;
  final double tension;
  final int rhoLevel;
  final double slowMo;
  final double scale;

  const DrivenStringBoard({
    super.key,
    required this.time,
    required this.freq,
    required this.length,
    required this.tension,
    required this.rhoLevel,
    required this.slowMo,
    required this.scale,
  });

  @override
  State<DrivenStringBoard> createState() => _DrivenStringBoardState();
}

class _DrivenStringBoardState extends State<DrivenStringBoard> {
  static const int nPoints = 200;
  /// 駆動端の振幅（小さくして左端をほぼ固定端に見せる）
  static const double amplitude = 0.18;
  /// 画面上の振幅スケール基準（共振で育った波が見えるよう駆動より大きめ）
  static const double visualRefAmp = 0.55;
  static const int maxBounces = 40;

  final List<double> _y = List<double>.filled(nPoints, 0.0);
  double? _lastTime;
  double _simTime = 0.0;

  double _cachedFreq = -1;
  double _cachedLength = -1;
  double _cachedTension = -1;
  int _cachedRho = -1;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void didUpdateWidget(covariant DrivenStringBoard oldWidget) {
    super.didUpdateWidget(oldWidget);

    final paramsChanged = widget.freq != _cachedFreq ||
        widget.length != _cachedLength ||
        widget.tension != _cachedTension ||
        widget.rhoLevel != _cachedRho;

    if (paramsChanged) {
      _reset();
    }

    final t = widget.time;
    if (_lastTime == null) {
      _lastTime = t;
      _rebuildProfile();
      return;
    }

    var wallDt = t - _lastTime!;
    if (wallDt < 0) {
      _reset();
      _lastTime = t;
      _rebuildProfile();
      return;
    }
    if (wallDt > 0.2) {
      wallDt = 1.0 / 60.0;
    }
    if (wallDt > 0) {
      final slowMo = widget.slowMo.clamp(5.0, 500.0);
      _simTime += wallDt / slowMo;
      _rebuildProfile();
    }
    _lastTime = t;
  }

  void _reset() {
    _simTime = 0.0;
    _lastTime = null;
    _cachedFreq = widget.freq;
    _cachedLength = widget.length;
    _cachedTension = widget.tension;
    _cachedRho = widget.rhoLevel;
    for (var i = 0; i < nPoints; i++) {
      _y[i] = 0.0;
    }
  }

  double get _rho => _rhoLevels[widget.rhoLevel - 1];
  double get _v => math.sqrt(widget.tension / _rho);
  double get _lambda => _v / widget.freq;
  double get _period => 1.0 / widget.freq;

  double _g(double tau) {
    if (tau < 0) return 0.0;
    return amplitude * math.sin(2 * math.pi * tau / _period);
  }

  /// 経路減衰 [1/s]。往復を何度も足しても発散しない程度。
  double get _pathGamma {
    final roundTrip = 2 * widget.length / _v;
    // だいたい数往復で半減するくらい
    return math.log(2) / (3.0 * roundTrip);
  }

  /// 駆動端 A（y(0)=g）＋固定端 B（y(L)=0）の多重反射合成。
  /// y = Σ_n [ g(t-(2nL+x)/v) − g(t-(2(n+1)L−x)/v) ]
  /// ※ 両端固定の自由振動用 (-1)^n を付けると共振が f/f₁ = 1.5, 2.5, … にずれる。
  void _rebuildProfile() {
    final L = widget.length;
    final v = _v;
    final t = _simTime;
    final gamma = _pathGamma;

    final maxN = t <= 0
        ? 0
        : math.min(maxBounces, (v * t / (2 * L)).floor() + 1);

    for (var i = 0; i < nPoints; i++) {
      final x = L * i / (nPoints - 1);
      var y = 0.0;

      for (var n = 0; n <= maxN; n++) {
        final delayR = (2 * n * L + x) / v;
        y += math.exp(-gamma * delayR) * _g(t - delayR);

        final delayL = (2 * (n + 1) * L - x) / v;
        y += -math.exp(-gamma * delayL) * _g(t - delayL);
      }

      _y[i] = y;
    }
  }

  @override
  Widget build(BuildContext context) {
    final f1 = _v / (2 * widget.length);
    final ratio = widget.freq / f1;
    final nearResonance = _nearestResonanceMode(ratio) != null;

    return CustomPaint(
      size: Size.infinite,
      painter: DrivenStringApparatusPainter(
        y: _y,
        length: widget.length,
        freq: widget.freq,
        tension: widget.tension,
        rhoLevel: widget.rhoLevel,
        simTime: _simTime,
        amplitude: amplitude,
        visualRefAmp: visualRefAmp,
        scale: widget.scale,
        nearResonance: nearResonance,
        waveSpeed: _v,
        lambda: _lambda,
      ),
    );
  }
}

class DrivenStringApparatusPainter extends CustomPainter {
  final List<double> y;
  final double length;
  final double freq;
  final double tension;
  final int rhoLevel;
  final double simTime;
  final double amplitude;
  final double visualRefAmp;
  final double scale;
  final bool nearResonance;
  final double waveSpeed;
  final double lambda;

  DrivenStringApparatusPainter({
    required this.y,
    required this.length,
    required this.freq,
    required this.tension,
    required this.rhoLevel,
    required this.simTime,
    required this.amplitude,
    required this.visualRefAmp,
    required this.scale,
    required this.nearResonance,
    required this.waveSpeed,
    required this.lambda,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final leftPad = w * 0.06;
    final rightPad = w * 0.22;
    final stringY = h * 0.38;
    final ampScale = h * 0.045 * scale;

    final Lnorm = ((length - 0.40) / 0.60).clamp(0.0, 1.0);
    final maxStringW = w - leftPad - rightPad - w * 0.14;
    final minStringW = maxStringW * 0.45;
    final stringW = minStringW + (maxStringW - minStringW) * Lnorm;

    final aX = leftPad + w * 0.12;
    final pulleyR = 16.0;
    // 弦は滑車の「上」に乗り、右端から下がる（中心に3本が集まらない）
    final bX = aX + stringW;
    final pulleyCenter = Offset(bX, stringY + pulleyR);
    final hangX = pulleyCenter.dx + pulleyR;

    final floorY = h * 0.88;
    final personX = hangX + 28;
    final personFeet = Offset(personX, floorY);

    final tensionNorm = ((tension - 10.0) / 90.0).clamp(0.0, 1.0);
    final handY = stringY + pulleyR * 2 + 24 + tensionNorm * 18;

    // 台は滑車半径分下げ、弦は台上に浮く。滑車は角から上・右へ出っ張る
    final benchTop = stringY + pulleyR;
    final benchLeft = aX - 48;
    final benchRight = bX;
    final benchBottom = math.min(floorY - 8, stringY + h * 0.28);
    _drawHatchedBench(
      canvas,
      Rect.fromLTRB(benchLeft, benchTop, benchRight, benchBottom),
    );

    final vibBody = Rect.fromCenter(
      center: Offset(aX - 28, stringY),
      width: 36,
      height: 48,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(vibBody, const Radius.circular(4)),
      Paint()..color = const Color(0xFF546E7A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(vibBody, const Radius.circular(4)),
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final period = 1.0 / freq;
    final driveY = amplitude * math.sin(2 * math.pi * simTime / period);
    final headCenter =
        Offset(aX, stringY - (driveY / visualRefAmp) * ampScale * 0.3);
    canvas.drawCircle(headCenter, 7, Paint()..color = const Color(0xFFFF8A65));
    canvas.drawCircle(
      headCenter,
      7,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    _drawLabel(canvas, Offset(aX - 36, stringY - 58), '${freq.toStringAsFixed(0)} Hz');
    _drawLabel(canvas, Offset(aX - 28, stringY - 42), 'バイブレータ');

    final strokeW = 1.5 + rhoLevel * 0.7;
    final stringPaint = Paint()
      ..color = nearResonance ? const Color(0xFFE65100) : const Color(0xFF1565C0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (var i = 0; i < y.length; i++) {
      final tt = i / (y.length - 1);
      final x = aX + tt * (bX - aX);
      final yy = stringY - (y[i] / visualRefAmp) * ampScale * 0.45;
      if (i == 0) {
        path.moveTo(x, yy);
      } else {
        path.lineTo(x, yy);
      }
    }
    canvas.drawPath(path, stringPaint);

    canvas.drawLine(
      Offset(aX, stringY),
      Offset(bX, stringY),
      Paint()
        ..color = Colors.black12
        ..strokeWidth = 1,
    );

    _drawLabel(canvas, Offset(aX + 4, stringY + 22), 'A');
    _drawLabel(
      canvas,
      Offset((aX + bX) / 2 - 28, stringY + 26),
      'L = ${length.toStringAsFixed(2)} m',
    );
    _drawLabel(canvas, Offset(bX - 18, stringY - 18), 'B');

    // 台の右上角に定滑車。弦は12時で乗り、右（3時）から下がる
    canvas.drawCircle(pulleyCenter, pulleyR, Paint()..color = Colors.white);
    canvas.drawCircle(
      pulleyCenter,
      pulleyR,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      pulleyCenter,
      pulleyR * 0.32,
      Paint()..color = const Color(0xFFF7F7F7),
    );
    canvas.drawCircle(
      pulleyCenter,
      pulleyR * 0.32,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    canvas.drawCircle(pulleyCenter, 2.2, Paint()..color = Colors.black87);
    _drawLabel(
        canvas, Offset(pulleyCenter.dx + pulleyR + 6, stringY - 36), '定滑車');

    final pulleyStringPaint = Paint()
      ..color = const Color(0xFF1565C0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final wrap = Path()
      ..addArc(
        Rect.fromCircle(center: pulleyCenter, radius: pulleyR),
        -math.pi / 2,
        math.pi / 2,
      );
    canvas.drawPath(wrap, pulleyStringPaint);

    final handPos = Offset(hangX, handY + 36);
    canvas.drawLine(
      Offset(hangX, pulleyCenter.dy),
      handPos,
      pulleyStringPaint,
    );

    _drawStickPerson(
      canvas,
      feet: personFeet,
      handTarget: handPos,
      pullHard: tensionNorm,
    );
    _drawLabel(
      canvas,
      Offset(personX - 8, floorY + 6),
      'T = ${tension.toStringAsFixed(0)} N',
    );

    final info =
        't=${simTime < 0.1 ? '${(simTime * 1000).toStringAsFixed(1)} ms' : '${simTime.toStringAsFixed(3)} s'}  '
        'v=${waveSpeed.toStringAsFixed(0)} m/s  λ=${lambda.toStringAsFixed(3)} m  '
        'λ/L=${(lambda / length).toStringAsFixed(2)}'
        '${nearResonance ? '  共振' : ''}';
    final tp = TextPainter(
      text: TextSpan(
        text: info,
        style: TextStyle(
          fontSize: 11,
          color: nearResonance ? Colors.deepOrange : Colors.black54,
          fontWeight: nearResonance ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w - 24);
    tp.paint(canvas, Offset(w - tp.width - 12, 8));
  }

  void _drawHatchedBench(Canvas canvas, Rect rect) {
    canvas.drawRect(rect, Paint()..color = const Color(0xFFF7F7F7));
    canvas.save();
    canvas.clipRect(rect);
    final hatch = Paint()
      ..color = const Color(0xFF9E9E9E)
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
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
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

  void _drawStickPerson(
    Canvas canvas, {
    required Offset feet,
    required Offset handTarget,
    required double pullHard,
  }) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final lean = 6.0 + pullHard * 10.0;
    const height = 70.0;
    final head = Offset(feet.dx - lean * 0.3, feet.dy - height);
    final shoulder = Offset(feet.dx - lean * 0.2, feet.dy - height * 0.78);
    final waist = Offset(feet.dx, feet.dy - height * 0.38);

    canvas.drawCircle(Offset(head.dx, head.dy - 8), 10, paint);
    canvas.drawLine(head, waist, paint);
    canvas.drawLine(waist, Offset(feet.dx - 12, feet.dy), paint);
    canvas.drawLine(waist, Offset(feet.dx + 14, feet.dy), paint);
    canvas.drawLine(shoulder, handTarget, paint);
    canvas.drawLine(
      shoulder,
      Offset(shoulder.dx + 18, shoulder.dy + 22),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant DrivenStringApparatusPainter oldDelegate) => true;
}
