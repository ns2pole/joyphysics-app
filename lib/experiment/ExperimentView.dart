import 'dart:math' as math; // 準備中透かしの回転で使用
import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:joyphysics/LatexView.dart';
import 'package:joyphysics/model.dart';
import 'package:joyphysics/experiment/PhysicsAnimationBase.dart';
import 'package:joyphysics/experiment/PhysicsAnimationScaffold.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:joyphysics/experiment/formulaListData.dart';
import 'package:joyphysics/experiment/HexColor.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter/services.dart'; // rootBundle 用
import 'package:flutter_html/flutter_html.dart';
import 'package:joyphysics/dataExporter.dart';
import 'package:joyphysics/theory/TheoryView.dart'; //画面遷移用
import 'package:html/dom.dart' as dom; // ← これが重要
import 'package:joyphysics/shared_components.dart';
import 'package:joyphysics/document_title.dart';

// 表示モード
enum VideoViewMode { byCategory, byFormula }

class VideoListView extends StatefulWidget {
  final Category category;
  VideoListView({required this.category});
  @override
  _VideoListViewState createState() => _VideoListViewState();
}

class _VideoListViewState extends State<VideoListView> {
  VideoViewMode viewMode = VideoViewMode.byCategory;

  List<Video> get videosInCategory =>
      widget.category.subcategories.expand((s) => s.videos).toList();
  List<FormulaEntry> get formulasInCategory =>
      formulaListData.where((f) => videosInCategory.contains(f.relatedVideo)).toList();

  @override
  Widget build(BuildContext context) {
    // 公式をカテゴリ毎にグループ化
    final groupMap = <String, List<FormulaEntry>>{};
    for (var f in formulasInCategory) {
      groupMap.putIfAbsent(f.categoryName, () => []).add(f);
    }

    final overallImageAsset = widget.category.getMindMapAsset();

    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name)),
      body: CustomScrollView(
        slivers: [
          // ─── 全体像画像 ───
          if (overallImageAsset != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PhysicsFullscreenImagePage(
                          imageAsset: overallImageAsset,
                          title: widget.category.getMindMapLabel(),
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.asset(
                            overallImageAsset,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4), // 画像と文字の間隔
                      Text(
                        widget.category.getMindMapLabel(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ─── 単元一覧 / 公式一覧 トグル ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Center(
                child: ToggleButtons(
                  constraints: const BoxConstraints(minWidth: 120, minHeight: 40),
                  borderRadius: BorderRadius.circular(8),
                  isSelected: [
                    viewMode == VideoViewMode.byCategory,
                    viewMode == VideoViewMode.byFormula,
                  ],
                  onPressed: (i) => setState(() {
                    viewMode = i == 0 ? VideoViewMode.byCategory : VideoViewMode.byFormula;
                  }),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('単元一覧', style: TextStyle(fontSize: 20)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('公式一覧', style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── コンテンツ本体（一覧 or 公式） ───
          if (viewMode == VideoViewMode.byCategory)
            _VideoCategoryList(
              subcategories: widget.category.subcategories,
              // 熱力学は項目が少ないのでプルダウンせず全表示
              flat: widget.category.name == '熱力学',
            )
          else
            FormulaList(
              groupedFormulas: groupMap,
              flat: widget.category.name == '熱力学',
            ),
        ],
      ),
    );
  }
}

// キャッシュ（アイコンパス解決結果を保持）
final Map<String, String> _assetPathCache = {};

Future<String> resolveAssetPath(String category, String iconName) async {
  final key = '$category/$iconName';
  if (_assetPathCache.containsKey(key)) {
    return _assetPathCache[key]!;
  }

  final pngPath = 'assets/$category/$iconName.png';
  final gifPath = 'assets/$category/$iconName.gif';

  try {
    await rootBundle.load(pngPath); // PNG 存在チェック
    _assetPathCache[key] = pngPath;
    return pngPath;
  } catch (_) {
    _assetPathCache[key] = gifPath;
    return gifPath;
  }
}

// ---- _VideoCategoryList（サブカテゴリはプルダウンで収納。flat時は全展開）----
class _VideoCategoryList extends StatelessWidget {
  final List<Subcategory> subcategories;
  /// true のとき ExpansionTile を使わず最初から全項目を出す
  final bool flat;
  const _VideoCategoryList({
    required this.subcategories,
    this.flat = false,
  });

  // 1件分のタイル（disabled = 準備中）
  Widget _videoTile(BuildContext context, Video v,
      {bool disabled = false, bool isLast = false}) {
    final hasIcon = v.iconName != null && v.iconName!.trim().isNotEmpty;

    final tileCore = ListTile(
      // ★ iconName 未設定なら空スペースを確保（❌を出さない）
      leading: hasIcon
          ? FutureBuilder<String>(
              future: resolveAssetPath(v.category, v.iconName!),
              builder: (context, snapshot) {
                Widget w = const SizedBox(width: 48, height: 27);
                if (snapshot.hasData) {
                  w = Image.asset(
                    snapshot.data!,
                    width: 48,
                    height: 27,
                    fit: BoxFit.contain,
                  );
                }
                return disabled ? Opacity(opacity: 0.6, child: w) : w;
              },
            )
          : const SizedBox(width: 48, height: 27),
      title: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 5,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 150,
            ),
            child: Text(
              v.title,
              style: const TextStyle(fontSize: 16),
              maxLines: 2,           // ← 2行まで表示
              softWrap: true,        // ← 改行許可
              overflow: TextOverflow.ellipsis, // 3行目以降は省略
            ),
          ),
          PhysicsBadge(
            isNew: v.isNew ?? false,
            isSimulation: v.isSimulation ?? false,
            isExperiment: v.isExperiment ?? false,
            isSmartPhoneOnly: v.isSmartPhoneOnly ?? false,
            opacity: disabled ? 0.6 : 1.0,
          ),
        ],
      ),
      onTap: disabled
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VideoDetailView(video: v)),
              ),
    );

    final row = Column(
      children: [
        tileCore,
        if (!isLast)
          Divider(
            thickness: 1.0,
            height: 0,
            indent: 16,
            endIndent: 16,
            color: Colors.grey[300],
          ),
        const SizedBox(height: 0),
      ],
    );

    if (!disabled) return row;

    return Stack(
      children: [
        Container(color: Colors.grey[200], child: row),
        const PreparationWatermark(),
      ],
    );
  }

  List<Video> _activeVideos(Subcategory sub) {
    return sub.videos.where((v) {
      final hasVideo = v.videoURL.isNotEmpty &&
          v.videoURL.trim() != "（動画URLをここに）" &&
          !v.videoURL.contains("（動画URL");
      final hasWidget =
          v.experimentWidgets != null && v.experimentWidgets!.isNotEmpty;
      return v.inPreparation != true && (hasVideo || hasWidget);
    }).toList();
  }

  List<Video> _prepVideos(Subcategory sub) {
    return sub.videos.where((v) {
      final hasVideo = v.videoURL.isNotEmpty &&
          v.videoURL.trim() != "（動画URLをここに）" &&
          !v.videoURL.contains("（動画URL");
      final hasWidget =
          v.experimentWidgets != null && v.experimentWidgets!.isNotEmpty;
      return v.inPreparation == true && (hasVideo || hasWidget);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[];

    for (final sub in subcategories) {
      final actives = _activeVideos(sub);
      final preps = _prepVideos(sub);

      if (actives.isNotEmpty) {
        final tiles = [
          for (var i = 0; i < actives.length; i++)
            _videoTile(
              context,
              actives[i],
              disabled: false,
              isLast: i == actives.length - 1,
            ),
        ];
        sections.add(
          flat
              ? _SubcategoryFlatList(
                  name: sub.name,
                  disabled: false,
                  children: tiles,
                )
              : _SubcategoryExpansion(
                  name: sub.name,
                  disabled: false,
                  children: tiles,
                ),
        );
      }

      if (preps.isNotEmpty) {
        final tiles = [
          for (var i = 0; i < preps.length; i++)
            _videoTile(
              context,
              preps[i],
              disabled: true,
              isLast: i == preps.length - 1,
            ),
        ];
        sections.add(
          flat
              ? _SubcategoryFlatList(
                  name: sub.name,
                  disabled: true,
                  children: tiles,
                )
              : _SubcategoryExpansion(
                  name: sub.name,
                  disabled: true,
                  children: tiles,
                ),
        );
      }
    }

    return SliverList(
      delegate: SliverChildListDelegate(sections),
    );
  }
}

/// サブカテゴリ見出しをタップで開閉するプルダウン
class _SubcategoryExpansion extends StatelessWidget {
  final String name;
  final bool disabled;
  final List<Widget> children;

  const _SubcategoryExpansion({
    required this.name,
    required this.disabled,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final bg = disabled ? Colors.grey[200] : Colors.grey[300];
    final titleColor = disabled ? Colors.black45 : Colors.black87;
    final label = disabled ? '$name（準備中）' : name;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        childrenPadding: EdgeInsets.zero,
        // 見出し行は灰色のまま。展開時も見出し帯は bg、中身は白で上書き。
        backgroundColor: bg,
        collapsedBackgroundColor: bg,
        iconColor: titleColor,
        collapsedIconColor: titleColor,
        title: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        children: [
          for (final child in children)
            ColoredBox(
              color: Colors.white,
              child: child,
            ),
        ],
      ),
    );
  }
}

/// プルダウンなしで見出し＋全項目を最初から出す（熱力学など）
class _SubcategoryFlatList extends StatelessWidget {
  final String name;
  final bool disabled;
  final List<Widget> children;

  const _SubcategoryFlatList({
    required this.name,
    required this.disabled,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final bg = disabled ? Colors.grey[200] : Colors.grey[300];
    final titleColor = disabled ? Colors.black45 : Colors.black87;
    final label = disabled ? '$name（準備中）' : name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ColoredBox(
          color: bg!,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
          ),
        ),
        for (final child in children)
          ColoredBox(
            color: Colors.white,
            child: child,
          ),
      ],
    );
  }
}

// 以降は元のまま（必要箇所のみ微修正）

class VideoDetailView extends StatefulWidget {
  final Video video;
  const VideoDetailView({required this.video, Key? key}) : super(key: key);

  @override
  State<VideoDetailView> createState() => _VideoDetailViewState();
}

class _VideoDetailViewState extends State<VideoDetailView> {
  List<_EmbeddedSimState> _simStates = [];

  String get _pageTitle {
    final v = widget.video;
    final prefix = (v.isExperiment == true)
        ? '【実験】'
        : (v.isSimulation == true)
            ? '【アニメ】'
            : '';
    return '$prefix${v.title}';
  }

  bool _isWideWeb(BuildContext context) {
    if (!kIsWeb) return false;
    final size = MediaQuery.sizeOf(context);
    if (size.height <= 0) return false;
    final ratio = size.width / size.height;
    return size.width >= 900 && ratio >= 1.2;
  }

  void _syncDocumentTitle() {
    if (kIsWeb) {
      setDocumentTitle(_pageTitle);
    }
  }

  @override
  void initState() {
    super.initState();
    _syncDocumentTitle();
  }

  @override
  void didUpdateWidget(covariant VideoDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video != widget.video) {
      _simStates = [];
    }
    _syncDocumentTitle();
  }

  _EmbeddedSimState _ensureSimState(int simIndex, PhysicsSimulation sim) {
    while (_simStates.length <= simIndex) {
      _simStates.add(_EmbeddedSimState.empty());
    }
    final existing = _simStates[simIndex];
    if (!existing.isInitialized) {
      _simStates[simIndex] = _EmbeddedSimState.fromSimulation(sim);
    }
    return _simStates[simIndex];
  }

  Widget _buildLeftVisualPane(BuildContext context) {
    final items = <Widget>[];

    // シミュレーション・実験
    if (widget.video.experimentWidgets != null &&
        widget.video.experimentWidgets!.isNotEmpty) {
      int simIndex = 0;
      for (final w in widget.video.experimentWidgets!) {
        // Wide Web では、解説カラムへ数式/スライダーを移すため、シミュレーションを「左=アニメのみ」に分割する
        if (_isWideWeb(context) && w is PhysicsSimulationView) {
          final sim = w.simulation;
          final state = _ensureSimState(simIndex, sim);

          void updateParam(String key, double value) {
            setState(() => state.parameters[key] = value);
          }

          void updateActiveIds(Set<String> ids) {
            setState(() => state.activeIds = ids);
          }

          void resetAll() {
            setState(() {
              state.parameters = Map<String, double>.from(sim.initialParameters);
              state.activeIds = Set<String>.from(sim.initialActiveIds);
            });
          }

          items.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PhysicsAnimationScaffold(
                // 左は「アニメ表示」に徹する（数式/スライダーは右へ）
                title: sim.title,
                formula: sim.buildFormulaOverlay(state.parameters),
                compactButtonSpacing: sim.useCompactButtonSpacing(state.parameters),
                animationOffsetY: sim.animationOffsetY(state.parameters),
                sliders: null,
                extraControls: null,
                height: w.height,
                aspectRatio: sim.aspectRatio,
                is3D: sim.is3D,
                // Simulation側の設定を反映（虹など time 無効のものは確実に非表示）
                enableTime: sim.enableTime,
                showTimeOverlay: sim.enableTime && sim.showTimeOverlay,
                showZoomButtons: sim.showZoomButtons,
                enableWideWebSplit: false, // VideoDetailView 側で左右分割するため、二重分割は抑止
                onReset: resetAll,
                getMarkers: (time) => sim.getMarkers(state.parameters, time),
                onMarkerDragged: (index, newPoint, time) {
                  sim.onMarkerDragged(
                      state.parameters, updateParam, index, newPoint, time);
                },
                animationBuilder: (context, time, azimuth, tilt, scale) {
                  return sim.buildAnimation(
                    context,
                    time,
                    azimuth,
                    tilt,
                    scale,
                    state.parameters,
                    state.activeIds,
                  );
                },
              ),
            ),
          );

          simIndex++;
          continue;
        }

        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: w,
          ),
        );
      }
    }

    // YouTube（視覚モジュール）
    if (widget.video.videoURL.isNotEmpty) {
      items.add(
        SizedBox(
          width: double.infinity,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: PhysicsYouTubePlayer(videoURL: widget.video.videoURL),
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return const Center(
        child: Text(
          'このコンテンツには動画/実験がありません。',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    // 左は「基本固定」。ただし溢れる場合だけ左カラム内でスクロールできるようにする
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView(
        children: items,
      ),
    );
  }

  Widget _buildRightExplanationPane(BuildContext context) {
    final items = <Widget>[];

    // Wide Web: 右上に「数式・スライダー」を集約して、その下に解説を置く
    if (_isWideWeb(context) &&
        widget.video.experimentWidgets != null &&
        widget.video.experimentWidgets!.isNotEmpty) {
      int simIndex = 0;
      for (final w in widget.video.experimentWidgets!) {
        if (w is PhysicsSimulationView) {
          final sim = w.simulation;
          final state = _ensureSimState(simIndex, sim);

          void updateParam(String key, double value) {
            setState(() => state.parameters[key] = value);
          }

          void updateActiveIds(Set<String> ids) {
            setState(() => state.activeIds = ids);
          }

          final extra = sim.buildExtraControls(
            context,
            state.activeIds,
            updateActiveIds,
          );
          final sliders = sim.buildControls(context, state.parameters, updateParam);

          items.add(
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '数式・パラメータ',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (sim.formula != null) sim.formula!,
                    if (extra != null) ...[
                      const SizedBox(height: 10),
                      extra,
                    ],
                    if (sliders.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ...sliders,
                    ],
                  ],
                ),
              ),
            ),
          );

          simIndex++;
        }
      }
    }

    // 解説・ポイント
    if (widget.video.latex != null) {
      items.add(LatexWebView(
        key: ValueKey('latex-${widget.video.title}'),
        latexHtml: widget.video.latex!,
      ));
    }

    // 実験道具
    if (widget.video.equipment.isNotEmpty) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: EquipmentListView(equipment: widget.video.equipment),
        ),
      );
    }

    if (items.isEmpty) {
      return const Center(
        child: Text(
          '解説がありません。',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    // 右側だけスクロール
    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _pageTitle;
    if (_isWideWeb(context)) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildLeftVisualPane(context),
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: _buildRightExplanationPane(context),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. シミュレーション・実験ウィジェットを最上部に
            if (widget.video.experimentWidgets != null &&
                widget.video.experimentWidgets!.isNotEmpty)
              ...widget.video.experimentWidgets!.map(
                (w) => Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: w,
                ),
              ),
            // 2. YouTube動画（これも視覚モジュールとして上部に配置）
            if (widget.video.videoURL.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: PhysicsYouTubePlayer(videoURL: widget.video.videoURL),
                ),
              ),
            // 3. 解説・ポイント
            if (widget.video.latex != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: LatexWebView(
                  key: ValueKey('latex-${widget.video.title}'),
                  latexHtml: widget.video.latex!,
                ),
              ),
            // 4. 実験道具を最後に
            if (widget.video.equipment.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: EquipmentListView(equipment: widget.video.equipment),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmbeddedSimState {
  Map<String, double> parameters;
  Set<String> activeIds;
  final bool isInitialized;

  _EmbeddedSimState._(this.parameters, this.activeIds, this.isInitialized);

  factory _EmbeddedSimState.empty() =>
      _EmbeddedSimState._(<String, double>{}, <String>{}, false);

  factory _EmbeddedSimState.fromSimulation(PhysicsSimulation sim) =>
      _EmbeddedSimState._(
        Map<String, double>.from(sim.initialParameters),
        Set<String>.from(sim.initialActiveIds),
        true,
      );
}

// 共通の TextStyle（ファイル上部に置く）
const TextStyle keiFontStyle = TextStyle(
  fontFamily: 'KeiFont',
  fontSize: 18,
);

class FormulaList extends StatelessWidget {
  final Map<String, List<FormulaEntry>> groupedFormulas;
  final bool flat;
  FormulaList({required this.groupedFormulas, this.flat = false});

  Widget _formulaTile(BuildContext context, FormulaEntry f, {bool isLast = false}) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideoDetailView(video: f.relatedVideo),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              f.relatedVideo.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          PhysicsBadge(
                            isNew: f.relatedVideo.isNew ?? false,
                            isSimulation: f.relatedVideo.isSimulation ?? false,
                            isExperiment: f.relatedVideo.isExperiment ?? false,
                            isSmartPhoneOnly: f.relatedVideo.isSmartPhoneOnly ?? false,
                            width: 68,
                            height: 45,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Math.tex(
                        f.latex,
                        textStyle: const TextStyle(
                          fontFamily: 'RobotoMono',
                          color: Colors.black,
                          height: 1.2,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            thickness: 1.0,
            height: 0,
            indent: 16,
            endIndent: 16,
            color: Colors.grey[300],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[];

    for (final entry in groupedFormulas.entries) {
      // 動画URL または 実験Widget があるもののみをフィルタリング
      final formulas = entry.value.where((f) {
        final v = f.relatedVideo;
        final hasVideo = v.videoURL.isNotEmpty &&
            v.videoURL.trim() != "（動画URLをここに）" &&
            !v.videoURL.contains("（動画URL");
        final hasWidget =
            v.experimentWidgets != null && v.experimentWidgets!.isNotEmpty;
        return hasVideo || hasWidget;
      }).toList();

      if (formulas.isEmpty) continue;

      final tiles = [
        for (var i = 0; i < formulas.length; i++)
          _formulaTile(
            context,
            formulas[i],
            isLast: i == formulas.length - 1,
          ),
      ];
      sections.add(
        flat
            ? _SubcategoryFlatList(
                name: entry.key,
                disabled: false,
                children: tiles,
              )
            : _SubcategoryExpansion(
                name: entry.key,
                disabled: false,
                children: tiles,
              ),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate(sections),
    );
  }
}

class EquipmentListView extends StatelessWidget {
  final List<String> equipment;
  const EquipmentListView({required this.equipment, super.key});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: HexColor.fromHex('#E5E5E5'),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text(
                '実験道具',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            ...equipment.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                child: Text('・$e', style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      );
}
