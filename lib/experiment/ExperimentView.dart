import 'dart:math' as math; // 準備中透かしの回転で使用
import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:flutter/material.dart';
import 'package:joyphysics/LatexView.dart';
import 'package:joyphysics/model.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:joyphysics/experiment/formulaListData.dart';
import 'package:joyphysics/experiment/HexColor.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter/services.dart'; // rootBundle 用
import 'package:flutter_html/flutter_html.dart';
import 'package:joyphysics/dataExporter.dart';
import 'package:joyphysics/theory/TheoryView.dart'; //画面遷移用
import 'package:html/dom.dart' as dom; // ← これが重要
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

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

    // カテゴリ名に応じて全体像画像のパスを決定
    String? getOverallImageAsset() {
      final categoryName = widget.category.name;
      if (categoryName == '力学') {
        return 'assets/mindMap/dynamicsLandScope.jpeg';
      } else if (categoryName == '電磁気学') {
        return 'assets/mindMap/emTheoryLandScope.jpeg';
      } else if (categoryName == '熱力学') {
        return 'assets/mindMap/thermoDynamicsLandScope.jpeg';
      } else if (categoryName == '波動') {
        return 'assets/mindMap/waveLandScope.jpeg';
      }
      return null;
    }

    final overallImageAsset = getOverallImageAsset();

    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name)),
      body: CustomScrollView(
        slivers: [
          // ─── 全体像画像 ───
          if (overallImageAsset != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullscreenImagePage(
                          imageAsset: overallImageAsset,
                        ),
                      ),
                    );
                  },
                  child: Builder(
                    builder: (context) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      // タブレット（600px以上）: 60%, スマホ: 95%
                      final imageWidthRatio = screenWidth >= 600 ? 0.60 : 0.95;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: screenWidth * imageWidthRatio,
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Image.asset(
                                  overallImageAsset,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4), // 画像と文字の間隔
                          Text(
                            // ラベルをカテゴリで切り替え
                            widget.category.name == '力学'
                                ? '力学全体像'
                                : widget.category.name == '電磁気学'
                                    ? '電磁気学全体像'
                                    : widget.category.name == '熱力学'
                                        ? '熱力学全体像'
                                        : '波動全体像',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      );
                    },
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
            _VideoCategoryList(subcategories: widget.category.subcategories)
          else
            FormulaList(groupedFormulas: groupMap),
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

// ---- _VideoCategoryList（ご要望対応：余白 + アイコン空欄 + タイトル2行）----
class _VideoCategoryList extends StatelessWidget {
  final List<Subcategory> subcategories;
  const _VideoCategoryList({required this.subcategories});

  // サブカテゴリ見出し帯（TheoryListView と同テイスト + 準備中表示）
  Widget _subHeader(String name, {bool disabled = false}) {
    return Container(
      width: double.infinity,
      color: disabled ? Colors.grey[200] : Colors.grey[300],
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        disabled ? '$name（準備中）' : name,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: disabled ? Colors.black45 : Colors.black87,
        ),
      ),
    );
  }

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
          if (v.isSmartPhoneOnly == true)
            Opacity(
              opacity: disabled ? 0.6 : 1.0,
              child: Image.asset(
                'assets/others/smartPhoneOnly.gif',
                width: 60,
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
          if (v.isNew == true)
            Opacity(
              opacity: disabled ? 0.6 : 1.0,
              child: Image.asset(
                'assets/others/new.gif',
                width: 45,
                height: 30,
                fit: BoxFit.contain,
            ),
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
        const SizedBox(height: 0), // 項目末尾は既存同等。見出し直下は build 側で 4 を入れる
      ],
    );

    if (!disabled) return row;

    // 準備中は薄グレー背景＋「準備中」透かし
    return Stack(
      children: [
        Container(color: Colors.grey[200], child: row),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: Center(
              child: Transform.rotate(
                angle: -math.pi / 12,
                child: Opacity(
                  opacity: 0.18,
                  child: Text(
                    '準備中',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final allItems = subcategories.expand((sub) {
      // 動画URLがあるもののみをフィルタリング（空文字列や「（動画URLをここに）」を除外）
      final actives = sub.videos.where((v) => 
        v.inPreparation != true && 
        v.videoURL.isNotEmpty && 
        v.videoURL.trim() != "（動画URLをここに）" &&
        !v.videoURL.contains("（動画URL")
      ).toList();
      final preps = sub.videos.where((v) => 
        v.inPreparation == true && 
        v.videoURL.isNotEmpty && 
        v.videoURL.trim() != "（動画URLをここに）" &&
        !v.videoURL.contains("（動画URL")
      ).toList();

      final widgets = <Widget>[];

      // フェーズ1：公開中
      if (actives.isNotEmpty) {
        widgets.add(_subHeader(sub.name, disabled: false));
        widgets.add(const SizedBox(height: 4)); // 見出し直下の白い余白

        for (var i = 0; i < actives.length; i++) {
          widgets.add(_videoTile(
            context,
            actives[i],
            disabled: false,
            isLast: i == actives.length - 1 && preps.isEmpty,
          ));
        }
        widgets.add(const SizedBox(height: 8)); // 次の帯との間隔（既存踏襲）
      }

      // フェーズ2：準備中
      if (preps.isNotEmpty) {
        widgets.add(_subHeader(sub.name, disabled: true));
        widgets.add(const SizedBox(height: 4)); // 見出し直下の白い余白

        for (var i = 0; i < preps.length; i++) {
          widgets.add(_videoTile(
            context,
            preps[i],
            disabled: true,
            isLast: i == preps.length - 1,
          ));
        }
        widgets.add(const SizedBox(height: 8)); // 次の帯との間隔（既存踏襲）
      }

      return widgets; // どちらも空なら何も追加しない
    }).toList();

    return SliverList(
      delegate: SliverChildListDelegate(allItems),
    );
  }
}

// 以降は元のまま（必要箇所のみ微修正）

class VideoDetailView extends StatelessWidget {
  final Video video;
  const VideoDetailView({required this.video, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(video.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (video.experimentWidgets != null && video.experimentWidgets!.isNotEmpty)
              ...video.experimentWidgets!.map(
                (w) => Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SizedBox(
                    height: (w is HasHeight) ? w.widgetHeight : 220,
                    width: double.infinity,
                    child: w,
                  ),
                ),
              ),
            if (video.videoURL.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: YouTubeWebView(videoURL: video.videoURL),
                ),
              ),
            if (video.equipment.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: EquipmentListView(equipment: video.equipment), // 元仕様どおり
              ),
            if (video.latex != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: LatexWebView(latexHtml: video.latex!),
              ),
          ],
        ),
      ),
    );
  }
}

// 共通の TextStyle（ファイル上部に置く）
const TextStyle keiFontStyle = TextStyle(
  fontFamily: 'KeiFont',
  fontSize: 18,
);

class FormulaList extends StatelessWidget {
  final Map<String, List<FormulaEntry>> groupedFormulas;
  FormulaList({required this.groupedFormulas});

  @override
  Widget build(BuildContext context) {
    final allItems = groupedFormulas.entries.expand((entry) {
      // 動画URLがあるもののみをフィルタリング（空文字列や「（動画URLをここに）」を除外）
      final formulas = entry.value.where((f) => 
        f.relatedVideo.videoURL.isNotEmpty && 
        f.relatedVideo.videoURL.trim() != "（動画URLをここに）" &&
        !f.relatedVideo.videoURL.contains("（動画URL")
      ).toList();
      
      if (formulas.isEmpty) {
        return <Widget>[];
      }

      return [
        Container(
          width: double.infinity,
          color: Colors.grey[300],
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            entry.key,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        ...List.generate(formulas.length, (index) {
          final f = formulas[index];
          final isLast = index == formulas.length - 1;

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
                      // 本文部
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // タイトル＋isNewマーク表示部分
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
                                    maxLines: 2,               // ← 2行まで表示
                                    softWrap: true,            // ← 改行許可
                                    overflow: TextOverflow.ellipsis, // 3行目以降は省略
                                  ),
                                ),
                                if (f.relatedVideo.isSmartPhoneOnly == true) ...[
                                  const SizedBox(width: 10),
                                  Image.asset(
                                    'assets/others/smartPhoneOnly.gif',
                                    width: 68,
                                    height: 45,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                                if (f.relatedVideo.isNew == true) ...[
                                  const SizedBox(width: 10),
                                  Image.asset(
                                    'assets/others/new.gif',
                                    width: 45,
                                    height: 30,
                                    fit: BoxFit.contain,
                                  ),
                                ],
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
        }),
      ];
    }).toList();

    return SliverList(
      delegate: SliverChildListDelegate(allItems),
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

/// YouTube動画IDを抽出する関数
/// フルURL（https://youtube.com/watch?v=...）や短縮URL（https://youtu.be/...）から動画IDを抽出
/// 既に動画IDのみの場合はそのまま返す
String extractVideoId(String videoUrl) {
  if (videoUrl.isEmpty) return '';
  
  // 既に動画IDのみの場合（短い文字列で特殊文字が含まれていない）
  if (!videoUrl.contains('http') && !videoUrl.contains('/') && !videoUrl.contains('?')) {
    return videoUrl;
  }
  
  // youtube.com/watch?v= 形式
  final watchMatch = RegExp(r'(?:youtube\.com/watch\?v=|youtu\.be/)([a-zA-Z0-9_-]{11})').firstMatch(videoUrl);
  if (watchMatch != null) {
    return watchMatch.group(1)!;
  }
  
  // embed形式から抽出
  final embedMatch = RegExp(r'youtube\.com/embed/([a-zA-Z0-9_-]{11})').firstMatch(videoUrl);
  if (embedMatch != null) {
    return embedMatch.group(1)!;
  }
  
  // それでも見つからない場合は、末尾の11文字を試す（動画IDは通常11文字）
  if (videoUrl.length >= 11) {
    final last11 = videoUrl.substring(videoUrl.length - 11);
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(last11)) {
      return last11;
    }
  }
  
  return videoUrl; // フォールバック: 元の文字列を返す
}

class YouTubeWebView extends StatefulWidget {
  final String videoURL;
  const YouTubeWebView({super.key, required this.videoURL});

  @override
  State<YouTubeWebView> createState() => _YouTubeWebViewState();
}

class _YouTubeWebViewState extends State<YouTubeWebView> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.videoURL.isNotEmpty) {
      final videoId = extractVideoId(widget.videoURL);
      if (videoId.isNotEmpty) {
        _controller = YoutubePlayerController.fromVideoId(
          videoId: videoId,
          params: const YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: true,
            origin: 'https://www.youtube-nocookie.com',
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const SizedBox.shrink();
    }
    return YoutubePlayer(
      controller: _controller!,
    );
  }
}
