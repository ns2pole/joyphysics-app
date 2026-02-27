import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import '../widgets/wave_slider.dart';

class _RayOptics {
  static const double dropRadius = 1.0;

  static _RayPath? computeRayPath(
    double k,
    double n, {
    Offset dropletCenter = Offset.zero,
  }) {
    final x = k.clamp(0.0, 0.999);
    final alpha = math.asin(x);
    final p1 =
        dropletCenter + Offset(-dropRadius * math.cos(alpha), dropRadius * math.sin(alpha));

    const incoming = Offset(1, 0);
    final normalAtP1 = _normalize(p1 - dropletCenter);
    final d1 = _refract(incoming, normalAtP1, 1.0, n);
    if (d1 == null) return null;

    final p2 = _nextCircleIntersection(
      p1 + d1 * 1e-6,
      d1,
      dropRadius,
      center: dropletCenter,
    );
    if (p2 == null) return null;

    final normalAtP2 = _normalize(p2 - dropletCenter);
    final d2 = _reflect(d1, normalAtP2);

    final p3 = _nextCircleIntersection(
      p2 + d2 * 1e-6,
      d2,
      dropRadius,
      center: dropletCenter,
    );
    if (p3 == null) return null;

    final normalAtP3 = _normalize(p3 - dropletCenter);
    final outDir = _refract(d2, normalAtP3, n, 1.0);
    if (outDir == null) return null;

    return _RayPath(p1: p1, p2: p2, p3: p3, outDir: _normalize(outDir));
  }

  static double phiGeoDegFromPath(_RayPath path) {
    final back = -path.outDir;
    final phi = math.atan2(back.dy.abs(), back.dx.abs());
    return phi * 180.0 / math.pi;
  }

  static double theoryPhiDeg(double k, double n) {
    final x = k.clamp(0.0, 0.999);
    final phiRad = 4.0 * math.asin(x / n) - 2.0 * math.asin(x);
    return phiRad * 180.0 / math.pi;
  }

  static double peakK(double n) => math.sqrt((4.0 - n * n) / 3.0);

  static Offset? horizontalIntersection(Offset p, Offset dir, double y) {
    if (dir.dy.abs() < 1e-9) return null;
    final t = (y - p.dy) / dir.dy;
    return p + dir * t;
  }

  static Offset? _nextCircleIntersection(
    Offset origin,
    Offset dir,
    double r, {
    Offset center = Offset.zero,
  }) {
    final shiftedOrigin = origin - center;
    final a = _dot(dir, dir);
    final b = 2.0 * _dot(shiftedOrigin, dir);
    final c = _dot(shiftedOrigin, shiftedOrigin) - r * r;
    final d = b * b - 4.0 * a * c;
    if (d < 0.0) return null;

    final sqrtD = math.sqrt(d);
    final t1 = (-b - sqrtD) / (2.0 * a);
    final t2 = (-b + sqrtD) / (2.0 * a);
    const eps = 1e-6;

    double? t;
    if (t1 > eps && t2 > eps) {
      t = math.min(t1, t2);
    } else if (t1 > eps) {
      t = t1;
    } else if (t2 > eps) {
      t = t2;
    }
    if (t == null) return null;
    return origin + dir * t;
  }

  static Offset _reflect(Offset v, Offset n) {
    return v - n * (2.0 * _dot(v, n));
  }

  static Offset? _refract(Offset incident, Offset normal, double n1, double n2) {
    final i = _normalize(incident);
    var n = _normalize(normal);
    // n1, n2 は呼び出し側で媒質を指定済みなので、法線は向きだけ合わせる
    if (_dot(i, n) > 0) {
      n = -n;
    }
    final cosI = -_dot(i, n);
    final eta = n1 / n2;
    final k = 1.0 - eta * eta * (1.0 - cosI * cosI);
    if (k < 0.0) return null;
    return i * eta + n * (eta * cosI - math.sqrt(k));
  }

  static Offset _normalize(Offset v) {
    final len = v.distance;
    if (len == 0.0) return Offset.zero;
    return v / len;
  }

  static double _dot(Offset a, Offset b) => a.dx * b.dx + a.dy * b.dy;
}

final rainbowDroplet2D = createWaveVideo(
  title: "虹の光路 (単一水滴)",
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>入射パラメータ $k$ を 0 から 1 の範囲で動かし、球状水滴での屈折→内部反射→出射を可視化します。</p>
  <p>赤色光 ($n=1.33$) と青色光 ($n=1.34$) の分散により、出射方向に差が生まれます。</p>
  <p><b>上半分だけ描いている理由</b>：水滴の下側も同様に光路が存在しますが、説明では「出射点付近の角度関係」が見やすい上側を主に表示しています。</p>
  <p><b>虹とのつながり</b>：$k$ を連続に変えると出射方向（角度 $\phi$）が変化し、ある角度付近で出射光が集中します。波長（屈折率）の違いでその集中角がずれるため、赤と青で見える方向が分かれて「虹」になります。</p>
  <p><b>表示モード</b></p>
  <ul>
    <li><b>通常</b>：1本の光線で光路の折れ方を確認</li>
    <li><b>極小水滴</b>：水滴を小さくして、入射・出射の方向（延長）を端まで見やすく</li>
    <li><b>出射点拡大</b>：出射点付近を拡大して、点線同士の角度（対頂角の $\phi$）を読み取りやすく</li>
    <li><b>光線束</b>：$k=0\sim 0.99$ の等間隔な複数光線を同時に描き、どの方向に光が集まりやすいかを直感的に確認</li>
  </ul>
  <p><b>理論式（$k$ から $\phi$）</b></p>
  <p>
    入射角 $i$ と屈折角 $r$ を
    \[
      i=\arcsin k,\qquad r=\arcsin\left(\frac{k}{n}\right)
    \]
    とすると、主虹（屈折→内部反射→出射）の出射方向は
    \[
      \phi(k)=4r-2i
      =4\arcsin\left(\frac{k}{n}\right)-2\arcsin(k)\quad(\mathrm{rad})
    \]
    です。度数表示では
    \[
      \phi_{\deg}(k)=\frac{180}{\pi}\left(4\arcsin\left(\frac{k}{n}\right)-2\arcsin(k)\right)
    \]
    となります（赤: $n=1.33$、青: $n=1.34$）。
  </p>
  <p><b>理論曲線（度数表示）</b></p>
  <canvas id="phi-plot" style="width:100%; height:260px; display:block;"></canvas>
  <script>
    (function(){
      const canvas = document.getElementById('phi-plot');
      if (!canvas) return;
      const nRed = 1.33, nBlue = 1.34;
      const kMin = 0.0, kMax = 0.99;

      function phiDeg(k, n) {
        const i = Math.asin(k);
        const r = Math.asin(k / n);
        return (180 / Math.PI) * (4 * r - 2 * i);
      }

      function draw() {
        const dpr = window.devicePixelRatio || 1;
        const rect = canvas.getBoundingClientRect();
        const cssW = Math.max(260, rect.width || 0);
        const cssH = Math.max(180, rect.height || 0);
        canvas.width = Math.floor(cssW * dpr);
        canvas.height = Math.floor(cssH * dpr);
        const ctx = canvas.getContext('2d');
        if (!ctx) return;
        ctx.setTransform(dpr, 0, 0, dpr, 0, 0);

        // compute ranges
        const samples = 220;
        let yMin = Infinity, yMax = -Infinity;
        const red = [];
        const blue = [];
        for (let s = 0; s < samples; s++) {
          const t = samples === 1 ? 0 : s / (samples - 1);
          const k = kMin + (kMax - kMin) * t;
          const yr = phiDeg(k, nRed);
          const yb = phiDeg(k, nBlue);
          red.push({k, y: yr});
          blue.push({k, y: yb});
          yMin = Math.min(yMin, yr, yb);
          yMax = Math.max(yMax, yr, yb);
        }
        const padY = (yMax - yMin) * 0.08 + 0.4;
        yMin -= padY;
        yMax += padY;

        // layout
        const m = {l: 46, r: 14, t: 12, b: 34};
        const W = cssW, H = cssH;
        const plotW = W - m.l - m.r;
        const plotH = H - m.t - m.b;

        function x(k){ return m.l + (k - kMin) / (kMax - kMin) * plotW; }
        function y(v){ return m.t + (yMax - v) / (yMax - yMin) * plotH; }

        // background
        ctx.clearRect(0, 0, W, H);
        ctx.fillStyle = 'rgba(255,255,255,1)';
        ctx.fillRect(0, 0, W, H);

        // grid + axes
        ctx.strokeStyle = 'rgba(0,0,0,0.12)';
        ctx.lineWidth = 1;
        ctx.beginPath();
        // x ticks
        const xTicks = [0, 0.25, 0.5, 0.75, 0.99];
        for (const xt of xTicks) {
          const xx = x(xt);
          ctx.moveTo(xx, m.t);
          ctx.lineTo(xx, m.t + plotH);
        }
        // y ticks
        const yTicks = 4;
        for (let i = 0; i <= yTicks; i++) {
          const vv = yMin + (yMax - yMin) * (i / yTicks);
          const yy = y(vv);
          ctx.moveTo(m.l, yy);
          ctx.lineTo(m.l + plotW, yy);
        }
        ctx.stroke();

        // axis lines
        ctx.strokeStyle = 'rgba(0,0,0,0.35)';
        ctx.beginPath();
        ctx.moveTo(m.l, m.t);
        ctx.lineTo(m.l, m.t + plotH);
        ctx.lineTo(m.l + plotW, m.t + plotH);
        ctx.stroke();

        // labels
        ctx.fillStyle = 'rgba(0,0,0,0.8)';
        ctx.font = '12px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'top';
        for (const xt of xTicks) {
          ctx.fillText(xt.toFixed(2), x(xt), m.t + plotH + 6);
        }
        ctx.textAlign = 'right';
        ctx.textBaseline = 'middle';
        for (let i = 0; i <= yTicks; i++) {
          const vv = yMin + (yMax - yMin) * (i / yTicks);
          ctx.fillText(vv.toFixed(1), m.l - 6, y(vv));
        }
        ctx.textAlign = 'left';
        ctx.textBaseline = 'top';
        ctx.fillText('k', m.l + plotW - 6, m.t + plotH + 6);
        ctx.fillText('φ [deg]', 6, m.t);

        // lines
        function drawLine(points, stroke) {
          ctx.strokeStyle = stroke;
          ctx.lineWidth = 2;
          ctx.beginPath();
          for (let i = 0; i < points.length; i++) {
            const p = points[i];
            const xx = x(p.k), yy = y(p.y);
            if (i === 0) ctx.moveTo(xx, yy);
            else ctx.lineTo(xx, yy);
          }
          ctx.stroke();
        }
        drawLine(red, 'rgba(220,40,40,0.95)');
        drawLine(blue, 'rgba(40,90,220,0.95)');

        // legend
        const lx = m.l + 10, ly = m.t + 10;
        ctx.fillStyle = 'rgba(255,255,255,0.85)';
        ctx.strokeStyle = 'rgba(0,0,0,0.15)';
        ctx.lineWidth = 1;
        ctx.fillRect(lx - 6, ly - 6, 150, 36);
        ctx.strokeRect(lx - 6, ly - 6, 150, 36);
        ctx.font = '12px sans-serif';
        ctx.textBaseline = 'middle';
        ctx.fillStyle = 'rgba(220,40,40,0.95)';
        ctx.fillText('red: n=1.33', lx, ly + 6);
        ctx.fillStyle = 'rgba(40,90,220,0.95)';
        ctx.fillText('blue: n=1.34', lx, ly + 22);
      }

      // draw now + on resize
      draw();
      window.addEventListener('resize', function(){ setTimeout(draw, 60); });
    })();
  </script>
  """,
  simulation: RainbowDroplet2DSimulation(),
  height: 780,
);

class RainbowDroplet2DSimulation extends WaveSimulation {
  RainbowDroplet2DSimulation()
      : super(
          title: "虹の光路 (単一水滴)",
          is3D: false,
          showTimeOverlay: false,
          enableTime: false,
        );

  @override
  Map<String, double> get initialParameters => const {
        'k': 0.82,
        'viewMode': 0.0,
        'bundleRed': 1.0,
        'bundleBlue': 1.0,
        'bundleColor0': 1.0,
        'bundleColor1': 1.0,
        'bundleColor2': 1.0,
        'bundleColor3': 1.0,
        'bundleColor4': 1.0,
        'bundleColor5': 1.0,
        'bundleColor6': 1.0,
      };

  @override
  List<Widget> buildControls(context, params, updateParam) {
    final metrics = _buildMetrics(params);
    final viewMode = _viewModeFromParams(params);
    final bundleSelection = _bundleSelectionFromParams(params);
    final multiColorSelection = _multiColorSelectionFromParams(params);
    void setBundleSelection({bool? red, bool? blue}) {
      var nextRed = red ?? bundleSelection.drawRed;
      var nextBlue = blue ?? bundleSelection.drawBlue;
      if (!nextRed && !nextBlue) {
        nextRed = true;
        nextBlue = true;
      }
      updateParam('bundleRed', nextRed ? 1.0 : 0.0);
      updateParam('bundleBlue', nextBlue ? 1.0 : 0.0);
    }
    void setMultiColorSelection(int colorIndex, bool selected) {
      final next = List<bool>.from(multiColorSelection.enabled);
      next[colorIndex] = selected;
      if (!next.contains(true)) {
        for (int i = 0; i < next.length; i++) {
          next[i] = true;
        }
      }
      for (int i = 0; i < next.length; i++) {
        updateParam(_multiColorParamKeys[i], next[i] ? 1.0 : 0.0);
      }
    }

    return [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ChoiceChip(
            label: const Text('通常'),
            selected: viewMode == _RainbowViewMode.normal,
            onSelected: (_) => updateParam('viewMode', 0.0),
          ),
          ChoiceChip(
            label: const Text('極小水滴'),
            selected: viewMode == _RainbowViewMode.tinyDroplet,
            onSelected: (_) => updateParam('viewMode', 1.0),
          ),
          ChoiceChip(
            label: const Text('出射点拡大'),
            selected: viewMode == _RainbowViewMode.exitZoom,
            onSelected: (_) => updateParam('viewMode', 2.0),
          ),
          ChoiceChip(
            label: const Text('光線束(単一)'),
            selected: viewMode == _RainbowViewMode.singleRayBundle,
            onSelected: (_) => updateParam('viewMode', 3.0),
          ),
          ChoiceChip(
            label: const Text('光線束(多水滴)'),
            selected: viewMode == _RainbowViewMode.multiRayBundle,
            onSelected: (_) => updateParam('viewMode', 4.0),
          ),
          ChoiceChip(
            label: const Text('多水滴極小'),
            selected: viewMode == _RainbowViewMode.multiRayBundleTiny,
            onSelected: (_) => updateParam('viewMode', 5.0),
          ),
        ],
      ),
      if (_isSingleBundleMode(viewMode))
        Wrap(
          spacing: 14,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              '描画色:',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            FilterChip(
              label: const Text('あか'),
              selected: bundleSelection.drawRed,
              onSelected: (v) => setBundleSelection(red: v),
              selectedColor: Colors.red.withOpacity(0.18),
              checkmarkColor: Colors.red.shade700,
            ),
            FilterChip(
              label: const Text('あお'),
              selected: bundleSelection.drawBlue,
              onSelected: (v) => setBundleSelection(blue: v),
              selectedColor: Colors.blue.withOpacity(0.18),
              checkmarkColor: Colors.blue.shade700,
            ),
          ],
        ),
      if (_isMultiBundleMode(viewMode))
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              '描画色:',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            for (int i = 0; i < _sevenColorPalette.length; i++)
              FilterChip(
                label: Text(_colorLabel(i)),
                selected: multiColorSelection.enabled[i],
                onSelected: (v) => setMultiColorSelection(i, v),
                selectedColor: _sevenColorPalette[i].withOpacity(0.20),
                checkmarkColor: _sevenColorPalette[i],
              ),
          ],
        ),
      if (!_isSingleBundleMode(viewMode) && !_isMultiBundleMode(viewMode))
        WaveParameterSlider(
          label: 'k',
          value: metrics.k,
          min: 0.0,
          max: 0.999,
          onChanged: (v) => updateParam('k', v),
        ),
      Text(
        '理論ピーク φ: 赤 ${metrics.redPeakPhi.toStringAsFixed(2)}° / 青 ${metrics.bluePeakPhi.toStringAsFixed(2)}°',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
    ];
  }

  @override
  Widget buildAnimation(
      context, time, azimuth, tilt, scale, params, activeIds) {
    final k = (params['k'] ?? 0.82).clamp(0.0, 0.999);
    final viewMode = _viewModeFromParams(params);
    final bundleSelection = _bundleSelectionFromParams(params);
    final showOverlayTex =
        !_isSingleBundleMode(viewMode) && !_isMultiBundleMode(viewMode);
    final multiColorSelection = _multiColorSelectionFromParams(params);
    final redPath = _RayOptics.computeRayPath(k, _RainbowDropletPainter.redN);
    final bluePath = _RayOptics.computeRayPath(k, _RainbowDropletPainter.blueN);
    final redPhiDeg =
        redPath == null ? 0.0 : _RayOptics.phiGeoDegFromPath(redPath);
    final bluePhiDeg =
        bluePath == null ? 0.0 : _RayOptics.phiGeoDegFromPath(bluePath);
    final overlayTex =
        'k=${k.toStringAsFixed(3)}\\quad '
        '{\\color{red}\\phi_{\\mathrm{red}}=${redPhiDeg.toStringAsFixed(2)}^\\circ}\\quad '
        '{\\color{blue}\\phi_{\\mathrm{blue}}=${bluePhiDeg.toStringAsFixed(2)}^\\circ}';

    return Stack(
      children: [
        CustomPaint(
          size: Size.infinite,
          painter:
              _RainbowDropletPainter(
            k: k,
            scale: scale,
            viewMode: viewMode,
            drawRed: bundleSelection.drawRed,
            drawBlue: bundleSelection.drawBlue,
            multiColorMask: multiColorSelection.mask,
          ),
        ),
        if (showOverlayTex)
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child: FormulaDisplay(
                  overlayTex,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  _RainbowMetrics _buildMetrics(Map<String, double> params) {
    final k = (params['k'] ?? 0.82).clamp(0.0, 0.999);
    final redPath = _RayOptics.computeRayPath(k, _RainbowDropletPainter.redN);
    final bluePath = _RayOptics.computeRayPath(k, _RainbowDropletPainter.blueN);
    final redPhiGeo = redPath == null ? 0.0 : _RayOptics.phiGeoDegFromPath(redPath);
    final bluePhiGeo =
        bluePath == null ? 0.0 : _RayOptics.phiGeoDegFromPath(bluePath);
    final redPhiTheory = _RayOptics.theoryPhiDeg(k, _RainbowDropletPainter.redN);
    final bluePhiTheory =
        _RayOptics.theoryPhiDeg(k, _RainbowDropletPainter.blueN);
    final redPeakPhi = _RayOptics.theoryPhiDeg(
      _RayOptics.peakK(_RainbowDropletPainter.redN),
      _RainbowDropletPainter.redN,
    );
    final bluePeakPhi = _RayOptics.theoryPhiDeg(
      _RayOptics.peakK(_RainbowDropletPainter.blueN),
      _RainbowDropletPainter.blueN,
    );
    return _RainbowMetrics(
      k: k,
      redPhiGeo: redPhiGeo,
      bluePhiGeo: bluePhiGeo,
      redPhiTheory: redPhiTheory,
      bluePhiTheory: bluePhiTheory,
      redPeakPhi: redPeakPhi,
      bluePeakPhi: bluePeakPhi,
    );
  }

  _RainbowViewMode _viewModeFromParams(Map<String, double> params) {
    final raw = (params['viewMode'] ?? 0.0).round().clamp(0, 5);
    return _RainbowViewMode.values[raw];
  }

  bool _isSingleBundleMode(_RainbowViewMode viewMode) {
    return viewMode == _RainbowViewMode.singleRayBundle;
  }

  bool _isMultiBundleMode(_RainbowViewMode viewMode) {
    return viewMode == _RainbowViewMode.multiRayBundle ||
        viewMode == _RainbowViewMode.multiRayBundleTiny;
  }

  _BundleSelection _bundleSelectionFromParams(Map<String, double> params) {
    var drawRed = (params['bundleRed'] ?? 1.0) >= 0.5;
    var drawBlue = (params['bundleBlue'] ?? 1.0) >= 0.5;
    if (!drawRed && !drawBlue) {
      drawRed = true;
      drawBlue = true;
    }
    return _BundleSelection(drawRed: drawRed, drawBlue: drawBlue);
  }

  _MultiColorSelection _multiColorSelectionFromParams(
      Map<String, double> params) {
    final enabled = List<bool>.generate(
      _multiColorParamKeys.length,
      (i) => (params[_multiColorParamKeys[i]] ?? 1.0) >= 0.5,
    );
    if (!enabled.contains(true)) {
      for (int i = 0; i < enabled.length; i++) {
        enabled[i] = true;
      }
    }
    var mask = 0;
    for (int i = 0; i < enabled.length; i++) {
      if (enabled[i]) {
        mask |= (1 << i);
      }
    }
    return _MultiColorSelection(enabled: enabled, mask: mask);
  }

  String _colorLabel(int i) {
    const labels = ['赤', '橙', '黄', '緑', '水', '青', '紫'];
    return labels[i];
  }
}

class _RainbowMetrics {
  final double k;
  final double redPhiGeo;
  final double bluePhiGeo;
  final double redPhiTheory;
  final double bluePhiTheory;
  final double redPeakPhi;
  final double bluePeakPhi;

  const _RainbowMetrics({
    required this.k,
    required this.redPhiGeo,
    required this.bluePhiGeo,
    required this.redPhiTheory,
    required this.bluePhiTheory,
    required this.redPeakPhi,
    required this.bluePeakPhi,
  });
}

class _RayPath {
  final Offset p1;
  final Offset p2;
  final Offset p3;
  final Offset outDir;

  const _RayPath({
    required this.p1,
    required this.p2,
    required this.p3,
    required this.outDir,
  });
}

class _RainbowDropletPainter extends CustomPainter {
  final double k;
  final double scale;
  final _RainbowViewMode viewMode;
  final bool drawRed;
  final bool drawBlue;
  final int multiColorMask;

  static const double _dropRadius = 1.0;
  static const double redN = 1.33;
  static const double blueN = 1.34;

  static const double _normalRadiusFactor = 0.40;
  static const double _tinyRadiusFactor = 0.018;
  static const double _singleBundleRadiusFactor = _tinyRadiusFactor * 3.0;
  static const double _multiTinyRadiusFactor = _tinyRadiusFactor / 5.0;
  static const double _exitZoomWorldZoom = 2.7;
  static const List<Color> _sevenColorPalette = <Color>[
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.cyan,
    Colors.blue,
    Colors.purple,
  ];

  const _RainbowDropletPainter({
    required this.k,
    required this.scale,
    required this.viewMode,
    required this.drawRed,
    required this.drawBlue,
    required this.multiColorMask,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final view = _computeView(size);

    if (viewMode == _RainbowViewMode.singleRayBundle) {
      _drawDroplet(canvas, size, view);
      _drawSingleRayBundle(
        canvas,
        size,
        view.worldToScreen,
        drawRed: drawRed,
        drawBlue: drawBlue,
      );
      return;
    }

    if (viewMode == _RainbowViewMode.multiRayBundle) {
      _drawMultiDropletRayBundle(
        canvas,
        size,
        view,
        dropletCount: 14,
        useSmoothGradient: false,
        spacingFactor: 1.03,
        xRatio: 0.875,
        topMarginRatio: 1.0 / 3.0,
      );
      return;
    }

    if (viewMode == _RainbowViewMode.multiRayBundleTiny) {
      _drawMultiDropletRayBundle(
        canvas,
        size,
        view,
        dropletCount: 28,
        useSmoothGradient: true,
        spacingFactor: 1.18,
        xRatio: 0.9375,
        topMarginRatio: 0.60,
      );
      return;
    }

    _drawDroplet(canvas, size, view);

    _drawColorPath(
      canvas: canvas,
      size: size,
      worldToScreen: view.worldToScreen,
      refractiveIndex: redN,
      color: Colors.red.withOpacity(0.7),
    );
    _drawColorPath(
      canvas: canvas,
      size: size,
      worldToScreen: view.worldToScreen,
      refractiveIndex: blueN,
      color: Colors.blue.withOpacity(0.7),
    );
  }

  void _drawSingleRayBundle(
    Canvas canvas,
    Size size,
    Offset Function(Offset) worldToScreen,
    {required bool drawRed, required bool drawBlue}
  ) {
    const count = 75;
    const kMin = 0.0;
    const kMax = 0.99;
    for (int i = 0; i < count; i++) {
      final t = count == 1 ? 0.0 : i / (count - 1);
      final kk = kMin + (kMax - kMin) * t;
      if (drawRed) {
        _drawThinRayForK(
          canvas,
          size,
          worldToScreen,
          kk,
          redN,
          Colors.red.withOpacity(0.20),
          dropletCenter: Offset.zero,
        );
      }
      if (drawBlue) {
        _drawThinRayForK(
          canvas,
          size,
          worldToScreen,
          kk,
          blueN,
          Colors.blue.withOpacity(0.20),
          dropletCenter: Offset.zero,
        );
      }
    }
  }

  void _drawMultiDropletRayBundle(
    Canvas canvas,
    Size size,
    _RainbowView view,
    {
    required int dropletCount,
    required bool useSmoothGradient,
    required double spacingFactor,
    required double xRatio,
    required double topMarginRatio,
  }
  ) {
    final centers = _buildDropletCenters(
      size,
      view,
      dropletCount: dropletCount,
      spacingFactor: spacingFactor,
      xRatio: xRatio,
      topMarginRatio: topMarginRatio,
    );
    for (int i = 0; i < centers.length; i++) {
      final dropletCenter = centers[i];
      final colorIndex = useSmoothGradient
          ? _gradientColorIndex(i, centers.length)
          : _groupColorIndex(i);
      if (!_isMultiColorEnabled(colorIndex)) {
        continue;
      }
      final color = useSmoothGradient
          ? _dropletGradientColor(i, centers.length)
          : _dropletGroupColor(i);
      final refractiveIndex = _dropletRefractiveIndex(i, centers.length);
      _drawSimpleDroplet(canvas, view, dropletCenter);
      _drawBundleForDroplet(
        canvas,
        size,
        view.worldToScreen,
        dropletCenter: dropletCenter,
        color: color,
        refractiveIndex: refractiveIndex,
      );
    }
  }

  List<Offset> _buildDropletCenters(
    Size size,
    _RainbowView view, {
    required int dropletCount,
    required double spacingFactor,
    required double xRatio,
    required double topMarginRatio,
  }) {
    final x = size.width * xRatio;

    // 水滴が「ギリギリ重ならない」程度: 直径の少し上を間隔にする
    final dropletDiameter = view.pixelsPerWorld * _dropRadius * 2.0;
    final step = dropletDiameter * spacingFactor;

    // 最上段は従来感覚の上余白の1/3まで寄せる
    final previousTopMargin = math.max(10.0, view.pixelsPerWorld * _dropRadius * 1.8);
    final yStart = previousTopMargin * topMarginRatio;

    return List<Offset>.generate(dropletCount, (i) {
      final y = yStart + step * i;
      return view.screenToWorld(Offset(x, y));
    });
  }

  Color _dropletGroupColor(int dropletIndex) {
    return _sevenColorPalette[_groupColorIndex(dropletIndex)];
  }

  Color _dropletGradientColor(int dropletIndex, int totalDroplets) {
    if (totalDroplets <= 1) return _sevenColorPalette.first;
    final t = dropletIndex / (totalDroplets - 1);
    final scaled = t * (_sevenColorPalette.length - 1);
    final lower = scaled.floor().clamp(0, _sevenColorPalette.length - 1);
    final upper = (lower + 1).clamp(0, _sevenColorPalette.length - 1);
    final localT = scaled - lower;
    return Color.lerp(
            _sevenColorPalette[lower], _sevenColorPalette[upper], localT) ??
        _sevenColorPalette[lower];
  }

  int _groupColorIndex(int dropletIndex) => (dropletIndex ~/ 2).clamp(0, 6);

  int _gradientColorIndex(int dropletIndex, int totalDroplets) {
    if (totalDroplets <= 1) return 0;
    final t = dropletIndex / (totalDroplets - 1);
    final idx = (t * _sevenColorPalette.length).floor();
    return idx.clamp(0, _sevenColorPalette.length - 1);
  }

  bool _isMultiColorEnabled(int colorIndex) {
    return (multiColorMask & (1 << colorIndex)) != 0;
  }

  void _drawSimpleDroplet(Canvas canvas, _RainbowView view, Offset centerWorld) {
    final center = view.worldToScreen(centerWorld);
    final radius = view.pixelsPerWorld * _dropRadius;
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF81D4FA).withOpacity(0.35);
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.lightBlue.shade200;
    canvas.drawCircle(center, radius, fill);
    canvas.drawCircle(center, radius, outline);
  }

  void _drawBundleForDroplet(
    Canvas canvas,
    Size size,
    Offset Function(Offset) worldToScreen, {
    required Offset dropletCenter,
    required Color color,
    required double refractiveIndex,
  }) {
    const count = 20;
    const kMin = 0.02;
    const kMax = 0.98;
    for (int i = 0; i < count; i++) {
      final t = count == 1 ? 0.0 : i / (count - 1);
      final kk = kMin + (kMax - kMin) * t;
      _drawThinRayForK(
        canvas,
        size,
        worldToScreen,
        kk,
        refractiveIndex,
        color.withOpacity(0.36),
        dropletCenter: dropletCenter,
      );
    }
  }

  double _dropletRefractiveIndex(int dropletIndex, int totalDroplets) {
    if (totalDroplets <= 1) return 1.33;
    final t = dropletIndex / (totalDroplets - 1);
    return 1.33 + (1.34 - 1.33) * t;
  }

  void _drawThinRayForK(
    Canvas canvas,
    Size size,
    Offset Function(Offset) worldToScreen,
    double kk,
    double refractiveIndex,
    Color color,
    {required Offset dropletCenter}
  ) {
    final path = _RayOptics.computeRayPath(
      kk,
      refractiveIndex,
      dropletCenter: dropletCenter,
    );
    if (path == null) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round
      ..color = color;

    final p1s = worldToScreen(path.p1);
    final p2s = worldToScreen(path.p2);
    final p3s = worldToScreen(path.p3);
    final outDirScreen = worldToScreen(path.p3 + path.outDir) - p3s;

    final incidentStart =
        _rayToCanvasEdge(p1s, const Offset(-1, 0), size) ?? p1s;
    final exitEnd = _rayToCanvasEdge(p3s, outDirScreen, size) ?? p3s;

    canvas.drawLine(incidentStart, p1s, paint);
    canvas.drawLine(p1s, p2s, paint);
    canvas.drawLine(p2s, p3s, paint);
    canvas.drawLine(p3s, exitEnd, paint);
  }

  _RainbowView _computeView(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height);

    var radiusFactor = _normalRadiusFactor;
    var worldZoom = 1.0;
    var focusWorld = Offset.zero;
    Offset? exitFocusPoint;

    if (viewMode == _RainbowViewMode.tinyDroplet) {
      radiusFactor = _tinyRadiusFactor;
    } else if (viewMode == _RainbowViewMode.singleRayBundle) {
      radiusFactor = _singleBundleRadiusFactor;
    } else if (viewMode == _RainbowViewMode.multiRayBundle) {
      radiusFactor = _tinyRadiusFactor;
    } else if (viewMode == _RainbowViewMode.multiRayBundleTiny) {
      radiusFactor = _multiTinyRadiusFactor;
    } else if (viewMode == _RainbowViewMode.exitZoom) {
      radiusFactor = _normalRadiusFactor;
      worldZoom = _exitZoomWorldZoom;
      final redPath = _RayOptics.computeRayPath(k, redN);
      final bluePath = _RayOptics.computeRayPath(k, blueN);
      exitFocusPoint = redPath?.p3 ?? bluePath?.p3 ?? Offset.zero;
      focusWorld = exitFocusPoint;
    }

    final pixelRadius = baseRadius * radiusFactor;
    final pixelsPerWorld = pixelRadius * scale * worldZoom;

    Offset worldToScreen(Offset p) {
      return Offset(
        center.dx + (p.dx - focusWorld.dx) * pixelsPerWorld,
        center.dy - (p.dy - focusWorld.dy) * pixelsPerWorld,
      );
    }
    Offset screenToWorld(Offset p) {
      return Offset(
        (p.dx - center.dx) / pixelsPerWorld + focusWorld.dx,
        (center.dy - p.dy) / pixelsPerWorld + focusWorld.dy,
      );
    }

    return _RainbowView(
      center: center,
      pixelsPerWorld: pixelsPerWorld,
      worldToScreen: worldToScreen,
      screenToWorld: screenToWorld,
      exitFocusPoint: exitFocusPoint,
    );
  }

  void _drawDroplet(Canvas canvas, Size size, _RainbowView view) {
    final dropletCenter = view.worldToScreen(Offset.zero);
    final dropletRadius = view.pixelsPerWorld * _dropRadius;

    if (viewMode != _RainbowViewMode.exitZoom) {
      final fill = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF81D4FA).withOpacity(0.35);
      final outline = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.lightBlue.shade200;
      canvas.drawCircle(dropletCenter, dropletRadius, fill);
      canvas.drawCircle(dropletCenter, dropletRadius, outline);
      return;
    }

    // exitZoom: 測角点(p3)を通る境界弧と、水側（円内部）を塗る
    final p3World = view.exitFocusPoint ?? Offset.zero;
    final p3Screen = view.worldToScreen(p3World);

    final circleRect = Rect.fromCircle(center: dropletCenter, radius: dropletRadius);
    final boundaryAngle = math.atan2(
      p3Screen.dy - dropletCenter.dy,
      p3Screen.dx - dropletCenter.dx,
    );

    const span = 1.95; // 境界弧の開き角
    final startAngle = boundaryAngle - span / 2;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF4FC3F7).withOpacity(0.30);
    final boundaryColor = Colors.lightBlue.shade600.withOpacity(0.95);
    final boundaryPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..color = boundaryColor;

    // p3近傍のみ表示（他所に出る大きな弧を抑制）
    // 拡大モードでは余白を減らして、より広い範囲に水滴を見せる
    final clipSize = math.min(size.width, size.height) * 0.92;
    final localClip =
        Rect.fromCenter(center: p3Screen, width: clipSize, height: clipSize);
    canvas.save();
    canvas.clipRect(localClip);
    canvas.drawCircle(dropletCenter, dropletRadius, fillPaint);
    canvas.drawArc(circleRect, startAngle, span, false, boundaryPaint);
    canvas.restore();
  }

  void _drawColorPath({
    required Canvas canvas,
    required Size size,
    required Offset Function(Offset) worldToScreen,
    required double refractiveIndex,
    required Color color,
  }) {
    final path = _RayOptics.computeRayPath(k, refractiveIndex);
    if (path == null) return;

    final rayPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = color;

    final p1s = worldToScreen(path.p1);
    final p2s = worldToScreen(path.p2);
    final p3s = worldToScreen(path.p3);
    final outDirScreen = worldToScreen(path.p3 + path.outDir) - p3s;
    final isTinyMode = viewMode == _RainbowViewMode.tinyDroplet;

    // 左から水平入射する前置きの線分
    final incidentStart = isTinyMode
        ? _rayToCanvasEdge(p1s, const Offset(-1, 0), size) ?? p1s
        : worldToScreen(Offset(path.p1.dx - 1.3, path.p1.dy));
    _drawArrowedLine(
      canvas,
      incidentStart,
      p1s,
      rayPaint,
      arrowPosition: isTinyMode ? 0.72 : 0.58,
    );

    // 水滴内: 屈折 -> 内部反射 -> 出射点まで
    _drawArrowedLine(
      canvas,
      p1s,
      p2s,
      rayPaint,
    );
    _drawArrowedLine(
      canvas,
      p2s,
      p3s,
      rayPaint,
    );

    // 出射光（実線）
    final exitEnd = isTinyMode
        ? _rayToCanvasEdge(p3s, outDirScreen, size) ?? p3s
        : worldToScreen(path.p3 + path.outDir * 1.6);
    _drawArrowedLine(
      canvas,
      p3s,
      exitEnd,
      rayPaint,
      arrowPosition: isTinyMode ? 0.72 : 0.58,
    );

    final helperPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color.withOpacity(0.85);

    // 出射点を通る水平基準線（点線）
    final horizontalY = p3s.dy;
    final horizontalStart = isTinyMode
        ? Offset(0, horizontalY)
        : worldToScreen(Offset(path.p3.dx - 1.0, path.p3.dy));
    final horizontalEnd = isTinyMode
        ? Offset(size.width, horizontalY)
        : worldToScreen(Offset(path.p3.dx + 1.0, path.p3.dy));
    _drawDashedLine(
      canvas,
      horizontalStart,
      horizontalEnd,
      helperPaint,
    );

    // 出射光の後方延長（点線）
    final backEnd = isTinyMode
        ? _rayToCanvasEdge(p3s, -outDirScreen, size) ?? p3s
        : worldToScreen(path.p3 - path.outDir * 1.0);
    _drawDashedLine(
      canvas,
      p3s,
      backEnd,
      helperPaint,
    );

    if (viewMode == _RainbowViewMode.exitZoom ||
        viewMode == _RainbowViewMode.normal ||
        viewMode == _RainbowViewMode.tinyDroplet) {
      final arcScale = (viewMode == _RainbowViewMode.tinyDroplet ||
              viewMode == _RainbowViewMode.exitZoom)
          ? 6.0
          : 3.0;
      _drawPhiArc(
        canvas,
        vertex: p3s,
        lineDir: const Offset(1, 0),
        rayDir: -outDirScreen,
        color: color,
        arcRadius: (refractiveIndex == redN ? 34.0 : 26.0) * arcScale,
        useVerticalAngle: true,
      );
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    final delta = end - start;
    final len = delta.distance;
    if (len <= 0.0) return;
    final unit = delta / len;
    const dash = 7.0;
    const gap = 5.0;
    double d = 0.0;
    while (d < len) {
      final s = start + unit * d;
      final e = start + unit * math.min(d + dash, len);
      canvas.drawLine(s, e, paint);
      d += dash + gap;
    }
  }

  void _drawArrowedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    {double arrowPosition = 0.58}
  ) {
    canvas.drawLine(start, end, paint);

    final delta = end - start;
    final len = delta.distance;
    if (len <= 1e-6) return;

    final dir = delta / len;
    const arrowLength = 9.0;
    const arrowAngle = 28.0 * math.pi / 180.0;

    final tip = start + delta * arrowPosition;
    final left = tip - _rotate(dir, arrowAngle) * arrowLength;
    final right = tip - _rotate(dir, -arrowAngle) * arrowLength;
    canvas.drawLine(tip, left, paint);
    canvas.drawLine(tip, right, paint);
  }

  Offset _rotate(Offset v, double rad) {
    final c = math.cos(rad);
    final s = math.sin(rad);
    return Offset(
      v.dx * c - v.dy * s,
      v.dx * s + v.dy * c,
    );
  }

  Offset? _rayToCanvasEdge(Offset start, Offset dir, Size size) {
    const eps = 1e-6;
    final dLen = dir.distance;
    if (dLen <= eps) return null;
    final unit = dir / dLen;
    final w = size.width;
    final h = size.height;
    final candidates = <double>[];

    void addT(double t) {
      if (t > eps && t.isFinite) {
        candidates.add(t);
      }
    }

    if (unit.dx.abs() > eps) {
      addT((0 - start.dx) / unit.dx);
      addT((w - start.dx) / unit.dx);
    }
    if (unit.dy.abs() > eps) {
      addT((0 - start.dy) / unit.dy);
      addT((h - start.dy) / unit.dy);
    }
    if (candidates.isEmpty) return null;

    double? bestT;
    for (final t in candidates) {
      final p = start + unit * t;
      final inBounds =
          p.dx >= -0.5 && p.dx <= w + 0.5 && p.dy >= -0.5 && p.dy <= h + 0.5;
      if (!inBounds) continue;
      if (bestT == null || t < bestT) bestT = t;
    }
    if (bestT == null) return null;
    return start + unit * bestT;
  }

  void _drawPhiArc(
    Canvas canvas,
    {
    required Offset vertex,
    required Offset lineDir,
    required Offset rayDir,
    required Color color,
    required double arcRadius,
    bool useVerticalAngle = false,
  }) {
    if (lineDir.distance <= 1e-6 || rayDir.distance <= 1e-6) return;

    final lineAngle = math.atan2(lineDir.dy, lineDir.dx);
    final oppositeLineAngle = _normalizeAngle(lineAngle + math.pi);
    final rayAngle = math.atan2(rayDir.dy, rayDir.dx);

    final delta1 = _normalizeSignedAngle(rayAngle - lineAngle);
    final delta2 = _normalizeSignedAngle(rayAngle - oppositeLineAngle);
    final usePrimary = delta1.abs() <= delta2.abs();
    var startAngle = usePrimary ? lineAngle : oppositeLineAngle;
    final sweep = usePrimary ? delta1 : delta2;
    if (useVerticalAngle) {
      // 対頂角（反対側の同じ角）として描く：両方の半直線をπだけ回転した位置に移す
      startAngle = _normalizeAngle(startAngle + math.pi);
    }
    final center = vertex;

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcRadius),
      startAngle,
      sweep,
      false,
      arcPaint,
    );

    final midAngle = startAngle + sweep * 0.5;
    final label = TextPainter(
      text: TextSpan(
        text: 'φ',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final labelCenter = center +
        Offset(
          math.cos(midAngle) * (arcRadius + 10),
          math.sin(midAngle) * (arcRadius + 10),
        );
    label.paint(
      canvas,
      labelCenter - Offset(label.width / 2, label.height / 2),
    );
  }

  double _normalizeAngle(double a) {
    var out = a;
    while (out > math.pi) out -= 2 * math.pi;
    while (out < -math.pi) out += 2 * math.pi;
    return out;
  }

  double _normalizeSignedAngle(double a) {
    var out = a;
    while (out > math.pi) out -= 2 * math.pi;
    while (out < -math.pi) out += 2 * math.pi;
    return out;
  }

  @override
  bool shouldRepaint(covariant _RainbowDropletPainter oldDelegate) {
    return oldDelegate.k != k ||
        oldDelegate.scale != scale ||
        oldDelegate.viewMode != viewMode ||
        oldDelegate.drawRed != drawRed ||
        oldDelegate.drawBlue != drawBlue ||
        oldDelegate.multiColorMask != multiColorMask;
  }
}

class _RainbowView {
  final Offset center;
  final double pixelsPerWorld;
  final Offset Function(Offset) worldToScreen;
  final Offset Function(Offset) screenToWorld;
  final Offset? exitFocusPoint;

  const _RainbowView({
    required this.center,
    required this.pixelsPerWorld,
    required this.worldToScreen,
    required this.screenToWorld,
    required this.exitFocusPoint,
  });
}

enum _RainbowViewMode {
  normal,
  tinyDroplet,
  exitZoom,
  singleRayBundle,
  multiRayBundle,
  multiRayBundleTiny,
}

class _BundleSelection {
  final bool drawRed;
  final bool drawBlue;

  const _BundleSelection({
    required this.drawRed,
    required this.drawBlue,
  });
}

class _MultiColorSelection {
  final List<bool> enabled;
  final int mask;

  const _MultiColorSelection({
    required this.enabled,
    required this.mask,
  });
}

const List<String> _multiColorParamKeys = <String>[
  'bundleColor0',
  'bundleColor1',
  'bundleColor2',
  'bundleColor3',
  'bundleColor4',
  'bundleColor5',
  'bundleColor6',
];

const List<Color> _sevenColorPalette = <Color>[
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.cyan,
  Colors.blue,
  Colors.purple,
];
