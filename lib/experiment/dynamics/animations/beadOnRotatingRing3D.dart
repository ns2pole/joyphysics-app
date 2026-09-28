import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/arrow_screen.dart';
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
const double kRingMinTheta0 = 0.0;
const double kRingMaxTheta0 = math.pi - 0.05;
const double kRingDefaultTheta0 = 0.35;
const double kRingMinThetaDot0 = -4.00;
const double kRingMaxThetaDot0 = 4.00;
const double kRingDefaultThetaDot0 = 0.00;
const double kRingSideBySideWidth = 640.0;
const double kRingPlayback = 0.55;
const double kRingDt = 1.0 / 240.0;

/// 軌道点線の時間間隔。
const double kRingTrailDt = 0.045;
const int kRingTrailMax = 160;

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

  /// 安定なつり合い角。$\omega^{2}\le g/R$ なら底 $\theta=0$、それ以外は斜めつり合い。
  double get stableEquilibriumTheta => equilibriumTheta ?? 0.0;

  /// $\omega^{2}>g/R$ なら斜めつり合いが安定。
  bool get hasObliqueEquilibrium => equilibriumTheta != null;

  factory RingBeadParams.fromMap(Map<String, double> params) {
    return RingBeadParams(
      r: params['r']!.clamp(kRingMinR, kRingMaxR).toDouble(),
      omega: params['W']!.clamp(kRingMinOmega, kRingMaxOmega).toDouble(),
      mass: params['m']!.clamp(kRingMinM, kRingMaxM).toDouble(),
      theta0: params['th0']!.clamp(kRingMinTheta0, kRingMaxTheta0).toDouble(),
      thetaDot0: params['thd0']!
          .clamp(kRingMinThetaDot0, kRingMaxThetaDot0)
          .toDouble(),
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
    required this.forces,
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

  /// 回転系での力の成分（真の力＋慣性力）。
  final RingBeadForces forces;

  double get forceTangential => gravityTangential + centrifugalTangential;
}

/// 回転系（円環を $xz$ 面に固定）での力。単位は N。
class RingBeadForces {
  const RingBeadForces({
    required this.gx,
    required this.gy,
    required this.gz,
    required this.nx,
    required this.ny,
    required this.nz,
    required this.cfx,
    required this.cfy,
    required this.cfz,
    required this.cox,
    required this.coy,
    required this.coz,
  });

  /// 重力 $m\vec{g}$。
  final double gx;
  final double gy;
  final double gz;

  /// 円環からの拘束力（接線成分は 0）。
  final double nx;
  final double ny;
  final double nz;

  /// 遠心力 $m\omega^{2}\rho\,\hat{\rho}$。
  final double cfx;
  final double cfy;
  final double cfz;

  /// コリオリ力 $-2m\vec{\omega}\times\vec{v}_{\mathrm{rel}}$。
  final double cox;
  final double coy;
  final double coz;

  double get gMag => math.sqrt(gx * gx + gy * gy + gz * gz);
  double get nMag => math.sqrt(nx * nx + ny * ny + nz * nz);
  double get cfMag => math.sqrt(cfx * cfx + cfy * cfy + cfz * cfz);
  double get coMag => math.sqrt(cox * cox + coy * coy + coz * coz);
}

/// 回転系での力。$\hat{e}_{\theta}=(\cos\theta,0,\sin\theta)$。
RingBeadForces ringBeadForcesAt(
  RingBeadParams params,
  double theta,
  double thetaDot,
) {
  final m = params.mass;
  final r = params.r;
  final w = params.omega;
  final s = math.sin(theta);
  final c = math.cos(theta);
  final thd = thetaDot;
  final gx = 0.0;
  const gy = 0.0;
  final gz = -m * kRingG;
  // 遠心力：軸から外。$\rho=R\sin\theta$、$\hat{\rho}=\hat{x}$。
  final cfx = m * w * w * r * s;
  const cfy = 0.0;
  const cfz = 0.0;
  // コリオリ：面に垂直。$\vec{\omega}=\omega\hat{z}$、$v_{\mathrm{rel}}=R\dot\theta\hat{e}_{\theta}$。
  const cox = 0.0;
  final coy = -2 * m * w * r * thd * c;
  const coz = 0.0;
  // 拘束力（滑らかな円環 ⇒ $\vec{N}\cdot\hat{e}_{\theta}=0$）。
  final nx = -m * s * (w * w * r * s * s + kRingG * c + r * thd * thd);
  final ny = 2 * m * w * r * thd * c;
  final nz = m * c * (w * w * r * s * s + r * thd * thd + kRingG * c);
  return RingBeadForces(
    gx: gx,
    gy: gy,
    gz: gz,
    nx: nx,
    ny: ny,
    nz: nz,
    cfx: cfx,
    cfy: cfy,
    cfz: cfz,
    cox: cox,
    coy: coy,
    coz: coz,
  );
}

/// $\ddot\theta=\sin\theta(\omega^{2}\cos\theta-g/R)$
double ringBeadAccel(RingBeadParams params, double theta) {
  final s = math.sin(theta);
  final c = math.cos(theta);
  return s * (params.omega * params.omega * c - kRingG / params.r);
}

RingBeadPhase ringBeadStep(
  RingBeadPhase phase,
  RingBeadParams params,
  double dt,
) {
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
    forces: ringBeadForcesAt(params, th, phase.thetaDot),
  );
}

String ringBeadCaption(RingBeadParams params, {bool equilibriumMode = false}) {
  if (equilibriumMode) {
    final th = params.stableEquilibriumTheta;
    if (!params.hasObliqueEquilibrium) {
      return '釣り合いモード：底 θ=0 に固定。円環だけ回る。\n'
          'ω を上げると斜めつり合いへ移る。';
    }
    return '釣り合いモード：θ=${th.toStringAsFixed(2)} rad に固定。\n'
        '円環と一緒に回り、回転系では止まって見える。';
  }
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
  <p>真の力は重力と円環からの拘束力です。円環と一緒に回る人から見ると、円環は止まっていて、遠心力と（ビーズが動いていれば）コリオリ力も加わります。接線方向に効くのは重力と遠心力だけで、コリオリ力は面に垂直なので拘束力が受け持ち、$\theta$ の式には入りません。アニメでは両系に力を全部描きます。重力ベクトルそのものは一定です。</p>
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
        is3D: true,
      );

  @override
  bool get showZoomButtons => true;

  final ValueNotifier<double> simTime = ValueNotifier(0.0);
  RingBeadPhase _phase = const RingBeadPhase(
    t: 0,
    theta: kRingDefaultTheta0,
    thetaDot: 0,
  );
  RingBeadParams? _frozen;
  Map<String, double> _latestParams = {};
  void Function(String key, double value)? _updateParam;
  bool _equilibriumMode = false;
  final ValueNotifier<int> _uiTick = ValueNotifier(0);
  final List<({double theta, double phi})> _trail = [];
  double _lastTrailT = -1e9;

  late final PlaybackLoop _loop = PlaybackLoop(
    onTick: (dt) {
      final p = _equilibriumMode ? _params : (_frozen ?? _params);
      final advanced = dt * kRingPlayback;
      if (_equilibriumMode) {
        final th = p.stableEquilibriumTheta;
        _phase = RingBeadPhase(t: _phase.t + advanced, theta: th, thetaDot: 0);
      } else {
        final steps = math.max(1, (advanced / kRingDt).ceil());
        final step = advanced / steps;
        var phase = _phase;
        for (var i = 0; i < steps; i++) {
          phase = ringBeadStep(phase, p, step);
        }
        _phase = phase;
      }
      _appendTrail(p);
      simTime.value = _phase.t;
    },
  );

  void _clearTrail() {
    _trail.clear();
    _lastTrailT = -1e9;
  }

  void _appendTrail(RingBeadParams p) {
    if (_trail.isNotEmpty && _phase.t - _lastTrailT < kRingTrailDt) return;
    _lastTrailT = _phase.t;
    _trail.add((theta: _phase.theta, phi: p.omega * _phase.t));
    while (_trail.length > kRingTrailMax) {
      _trail.removeAt(0);
    }
  }

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
  String? get situation => '鉛直直径まわりに一定角速度で回る滑らかな円環に拘束されたビーズ';

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
    if (_equilibriumMode) {
      final th = p.stableEquilibriumTheta;
      _phase = RingBeadPhase(t: 0, theta: th, thetaDot: 0);
    } else {
      _phase = RingBeadPhase(t: 0, theta: p.theta0, thetaDot: p.thetaDot0);
    }
    simTime.value = 0;
  }

  void _applyEquilibriumIcs() {
    final th = _params.stableEquilibriumTheta;
    _latestParams =
        Map<String, double>.from(
            _latestParams.isEmpty ? initialParameters : _latestParams,
          )
          ..['th0'] = th
          ..['thd0'] = 0.0;
    _updateParam?.call('th0', th);
    _updateParam?.call('thd0', 0.0);
    _frozen = null;
    _phase = RingBeadPhase(t: _phase.t, theta: th, thetaDot: 0);
    simTime.value = _phase.t;
  }

  void setEquilibriumMode(bool on) {
    if (_equilibriumMode == on) return;
    _equilibriumMode = on;
    _clearTrail();
    if (on) {
      _applyEquilibriumIcs();
      if (!running.value) start();
    } else {
      // いまの釣り合い位置を運動モードの初期条件にする。
      final th = _phase.theta;
      _latestParams =
          Map<String, double>.from(
              _latestParams.isEmpty ? initialParameters : _latestParams,
            )
            ..['th0'] = th
            ..['thd0'] = 0.0;
      _updateParam?.call('th0', th);
      _updateParam?.call('thd0', 0.0);
      _frozen = _params;
      _phase = RingBeadPhase(t: _phase.t, theta: th, thetaDot: 0);
    }
    _appendTrail(_params);
    _uiTick.value++;
  }

  @override
  void startPlayback() => start();

  void start() {
    if (running.value) return;
    _clearTrail();
    if (_equilibriumMode) {
      _frozen = null;
      final th = _params.stableEquilibriumTheta;
      _phase = RingBeadPhase(t: 0, theta: th, thetaDot: 0);
    } else {
      _frozen = _params;
      _phase = RingBeadPhase(
        t: 0,
        theta: _frozen!.theta0,
        thetaDot: _frozen!.thetaDot0,
      );
    }
    _appendTrail(_frozen ?? _params);
    simTime.value = 0;
    _loop.start();
  }

  void pause() => _loop.pause();

  void resetMotion() {
    _loop.reset();
    _frozen = null;
    _clearTrail();
    if (_equilibriumMode) {
      _applyEquilibriumIcs();
      _phase = RingBeadPhase(
        t: 0,
        theta: _params.stableEquilibriumTheta,
        thetaDot: 0,
      );
    } else {
      final p = _params;
      _phase = RingBeadPhase(t: 0, theta: p.theta0, thetaDot: p.thetaDot0);
    }
    _appendTrail(_params);
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
  Widget? buildFormulaOverlay(Map<String, double> parameters) {
    _rememberParams(parameters);
    if (_equilibriumMode) {
      final p = _params;
      return SizedBox(
        height: 52,
        child: Center(
          child: FormulaDisplay(
            p.hasObliqueEquilibrium
                ? r'\displaystyle \cos\theta=\frac{g}{\omega^{2}R}\ \text{（釣り合い）}'
                : r'\displaystyle \theta=0\ \text{（底が安定）}',
          ),
        ),
      );
    }
    return const SizedBox(
      height: 52,
      child: Center(
        child: FormulaDisplay(
          r'\displaystyle \ddot{\theta}=\sin\theta\Bigl(\omega^{2}\cos\theta-\frac{g}{R}\Bigr)',
        ),
      ),
    );
  }

  @override
  Widget? buildExtraControls(
    BuildContext context,
    Set<String> activeIds,
    void Function(Set<String> ids) updateActiveIds,
  ) {
    return AnimatedBuilder(
      animation: Listenable.merge([running, _uiTick]),
      builder: (context, _) {
        final isRunning = running.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ringBeadCaption(_params, equilibriumMode: _equilibriumMode),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Color(0xFF546E7A),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('釣り合い'),
                  selected: _equilibriumMode,
                  onSelected: setEquilibriumMode,
                ),
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
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: Center(
                child: PlayPauseResetButtons(
                  playing: isRunning,
                  onPlayPause: isRunning ? pause : start,
                  onReset: resetMotion,
                ),
              ),
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
    _updateParam = updateParam;
    _rememberParams(parameters);
    final p = _params;
    if (_equilibriumMode) {
      final th = p.stableEquilibriumTheta;
      if ((p.theta0 - th).abs() > 1e-6 || p.thetaDot0.abs() > 1e-9) {
        // ω・R 変更に合わせて釣り合い位置を追従させる。
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_equilibriumMode) return;
          _updateParam?.call('th0', th);
          _updateParam?.call('thd0', 0.0);
        });
      }
    }
    if (!running.value) _syncPhaseToIcs(p);
    return [
      AnimatedBuilder(
        animation: _uiTick,
        builder: (context, _) {
          final live = _params;
          final eq = live.equilibriumTheta;
          final eqLocked = _equilibriumMode;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '滑らかな円環・鉛直直径まわりに一定 ω',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              _RingSlider(
                label: 'R',
                value: live.r,
                min: kRingMinR,
                max: kRingMaxR,
                onChanged: (v) {
                  _clearTrail();
                  updateParam('r', v);
                },
                semanticLabel: '半径 R',
              ),
              _RingSlider(
                label: 'ω',
                value: live.omega,
                min: kRingMinOmega,
                max: kRingMaxOmega,
                onChanged: (v) {
                  _clearTrail();
                  updateParam('W', v);
                },
                semanticLabel: '角速度 ω',
              ),
              _RingSlider(
                label: 'm',
                value: live.mass,
                min: kRingMinM,
                max: kRingMaxM,
                onChanged: (v) {
                  _clearTrail();
                  updateParam('m', v);
                },
                semanticLabel: '質量 m',
              ),
              IgnorePointer(
                ignoring: eqLocked,
                child: Opacity(
                  opacity: eqLocked ? 0.45 : 1,
                  child: _RingSlider(
                    label: 'θ₀',
                    value: live.theta0,
                    min: kRingMinTheta0,
                    max: kRingMaxTheta0,
                    onChanged: (v) {
                      _clearTrail();
                      updateParam('th0', v);
                    },
                    semanticLabel: '初期角 θ0',
                  ),
                ),
              ),
              IgnorePointer(
                ignoring: eqLocked,
                child: Opacity(
                  opacity: eqLocked ? 0.45 : 1,
                  child: _RingSlider(
                    label: 'θ̇₀',
                    value: live.thetaDot0,
                    min: kRingMinThetaDot0,
                    max: kRingMaxThetaDot0,
                    onChanged: (v) {
                      _clearTrail();
                      updateParam('thd0', v);
                    },
                    semanticLabel: '初期角速度 θドット0',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SizedBox(
                  height: 32,
                  child: Text(
                    eq == null
                        ? 'g/R = ${(kRingG / live.r).toStringAsFixed(2)}    '
                              'ω² = ${(live.omega * live.omega).toStringAsFixed(2)}  → 底が安定'
                        : 'つり合い θ = ${eq.toStringAsFixed(2)} rad    '
                              'ω²R/g = ${(live.omega * live.omega * live.r / kRingG).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Courier',
                      color: Color(0xFF37474F),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
      animation: Listenable.merge([running, simTime, _uiTick]),
      builder: (context, _) {
        final p = _equilibriumMode
            ? RingBeadParams.fromMap(parameters)
            : (_frozen ?? RingBeadParams.fromMap(parameters));
        final sample = ringBeadSampleAt(p, _phase);
        return CustomPaint(
          size: Size.infinite,
          painter: _RingBeadPainter(
            params: p,
            sample: sample,
            trail: List<({double theta, double phi})>.from(_trail),
            azimuth: azimuth,
            tilt: tilt,
            scale: scale,
          ),
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
    required this.trail,
    required this.azimuth,
    required this.tilt,
    required this.scale,
  });

  final RingBeadParams params;
  final RingBeadSample sample;
  final List<({double theta, double phi})> trail;
  final double azimuth;
  final double tilt;
  final double scale;

  static const _bg = Color(0xFFF4F7FA);
  static const _ink = Color(0xFF37474F);
  static const _muted = Color(0xFF546E7A);
  static const _bead = Color(0xFFE53935);
  static const _ringA = Color(0xFF1565C0);
  static const _axis = Color(0xFF78909C);
  static const _gravity = Color(0xFF5D4037);
  static const _centrifugal = Color(0xFF2E7D32);
  static const _coriolis = Color(0xFF0277BD);
  static const _constraint = Color(0xFFF9A825);
  static const _resultant = Color(0xFF00838F);
  static const _velocity = Color(0xFF6A1B9A);
  static const _floorA = Color(0xFFE8E0D4);
  static const _floorB = Color(0xFFD4C6B4);
  static const _eq = Color(0xFF00897B);

  /// 波動の平面波と同じ操作系。初期は見やすい斜め上へ少しずらす。
  static const double _az0 = 0.55;

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
    if (params.equilibriumTheta != null) {
      _text(
        canvas,
        Offset(size.width - 8, 6),
        '緑○：安定な釣り合い位置（左右対称）',
        _eq,
        alignRight: true,
      );
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
    // 円環は約 1.5 倍（ズーム +3 回 ≈ 1.15³ 相当）。床の広さは half で別制御。
    const viewScale = 1.5;
    final unit =
        math.min(plot.width, plot.height) /
        (3.5 * kRingMaxR) *
        scale *
        viewScale;
    final az = azimuth + _az0;
    final t = tilt.clamp(0.05, math.pi / 2);
    final cA = math.cos(az);
    final sA = math.sin(az);
    final cT = math.cos(t);
    final sT = math.sin(t);

    // 正投影（画面縦横同スケール）。真上から見ても円環は円に見える。
    Offset proj(double x, double y, double z) {
      final x1 = x * cA - y * sA;
      final y1 = x * sA + y * cA;
      final xCam = x1;
      final yCam = -y1 * sT + z * cT;
      return Offset(plot.center.dx + xCam * unit, plot.center.dy - yCam * unit);
    }

    double depth(double x, double y, double z) {
      final y1 = x * sA + y * cA;
      return y1 * cT + z * sT;
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
    _scene(canvas, proj, depth, unit, ground: ground);
    _text(
      canvas,
      Offset(panel.center.dx, panel.bottom - 18),
      ground ? '真の力の合力 = ma。軌道は時間等間隔の点。' : '遠心力・コリオリ込みの合力。',
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

    // 円環軌道：時間等間隔ドットの点線（＋淡いガイド円）
    _drawHoop(canvas, proj, depth, r, phi, ground: ground);

    // 安定つり合いの目印（回転系のみ・斜めつり合いがあるとき）
    final eq = params.equilibriumTheta;
    if (!ground && eq != null) {
      for (final sign in [1.0, -1.0]) {
        final th = sign > 0 ? eq : (2 * math.pi - eq);
        final p = _beadWorld(r, th, 0);
        final o = proj(p.$1, p.$2, p.$3);
        canvas.drawCircle(o, 2.6, Paint()..color = _eq.withValues(alpha: 0.28));
        canvas.drawCircle(
          o,
          2.6,
          Paint()
            ..color = _eq.withValues(alpha: 0.95)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }

    final beadTh = sample.theta;
    final bead = ground
        ? (sample.x, sample.y, sample.z)
        : (sample.xRot, sample.yRot, sample.zRot);
    final beadO = proj(bead.$1, bead.$2, bead.$3);

    _drawAllForces(canvas, proj, beadO, unit, ground: ground);

    // 速度（力と重ならないよう少しずらす）
    if (ground) {
      final s = math.sin(beadTh);
      final c = math.cos(beadTh);
      final cp = math.cos(phi);
      final sp = math.sin(phi);
      final thd = sample.thetaDot;
      final phd = params.omega;
      _drawVelocity(
        canvas,
        proj,
        beadO + const Offset(12, -8),
        unit,
        vx: r * (c * thd * cp - s * sp * phd),
        vy: r * (c * thd * sp + s * cp * phd),
        vz: r * s * thd,
      );
    } else {
      final s = math.sin(beadTh);
      final c = math.cos(beadTh);
      _drawVelocity(
        canvas,
        proj,
        beadO + const Offset(-12, -8),
        unit,
        vx: r * sample.thetaDot * c,
        vy: 0,
        vz: r * sample.thetaDot * s,
      );
    }

    canvas.drawCircle(
      beadO.translate(0.7, 0.8),
      5,
      Paint()..color = Colors.black26,
    );
    canvas.drawCircle(beadO, 4.5, Paint()..color = _bead);
    canvas.drawCircle(
      beadO.translate(-1.25, -1.25),
      1.25,
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
    double Function(double x, double y, double z) depth,
    double r,
    double phi, {
    required bool ground,
  }) {
    const nGuide = 64;
    // 淡いガイド円（拘束の形）
    Offset? prev;
    for (var i = 0; i <= nGuide; i++) {
      final th = 2 * math.pi * i / nGuide;
      final w = _beadWorld(r, th, phi);
      final o = proj(w.$1, w.$2, w.$3);
      if (prev != null) {
        canvas.drawLine(
          prev,
          o,
          Paint()
            ..color = _ringA.withValues(alpha: 0.22)
            ..strokeWidth = 1.4
            ..strokeCap = StrokeCap.round,
        );
      }
      prev = o;
    }

    // 軌道：時間等間隔で記録したビーズ位置を点で描く
    final pts = <({Offset o, double depth})>[];
    for (final p in trail) {
      final ringPhi = ground ? p.phi : 0.0;
      final w = _beadWorld(r, p.theta, ringPhi);
      pts.add((o: proj(w.$1, w.$2, w.$3), depth: depth(w.$1, w.$2, w.$3)));
    }
    pts.sort((a, b) => a.depth.compareTo(b.depth));
    final n = pts.length;
    for (var i = 0; i < n; i++) {
      final age = n <= 1 ? 1.0 : i / (n - 1);
      final alpha = 0.25 + 0.70 * age;
      final rad = 1.6 + 1.4 * age;
      canvas.drawCircle(
        pts[i].o,
        rad,
        Paint()..color = _ringA.withValues(alpha: alpha),
      );
    }
  }

  void _drawVelocity(
    Canvas canvas,
    Offset Function(double x, double y, double z) proj,
    Offset beadO,
    double unit, {
    required double vx,
    required double vy,
    required double vz,
  }) {
    final speed = math.sqrt(vx * vx + vy * vy + vz * vz);
    if (speed < 0.08) return;
    final screen = _screenDir(proj, vx, vy, vz);
    if (screen.distance < 1e-6) return;
    final foreshorten = arrowScreenForeshorten(
      screenPx: screen.distance,
      pxPerMeter: unit,
    );
    final len = ((speed * 14).clamp(12.0, 48.0)) * foreshorten;
    if (len < 4) return;
    _arrow(canvas, beadO, screen / screen.distance, len, _velocity, 'v');
  }

  /// 単位ベクトルの画面向き。視線と平行ならほぼ 0（真上から見た重力など）。
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

  /// 正面の長さは |F|。視線方向へ潰れた分は掛ける。
  void _drawAllForces(
    Canvas canvas,
    Offset Function(double x, double y, double z) proj,
    Offset beadO,
    double unit, {
    required bool ground,
  }) {
    final f = sample.forces;
    // 慣性系／回転系で同じ px/N（重力・拘束力がパネル間で別長さにならないように）。
    final biggest = [f.gMag, f.nMag, f.cfMag, f.coMag].reduce(math.max);
    double forcePx(double mag) {
      if (biggest < 1e-9) return 0;
      return 48 * mag / biggest;
    }

    void drawVec(
      double fx,
      double fy,
      double fz,
      Color color,
      String label, {
      bool dashed = false,
    }) {
      final mag = math.sqrt(fx * fx + fy * fy + fz * fz);
      if (mag < 0.05) return;
      final screen = _screenDir(proj, fx, fy, fz);
      if (screen.distance < 1e-6) return;
      final foreshorten = arrowScreenForeshorten(
        screenPx: screen.distance,
        pxPerMeter: unit,
      );
      final length = forcePx(mag) * foreshorten;
      if (length < 4) return;
      _arrow(
        canvas,
        beadO,
        screen / screen.distance,
        length,
        color,
        label,
        dashed: dashed,
      );
    }

    if (ground) {
      // 慣性系: 真の力だけ（重力＋拘束力）。拘束は φ で回す。
      final cp = math.cos(sample.phi);
      final sp = math.sin(sample.phi);
      final nix = f.nx * cp - f.ny * sp;
      final niy = f.nx * sp + f.ny * cp;
      final niz = f.nz;
      drawVec(f.gx, f.gy, f.gz, _gravity, '重力');
      drawVec(nix, niy, niz, _constraint, '拘束力');
      drawVec(f.gx + nix, f.gy + niy, f.gz + niz, _resultant, '合力(=ma)');
    } else {
      // 回転系: 重力・遠心力・コリオリ・拘束力。
      drawVec(f.gx, f.gy, f.gz, _gravity, '重力');
      drawVec(f.cfx, f.cfy, f.cfz, _centrifugal, '遠心力', dashed: true);
      drawVec(f.cox, f.coy, f.coz, _coriolis, 'コリオリ', dashed: true);
      drawVec(f.nx, f.ny, f.nz, _constraint, '拘束力');
      drawVec(
        f.gx + f.nx + f.cfx + f.cox,
        f.gy + f.ny + f.cfy + f.coy,
        f.gz + f.nz + f.cfz + f.coz,
        _resultant,
        '合力',
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
    // 床の半幅（いまの 1.5 倍）。
    const n = 11;
    const half = (2.85 / 1.5) * (2.0 / 1.5) * 1.2 * 1.5 * 0.75;
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
    bool alignRight = false,
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
    final dx = alignRight
        ? o.dx - tp.width
        : (alignLeft ? o.dx : o.dx - tp.width / 2);
    tp.paint(canvas, Offset(dx, o.dy));
  }

  @override
  bool shouldRepaint(covariant _RingBeadPainter oldDelegate) {
    return oldDelegate.sample.t != sample.t ||
        oldDelegate.sample.theta != sample.theta ||
        oldDelegate.trail.length != trail.length ||
        (trail.isNotEmpty &&
            oldDelegate.trail.isNotEmpty &&
            (oldDelegate.trail.last.theta != trail.last.theta ||
                oldDelegate.trail.last.phi != trail.last.phi)) ||
        oldDelegate.params.r != params.r ||
        oldDelegate.params.omega != params.omega ||
        oldDelegate.params.mass != params.mass ||
        oldDelegate.azimuth != azimuth ||
        oldDelegate.tilt != tilt ||
        oldDelegate.scale != scale;
  }
}
