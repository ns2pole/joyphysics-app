import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// 球対称の地球上に直立する人を、宇宙（慣性系）と地球共回転系で比較する。
/// 緯度 $\lambda$（$-90^\circ\sim 90^\circ$）、軸距離 $\rho=R\cos\lambda$。
/// 人は最初から地球と同じ $\omega$ で共回転する。
const double kEarthG = 9.80;
const double kEarthR = 1.00;
/// 赤道で $N>0$ を保つ上限の少し手前。$\omega_{\max}<\sqrt{g/R}$。
const double kEarthMinOmega = 0.40;
const double kEarthMaxOmega = 3.05;
const double kEarthDefaultOmega = 2.70;
const double kEarthMinM = 0.50;
const double kEarthMaxM = 4.00;
const double kEarthDefaultM = 1.00;
const double kEarthMinLatDeg = -90.0;
const double kEarthMaxLatDeg = 90.0;
const double kEarthDefaultLatDeg = 35.0;
const double kEarthSideBySideWidth = 640.0;
const double kEarthPlayback = 0.70;
/// 力矢印の画面上の長さ倍率（物理の大きさはそのまま。見えやすくするため）。
/// 大きすぎると clip で切れて「長さが変わる」ように見えるので抑える。
const double kEarthForceArrowExaggeration = 2.4;

class EarthStandingParams {
  const EarthStandingParams({
    required this.latDeg,
    required this.omega,
    required this.mass,
  });

  /// 緯度 [deg]。$0$ = 赤道、$+90$ = 北極。
  final double latDeg;
  final double omega;
  final double mass;

  double get latRad => latDeg * math.pi / 180.0;

  double get rho => kEarthR * math.cos(latRad);

  factory EarthStandingParams.fromMap(Map<String, double> params) {
    return EarthStandingParams(
      latDeg: params['lat']!
          .clamp(kEarthMinLatDeg, kEarthMaxLatDeg)
          .toDouble(),
      omega: params['W']!.clamp(kEarthMinOmega, kEarthMaxOmega).toDouble(),
      mass: params['m']!.clamp(kEarthMinM, kEarthMaxM).toDouble(),
    );
  }
}

/// 画面上の向きがほぼ同じとき true。真上視点で抗力と遠心力が重なる判定。
bool _screenDirsAligned(Offset a, Offset b) {
  if (a.distance < 1e-6 || b.distance < 1e-6) return false;
  final d = (a.dx * b.dx + a.dy * b.dy) / (a.distance * b.distance);
  return d > 0.85;
}

/// 共回転系の $xz$ 面（$\phi=0$）での力と分解。
class EarthStandingForces {
  const EarthStandingForces({
    required this.latRad,
    required this.rho,
    required this.gx,
    required this.gz,
    required this.rx,
    required this.rz,
    required this.cenX,
    required this.normal,
    required this.friction,
    required this.ax,
    required this.az,
  });

  final double latRad;
  final double rho;

  /// 重力（地心向き）。
  final double gx;
  final double gz;

  /// 地球からの全抗力 $\vec{R}$（半径＋摩擦）。
  final double rx;
  final double rz;

  /// 遠心力（軸から外向き）。共回転系のみ。慣性系では $0$ 扱い。
  final double cenX;

  /// $\vec{R}\cdot\hat{e}_r$（半径外向き正）。
  final double normal;

  /// $\vec{R}\cdot\hat{e}_\lambda$（北向き正）。いわゆる静止摩擦。
  final double friction;

  /// 慣性系の加速度（軸向き）。
  final double ax;
  final double az;

  double get gMag => math.sqrt(gx * gx + gz * gz);
  double get rMag => math.sqrt(rx * rx + rz * rz);
  double get cenMag => cenX.abs();

  /// 真の力の合力 $\vec{R}+\vec{F}_g$（$=m\vec{a}$、軸向き）。
  double get sumTrueX => rx + gx;
  double get sumTrueZ => rz + gz;
  double get sumTrueMag => math.sqrt(sumTrueX * sumTrueX + sumTrueZ * sumTrueZ);
}

/// $\phi=0$ の子午線上での力。$\hat{e}_r=(\cos\lambda,0,\sin\lambda)$、
/// $\hat{e}_\lambda=(-\sin\lambda,0,\cos\lambda)$（北向き）。
EarthStandingForces earthStandingForces(EarthStandingParams params) {
  final lam = params.latRad;
  final c = math.cos(lam);
  final s = math.sin(lam);
  final m = params.mass;
  final w2 = params.omega * params.omega;
  final rho = kEarthR * c;

  // 重力：地心向き
  final gx = -m * kEarthG * c;
  final gz = -m * kEarthG * s;

  // 慣性系加速度：軸向き（$-\omega^{2}\rho\,\hat{\rho}$）。$\hat{\rho}=\hat{x}$ at φ=0。
  final ax = -w2 * rho;
  const az = 0.0;

  // $\vec{R}+\vec{F}_g=m\vec{a}$ ⇒ $\vec{R}=m\vec{a}-\vec{F}_g$
  final rx = m * ax - gx;
  final rz = m * az - gz;

  // 遠心力（共回転系）：軸から外 = $-m\vec{a}$
  final cenX = -m * ax;

  final normal = rx * c + rz * s;
  final friction = rx * (-s) + rz * c;

  return EarthStandingForces(
    latRad: lam,
    rho: rho,
    gx: gx,
    gz: gz,
    rx: rx,
    rz: rz,
    cenX: cenX,
    normal: normal,
    friction: friction,
    ax: ax,
    az: az,
  );
}

class EarthStandingSample {
  const EarthStandingSample({
    required this.t,
    required this.phi,
    required this.forces,
    required this.x,
    required this.y,
    required this.z,
    required this.xRot,
    required this.yRot,
    required this.zRot,
  });

  final double t;
  final double phi;
  final EarthStandingForces forces;

  /// 慣性系の人の位置。
  final double x;
  final double y;
  final double z;

  /// 共回転系（地球固定、φ=0）。
  final double xRot;
  final double yRot;
  final double zRot;
}

EarthStandingSample earthStandingSampleAt(
  EarthStandingParams params,
  double t,
) {
  final forces = earthStandingForces(params);
  final lam = params.latRad;
  final phi = params.omega * math.max(0.0, t);
  final c = math.cos(lam);
  final s = math.sin(lam);
  final cp = math.cos(phi);
  final sp = math.sin(phi);
  final xRot = kEarthR * c;
  const yRot = 0.0;
  final zRot = kEarthR * s;
  return EarthStandingSample(
    t: math.max(0.0, t),
    phi: phi,
    forces: forces,
    x: xRot * cp,
    y: xRot * sp,
    z: zRot,
    xRot: xRot,
    yRot: yRot,
    zRot: zRot,
  );
}

/// 慣性系：$\vec{R}+\vec{F}_g - m\vec{a}$ の残差ノルム。
double earthStandingInertialResidual(EarthStandingForces f, double mass) {
  final ex = f.rx + f.gx - mass * f.ax;
  final ez = f.rz + f.gz - mass * f.az;
  return math.sqrt(ex * ex + ez * ez);
}

/// 共回転系：$\vec{R}+\vec{F}_g+\vec{F}_{\mathrm{cen}}$ の残差ノルム。
double earthStandingRotatingResidual(EarthStandingForces f) {
  final ex = f.rx + f.gx + f.cenX;
  final ez = f.rz + f.gz;
  return math.sqrt(ex * ex + ez * ez);
}

String earthStandingCaption(EarthStandingParams params) {
  final f = earthStandingForces(params);
  if (params.latDeg.abs() < 1) {
    return '赤道: 抗力∥重力。慣性系 R+Fg=ma、共回転系は遠心力込みで合力0。';
  }
  if (params.latDeg.abs() > 89) {
    return '極: ρ=0 で遠心力なし。抗力と重力がつり合う。';
  }
  return '中緯度: 抗力に摩擦成分 ${f.friction.toStringAsFixed(2)}。'
      '共回転系は遠心力込みで合力0。';
}

final earthStandingPerson3D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '地上に立つ人と遠心力',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>球対称の地球上に立つ人を、宇宙（慣性系）と、地球と一緒に回る座標系で比べます。広い画面では左右、狭い画面では上下です。人は最初から地球と同じ角速度 $\omega$ で回っています。$\omega$ は見えやすくするため大きく誇張し、力矢印の長さもさらに強調しています。</p>
  <p>緯度を $\lambda$、半径を $R$ とすると、自転軸からの距離は $\displaystyle\rho=R\cos\lambda$ です。慣性系では人は軸まわりの等速円運動をし、加速度は軸向きの $\displaystyle\vec{a}=-\omega^{2}\vec{\rho}$ です。速さは一定でも、向きが変わるので加速度があります。</p>
  <p>真の力は重力 $\vec{F}_g$（地心向き）と、地球からの抗力 $\vec{R}$ です。慣性系ではその合力が向心加速度を担います。アニメの左側（または上側）では、この合力 $\vec{R}+\vec{F}_g=m\vec{a}$ を軸向きの矢印で示します。</p>
  <p>$$\vec{R}+\vec{F}_g=m\vec{a}$$</p>
  <p>中緯度では必要な $\vec{a}$ が地心向きと一致しないので、$\vec{R}$ は重力と平行になりません。球モデルでは、その接線成分を静止摩擦と呼びます。赤道・極では接線成分は $0$ です。アニメでは軸に垂直な断面（半径 $\rho$ の円運動の面）も描きます。</p>
  <p>地球と一緒に回る系では人は止まって見え、コリオリ力は出ません。軸から外向きの遠心力 $\displaystyle m\omega^{2}\rho$ を足すとつり合い、合力は $0$ です（右側・下側のパネルでは遠心力を描き、合力矢印は出しません）。</p>
  <p>$$\vec{R}+\vec{F}_g+\vec{F}_{\mathrm{遠}}=\vec{0}$$</p>
  <p>赤道では $\displaystyle N=mg-m\omega^{2}R$ です。実地球は扁球なので、局所鉛直が有効重力に揃うと接線成分はほぼ要りませんが、ここでは球＋摩擦で一貫させています。</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: EarthStandingPerson3DSimulation(),
      height: 980,
    ),
  ],
);

class EarthStandingPerson3DSimulation extends PhysicsSimulation {
  EarthStandingPerson3DSimulation()
      : super(
          title: '地上に立つ人と遠心力',
          formula: const FormulaDisplay(
            r'\displaystyle \rho=R\cos\lambda,\quad'
            r' \vec{R}+\vec{F}_{g}=m\vec{a}\ \text{(慣性)},\ '
            r'\vec{R}+\vec{F}_{g}+\vec{F}_{\mathrm{cen}}=\vec{0}\ \text{(共回転)}',
          ),
          aspectRatio: 0.72,
          enableTime: false,
          showTimeOverlay: false,
          is3D: true,
        );

  @override
  bool get showZoomButtons => true;

  final ValueNotifier<double> simTime = ValueNotifier(0.0);
  Map<String, double> _latestParams = {};

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    simTime.value = simTime.value + dt * kEarthPlayback;
  });

  bool _didAutoStart = false;

  void _ensureAutoStart() {
    if (_didAutoStart) return;
    _didAutoStart = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_loop.running.value) start();
    });
  }

  @override
  String? get situation =>
      '球対称の地球上に直立し、最初から地球と同じ角速度で共回転する人';

  ValueNotifier<bool> get running => _loop.running;

  EarthStandingParams get _params {
    if (_latestParams.isEmpty) {
      return EarthStandingParams.fromMap(initialParameters);
    }
    return EarthStandingParams.fromMap(_latestParams);
  }

  void _rememberParams(Map<String, double> params) {
    _latestParams = Map<String, double>.from(params);
  }

  @override
  void startPlayback() => start();

  void start() {
    if (running.value) return;
    _loop.start();
  }

  void pause() => _loop.pause();

  void resetMotion() {
    _loop.reset();
    simTime.value = 0.0;
  }

  @override
  double aspectRatioForWidth(double width) {
    return width >= kEarthSideBySideWidth ? 1.85 : 0.72;
  }

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'lat': kEarthDefaultLatDeg,
        'W': kEarthDefaultOmega,
        'm': kEarthDefaultM,
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
              earthStandingCaption(_params),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Color(0xFF546E7A),
              ),
            ),
            const SizedBox(height: 8),
            FilterChip(
              avatar: Icon(
                Icons.vertical_align_top,
                size: 16,
                color: activeIds.contains('showWavefrontTopView')
                    ? const Color(0xFF1565C0)
                    : Colors.black54,
              ),
              label: const Text('真上から見る', style: TextStyle(fontSize: 12)),
              selected: activeIds.contains('showWavefrontTopView'),
              onSelected: (on) {
                final next = Set<String>.from(activeIds);
                if (on) {
                  next.add('showWavefrontTopView');
                } else {
                  next.remove('showWavefrontTopView');
                }
                updateActiveIds(next);
              },
              selectedColor: const Color(0xFFBBDEFB),
              checkmarkColor: const Color(0xFF1565C0),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
    final f = earthStandingForces(p);
    return [
      const Text(
        '球・最初から同じ ω で共回転（ω は誇張）',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _EarthSlider(
        label: 'λ',
        value: p.latDeg,
        min: kEarthMinLatDeg,
        max: kEarthMaxLatDeg,
        onChanged: (v) => updateParam('lat', v),
        semanticLabel: '緯度',
        digits: 0,
        suffix: '°',
      ),
      _EarthSlider(
        label: 'ω',
        value: p.omega,
        min: kEarthMinOmega,
        max: kEarthMaxOmega,
        onChanged: (v) => updateParam('W', v),
        semanticLabel: '角速度 ω',
      ),
      _EarthSlider(
        label: 'm',
        value: p.mass,
        min: kEarthMinM,
        max: kEarthMaxM,
        onChanged: (v) => updateParam('m', v),
        semanticLabel: '質量 m',
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'ρ = ${f.rho.toStringAsFixed(2)}    '
          'N = ${f.normal.toStringAsFixed(2)} N    '
          'f = ${f.friction.toStringAsFixed(2)} N',
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
        final p = EarthStandingParams.fromMap(parameters);
        final sample = earthStandingSampleAt(p, simTime.value);
        return CustomPaint(
          size: Size.infinite,
          painter: _EarthStandingPainter(
            params: p,
            sample: sample,
            azimuth: azimuth,
            tilt: tilt,
            scale: scale,
          ),
        );
      },
    );
  }
}

class _EarthSlider extends StatelessWidget {
  const _EarthSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.semanticLabel,
    this.digits = 2,
    this.suffix = '',
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String semanticLabel;
  final int digits;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 28,
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
                  '$semanticLabel ${v.toStringAsFixed(digits)}$suffix',
            ),
          ),
        ),
        SizedBox(
          width: 56,
          child: Text(
            '${value.toStringAsFixed(digits)}$suffix',
            style: const TextStyle(fontSize: 12, fontFamily: 'Courier'),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _EarthStandingPainter extends CustomPainter {
  _EarthStandingPainter({
    required this.params,
    required this.sample,
    required this.azimuth,
    required this.tilt,
    required this.scale,
  });

  final EarthStandingParams params;
  final EarthStandingSample sample;
  final double azimuth;
  final double tilt;
  final double scale;

  static const _bg = Color(0xFF0B1220);
  static const _ink = Color(0xFFECEFF1);
  static const _muted = Color(0xFF90A4AE);
  static const _ocean = Color(0xFF1565C0);
  static const _grid = Color(0xFFBBDEFB);
  static const _gridBack = Color(0x3342A5F5);
  static const _axis = Color(0xFF80CBC4);
  static const _person = Color(0xFFE0E0E0);
  static const _gravity = Color(0xFFEF9A9A);
  static const _reaction = Color(0xFFFFF176);
  static const _centrifugal = Color(0xFFA5D6A7);
  static const _resultant = Color(0xFF4DD0E1);
  static const _orbitPlane = Color(0xFF81D4FA);
  static const _star = Color(0xFFCFD8DC);

  /// 波動と同じ操作系。初期は見やすい斜め上へ少しずらす。
  static const double _az0 = 0.85;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final sideBySide =
        size.width >= kEarthSideBySideWidth && size.width > size.height;
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
      panel.left + 8,
      panel.top + 28,
      panel.right - 8,
      panel.bottom - 28,
    );
    final unit = math.min(plot.width, plot.height) / 2.8 * scale;
    final az = azimuth + _az0;
    final t = tilt.clamp(0.05, math.pi / 2);
    final cA = math.cos(az);
    final sA = math.sin(az);
    final cT = math.cos(t);
    final sT = math.sin(t);

    // 正投影（画面縦横同スケール）。球の輪郭は常に円。
    Offset proj(double x, double y, double z) {
      final x1 = x * cA - y * sA;
      final y1 = x * sA + y * cA;
      final xCam = x1;
      final yCam = -y1 * sT + z * cT;
      return Offset(
        plot.center.dx + xCam * unit,
        plot.center.dy - yCam * unit,
      );
    }

    double depth(double x, double y, double z) {
      final y1 = x * sA + y * cA;
      return y1 * cT + z * sT;
    }

    if (!ground) {
      // 共回転系：地球固定なので恒星は逆回転して見える。
      _drawStars(canvas, plot, skyAngle: -sample.phi);
    } else {
      _drawStars(canvas, plot, skyAngle: 0.0);
    }

    canvas.drawRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF455A64),
    );
    _text(
      canvas,
      Offset(panel.left + 8, panel.top + 6),
      ground ? '宇宙（慣性系）' : '地球と一緒に回る系',
      _ink,
      alignLeft: true,
    );

    final phi = ground ? sample.phi : 0.0;
    _drawAxis(canvas, proj);
    _drawGlobe(canvas, proj, depth, phi, unit);
    _drawOrbitCrossSection(canvas, proj, depth, ground: ground);
    _drawPersonAndForces(canvas, proj, depth, ground: ground);

    _text(
      canvas,
      Offset(panel.center.dx, panel.bottom - 16),
      ground
          ? '真の力の合力 R+Fg = ma（軸向き）'
          : 'R+Fg+遠心力 = 0（人は静止）',
      _muted,
    );
    canvas.restore();
  }

  void _drawStars(Canvas canvas, Rect plot, {required double skyAngle}) {
    final rng = _StarRng(42);
    final ca = math.cos(skyAngle);
    final sa = math.sin(skyAngle);
    final rotateSky = skyAngle.abs() > 1e-12;
    for (var i = 0; i < 48; i++) {
      var x = (rng.next() - 0.5) * 2.4;
      var y = (rng.next() - 0.5) * 2.4;
      if (rotateSky) {
        final xr = x * ca - y * sa;
        final yr = x * sa + y * ca;
        x = xr;
        y = yr;
      }
      final o = Offset(
        plot.center.dx + x * plot.width * 0.42,
        plot.center.dy + y * plot.height * 0.42,
      );
      if (!plot.contains(o)) continue;
      canvas.drawCircle(
        o,
        0.8 + rng.next() * 1.2,
        Paint()..color = _star.withValues(alpha: 0.35 + rng.next() * 0.45),
      );
    }
  }

  void _drawAxis(Canvas canvas, Offset Function(double, double, double) proj) {
    final top = proj(0, 0, kEarthR * 1.35);
    final bot = proj(0, 0, -kEarthR * 1.35);
    canvas.drawLine(
      top,
      bot,
      Paint()
        ..color = _axis
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
    _text(canvas, top + const Offset(10, -4), 'N', _axis);
    _text(canvas, bot + const Offset(10, 0), 'S', _axis);
  }

  void _drawGlobe(
    Canvas canvas,
    Offset Function(double, double, double) proj,
    double Function(double, double, double) depth,
    double phi,
    double unit,
  ) {
    final center = proj(0, 0, 0);
    // 正投影なので輪郭は常に半径 R の円。
    final rimR = kEarthR * unit;
    canvas.drawCircle(
      center,
      rimR,
      Paint()
        ..color = _grid.withValues(alpha: 0.40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
    canvas.drawCircle(center, 3.5, Paint()..color = _ocean);

    final segs = <({Offset a, Offset b, double d, bool front})>[];

    // 緯線：λ = -60,-30,0,30,60（等間隔 30°）
    for (var lat = -60; lat <= 60; lat += 30) {
      final lam = lat * math.pi / 180;
      const n = 64;
      Offset? prev;
      double? prevD;
      for (var i = 0; i <= n; i++) {
        final th = 2 * math.pi * i / n + phi;
        final x = kEarthR * math.cos(lam) * math.cos(th);
        final y = kEarthR * math.cos(lam) * math.sin(th);
        final z = kEarthR * math.sin(lam);
        final o = proj(x, y, z);
        final d = depth(x, y, z);
        if (prev != null && prevD != null) {
          segs.add((
            a: prev,
            b: o,
            d: 0.5 * (prevD + d),
            front: d > -0.05 || prevD > -0.05,
          ));
        }
        prev = o;
        prevD = d;
      }
    }

    // 経線：30° ごと
    for (var lon = 0; lon < 360; lon += 30) {
      final th0 = lon * math.pi / 180 + phi;
      const n = 48;
      Offset? prev;
      double? prevD;
      for (var i = 0; i <= n; i++) {
        final lam = -math.pi / 2 + math.pi * i / n;
        final x = kEarthR * math.cos(lam) * math.cos(th0);
        final y = kEarthR * math.cos(lam) * math.sin(th0);
        final z = kEarthR * math.sin(lam);
        final o = proj(x, y, z);
        final d = depth(x, y, z);
        if (prev != null && prevD != null) {
          segs.add((
            a: prev,
            b: o,
            d: 0.5 * (prevD + d),
            front: d > -0.05 || prevD > -0.05,
          ));
        }
        prev = o;
        prevD = d;
      }
    }

    segs.sort((a, b) => a.d.compareTo(b.d));
    for (final s in segs) {
      canvas.drawLine(
        s.a,
        s.b,
        Paint()
          ..color = s.front ? _grid : _gridBack
          ..strokeWidth = s.front ? 1.35 : 0.9
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  /// 軸に垂直・高さ $z=R\sin\lambda$ の断面＝半径 $\rho$ の円運動の面。
  void _drawOrbitCrossSection(
    Canvas canvas,
    Offset Function(double, double, double) proj,
    double Function(double, double, double) depth, {
    required bool ground,
  }) {
    final rho = sample.forces.rho;
    final z = ground ? sample.z : sample.zRot;
    if (rho < 0.04) return;

    const n = 72;
    final rim = <({Offset o, double d})>[];
    for (var i = 0; i <= n; i++) {
      final th = 2 * math.pi * i / n;
      final x = rho * math.cos(th);
      final y = rho * math.sin(th);
      rim.add((o: proj(x, y, z), d: depth(x, y, z)));
    }

    final disk = Path()..moveTo(rim.first.o.dx, rim.first.o.dy);
    for (var i = 1; i < rim.length; i++) {
      disk.lineTo(rim[i].o.dx, rim[i].o.dy);
    }
    disk.close();
    canvas.drawPath(
      disk,
      Paint()..color = _orbitPlane.withValues(alpha: 0.14),
    );

    final axisHit = proj(0, 0, z);
    canvas.drawCircle(
      axisHit,
      3.2,
      Paint()..color = _orbitPlane.withValues(alpha: 0.85),
    );

    // 半径の目印（軸 → 人の足元方向）
    final px = ground ? sample.x : sample.xRot;
    final py = ground ? sample.y : sample.yRot;
    final feet = proj(px, py, z);
    canvas.drawLine(
      axisHit,
      feet,
      Paint()
        ..color = _orbitPlane.withValues(alpha: 0.75)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );

    final rimSegs = <({Offset a, Offset b, double d})>[];
    for (var i = 0; i < n; i++) {
      rimSegs.add((
        a: rim[i].o,
        b: rim[i + 1].o,
        d: 0.5 * (rim[i].d + rim[i + 1].d),
      ));
    }
    rimSegs.sort((a, b) => a.d.compareTo(b.d));
    for (final s in rimSegs) {
      canvas.drawLine(
        s.a,
        s.b,
        Paint()
          ..color = _orbitPlane.withValues(alpha: 0.95)
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round,
      );
    }

    // 断面のラベル：軸付近
    _text(
      canvas,
      axisHit + const Offset(14, -10),
      ground ? '円運動の断面' : '遠心力の面',
      _orbitPlane,
      alignLeft: true,
    );
    _text(
      canvas,
      Offset((axisHit.dx + feet.dx) / 2, (axisHit.dy + feet.dy) / 2 - 12),
      'ρ',
      _orbitPlane,
    );
  }

  void _drawPersonAndForces(
    Canvas canvas,
    Offset Function(double, double, double) proj,
    double Function(double, double, double) depth, {
    required bool ground,
  }) {
    final px = ground ? sample.x : sample.xRot;
    final py = ground ? sample.y : sample.yRot;
    final pz = ground ? sample.z : sample.zRot;
    final feet = proj(px, py, pz);

    // 局所半径外向き（直立）
    final scale = 0.22;
    final hx = px / kEarthR * scale;
    final hy = py / kEarthR * scale;
    final hz = pz / kEarthR * scale;
    final head = proj(px + hx, py + hy, pz + hz);
    final mid = Offset(
      (feet.dx + head.dx) / 2,
      (feet.dy + head.dy) / 2,
    );

    // 簡易人型（胴と頭）
    canvas.drawLine(
      feet,
      head,
      Paint()
        ..color = _person
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(head, 5.5, Paint()..color = _person);

    final f = sample.forces;
    // 長さは理論の |F| に比例（視点・φ で変えない）。向きだけ投影する。
    // 起点はすべて mid。
    // 慣性系: 重力・抗力・合力(=ma)。共回転系: 重力・抗力・遠心力（三者で 0）。
    final forceOrigin = mid;

    final er = head - feet;
    final hasEr = er.distance >= 2;
    final erN = hasEr ? er / er.distance : Offset.zero;

    final phi = ground ? sample.phi : 0.0;
    final cp = math.cos(phi);
    final sp = math.sin(phi);

    (double, double, double) rotForce(double fx, double fz) =>
        (fx * cp, fx * sp, fz);

    /// 単位ベクトルの画面向き。正投影は平行移動不変。
    Offset rawDir(double ux, double uy, double uz) {
      const eps = 0.25;
      return proj(ux * eps, uy * eps, uz * eps) - proj(0, 0, 0);
    }

    /// 真正面で投影が潰れるとき、方位を少しずらして向きを拾う。
    Offset screenDir(double ux, double uy, double uz) {
      var d = rawDir(ux, uy, uz);
      if (d.distance >= 0.75) return d;
      const dphi = 0.22;
      for (final s in [1.0, -1.0, 2.0, -2.0]) {
        final a = s * dphi;
        final ca = math.cos(a);
        final sa = math.sin(a);
        final ux2 = ux * ca - uy * sa;
        final uy2 = ux * sa + uy * ca;
        d = rawDir(ux2, uy2, uz);
        if (d.distance >= 0.75) return d;
      }
      if (hasEr) {
        // 半径成分が残っていれば直立方向で代用
        final fr = ux * (px / kEarthR) + uy * (py / kEarthR) + uz * (pz / kEarthR);
        if (fr.abs() > 1e-6) return erN * fr.sign;
      }
      // 最後の手段：ゼロにしない（一瞬消えを防ぐ）
      return d.distance > 1e-12 ? d : const Offset(0, -1);
    }

    Offset dirOfForce(double fx, double fy, double fz) {
      final mag = math.sqrt(fx * fx + fy * fy + fz * fz);
      if (mag < 1e-12) return Offset.zero;
      return screenDir(fx / mag, fy / mag, fz / mag);
    }

    double forcePx(double mag) {
      final raw =
          22 * kEarthForceArrowExaggeration * mag / (params.mass * kEarthG);
      return raw.clamp(0.0, 52.0);
    }

    void drawArrow(
      Offset dir,
      double mag,
      Color color,
      String label, {
      bool dashed = false,
      Offset? origin,
      double labelSide = 1,
    }) {
      if (mag < 0.05) return;
      final d = dir.distance < 1e-9 ? const Offset(0, -1) : dir;
      _arrow(
        canvas,
        origin ?? forceOrigin,
        d / d.distance,
        forcePx(mag),
        color,
        label,
        dashed: dashed,
        labelSide: labelSide,
      );
    }

    // 重力：地心向き、|Fg|=mg（一定）
    drawArrow(
      screenDir(-px / kEarthR, -py / kEarthR, -pz / kEarthR),
      f.gMag,
      _gravity,
      '重力',
    );

    // 抗力：φ 回転した 3D（概ね外向き＝重力と逆）
    final r3 = rotForce(f.rx, f.rz);
    final rDir = dirOfForce(r3.$1, r3.$2, r3.$3);

    // 軸水平の単位ベクトル（外向き ê_ρ）
    final rho = math.sqrt(px * px + py * py);
    final Offset? outDir =
        rho > 1e-6 ? screenDir(px / rho, py / rho, 0) : null;

    // 真上から見ると z が潰れ、抗力と遠心力が同じ外向きに重なる。
    // 向きは保ったまま、矢印と垂直な向きへ起点だけ少しずらす。
    var reactionOrigin = forceOrigin;
    var cenOrigin = forceOrigin;
    var reactionLabelSide = 1.0;
    var cenLabelSide = 1.0;
    if (!ground && outDir != null && _screenDirsAligned(rDir, outDir)) {
      final u = rDir / rDir.distance;
      final n = Offset(-u.dy, u.dx);
      const sep = 10.0;
      reactionOrigin = forceOrigin - n * sep;
      cenOrigin = forceOrigin + n * sep;
      reactionLabelSide = -1;
      cenLabelSide = 1;
    }

    drawArrow(
      rDir,
      f.rMag,
      _reaction,
      '抗力',
      origin: reactionOrigin,
      labelSide: reactionLabelSide,
    );

    if (outDir != null) {
      if (!ground) {
        drawArrow(
          outDir,
          f.cenMag,
          _centrifugal,
          '遠心力',
          dashed: true,
          origin: cenOrigin,
          labelSide: cenLabelSide,
        );
      } else {
        // 合力 = ma = −mω²ρ ê_ρ。長さは mω²ρ で φ によらず一定。
        drawArrow(-outDir, f.sumTrueMag, _resultant, '合力(=ma)');
      }
    }

    assert(depth(px, py, pz).isFinite);
  }

  void _arrow(
    Canvas canvas,
    Offset origin,
    Offset dir,
    double length,
    Color color,
    String label, {
    bool dashed = false,
    double labelSide = 1,
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
    _text(canvas, tip + n * (12 * labelSide), label, color);
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
  bool shouldRepaint(covariant _EarthStandingPainter oldDelegate) {
    return oldDelegate.sample.t != sample.t ||
        oldDelegate.sample.phi != sample.phi ||
        oldDelegate.params.latDeg != params.latDeg ||
        oldDelegate.params.omega != params.omega ||
        oldDelegate.params.mass != params.mass ||
        oldDelegate.azimuth != azimuth ||
        oldDelegate.tilt != tilt ||
        oldDelegate.scale != scale;
  }
}

class _StarRng {
  _StarRng(this._s);
  int _s;
  double next() {
    _s = (1103515245 * _s + 12345) & 0x7fffffff;
    return _s / 0x7fffffff;
  }
}
