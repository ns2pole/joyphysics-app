import 'dart:math' as math;
import 'dart:ui';

/// マーチングスクエアのバラバラな線分を、端点共有でポリラインへ繋ぐ。
List<List<math.Point<double>>> stitchContourPolylines(List<double> segs) {
  final adj = <(int, int), List<_ContourEnd>>{};
  final pos = <(int, int), math.Point<double>>{};

  void addEnd((int, int) from, (int, int) to, double x, double y) {
    final list = adj.putIfAbsent(from, () => <_ContourEnd>[]);
    for (final e in list) {
      if (e.key == to) return;
    }
    list.add(_ContourEnd(to, x, y));
  }

  for (int k = 0; k + 3 < segs.length; k += 4) {
    final x0 = segs[k];
    final y0 = segs[k + 1];
    final x1 = segs[k + 2];
    final y1 = segs[k + 3];
    final a = _contourKey(x0, y0);
    final b = _contourKey(x1, y1);
    if (a == b) continue;
    pos[a] = math.Point(x0, y0);
    pos[b] = math.Point(x1, y1);
    addEnd(a, b, x1, y1);
    addEnd(b, a, x0, y0);
  }

  final polylines = <List<math.Point<double>>>[];

  int unusedCount((int, int) key) {
    final list = adj[key];
    if (list == null) return 0;
    var n = 0;
    for (final e in list) {
      if (!e.used) n++;
    }
    return n;
  }

  void markUsed((int, int) from, (int, int) to) {
    final fromList = adj[from];
    if (fromList != null) {
      for (final e in fromList) {
        if (e.key == to && !e.used) {
          e.used = true;
          break;
        }
      }
    }
    final toList = adj[to];
    if (toList != null) {
      for (final e in toList) {
        if (e.key == from && !e.used) {
          e.used = true;
          break;
        }
      }
    }
  }

  _ContourEnd? nextUnused((int, int) key) {
    final list = adj[key];
    if (list == null) return null;
    for (final e in list) {
      if (!e.used) return e;
    }
    return null;
  }

  void walk((int, int) start) {
    final startPt = pos[start];
    if (startPt == null) return;
    final poly = <math.Point<double>>[startPt];
    var cur = start;
    while (true) {
      final nxt = nextUnused(cur);
      if (nxt == null) break;
      markUsed(cur, nxt.key);
      poly.add(math.Point(nxt.x, nxt.y));
      cur = nxt.key;
      if (cur == start) break;
    }
    if (poly.length >= 2) polylines.add(poly);
  }

  for (final key in adj.keys) {
    if (unusedCount(key) == 1) walk(key);
  }
  for (final key in adj.keys) {
    if (unusedCount(key) > 0) walk(key);
  }
  return polylines;
}

/// 画面座標のポリラインを、パス長に沿った等間隔の点線として [Path] にする。
/// 呼び出し側は `canvas.drawPath` 1回で描ける。
Path dashedPolylinePath(
  List<List<Offset>> polylines, {
  double dashLen = 12.0,
  double gapLen = 10.0,
}) {
  final path = Path();
  emitDashedPolylines(
    polylines: polylines,
    dashLen: dashLen,
    gapLen: gapLen,
    emit: (pts) {
      path.moveTo(pts.first.dx, pts.first.dy);
      for (int i = 1; i < pts.length; i++) {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
    },
  );
  return path;
}

void emitDashedPolylines({
  required List<List<Offset>> polylines,
  required void Function(List<Offset> dashPts) emit,
  double dashLen = 12.0,
  double gapLen = 10.0,
}) {
  for (final pts in polylines) {
    if (pts.length < 2) continue;
    var drawing = true;
    var remain = dashLen;
    List<Offset>? dash;
    void flush() {
      final pts = dash;
      if (pts != null && pts.length >= 2) emit(pts);
      dash = null;
    }

    void append(Offset p) {
      if (dash == null) {
        dash = [p];
        return;
      }
      final last = dash!.last;
      if ((last.dx - p.dx).abs() < 1e-9 && (last.dy - p.dy).abs() < 1e-9) {
        return;
      }
      dash!.add(p);
    }

    for (int i = 1; i < pts.length; i++) {
      final from = pts[i - 1];
      final to = pts[i];
      final dx = to.dx - from.dx;
      final dy = to.dy - from.dy;
      final segLen = math.sqrt(dx * dx + dy * dy);
      if (segLen < 1e-9) continue;
      var pos = 0.0;
      while (pos < segLen - 1e-9) {
        final take = math.min(remain, segLen - pos);
        final t0 = pos / segLen;
        final t1 = (pos + take) / segLen;
        final p0 = Offset(from.dx + dx * t0, from.dy + dy * t0);
        final p1 = Offset(from.dx + dx * t1, from.dy + dy * t1);
        if (drawing && take > 1e-9) {
          append(p0);
          append(p1);
        } else {
          flush();
        }
        pos += take;
        remain -= take;
        if (remain <= 1e-9) {
          if (drawing) flush();
          drawing = !drawing;
          remain = drawing ? dashLen : gapLen;
        }
      }
    }
    flush();
  }
}

(int, int) _contourKey(double x, double y) =>
    ((x * 1e5).round(), (y * 1e5).round());

class _ContourEnd {
  _ContourEnd(this.key, this.x, this.y);

  final (int, int) key;
  final double x;
  final double y;
  bool used = false;
}
