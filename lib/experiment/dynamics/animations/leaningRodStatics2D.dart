import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/leaningRod/leaning_rod_params.dart';
import 'package:joyphysics/experiment/dynamics/animations/leaningRod/leaning_rod_pipeline.dart';
import 'package:joyphysics/experiment/dynamics/animations/leaningRod/leaning_rod_runtime.dart';
import 'package:joyphysics/experiment/dynamics/animations/leaningRod/leaning_rod_statics.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';
import 'package:joyphysics/l10n/anim_ui.dart';

export 'leaningRod/leaning_rod_params.dart';
export 'leaningRod/leaning_rod_statics.dart';
export 'leaningRod/leaning_rod_sliding_both.dart';
export 'leaningRod/leaning_rod_after_leave.dart';
export 'leaningRod/leaning_rod_pipeline.dart';
export 'leaningRod/leaning_rod_runtime.dart';

String kLeaningRodCaption =
    animL('壁は滑らか、床は粗い。θ は棒と壁の角。\n静止できなければ自動で滑り始め、Nw=0 で壁から離れ、倒れる。\n倒れるか画面外に出たら止まり、「最初から」で戻る。', 'Wall is smooth, floor is rough. θ is the angle between rod and wall.\nIf it cannot stay at rest it starts sliding automatically, leaves the wall at Nw=0, and falls.\nStops when it falls or leaves the screen; use “Start over” to reset.');

final leaningRodStatics2D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '立て掛けた棒（壁滑らか）',
  titleEn: 'Leaning rod (smooth wall)',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>長さ $L$、質量 $m$ の一様な棒を、壁との角 $\theta$ で立て掛けます。壁は滑らか、床の静止摩擦係数を $\mu_s$、動摩擦係数を $\mu_k$ とします。</p>
  <div class="common-box">静止</div>
  <p>壁の摩擦力は 0 なので</p>
  <p>$$N_f=mg,\qquad f_f=N_w=\frac{1}{2}mg\tan\theta$$</p>
  <p>静止条件は $\displaystyle\mu_s\ge\frac{1}{2}\tan\theta$ です。</p>
  <div class="common-box">両端が接触したまま滑る</div>
  <p>条件が破れると足が外へ滑ります。床には動摩擦力 $f=\mu_k N_f$（壁向き）が働きます。自由度は角度だけです。壁の垂直抗力 $N_w$ が 0 になると壁から離れます。$\mu_k=0$ のときは</p>
  <p>$$\cos\theta=\frac{2}{3}\cos\theta_0$$</p>
  <p>で離れます（$\theta_0$ ははじめの壁との角）。</p>
  <div class="common-box">壁から離れたあと</div>
  <p>足の位置 $x_A$ と角の 2 自由度で倒れます。</p>
""",
  latexEn: r"""
  <div class="common-box">Key points</div>
  <p>Lean a uniform rod of length $L$ and mass $m$ against a wall at angle $\theta$ with the wall. The wall is smooth; the floor has static friction coefficient $\mu_s$ and kinetic friction coefficient $\mu_k$.</p>
  <div class="common-box">At rest</div>
  <p>Friction at the wall is zero, so</p>
  <p>$$N_f=mg,\qquad f_f=N_w=\frac{1}{2}mg\tan\theta$$</p>
  <p>The rest condition is $\displaystyle\mu_s\ge\frac{1}{2}\tan\theta$.</p>
  <div class="common-box">Sliding while both ends stay in contact</div>
  <p>When the condition fails, the foot slides outward. Kinetic friction $f=\mu_k N_f$ (toward the wall) acts at the floor. The only degree of freedom is the angle. When the wall normal $N_w$ reaches 0, the rod leaves the wall. For $\mu_k=0$, detachment occurs at</p>
  <p>$$\cos\theta=\frac{2}{3}\cos\theta_0$$</p>
  <p>($\theta_0$ is the initial angle with the wall).</p>
  <div class="common-box">After leaving the wall</div>
  <p>It falls with two degrees of freedom: foot position $x_A$ and angle.</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: LeaningRodStatics2DSimulation(),
      height: 860,
    ),
  ],
);

class LeaningRodStatics2DSimulation extends PhysicsSimulation {
  LeaningRodStatics2DSimulation()
      : super(
          title: animL('立て掛けた棒（壁滑らか）', 'Leaning rod (smooth wall)'),
          formula: FormulaDisplay(
            animL('\\displaystyle \\mu_s\\ge\\frac{1}{2}\\tan\\theta\\text{ なら静止}', '\\displaystyle \\mu_s\\ge\\frac{1}{2}\\tan\\theta\\text{ then at rest}'),
          ),
          aspectRatio: (16 / 9) / 1.45,
          enableTime: false,
          showTimeOverlay: false,
        );

  @override
  bool get playOnOpen => false;

  final ValueNotifier<int> _frame = ValueNotifier(0);

  late final LeaningRodRuntime _runtime =
      LeaningRodRuntime(LeaningRodParams.fromMap({
    'theta': kLeaningRodDefaultTheta,
    'mu': kLeaningRodDefaultMuK,
    'muS': kLeaningRodDefaultMuS,
  }));

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    final alive = _runtime.step(dt * _playback);
    final ended = !alive ||
        _runtime.phase == LeaningRodPhase.flat ||
        _rodLeftView(_runtime.sample);
    if (ended) {
      if (_runtime.phase != LeaningRodPhase.equilibrium) {
        _awaitingRestart = true;
      }
      _loop.pause();
    }
    _frame.value++;
  });

  ValueNotifier<bool> get running => _loop.running;

  Map<String, double> _latestParams = {};
  /// LOCK_MARKER_v5: 再生開始後は初期条件ロック。リセットで解除。
  bool _icsLocked = false;
  final ValueNotifier<int> _lockTick = ValueNotifier(0);
  void Function(String key, double value)? _updateParam;
  Timer? _demoTimer;
  /// 転倒・画面外で停止。自動では戻さず「最初から」を出す。
  bool _awaitingRestart = false;
  static const double _playback = 0.45;
  static String _lockHint = animL('再生中は変更できません。リセットで戻ります。', 'Cannot change while playing. Reset to revert.');
  static String _restartHint =
      animL('ここで止まりました。「最初から」で初期状態に戻ります。', 'Stopped here. Use “Start over” to restore the initial state.');

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'theta': kLeaningRodDefaultTheta,
        'mu': kLeaningRodDefaultMuK,
        'muS': kLeaningRodDefaultMuS,
      };

  LeaningRodParams get _params {
    if (_latestParams.isEmpty) {
      return LeaningRodParams.fromMap(initialParameters);
    }
    return LeaningRodParams.fromMap(_latestParams);
  }

  void _cancelTimers() {
    _demoTimer?.cancel();
    _demoTimer = null;
  }

  /// 足または上端が固定視野の外に出たか。
  bool _rodLeftView(LeaningRodSample sample) {
    const edge = 0.08;
    final maxX = kLeaningRodViewWidth - 0.3;
    final maxY = kLeaningRodViewHeight - 0.25;
    return sample.xA > maxX + edge ||
        sample.xB > maxX + edge ||
        sample.yB > maxY + edge;
  }

  void _setIcsLocked(bool locked) {
    if (_icsLocked == locked) return;
    _icsLocked = locked;
    _lockTick.value++;
  }

  void _lockAndRun() {
    if (_runtime.phase == LeaningRodPhase.flat) {
      _runtime.reset();
    }
    _demoTimer?.cancel();
    _demoTimer = null;
    _awaitingRestart = false;
    _setIcsLocked(true);
    _loop.start();
    _frame.value++;
  }

  void _rememberParams(Map<String, double> params) {
    final next = Map<String, double>.from(params);
    final changed = _latestParams.isEmpty ||
        _latestParams['theta'] != next['theta'] ||
        _latestParams['mu'] != next['mu'] ||
        _latestParams['muS'] != next['muS'];
    if (!changed) return;
    if (_icsLocked) return;
    _latestParams = next;
    _runtime.setParams(_params);
    _frame.value++;
    if (!leaningRodHolds(_params)) {
      _lockAndRun();
    } else {
      _loop.pause();
    }
  }

  /// 親のパラメータ state を上書きする。常に全キーを書く（差分スキップしない）。
  void _syncParentParams(Map<String, double> next) {
    final updater = _updateParam;
    if (updater == null) return;
    for (final e in next.entries) {
      updater(e.key, e.value);
    }
  }

  void runDemo(LeaningRodDemo demo) {
    _cancelTimers();
    _awaitingRestart = false;
    _loop.pause();
    _setIcsLocked(false);
    final shape = Map<String, double>.from(leaningRodDemoShape(demo));
    _latestParams = shape;
    _runtime.setParams(LeaningRodParams.fromMap(shape));
    _syncParentParams(shape);
    _frame.value++;

    final target = leaningRodDemoThetaDeg(LeaningRodParams.fromMap(shape));
    final start = shape['theta'] ?? kLeaningRodDefaultTheta;
    final step = math.max((target - start) / kLeaningRodDemoRampSteps, 0.15);
    _demoTimer = Timer.periodic(kLeaningRodDemoRampPeriod, (timer) {
      if (_icsLocked) {
        timer.cancel();
        _demoTimer = null;
        return;
      }
      final cur = _latestParams['theta'] ?? start;
      final nextTheta = math.min(cur + step, target);
      _latestParams =
          Map<String, double>.from(_latestParams)..['theta'] = nextTheta;
      _runtime.setParams(_params);
      _updateParam?.call('theta', nextTheta);
      _frame.value++;
      if (!leaningRodHolds(_params)) {
        timer.cancel();
        _demoTimer = null;
        _lockAndRun();
        return;
      }
      if (nextTheta >= target - 1e-9) {
        timer.cancel();
        _demoTimer = null;
      }
    });
  }

  void start() {
    if (running.value) return;
    if (leaningRodHolds(_params)) return;
    _lockAndRun();
  }

  void pause() => _loop.pause();

  /// 姿勢・ロック解除に加え、初期条件もデフォルトの静止パラメータへ戻す。
  void resetMotion() {
    _cancelTimers();
    _awaitingRestart = false;
    _loop.reset();
    // 親へデフォルトを流すあいだはロックし、旧 θ の再適用を防ぐ。
    _icsLocked = true;
    final defaults = Map<String, double>.from(initialParameters);
    _latestParams = defaults;
    _runtime.setParams(LeaningRodParams.fromMap(defaults));
    _syncParentParams(defaults);
    _setIcsLocked(false);
    _frame.value++;
  }

  @override
  Widget? buildFormulaOverlay(Map<String, double> parameters) {
    _rememberParams(parameters);
    final holds = leaningRodHolds(_params);
    return FormulaDisplay(
      holds
          ? animL('\\displaystyle \\mu_s\\ge\\frac{1}{2}\\tan\\theta\\text{（静止）}', '\\displaystyle \\mu_s\\ge\\frac{1}{2}\\tan\\theta\\text{(at rest)}')
          : animL('\\displaystyle N_w=0\\text{ で壁から離れる}', '\\displaystyle N_w=0\\text{ leaves the wall}'),
    );
  }

  @override
  Widget? buildExtraControls(
    BuildContext context,
    Set<String> activeIds,
    void Function(Set<String> ids) updateActiveIds,
  ) {
    return AnimatedBuilder(
      animation: Listenable.merge([running, _lockTick, _frame]),
      builder: (context, _) {
        final holds = leaningRodHolds(_params);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              kLeaningRodCaption,
              textAlign: TextAlign.center,
              style: TextStyle(
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
                OutlinedButton(
                  onPressed: () => runDemo(LeaningRodDemo.slip),
                  child: Text(animL('滑る Auto', 'Slide Auto')),
                ),
              ],
            ),
            if (_icsLocked) ...[
              const SizedBox(height: 6),
              Text(
                _awaitingRestart ? _restartHint : _lockHint,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Color(0xFF546E7A)),
              ),
            ],
            const SizedBox(height: 8),
            if (_awaitingRestart)
              RestartFromStartButton(onPressed: resetMotion)
            else if (!holds || _icsLocked)
              PlayPauseResetButtons(
                playing: running.value,
                onPlayPause: running.value ? pause : start,
                onReset: resetMotion,
              )
            else
              Text(
                animL('静止している（θ を上げるか μs を下げると滑る）', 'At rest (raise θ or lower μs to slide)'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF546E7A)),
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
    return [
      AnimatedBuilder(
        animation: Listenable.merge([running, _lockTick, _frame]),
        builder: (context, _) {
          final p = _params;
          final sample = _runtime.sample;
          final locked = _icsLocked;
          final need = 0.5 * math.tan(p.theta);
          final wallDeg = sample.phase == LeaningRodPhase.equilibrium
              ? p.thetaDeg
              : (math.pi / 2 - sample.theta) * 180 / math.pi;
          final String summary;
          if (leaningRodHolds(p)) {
            summary =
                animL('必要 μs ≥ ${need.toStringAsFixed(2)}    ', 'Need μs ≥ ${need.toStringAsFixed(2)}    ') +
                'Nw=${sample.nw.toStringAsFixed(2)} N';
          } else {
            summary =
                'θ=${wallDeg.toStringAsFixed(1)}°    '
                'Nw=${sample.nw.toStringAsFixed(2)} N';
          }
          return IgnorePointer(
            ignoring: locked,
            child: Opacity(
              opacity: locked ? 0.45 : 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    animL('初期条件（壁滑らか、m = 1 kg、L = 2 m、g = 9.8 m/s²）', 'Initial conditions (smooth wall, m = 1 kg, L = 2 m, g = 9.8 m/s²)'),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  if (locked)
                    Padding(
                      padding: EdgeInsets.only(top: 2, bottom: 4),
                      child: Text(
                        _lockHint,
                        style: TextStyle(fontSize: 11, color: Color(0xFF546E7A)),
                      ),
                    ),
                  _RodSlider(
                    label: 'θ',
                    value: p.thetaDeg,
                    min: kLeaningRodMinTheta,
                    max: kLeaningRodMaxTheta,
                    digits: 0,
                    suffix: '°',
                    onChanged: (v) {
                      if (_icsLocked) return;
                      updateParam('theta', v);
                    },
                    semanticLabel: animL('棒と壁の角 θ', 'Rod–wall angle θ'),
                  ),
                  _RodSlider(
                    label: 'μ',
                    value: p.muK,
                    min: kLeaningRodMinMu,
                    max: kLeaningRodMaxMu,
                    onChanged: (v) {
                      if (_icsLocked) return;
                      updateParam('mu', v);
                      final needS = v + kLeaningRodMuGap;
                      if (p.muS < needS) updateParam('muS', needS);
                    },
                    semanticLabel: animL('床の動摩擦係数 μ', 'Floor kinetic friction μ'),
                  ),
                  _RodSlider(
                    label: 'μs',
                    value: p.muS,
                    min: kLeaningRodMinMuS,
                    max: kLeaningRodMaxMuS,
                    onChanged: (v) {
                      if (_icsLocked) return;
                      updateParam('muS', v);
                      final maxK = v - kLeaningRodMuGap;
                      if (p.muK > maxK) updateParam('mu', maxK);
                    },
                    semanticLabel: animL('床の静止摩擦係数 μs', 'Floor static friction μs'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      summary,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Courier',
                        color: leaningRodHolds(p)
                            ? const Color(0xFF37474F)
                            : const Color(0xFFC62828),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
    return AnimatedBuilder(
      animation: Listenable.merge([running, _frame]),
      builder: (context, _) {
        _rememberParams(parameters);
        final sample = _runtime.sample;
        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: _LeaningRodPainter(params: _params, sample: sample),
            ),
            if (_awaitingRestart)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: RestartFromStartButton(onPressed: resetMotion),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RodSlider extends StatelessWidget {
  const _RodSlider({
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
  final ValueChanged<double>? onChanged;
  final String semanticLabel;
  final int digits;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final shown = '${value.toStringAsFixed(digits)}$suffix';
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
                  '$semanticLabel ${v.toStringAsFixed(digits)}$suffix',
            ),
          ),
        ),
        SizedBox(
          width: 52,
          child: Text(
            shown,
            style: const TextStyle(fontSize: 12, fontFamily: 'Courier'),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _LeaningRodPainter extends CustomPainter {
  _LeaningRodPainter({
    required this.params,
    required this.sample,
  });

  final LeaningRodParams params;
  final LeaningRodSample sample;

  static const _bg = Color(0xFFF7FAFC);
  static const _ink = Color(0xFF37474F);
  static const _rod = Color(0xFFBCAAA4); // 薄い茶色
  static const _floor = Color(0xFF8E989F);
  static const _wall = Color(0xFFB0BEC5);
  static const _normal = Color(0xFF2E7D32); // N 垂直抗力
  static const _friction = Color(0xFF1565C0); // f 摩擦
  static const _gravity = Color(0xFF455A64); // mg
  static const _angle = Color(0xFF6A1B9A); // θ
  static const _warn = Color(0xFFC62828);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    // 文言の有無で壁・棒が動かないよう、帯の高さを常時確保する。
    final statusBottom = _statusReservedBottom(size);
    _drawStatusBanner(canvas, size);
    final hud = _drawHud(canvas, size, top: statusBottom);
    final map = _mapper(size, hud.bottom + 8);
    _drawRoom(canvas, map);
    _drawRod(canvas, map);
    _drawAngle(canvas, map);
    if (sample.phase == LeaningRodPhase.equilibrium ||
        sample.phase == LeaningRodPhase.slidingBoth ||
        sample.phase == LeaningRodPhase.afterLeave) {
      _drawForces(canvas, map);
    }
    _drawForceLegend(canvas, size);
  }

  String? _statusMessage() {
    switch (sample.phase) {
      case LeaningRodPhase.equilibrium:
        return null;
      case LeaningRodPhase.slidingBoth:
        return animL('物体が滑り始めました', 'Object started sliding');
      case LeaningRodPhase.afterLeave:
        return animL('壁から離れました', 'Left the wall');
      case LeaningRodPhase.flat:
        return animL('床に倒れました', 'Fell to the floor');
    }
  }

  static const _statusTextStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: _warn,
  );

  /// 最長メッセージ相当の高さを常に確保する。
  double _statusReservedBottom(Size size) {
    final tp = TextPainter(
      text: TextSpan(
        text: animL('物体が滑り始めました', 'Object started sliding'),
        style: _statusTextStyle,
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.width - 40);
    return 10 + tp.height + 16 + 6;
  }

  void _drawStatusBanner(Canvas canvas, Size size) {
    final msg = _statusMessage();
    if (msg == null) return;
    final tp = TextPainter(
      text: TextSpan(text: msg, style: _statusTextStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.width - 40);
    final width = tp.width + 28;
    final height = tp.height + 16;
    final card = Rect.fromLTWH(
      (size.width - width) / 2,
      10,
      width,
      height,
    );
    final rrect = RRect.fromRectAndRadius(card, const Radius.circular(8));
    canvas.drawRRect(
      rrect,
      Paint()..color = const Color(0xFFFFEBEE).withValues(alpha: 0.96),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = _warn
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    tp.paint(canvas, Offset(card.left + 14, card.top + 8));
  }

  void _drawForceLegend(Canvas canvas, Size size) {
    final items = <(Color, String)>[
      (_normal, animL('N 垂直抗力', 'N normal force')),
      (_friction, animL('f 摩擦', 'f friction')),
      (_gravity, animL('mg 重力', 'mg gravity')),
    ];
    const rightPad = 10.0;
    const topPad = 10.0;
    const lineH = 18.0;
    const dotGap = 10.0;
    final painters = <TextPainter>[];
    var maxW = 0.0;
    for (final item in items) {
      final tp = TextPainter(
        text: TextSpan(
          text: item.$2,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: item.$1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painters.add(tp);
      if (tp.width > maxW) maxW = tp.width;
    }
    final cardW = 8 + 9 + dotGap + maxW + 12;
    final cardH = 8 + items.length * lineH + 4;
    final card = Rect.fromLTWH(
      size.width - rightPad - cardW,
      topPad,
      cardW,
      cardH,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(card, const Radius.circular(8)),
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
    for (var i = 0; i < items.length; i++) {
      final color = items[i].$1;
      final tp = painters[i];
      final y = card.top + 8 + i * lineH;
      final textLeft = card.right - 12 - tp.width;
      canvas.drawCircle(
        Offset(textLeft - dotGap, y + tp.height / 2),
        4.5,
        Paint()..color = color,
      );
      tp.paint(canvas, Offset(textLeft, y));
    }
  }

  Rect _drawHud(Canvas canvas, Size size, {double top = 8}) {
    final wallDeg = (math.pi / 2 - sample.theta) * 180 / math.pi;
    final lines = <String>[
      animL('θ = ${wallDeg.toStringAsFixed(1)}°（壁との角）', 'θ = ${wallDeg.toStringAsFixed(1)}° (angle with wall)'),
      'μ = ${params.muK.toStringAsFixed(2)}  μs = ${params.muS.toStringAsFixed(2)}',
      'Nw = ${sample.nw.toStringAsFixed(2)} N',
    ];
    final tp = TextPainter(
      text: TextSpan(
        text: lines.join('\n'),
        style: TextStyle(
          fontSize: 13,
          height: 1.35,
          fontFamily: 'Courier',
          fontWeight: FontWeight.w600,
          color: sample.phase == LeaningRodPhase.equilibrium ? _ink : _warn,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 40);
    final card = Rect.fromLTWH(8, top, tp.width + 24, tp.height + 16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(card, const Radius.circular(8)),
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
    tp.paint(canvas, Offset(20, top + 8));
    return card;
  }

  _RodMap _mapper(Size size, double top) {
    final pad = Rect.fromLTRB(28, top, size.width - 20, size.height - 18);
    final scale = math.min(
      pad.width / kLeaningRodViewWidth,
      pad.height / kLeaningRodViewHeight,
    );
    final origin = Offset(pad.left + 18, pad.bottom - 10);
    Offset at(double x, double y) => Offset(
          origin.dx + x * scale,
          origin.dy - y * scale,
        );
    return _RodMap(at: at, scale: scale, origin: origin);
  }

  void _drawRoom(Canvas canvas, _RodMap map) {
    final floorEnd = map.at(kLeaningRodViewWidth - 0.3, 0);
    final wallTop = map.at(0, kLeaningRodViewHeight - 0.25);
    final corner = map.at(0, 0);

    final floorColor = Color.lerp(
      const Color(0xFF607D8B),
      const Color(0xFFECEFF1),
      ((params.muK + params.muS) / 2 / kLeaningRodMaxMuS).clamp(0.0, 1.0),
    )!;

    canvas.drawRect(
      Rect.fromLTRB(corner.dx, corner.dy, floorEnd.dx + 8, corner.dy + 14),
      Paint()..color = floorColor,
    );
    canvas.drawRect(
      Rect.fromLTRB(corner.dx - 14, wallTop.dy - 8, corner.dx, corner.dy),
      Paint()..color = _wall,
    );
    canvas.drawLine(
      Offset(corner.dx - 14, corner.dy),
      floorEnd,
      Paint()
        ..color = _floor
        ..strokeWidth = 2.2,
    );
    canvas.drawLine(
      Offset(corner.dx, corner.dy + 14),
      wallTop,
      Paint()
        ..color = _wall
        ..strokeWidth = 2.2,
    );
    _label(canvas, Offset(floorEnd.dx - 28, corner.dy + 22), animL('床', 'Floor'), _ink);
    _label(canvas, Offset(corner.dx - 40, wallTop.dy + 12), animL('壁(滑)', 'Wall (smooth)'), _ink);
  }

  void _drawRod(Canvas canvas, _RodMap map) {
    final a = map.at(sample.xA, 0);
    final b = map.at(sample.xB, sample.yB);
    final dim = sample.phase == LeaningRodPhase.flat;
    final paint = Paint()
      ..color = dim ? _rod.withValues(alpha: 0.45) : _rod
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(a, b, paint);
    canvas.drawCircle(a, 5.5, Paint()..color = _ink);
    canvas.drawCircle(b, 5.5, Paint()..color = _ink);
    _label(canvas, a + const Offset(10, 16), 'A', _ink);
    _label(canvas, b + const Offset(-18, -10), 'B', _ink);
  }

  void _drawAngle(Canvas canvas, _RodMap map) {
    // sample.theta は床との角。表示の θ は壁との角。
    // ラベルは壁・床・棒の三角形のうち、壁と棒に挟まれた側（B 付近）に置く。
    final phi = math.pi / 2 - sample.theta;
    if (phi < 0.05 || sample.yB < 0.08) return;
    final origin = map.at(sample.xB, sample.yB);
    const radius = 34.0;
    // 壁に沿って下向き（三角形の内側）
    canvas.drawLine(
      origin,
      origin + const Offset(0, radius + 6),
      Paint()
        ..color = _ink
        ..strokeWidth = 1.2,
    );
    final rect = Rect.fromCircle(center: origin, radius: radius);
    // Flutter: 下 = π/2。壁下向きから棒へ反時計（負の掃引）で θ。
    canvas.drawArc(
      rect,
      math.pi / 2,
      -phi,
      false,
      Paint()
        ..color = _angle
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    final mid = math.pi / 2 - phi / 2;
    final labelAt =
        origin + Offset(math.cos(mid), math.sin(mid)) * (radius * 0.55);
    _label(canvas, labelAt, 'θ', _angle);
  }

  void _drawForces(Canvas canvas, _RodMap map) {
    final mg = params.weight;
    final scale = 48.0 / mg;
    final a = map.at(sample.xA, 0);
    final b = map.at(sample.xB, sample.yB);
    final cm = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);

    // 重力：重心
    _drawArrow(canvas, cm, const Offset(0, 1), mg * scale, _gravity, 'mg');
    // 床の垂直抗力 Nf：足 A
    if (sample.nf > 1e-6) {
      _drawArrow(canvas, a, const Offset(0, -1), sample.nf * scale, _normal, 'Nf');
    }
    // 床の摩擦 f：足 A。滑り・静止は壁向きが正で左向き。
    // 離脱後の ff は実験室の +x（壁から離れる向き）成分。
    if (sample.ff.abs() > 1e-6) {
      final sliding = sample.phase == LeaningRodPhase.slidingBoth ||
          sample.phase == LeaningRodPhase.afterLeave;
      final towardWall = sample.phase != LeaningRodPhase.afterLeave;
      _drawArrow(
        canvas,
        a,
        Offset((sample.ff >= 0) == towardWall ? -1 : 1, 0),
        sample.ff.abs() * scale,
        _friction,
        sliding ? 'fk' : 'fs',
      );
    }
    // 壁の垂直抗力 Nw：接点 B から右向き（壁→棒）
    if (sample.nw > 1e-6) {
      _drawArrow(canvas, b, const Offset(1, 0), sample.nw * scale, _normal, 'Nw');
    }
  }

  void _drawArrow(
    Canvas canvas,
    Offset from,
    Offset dir,
    double length,
    Color color,
    String label,
  ) {
    final len = length.clamp(12.0, 78.0);
    final n = dir.distance;
    if (n < 1e-9) return;
    final u = dir / n;
    final tip = from + u * len;
    canvas.drawLine(
      from,
      tip,
      Paint()
        ..color = color
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    final side = Offset(-u.dy, u.dx);
    final head = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        tip.dx - u.dx * 9 + side.dx * 4.5,
        tip.dy - u.dy * 9 + side.dy * 4.5,
      )
      ..lineTo(
        tip.dx - u.dx * 9 - side.dx * 4.5,
        tip.dy - u.dy * 9 - side.dy * 4.5,
      )
      ..close();
    canvas.drawPath(head, Paint()..color = color);
    _label(canvas, tip + u * 12 + side * 8, label, color);
  }

  void _label(Canvas canvas, Offset at, String text, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _LeaningRodPainter oldDelegate) {
    return oldDelegate.sample.t != sample.t ||
        oldDelegate.sample.phase != sample.phase ||
        oldDelegate.sample.theta != sample.theta ||
        oldDelegate.sample.xA != sample.xA ||
        oldDelegate.params.muK != params.muK ||
        oldDelegate.params.muS != params.muS ||
        oldDelegate.params.thetaDeg != params.thetaDeg;
  }
}

class _RodMap {
  _RodMap({
    required this.at,
    required this.scale,
    required this.origin,
  });

  final Offset Function(double x, double y) at;
  final double scale;
  final Offset origin;
}
