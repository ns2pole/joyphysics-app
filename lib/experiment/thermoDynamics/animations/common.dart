import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 熱力学シミュレーションで共通して使用される粒子クラス
class ThermodynamicParticle {
  Offset position; // (0.0, 0.0) to (1.0, 1.0) の相対座標
  Offset velocity;

  ThermodynamicParticle({required this.position, required this.velocity});

  void update(double dt, double speedScale) {
    Offset v = velocity * speedScale;
    // dt=0.02 を基準とした更新
    position += v * (dt / 0.02);

    // 壁との衝突判定
    if (position.dx < 0) {
      position = Offset(0, position.dy);
      velocity = Offset(-velocity.dx, velocity.dy);
    } else if (position.dx > 1.0) {
      position = Offset(1.0, position.dy);
      velocity = Offset(-velocity.dx, velocity.dy);
    }

    if (position.dy < 0) {
      position = Offset(position.dx, 0);
      velocity = Offset(velocity.dx, -velocity.dy);
    } else if (position.dy > 1.0) {
      position = Offset(position.dx, 1.0);
      velocity = Offset(velocity.dx, -velocity.dy);
    }
  }
}

/// シリンダー内の気体高さ係数（ピストン位置・ストッパー位置で共通）
const double kGasHeightFactor = 0.9;
/// ピストン上面が pistonY から上に伸びる量
const double kPistonTopExtent = 15.0;
/// ピストン下面が pistonY から下に伸びる量
const double kPistonBottomExtent = 6.0;

/// 熱力学シミュレーション用のベースGasPainter
class BaseGasPainter extends CustomPainter {
  final List<ThermodynamicParticle> particles;
  final double volume;
  final double temperature;
  final bool isHeating;
  final bool isCooling;
  final bool showHeater;
  final double heatFlux; // 正: 吸熱, 負: 放熱
  final int weights;
  final bool showTopStoppers;
  final bool showBottomStoppers;
  /// 上側ストッパーを置く体積（ピストン位置と同じスケール）。showTopStoppers 時に使用。
  final double? topStopperVolume;
  /// 下側ストッパーを置く体積。showBottomStoppers 時に使用。
  final double? bottomStopperVolume;
  final Color wallColor;
  final double wallThickness;
  final double cylinderWidthFactor; // 画面幅に対するシリンダー幅の割合
  final double cylinderHeightFactor; // 画面高さに対するシリンダー最大高さの割合
  final Offset? personFeetPos;
  final Offset? handTargetOffset; // ロッド先端へのオフセット

  BaseGasPainter({
    required this.particles,
    required this.volume,
    this.temperature = 300.0,
    this.isHeating = false,
    this.isCooling = false,
    this.showHeater = true,
    this.heatFlux = 0.0,
    this.weights = 0,
    this.showTopStoppers = false,
    this.showBottomStoppers = false,
    this.topStopperVolume,
    this.bottomStopperVolume,
    this.wallColor = Colors.grey,
    this.wallThickness = 16.0,
    this.cylinderWidthFactor = 0.35,
    this.cylinderHeightFactor = 0.85,
    this.personFeetPos,
    this.handTargetOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double cylinderWidth = size.width * cylinderWidthFactor;
    double left = (size.width - cylinderWidth) / 2;
    
    // 人がいる場合は左に寄せるなどの調整が必要だが、
    // いったん中央寄せまたは指定位置を基準にする
    if (personFeetPos != null) {
      // Isothermalのように人物がいる場合のレイアウト調整
      double gap = 40.0;
      double personWidth = 30.0;
      double totalWidth = cylinderWidth + gap + personWidth;
      left = (size.width - totalWidth) / 2;
    }
    double right = left + cylinderWidth;

    double cylinderMaxHeight = size.height * cylinderHeightFactor;
    double bottomY = size.height - 8;
    double cylinderTopY = bottomY - cylinderMaxHeight;

    // 床
    final floorPaint = Paint()..color = Colors.grey[400]!..strokeWidth = 2.0;
    canvas.drawLine(Offset(0, bottomY), Offset(size.width, bottomY), floorPaint);

    // シリンダーの壁
    final wallPaint = Paint()
      ..color = wallColor
      ..strokeWidth = wallThickness
      ..style = PaintingStyle.stroke;

    final cylinderPath = Path()
      ..moveTo(left, cylinderTopY)
      ..lineTo(left, bottomY)
      ..lineTo(right, bottomY)
      ..lineTo(right, cylinderTopY);
    canvas.drawPath(cylinderPath, wallPaint);

    // ピストンの位置計算（ストッパーも同じ換算式を使う）
    double pistonY = _pistonYForVolume(bottomY, cylinderMaxHeight, volume);

    // 熱交換の視覚化 (壁際の発光)
    _drawHeatFluxGlow(canvas, left, right, bottomY, pistonY, heatFlux);

    // 背景 (気体領域)
    Rect gasRect = Rect.fromLTRB(left + wallThickness/2, pistonY, right - wallThickness/2, bottomY - wallThickness/2);
    canvas.drawRect(gasRect, Paint()..color = Colors.white);
    canvas.drawRect(gasRect, Paint()..color = Colors.black..strokeWidth = 1.0..style = PaintingStyle.stroke);

    // ヒーター（断熱など熱交換しない過程では非表示）
    if (showHeater) {
      _drawHeater(canvas, left, right, bottomY, isHeating);
    }

    // ピストン
    final pistonPaint = Paint()..color = Colors.black..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTRB(
        left + wallThickness / 2,
        pistonY - kPistonTopExtent,
        right - wallThickness / 2,
        pistonY + kPistonBottomExtent,
      ),
      pistonPaint,
    );

    // ロッド
    double rodLength = (personFeetPos != null) ? 40.0 : cylinderMaxHeight * 0.3;
    double rodTopY = pistonY - kPistonTopExtent - rodLength;
    canvas.drawRect(
      Rect.fromLTRB((left + right) / 2 - 5, rodTopY, (left + right) / 2 + 5, pistonY - kPistonTopExtent),
      pistonPaint,
    );

    // 錘
    _drawWeights(canvas, (left + right) / 2, pistonY - kPistonTopExtent, weights);

    // ストッパーはピストンの後に描き、移動限界で上面/下面に当たるように合わせる
    final bool lockMode = showTopStoppers &&
        showBottomStoppers &&
        topStopperVolume != null &&
        bottomStopperVolume != null &&
        (topStopperVolume! - bottomStopperVolume!).abs() < 1e-6;

    if (showTopStoppers) {
      final v = topStopperVolume ?? volume;
      final pistonAtStop = _pistonYForVolume(bottomY, cylinderMaxHeight, v);
      // 定積ロック: ピストンを挟む / 移動限界: ピストン上面に接触
      final y = lockMode ? pistonAtStop - 12.0 : pistonAtStop - kPistonTopExtent;
      _drawStoppers(canvas, left, right, y, true);
    }
    if (showBottomStoppers) {
      final v = bottomStopperVolume ?? volume;
      final pistonAtStop = _pistonYForVolume(bottomY, cylinderMaxHeight, v);
      // 定積ロック: ピストンを挟む / 移動限界: ピストン下面に接触
      final y = lockMode ? pistonAtStop + 12.0 : pistonAtStop + kPistonBottomExtent;
      _drawStoppers(canvas, left, right, y, false);
    }

    // 人物
    if (personFeetPos != null) {
      double pX = right + 40;
      _drawPerson(canvas, size, Offset(pX, bottomY), Offset((left + right) / 2, rodTopY));
    }

    // 粒子
    final particlePaint = Paint()..color = Colors.blueAccent..style = PaintingStyle.fill;
    for (var p in particles) {
      Offset pos = Offset(
        left + wallThickness/2 + p.position.dx * (cylinderWidth - wallThickness),
        pistonY + p.position.dy * (bottomY - wallThickness/2 - pistonY),
      );
      canvas.drawCircle(pos, 4, particlePaint);
    }
  }

  void _drawHeatFluxGlow(Canvas canvas, double left, double right, double bottomY, double pistonY, double flux) {
    if (flux.abs() < 0.05) return;
    double intensity = (flux.abs() * 0.8).clamp(0.0, 0.4);
    Color glowColor = flux > 0 ? Colors.blue.withOpacity(intensity) : Colors.red.withOpacity(intensity);
    
    final glowPaint = Paint()
      ..color = glowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0;
    
    final gasPath = Path()
      ..moveTo(left, pistonY)
      ..lineTo(left, bottomY)
      ..lineTo(right, bottomY)
      ..lineTo(right, pistonY);
    canvas.drawPath(gasPath, glowPaint);
  }

  /// volume に対応するピストン下面（気体上端）の Y 座標
  static double _pistonYForVolume(double bottomY, double cylinderMaxHeight, double volume) {
    return bottomY - cylinderMaxHeight * kGasHeightFactor * volume;
  }

  void _drawStoppers(Canvas canvas, double left, double right, double y, bool isTop) {
    double stopperWidth = 25.0;
    final stopperPaint = Paint()..color = const Color(0xFF4B2C20)..style = PaintingStyle.fill;
    // 内側に引っかかるように配置
    canvas.drawRect(Rect.fromLTRB(left + 8, y - 5, left + 8 + stopperWidth, y + 5), stopperPaint);
    canvas.drawRect(Rect.fromLTRB(right - 8 - stopperWidth, y - 5, right - 8, y + 5), stopperPaint);
  }

  void _drawHeater(Canvas canvas, double left, double right, double bottomY, bool active) {
    final heaterPaint = Paint()
      ..color = active ? Colors.red : Colors.grey[400]!
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    if (active) {
      heaterPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      _drawHeaterPath(canvas, left, right, bottomY, Paint()
        ..color = Colors.orange.withOpacity(0.5)
        ..strokeWidth = 8.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    }
    _drawHeaterPath(canvas, left, right, bottomY, heaterPaint);
  }

  void _drawHeaterPath(Canvas canvas, double left, double right, double bottomY, Paint paint) {
    final path = Path();
    double y = bottomY - 25;
    double cylinderWidth = right - left;
    double startX = left + cylinderWidth * 0.2;
    double endX = right - cylinderWidth * 0.2;
    double step = (endX - startX) / 10;
    path.moveTo(startX, y);
    for (int i = 1; i <= 10; i++) {
      path.lineTo(startX + i * step, y + ((i % 2 == 0) ? 10 : -10));
    }
    canvas.drawPath(path, paint);
  }

  void _drawWeights(Canvas canvas, double centerX, double topY, int count) {
    if (count <= 0) return;
    final weightPaint = Paint()..color = Colors.blueGrey[700]!..style = PaintingStyle.fill;
    double wWidth = 40.0;
    double wHeight = 15.0;
    for (int i = 0; i < count; i++) {
      canvas.drawRect(
        Rect.fromCenter(center: Offset(centerX, topY - (i + 0.5) * wHeight - 2), width: wWidth, height: wHeight - 2),
        weightPaint
      );
    }
  }

  void _drawPerson(Canvas canvas, Size size, Offset feetPos, Offset handTarget) {
    final paint = Paint()..color = Colors.black..strokeWidth = 2.5..style = PaintingStyle.stroke;
    double height = size.height * 0.5;
    Offset head = Offset(feetPos.dx, feetPos.dy - height);
    Offset shoulder = Offset(feetPos.dx, feetPos.dy - height * 0.8);
    Offset waist = Offset(feetPos.dx, feetPos.dy - height * 0.4);

    canvas.drawCircle(Offset(head.dx, head.dy - 10), 15, paint);
    canvas.drawLine(head, waist, paint);
    canvas.drawLine(waist, Offset(feetPos.dx - 15, feetPos.dy), paint);
    canvas.drawLine(waist, Offset(feetPos.dx + 15, feetPos.dy), paint);
    canvas.drawLine(shoulder, handTarget, paint);
    canvas.drawLine(shoulder, Offset(feetPos.dx + 20, shoulder.dy + 20), paint);
  }

  @override
  bool shouldRepaint(covariant BaseGasPainter oldDelegate) => true;
}

/// 熱力学シミュレーション用のベースPVPainter
class BasePVPainter extends CustomPainter {
  final double volume;
  final double pressure;
  final double temperature;
  final String? label;
  final List<Offset>? history; // 過去の軌跡

  BasePVPainter({
    required this.volume,
    required this.pressure,
    required this.temperature,
    this.label,
    this.history,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black..strokeWidth = 2.0..style = PaintingStyle.stroke;
    double padding = 35.0;
    double w = size.width - padding * 2;
    double h = size.height - padding * 2;
    Offset origin = Offset(padding, size.height - padding);

    // 軸
    canvas.drawLine(origin, Offset(padding, padding), paint);
    canvas.drawLine(origin, Offset(size.width - padding, size.height - padding), paint);
    
    _drawLabel(canvas, "P", Offset(padding - 20, padding - 10));
    _drawLabel(canvas, "V", Offset(size.width - padding + 5, size.height - padding - 5));

    // 参考曲線などは軌跡の下に描く
    drawExtraCurves(canvas, size, padding, w, h);

    // 軌跡の描画
    if (history != null && history!.length > 1) {
      final historyPaint = Paint()
        ..color = Colors.red.withOpacity(0.5)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      final path = Path();
      for (int i = 0; i < history!.length; i++) {
        double x = padding + history![i].dx * w;
        double y = size.height - padding - history![i].dy * h;
        if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
      }
      canvas.drawPath(path, historyPaint);
    }

    // 現在の状態点
    double currentX = padding + volume * w;
    double currentY = size.height - padding - pressure * h;
    canvas.drawCircle(Offset(currentX, currentY), 5, Paint()..color = Colors.red..style = PaintingStyle.fill);

    if (label != null) {
      _drawLabel(canvas, label!, Offset(currentX + 10, currentY - 10), color: Colors.red);
    }
  }

  /// 等温・断熱などの参考曲線を軌跡の下に描くためのフック
  void drawExtraCurves(Canvas canvas, Size size, double padding, double w, double h) {}
  void _drawLabel(Canvas canvas, String text, Offset offset, {Color color = Colors.black}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant BasePVPainter oldDelegate) => true;
}

/// PV図上の状態点の軌跡を間引きながら記録する
class PvHistoryTracker {
  final List<Offset> points = [];
  Offset? _last;
  final int maxPoints;
  final double minDistance;

  PvHistoryTracker({this.maxPoints = 500, this.minDistance = 0.01});

  /// BasePVPainter に渡すのと同じ正規化座標 (V, P) で記録する
  void record(double volume, double pressure) {
    final point = Offset(volume, pressure);
    if (_last == null || (_last! - point).distance > minDistance) {
      points.add(point);
      _last = point;
      if (points.length > maxPoints) points.removeAt(0);
    }
  }
}
