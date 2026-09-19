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
/// ストッパー矩形の半分の高さ（中心±この値が描画範囲）
const double kStopperHalfHeight = 5.0;

/// 熱力学シミュレーション用のベースGasPainter
class BaseGasPainter extends CustomPainter {
  final List<ThermodynamicParticle> particles;
  final double volume;
  final double temperature;
  final bool isHeating;
  final bool isCooling;
  final bool showHeater;
  /// 側面の着脱式断熱カバー（true のとき両壁に装着。冷却時は外す想定）
  final bool showInsulationCovers;
  /// 容器底面下の断熱材（true のとき容器を断熱パッドの上に置く。加熱時は外す想定）
  final bool showBottomInsulation;
  /// 定積・定圧用: 薄い外容器に内容器＋断熱材をスッポリ入れる
  final bool showOuterVessel;
  /// 外容器に 0℃ の水を満たす（冷却時）
  final bool fillOuterVesselWithIceWater;
  final double heatFlux; // 壁経由の外気との熱流。正: 外→気体（吸熱）, 負: 気体→外（発熱）。内部ヒーターは含めない。
  final int weights;
  /// ロッド中心の左右バイアス（-1=左端寄り, 0=中央, +1=右端寄り）
  final double rodCenterBias;
  /// ピストン上面の右寄りに荷物（箱）を描画
  final bool showCargo;
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

  static const double kJacketGap = 14.0;
  static const double kOuterWallThickness = 2.0;
  static const double kJacketBottom = 16.0;

  BaseGasPainter({
    required this.particles,
    required this.volume,
    this.temperature = 300.0,
    this.isHeating = false,
    this.isCooling = false,
    this.showHeater = true,
    this.showInsulationCovers = false,
    this.showBottomInsulation = false,
    this.showOuterVessel = false,
    this.fillOuterVesselWithIceWater = false,
    this.heatFlux = 0.0,
    this.weights = 0,
    this.rodCenterBias = 0.0,
    this.showCargo = false,
    this.showTopStoppers = false,
    this.showBottomStoppers = false,
    this.topStopperVolume,
    this.bottomStopperVolume,
    this.wallColor = Colors.grey,
    this.wallThickness = 4.0,
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

    // 底面断熱材 / 外容器ジャケット用スペース。電熱線は容器内。
    const double bottomPadHeight = 18.0;
    final bool needBottomSpace = showOuterVessel || showBottomInsulation;
    final double bottomReserve =
        showOuterVessel ? kJacketBottom + kOuterWallThickness + 2 : bottomPadHeight;
    double floorY = size.height - 4;
    double bottomY = needBottomSpace ? floorY - bottomReserve : floorY;
    double cylinderMaxHeight = size.height * cylinderHeightFactor;
    if (needBottomSpace) {
      cylinderMaxHeight = math.min(cylinderMaxHeight, bottomY - 8);
    }
    // 外容器は上面開放。内容器より少し低くして「入れ物」感を出す
    double cylinderTopY = bottomY - cylinderMaxHeight;
    final double jacketTopY =
        showOuterVessel ? cylinderTopY + cylinderMaxHeight * 0.08 : cylinderTopY;

    // 床
    final floorPaint = Paint()..color = Colors.grey[400]!..strokeWidth = 2.0;
    canvas.drawLine(Offset(0, floorY), Offset(size.width, floorY), floorPaint);

    if (showOuterVessel) {
      final outerLeft = left - wallThickness / 2 - kJacketGap - kOuterWallThickness;
      final outerRight = right + wallThickness / 2 + kJacketGap + kOuterWallThickness;
      final outerBottom = bottomY + kJacketBottom + kOuterWallThickness;
      final innerJacketLeft = left - wallThickness / 2;
      final innerJacketRight = right + wallThickness / 2;

      // 外容器内の中身（断熱材 or 0℃の水）を先に塗り、その上に薄い外容器の輪郭
      if (showInsulationCovers) {
        _drawJacketInsulation(
          canvas,
          innerJacketLeft: innerJacketLeft,
          innerJacketRight: innerJacketRight,
          outerLeft: outerLeft + kOuterWallThickness,
          outerRight: outerRight - kOuterWallThickness,
          jacketTopY: jacketTopY,
          cylinderBottomY: bottomY,
          outerInnerBottomY: outerBottom - kOuterWallThickness,
        );
      } else if (fillOuterVesselWithIceWater) {
        _drawJacketIceWater(
          canvas,
          innerJacketLeft: innerJacketLeft,
          innerJacketRight: innerJacketRight,
          outerLeft: outerLeft + kOuterWallThickness,
          outerRight: outerRight - kOuterWallThickness,
          jacketTopY: jacketTopY,
          cylinderBottomY: bottomY,
          outerInnerBottomY: outerBottom - kOuterWallThickness,
        );
      }

      _drawOuterVesselOutline(
        canvas,
        outerLeft: outerLeft,
        outerRight: outerRight,
        jacketTopY: jacketTopY,
        outerBottom: outerBottom,
      );
    } else {
      // 旧スタイル: 底パッド＋側面カバー（断熱・等温・熱サイクルなど）
      if (showBottomInsulation) {
        _drawBottomInsulation(canvas, left, right, bottomY, floorY);
      }
    }

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

    // 着脱式断熱カバー（両側面）— 外容器モードではジャケット内に描済み
    if (showInsulationCovers && !showOuterVessel) {
      _drawInsulationCovers(canvas, left, right, cylinderTopY, bottomY, wallThickness);
    }

    // ピストンの位置計算（ストッパーも同じ換算式を使う）
    double pistonY = _pistonYForVolume(bottomY, cylinderMaxHeight, volume);

    // 背景 (気体領域)
    Rect gasRect = Rect.fromLTRB(left + wallThickness/2, pistonY, right - wallThickness/2, bottomY - wallThickness/2);
    canvas.drawRect(gasRect, Paint()..color = Colors.white);
    canvas.drawRect(gasRect, Paint()..color = Colors.black..strokeWidth = 1.0..style = PaintingStyle.stroke);

    // 電熱線は容器の中（底面付近）。底の断熱材とは独立
    if (showHeater) {
      _drawHeater(canvas, left, right, bottomY, isHeating);
    }

    // 熱交換: 両壁からの赤いシルエット矢印（容器向き=吸熱、外向き=発熱）
    _drawHeatFluxArrows(canvas, left, right, bottomY, pistonY, heatFlux);

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

    // ロッド（荷物持ち上げモードでは中央から少し左）
    final double midX = (left + right) / 2;
    final double rodX =
        midX + rodCenterBias.clamp(-1.0, 1.0) * (right - left) * 0.5;
    double rodLength = (personFeetPos != null) ? 40.0 : cylinderMaxHeight * 0.3;
    double rodTopY = pistonY - kPistonTopExtent - rodLength;
    canvas.drawRect(
      Rect.fromLTRB(rodX - 5, rodTopY, rodX + 5, pistonY - kPistonTopExtent),
      pistonPaint,
    );

    // 錘（サイクル用）／荷物（持ち上げモード）
    final double pistonTopY = pistonY - kPistonTopExtent;
    _drawWeights(canvas, midX, pistonTopY, weights);
    if (showCargo) {
      _drawCargo(canvas, left, right, pistonTopY);
    }

    // ストッパーはピストンの後に描き、移動限界で上面/下面に当たるように合わせる
    final bool lockMode = showTopStoppers &&
        showBottomStoppers &&
        topStopperVolume != null &&
        bottomStopperVolume != null &&
        (topStopperVolume! - bottomStopperVolume!).abs() < 1e-6;

    if (showTopStoppers) {
      final v = topStopperVolume ?? volume;
      final pistonAtStop = _pistonYForVolume(bottomY, cylinderMaxHeight, v);
      // 定積ロック: ピストン上面に密着 / 移動限界: 上面中心合わせ
      final y = lockMode
          ? pistonAtStop - kPistonTopExtent - kStopperHalfHeight
          : pistonAtStop - kPistonTopExtent;
      _drawStoppers(canvas, left, right, y, true, wallThickness);
    }
    if (showBottomStoppers) {
      final v = bottomStopperVolume ?? volume;
      final pistonAtStop = _pistonYForVolume(bottomY, cylinderMaxHeight, v);
      // 定積ロック: ピストン下面に密着 / 移動限界: 下面中心合わせ
      // （以前は上下とも +12 固定で、下面 extent=6 との差で隙間が空いていた）
      final y = lockMode
          ? pistonAtStop + kPistonBottomExtent + kStopperHalfHeight
          : pistonAtStop + kPistonBottomExtent;
      _drawStoppers(canvas, left, right, y, false, wallThickness);
    }

    // 人物
    if (personFeetPos != null) {
      double pX = right + 40;
      _drawPerson(canvas, size, Offset(pX, floorY), Offset((left + right) / 2, rodTopY));
    }

    // 粒子（温度が高いほど赤く・少し大きく）
    final double tNorm =
        ((temperature - 275.0) / (1000.0 - 275.0)).clamp(0.0, 1.0);
    final Color particleColor =
        Color.lerp(const Color(0xFF2979FF), const Color(0xFFFF1744), tNorm)!;
    final double particleRadius = 3.5 + 2.0 * tNorm;
    final particlePaint = Paint()
      ..color = particleColor
      ..style = PaintingStyle.fill;
    for (var p in particles) {
      Offset pos = Offset(
        left + wallThickness/2 + p.position.dx * (cylinderWidth - wallThickness),
        pistonY + p.position.dy * (bottomY - wallThickness/2 - pistonY),
      );
      canvas.drawCircle(pos, particleRadius, particlePaint);
    }
  }

  /// 両壁からの熱流矢印（気体中央に太めの1本ずつ）。
  /// flux > 0: 矢印が容器へ（気体の吸熱） / flux < 0: 矢印が外へ（気体の発熱）
  void _drawHeatFluxArrows(
    Canvas canvas,
    double left,
    double right,
    double bottomY,
    double pistonY,
    double flux,
  ) {
    if (flux.abs() < 0.05) return;

    final bool intoGas = flux > 0;
    final double intensity = flux.abs().clamp(0.2, 1.0);
    final double alpha = (0.40 + 0.40 * intensity).clamp(0.4, 0.85);

    final softPaint = Paint()
      ..color = const Color(0xFFE53935).withOpacity(alpha * 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0)
      ..style = PaintingStyle.fill;
    final hardPaint = Paint()
      ..color = const Color(0xFFE53935).withOpacity(alpha)
      ..style = PaintingStyle.fill;

    // 圧縮で気体が薄くなっても、気体領域の中央に矢印を出す
    // （以前は高さ40未満で非表示にしていたため、押し込みで消えてしまっていた）
    final double gasTop = pistonY + 4;
    final double gasBottom = bottomY - wallThickness / 2 - 2;
    if (gasBottom - gasTop < 8) return;

    final double midY = (gasTop + gasBottom) / 2;
    const double shaft = 28.0;
    const double gap = 6.0; // 壁からの距離

    // 左壁: 気体中央に1本
    if (intoGas) {
      _drawSoftHorizontalArrow(
        canvas,
        tip: Offset(left - gap, midY),
        pointingRight: true,
        length: shaft,
        softPaint: softPaint,
        hardPaint: hardPaint,
      );
    } else {
      _drawSoftHorizontalArrow(
        canvas,
        tip: Offset(left - gap - shaft, midY),
        pointingRight: false,
        length: shaft,
        softPaint: softPaint,
        hardPaint: hardPaint,
      );
    }

    // 右壁: 気体中央に1本
    if (intoGas) {
      _drawSoftHorizontalArrow(
        canvas,
        tip: Offset(right + gap, midY),
        pointingRight: false,
        length: shaft,
        softPaint: softPaint,
        hardPaint: hardPaint,
      );
    } else {
      _drawSoftHorizontalArrow(
        canvas,
        tip: Offset(right + gap + shaft, midY),
        pointingRight: true,
        length: shaft,
        softPaint: softPaint,
        hardPaint: hardPaint,
      );
    }
  }

  void _drawSoftHorizontalArrow(
    Canvas canvas, {
    required Offset tip,
    required bool pointingRight,
    required double length,
    required Paint softPaint,
    required Paint hardPaint,
  }) {
    const double headLen = 16.0;
    const double headHalfH = 13.0;
    const double shaftHalfH = 5.5;

    final double dir = pointingRight ? 1.0 : -1.0;
    final Offset base = Offset(tip.dx - dir * length, tip.dy);
    final Offset headBase = Offset(tip.dx - dir * headLen, tip.dy);

    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(headBase.dx, tip.dy - headHalfH)
      ..lineTo(headBase.dx, tip.dy - shaftHalfH)
      ..lineTo(base.dx, tip.dy - shaftHalfH)
      ..lineTo(base.dx, tip.dy + shaftHalfH)
      ..lineTo(headBase.dx, tip.dy + shaftHalfH)
      ..lineTo(headBase.dx, tip.dy + headHalfH)
      ..close();

    canvas.drawPath(path, softPaint);
    canvas.drawPath(path, hardPaint);
  }

  /// 薄い外容器の輪郭（上面開放の U 字）
  void _drawOuterVesselOutline(
    Canvas canvas, {
    required double outerLeft,
    required double outerRight,
    required double jacketTopY,
    required double outerBottom,
  }) {
    final paint = Paint()
      ..color = const Color(0xFF90A4AE)
      ..strokeWidth = kOuterWallThickness
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.miter
      ..strokeCap = StrokeCap.square;
    final path = Path()
      ..moveTo(outerLeft, jacketTopY)
      ..lineTo(outerLeft, outerBottom)
      ..lineTo(outerRight, outerBottom)
      ..lineTo(outerRight, jacketTopY);
    canvas.drawPath(path, paint);
  }

  Path _jacketFillPath({
    required double innerJacketLeft,
    required double innerJacketRight,
    required double outerLeft,
    required double outerRight,
    required double jacketTopY,
    required double cylinderBottomY,
    required double outerInnerBottomY,
  }) {
    // 内容器の外側〜外容器の内側を U 字に塗りつぶす（左下・右下も直角）
    return Path()
      ..moveTo(outerLeft, jacketTopY)
      ..lineTo(outerLeft, outerInnerBottomY)
      ..lineTo(outerRight, outerInnerBottomY)
      ..lineTo(outerRight, jacketTopY)
      ..lineTo(innerJacketRight, jacketTopY)
      ..lineTo(innerJacketRight, cylinderBottomY)
      ..lineTo(innerJacketLeft, cylinderBottomY)
      ..lineTo(innerJacketLeft, jacketTopY)
      ..close();
  }

  /// 外容器の中にスッポリ収まる断熱材（側面＋底）
  void _drawJacketInsulation(
    Canvas canvas, {
    required double innerJacketLeft,
    required double innerJacketRight,
    required double outerLeft,
    required double outerRight,
    required double jacketTopY,
    required double cylinderBottomY,
    required double outerInnerBottomY,
  }) {
    final path = _jacketFillPath(
      innerJacketLeft: innerJacketLeft,
      innerJacketRight: innerJacketRight,
      outerLeft: outerLeft,
      outerRight: outerRight,
      jacketTopY: jacketTopY,
      cylinderBottomY: cylinderBottomY,
      outerInnerBottomY: outerInnerBottomY,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF1A1A1A)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF444444)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    final hatchPaint = Paint()
      ..color = const Color(0xFF3D3D3D)
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    canvas.save();
    canvas.clipPath(path);
    for (double y = jacketTopY + 4; y < outerInnerBottomY; y += 8) {
      canvas.drawLine(
        Offset(outerLeft, y),
        Offset(outerRight, y - 6),
        hatchPaint,
      );
    }
    canvas.restore();
  }

  /// 外容器に満たす 0℃ の水
  void _drawJacketIceWater(
    Canvas canvas, {
    required double innerJacketLeft,
    required double innerJacketRight,
    required double outerLeft,
    required double outerRight,
    required double jacketTopY,
    required double cylinderBottomY,
    required double outerInnerBottomY,
  }) {
    final path = _jacketFillPath(
      innerJacketLeft: innerJacketLeft,
      innerJacketRight: innerJacketRight,
      outerLeft: outerLeft,
      outerRight: outerRight,
      jacketTopY: jacketTopY,
      cylinderBottomY: cylinderBottomY,
      outerInnerBottomY: outerInnerBottomY,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF81D4FA).withOpacity(0.72)
        ..style = PaintingStyle.fill,
    );
    // 水面のハイライト
    final surfacePaint = Paint()
      ..color = const Color(0xFFE1F5FE).withOpacity(0.85)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(outerLeft + 1, jacketTopY), Offset(innerJacketLeft - 1, jacketTopY), surfacePaint);
    canvas.drawLine(Offset(innerJacketRight + 1, jacketTopY), Offset(outerRight - 1, jacketTopY), surfacePaint);

    final tp = TextPainter(
      text: const TextSpan(
        text: '0 ℃',
        style: TextStyle(
          color: Color(0xFF01579B),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(outerRight + 6, (jacketTopY + outerInnerBottomY) / 2 - tp.height / 2),
    );
  }

  /// 両側面に取り付ける着脱式の断熱カバー（容器壁の外面に密着）
  void _drawInsulationCovers(
    Canvas canvas,
    double left,
    double right,
    double topY,
    double bottomY,
    double wallThickness,
  ) {
    const double coverWidth = 12.0;
    const double gap = 0.5;
    final double outerLeft = left - wallThickness / 2;
    final double outerRight = right + wallThickness / 2;
    final coverPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;
    final edgePaint = Paint()
      ..color = const Color(0xFF444444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final hatchPaint = Paint()
      ..color = const Color(0xFF3D3D3D)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    void drawOne(Rect rect) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        coverPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        edgePaint,
      );
      // 断熱材らしい斜線ハッチ
      for (double y = rect.top + 6; y < rect.bottom - 4; y += 9) {
        canvas.drawLine(
          Offset(rect.left + 2, y),
          Offset(rect.right - 2, y - 5),
          hatchPaint,
        );
      }
      // 留め具（上下）
      final clipPaint = Paint()..color = const Color(0xFF6B6B6B);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(rect.center.dx, rect.top + 10),
          width: coverWidth * 0.55,
          height: 4,
        ),
        clipPaint,
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(rect.center.dx, rect.bottom - 10),
          width: coverWidth * 0.55,
          height: 4,
        ),
        clipPaint,
      );
    }

    drawOne(Rect.fromLTRB(
      outerLeft - gap - coverWidth,
      topY,
      outerLeft - gap,
      bottomY,
    ));
    drawOne(Rect.fromLTRB(
      outerRight + gap,
      topY,
      outerRight + gap + coverWidth,
      bottomY,
    ));
  }

  /// 容器底の下に置く断熱パッド（側面カバーと同じ見た目）
  void _drawBottomInsulation(
    Canvas canvas,
    double left,
    double right,
    double bottomY,
    double floorY,
  ) {
    // 薄い壁の外面に揃える程度のわずかな張り出し
    final double overhang = wallThickness / 2 + 2.0;
    final rect = Rect.fromLTRB(left - overhang, bottomY + 0.5, right + overhang, floorY - 1);
    final coverPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;
    final edgePaint = Paint()
      ..color = const Color(0xFF444444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final hatchPaint = Paint()
      ..color = const Color(0xFF3D3D3D)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      coverPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      edgePaint,
    );
    for (double x = rect.left + 4; x < rect.right - 2; x += 8) {
      canvas.drawLine(
        Offset(x, rect.bottom - 2),
        Offset(x + 5, rect.top + 2),
        hatchPaint,
      );
    }
  }

  /// volume に対応するピストン下面（気体上端）の Y 座標
  static double _pistonYForVolume(double bottomY, double cylinderMaxHeight, double volume) {
    return bottomY - cylinderMaxHeight * kGasHeightFactor * volume;
  }

  void _drawStoppers(
    Canvas canvas,
    double left,
    double right,
    double y,
    bool isTop,
    double wallThickness,
  ) {
    const double stopperWidth = 25.0;
    // 壁の内面に密着（少し壁側へ食い込ませて「刺さっている」見た目に）
    final double innerLeft = left + wallThickness / 2;
    final double innerRight = right - wallThickness / 2;
    const double mountIntoWall = 1.5;
    final stopperPaint = Paint()..color = const Color(0xFF4B2C20)..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTRB(
        innerLeft - mountIntoWall,
        y - kStopperHalfHeight,
        innerLeft - mountIntoWall + stopperWidth,
        y + kStopperHalfHeight,
      ),
      stopperPaint,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        innerRight + mountIntoWall - stopperWidth,
        y - kStopperHalfHeight,
        innerRight + mountIntoWall,
        y + kStopperHalfHeight,
      ),
      stopperPaint,
    );
  }

  /// 容器内の底面付近に電熱線を描く
  void _drawHeater(Canvas canvas, double left, double right, double bottomY, bool active) {
    final heaterPaint = Paint()
      ..color = active ? Colors.red : Colors.grey[400]!
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (active) {
      heaterPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      _drawHeaterPath(canvas, left, right, bottomY, Paint()
        ..color = Colors.orange.withOpacity(0.5)
        ..strokeWidth = 7.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    }
    _drawHeaterPath(canvas, left, right, bottomY, heaterPaint);
  }

  void _drawHeaterPath(Canvas canvas, double left, double right, double bottomY, Paint paint) {
    final path = Path();
    // 容器内・底面の少し上
    double y = bottomY - 12;
    double cylinderWidth = right - left;
    double startX = left + cylinderWidth * 0.12;
    double endX = right - cylinderWidth * 0.12;
    double step = (endX - startX) / 10;
    path.moveTo(startX, y);
    for (int i = 1; i <= 10; i++) {
      path.lineTo(startX + i * step, y + ((i % 2 == 0) ? 5 : -5));
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

  /// ピストン上面の右寄りに載せる荷物（箱）。見た目はサイクル用の青錘と区別する。
  void _drawCargo(Canvas canvas, double left, double right, double pistonTopY) {
    final double innerLeft = left + wallThickness / 2;
    final double innerRight = right - wallThickness / 2;
    final double span = innerRight - innerLeft;
    final double boxW = span * 0.38 * 0.6; // 横幅を約60%に
    final double boxH = 22.0;
    // 右寄りだがストッパーと重ならないよう、中央寄り（旧 0.72 → 半分程度寄せて ~0.61）
    final double cx = innerLeft + span * 0.61;
    final Rect box = Rect.fromCenter(
      center: Offset(cx, pistonTopY - boxH / 2 - 2),
      width: boxW,
      height: boxH,
    );
    final fill = Paint()
      ..color = const Color(0xFFB08968)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = const Color(0xFF6F4E37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(2)),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(2)),
      stroke,
    );
    // 簡易な帯・ラベル感
    canvas.drawLine(
      Offset(box.left + 4, box.center.dy),
      Offset(box.right - 4, box.center.dy),
      stroke,
    );
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

/// 単原子分子理想気体の基準状態（初期: 300 K, 1013 hPa, V0 = 1.0 L）
abstract final class IdealGasRef {
  static const double t0K = 300.0;
  static const double p0HPa = 1013.0;
  static const double v0L = 1.0;
  /// シリンダー描画で満杯に相当する体積 [L]（初期の2倍 = 押し引きレンジ）
  static const double vVisMaxL = 2.0;
  /// 断熱スライダー下限 [L]（約 V0/3.3、旧正規化 0.15 相当）
  static const double vMinL = 0.30;
  /// 正規化体積がこの値のとき物理体積 = [v0L]（等温など旧スケール用）
  static const double vNormRef = 0.5;
  static const double gamma = 5.0 / 3.0; // 単原子分子
  static const double gammaMinus1 = 2.0 / 3.0;

  static double volumeLiters(double vNorm) => v0L * vNorm / vNormRef;

  /// 物理体積 [L] → シリンダー描画用の相対体積 (0–1)
  static double cylinderVolumeFromVL(double vL) =>
      (vL / vVisMaxL).clamp(0.05, 1.0);

  static double pressureHPa({required double tK, required double vL}) =>
      p0HPa * (tK / t0K) * (v0L / vL);

  /// 断熱: P V^γ = const（初期状態基準）— 引数は物理体積 [L]
  static double adiabaticPressureHPa(double vL) =>
      p0HPa * math.pow(v0L / vL, gamma);

  /// 断熱: T V^{γ-1} = const — 引数は物理体積 [L]
  static double adiabaticTemperatureK(double vL) =>
      t0K * math.pow(v0L / vL, gammaMinus1);

  /// 等温 (T=T0): ボイル — 引数は物理体積 [L]
  static double isothermalPressureHPa(double vL) =>
      p0HPa * (v0L / vL);

  /// 旧正規化体積用（等温スライダーなど）
  static double isothermalPressureHPaFromNorm(double vNorm) =>
      isothermalPressureHPa(volumeLiters(vNorm));
}

/// 気体の状態量 (V, P, T) を左上に表示（項目ごとに余白を空けて境目を明確に）
Widget buildGasStateHud({
  required double volumeL,
  required double pressureHPa,
  required double temperatureK,
}) {
  TextStyle valueStyle({double size = 13}) => TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        height: 1.25,
      );
  const labelStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: Colors.black54,
    height: 1.2,
  );

  Widget block(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 2),
          Text(value, style: valueStyle()),
        ],
      ),
    );
  }

  return Positioned(
    top: 0,
    left: 0,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        block('体積', '${volumeL.toStringAsFixed(2)} L'),
        block('気圧', '${pressureHPa.toStringAsFixed(0)} hPa'),
        block('温度', '${temperatureK.toStringAsFixed(0)} K'),
      ],
    ),
  );
}

/// 右上の「外気と断熱中」バッジ（小さめ＋枠で視認性を確保）
Widget buildAmbientInsulationBadge() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.92),
      border: Border.all(color: Colors.black87, width: 1.2),
      borderRadius: BorderRadius.circular(4),
    ),
    child: const Text(
      '外気と断熱中',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        height: 1.2,
      ),
    ),
  );
}

/// 右上の外気温・外気圧（ラベルと値を改行し、項目間を空ける）
Widget buildAmbientTpLabels({
  double temperatureK = IdealGasRef.t0K,
  double pressureHPa = IdealGasRef.p0HPa,
}) {
  const labelStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: Colors.black54,
    height: 1.2,
  );
  const valueStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
    height: 1.25,
  );

  Widget block(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label, style: labelStyle, textAlign: TextAlign.right),
          const SizedBox(height: 2),
          Text(value, style: valueStyle, textAlign: TextAlign.right),
        ],
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      block('外気温', '${temperatureK.toStringAsFixed(0)} K'),
      block('外気圧', '${pressureHPa.toStringAsFixed(0)} hPa'),
    ],
  );
}

/// 熱力学シミュレーション用のベースPVPainter
class BasePVPainter extends CustomPainter {
  final double volume;
  final double pressure;
  final double temperature;
  final String? label;
  final List<Offset>? history; // 過去の軌跡
  /// 横軸の最大値（volume と同じ単位）。状態点が枠内に収まるよう設定する。
  final double volumeAxisMax;
  /// 縦軸の最大値（pressure と同じ単位）。
  final double pressureAxisMax;
  /// 目盛りに付ける単位（例: `L`, `hPa`）。空なら数値のみ。
  final String volumeUnit;
  final String pressureUnit;

  BasePVPainter({
    required this.volume,
    required this.pressure,
    required this.temperature,
    this.label,
    this.history,
    this.volumeAxisMax = 1.0,
    this.pressureAxisMax = 1.0,
    this.volumeUnit = '',
    this.pressureUnit = '',
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    // 現在値ラベル（例: `1013 hPa`）用に広めの余白
    const double padding = 56.0;
    final double w = size.width - padding * 2;
    final double h = size.height - padding * 2;
    final Offset origin = Offset(padding, size.height - padding);
    final double vMax = volumeAxisMax <= 0 ? 1.0 : volumeAxisMax;
    final double pMax = pressureAxisMax <= 0 ? 1.0 : pressureAxisMax;

    // 軸
    canvas.drawLine(origin, Offset(padding, padding), paint);
    canvas.drawLine(
      origin,
      Offset(size.width - padding, size.height - padding),
      paint,
    );

    _drawLabel(canvas, 'P', Offset(padding - 18, padding - 14));
    _drawLabel(
      canvas,
      'V',
      Offset(size.width - padding + 4, size.height - padding - 4),
    );

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
        final double x = padding + (history![i].dx / vMax) * w;
        final double y =
            size.height - padding - (history![i].dy / pMax) * h;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, historyPaint);
    }

    // 現在の状態点（軸外にはみ出さないようクランプ）
    final double currentX =
        (padding + (volume / vMax) * w).clamp(padding, size.width - padding);
    final double currentY = (size.height - padding - (pressure / pMax) * h)
        .clamp(padding, size.height - padding);
    final Offset state = Offset(currentX, currentY);

    // 状態点から軸へ水平・垂直の点線
    final guidePaint = Paint()
      ..color = Colors.red.withOpacity(0.65)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    _drawDashedLine(canvas, state, Offset(padding, currentY), guidePaint);
    _drawDashedLine(
      canvas,
      state,
      Offset(currentX, size.height - padding),
      guidePaint,
    );

    // 目盛り（軸上の短いティック）
    final tickPaint = Paint()
      ..color = Colors.red.shade700
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(currentX, size.height - padding - 5),
      Offset(currentX, size.height - padding + 5),
      tickPaint,
    );
    canvas.drawLine(
      Offset(padding - 5, currentY),
      Offset(padding + 5, currentY),
      tickPaint,
    );

    // 目盛り位置に現在値を表示
    final String vText = _axisTickText(volume, volumeUnit);
    final String pText = _axisTickText(pressure, pressureUnit);
    _drawCenteredLabel(
      canvas,
      vText,
      Offset(currentX, size.height - padding + 8),
      color: Colors.red.shade700,
      fontSize: 11,
    );
    _drawRightAlignedLabel(
      canvas,
      pText,
      Offset(padding - 8, currentY),
      color: Colors.red.shade700,
      fontSize: 11,
    );

    canvas.drawCircle(
      state,
      5,
      Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill,
    );

    if (label != null) {
      _drawLabel(
        canvas,
        label!,
        Offset(currentX + 10, currentY - 10),
        color: Colors.red,
      );
    }
  }

  /// 等温・断熱などの参考曲線を軌跡の下に描くためのフック
  void drawExtraCurves(Canvas canvas, Size size, double padding, double w, double h) {}

  String _formatAxisValue(double v) {
    final double a = v.abs();
    if (a >= 100) return v.toStringAsFixed(0);
    if (a >= 10) return v.toStringAsFixed(1);
    return v.toStringAsFixed(2);
  }

  String _axisTickText(double v, String unit) {
    final String num = _formatAxisValue(v);
    if (unit.isEmpty) return num;
    return '$num $unit';
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final Offset delta = end - start;
    final double len = delta.distance;
    if (len <= 0.0) return;
    final Offset unit = delta / len;
    const double dash = 5.0;
    const double gap = 4.0;
    double d = 0.0;
    while (d < len) {
      final Offset s = start + unit * d;
      final Offset e = start + unit * math.min(d + dash, len);
      canvas.drawLine(s, e, paint);
      d += dash + gap;
    }
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset offset, {
    Color color = Colors.black,
    double fontSize = 12,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  void _drawCenteredLabel(
    Canvas canvas,
    String text,
    Offset topCenter, {
    Color color = Colors.black,
    double fontSize = 12,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(topCenter.dx - tp.width / 2, topCenter.dy));
  }

  void _drawRightAlignedLabel(
    Canvas canvas,
    String text,
    Offset midRight, {
    Color color = Colors.black,
    double fontSize = 12,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(midRight.dx - tp.width, midRight.dy - tp.height / 2),
    );
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

/// 壁経由の外気↔気体の熱流（矢印表示用）。
/// 正: 外→気体（吸熱） / 負: 気体→外（発熱）
/// 内部ヒーターによる加熱は壁を通らないので、ここには含めない。
double wallAmbientHeatFlux({
  required bool sideInsulated,
  required double temperature,
  double ambientTemp = 300.0,
  bool heatingWithoutSideInsulation = false,
}) {
  // 側面が断熱されている間は外気とやりとりしない
  if (sideInsulated) return 0.0;

  final dT = temperature - ambientTemp;
  if (dT > 2.0) {
    // 気体が外気温より高い → 壁から放熱
    return (-0.25 - 0.35 * ((dT / 200.0).clamp(0.0, 1.0))).clamp(-0.7, -0.2);
  }
  if (dT < -2.0) {
    // 気体が外気温より低い → 壁から吸熱
    return (0.25 + 0.35 * (((-dT) / 200.0).clamp(0.0, 1.0))).clamp(0.2, 0.7);
  }
  // ほぼ外気温でも、断熱なしで加熱中なら入れた熱がすぐ壁から逃げる
  if (heatingWithoutSideInsulation) return -0.55;
  return 0.0;
}

/// Auto 上部の工程表示（四角枠・中央寄せ。OFF 時も高さを確保）
Widget buildThermoAutoStatusBox(String? label) {
  const double boxHeight = 36;
  return SizedBox(
    height: boxHeight,
    child: Center(
      child: label == null
          ? const SizedBox.shrink()
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54, width: 1),
                borderRadius: BorderRadius.circular(4),
                color: Colors.white.withValues(alpha: 0.85),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
    ),
  );
}

/// Auto トグル（上部に工程ラベル用の高さを確保）
Widget buildThermoAutoToggle({
  required bool autoOn,
  required ValueChanged<bool> onChanged,
  String? statusLabel,
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 2),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildThermoAutoStatusBox(
          autoOn ? (statusLabel ?? '自動サイクル中') : null,
        ),
        const SizedBox(height: 4),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Auto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Switch(value: autoOn, onChanged: onChanged),
            ],
          ),
        ),
      ],
    ),
  );
}

/// 断熱（中央上）＋ 加熱/冷却（その下）の共通コントロール
Widget buildThermoInsulationHeatControls({
  required Set<String> activeIds,
  required void Function(Set<String>) updateActiveIds,
  required bool atMaxTemp,
  required bool atMinTemp,
  bool showCooling = true,
  /// true のとき冷却は断熱オフ時のみ有効（定積・定圧）
  bool coolingRequiresUninsulated = false,
  /// true のとき加熱は断熱オン時のみ有効（定積・定圧）
  bool heatingRequiresInsulation = false,
  /// false のとき全チップ操作不可（Auto 運転中など）
  bool controlsEnabled = true,
}) {
  final bool insulated = activeIds.contains('insulated');
  final bool heatingEnabled = controlsEnabled &&
      !atMaxTemp &&
      (!heatingRequiresInsulation || insulated);
  final bool coolingEnabled = controlsEnabled &&
      showCooling &&
      (!coolingRequiresUninsulated || !insulated);
  final bool insulationEnabled = controlsEnabled;

  FilterChip chip({
    required String label,
    required Color color,
    required bool selected,
    required bool enabled,
    required void Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      selected: selected,
      onSelected: enabled ? onSelected : null,
      selectedColor: color.withOpacity(0.35),
      checkmarkColor: color,
      labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      visualDensity: VisualDensity.comfortable,
    );
  }

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Center(
        child: chip(
          label: '断熱',
          color: Colors.brown,
          selected: insulated,
          enabled: insulationEnabled,
          onSelected: (val) {
            final next = Set<String>.from(activeIds);
            if (val) {
              next.add('insulated');
              // 断熱を戻したら冷却（氷水）は解除
              if (coolingRequiresUninsulated) {
                next.remove('cooling');
              }
            } else {
              next.remove('insulated');
              // 断熱を外すと加熱は効かないので自動OFF
              if (heatingRequiresInsulation) {
                next.remove('heating');
              }
            }
            updateActiveIds(next);
          },
        ),
      ),
      const SizedBox(height: 10),
      Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            chip(
              label: '加熱',
              color: Colors.orange,
              selected: activeIds.contains('heating'),
              enabled: heatingEnabled,
              onSelected: (val) {
                final next = Set<String>.from(activeIds);
                if (val) {
                  next.add('heating');
                  next.remove('cooling');
                  if (heatingRequiresInsulation) {
                    next.add('insulated');
                  }
                } else {
                  next.remove('heating');
                }
                updateActiveIds(next);
              },
            ),
            if (showCooling) ...[
              const SizedBox(width: 16),
              chip(
                label: '冷却',
                color: Colors.blue,
                selected: activeIds.contains('cooling'),
                enabled: coolingEnabled,
                onSelected: (val) {
                  final next = Set<String>.from(activeIds);
                  if (val) {
                    next.add('cooling');
                    next.remove('heating');
                    if (coolingRequiresUninsulated) {
                      next.remove('insulated');
                    }
                  } else {
                    next.remove('cooling');
                  }
                  updateActiveIds(next);
                },
              ),
            ],
          ],
        ),
      ),
    ],
  );
}
