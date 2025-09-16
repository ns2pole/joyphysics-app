import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:flutter/material.dart';
import 'package:joyphysics/LatexView.dart';
import 'package:joyphysics/model.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:joyphysics/experiment/formulaListData.dart';
import 'package:joyphysics/experiment/HexColor.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter/services.dart'; // rootBundle 用
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/dataExporter.dart';
import 'package:joyphysics/theory/TheoryView.dart'; //画面遷移用
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

    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name)),
      body: Column(
        children: [
          // ─── 単元一覧 / 公式一覧 トグル ───
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ToggleButtons(
              constraints: const BoxConstraints(minWidth: 120, minHeight: 40),
              borderRadius: BorderRadius.circular(8),
              isSelected: [
                viewMode == VideoViewMode.byCategory,
                viewMode == VideoViewMode.byFormula,
              ],
              onPressed: (i) => setState(() {
                viewMode =
                    i == 0 ? VideoViewMode.byCategory : VideoViewMode.byFormula;
              }),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '単元一覧',
                    style: TextStyle(fontSize: 20), // フォントサイズ大きく
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '公式一覧',
                    style: TextStyle(fontSize: 20), // フォントサイズ大きく
                  ),
                ),
              ],
            ),
          ),

          // ─── 実験コスト凡例 ───
          const CostLegendSection(),

          // ─── コンテンツ本体（一覧 or 公式） ───
          Expanded(
            child: viewMode == VideoViewMode.byCategory
                ? _VideoCategoryList(
                    subcategories: widget.category.subcategories)
                : FormulaList(groupedFormulas: groupMap),
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

// ---- あなたのウィジェット ----
class _VideoCategoryList extends StatelessWidget {
  final List<Subcategory> subcategories;
  _VideoCategoryList({required this.subcategories});

  @override
  Widget build(BuildContext context) => ListView(
        children: subcategories.expand((sub) {
          final videos = sub.videos;

          return [
            // ── サブカテゴリ見出し帯 ──
            Container(
              width: double.infinity,
              color: Colors.grey[300], // 薄いグレー
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                sub.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // ▼ サブカテゴリに属する動画リスト（線入り）
            ...List.generate(videos.length, (index) {
              final v = videos[index];
              final isLast = index == videos.length - 1;

              return Column(
                children: [
                  ListTile(
                    leading: FutureBuilder<String>(
                      future: resolveAssetPath(v.category, v.iconName),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SizedBox(width: 48, height: 27); // ローディング中
                        }
                        return Image.asset(
                          snapshot.data!,
                          width: 48,
                          height: 27,
                          fit: BoxFit.contain,
                        );
                      },
                    ),
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
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        if (v.isSmartPhoneOnly == true) ...[
                          SizedBox(width: 10), // タイトルと画像の隙間
                          Image.asset(
                            'assets/others/smartPhoneOnly.gif',
                            width: 60,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                        ],
                        if (v.isNew == true)
                          Image.asset(
                            'assets/others/new.gif',
                            width: 45,
                            height: 30,
                            fit: BoxFit.contain,
                          ),
                      ],
                    ),
                    trailing: Text(
                      v.costRating,
                      style: TextStyle(
                        fontFamily: 'Keifont',
                        color: HexColor.fromHex('#FF9900'),
                        fontSize: 19,
                      ),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => VideoDetailView(video: v)),
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
            SizedBox(height: 8), // 次の帯との間隔
          ];
        }).toList(),
      );
}


class VideoDetailView extends StatelessWidget {
  final Video video;
  const VideoDetailView({required this.video, Key? key}) : super(key: key);

  // -----------------------------
  // LaTeX を <tex> タグに変換
  // -----------------------------
  String _wrapTexWithTags(String html) {
    // display math
    final displayRe = RegExp(r'\$\$(.*?)\$\$', dotAll: true);
    html = html.replaceAllMapped(displayRe, (m) {
      String inner = m[1]!;
      inner = inner.replaceAll('&', '%%AMP%%'); // プレースホルダー
      return '<tex display="true">$inner</tex>';
    });

    // inline math
    final inlineRe = RegExp(r'\$([^\$]+?)\$');
    html = html.replaceAllMapped(inlineRe, (m) {
      String inner = m[1]!;
      inner = inner.replaceAll('&', '%%AMP%%'); // プレースホルダー
      return '<tex>$inner</tex>';
    });

    return html;
  }

  @override
  Widget build(BuildContext context) {
    final processedHtml = video.latex != null ? _wrapTexWithTags(video.latex!) : '';

    return Scaffold(
      appBar: AppBar(title: Text(video.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 動画プレイヤー
            if (video.videoURL.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: YouTubeWebView(videoURL: video.videoURL),
                ),
              ),

            // 装置リスト
            if (video.equipment.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: EquipmentListView(equipment: video.equipment),
              ),

            // HTML + LaTeX
            if (processedHtml.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Html(
                  data: processedHtml,
                  onLinkTap: (url, attributes, element) {
                    if (url != null) _handleVideoLink(context, url);
                  },
                  extensions: [
                    // ① LaTeX 用 <tex>
                    TagExtension(
                      tagsToExtend: {"tex"},
                      builder: (extCtx) {
                        String texString = extCtx.innerHtml.replaceAll('%%AMP%%', '&');
                        final isDisplay = extCtx.styledElement?.attributes['display'] == 'true';
                        final mathWidget = Math.tex(
                          texString,
                          mathStyle: isDisplay ? MathStyle.display : MathStyle.text,
                          textStyle: TextStyle(fontSize: isDisplay ? 22 : 18),
                          onErrorFallback: (e) => Text('LaTeX parse error: ${e.message}'),
                        );
                        return isDisplay
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Center(child: mathWidget),
                              )
                            : mathWidget;
                      },
                    ),

                    // ② CSS互換 <div> タグ
                    TagExtension(
                      tagsToExtend: {"div"},
                      builder: (extCtx) {
                        final className = extCtx.element?.classes.join(' ');
                        final textContent = extCtx.element?.text;

                        final textWidget = Text(
                          textContent!,
                          style: const TextStyle(
                            fontSize: 17,
                            fontFamily: 'KeiFont',
                          ),
                        );

                        // まず共通スタイルを定義しておくと便利
                        const TextStyle keiFontStyle = TextStyle(
                          fontFamily: 'KeiFont',
                          fontSize: 18,
                        );

                        switch (className) {
                          case 'common-box':
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              margin: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                color: const Color(0xffccffcc), // #cfc
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(width: 1.0, color: Colors.black),
                              ),
                              child: DefaultTextStyle.merge(
                                style: keiFontStyle,
                                child: textWidget,
                              ),
                            );

                          case 'theory-common-box':
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              margin: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                color: const Color(0xffccffcc),
                                border: Border.all(width: 1.0, color: Colors.black),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DefaultTextStyle.merge(
                                style: keiFontStyle,
                                child: textWidget,
                              ),
                            );

                          case 'theorem-box':
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              margin: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                color: const Color(0xfffbdfa2),
                                border: Border.all(width: 1.0, color: Colors.black),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DefaultTextStyle.merge(
                                style: keiFontStyle,
                                child: textWidget,
                              ),
                            );

                          case 'proof-box':
                            return Container(
                              padding: const EdgeInsets.all(2),
                              margin: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(width: 1.0, color: Colors.black),
                              ),
                              child: Text(
                                textContent,
                                style: keiFontStyle.copyWith(
                                  fontSize: 20, // 1.1em 相当
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );

                          case 'remark-box':
                            return IntrinsicWidth(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(width: 1.0, color: Colors.black),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  textContent,
                                  style: keiFontStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );

                          case 'condition-box':
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              margin: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                color: const Color(0xffffa5f4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(width: 1.0, color: Colors.black),
                              ),
                              child: DefaultTextStyle.merge(
                                style: keiFontStyle,
                                child: textWidget,
                              ),
                            );

                          case 'paragraph-box':
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xfff9f9f9),
                                border: Border.all(width: 2.0, color: Colors.black), // CSS は 2px
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: DefaultTextStyle.merge(
                                style: keiFontStyle,
                                child: textWidget,
                              ),
                            );

                          default:
                            return DefaultTextStyle.merge(
                              style: keiFontStyle,
                              child: textWidget,
                            );
                        }
                      }
                      )

                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleVideoLink(BuildContext context, String url) {
    debugPrint('Tapped URL: $url');
  }
}




// class VideoDetailView extends StatelessWidget {
//   final Video video;
//   const VideoDetailView({required this.video, Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(video.title)),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(6),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 複数ウィジェット対応
//             if (video.experimentWidgets != null && video.experimentWidgets!.isNotEmpty)
//               ...video.experimentWidgets!.map((w) => Padding(
//                     padding: const EdgeInsets.only(top: 16),
//                     child: SizedBox(
//                       height: (w is HasHeight) ? w.widgetHeight : 220, // デフォルト高さ
//                       width: double.infinity,
//                       child: w,
//                     ),
//                   )),
//             if (video.videoURL.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(top: 16),
//                 child: SizedBox(
//                   height: 200,
//                   width: double.infinity,
//                   child: YouTubeWebView(videoURL: video.videoURL),
//                 ),
//               ),

//             if (video.equipment.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(top: 16),
//                 child: EquipmentListView(equipment: video.equipment),
//               ),

//             if (video.latex != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 16),
//                 child: LatexWebView(latexHtml: video.latex!),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }


class FormulaList extends StatelessWidget {
  final Map<String, List<FormulaEntry>> groupedFormulas;
  FormulaList({required this.groupedFormulas});

  @override
  Widget build(BuildContext context) => ListView(
        children: groupedFormulas.entries.expand((entry) {
          final formulas = entry.value;

          return [
            // サブカテゴリヘッダー
            Container(
              width: double.infinity,
              color: Colors.grey[300],
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                entry.key,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            // 各公式
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
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (f.relatedVideo.isSmartPhoneOnly == true) ...[
                                      SizedBox(width: 10), // タイトルと画像の隙間
                                      Image.asset(
                                        'assets/others/smartPhoneOnly.gif',
                                        width: 68,
                                        height: 45,
                                        fit: BoxFit.contain,
                                      ),
                                    ],
                                    if (f.relatedVideo.isNew == true) ...[
                                      SizedBox(width: 10),
                                      Image.asset(
                                        'assets/others/new.gif',
                                        width: 45,
                                        height: 30,
                                        fit: BoxFit.contain,
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 4),
                                Math.tex(
                                  f.latex,
                                  textStyle: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Text(
                              f.relatedVideo.costRating,
                              style: TextStyle(
                                fontFamily: 'Keifont',
                                color: HexColor.fromHex('#FF9900'),
                                fontSize: 19,
                              ),
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
        }).toList(),
      );
}



class CostLegendSection extends StatelessWidget {
  const CostLegendSection({super.key});

  @override
  Widget build(BuildContext context) {
    const starColor = Color.fromRGBO(255, 153, 0, 1.0);

    const legendTextStyle = TextStyle(fontSize: 18);  // ← ここでフォントサイズ指定

    return Container(
      width: double.infinity,
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 上部タイトル
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("★", style: TextStyle(color: starColor, fontSize: 18)),
              Text("・・・実験コスト", style: TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 4),

          // 凡例項目
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("★☆☆", style: TextStyle(color: starColor, fontSize: 18)),
              Text(" = 500円未満", style: legendTextStyle),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("★★☆", style: TextStyle(color: starColor, fontSize: 18)),
              Text(" = 1500円未満", style: legendTextStyle),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("★★★", style: TextStyle(color: starColor, fontSize: 18)),
              Text(" = 1500円以上", style: legendTextStyle),
            ],
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Image.asset('assets/others/smartPhoneOnly.png', width: 60, height: 40),
          //     const SizedBox(width: 8),
          //     const Text("・・・スマホのみで実験可能", style: legendTextStyle),
          //   ],
          // ),
        ],
      ),
    );
  }
}

class EquipmentListView extends StatelessWidget {
  final List<String> equipment;
  EquipmentListView({required this.equipment});

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: HexColor.fromHex('#E5E5E5'),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                '実験道具',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18, // ← フォントサイズ16に指定
                ),
              ),
            ),
            ...equipment.map((e) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: Text(
                    '・$e',
                    style: TextStyle(fontSize: 16), // ← フォントサイズ16に指定
                  ),
                )),
          ],
        ),
      );
}


class YouTubeWebView extends StatefulWidget {
  final String videoURL;
  const YouTubeWebView({super.key, required this.videoURL});

  @override
  State<YouTubeWebView> createState() => _YouTubeWebViewState();
}

class _YouTubeWebViewState extends State<YouTubeWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse('https://www.youtube-nocookie.com/embed/${widget.videoURL}?autoplay=0'),
      );
  }

  @override
  Widget build(BuildContext context) {
    // SizedBoxは外側で管理するので不要
    return WebViewWidget(controller: _controller);
  }
}

