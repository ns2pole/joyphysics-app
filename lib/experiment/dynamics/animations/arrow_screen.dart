/// 画面上の向きを取るとき、単位ベクトルに沿って進める世界長。
const double kArrowWorldEps = 0.25;

/// 正投影の潰れ。正面（視線と垂直）で 1、視線と平行で 0。
/// [screenPx] は世界長 [kArrowWorldEps] を [pxPerMeter] で映した長さ。
double arrowScreenForeshorten({
  required double screenPx,
  required double pxPerMeter,
}) {
  final faceOn = kArrowWorldEps * pxPerMeter;
  if (!(faceOn > 1e-9) || !(screenPx > 0)) return 0;
  return (screenPx / faceOn).clamp(0.0, 1.0);
}
