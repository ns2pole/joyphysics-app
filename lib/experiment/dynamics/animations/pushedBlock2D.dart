import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/dynamics/animations/pushedBlock/pushed_block_params.dart';
import 'package:joyphysics/experiment/dynamics/animations/pushedBlock/pushed_block_pipeline.dart';
import 'package:joyphysics/experiment/dynamics/animations/pushedBlock/pushed_block_runtime.dart';
import 'package:joyphysics/experiment/dynamics/animations/pushedBlock/pushed_block_statics.dart';
import 'package:joyphysics/experiment/playback_controls.dart';
import 'package:joyphysics/model.dart';

export 'pushedBlock/pushed_block_params.dart';
export 'pushedBlock/pushed_block_statics.dart';
export 'pushedBlock/pushed_block_sliding.dart';
export 'pushedBlock/pushed_block_tipping.dart';
export 'pushedBlock/pushed_block_pipeline.dart';
export 'pushedBlock/pushed_block_runtime.dart';

const String kPushedBlockCaption =
    '粗い床の直方体を一定の水平力 F で押す。\n'
    '押し高で滑り／転倒が分かれる。静止を外すと自動で動き出す。\n'
    '転倒中、手が高さ h を外れると F=0。';

final pushedBlock2D = Video(
  isNew: true,
  isSimulation: true,
  category: 'dynamics',
  iconName: 'dynamics',
  title: '直方体を押す（滑りと転倒）',
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
          title: '直方体を押す（滑りと転倒）',
          formula: const FormulaDisplay(
            r'\displaystyle F\le\mu_s mg,\ F\le mg\frac{w}{2h}\ \text{なら静止}',
          ),
          aspectRatio: (16 / 9) / 1.5,
          enableTime: false,
          showTimeOverlay: false,
        );

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
    _frame.value++;
    if (!alive) _loop.pause();
  });

  ValueNotifier<bool> get running => _loop.running;
  Map<String, double> _latestParams = {};
  static const double _playback = 0.55;

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

  void _rememberParams(Map<String, double> params) {
    final next = Map<String, double>.from(params);
    final changed = _latestParams.isEmpty ||
        _latestParams['w'] != next['w'] ||
        _latestParams['H'] != next['H'] ||
        _latestParams['h'] != next['h'] ||
        _latestParams['F'] != next['F'] ||
        _latestParams['mu'] != next['mu'] ||
        _latestParams['muS'] != next['muS'];
    _latestParams = next;
    if (changed) {
      _runtime.setParams(_params);
      _frame.value++;
      // 静止を外れたら自動再生（「滑っている」表示のまま止まらない）。
      final shouldRun = !pushedBlockHolds(_params);
      Future.microtask(() {
        if (shouldRun) {
          if (_runtime.phase == PushedBlockPhase.onSide) {
            _runtime.reset();
          }
          _loop.start();
        } else {
          _loop.pause();
        }
        _frame.value++;
      });
    }
  }

  void start() {
    if (running.value) return;
    if (pushedBlockHolds(_params)) return;
    if (_runtime.phase == PushedBlockPhase.onSide) {
      _runtime.reset();
    }
    _loop.start();
  }

  void pause() => _loop.pause();

  void resetMotion() {
    _loop.reset();
    _runtime.reset();
    _frame.value++;
  }

  @override
  Widget? buildFormulaOverlay(Map<String, double> parameters) {
    _rememberParams(parameters);
    final st = pushedBlockStatics(_params);
    switch (st.onset) {
      case PushedBlockOnset.holds:
        return const FormulaDisplay(
          r'\displaystyle F\le\mu_s mg,\ F\le mg\frac{w}{2h}\ \text{（静止）}',
        );
      case PushedBlockOnset.slide:
        return const FormulaDisplay(
          r'\displaystyle a=\frac{F-\mu_k mg}{m}\ \text{（滑り）}',
        );
      case PushedBlockOnset.tip:
        return const FormulaDisplay(
          r'\displaystyle I_P\ddot\theta=-mg\bigl(\tfrac{w}{2}\cos\theta-\tfrac{H}{2}\sin\theta\bigr)+Fh',
        );
    }
  }

  @override
  Widget? buildExtraControls(
    BuildContext context,
    Set<String> activeIds,
    void Function(Set<String> ids) updateActiveIds,
  ) {
    return ValueListenableBuilder<bool>(
      valueListenable: running,
      builder: (context, isRunning, _) {
        final holds = pushedBlockHolds(_params);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              kPushedBlockCaption,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Color(0xFF546E7A),
              ),
            ),
            const SizedBox(height: 8),
            if (!holds)
              PlayPauseResetButtons(
                playing: isRunning,
                onPlayPause: isRunning ? pause : start,
                onReset: resetMotion,
              )
            else
              const Text(
                '静止（F を上げる／h を変えると滑るまたは転ぶ）',
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
    _rememberParams(parameters);
    final p = _params;
    return [
      const Text(
        '初期条件（m = 1 kg、g = 9.8 m/s²）',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      _SliderRow(
        label: 'w',
        value: p.width,
        min: kPushedBlockMinW,
        max: kPushedBlockMaxW,
        onChanged: (v) {
          updateParam('w', v);
          resetMotion();
        },
        semanticLabel: '幅 w',
      ),
      _SliderRow(
        label: 'H',
        value: p.height,
        min: kPushedBlockMinH,
        max: kPushedBlockMaxH,
        onChanged: (v) {
          updateParam('H', v);
          if (p.pushHeight > v) updateParam('h', v);
          resetMotion();
        },
        semanticLabel: '高さ H',
      ),
      _SliderRow(
        label: 'h',
        value: p.pushHeight,
        min: kPushedBlockMinPushH,
        max: p.height,
        onChanged: (v) {
          updateParam('h', v);
          resetMotion();
        },
        semanticLabel: '押し高 h',
      ),
      _SliderRow(
        label: 'F',
        value: p.force,
        min: kPushedBlockMinF,
        max: kPushedBlockMaxF,
        onChanged: (v) {
          updateParam('F', v);
          resetMotion();
        },
        semanticLabel: '力 F',
      ),
      _SliderRow(
        label: 'μ',
        value: p.muK,
        min: kPushedBlockMinMu,
        max: kPushedBlockMaxMu,
        onChanged: (v) {
          updateParam('mu', v);
          final need = v + kPushedBlockMuGap;
          if (p.muS < need) updateParam('muS', need);
          resetMotion();
        },
        semanticLabel: '動摩擦係数',
      ),
      _SliderRow(
        label: 'μs',
        value: p.muS,
        min: kPushedBlockMinMuS,
        max: kPushedBlockMaxMuS,
        onChanged: (v) {
          updateParam('muS', v);
          final maxK = v - kPushedBlockMuGap;
          if (p.muK > maxK) updateParam('mu', maxK);
          resetMotion();
        },
        semanticLabel: '静止摩擦係数',
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
        return CustomPaint(
          size: Size.infinite,
          painter: _PushedBlockPainter(
            params: _params,
            sample: _runtime.sample,
            statics: pushedBlockStatics(_params),
          ),
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
  final ValueChanged<double> onChanged;
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

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final map = _mapper(size, 8);
    _drawFloor(canvas, map);
    _drawBlock(canvas, map);
    _drawHand(canvas, map);
    _drawForces(canvas, map);
    _drawForceLegend(canvas, size);
  }

  void _drawForceLegend(Canvas canvas, Size size) {
    final items = <(Color, String)>[
      (_force, 'F 押し力'),
      (_normal, 'N 垂直抗力'),
      (_friction, 'f 摩擦'),
      (_gravity, 'mg 重力'),
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
    _label(canvas, hand + const Offset(-18, -14), '手', _hand);
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

    // 垂直抗力 N：床の作用点から上向き
    final nLen = (22 + params.weight * 2.2).clamp(28.0, 56.0);
    _arrow(canvas, foot, const Offset(0, -1), nLen, _normal, 'N');

    // 摩擦力 f：同じ作用点。静止は F に対抗、滑りは μk N、転倒中は枢軸で水平
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
