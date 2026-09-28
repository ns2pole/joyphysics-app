import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// 鉛直直径まわりに一定角速度で回る滑らかな円環上のビーズ。
/// 底から測った角 $\theta$ の運動方程式は
/// $\ddot\theta=\sin\theta\bigl(\omega^{2}\cos\theta-g/R\bigr)$。
const double kRingG = 9.80;
const double kRingMinR = 0.40;
const double kRingMaxR = 1.20;
const double kRingDefaultR = 0.80;
const double kRingMinOmega = 0.40;
const double kRingMaxOmega = 6.00;
const double kRingDefaultOmega = 4.20;
const double kRingMinM = 0.50;
const double kRingMaxM = 4.00;
const double kRingDefaultM = 1.00;
const double kRingMinTheta0 = 0.05;
const double kRingMaxTheta0 = math.pi - 0.05;
const double kRingDefaultTheta0 = 0.35;
const double kRingMinThetaDot0 = -4.00;
const double kRingMaxThetaDot0 = 4.00;
const double kRingDefaultThetaDot0 = 0.00;
const double kRingSideBySideWidth = 640.0;
const double kRingPlayback = 0.55;
const double kRingDt = 1.0 / 240.0;

class RingBeadParams {
  const RingBeadParams({
    required this.r,
    required this.omega,
    required this.mass,
    required this.theta0,
    required this.thetaDot0,
  });

  final double r;
  final double omega;
  final double mass;
  final double theta0;
  final double thetaDot0;

  /// $\omega^{2}>g/R$ のとき実在する斜めつり合いの $\cos\theta$。
  double? get equilibriumCos {
    final c = kRingG / (omega * omega * r);
    if (c >= 1) return null;
    return c;
  }

  double? get equilibriumTheta {
    final c = equilibriumCos;
    if (c == null) return null;
    return math.acos(c);
  }

  factory RingBeadParams.fromMap(Map<String, double> params) {
    return RingBeadParams(
      r: params['r']!.clamp(kRingMinR, kRingMaxR).toDouble(),
      omega: params['W']!.clamp(kRingMinOmega, kRingMaxOmega).toDouble(),
      mass: params['m']!.clamp(kRingMinM, kRingMaxM).toDouble(),
      theta0: params['th0']!.clamp(kRingMinTheta0, kRingMaxTheta0).toDouble(),
      thetaDot0:
          params['thd0']!.clamp(kRingMinThetaDot0, kRingMaxThetaDot0).toDouble(),
    );
  }
}

class RingBeadPhase {
  const RingBeadPhase({
    required this.t,
    required this.theta,
    required this.thetaDot,
  });

  final double t;
  final double theta;
  final double thetaDot;
}

class RingBeadSample {
  const RingBeadSample({
    required this.t,
    required this.phi,
    required this.theta,
    required this.thetaDot,
    required this.thetaDDot,
    required this.gravityTangential,
    required this.centrifugalTangential,
    required this.x,
    required this.y,
    required this.z,
    required this.xRot,
    required this.yRot,
    required this.zRot,
  });

  final double t;

  /// 円環の回転角（慣性系）。$\phi=\omega t$。
  final double phi;
  final double theta;
  final double thetaDot;
  final double thetaDDot;

  /// 接線方向（$\theta$ 増方向）の力。回転系。
  final double gravityTangential;
  final double centrifugalTangential;

  /// 慣性系の直交座標。
  final double x;
  final double y;
  final double z;

  /// 円環と一緒に回る系。円環は $xz$ 面に固定。
  final double xRot;
  final double yRot;
  final double zRot;

  double get forceTangential => gravityTangential + centrifugalTangential;
}

/// $\ddot\theta=\sin\theta(\omega^{2}\cos\theta-g/R)$
double ringBeadAccel(RingBeadParams params, double theta) {
  final s = math.sin(theta);
  final c = math.cos(theta);
  return s * (params.omega * params.omega * c - kRingG / params.r);
}

RingBeadPhase ringBeadStep(RingBeadPhase phase, RingBeadParams params, double dt) {
  final th = phase.theta;
  final w = phase.thetaDot;
  final h = dt;

  double a(double theta) => ringBeadAccel(params, theta);

  final k1Th = w;
  final k1W = a(th);

  final k2Th = w + 0.5 * h * k1W;
  final k2W = a(th + 0.5 * h * k1Th);

  final k3Th = w + 0.5 * h * k2W;
  final k3W = a(th + 0.5 * h * k2Th);

  final k4Th = w + h * k3W;
  final k4W = a(th + h * k3Th);

  var nextTh = th + (h / 6) * (k1Th + 2 * k2Th + 2 * k3Th + k4Th);
  var nextW = w + (h / 6) * (k1W + 2 * k2W + 2 * k3W + k4W);

  // 頂点を越えても円環上にいるので角度は折り返さず周期化する。
  nextTh = nextTh % (2 * math.pi);
  if (nextTh < 0) nextTh += 2 * math.pi;
  // 描画・説明は底から測った $[0,\pi]$ 側を主に見せるが、運動は全周可。
  return RingBeadPhase(t: phase.t + dt, theta: nextTh, thetaDot: nextW);
}

RingBeadPhase ringBeadIntegrate(
  RingBeadParams params,
  double t, {
  double dt = kRingDt,
}) {
  var phase = RingBeadPhase(
    t: 0,
    theta: params.theta0,
    thetaDot: params.thetaDot0,
  );
  final target = math.max(0.0, t);
  while (phase.t + dt <= target + 1e-12) {
    phase = ringBeadStep(phase, params, dt);
  }
  final rem = target - phase.t;
  if (rem > 1e-12) {
    phase = ringBeadStep(phase, params, rem);
  }
  return phase;
}

RingBeadSample ringBeadSampleAt(RingBeadParams params, RingBeadPhase phase) {
  final th = phase.theta;
  final phi = params.omega * phase.t;
  final s = math.sin(th);
  final c = math.cos(th);
  final xRot = params.r * s;
  const yRot = 0.0;
  final zRot = -params.r * c;
  final cp = math.cos(phi);
  final sp = math.sin(phi);
  final x = xRot * cp - yRot * sp;
  final y = xRot * sp + yRot * cp;
  final z = zRot;
  final gT = -params.mass * kRingG * s;
  final cenT = params.mass * params.omega * params.omega * params.r * s * c;
  return RingBeadSample(
    t: phase.t,
    phi: phi,
    theta: th,
    thetaDot: phase.thetaDot,
    thetaDDot: ringBeadAccel(params, th),
    gravityTangential: gT,
    centrifugalTangential: cenT,
    x: x,
    y: y,
    z: z,
    xRot: xRot,
    yRot: yRot,
    zRot: zRot,
  );
}

String ringBeadCaption(RingBeadParams params) {
  final eq = params.equilibriumTheta;
  if (eq == null) {
    return 'ω が小さいと底が安定。ビーズは底のまわりで揺れる。';
  }
  return 'ω が大きいと θ≈${eq.toStringAsFixed(2)} rad が安定。\n'
      'そこへ向かって円環上を動く。';
}

final beadOnRotatingRing3D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '回転する円環上のビーズ',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>鉛直な円環が、鉛直直径まわりに一定の角速度 $\omega$ で回ります。円環は滑らかで、ビーズは円環に沿ってだけ動けます。広い画面では左右、狭い画面では上下です。上または左が地上（慣性系）、下または右が円環と一緒に回る座標系です。</p>
  <p>底から測った角を $\theta$ とすると、運動方程式は</p>
  <p>$$\ddot{\theta}=\sin\theta\left(\omega^{2}\cos\theta-\frac{g}{R}\right)$$</p>
  <p>円環と一緒に回る人から見ると、円環は止まっています。接線方向に効くのは重力と遠心力だけです。ビーズの速さがあるときのコリオリ力は円環の面に垂直なので、拘束力が受け持ち、$\theta$ の式には入りません。</p>
  <p>$\omega^{2}&gt;g/R$ のとき、$\displaystyle\cos\theta=\frac{g}{\omega^{2}R}$ の位置が安定なつり合いになります。$\omega$ が小さいときは底 $\theta=0$ が安定です。</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: BeadOnRotatingRing3DSimulation(),
      height: 980,
    ),
  ],
);

class BeadOnRotatingRing3DSimulation extends PhysicsSimulation {
  BeadOnRotatingRing3DSimulation()
      : super(
          title: '回転する円環上のビーズ',
          formula: const FormulaDisplay(
            r'\displaystyle \ddot{\theta}=\sin\theta\Bigl(\omega^{2}\cos\theta-\frac{g}{R}\Bigr)',
          ),
          aspectRatio: 0.72,
          enableTime: false,
          showTimeOverlay: false,
        );

  final ValueNotifier<double> simTime = ValueNotifier(0.0);
  RingBeadPhase _phase = const RingBeadPhase(t: 0, theta: kRingDefaultTheta0, thetaDot: 0);
  RingBeadParams? _frozen;
  Map<String, double> _latestParams = {};

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    final p = _frozen ?? _params;
    final steps = math.max(1, (dt * kRingPlayback / kRingDt).ceil());
    final step = dt * kRingPlayback / steps;
    var phase = _phase;
    for (var i = 0; i < steps; i++) {
      phase = ringBeadStep(phase, p, step);
    }
    _phase = phase;
    simTime.value = phase.t;
  });

  bool _didAutoStart = false;

  void _ensureAutoStart() {
    if (_didAutoStart) return;
    _didAutoStart = true;
    // 開いた瞬間から円環が回って見えるようにする。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_loop.running.value) start();
    });
  }

  @override
  String? get situation =>
      '鉛直直径まわりに一定角速度で回る滑らかな円環に拘束されたビーズ';

  ValueNotifier<bool> get running => _loop.running;

  RingBeadParams get _params {
    if (_latestParams.isEmpty) {
      return RingBeadParams.fromMap(initialParameters);
    }
    return RingBeadParams.fromMap(_latestParams);
  }

  void _rememberParams(Map<String, double> params) {
    _latestParams = Map<String, double>.from(params);
  }

  void _syncPhaseToIcs(RingBeadParams p) {
    if (running.value) return;
    _phase = RingBeadPhase(t: 0, theta: p.theta0, thetaDot: p.thetaDot0);
    simTime.value = 0;
  }

  void start() {
    if (running.value) return;
    _frozen = _params;
    _phase = RingBeadPhase(
      t: 0,
      theta: _frozen!.theta0,
      thetaDot: _frozen!.thetaDot0,
    );
    simTime.value = 0;
    _loop.start();
  }

  void pause() => _loop.pause();

  void resetMotion() {
    _loop.reset();
    _frozen = null;
    final p = _params;
    _phase = RingBeadPhase(t: 0, theta: p.theta0, thetaDot: p.thetaDot0);
    simTime.value = 0;
  }

  @override
  double aspectRatioForWidth(double width) {
    return width >= kRingSideBySideWidth ? 1.85 : 0.72;
  }

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'r': kRingDefaultR,
        'W': kRingDefaultOmega,
        'm': kRingDefaultM,
        'th0': kRingDefaultTheta0,
        'thd0': kRingDefaultThetaDot0,
      };

  @override
  Widget? buildExtraControls(
    BuildContext context,
    Set<String> activeIds,
    void Function(Set<String> ids) updateActiveIds,
  ) {
    return ValueListenableBuilder<bool>(
      valueListenable: running,
      builder: (context, isRunning, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ringBeadCaption(_params),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Color(0xFF546E7A),
              ),
            ),
            const SizedBox(height: 8),
            PlayPauseResetButtons(
              playing: isRunning,
              onPlayPause: isRunning ? pause : start,
              onReset: resetMotion,
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
    final p = _params;
    if (!running.value) _syncPhaseToIcs(p);
    final eq = p.equilibriumTheta;
    return [
      const Text(
        '滑らかな円環・鉛直直径まわりに一定 ω',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _RingSlider(
        label: 'R',
        value: p.r,
        min: kRingMinR,
        max: kRingMaxR,
        onChanged: (v) => updateParam('r', v),
        semanticLabel: '半径 R',
      ),
      _RingSlider(
        label: 'ω',
        value: p.omega,
        min: kRingMinOmega,
        max: kRingMaxOmega,
        onChanged: (v) => updateParam('W', v),
        semanticLabel: '角速度 ω',
      ),
      _RingSlider(
        label: 'm',
        value: p.mass,
        min: kRingMinM,
        max: kRingMaxM,
        onChanged: (v) => updateParam('m', v),
        semanticLabel: '質量 m',
      ),
      _RingSlider(
        label: 'θ₀',
        value: p.theta0,
        min: kRingMinTheta0,
        max: kRingMaxTheta0,
        onChanged: (v) => updateParam('th0', v),
        semanticLabel: '初期角 θ0',
      ),
      _RingSlider(
        label: 'θ̇₀',
        value: p.thetaDot0,
        min: kRingMinThetaDot0,
        max: kRingMaxThetaDot0,
        onChanged: (v) => updateParam('thd0', v),
        semanticLabel: '初期角速度 θドット0',
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          eq == null
              ? 'g/R = ${(kRingG / p.r).toStringAsFixed(2)}    '
                  'ω² = ${(p.omega * p.omega).toStringAsFixed(2)}  → 底が安定'
              : 'つり合い θ = ${eq.toStringAsFixed(2)} rad    '
                  'ω²R/g = ${(p.omega * p.omega * p.r / kRingG).toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Courier',
            color: Color(0xFF37474F),
          ),
        ),
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
    _ensureAutoStart();
    return AnimatedBuilder(
      animation: Listenable.merge([running, simTime]),
      builder: (context, _) {
        final p = _frozen ?? RingBeadParams.fromMap(parameters);
        final sample = ringBeadSampleAt(p, _phase);
        return CustomPaint(
          size: Size.infinite,
          painter: _RingBeadPainter(params: p, sample: sample),
        );
      },
    );
  }
}

class _RingSlider extends StatelessWidget {
  const _RingSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.semanticLabel,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 36,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Semantics(
            label: semanticLabel,
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
              semanticFormatterCallback: (v) =>
                  '$semanticLabel ${v.toStringAsFixed(2)}',
            ),
          ),
        ),
        SizedBox(
          width: 52,
          child: Text(
            value.toStringAsFixed(2),
            style: const TextStyle(fontSize: 12, fontFamily: 'Courier'),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _RingBeadPainter extends CustomPainter {
  _RingBeadPainter({
    required this.params,
    required this.sample,
  });

  final RingBeadParams params;
  final RingBeadSample sample;

  static const _bg = Color(0xFFF4F7FA);
  static const _ink = Color(0xFF37474F);
  static const _muted = Color(0xFF546E7A);
  static const _bead = Color(0xFFE53935);
  static const _ringA = Color(0xFF1565C0);
  static const _ringB = Color(0xFFFFB300);
  static const _axis = Color(0xFF78909C);
  static const _gravity = Color(0xFF5D4037);
  static const _centrifugal = Color(0xFF2E7D32);
  static const _floorA = Color(0xFFE8E0D4);
  static const _floorB = Color(0xFFD4C6B4);
  static const _eq = Color(0xFF00897B);

  // 固定カメラ。クルクル感が出る斜め上からの視点。
  static const double _az = 0.55;
  static const double _tilt = 0.62;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final sideBySide =
        size.width >= kRingSideBySideWidth && size.width > size.height;
    if (sideBySide) {
      const gap = 8.0;
      final w = (size.width - gap) / 2;
      _panel(canvas, Rect.fromLTWH(0, 0, w, size.height), ground: true);
      _panel(canvas, Rect.fromLTWH(w + gap, 0, w, size.height), ground: false);
    } else {
      const gap = 8.0;
      final h = (size.height - gap) / 2;
      _panel(canvas, Rect.fromLTWH(0, 0, size.width, h), ground: true);
      _panel(canvas, Rect.fromLTWH(0, h + gap, size.width, h), ground: false);
    }
  }

  void _panel(Canvas canvas, Rect panel, {required bool ground}) {
    canvas.save();
    canvas.clipRect(panel);
    final plot = Rect.fromLTRB(
      panel.left + 10,
      panel.top + 28,
      panel.right - 10,
      panel.bottom - 30,
    );
    final unit = math.min(plot.width, plot.height) / (2.9 * kRingMaxR);
    Offset proj(double x, double y, double z) {
      final cA = math.cos(_az);
      final sA = math.sin(_az);
      final cT = math.cos(_tilt);
      final sT = math.sin(_tilt);
      final xr = x * cA - y * sA;
      final yr = x * sA + y * cA;
      final px = plot.center.dx + (yr - xr) * 0.72 * unit;
      final py = plot.center.dy + (xr + yr) * 0.42 * sT * unit - z * cT * unit;
      return Offset(px, py);
    }

    _drawFloor(canvas, plot, proj, unit, ground: ground);
    canvas.drawRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFCFD8DC),
    );
    _text(
      canvas,
      Offset(panel.left + 8, panel.top + 6),
      ground ? '地上（慣性系）' : '円環と一緒に回る系',
      _ink,
      alignLeft: true,
    );
    _scene(canvas, proj, unit, ground: ground);
    _text(
      canvas,
      Offset(panel.center.dx, panel.bottom - 18),
      ground
          ? '円環が鉛直軸まわりにクルクル回る。'
          : '円環は止まり、遠心力でビーズが動く。',
      _muted,
    );
    canvas.restore();
  }

  void _scene(
    Canvas canvas,
    Offset Function(double x, double y, double z) proj,
    double unit, {
    required bool ground,
  }) {
    final r = params.r;
    final phi = ground ? sample.phi : 0.0;

    // 鉛直軸
    final top = proj(0, 0, r * 1.15);
    final bottom = proj(0, 0, -r * 1.15);
    canvas.drawLine(
      top,
      bottom,
      Paint()
        ..color = _axis
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    _omegaBadge(canvas, top, ground: ground);

    // 円環（縞模様で回転が分かる）
    _drawHoop(canvas, proj, r, phi, unit);

    // 安定つり合いの目印（回転系のみ・存在するとき）
    final eq = params.equilibriumTheta;
    if (!ground && eq != null) {
      for (final sign in [1.0, -1.0]) {
        final th = sign > 0 ? eq : (2 * math.pi - eq);
        final p = _beadWorld(r, th, 0);
        final o = proj(p.$1, p.$2, p.$3);
        canvas.drawCircle(
          o,
          5,
          Paint()
            ..color = _eq.withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }

    final beadTh = sample.theta;
    final bead = ground
        ? (sample.x, sample.y, sample.z)
        : (sample.xRot, sample.yRot, sample.zRot);
    final beadO = proj(bead.$1, bead.$2, bead.$3);

    if (!ground) {
      _drawRotatingForces(canvas, proj, beadO, unit);
    } else {
      final nextPhi = phi + params.omega * 0.08;
      final next = _beadWorld(r, beadTh + sample.thetaDot * 0.08, nextPhi);
      final v = proj(next.$1, next.$2, next.$3) - beadO;
      if (v.distance > 2) {
        _arrow(canvas, beadO, v / v.distance, 36, _gravity, '運動');
      }
    }

    canvas.drawCircle(beadO.translate(1.4, 1.6), 10, Paint()..color = Colors.black26);
    canvas.drawCircle(beadO, 9, Paint()..color = _bead);
    canvas.drawCircle(
      beadO.translate(-2.5, -2.5),
      2.5,
      Paint()..color = Colors.white70,
    );

    _text(
      canvas,
      Offset(proj(0, 0, -r * 1.15).dx, proj(0, 0, -r * 1.15).dy + 14),
      'θ=${_fmtTheta(sample.theta)}',
      _ink,
    );
  }

  (double, double, double) _beadWorld(double r, double theta, double phi) {
    final s = math.sin(theta);
    final c = math.cos(theta);
    final x0 = r * s;
    final z = -r * c;
    final cp = math.cos(phi);
    final sp = math.sin(phi);
    return (x0 * cp, x0 * sp, z);
  }

  void _drawHoop(
    Canvas canvas,
    Offset Function(double x, double y, double z) proj,
    double r,
    double phi,
    double unit,
  ) {
    const n = 72;
    final pts = <({Offset o, double depth, int i})>[];
    for (var i = 0; i <= n; i++) {
      final th = 2 * math.pi * i / n;
      final w = _beadWorld(r, th, phi);
      // depth: カメラ前方ほど大きい（簡易）
      final cA = math.cos(_az);
      final sA = math.sin(_az);
      final depth = w.$1 * sA + w.$2 * cA;
      pts.add((o: proj(w.$1, w.$2, w.$3), depth: depth, i: i));
    }
    // 奥から手前へセグメント描画
    final segs = <({Offset a, Offset b, double depth, Color color, double w})>[];
    for (var i = 0; i < n; i++) {
      final a = pts[i];
      final b = pts[i + 1];
      final stripe = ((i + (phi / (2 * math.pi) * 16).floor()) % 8) < 4;
      segs.add((
        a: a.o,
        b: b.o,
        depth: 0.5 * (a.depth + b.depth),
        color: stripe ? _ringA : _ringB,
        w: stripe ? 4.2 : 3.4,
      ));
    }
    segs.sort((a, b) => a.depth.compareTo(b.depth));
    for (final s in segs) {
      canvas.drawLine(
        s.a,
        s.b,
        Paint()
          ..color = s.color
          ..strokeWidth = s.w
          ..strokeCap = StrokeCap.round,
      );
    }

    // 円環上の目印ドット（回転がさらに分かりやすい）
    for (var k = 0; k < 8; k++) {
      final th = k * math.pi / 4;
      final w = _beadWorld(r, th, phi);
      final o = proj(w.$1, w.$2, w.$3);
      canvas.drawCircle(
        o,
        3.2,
        Paint()..color = k.isEven ? Colors.white : const Color(0xFF0D47A1),
      );
    }
  }

  void _omegaBadge(Canvas canvas, Offset top, {required bool ground}) {
    final sweep = ground ? sample.phi : -sample.phi;
    final rect = Rect.fromCenter(center: top, width: 28, height: 28);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      1.8,
      false,
      Paint()
        ..color = const Color(0xFF0277BD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    // 矢印の頭
    final tipA = -math.pi / 2 + 1.8;
    final tip = Offset(
      top.dx + 14 * math.cos(tipA),
      top.dy + 14 * math.sin(tipA),
    );
    final tang = Offset(-math.sin(tipA), math.cos(tipA));
    final n = Offset(-tang.dy, tang.dx);
    final head = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo((tip - tang * 7 + n * 4).dx, (tip - tang * 7 + n * 4).dy)
      ..lineTo((tip - tang * 7 - n * 4).dx, (tip - tang * 7 - n * 4).dy)
      ..close();
    canvas.drawPath(head, Paint()..color = const Color(0xFF0277BD));
    _text(
      canvas,
      top + const Offset(22, -8),
      ground ? 'ω' : '床が逆回転',
      _ink,
    );
    // 回転角のマーカー（弧の向きの気配）
    final mark = Offset(
      top.dx + 10 * math.cos(sweep),
      top.dy + 10 * math.sin(sweep),
    );
    canvas.drawCircle(mark, 2.5, Paint()..color = const Color(0xFF0277BD));
  }

  void _drawRotatingForces(
    Canvas canvas,
    Offset Function(double x, double y, double z) proj,
    Offset beadO,
    double unit,
  ) {
    final th = sample.theta;
    final s = math.sin(th);
    final c = math.cos(th);
    // 接線 ê_θ = (cos θ, 0, sin θ) in rotating frame
    final eTh = proj(0.2 * c, 0, 0.2 * s) - proj(0, 0, 0);
    if (eTh.distance < 1) return;
    final dir = eTh / eTh.distance;
    double forcePx(double f) => (22 * f.abs() / 8).clamp(14.0, 58.0);

    if (sample.gravityTangential.abs() > 0.05) {
      final sense = sample.gravityTangential >= 0 ? 1.0 : -1.0;
      _arrow(
        canvas,
        beadO,
        dir * sense,
        forcePx(sample.gravityTangential),
        _gravity,
        '重力',
      );
    }
    if (sample.centrifugalTangential.abs() > 0.05) {
      final sense = sample.centrifugalTangential >= 0 ? 1.0 : -1.0;
      _arrow(
        canvas,
        beadO + Offset(-dir.dy, dir.dx) * 10,
        dir * sense,
        forcePx(sample.centrifugalTangential),
        _centrifugal,
        '遠心力',
        dashed: true,
      );
    }
  }

  void _drawFloor(
    Canvas canvas,
    Rect plot,
    Offset Function(double x, double y, double z) proj,
    double unit, {
    required bool ground,
  }) {
    const n = 7;
    const half = 1.55;
    final step = (2 * half) / n;
    final z = -params.r * 1.05;
    final angle = ground ? 0.0 : sample.phi;
    final ca = math.cos(angle);
    final sa = math.sin(angle);
    for (var ix = 0; ix < n; ix++) {
      for (var iy = 0; iy < n; iy++) {
        final x0 = -half + ix * step;
        final y0 = -half + iy * step;
        final corners = [
          _rotFloor(x0, y0, ca, sa),
          _rotFloor(x0 + step, y0, ca, sa),
          _rotFloor(x0 + step, y0 + step, ca, sa),
          _rotFloor(x0, y0 + step, ca, sa),
        ];
        final path = Path();
        for (var i = 0; i < 4; i++) {
          final p = proj(corners[i].dx * params.r, corners[i].dy * params.r, z);
          if (i == 0) {
            path.moveTo(p.dx, p.dy);
          } else {
            path.lineTo(p.dx, p.dy);
          }
        }
        path.close();
        canvas.drawPath(
          path,
          Paint()..color = (ix + iy).isEven ? _floorA : _floorB,
        );
      }
    }
  }

  Offset _rotFloor(double x, double y, double ca, double sa) {
    return Offset(x * ca - y * sa, x * sa + y * ca);
  }

  void _arrow(
    Canvas canvas,
    Offset origin,
    Offset dir,
    double length,
    Color color,
    String label, {
    bool dashed = false,
  }) {
    final tip = origin + dir * length;
    const headLen = 9.0;
    const headHalf = 4.5;
    final shaftEnd = tip - dir * (headLen * 0.7);
    final n = Offset(-dir.dy, dir.dx);
    final shaft = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    if (!dashed) {
      canvas.drawLine(origin, shaftEnd, shaft);
    } else {
      final delta = shaftEnd - origin;
      final len = delta.distance;
      if (len > 1) {
        final step = delta / len;
        var d = 0.0;
        while (d < len) {
          canvas.drawLine(
            origin + step * d,
            origin + step * math.min(d + 4, len),
            shaft,
          );
          d += 7;
        }
      }
    }
    final head = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo((tip - dir * headLen + n * headHalf).dx,
          (tip - dir * headLen + n * headHalf).dy)
      ..lineTo((tip - dir * headLen - n * headHalf).dx,
          (tip - dir * headLen - n * headHalf).dy)
      ..close();
    canvas.drawPath(head, Paint()..color = color);
    _text(canvas, tip + n * 12, label, color);
  }

  String _fmtTheta(double th) {
    var t = th % (2 * math.pi);
    if (t < 0) t += 2 * math.pi;
    if (t > math.pi) t = 2 * math.pi - t;
    return t.toStringAsFixed(2);
  }

  void _text(
    Canvas canvas,
    Offset o,
    String text,
    Color color, {
    bool alignLeft = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(alignLeft ? o.dx : o.dx - tp.width / 2, o.dy));
  }

  @override
  bool shouldRepaint(covariant _RingBeadPainter oldDelegate) {
    return oldDelegate.sample.t != sample.t ||
        oldDelegate.sample.theta != sample.theta ||
        oldDelegate.params.r != params.r ||
        oldDelegate.params.omega != params.omega ||
        oldDelegate.params.mass != params.mass;
  }
}
