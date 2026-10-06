import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/pushedBlock/pushed_block_params.dart';
import 'package:joyphysics/experiment/dynamics/animations/pushedBlock/pushed_block_pipeline.dart';
import 'package:joyphysics/experiment/dynamics/animations/pushedBlock/pushed_block_runtime.dart';
import 'package:joyphysics/experiment/dynamics/animations/pushedBlock/pushed_block_statics.dart';
import 'package:joyphysics/experiment/dynamics/animations/pushedBlock/pushed_block_tipping.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';
import 'package:joyphysics/l10n/anim_ui.dart';

export 'pushedBlock/pushed_block_params.dart';
export 'pushedBlock/pushed_block_statics.dart';
export 'pushedBlock/pushed_block_sliding.dart';
export 'pushedBlock/pushed_block_tipping.dart';
export 'pushedBlock/pushed_block_pipeline.dart';
export 'pushedBlock/pushed_block_runtime.dart';

String kPushedBlockCaption =
    animL('粗い床の直方体を一定の水平力 F で押す。\n押し高で滑り／転倒が分かれる。静止を外すと自動で動き出す。\n転倒中、手が高さ h を外れると F=0。画面外・転倒完了では止まり、「最初から」で戻る。', 'Push a rectangular block on a rough floor with a constant horizontal force F.\nPush height decides sliding vs tipping. When equilibrium fails, it starts moving automatically.\nWhile tipping, if the hand leaves height h then F=0. Stops off-screen or when tipping finishes; use Restart to reset.');

final pushedBlock2D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '直方体を押す（滑りと転倒）',
  titleEn: 'Pushing a block (sliding and tipping)',
  videoURL: '',
  equipment: [],
  costRating: '★',
  latex: r"""
  <div class="common-box">ポイント</div>
  <p>幅 $w$、高さ $H$、質量 $m$ の直方体を粗い床に置き、床から高さ $h$ で一定の水平力 $F$ をかけます。床の静止摩擦係数を $\mu_s$、動摩擦係数を $\mu_k$ とします。</p>
  <div class="common-box">静止</div>
  <p>滑らない条件は $F\le\mu_s mg$ です。転ばない条件は右下端まわりで</p>
  <p>$$\displaystyle F\le mg\cdot\frac{w}{2h}$$</p>
  <p>両方満たせば静止します。$F$ を静かに上げると、$\displaystyle h>\frac{w}{2\mu_s}$ なら転倒が先、$h$ が小さければ滑りが先です。</p>
  <div class="common-box">滑り</div>
  <p>滑り出したあと、加速度は $\displaystyle a=\frac{F-\mu_k mg}{m}$ です。</p>
  <div class="common-box">転倒</div>
  <p>右下端を軸に傾きます。手の高さは $h$ 固定で、左面が $y=h$ を外れると手が離れ $F=0$ になります（目安 $\displaystyle\theta=\arcsin\frac{h}{w}$）。そのあと側面まで倒れます。</p>
  <p>右下端が止まっているあいだ、床の水平力と垂直抗力は重心の加速度から決まります。手が当たっているときは</p>
  <p>$$\displaystyle I_P\ddot\theta=-mg\Bigl(\frac{w}{2}\cos\theta-\frac{H}{2}\sin\theta\Bigr)+Fh$$</p>
  <p>手が離れたあとは $Fh$ の項が消えます。</p>
""",
  latexEn: r"""
  <div class="common-box">Key points</div>
  <p>Place a rectangular block of width $w$, height $H$, and mass $m$ on a rough floor, and apply a constant horizontal force $F$ at height $h$ above the floor. The floor has static friction coefficient $\mu_s$ and kinetic friction coefficient $\mu_k$.</p>
  <div class="common-box">At rest</div>
  <p>No sliding requires $F\le\mu_s mg$. No tipping, about the lower-right edge, requires</p>
  <p>$$\displaystyle F\le mg\cdot\frac{w}{2h}$$</p>
  <p>If both hold, it stays at rest. Raising $F$ slowly, tipping comes first if $\displaystyle h>\frac{w}{2\mu_s}$; if $h$ is smaller, sliding comes first.</p>
  <div class="common-box">Sliding</div>
  <p>After sliding starts, the acceleration is $\displaystyle a=\frac{F-\mu_k mg}{m}$.</p>
  <div class="common-box">Tipping</div>
  <p>It rotates about the lower-right edge. Hand height stays fixed at $h$; when the left face clears $y=h$, the hand loses contact and $F=0$ (roughly $\displaystyle\theta=\arcsin\frac{h}{w}$). Then it falls onto its side.</p>
  <p>While the lower-right edge stays put, the floor’s horizontal force and normal force follow from the CM acceleration. While the hand is in contact,</p>
  <p>$$\displaystyle I_P\ddot\theta=-mg\Bigl(\frac{w}{2}\cos\theta-\frac{H}{2}\sin\theta\Bigr)+Fh$$</p>
  <p>After the hand leaves, the $Fh$ term vanishes.</p>
""",
  experimentWidgets: [
    PhysicsSimulationView(
      simulation: PushedBlock2DSimulation(),
      height: 900,
    ),
  ],
);

class PushedBlock2DSimulation extends PhysicsSimulation {
  PushedBlock2DSimulation()
      : super(
          title: animL('直方体を押す（滑りと転倒）', 'Pushing a block (sliding and tipping)'),
          formula: FormulaDisplay(
            animL('\\displaystyle F\\le\\mu_s mg,\\ F\\le mg\\frac{w}{2h}\\ \\text{なら静止}', '\\displaystyle F\\le\\mu_s mg,\\ F\\le mg\\frac{w}{2h}\\ \\text{ for equilibrium}'),
          ),
          aspectRatio: (16 / 9) / 1.5,
          enableTime: false,
          showTimeOverlay: false,
        );

  @override
  bool get playOnOpen => false;

  final ValueNotifier<int> _frame = ValueNotifier(0);

  late final PushedBlockRuntime _runtime = PushedBlockRuntime(
    PushedBlockParams.fromMap({
      'w': kPushedBlockDefaultW,
      'H': kPushedBlockDefaultH,
      'h': PushedBlockParams.defaultPushHeight(kPushedBlockDefaultH),
      'F': kPushedBlockDefaultF,
      'mu': kPushedBlockDefaultMuK,
      'muS': kPushedBlockDefaultMuS,
    }),
  );

  late final PlaybackLoop _loop = PlaybackLoop(onTick: (dt) {
    final alive = _runtime.step(dt * _playback);
    if (!alive || _runtime.isFinished) {
      if (_runtime.isFinished) {
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
  /// 転倒完了・画面外で停止。自動では戻さず「最初から」を出す。
  bool _awaitingRestart = false;
  static const double _playback = 0.55;
  static String _lockHint = animL('再生中は変更できません。リセットで戻ります。', 'Cannot change while playing. Reset to revert.');
  static String _restartHint =
      animL('ここで止まりました。「最初から」で初期状態に戻ります。', 'Stopped here. Use “Start over” to restore the initial state.');

  @override
  Set<String> get initialActiveIds => {};

  @override
  Map<String, double> get initialParameters => {
        'w': kPushedBlockDefaultW,
        'H': kPushedBlockDefaultH,
        'h': PushedBlockParams.defaultPushHeight(kPushedBlockDefaultH),
        'F': kPushedBlockDefaultF,
        'mu': kPushedBlockDefaultMuK,
        'muS': kPushedBlockDefaultMuS,
      };

  PushedBlockParams get _params {
    if (_latestParams.isEmpty) {
      return PushedBlockParams.fromMap(initialParameters);
    }
    return PushedBlockParams.fromMap(_latestParams);
  }

  void _cancelTimers() {
    _demoTimer?.cancel();
    _demoTimer = null;
  }

  void _setIcsLocked(bool locked) {
    if (_icsLocked == locked) return;
    _icsLocked = locked;
    _lockTick.value++;
  }

  void _lockAndRun() {
    if (_runtime.phase == PushedBlockPhase.onSide) {
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
        _latestParams['w'] != next['w'] ||
        _latestParams['H'] != next['H'] ||
        _latestParams['h'] != next['h'] ||
        _latestParams['F'] != next['F'] ||
        _latestParams['mu'] != next['mu'] ||
        _latestParams['muS'] != next['muS'];
    if (!changed) return;
    if (_icsLocked) return;
    _latestParams = next;
    _runtime.setParams(_params);
    _frame.value++;
    if (!pushedBlockHolds(_params)) {
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

  void runDemo(PushedBlockDemo demo) {
    _cancelTimers();
    _awaitingRestart = false;
    _loop.pause();
    _setIcsLocked(false);
    final shape = Map<String, double>.from(pushedBlockDemoShape(demo));
    _latestParams = shape;
    _runtime.setParams(PushedBlockParams.fromMap(shape));
    _syncParentParams(shape);
    _frame.value++;

    final target = pushedBlockDemoForce(PushedBlockParams.fromMap(shape));
    final step = math.max(target / kPushedBlockDemoRampSteps, 0.05);
    _demoTimer = Timer.periodic(kPushedBlockDemoRampPeriod, (timer) {
      if (_icsLocked) {
        timer.cancel();
        _demoTimer = null;
        return;
      }
      final cur = _latestParams['F'] ?? 0.0;
      final nextF = math.min(cur + step, target);
      _latestParams = Map<String, double>.from(_latestParams)..['F'] = nextF;
      _runtime.setParams(_params);
      _updateParam?.call('F', nextF);
      _frame.value++;
      if (!pushedBlockHolds(_params)) {
        timer.cancel();
        _demoTimer = null;
        _lockAndRun();
        return;
      }
      if (nextF >= target - 1e-9) {
        timer.cancel();
        _demoTimer = null;
      }
    });
  }

  void start() {
    if (running.value) return;
    if (pushedBlockHolds(_params)) return;
    _lockAndRun();
  }

  void pause() => _loop.pause();

  /// 姿勢・ロック解除に加え、初期条件もデフォルトの静止パラメータへ戻す。
  void resetMotion() {
    _cancelTimers();
    _awaitingRestart = false;
    _loop.reset();
    // 親へデフォルトを流すあいだはロックし、旧 F の再適用を防ぐ。
    _icsLocked = true;
    final defaults = Map<String, double>.from(initialParameters);
    _latestParams = defaults;
    _runtime.setParams(PushedBlockParams.fromMap(defaults));
    // 必ず親 state を書き換える（差分スキップだと旧 F が残る）。
    _syncParentParams(defaults);
    _setIcsLocked(false);
    _frame.value++;
  }

  @override
  Widget? buildFormulaOverlay(Map<String, double> parameters) {
    _rememberParams(parameters);
    final st = pushedBlockStatics(_params);
    switch (st.onset) {
      case PushedBlockOnset.holds:
        return FormulaDisplay(
          animL('\\displaystyle F\\le\\mu_s mg,\\ F\\le mg\\frac{w}{2h}\\ \\text{（静止）}', '\\displaystyle F\\le\\mu_s mg,\\ F\\le mg\\frac{w}{2h}\\ \\text{ (equilibrium)}'),
        );
      case PushedBlockOnset.slide:
        return FormulaDisplay(
          animL('\\displaystyle a=\\frac{F-\\mu_k mg}{m}\\ \\text{（滑り）}', '\\displaystyle a=\\frac{F-\\mu_k mg}{m}\\ \\text{ (sliding)}'),
        );
      case PushedBlockOnset.tip:
        final phase = _runtime.phase;
        if (phase == PushedBlockPhase.freeTip ||
            phase == PushedBlockPhase.onSide) {
          return const FormulaDisplay(
            r'\displaystyle I_P\ddot\theta=-mg\bigl(\frac{w}{2}\cos\theta-\frac{H}{2}\sin\theta\bigr)',
          );
        }
        return const FormulaDisplay(
          r'\displaystyle I_P\ddot\theta=-mg\bigl(\frac{w}{2}\cos\theta-\frac{H}{2}\sin\theta\bigr)+Fh',
        );
    }
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
        final holds = pushedBlockHolds(_params);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              kPushedBlockCaption,
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
                  onPressed: () => runDemo(PushedBlockDemo.slide),
                  child: Text(animL('滑る Auto', 'Slide Auto')),
                ),
                OutlinedButton(
                  onPressed: () => runDemo(PushedBlockDemo.tip),
                  child: Text(animL('転倒 Auto', 'Tipping Auto')),
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
                animL('静止（F を上げる／h を変えると滑るまたは転ぶ）', 'Equilibrium (raise F / change h to slide or tip)'),
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
          final st = pushedBlockStatics(p);
          final locked = _icsLocked;
          final summary =
              'Fslide=${st.fSlide.toStringAsFixed(2)} N    '
              'Ftip=${st.fTip.toStringAsFixed(2)} N    '
              'F=${p.force.toStringAsFixed(2)} N';
          return IgnorePointer(
            ignoring: locked,
            child: Opacity(
              opacity: locked ? 0.45 : 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    animL('初期条件（m = 1 kg、g = 9.8 m/s²）', 'Initial conditions (m = 1 kg, g = 9.8 m/s²)'),
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
                  _SliderRow(
                    label: 'w',
                    value: p.width,
                    min: kPushedBlockMinW,
                    max: kPushedBlockMaxW,
                    onChanged: (v) {
                      if (_icsLocked) return;
                      updateParam('w', v);
                    },
                    semanticLabel: animL('幅 w', 'Width w'),
                  ),
                  _SliderRow(
                    label: 'H',
                    value: p.height,
                    min: kPushedBlockMinH,
                    max: kPushedBlockMaxH,
                    onChanged: (v) {
                      if (_icsLocked) return;
                      updateParam('H', v);
                      if (p.pushHeight > v) updateParam('h', v);
                    },
                    semanticLabel: animL('高さ H', 'Height H'),
                  ),
                  _SliderRow(
                    label: 'h',
                    value: p.pushHeight,
                    min: kPushedBlockMinPushH,
                    max: p.height,
                    onChanged: (v) {
                      if (_icsLocked) return;
                      updateParam('h', v);
                    },
                    semanticLabel: animL('押し高 h', 'Push height h'),
                  ),
                  _SliderRow(
                    label: 'F',
                    value: p.force,
                    min: kPushedBlockMinF,
                    max: kPushedBlockMaxF,
                    onChanged: (v) {
                      if (_icsLocked) return;
                      updateParam('F', v);
                    },
                    semanticLabel: animL('力 F', 'Force F'),
                  ),
                  _SliderRow(
                    label: 'μ',
                    value: p.muK,
                    min: kPushedBlockMinMu,
                    max: kPushedBlockMaxMu,
                    onChanged: (v) {
                      if (_icsLocked) return;
                      updateParam('mu', v);
                      final need = v + kPushedBlockMuGap;
                      if (p.muS < need) updateParam('muS', need);
                    },
                    semanticLabel: animL('動摩擦係数', 'Kinetic friction coefficient'),
                  ),
                  _SliderRow(
                    label: 'μs',
                    value: p.muS,
                    min: kPushedBlockMinMuS,
                    max: kPushedBlockMaxMuS,
                    onChanged: (v) {
                      if (_icsLocked) return;
                      updateParam('muS', v);
                      final maxK = v - kPushedBlockMuGap;
                      if (p.muK > maxK) updateParam('mu', maxK);
                    },
                    semanticLabel: animL('静止摩擦係数', 'Static friction coefficient'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      summary,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Courier',
                        color: st.holds
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
        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: _PushedBlockPainter(
                params: _params,
                sample: _runtime.sample,
                statics: pushedBlockStatics(_params),
              ),
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

class _SliderRow extends StatelessWidget {
  const _SliderRow({
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
  final ValueChanged<double>? onChanged;
  final String semanticLabel;

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

class _PushedBlockPainter extends CustomPainter {
  _PushedBlockPainter({
    required this.params,
    required this.sample,
    required this.statics,
  });

  final PushedBlockParams params;
  final PushedBlockSample sample;
  final PushedBlockStatics statics;

  static const _bg = Color(0xFFF7FAFC);
  static const _ink = Color(0xFF37474F);
  static const _block = Color(0xFFBCAAA4); // 薄い茶色
  static const _floor = Color(0xFF90A4AE);
  static const _force = Color(0xFFE65100); // F 押し力
  static const _gravity = Color(0xFF455A64); // mg
  static const _normal = Color(0xFF2E7D32); // N 垂直抗力
  static const _friction = Color(0xFF1565C0); // f 摩擦
  static const _hand = Color(0xFFD81B60);
  static const _warn = Color(0xFFC62828);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    // 文言の有無で壁・物体が動かないよう、帯の高さを常時確保する。
    final top = _statusReservedBottom(size);
    _drawStatusBanner(canvas, size);
    final map = _mapper(size, top);
    _drawFloor(canvas, map);
    _drawBlock(canvas, map);
    _drawHand(canvas, map);
    _drawForces(canvas, map);
    _drawForceLegend(canvas, size);
  }

  String? _statusMessage() {
    switch (sample.phase) {
      case PushedBlockPhase.equilibrium:
        return null;
      case PushedBlockPhase.sliding:
        return animL('物体が滑り始めました', 'Object started sliding');
      case PushedBlockPhase.tipping:
        return animL('物体が転倒し始めました', 'The block started tipping');
      case PushedBlockPhase.freeTip:
        return animL('手が離れました', 'The hand left');
      case PushedBlockPhase.onSide:
        return animL('側面に着地しました', 'Landed on its side');
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
        text: animL('物体が転倒し始めました', 'The block started tipping'),
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
      (_force, animL('F 押し力', 'F push force')),
      (_normal, animL('N 垂直抗力', 'N normal force')),
      (_friction, animL('f 摩擦', 'f friction')),
      (_gravity, animL('mg 重力', 'mg gravity')),
    ];
    const rightPad = 12.0;
    const top = 16.0;
    const lineH = 18.0;
    for (var i = 0; i < items.length; i++) {
      final (color, text) = items[i];
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final y = top + i * lineH;
      final textLeft = size.width - rightPad - tp.width;
      canvas.drawCircle(Offset(textLeft - 10, y + tp.height / 2), 4.5, Paint()..color = color);
      tp.paint(canvas, Offset(textLeft, y));
    }
  }

  _Map _mapper(Size size, double top) {
    final pad = Rect.fromLTRB(24, top, size.width - 16, size.height - 16);
    // スケールは視野定数のみ。直方体の寸法や滑りで変えない。
    final scale = math.min(
      pad.width / kPushedBlockViewWidth,
      pad.height / kPushedBlockViewHeight,
    );
    final origin = Offset(pad.left + 40, pad.bottom - 12);
    Offset at(double x, double y) =>
        Offset(origin.dx + x * scale, origin.dy - y * scale);
    return _Map(at: at, scale: scale);
  }

  void _drawFloor(Canvas canvas, _Map map) {
    final a = map.at(-0.3, 0);
    final b = map.at(kPushedBlockViewWidth - 0.5, 0);
    canvas.drawLine(
      a,
      b,
      Paint()
        ..color = _floor
        ..strokeWidth = 3,
    );
  }

  List<Offset> _blockCorners() {
    final w = params.width;
    final H = params.height;
    if (sample.phase == PushedBlockPhase.sliding ||
        sample.phase == PushedBlockPhase.equilibrium) {
      final x0 = sample.x;
      return [
        Offset(x0, 0),
        Offset(x0 + w, 0),
        Offset(x0 + w, H),
        Offset(x0, H),
      ];
    }
    // pivot at (sample.x, 0) = initial right bottom
    final p = Offset(sample.x, 0);
    final th = sample.theta;
    final c = math.cos(th);
    final s = math.sin(th);
    Offset rot(double rx, double ry) => Offset(
          p.dx + rx * c + ry * s,
          p.dy - rx * s + ry * c,
        );
    // corners relative to pivot before rotation: LB=(-w,0), RB=(0,0), RT=(0,H), LT=(-w,H)
    return [
      rot(-w, 0),
      rot(0, 0),
      rot(0, H),
      rot(-w, H),
    ];
  }

  void _drawBlock(Canvas canvas, _Map map) {
    final corners = _blockCorners().map((p) => map.at(p.dx, p.dy)).toList();
    final path = Path()..moveTo(corners[0].dx, corners[0].dy);
    for (var i = 1; i < corners.length; i++) {
      path.lineTo(corners[i].dx, corners[i].dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = _block.withValues(alpha: 0.85));
    canvas.drawPath(
      path,
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawHand(Canvas canvas, _Map map) {
    final hand = map.at(sample.handX, sample.handY);
    canvas.drawCircle(hand, 8, Paint()..color = _hand);
    canvas.drawCircle(
      hand,
      8,
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    _label(canvas, hand + Offset(-18, -14), animL('手', 'Hand'), _hand);
  }

  void _drawForces(Canvas canvas, _Map map) {
    final corners = _blockCorners();
    final cm = Offset(
      (corners[0].dx + corners[1].dx + corners[2].dx + corners[3].dx) / 4,
      (corners[0].dy + corners[1].dy + corners[2].dy + corners[3].dy) / 4,
    );
    final cmS = map.at(cm.dx, cm.dy);
    final gLen = (22 + params.weight * 2.2).clamp(28.0, 56.0);
    // 重力：重心
    _arrow(canvas, cmS, const Offset(0, 1), gLen, _gravity, 'mg');

    // 押し力 F：左面・高さ h の作用点（手）から右向き
    if (sample.forceApplied > 1e-6) {
      final hand = map.at(sample.handX, sample.handY);
      final fLen = (18 + sample.forceApplied * 3).clamp(16.0, 70.0);
      _arrow(canvas, hand, const Offset(1, 0), fLen, _force, 'F');
    }

    final contact = _floorContactPoint();
    if (contact == null) return;
    final foot = map.at(contact.dx, contact.dy);

    if (sample.phase == PushedBlockPhase.tipping ||
        sample.phase == PushedBlockPhase.freeTip) {
      final rx = pushedBlockPivotReactions(
        params,
        sample.theta,
        sample.omega,
        fingerContact: sample.fingerContact,
      );
      if (rx.normal > 1e-4) {
        final nLen = (gLen * rx.normal / params.weight).clamp(8.0, 90.0);
        _arrow(canvas, foot, const Offset(0, -1), nLen, _normal, 'N');
      }
      if (rx.fx.abs() > 1e-4) {
        final fLen = (rx.fx.abs() * 3).clamp(12.0, 70.0);
        _arrow(
          canvas,
          foot,
          Offset(rx.fx >= 0 ? 1 : -1, 0),
          fLen,
          _friction,
          'fs',
        );
      }
      return;
    }

    // 垂直抗力 N：床の作用点から上向き
    final nLen = (22 + params.weight * 2.2).clamp(28.0, 56.0);
    _arrow(canvas, foot, const Offset(0, -1), nLen, _normal, 'N');

    // 摩擦力 f：同じ作用点。静止は F に対抗、滑りは μk mg
    final friction = _frictionMagnitude();
    if (friction > 1e-6) {
      final fLen = (14 + friction * 3).clamp(12.0, 56.0);
      final label = sample.phase == PushedBlockPhase.sliding ? 'fk' : 'fs';
      _arrow(canvas, foot, const Offset(-1, 0), fLen, _friction, label);
    }
  }

  /// 床との接触作用点（物理座標）。滑り・静止は底面上、転倒は枢軸。
  ///
  /// 滑り中も中央ではない。重心まわりで $F$・$f_k$・$N$ のモーメントが釣り合う位置
  /// $\displaystyle x=\frac{F(h-H/2)+\mu_k mg\cdot H/2}{mg}$（底面中央から右正）。
  Offset? _floorContactPoint() {
    final w = params.width;
    if (sample.phase == PushedBlockPhase.equilibrium) {
      return Offset(
        sample.x + w / 2 + statics.normalXFromCenter,
        0,
      );
    }
    if (sample.phase == PushedBlockPhase.sliding) {
      final xN = pushedBlockNormalXFromCenter(params, kinetic: true);
      return Offset(sample.x + w / 2 + xN, 0);
    }
    if (sample.phase == PushedBlockPhase.tipping ||
        sample.phase == PushedBlockPhase.freeTip) {
      // 右下端（枢軸）
      return Offset(sample.x, 0);
    }
    return null;
  }

  double _frictionMagnitude() {
    switch (sample.phase) {
      case PushedBlockPhase.equilibrium:
        return params.force.clamp(0.0, params.muS * params.weight);
      case PushedBlockPhase.sliding:
        return params.muK * params.weight;
      case PushedBlockPhase.tipping:
        // 枢軸まわり。水平の静止摩擦は押し力に対抗（指が当たっているあいだ）。
        return sample.forceApplied.clamp(0.0, params.muS * params.weight);
      case PushedBlockPhase.freeTip:
      case PushedBlockPhase.onSide:
        return 0;
    }
  }

  void _arrow(
    Canvas canvas,
    Offset from,
    Offset dir,
    double length,
    Color color,
    String label,
  ) {
    final n = dir.distance;
    if (n < 1e-9) return;
    final u = dir / n;
    final tip = from + u * length;
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
      ..lineTo(tip.dx - u.dx * 8 + side.dx * 4, tip.dy - u.dy * 8 + side.dy * 4)
      ..lineTo(tip.dx - u.dx * 8 - side.dx * 4, tip.dy - u.dy * 8 - side.dy * 4)
      ..close();
    canvas.drawPath(head, Paint()..color = color);
    _label(canvas, tip + u * 10 + side * 8, label, color);
  }

  void _label(Canvas canvas, Offset at, String text, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _PushedBlockPainter oldDelegate) {
    return oldDelegate.sample.t != sample.t ||
        oldDelegate.sample.phase != sample.phase ||
        oldDelegate.sample.theta != sample.theta ||
        oldDelegate.sample.x != sample.x ||
        oldDelegate.sample.handX != sample.handX ||
        oldDelegate.sample.forceApplied != sample.forceApplied ||
        oldDelegate.params.width != params.width ||
        oldDelegate.params.height != params.height ||
        oldDelegate.params.force != params.force ||
        oldDelegate.params.pushHeight != params.pushHeight ||
        oldDelegate.params.muK != params.muK ||
        oldDelegate.params.muS != params.muS;
  }
}

class _Map {
  _Map({required this.at, required this.scale});
  final Offset Function(double x, double y) at;
  final double scale;
}
