import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../fields/wave_fields.dart';
import '../painters/wave_line_painter.dart';
import '../widgets/wave_slider.dart';

final waveEquation1D = createWaveVideo(
  title: "波の式",
  latex: r"""
  <div class="common-box">波の式</div>
  <p>振幅 $A$、周期 $T$、波長 $\lambda$、初期位相 $\phi$ の正弦波が $x$ 軸の正の向きに進むとき、時刻 $t$、位置 $x$ における媒質の変位 $y$ は次のように表されます。</p>
  <p>$$y(x, t) = A \sin\left\{ 2\pi \left( \frac{t}{T} - \frac{x}{\lambda} \right) + \phi \right\}$$</p>
  <p>上側のグラフは時刻 $t$ を固定したときの波の形（$y-x$ グラフ）、下側のグラフは場所 $x=a$ を固定したときの媒質の時間変化（$y-t$ グラフ）を表しています。</p>
  """,
  simulation: WaveEquationSimulation(),
);

class WaveEquationSimulation extends PhysicsSimulation {
  WaveEquationSimulation()
      : super(
          title: "波の式",
          formula: const Column(
            children: [
              FormulaDisplay(r'y = A \sin\left\{ 2\pi \left( \frac{t}{T} - \frac{x}{\lambda} \right) + \phi \right\}'),
            ],
          ),
        );

  @override
  Map<String, double> get initialParameters => {
        'amplitude': 0.6,
        'initialPhase': 0.0,
        'lambda': 4.0,
        'periodT': 2.0,
        'positionA': 0.0,
      };

  @override
  List<Widget> buildControls(context, params, updateParam) {
    return [
      WaveParameterSlider(
        label: '振幅 A',
        value: params['amplitude']!,
        min: 0.1,
        max: 1.0,
        onChanged: (v) => updateParam('amplitude', v),
      ),
      WaveParameterSlider(
        label: '波長 λ',
        value: params['lambda']!,
        min: 1.0,
        max: 8.0,
        onChanged: (v) => updateParam('lambda', v),
      ),
      WaveParameterSlider(
        label: '周期 T',
        value: params['periodT']!,
        min: 0.5,
        max: 5.0,
        onChanged: (v) => updateParam('periodT', v),
      ),
      WaveParameterSlider(
        label: '初期位相 φ',
        value: params['initialPhase']!,
        min: 0.0,
        max: 2 * math.pi,
        onChanged: (v) => updateParam('initialPhase', v),
      ),
      WaveParameterSlider(
        label: '場所 a',
        value: params['positionA']!,
        min: -5.0,
        max: 5.0,
        onChanged: (v) => updateParam('positionA', v),
      ),
    ];
  }

  @override
  Widget buildAnimation(context, time, azimuth, tilt, scale, params, activeIds) {
    final field = WaveEquationField(
      amplitude: params['amplitude']!,
      lambda: params['lambda']!,
      periodT: params['periodT']!,
      initialPhase: params['initialPhase']!,
    );

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: WaveLinePainter(
                  time: time,
                  field: field,
                  surfaceColor: Colors.blue,
                  showTicks: true,
                  scale: scale,
                  markers: [
                    WaveMarker(point: math.Point(params['positionA']!, 0.0), color: Colors.red),
                  ],
                ),
              ),
              CustomPaint(
                size: Size.infinite,
                painter: PositionIndicatorPainter(
                  positionA: params['positionA']!,
                  scale: scale,
                ),
              ),
              Positioned(
                top: 5,
                left: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  color: Colors.white70,
                  child: const Text('y-x グラフ (時刻 t での波の形)', 
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.black26),
        Expanded(
          child: Stack(
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: WaveTimePainter(
                  currentTime: time,
                  positionA: params['positionA']!,
                  field: field,
                  scale: scale,
                ),
              ),
              Positioned(
                top: 5,
                left: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  color: Colors.white70,
                  child: const Text('y-t グラフ (場所 x=a での媒質の動き)', 
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class WaveEquationField extends WaveField {
  final double amplitude;
  final double lambda;
  final double periodT;
  final double initialPhase;

  WaveEquationField({
    required this.amplitude,
    required this.lambda,
    required this.periodT,
    required this.initialPhase,
  });

  @override
  double phase(double x, double y, double t) {
    return 2 * math.pi * (t / periodT - x / lambda) + initialPhase;
  }

  @override
  double z(double x, double y, double t) => amplitude * math.sin(phase(x, y, t));

  @override
  bool operator ==(Object other) =>
      other is WaveEquationField &&
      other.amplitude == amplitude &&
      other.lambda == lambda &&
      other.periodT == periodT &&
      other.initialPhase == initialPhase;

  @override
  int get hashCode => Object.hash(amplitude, lambda, periodT, initialPhase);
}

class PositionIndicatorPainter extends CustomPainter {
  final double positionA;
  final double scale;
  PositionIndicatorPainter({required this.positionA, this.scale = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double unitScale = (size.width / 12) * scale;
    final xPos = center.dx + positionA * unitScale;
    
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(Offset(xPos, 0), Offset(xPos, size.height), paint);
    
    final textPainter = TextPainter(
      text: const TextSpan(text: 'x=a', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(xPos + 5, 20));
  }

  @override
  bool shouldRepaint(PositionIndicatorPainter oldDelegate) => 
    oldDelegate.positionA != positionA || oldDelegate.scale != scale;
}

class WaveTimePainter extends CustomPainter {
  final double currentTime;
  final double positionA;
  final WaveEquationField field;
  final double scale;

  WaveTimePainter({
    required this.currentTime,
    required this.positionA,
    required this.field,
    this.scale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFF7F7FB));

    final center = Offset(size.width / 2, size.height / 2);
    const double timeRange = 4.0; // グラフ全体の時間幅
    final double timeScale = (size.width / timeRange) * scale;

    Offset timeToScreen(double t, double y) {
      // 現在時刻 currentTime が中心 (size.width / 2) にくるように配置
      return Offset(size.width / 2 - (currentTime - t) * timeScale, center.dy - y * (size.height / 4) * scale);
    }

    final axisPaint = Paint()..color = Colors.black45..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), axisPaint);
    // t軸（垂直線）を中心（現在時刻）に引く
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), axisPaint);

    // 目盛り (過去から現在まで、および未来の余白部分)
    for (double t = (currentTime - timeRange).floorToDouble(); t <= currentTime + timeRange / 2; t += 1.0) {
      final p = timeToScreen(t, 0);
      if (p.dx < 0 || p.dx > size.width) continue;

      canvas.drawLine(Offset(p.dx, center.dy - 5), Offset(p.dx, center.dy + 5), axisPaint);
      final tp = TextPainter(
        text: TextSpan(text: t.toStringAsFixed(0), style: const TextStyle(color: Colors.black54, fontSize: 10)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(p.dx - 5, center.dy + 7));
    }

    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const int samples = 100;
    bool started = false;

    // 過去の時間（左端から中心まで）のみ描画
    for (int i = 0; i <= samples; i++) {
      // 左端は currentTime - 2.0 (timeRange / 2)
      final t = currentTime - (timeRange / 2 * (samples - i) / samples);
      final y = field.z(positionA, 0, t);
      final p = timeToScreen(t, y);
      if (!started) {
        path.moveTo(p.dx, p.dy);
        started = true;
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(path, paint);
    
    // 現在の点
    final currentY = field.z(positionA, 0, currentTime);
    final currentP = timeToScreen(currentTime, currentY);
    canvas.drawCircle(currentP, 5, Paint()..color = Colors.red);

    // 未来側（右半分）に「未来」であることを示すラベルを薄く表示
    final futureSpan = TextSpan(
      text: 'Future',
      style: TextStyle(color: Colors.black12, fontSize: 24, fontWeight: FontWeight.bold),
    );
    final futureTp = TextPainter(text: futureSpan, textDirection: TextDirection.ltr)..layout();
    futureTp.paint(canvas, Offset(size.width * 0.75 - futureTp.width / 2, center.dy - futureTp.height / 2));
  }

  @override
  bool shouldRepaint(WaveTimePainter oldDelegate) => 
    oldDelegate.currentTime != currentTime || 
    oldDelegate.positionA != positionA || 
    oldDelegate.field != field ||
    oldDelegate.scale != scale;
}

