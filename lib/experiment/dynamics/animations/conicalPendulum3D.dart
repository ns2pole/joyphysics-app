import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/arrow_screen.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// 一定の開き角 $\theta$ で水平円運動する円錐振り子。
/// 支点を原点、鉛直上向きを正の $z$ とする。
/// $\omega^{2}=g/(l\cos\theta)$、$S=mg/\cos\theta$。
const double kConeG = 9.8;
const double kConeMinThetaDeg = 15.0;
const double kConeMaxThetaDeg = 65.0;
const double kConeDefaultThetaDeg = 40.0;
const double kConeMinL = 0.80;
const double kConeMaxL = 2.00;
const double kConeDefaultL = 1.20;
const double kConeMinM = 0.50;
const double kConeMaxM = 4.00;
const double kConeDefaultM = 1.00;
const double kConeSideBySideWidth = 640.0;
const double kConePlayback = 1.0;

class ConicalPendulumParams {
  const ConicalPendulumParams({
    required this.thetaDeg,
    required this.length,
    required this.mass,
  });

  /// 鉛直下向きから測った開き角 [deg]。
  final double thetaDeg;
  final double length;
  final double mass;

  double get theta => thetaDeg * math.pi / 180.0;

  /// 水平半径 $r=l\sin\theta$。
  double get radius => length * math.sin(theta);

  /// 支点から軌道面までの鉛直距離 $h=l\cos\theta$。
  double get coneHeight => length * math.cos(theta);

  /// つり合いの角速度。$\omega^{2}=g/(l\cos\theta)$。
  double get omega => math.sqrt(kConeG / coneHeight);

  /// 糸の張力 $S=mg/\cos\theta$。
  double get tension => mass * kConeG / math.cos(theta);

  /// 周期 $T=2\pi\sqrt{h/g}$。
  double get period => 2 * math.pi / omega;

  factory ConicalPendulumParams.fromMap(Map<String, double> params) {
    return ConicalPendulumParams(
      thetaDeg: params['th']!
          .clamp(kConeMinThetaDeg, kConeMaxThetaDeg)
          .toDouble(),
      length: params['l']!.clamp(kConeMinL, kConeMaxL).toDouble(),
      mass: params['m']!.clamp(kConeMinM, kConeMaxM).toDouble(),
    );
  }
}

/// 回転系（糸を $xz$ 面、$x>0$ に固定）での力。単位は N。
class ConicalPendulumForces {
  const ConicalPendulumForces({
    required this.tensionX,
    required this.tensionZ,
    required this.gravityZ,
    required this.cenX,
    required this.ax,
    required this.az,
  });

  /// 張力の水平成分（軸向きが負）。
  final double tensionX;

  /// 張力の鉛直成分（上向きが正）。
  final double tensionZ;

  /// 重力（下向きが負）。
  final double gravityZ;

  /// 遠心力（軸から外向き）。回転系のみ。
  final double cenX;

  /// 慣性系の加速度（$\phi=0$ では軸向き）。
  final double ax;
  final double az;

  double get tensionMag => math.sqrt(tensionX * tensionX + tensionZ * tensionZ);
  double get gravityMag => gravityZ.abs();
  double get cenMag => cenX.abs();

  /// 真の力の合力 $\vec{S}+\vec{F}_g$（$=m\vec{a}$）。
  double get sumTrueX => tensionX;
  double get sumTrueZ => tensionZ + gravityZ;
  double get sumTrueMag => math.sqrt(sumTrueX * sumTrueX + sumTrueZ * sumTrueZ);
}

ConicalPendulumForces conicalPendulumForces(ConicalPendulumParams params) {
  final th = params.theta;
  final m = params.mass;
  final w2 = params.omega * params.omega;
  final mg = m * kConeG;
  final horizontal = mg * math.tan(th);

  // 張力は支点向き。$\phi=0$ では $(-\sin\theta, 0, \cos\theta)$ 方向。
  final tensionX = -horizontal;
  final tensionZ = mg;

  // 慣性加速度：軸向き $-\omega^{2}r$。
  final ax = -w2 * params.radius;
  const az = 0.0;

  // 遠心力は $-m\vec{a}$。
  final cenX = -m * ax;

  return ConicalPendulumForces(
    tensionX: tensionX,
    tensionZ: tensionZ,
    gravityZ: -mg,
    cenX: cenX,
    ax: ax,
    az: az,
  );
}

class ConicalPendulumSample {
  const ConicalPendulumSample({
    required this.t,
    required this.phi,
    required this.forces,
    required this.x,
    required this.y,
    required this.z,
    required this.xRot,
    required this.yRot,
    required this.zRot,
    required this.vx,
    required this.vy,
    required this.vz,
  });

  final double t;
  final double phi;
  final ConicalPendulumForces forces;

  /// 慣性系のおもり。
  final double x;
  final double y;
  final double z;

  /// 振り子と一緒に回る系（糸は $xz$ 面）。
  final double xRot;
  final double yRot;
  final double zRot;

  /// 慣性系の速度。
  final double vx;
  final double vy;
  final double vz;
}

ConicalPendulumSample conicalPendulumSampleAt(
  ConicalPendulumParams params,
  double t,
) {
  final forces = conicalPendulumForces(params);
  final time = math.max(0.0, t);
  final phi = params.omega * time;
  final r = params.radius;
  final z = -params.coneHeight;
  final cp = math.cos(phi);
  final sp = math.sin(phi);
  final x = r * cp;
  final y = r * sp;
  return ConicalPendulumSample(
    t: time,
    phi: phi,
    forces: forces,
    x: x,
    y: y,
    z: z,
    xRot: r,
    yRot: 0.0,
    zRot: z,
    vx: -params.omega * y,
    vy: params.omega * x,
    vz: 0.0,
  );
}

/// 慣性系：$\vec{S}+\vec{F}_g-m\vec{a}$ の残差ノルム（$\phi=0$）。
double conicalInertialResidual(ConicalPendulumForces f, double mass) {
  final ex = f.tensionX - mass * f.ax;
  final ez = f.tensionZ + f.gravityZ - mass * f.az;
  return math.sqrt(ex * ex + ez * ez);
}

/// 回転系：$\vec{S}+\vec{F}_g+\vec{F}_{\mathrm{cen}}$ の残差ノルム。
double conicalRotatingResidual(ConicalPendulumForces f) {
  final ex = f.tensionX + f.cenX;
  final ez = f.tensionZ + f.gravityZ;
  return math.sqrt(ex * ex + ez * ez);
}

String conicalPendulumCaption(ConicalPendulumParams params) {
  return 'θ=${params.thetaDeg.toStringAsFixed(0)}° で水平円運動。'
      '慣性系は張力の水平成分が向心力。'
      '一緒に回る系では遠心力とつり合い、合力は 0。';
}

final conicalPendulum3D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '円錐振り子',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>長さ $l$ の糸の先のおもりが、鉛直軸のまわりを一定の角速度 $\omega$ で水平に回ります。糸は鉛直から一定の角 $\theta$ を保ち、円錐面を描きます。広い画面では左右、狭い画面では上下です。上または左が地上（慣性系）、下または右が振り子と一緒に回る座標系です。</p>
  <p>支点を原点、鉛直上向きを正の $z$ とすると、水平半径と支点から軌道面までの鉛直距離は次のとおりです。</p>
  <p>$$r=l\sin\theta,\qquad h=l\cos\theta$$</p>
  <p>真の力は重力と糸の張力 $\vec{S}$ です。慣性系ではおもりは水平な等速円運動をし、加速度は軸向きの $\displaystyle\vec{a}=-\omega^{2}\vec{r}$ です。鉛直方向はつり合い、水平方向は張力の成分が向心力になります。</p>
  <p>$$S\cos\theta=mg,\qquad S\sin\theta=m\omega^{2}r$$</p>
  <p>$\theta$ が $0$ でないとき、角速度と張力は次で決まります。周期は質量によらず、鉛直距離 $h$ だけで決まります。</p>
  <p>$$\omega^{2}=\frac{g}{l\cos\theta},\qquad S=\frac{mg}{\cos\theta}$$</p>
  <p>$$T=2\pi\sqrt{\frac{l\cos\theta}{g}}=2\pi\sqrt{\frac{h}{g}}$$</p>
  <p>振り子と一緒に回る系ではおもりは止まって見えます。軸から外向きの遠心力 $\displaystyle m\omega^{2}r$ を足すと、重力・張力・遠心力の合力は $0$ です。おもりは止まっているのでコリオリ力は出ません。三力の大きさの比は、円錐の断面の直角三角形と相似です。</p>
  <p>$$\vec{S}+\vec{F}_{g}+\vec{F}_{\mathrm{遠}}=\vec{0}$$</p>
  <p>$$S:mg:m\omega^{2}r=l:h:r$$</p>
  <p>アニメでは両系に力を描きます。遠心力は破線です。軌道の点は時間等間隔です。$g=9.8\,\mathrm{m/s^{2}}$ です。</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: ConicalPendulum3DSimulation(),
      height: 980,
    ),
  ],
);

class ConicalPendulum3DSimulation extends PhysicsSimulation {
  ConicalPendulum3DSimulation()
    : super(
        title: '円錐振り子',
        formula: const FormulaDisplay(
          r'\displaystyle \omega^{2}=\frac{g}{l\cos\theta},\quad'
          r' S=\frac{mg}{\cos\theta},\quad'
          r' T=2\pi\sqrt{\frac{h}{g}}',
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

  late final PlaybackLoop _loop = PlaybackLoop(
    onTick: (dt) {
      simTime.value = simTime.value + dt * kConePlayback;
    },
  );

  bool _didAutoStart = false;

  void _ensureAutoStart() {
    if (_didAutoStart) return;
    _didAutoStart = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_loop.running.value) start();
    });
  }

  @override
  String? get situation => '糸が鉛直から一定角を保ったまま、おもりが水平な等速円運動をする';

  ValueNotifier<bool> get running => _loop.running;

  ConicalPendulumParams get _params {
    if (_latestParams.isEmpty) {
      return ConicalPendulumParams.fromMap(initialParameters);
    }
    return ConicalPendulumParams.fromMap(_latestParams);
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
    return width >= kConeSideBySideWidth ? 1.85 : 0.72;
  }

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
    'th': kConeDefaultThetaDeg,
    'l': kConeDefaultL,
    'm': kConeDefaultM,
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
              conicalPendulumCaption(_params),
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
    return [
      const Text(
        '一定の θ で回る円錐振り子（g = 9.8 m/s²）',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _ConeSlider(
        label: 'θ',
        value: p.thetaDeg,
        min: kConeMinThetaDeg,
        max: kConeMaxThetaDeg,
        onChanged: (v) => updateParam('th', v),
        semanticLabel: '開き角 θ',
        digits: 0,
        suffix: '°',
      ),
      _ConeSlider(
        label: 'l',
        value: p.length,
        min: kConeMinL,
        max: kConeMaxL,
        onChanged: (v) => updateParam('l', v),
        semanticLabel: '糸の長さ l',
      ),
      _ConeSlider(
        label: 'm',
        value: p.mass,
        min: kConeMinM,
        max: kConeMaxM,
        onChanged: (v) => updateParam('m', v),
        semanticLabel: '質量 m',
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'ω = ${p.omega.toStringAsFixed(2)} rad/s    '
          'S = ${p.tension.toStringAsFixed(2)} N    '
          'T = ${p.period.toStringAsFixed(2)} s\n'
          'r = ${p.radius.toStringAsFixed(2)}    '
          'h = ${p.coneHeight.toStringAsFixed(2)}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            height: 1.35,
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
        final p = ConicalPendulumParams.fromMap(parameters);
        final sample = conicalPendulumSampleAt(p, simTime.value);
        return CustomPaint(
          size: Size.infinite,
          painter: _ConicalPendulumPainter(
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

class _ConeSlider extends StatelessWidget {
  const _ConeSlider({
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
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
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

class _ConicalPendulumPainter extends CustomPainter {
  _ConicalPendulumPainter({
    required this.params,
    required this.sample,
    required this.azimuth,
    required this.tilt,
    required this.scale,
  });

  final ConicalPendulumParams params;
  final ConicalPendulumSample sample;
  final double azimuth;
  final double tilt;
  final double scale;

  static const _bg = Color(0xFFF4F7FA);
  static const _ink = Color(0xFF37474F);
  static const _muted = Color(0xFF546E7A);
  static const _bob = Color(0xFFE53935);
  static const _string = Color(0xFF455A64);
  static const _orbit = Color(0xFF1565C0);
  static const _axis = Color(0xFF78909C);
  static const _gravity = Color(0xFF5D4037);
  static const _tension = Color(0xFFF9A825);
  static const _centrifugal = Color(0xFF2E7D32);
  static const _resultant = Color(0xFF00838F);
  static const _velocity = Color(0xFF6A1B9A);
  static const _floorA = Color(0xFFE8E0D4);
  static const _floorB = Color(0xFFD4C6B4);
  static const _cone = Color(0xFF90A4AE);

  /// 円環ビーズと同じ操作系。初期は斜め上。
  static const double _az0 = 0.55;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final sideBySide =
        size.width >= kConeSideBySideWidth && size.width > size.height;
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
    final unit =
        math.min(plot.width, plot.height) / (2.7 * params.length) * scale;
    final az = azimuth + _az0;
    final t = tilt.clamp(0.05, math.pi / 2);
    final cA = math.cos(az);
    final sA = math.sin(az);
    final cT = math.cos(t);
    final sT = math.sin(t);
    final zShift = -0.55 * params.length;

    Offset proj(double x, double y, double z) {
      final zz = z - zShift;
      final x1 = x * cA - y * sA;
      final y1 = x * sA + y * cA;
      final yCam = -y1 * sT + zz * cT;
      return Offset(plot.center.dx + x1 * unit, plot.center.dy - yCam * unit);
    }

    double depth(double x, double y, double z) {
      final zz = z - zShift;
      final y1 = x * sA + y * cA;
      return y1 * cT + zz * sT;
    }

    _drawFloor(canvas, plot, proj, ground: ground);
    canvas.drawRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFCFD8DC),
    );
    _text(
      canvas,
      Offset(panel.left + 8, panel.top + 6),
      ground ? '地上（慣性系）' : '振り子と一緒に回る系',
      _ink,
      alignLeft: true,
    );
    _scene(canvas, proj, depth, unit, ground: ground);
    _text(
      canvas,
      Offset(panel.center.dx, panel.bottom - 18),
      ground ? '張力＋重力 = ma（水平・軸向き）' : '張力＋重力＋遠心力 = 0',
      _muted,
    );
    canvas.restore();
  }

  void _scene(
    Canvas canvas,
    Offset Function(double x, double y, double z) proj,
    double Function(double x, double y, double z) depth,
    double unit, {
    required bool ground,
  }) {
    final phi = ground ? sample.phi : 0.0;
    final bob = ground
        ? (sample.x, sample.y, sample.z)
        : (sample.xRot, sample.yRot, sample.zRot);
    final bobO = proj(bob.$1, bob.$2, bob.$3);

    _drawSupport(canvas, proj, ground: ground);
    _drawAxis(canvas, proj);
    _drawConeSection(canvas, proj, phi, bob);
    _drawOrbit(canvas, proj, depth, ground: ground);
    _drawAngleArc(canvas, proj, phi);

    canvas.drawLine(
      proj(0, 0, 0),
      bobO,
      Paint()
        ..color = _string
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );

    final shadowZ = -params.length * 1.18;
    canvas.drawCircle(
      proj(bob.$1, bob.$2, shadowZ),
      5.5,
      Paint()..color = Colors.black12,
    );

    _drawForces(canvas, proj, bobO, unit, ground: ground);
    if (ground) {
      _drawVelocity(canvas, proj, bobO, unit);
    }

    canvas.drawCircle(proj(0, 0, 0), 3.2, Paint()..color = _string);
    canvas.drawCircle(
      bobO.translate(0.7, 0.8),
      5.2,
      Paint()..color = Colors.black26,
    );
    canvas.drawCircle(bobO, 4.6, Paint()..color = _bob);
    canvas.drawCircle(
      bobO.translate(-1.2, -1.2),
      1.3,
      Paint()..color = Colors.white70,
    );
  }

  void _drawSupport(
    Canvas canvas,
    Offset Function(double x, double y, double z) proj, {
    required bool ground,
  }) {
    final ang = ground ? 0.0 : sample.phi;
    final ca = math.cos(ang);
    final sa = math.sin(ang);
    final half = params.length * 0.16;
    final top = params.length * 0.14;
    final paint = Paint()
      ..color = _string
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(proj(0, 0, 0), proj(0, 0, top), paint);
    canvas.drawLine(
      proj(half * ca, half * sa, top),
      proj(-half * ca, -half * sa, top),
      paint,
    );
  }

  void _drawAxis(
    Canvas canvas,
    Offset Function(double x, double y, double z) proj,
  ) {
    canvas.drawLine(
      proj(0, 0, params.length * 0.14),
      proj(0, 0, -params.length * 1.05),
      Paint()
        ..color = _axis
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawConeSection(
    Canvas canvas,
    Offset Function(double x, double y, double z) proj,
    double phi,
    (double, double, double) bob,
  ) {
    final pivot = proj(0, 0, 0);
    final foot = proj(0, 0, bob.$3);
    final tip = proj(bob.$1, bob.$2, bob.$3);
    final path = Path()
      ..moveTo(pivot.dx, pivot.dy)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(foot.dx, foot.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = _cone.withValues(alpha: 0.16));
    final leg = Paint()
      ..color = _orbit.withValues(alpha: 0.55)
      ..strokeWidth = 1.3;
    canvas.drawLine(foot, tip, leg);

    // 円錐の母線（淡い）
    const n = 12;
    final r = params.radius;
    final z = -params.coneHeight;
    final guide = Paint()
      ..color = _cone.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (var i = 0; i < n; i++) {
      final a = phi + 2 * math.pi * i / n;
      canvas.drawLine(pivot, proj(r * math.cos(a), r * math.sin(a), z), guide);
    }
  }

  void _drawOrbit(
    Canvas canvas,
    Offset Function(double x, double y, double z) proj,
    double Function(double x, double y, double z) depth, {
    required bool ground,
  }) {
    final r = params.radius;
    final z = -params.coneHeight;
    const nGuide = 72;
    Offset? prev;
    for (var i = 0; i <= nGuide; i++) {
      final a = 2 * math.pi * i / nGuide;
      final o = proj(r * math.cos(a), r * math.sin(a), z);
      if (prev != null) {
        canvas.drawLine(
          prev,
          o,
          Paint()
            ..color = _orbit.withValues(alpha: 0.22)
            ..strokeWidth = 1.3,
        );
      }
      prev = o;
    }

    const n = 32;
    final base = ground ? sample.phi : 0.0;
    final pts = <({Offset o, double depth, double alpha, double rad})>[];
    for (var i = 0; i < n; i++) {
      final a = base - 2 * math.pi * i / n;
      final x = r * math.cos(a);
      final y = r * math.sin(a);
      final age = n <= 1 ? 1.0 : 1 - i / (n - 1);
      pts.add((
        o: proj(x, y, z),
        depth: depth(x, y, z),
        alpha: ground ? 0.22 + 0.72 * age : 0.45,
        rad: ground ? 1.5 + 1.5 * age : 1.8,
      ));
    }
    pts.sort((a, b) => a.depth.compareTo(b.depth));
    for (final p in pts) {
      canvas.drawCircle(
        p.o,
        p.rad,
        Paint()..color = _orbit.withValues(alpha: p.alpha),
      );
    }
  }

  void _drawAngleArc(
    Canvas canvas,
    Offset Function(double x, double y, double z) proj,
    double phi,
  ) {
    final arcR = params.length * 0.26;
    final path = Path();
    const n = 16;
    for (var i = 0; i <= n; i++) {
      final a = params.theta * i / n;
      final o = proj(
        arcR * math.sin(a) * math.cos(phi),
        arcR * math.sin(a) * math.sin(phi),
        -arcR * math.cos(a),
      );
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
    final am = params.theta * 0.62;
    final labelR = arcR * 1.35;
    final label = proj(
      labelR * math.sin(am) * math.cos(phi),
      labelR * math.sin(am) * math.sin(phi),
      -labelR * math.cos(am),
    );
    _text(canvas, label, 'θ', _ink);
  }

  void _drawVelocity(
    Canvas canvas,
    Offset Function(double x, double y, double z) proj,
    Offset bobO,
    double unit,
  ) {
    final speed = math.sqrt(
      sample.vx * sample.vx + sample.vy * sample.vy + sample.vz * sample.vz,
    );
    if (speed < 0.05) return;
    final screen = _screenDir(proj, sample.vx, sample.vy, sample.vz);
    final foreshorten = arrowScreenForeshorten(
      screenPx: screen.distance,
      pxPerMeter: unit,
    );
    final len = ((speed * 11).clamp(14.0, 46.0)) * foreshorten;
    if (len < 4 || screen.distance < 1e-6) return;
    _arrow(
      canvas,
      bobO + const Offset(11, -6),
      screen / screen.distance,
      len,
      _velocity,
      'v',
    );
  }

  Offset _screenDir(
    Offset Function(double, double, double) proj,
    double ux,
    double uy,
    double uz,
  ) {
    final mag = math.sqrt(ux * ux + uy * uy + uz * uz);
    if (mag < 1e-12) return Offset.zero;
    final eps = kArrowWorldEps;
    return proj(ux / mag * eps, uy / mag * eps, uz / mag * eps) - proj(0, 0, 0);
  }

  void _drawForces(
    Canvas canvas,
    Offset Function(double x, double y, double z) proj,
    Offset bobO,
    double unit, {
    required bool ground,
  }) {
    final f = sample.forces;
    // 正面での長さは |F| に比例（基準は mg）。視線方向へ潰れた分は掛ける。
    double forcePx(double mag) {
      final ref = params.mass * kConeG;
      if (ref < 1e-9) return 0;
      return (28 * mag / ref).clamp(0.0, 78.0);
    }

    ({Offset dir, double mag, double foreshorten})? prepare(
      double fx,
      double fy,
      double fz,
    ) {
      final mag = math.sqrt(fx * fx + fy * fy + fz * fz);
      if (mag < 0.05) return null;
      final screen = _screenDir(proj, fx, fy, fz);
      if (screen.distance < 1e-6) return null;
      final foreshorten = arrowScreenForeshorten(
        screenPx: screen.distance,
        pxPerMeter: unit,
      );
      if (foreshorten < 0.05) return null;
      return (
        dir: screen / screen.distance,
        mag: mag,
        foreshorten: foreshorten,
      );
    }

    void draw(
      ({Offset dir, double mag, double foreshorten})? arrow,
      Color color,
      String label, {
      bool dashed = false,
      Offset? origin,
      double labelSide = 1,
    }) {
      if (arrow == null) return;
      final length = forcePx(arrow.mag) * arrow.foreshorten;
      if (length < 4) return;
      _arrow(
        canvas,
        origin ?? bobO,
        arrow.dir,
        length,
        color,
        label,
        dashed: dashed,
        labelSide: labelSide,
      );
    }

    final cp = math.cos(sample.phi);
    final sp = math.sin(sample.phi);
    final tx = ground ? f.tensionX * cp : f.tensionX;
    final ty = ground ? f.tensionX * sp : 0.0;
    final tz = f.tensionZ;
    final tension = prepare(tx, ty, tz);
    final gravity = prepare(0, 0, f.gravityZ);

    if (ground) {
      final resultant = prepare(f.sumTrueX * cp, f.sumTrueX * sp, f.sumTrueZ);
      draw(gravity, _gravity, '重力');
      draw(tension, _tension, '張力');
      draw(resultant, _resultant, '合力', labelSide: -1);
    } else {
      final cen = prepare(f.cenX, 0, 0);
      draw(gravity, _gravity, '重力', labelSide: -1);
      draw(tension, _tension, '張力');
      draw(cen, _centrifugal, '遠心力', dashed: true, labelSide: -1);
    }
  }

  void _drawFloor(
    Canvas canvas,
    Rect plot,
    Offset Function(double x, double y, double z) proj, {
    required bool ground,
  }) {
    const n = 10;
    const half = 1.15;
    final step = (2 * half) / n;
    final z = -params.length * 1.18;
    final angle = ground ? 0.0 : sample.phi;
    final ca = math.cos(angle);
    final sa = math.sin(angle);
    for (var ix = 0; ix < n; ix++) {
      for (var iy = 0; iy < n; iy++) {
        final x0 = -half + ix * step;
        final y0 = -half + iy * step;
        final corners = [
          _rot(x0, y0, ca, sa),
          _rot(x0 + step, y0, ca, sa),
          _rot(x0 + step, y0 + step, ca, sa),
          _rot(x0, y0 + step, ca, sa),
        ];
        final path = Path();
        for (var i = 0; i < 4; i++) {
          final p = proj(
            corners[i].dx * params.length,
            corners[i].dy * params.length,
            z,
          );
          if (i == 0) {
            path.moveTo(p.dx, p.dy);
          } else {
            path.lineTo(p.dx, p.dy);
          }
        }
        path.close();
        if (!plot.overlaps(path.getBounds())) continue;
        canvas.drawPath(
          path,
          Paint()..color = (ix + iy).isEven ? _floorA : _floorB,
        );
      }
    }
  }

  Offset _rot(double x, double y, double ca, double sa) {
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
    double labelSide = 1,
  }) {
    if (length < 4) return;
    final tip = origin + dir * length;
    final headLen = math.min(9.0, length * 0.38);
    final headHalf = headLen * 0.5;
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
      ..lineTo(
        (tip - dir * headLen + n * headHalf).dx,
        (tip - dir * headLen + n * headHalf).dy,
      )
      ..lineTo(
        (tip - dir * headLen - n * headHalf).dx,
        (tip - dir * headLen - n * headHalf).dy,
      )
      ..close();
    canvas.drawPath(head, Paint()..color = color);
    if (length < 16) return;
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
  bool shouldRepaint(covariant _ConicalPendulumPainter oldDelegate) {
    return oldDelegate.sample.t != sample.t ||
        oldDelegate.sample.phi != sample.phi ||
        oldDelegate.params.thetaDeg != params.thetaDeg ||
        oldDelegate.params.length != params.length ||
        oldDelegate.params.mass != params.mass ||
        oldDelegate.azimuth != azimuth ||
        oldDelegate.tilt != tilt ||
        oldDelegate.scale != scale;
  }
}
