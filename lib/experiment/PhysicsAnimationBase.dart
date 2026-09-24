import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/model.dart';
import 'package:joyphysics/experiment/HasHeight.dart';
import 'PhysicsAnimationScaffold.dart';
import 'waves/animations/fields/wave_fields.dart';
import 'waves/animations/widgets/wave_slider.dart';

/// 数式表示用の共通スタイル
const TextStyle commonFormulaStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w900,
);

/// 数式を表示するための共通ウィジェット。
/// TeX 解析は初回フレームをブロックするので、1フレーム遅らせてアニメを先に出す。
class FormulaDisplay extends StatefulWidget {
  final String tex;
  final TextStyle? style;

  const FormulaDisplay(this.tex, {super.key, this.style});

  @override
  State<FormulaDisplay> createState() => _FormulaDisplayState();
}

class _FormulaDisplayState extends State<FormulaDisplay> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SizedBox(height: 28);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Math.tex(
        widget.tex,
        textStyle: commonFormulaStyle.merge(widget.style),
      ),
    );
  }
}

/// 物理シミュレーションの設定データを保持する抽象クラス
abstract class PhysicsSimulation {
  final String title;
  final String? latex;
  final Widget? formula;
  final bool is3D;
  final double aspectRatio;
  final bool showTimeOverlay;
  final bool enableTime;

  PhysicsSimulation({
    required this.title,
    this.latex,
    this.formula,
    this.is3D = false,
    this.aspectRatio = 1.0,
    this.showTimeOverlay = true,
    this.enableTime = true,
  });

  /// 数式とアニメのあいだに置く、慣性系から見た状況。
  String? get situation => null;

  /// キャンバス幅に応じた縦横比。未使用のシミュレーションは [aspectRatio] のまま。
  double aspectRatioForWidth(double width) => aspectRatio;

  /// 初期パラメータ
  Map<String, double> get initialParameters;

  /// 初期アクティブID
  Set<String> get initialActiveIds => {'total'};

  /// スライダーなどのコントロールを構築
  List<Widget> buildControls(
    BuildContext context,
    Map<String, double> parameters,
    void Function(String key, double value) updateParam,
  );

  /// 追加のコントロール（Chipなど）を構築
  Widget? buildExtraControls(
    BuildContext context,
    Set<String> activeIds,
    void Function(Set<String> ids) updateActiveIds,
  ) =>
      null;

  /// パラメータに依存する数式オーバーレイ（ボタンより上に表示する場合に使用）
  Widget? buildFormulaOverlay(Map<String, double> parameters) => null;

  /// ボタンとアニメーションの間を詰めるか（通常8px→約3px）
  bool useCompactButtonSpacing(Map<String, double> parameters) => false;

  /// アニメーション領域の縦方向オフセット（正で下、負で上）[px]
  double animationOffsetY(Map<String, double> parameters) => 0;

  /// キャンバス右下の拡大縮小ボタンを表示するか
  bool get showZoomButtons => false;

  /// 「真上から波面を見る」トグルを出すか（2D曲面波動向け）
  bool get enableWavefrontTopView => false;

  /// 真上視点で出す波面レイヤー。干渉では波ごとに複数。
  List<WavefrontLayer> get wavefrontLayers => const [
        WavefrontLayer(id: 'total', label: '波面', color: Colors.blueAccent),
      ];

  /// チップ類 + 波面ビュー操作をまとめたコントロール
  Widget? composeExtraControls(
    BuildContext context,
    Set<String> activeIds,
    void Function(Set<String> ids) updateActiveIds,
  ) {
    final base = buildExtraControls(context, activeIds, updateActiveIds);
    if (!enableWavefrontTopView) return base;
    final panel = buildWavefrontViewPanel(activeIds, updateActiveIds);
    if (base == null) return panel;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        base,
        const SizedBox(height: 8),
        panel,
      ],
    );
  }

  Widget buildWavefrontViewPanel(
    Set<String> activeIds,
    void Function(Set<String> ids) updateActiveIds,
  ) {
    final layers = wavefrontLayers;
    final topOn = activeIds.contains('showWavefrontTopView');

    void setTopView(bool on) {
      final next = Set<String>.from(activeIds);
      if (on) {
        next.add('showWavefrontTopView');
        for (final layer in layers) {
          next.add(layer.toggleId);
        }
      } else {
        next.remove('showWavefrontTopView');
        for (final layer in layers) {
          next.remove(layer.toggleId);
        }
      }
      updateActiveIds(next);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD5DEEA)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            children: [
              FilterChip(
                avatar: Icon(
                  Icons.vertical_align_top,
                  size: 16,
                  color: topOn ? const Color(0xFF1565C0) : Colors.black54,
                ),
                label: const Text('真上から見る', style: TextStyle(fontSize: 12)),
                selected: topOn,
                onSelected: setTopView,
                selectedColor: const Color(0xFFBBDEFB),
                checkmarkColor: const Color(0xFF1565C0),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              if (topOn) const _WavefrontLegend(),
            ],
          ),
          if (topOn && layers.length > 1) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              children: [
                const Text(
                  '波面',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF546E7A),
                  ),
                ),
                for (final layer in layers)
                  FilterChip(
                    avatar: CircleAvatar(
                      backgroundColor: layer.lineColor,
                      radius: 7,
                    ),
                    label: Text(layer.label, style: const TextStyle(fontSize: 11)),
                    selected: activeIds.contains(layer.toggleId),
                    onSelected: (val) {
                      final next = Set<String>.from(activeIds);
                      val
                          ? next.add(layer.toggleId)
                          : next.remove(layer.toggleId);
                      updateActiveIds(next);
                    },
                    selectedColor: layer.color.withOpacity(0.28),
                    checkmarkColor: layer.lineColor,
                    side: BorderSide(color: layer.lineColor, width: 1.1),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// アニメーション本体を構築
  Widget buildAnimation(
    BuildContext context,
    double time,
    double azimuth,
    double tilt,
    double scale,
    Map<String, double> parameters,
    Set<String> activeIds,
  );

  /// ドラッグ可能なマーカーを取得
  List<WaveMarker> getMarkers(Map<String, double> parameters, double time) => [];

  /// マーカーがドラッグされた時の処理
  void onMarkerDragged(
    Map<String, double> parameters,
    void Function(String key, double value) updateParam,
    int markerIndex,
    math.Point<double> newPoint,
    double time,
  ) {}

  /// FilterChipを生成する共通ヘルパー
  Widget buildChip(
    String label,
    String id,
    Color color,
    Set<String> activeIds,
    void Function(Set<String>) update, {
    double fontSize = 11,
  }) {
    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: fontSize)),
      selected: activeIds.contains(id),
      onSelected: (val) {
        final next = Set<String>.from(activeIds);
        val ? next.add(id) : next.remove(id);
        update(next);
      },
      selectedColor: color.withOpacity(0.3),
      checkmarkColor: color,
      padding: EdgeInsets.zero,
    );
  }
}

/// 波動シミュレーション用の共通基盤クラス
abstract class WaveSimulation extends PhysicsSimulation {
  WaveSimulation({
    required super.title,
    super.latex,
    super.formula,
    super.is3D = false,
    super.showTimeOverlay = true,
    super.enableTime = true,
  });

  @override
  bool get showZoomButtons => true;

  /// 3D 曲面表示の波動シミュレーションでは真上波面ビューを有効化
  @override
  bool get enableWavefrontTopView => is3D;

  /// 観測点位置を含む初期パラメータを生成するヘルパー
  Map<String, double> getInitialParamsWithObs({
    required Map<String, double> baseParams,
    double obsX = 2.0,
    double obsY = 0.0,
  }) {
    return {
      ...baseParams,
      'obsX': obsX,
      'obsY': obsY,
    };
  }

  /// 観測点位置調整用のスライダーを構築するヘルパー
  List<Widget> buildObsSliders(
    Map<String, double> params,
    void Function(String key, double value) updateParam, {
    bool is2D = true,
    String labelX = 'a',
    String labelY = 'b',
  }) {
    return [
      const Divider(),
      Text(
        is2D ? '観測点 ($labelX, $labelY)' : '観測点 $labelX',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      WaveParameterSlider(
        label: labelX,
        value: params['obsX']!,
        min: -5.0,
        max: 5.0,
        onChanged: (v) => updateParam('obsX', v),
      ),
      if (is2D)
        WaveParameterSlider(
          label: labelY,
          value: params['obsY']!,
          min: -5.0,
          max: 5.0,
          onChanged: (v) => updateParam('obsY', v),
        ),
    ];
  }

  /// 観測点を示す WaveMarker を生成するヘルパー
  WaveMarker getObsMarker(Map<String, double> params, {String? label}) {
    return WaveMarker(
      point: math.Point(params['obsX']!, params['obsY'] ?? 0.0),
      color: Colors.red,
      label: label,
      showZDisplacement: true,
    );
  }

  @override
  List<WaveMarker> getMarkers(Map<String, double> parameters, double time) {
    if (parameters.containsKey('obsX')) {
      return [getObsMarker(parameters)];
    }
    return [];
  }

  @override
  void onMarkerDragged(
    Map<String, double> parameters,
    void Function(String key, double value) updateParam,
    int markerIndex,
    math.Point<double> newPoint,
    double time,
  ) {
    // 波動シミュレーションのデフォルトでは最初のマーカーが obsX/obsY
    if (markerIndex == 0 && parameters.containsKey('obsX')) {
      updateParam('obsX', newPoint.x.clamp(-5.0, 5.0));
      if (parameters.containsKey('obsY')) {
        updateParam('obsY', newPoint.y.clamp(-5.0, 5.0));
      }
    }
  }
}

/// 共通のシミュレーション表示ウィジェット
class PhysicsSimulationView extends StatefulWidget with HasHeight {
  final PhysicsSimulation simulation;
  final double height;

  const PhysicsSimulationView({
    super.key,
    required this.simulation,
    this.height = 650,
  });

  @override
  double get widgetHeight => height;

  @override
  State<PhysicsSimulationView> createState() => _PhysicsSimulationViewState();
}

class _PhysicsSimulationViewState extends State<PhysicsSimulationView> {
  late Map<String, double> _parameters;
  late Set<String> _activeIds;

  @override
  void initState() {
    super.initState();
    _parameters = Map.from(widget.simulation.initialParameters);
    _activeIds = Set.from(widget.simulation.initialActiveIds);
  }

  void _updateParam(String key, double value) {
    setState(() {
      _parameters[key] = value;
    });
  }

  void _updateActiveIds(Set<String> ids) {
    setState(() {
      _activeIds = ids;
    });
  }

  Widget? _situationLine(String? text) {
    if (text == null || text.isEmpty) return null;
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 14,
        height: 1.45,
        color: Color(0xFF37474F),
      ),
    );
  }

  Widget? _buildExtraControls(BuildContext context) {
    return widget.simulation
        .composeExtraControls(context, _activeIds, _updateActiveIds);
  }

  @override
  Widget build(BuildContext context) {
    return PhysicsAnimationScaffold(
      title: widget.simulation.title,
      formula: widget.simulation.buildFormulaOverlay(_parameters) ??
          widget.simulation.formula,
      situation: _situationLine(widget.simulation.situation),
      compactButtonSpacing:
          widget.simulation.useCompactButtonSpacing(_parameters),
      animationOffsetY: widget.simulation.animationOffsetY(_parameters),
      is3D: widget.simulation.is3D,
      aspectRatio: widget.simulation.aspectRatio,
      aspectRatioForWidth: widget.simulation.aspectRatioForWidth,
      // Safety: when time is disabled, never show any time overlay UI.
      enableTime: widget.simulation.enableTime,
      showTimeOverlay:
          widget.simulation.enableTime && widget.simulation.showTimeOverlay,
      height: widget.height,
      sliders:
          widget.simulation.buildControls(context, _parameters, _updateParam),
      extraControls: _buildExtraControls(context),
      showZoomButtons: widget.simulation.showZoomButtons,
      wavefrontTopView: _activeIds.contains('showWavefrontTopView'),
      getMarkers: (time) => widget.simulation.getMarkers(_parameters, time),
      onMarkerDragged: (index, newPoint, time) {
        widget.simulation
            .onMarkerDragged(_parameters, _updateParam, index, newPoint, time);
      },
      animationBuilder: (context, time, azimuth, tilt, scale) {
        return widget.simulation.buildAnimation(
          context,
          time,
          azimuth,
          tilt,
          scale,
          _parameters,
          _activeIds,
        );
      },
    );
  }
}

/// Waveアニメーション用のVideoオブジェクト生成ヘルパー
Video createWaveVideo({
  required String title,
  required String latex,
  required PhysicsSimulation simulation,
  double height = 650,
  bool playsSound = false,
}) {
  return Video(
    category: 'waves',
    iconName: "wave",
    title: title,
    videoURL: "",
    equipment: [],
    costRating: "★",
    isSimulation: true,
    playsSound: playsSound,
    latex: latex,
    experimentWidgets: [
      PhysicsSimulationView(simulation: simulation, height: height),
    ],
  );
}

class _WavefrontLegend extends StatelessWidget {
  const _WavefrontLegend();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LegendMark(dashed: false),
        SizedBox(width: 4),
        Text('山', style: TextStyle(fontSize: 10, color: Color(0xFF546E7A))),
        SizedBox(width: 10),
        _LegendMark(dashed: true),
        SizedBox(width: 4),
        Text('谷', style: TextStyle(fontSize: 10, color: Color(0xFF546E7A))),
      ],
    );
  }
}

class _LegendMark extends StatelessWidget {
  const _LegendMark({required this.dashed});

  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(18, 8),
      painter: _LegendMarkPainter(dashed: dashed),
    );
  }
}

class _LegendMarkPainter extends CustomPainter {
  _LegendMarkPainter({required this.dashed});

  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF37474F)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final y = size.height / 2;
    if (!dashed) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      return;
    }
    canvas.drawLine(Offset(0, y), Offset(7, y), paint);
    canvas.drawLine(Offset(11, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(covariant _LegendMarkPainter oldDelegate) =>
      oldDelegate.dashed != dashed;
}


