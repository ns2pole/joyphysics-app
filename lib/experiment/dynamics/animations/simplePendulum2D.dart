import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

/// 鉛直下から測った角。画面のスライダーは度、式はラジアン。
const double kPendulumG = 9.8;
const double kPendulumMinL = 0.25;
const double kPendulumMaxL = 2.00;
const double kPendulumDefaultL = 1.00;

const double kEllipticMinDeg = 5.0;
const double kEllipticMaxDeg = 150.0;
const double kEllipticDefaultDeg = 30.0;

class JacobiElliptic {
  const JacobiElliptic(this.sn, this.cn, this.dn);

  final double sn;
  final double cn;
  final double dn;
}

class PendulumState {
  const PendulumState({
    required this.t,
    required this.theta,
    required this.omega,
  });

  final double t;

  /// 鉛直下から。右回りを正にする画面では、正が右。
  final double theta;

  /// $\dot\theta$。
  final double omega;
}

class PendulumBobPosition {
  const PendulumBobPosition(this.x, this.y);

  /// 支点原点。右が正。
  final double x;

  /// 支点原点。上が正。鉛直下は負。
  final double y;
}

double _cosh(double x) {
  final ax = x.abs();
  if (ax > 20) return 0.5 * math.exp(ax);
  final e = math.exp(ax);
  return 0.5 * (e + 1 / e);
}

double _tanh(double x) {
  if (x.abs() > 20) return x.isNegative ? -1 : 1;
  final e = math.exp(2 * x);
  return (e - 1) / (e + 1);
}

/// 第一種完全楕円積分 $K(k)$。$k$ は母数。
double completeEllipticK(double k) {
  final m = k * k;
  if (m <= 0) return math.pi / 2;
  if (m >= 1) return double.infinity;
  var a = 1.0;
  var b = math.sqrt(1 - m);
  for (var i = 0; i < 30; i++) {
    final nextA = 0.5 * (a + b);
    final nextB = math.sqrt(a * b);
    a = nextA;
    b = nextB;
    if ((a - b).abs() < 1e-15) break;
  }
  return math.pi / (2 * a);
}

/// ヤコビの楕円関数 $\mathrm{sn},\mathrm{cn},\mathrm{dn}$。算術幾何平均。
JacobiElliptic jacobiElliptic(double u, double k) {
  final m = (k * k).clamp(0.0, 1.0).toDouble();
  if (m < 1e-16) {
    return JacobiElliptic(math.sin(u), math.cos(u), 1);
  }
  if (m > 1 - 1e-16) {
    final sech = 1 / _cosh(u);
    return JacobiElliptic(_tanh(u), sech, sech);
  }
  final a = <double>[1];
  final c = <double>[math.sqrt(m)];
  var b = math.sqrt(1 - m);
  var n = 0;
  while (c[n].abs() > 1e-15 && n < 20) {
    a.add(0.5 * (a[n] + b));
    c.add(0.5 * (a[n] - b));
    b = math.sqrt(a[n] * b);
    n++;
  }
  var twon = 1.0;
  for (var i = 0; i < n; i++) {
    twon *= 2;
  }
  var phi = twon * a[n] * u;
  for (var i = n; i > 0; i--) {
    final arg = ((c[i] / a[i]) * math.sin(phi)).clamp(-1.0, 1.0).toDouble();
    phi = 0.5 * (math.asin(arg) + phi);
  }
  final sn = math.sin(phi);
  final cn = math.cos(phi);
  final dn = math.sqrt(math.max(0.0, 1 - m * sn * sn));
  return JacobiElliptic(sn, cn, dn);
}

double _foldEllipticArgument(double u, double completeK) {
  final period = 4 * completeK;
  if (!period.isFinite || period <= 0) return u;
  var x = u % period;
  if (x < 0) x += period;
  return x;
}

double pendulumSmallAnglePeriod(double length) =>
    2 * math.pi * math.sqrt(length / kPendulumG);

/// $k=\sin(\theta_0/2)$、$T=4\sqrt{l/g}\,K(k)$。
double pendulumExactPeriod(double length, double theta0) {
  final k = math.sin(theta0.abs() / 2);
  if (k >= 1) return double.infinity;
  return 4 * math.sqrt(length / kPendulumG) * completeEllipticK(k);
}

double pendulumPeriodRatio(double theta0) {
  final small = pendulumSmallAnglePeriod(1);
  final exact = pendulumExactPeriod(1, theta0);
  if (!exact.isFinite || small == 0) return double.infinity;
  return exact / small;
}

/// $\displaystyle \frac{T}{T_0}=1+\left(\frac{1}{2}\right)^{2}k^{2}+\cdots$
double pendulumPeriodRatioSeries(double theta0, {int terms = 8}) {
  final s = math.sin(theta0.abs() / 2);
  final m = s * s;
  var term = 1.0;
  var sum = 1.0;
  final nTerms = math.max(1, terms);
  for (var n = 1; n < nTerms; n++) {
    final factor = (2 * n - 1) / (2 * n);
    term *= factor * factor * m;
    sum += term;
  }
  return sum;
}

PendulumState pendulumSmallAngleAt(double length, double theta0, double t) {
  final time = math.max(0.0, t);
  final omega0 = math.sqrt(kPendulumG / length);
  return PendulumState(
    t: time,
    theta: theta0 * math.cos(omega0 * time),
    omega: -theta0 * omega0 * math.sin(omega0 * time),
  );
}

/// 最高点 $\theta_0$ から静かに放す。$\sin(\theta/2)=k\,\mathrm{sn}(K-\omega_0 t,k)$。
PendulumState pendulumExactAt(double length, double theta0, double t) {
  final time = math.max(0.0, t);
  final omega0 = math.sqrt(kPendulumG / length);
  if (theta0.abs() < 1e-12) {
    return PendulumState(t: time, theta: 0, omega: 0);
  }
  final k = math.sin(theta0.abs() / 2);
  if (k >= 1 - 1e-12) {
    return PendulumState(t: time, theta: theta0, omega: 0);
  }
  final bigK = completeEllipticK(k);
  final u = _foldEllipticArgument(bigK - omega0 * time, bigK);
  final j = jacobiElliptic(u, k);
  final sign = theta0 >= 0 ? 1.0 : -1.0;
  final theta = sign * 2 * math.asin((k * j.sn).clamp(-1.0, 1.0).toDouble());
  final omega = sign * (-2 * k * omega0 * j.cn);
  return PendulumState(t: time, theta: theta, omega: omega);
}

String _degLabel(double deg) {
  if ((deg - deg.roundToDouble()).abs() < 0.05) return '${deg.round()}°';
  return '${deg.toStringAsFixed(1)}°';
}

/// 張力を重さ $mg$ で割った値。負のときは糸がたるむ。
/// $\displaystyle \frac{T}{mg}=\cos\theta+\frac{l}{g}\dot\theta^{2}$。
double pendulumTensionRatio({
  required double theta,
  required double omega,
  required double length,
}) {
  return math.cos(theta) + length * omega * omega / kPendulumG;
}

PendulumBobPosition pendulumBob(double length, double theta) {
  return PendulumBobPosition(
    length * math.sin(theta),
    -length * math.cos(theta),
  );
}

enum PendulumArticleMode { approximate, exact, compare }

const String kPendulumApproximateLatex = r'''
  <div class="common-box">ポイント</div>
  <p>糸の長さを $l$、振れ角 $\theta$ を鉛直の下向きから測ります。$\theta$ はラジアンです。接線方向の運動方程式は $\displaystyle \ddot{\theta}=-\frac{g}{l}\sin\theta$ です。振れ角が小さいとき $\sin\theta$ を $\theta$ で置き換えると、次の微分方程式になります。</p>
  <p>$$\ddot{\theta}=-\frac{g}{l}\theta$$</p>
  <p>最高点 $\theta_{0}$ から静かに放すと、初期条件は $\theta(0)=\theta_{0}$、$\dot{\theta}(0)=0$ です。この解が、画面の橙の動きです。</p>
  <p>$$\theta(t)=\theta_{0}\cos\left(\sqrt{\frac{g}{l}}\,t\right)$$</p>
  <p>周期は振れ角によりません。</p>
  <p>$$T_{0}=2\pi\sqrt{\frac{l}{g}}$$</p>
  <p>同じ長さなら、振れの大きさが違っても周期は同じです。長さを $4$ 倍にすると周期は $2$ 倍になります。質量は入りません。振れ角を動かしても $T_{0}$ は変わりません。</p>
  <p>角が大きいところでも、この画面は $\sin\theta$ を $\theta$ と置いた微分方程式の解のまま動きます。本当の復元は $\sin\theta$ なので、同じ初期角の厳密な運動より早く戻ります。</p>
  <p>おもりに働くのは、下向きの重力と、支点へ向かう張力です。矢印はその二つです。</p>
  <p>$l=0.30\,\mathrm{m}$ と $0.60\,\mathrm{m}$ のときの $T_{0}$ は、実験の記事「単振り子の周期」と同じく約 $1.10\,\mathrm{s}$ と $1.55\,\mathrm{s}$ です。$g=9.8\,\mathrm{m/s^{2}}$ です。</p>
  <p>大きい角でこの式がずれることは、「厳密」と「比較」に切り替えると見えます。</p>
''';

const String kPendulumExactLatex = r'''
  <div class="common-box">ポイント</div>
  <p>振れ角を小さく近似しない運動方程式は次です。$\theta$ はラジアンで、鉛直の下向きから測ります。</p>
  <p>$$\ddot{\theta}=-\frac{g}{l}\sin\theta$$</p>
  <p>最高点の角 $\theta_{0}$ で静かに放すと、周期は第一種完全楕円積分 $K$ で書けます。</p>
  <p>$$k=\sin\frac{\theta_{0}}{2},\quad T=4\sqrt{\frac{l}{g}}\,K(k)$$</p>
  <p>$$K(k)=\int_{0}^{\frac{\pi}{2}}\frac{\mathrm{d}\varphi}{\sqrt{1-k^{2}\sin^{2}\varphi}}$$</p>
  <p>振れ角が小さいと $k$ は $0$ に近づき、$\displaystyle K(0)=\frac{\pi}{2}$ なので、周期は $\displaystyle T_{0}=2\pi\sqrt{\frac{l}{g}}$ に戻ります。</p>
  <p>比は次の級数です。</p>
  <p>$$\frac{T}{T_{0}}=1+\left(\frac{1}{2}\right)^{2}k^{2}+\left(\frac{1\cdot 3}{2\cdot 4}\right)^{2}k^{4}+\cdots$$</p>
  <p>この画面の角は、楕円関数 $\mathrm{sn}$ でその時刻の値を直接出しています。振れ角を大きくすると $K(k)$ が増え、周期が伸びます。</p>
  <p>張力は $\displaystyle mg\left(\cos\theta+\frac{l}{g}\dot{\theta}^{2}\right)$ です。この値が負のときは糸がたるむので、張力の矢印は出しません。</p>
  <p>小さい角の式は「近似」、二つの運動を重ねた画面は「比較」です。</p>
''';

const String kPendulumCompareLatex = r'''
  <div class="common-box">ポイント</div>
  <p>同じ長さ $l$、同じ初期角 $\theta_{0}$ から静かに放した二つの運動を重ねています。橙色は $\displaystyle \ddot{\theta}=-\frac{g}{l}\theta$ の解 $\displaystyle \theta=\theta_{0}\cos\left(\sqrt{\frac{g}{l}}\,t\right)$、青は $\displaystyle \ddot{\theta}=-\frac{g}{l}\sin\theta$ の解です。</p>
  <p>近似の周期は振れ角によりません。</p>
  <p>$$T_{0}=2\pi\sqrt{\frac{l}{g}}$$</p>
  <p>厳密な周期は楕円積分です。</p>
  <p>$$k=\sin\frac{\theta_{0}}{2},\quad T=4\sqrt{\frac{l}{g}}\,K(k)$$</p>
  <p>$$\frac{T}{T_{0}}=\frac{2}{\pi}K(k)$$</p>
  <p>$20^{\circ}$ 程度では周期の伸びは $1\%$ ほどで、二つのおもりはほとんど重なります。$90^{\circ}$ では約 $1.18$ 倍になり、青が遅れます。</p>
  <p>矢印は青のおもりに働く重力と張力です。</p>
  <p>式だけの解説は「近似」と「厳密」に切り替わります。</p>
''';

String pendulumArticleLatex(PendulumArticleMode mode) {
  switch (mode) {
    case PendulumArticleMode.approximate:
      return kPendulumApproximateLatex;
    case PendulumArticleMode.exact:
      return kPendulumExactLatex;
    case PendulumArticleMode.compare:
      return kPendulumCompareLatex;
  }
}

final simplePendulum2D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '単振り子の近似と厳密',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: kPendulumCompareLatex,
  experimentWidgets: [
    PhysicsSimulationView(simulation: _PendulumSimulation(), height: 960),
  ],
);

class _SwingClock {
  _SwingClock() {
    loop = PlaybackLoop(
      onTick: (dt) {
        time += math.min(dt, 0.05);
        frame.value++;
      },
    );
  }

  double time = 0;
  final ValueNotifier<int> frame = ValueNotifier<int>(0);
  late final PlaybackLoop loop;

  ValueNotifier<bool> get running => loop.running;

  void start() {
    if (running.value) return;
    loop.start();
  }

  void pause() => loop.pause();

  void reset() {
    loop.reset();
    time = 0;
    frame.value++;
  }
}

class _PendulumParams {
  const _PendulumParams({required this.length, required this.deg});

  final double length;
  final double deg;

  double get theta0 => deg * math.pi / 180;
  double get period => pendulumExactPeriod(length, theta0);
  double get periodSmall => pendulumSmallAnglePeriod(length);

  factory _PendulumParams.fromMap(Map<String, double> params) {
    return _PendulumParams(
      length: params['l']!.clamp(kPendulumMinL, kPendulumMaxL).toDouble(),
      deg: params['amp']!.clamp(kEllipticMinDeg, kEllipticMaxDeg).toDouble(),
    );
  }
}

class _PendulumSimulation extends PhysicsSimulation {
  _PendulumSimulation()
    : super(
        title: '単振り子の近似と厳密',
        aspectRatio: 1.35,
        enableTime: false,
        showTimeOverlay: false,
      );

  final _clock = _SwingClock();
  final ValueNotifier<String> _explanationHtml = ValueNotifier<String>(
    kPendulumCompareLatex,
  );
  PendulumArticleMode _mode = PendulumArticleMode.compare;
  Map<String, double> _latest = {};

  _PendulumParams get _params {
    if (_latest.isEmpty) return _PendulumParams.fromMap(initialParameters);
    return _PendulumParams.fromMap(_latest);
  }

  void _remember(Map<String, double> params) {
    final next = _PendulumParams.fromMap(params);
    final prev = _latest.isEmpty ? null : _PendulumParams.fromMap(_latest);
    _latest = Map<String, double>.from(params);
    final changed =
        prev != null && (prev.length != next.length || prev.deg != next.deg);
    if (changed) {
      _clock.time = 0;
      _clock.frame.value++;
    }
  }

  void _applyMode(
    PendulumArticleMode mode,
    void Function(Set<String> ids) updateActiveIds,
  ) {
    if (_mode == mode) return;
    _mode = mode;
    final next = pendulumArticleLatex(mode);
    if (_explanationHtml.value != next) _explanationHtml.value = next;
    _clock.time = 0;
    _clock.frame.value++;
    updateActiveIds({mode.name});
  }

  @override
  bool get showZoomButtons => true;

  @override
  ValueListenable<String>? get explanationHtmlListenable => _explanationHtml;

  @override
  String? get situation {
    switch (_mode) {
      case PendulumArticleMode.approximate:
        return '振れ角が小さいときの単振り子。周期は長さと g だけで決まる';
      case PendulumArticleMode.exact:
        return '厳密な周期は楕円積分。振れ角が大きいほど長くなる';
      case PendulumArticleMode.compare:
        return '同じ初期条件。青が厳密、橙が近似';
    }
  }

  @override
  Map<String, double> get initialParameters => {
    'l': kPendulumDefaultL,
    'amp': kEllipticDefaultDeg,
  };

  @override
  Set<String> get initialActiveIds => {PendulumArticleMode.compare.name};

  @override
  void startPlayback() => _clock.start();

  void _pause() => _clock.pause();

  void _reset() => _clock.reset();

  String _caption() {
    switch (_mode) {
      case PendulumArticleMode.approximate:
        return '小さい角の微分方程式の解で動かしています。\nθ = θ₀ cos(√(g/l) t) です。\n振れ角を変えても、周期の数字は変わりません。\n橙の矢印が重力、青の矢印が張力です。';
      case PendulumArticleMode.exact:
        return '楕円積分の周期で動かしています。\n振れ角を大きくすると、周期が伸びます。\n橙の矢印が重力、青の矢印が張力です。';
      case PendulumArticleMode.compare:
        return '青が厳密、橙が小さい角の近似です。\n角を大きくすると青が遅れます。\n矢印は青に働く重力と張力です。';
    }
  }

  String _readout(_PendulumParams p) {
    final exact = p.period.toStringAsFixed(2);
    final approx = p.periodSmall.toStringAsFixed(2);
    switch (_mode) {
      case PendulumArticleMode.approximate:
        return 'T₀ = $approx s（振れ角によらない）';
      case PendulumArticleMode.exact:
        return 'T = $exact s';
      case PendulumArticleMode.compare:
        final ratio = p.periodSmall == 0
            ? double.infinity
            : p.period / p.periodSmall;
        return 'T = $exact s\nT₀ = $approx s    T/T₀ = ${ratio.toStringAsFixed(2)}';
    }
  }

  String _header(_PendulumParams p) {
    final exact = p.period.toStringAsFixed(2);
    final approx = p.periodSmall.toStringAsFixed(2);
    switch (_mode) {
      case PendulumArticleMode.approximate:
        return '近似 T₀ = $approx s';
      case PendulumArticleMode.exact:
        return '厳密 T = $exact s';
      case PendulumArticleMode.compare:
        return '厳密 $exact s    近似 $approx s';
    }
  }

  List<_PendulumBobDraw> _bobs(_PendulumParams p) {
    final exact = pendulumExactAt(p.length, p.theta0, _clock.time);
    final approx = pendulumSmallAngleAt(p.length, p.theta0, _clock.time);
    switch (_mode) {
      case PendulumArticleMode.approximate:
        return [
          _PendulumBobDraw(
            theta: approx.theta,
            omega: approx.omega,
            color: const Color(0xFFEF6C00),
          ),
        ];
      case PendulumArticleMode.exact:
        return [
          _PendulumBobDraw(
            theta: exact.theta,
            omega: exact.omega,
            color: const Color(0xFF1565C0),
          ),
        ];
      case PendulumArticleMode.compare:
        return [
          _PendulumBobDraw(
            theta: approx.theta,
            omega: approx.omega,
            color: const Color(0xFFEF6C00),
            ghost: true,
          ),
          _PendulumBobDraw(
            theta: exact.theta,
            omega: exact.omega,
            color: const Color(0xFF1565C0),
          ),
        ];
    }
  }

  Widget _formula() {
    switch (_mode) {
      case PendulumArticleMode.approximate:
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormulaDisplay(
              r'\displaystyle \theta=\theta_{0}\cos\left(\sqrt{\frac{g}{l}}\,t\right)',
            ),
            SizedBox(height: 2),
            FormulaDisplay(r'\displaystyle T_{0}=2\pi\sqrt{\frac{l}{g}}'),
          ],
        );
      case PendulumArticleMode.exact:
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormulaDisplay(r'\displaystyle k=\sin\frac{\theta_{0}}{2}'),
            SizedBox(height: 2),
            FormulaDisplay(r'\displaystyle T=4\sqrt{\frac{l}{g}}\,K(k)'),
          ],
        );
      case PendulumArticleMode.compare:
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormulaDisplay(r'\displaystyle T_{0}=2\pi\sqrt{\frac{l}{g}}'),
            SizedBox(height: 2),
            FormulaDisplay(r'\displaystyle T=4\sqrt{\frac{l}{g}}\,K(k)'),
          ],
        );
    }
  }

  @override
  Widget? buildFormulaOverlay(Map<String, double> parameters) {
    _remember(parameters);
    return _formula();
  }

  @override
  Widget? buildExtraControls(
    BuildContext context,
    Set<String> activeIds,
    void Function(Set<String> ids) updateActiveIds,
  ) {
    return ValueListenableBuilder<bool>(
      valueListenable: _clock.running,
      builder: (context, isRunning, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _caption(),
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
              onPlayPause: isRunning ? _pause : startPlayback,
              onReset: _reset,
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                _modeButton(
                  '近似',
                  PendulumArticleMode.approximate,
                  updateActiveIds,
                ),
                _modeButton('厳密', PendulumArticleMode.exact, updateActiveIds),
                _modeButton('比較', PendulumArticleMode.compare, updateActiveIds),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _modeButton(
    String label,
    PendulumArticleMode mode,
    void Function(Set<String> ids) updateActiveIds,
  ) {
    final selected = _mode == mode;
    final onPressed = () => _applyMode(mode, updateActiveIds);
    if (selected) return FilledButton(onPressed: onPressed, child: Text(label));
    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }

  @override
  List<Widget> buildControls(
    BuildContext context,
    Map<String, double> parameters,
    void Function(String key, double value) updateParam,
  ) {
    _remember(parameters);
    final p = _params;
    return [
      const Text(
        '糸の長さ l（g = 9.8 m/s²）',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _PendulumSlider(
        label: 'l',
        value: p.length,
        min: kPendulumMinL,
        max: kPendulumMaxL,
        onChanged: (v) => updateParam('l', v),
        semanticLabel: '糸の長さ l',
      ),
      const Text(
        '最初の振れ角 θ₀（度）',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _PendulumSlider(
        label: 'θ₀',
        value: p.deg,
        min: kEllipticMinDeg,
        max: kEllipticMaxDeg,
        onChanged: (v) => updateParam('amp', v),
        semanticLabel: '最初の振れ角',
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          _readout(p),
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
    _remember(parameters);
    return AnimatedBuilder(
      animation: Listenable.merge([_clock.running, _clock.frame]),
      builder: (context, _) {
        final p = _PendulumParams.fromMap(parameters);
        return CustomPaint(
          size: Size.infinite,
          painter: _PendulumPainter(
            time: _clock.time,
            zoom: scale,
            hangs: [
              _PendulumHang(
                length: p.length,
                amplitude: p.theta0,
                header: _header(p),
                bobs: _bobs(p),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PendulumSlider extends StatelessWidget {
  const _PendulumSlider({
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        Expanded(
          child: Semantics(
            label: semanticLabel,
            child: Slider(
              value: value.clamp(min, max).toDouble(),
              min: min,
              max: max,
              onChanged: onChanged,
              semanticFormatterCallback: (v) =>
                  '$semanticLabel ${v.toStringAsFixed(2)}',
            ),
          ),
        ),
        SizedBox(
          width: 48,
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

class _PendulumBobDraw {
  const _PendulumBobDraw({
    required this.theta,
    required this.omega,
    required this.color,
    this.ghost = false,
  });

  final double theta;
  final double omega;
  final Color color;
  final bool ghost;
}

class _PendulumHang {
  const _PendulumHang({
    required this.length,
    required this.amplitude,
    required this.header,
    required this.bobs,
  });

  final double length;
  final double amplitude;
  final String header;
  final List<_PendulumBobDraw> bobs;
}

class _WorldBox {
  const _WorldBox({
    required this.xHalf,
    required this.yMin,
    required this.yMax,
  });

  final double xHalf;
  final double yMin;
  final double yMax;

  double get span => yMax - yMin;
}

class _PendulumPainter extends CustomPainter {
  _PendulumPainter({
    required this.time,
    required this.zoom,
    required this.hangs,
  });

  final double time;
  final double zoom;
  final List<_PendulumHang> hangs;

  static const _bg = Color(0xFFF7FAFC);
  static const _ink = Color(0xFF37474F);
  static const _arc = Color(0xFFB0BEC5);
  static const _guide = Color(0xFF90A4AE);
  static const _bar = Color(0xFF607D8B);
  static const _gravity = Color(0xFFEF6C00);
  static const _tension = Color(0xFF1565C0);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    if (size.width < 8 || size.height < 8 || hangs.isEmpty) return;
    final shared = _sharedBox();
    const gap = 8.0;
    final n = hangs.length;
    final w = (size.width - gap * (n - 1)) / n;
    for (var i = 0; i < n; i++) {
      final rect = Rect.fromLTWH(i * (w + gap), 0, w, size.height);
      _panel(canvas, rect, hangs[i], shared, showTime: i == n - 1);
    }
  }

  _WorldBox _boxFor(_PendulumHang hang) {
    final amp = hang.amplitude.abs();
    final length = hang.length;
    final reach = amp <= math.pi / 2 ? length * math.sin(amp) : length;
    final above = math.max(0.0, -length * math.cos(amp));
    return _WorldBox(
      xHalf: math.max(reach + length * 0.12, length * 0.28),
      yMin: -length * 1.14,
      yMax: above + length * 0.18,
    );
  }

  _WorldBox _sharedBox() {
    var xHalf = 0.0;
    var yMin = 0.0;
    var yMax = 0.0;
    for (final hang in hangs) {
      final box = _boxFor(hang);
      xHalf = math.max(xHalf, box.xHalf);
      yMin = math.min(yMin, box.yMin);
      yMax = math.max(yMax, box.yMax);
    }
    return _WorldBox(xHalf: xHalf, yMin: yMin, yMax: yMax);
  }

  void _panel(
    Canvas canvas,
    Rect panel,
    _PendulumHang hang,
    _WorldBox world, {
    required bool showTime,
  }) {
    canvas.save();
    canvas.clipRect(panel);
    canvas.drawRect(panel, Paint()..color = Colors.white);
    canvas.drawRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFCFD8DC),
    );
    _text(
      canvas,
      Offset(panel.left + 8, panel.top + 6),
      hang.header,
      _ink,
      alignLeft: true,
      maxWidth: math.max(40.0, panel.width - 16),
    );

    final plot = Rect.fromLTRB(
      panel.left + 6,
      panel.top + 26,
      panel.right - 6,
      panel.bottom - 8,
    );
    final availW = math.max(1.0, plot.width - 24);
    final availH = math.max(1.0, plot.height - 64);
    final scale =
        math.min(availW / (2 * world.xHalf), availH / world.span) * zoom;
    final pivot = Offset(plot.center.dx, plot.top + 4 + world.yMax * scale);
    Offset at(double x, double y) =>
        Offset(pivot.dx + x * scale, pivot.dy - y * scale);

    final amp = hang.amplitude.abs();
    if (amp > 0.02) {
      final radius = hang.length * scale;
      canvas.drawArc(
        Rect.fromCircle(center: pivot, radius: radius),
        math.pi / 2 - amp,
        2 * amp,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = _arc,
      );
    }
    _dashed(canvas, pivot, at(0, -hang.length), _guide);

    for (final bob in hang.bobs) {
      _bob(canvas, at, hang.length, bob);
    }
    for (final bob in hang.bobs) {
      if (bob.ghost) continue;
      _forces(canvas, at, hang.length, scale, bob);
    }

    canvas.drawCircle(pivot, 3.5, Paint()..color = _bar);
    final barWidth = math.min(plot.width * 0.62, 180.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(pivot.dx, pivot.dy - 7),
          width: barWidth,
          height: 8,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = _bar,
    );
    if (showTime) {
      _text(
        canvas,
        Offset(plot.right, plot.bottom - 14),
        't = ${time.toStringAsFixed(2)} s',
        const Color(0xFF607D8B),
        alignRight: true,
      );
    }
    canvas.restore();
  }

  void _bob(
    Canvas canvas,
    Offset Function(double x, double y) at,
    double length,
    _PendulumBobDraw bob,
  ) {
    final pos = pendulumBob(length, bob.theta);
    final tip = at(pos.x, pos.y);
    final pivot = at(0, 0);
    if (bob.ghost) {
      _dashed(canvas, pivot, tip, bob.color.withValues(alpha: 0.95));
      canvas.drawCircle(
        tip,
        12,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..color = bob.color,
      );
      return;
    }
    canvas.drawLine(
      pivot,
      tip,
      Paint()
        ..color = const Color(0xFF455A64)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(tip, 14, Paint()..color = bob.color);
    canvas.drawCircle(
      tip,
      14,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white,
    );
  }

  void _forces(
    Canvas canvas,
    Offset Function(double x, double y) at,
    double length,
    double scale,
    _PendulumBobDraw bob,
  ) {
    final pos = pendulumBob(length, bob.theta);
    final center = at(pos.x, pos.y);
    const weightPx = 38.0;
    const bobR = 16.0;
    final ratio = pendulumTensionRatio(
      theta: bob.theta,
      omega: bob.omega,
      length: length,
    );
    final tensionPx = math.min(
      weightPx * math.max(0.0, ratio),
      math.max(0.0, length * scale - bobR - 10),
    );
    _arrow(
      canvas,
      center + const Offset(0, bobR),
      const Offset(0, 1),
      weightPx,
      _gravity,
      '重力',
    );
    if (tensionPx < 12) return;
    final towardPivot = Offset(-math.sin(bob.theta), -math.cos(bob.theta));
    _arrow(
      canvas,
      center + towardPivot * bobR,
      towardPivot,
      tensionPx,
      _tension,
      '張力',
    );
  }

  void _arrow(
    Canvas canvas,
    Offset origin,
    Offset dir,
    double length,
    Color color,
    String label,
  ) {
    if (length < 12 || dir.distance == 0) return;
    final nrm = dir / dir.distance;
    final tip = origin + nrm * length;
    const headLen = 8.0;
    const headHalf = 4.5;
    final shaftEnd = tip - nrm * (headLen * 0.7);
    final normal = Offset(-nrm.dy, nrm.dx);
    canvas.drawLine(
      origin,
      shaftEnd,
      Paint()
        ..color = color
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
    final head = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        (tip - nrm * headLen + normal * headHalf).dx,
        (tip - nrm * headLen + normal * headHalf).dy,
      )
      ..lineTo(
        (tip - nrm * headLen - normal * headHalf).dx,
        (tip - nrm * headLen - normal * headHalf).dy,
      )
      ..close();
    canvas.drawPath(head, Paint()..color = color);
    _text(canvas, tip + normal * 12, label, color);
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Color color) {
    final delta = b - a;
    final len = delta.distance;
    if (len < 1) return;
    final step = delta / len;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    var d = 0.0;
    while (d < len) {
      canvas.drawLine(a + step * d, a + step * math.min(d + 5, len), paint);
      d += 9;
    }
  }

  void _text(
    Canvas canvas,
    Offset o,
    String text,
    Color color, {
    bool alignLeft = false,
    bool alignRight = false,
    double maxWidth = 280,
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
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);
    final dx = alignRight
        ? o.dx - tp.width
        : alignLeft
        ? o.dx
        : o.dx - tp.width / 2;
    tp.paint(canvas, Offset(dx, o.dy));
  }

  @override
  bool shouldRepaint(covariant _PendulumPainter oldDelegate) {
    if (oldDelegate.time != time ||
        oldDelegate.zoom != zoom ||
        oldDelegate.hangs.length != hangs.length) {
      return true;
    }
    for (var i = 0; i < hangs.length; i++) {
      final a = hangs[i];
      final b = oldDelegate.hangs[i];
      if (a.length != b.length ||
          a.amplitude != b.amplitude ||
          a.header != b.header)
        return true;
      if (a.bobs.length != b.bobs.length) return true;
      for (var j = 0; j < a.bobs.length; j++) {
        if (a.bobs[j].theta != b.bobs[j].theta ||
            a.bobs[j].omega != b.bobs[j].omega ||
            a.bobs[j].ghost != b.bobs[j].ghost) {
          return true;
        }
      }
    }
    return false;
  }
}
