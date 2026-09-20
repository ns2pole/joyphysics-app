import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/waves/animations/painters/contour_dash.dart';

void main() {
  test('共有端点の線分は1本のポリラインになる', () {
    final polys = stitchContourPolylines([
      0.0, 0.0, 1.0, 0.0,
      1.0, 0.0, 2.0, 0.0,
    ]);
    expect(polys, hasLength(1));
    expect(polys.single, hasLength(3));
    expect(polys.single.first.x, 0.0);
    expect(polys.single.last.x, 2.0);
  });

  test('繋がらない線分は別ポリラインになる', () {
    final polys = stitchContourPolylines([
      0.0, 0.0, 1.0, 0.0,
      5.0, 5.0, 6.0, 5.0,
    ]);
    expect(polys, hasLength(2));
  });

  test('閉曲線はループとして繋がる', () {
    final polys = stitchContourPolylines([
      0.0, 0.0, 1.0, 0.0,
      1.0, 0.0, 1.0, 1.0,
      1.0, 1.0, 0.0, 0.0,
    ]);
    expect(polys, hasLength(1));
    expect(polys.single.length, 4);
    expect(polys.single.first.x, polys.single.last.x);
    expect(polys.single.first.y, polys.single.last.y);
  });

  test('点線はパス長に沿って等間隔になる', () {
    final dashes = <List<Offset>>[];
    emitDashedPolylines(
      polylines: [
        [Offset.zero, const Offset(110, 0)],
      ],
      dashLen: 12,
      gapLen: 10,
      emit: dashes.add,
    );
    expect(dashes, hasLength(5));
    for (final d in dashes) {
      expect(d, hasLength(2));
      expect((d.last.dx - d.first.dx).abs(), closeTo(12, 1e-9));
    }
    expect(dashes.first.first.dx, closeTo(0, 1e-9));
    expect(dashes.last.last.dx, closeTo(100, 1e-9));
  });

  test('点線位相は頂点をまたいでも一本のダッシュになる', () {
    final dashes = <List<Offset>>[];
    emitDashedPolylines(
      polylines: [
        [Offset.zero, const Offset(10, 0), const Offset(34, 0)],
      ],
      dashLen: 12,
      gapLen: 10,
      emit: dashes.add,
    );
    expect(dashes, hasLength(2));
    expect(dashes[0].first.dx, closeTo(0, 1e-9));
    expect(dashes[0].last.dx, closeTo(12, 1e-9));
    expect(dashes[0], hasLength(3));
    expect(dashes[1].first.dx, closeTo(22, 1e-9));
    expect(dashes[1].last.dx, closeTo(34, 1e-9));
  });
}
