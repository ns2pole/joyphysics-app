import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/model.dart';
import 'package:joyphysics/experiment/HasHeight.dart';
import 'PhysicsAnimationScaffold.dart';

/// 数式表示用の共通スタイル
const TextStyle commonFormulaStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w900,
);

/// 数式を表示するための共通ウィジェット
class FormulaDisplay extends StatelessWidget {
  final String tex;
  final TextStyle? style;

  const FormulaDisplay(this.tex, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return Math.tex(
      tex,
      textStyle: commonFormulaStyle.merge(style),
    );
  }
}

/// 物理シミュレーションの設定データを保持する抽象クラス
abstract class PhysicsSimulation {
  final String title;
  final String? latex;
  final Widget? formula;
  final bool is3D;

  PhysicsSimulation({
    required this.title,
    this.latex,
    this.formula,
    this.is3D = false,
  });

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
  ) => null;

  /// アニメーション本体を構築
  Widget buildAnimation(
    BuildContext context,
    double time,
    double azimuth,
    double tilt,
    Map<String, double> parameters,
    Set<String> activeIds,
  );
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

  @override
  Widget build(BuildContext context) {
    return PhysicsAnimationScaffold(
      title: widget.simulation.title,
      formula: widget.simulation.formula,
      is3D: widget.simulation.is3D,
      height: widget.height,
      sliders: widget.simulation.buildControls(context, _parameters, _updateParam),
      extraControls: widget.simulation.buildExtraControls(context, _activeIds, _updateActiveIds),
      animationBuilder: (context, time, azimuth, tilt) {
        return widget.simulation.buildAnimation(
          context,
          time,
          azimuth,
          tilt,
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
}) {
  return Video(
    category: 'waves',
    iconName: "wave",
    title: title,
    videoURL: "",
    equipment: [],
    costRating: "★",
    isSimulation: true,
    latex: latex,
    experimentWidgets: [
      PhysicsSimulationView(simulation: simulation),
    ],
  );
}


