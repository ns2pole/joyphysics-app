import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/theory/theoryData.dart';
import 'package:joyphysics/LatexView.dart';
import 'package:joyphysics/model.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

// ─────────────────────────────
// TheoryListView
// ─────────────────────────────
class TheoryListView extends StatelessWidget {
  final String categoryName;

  const TheoryListView({Key? key, required this.categoryName}) : super(key: key);

          
  // 小ヘルパー：サブカテゴリ見出し
  Widget subHeader(String name, {bool disabled = false}) {
    return Container(
      width: double.infinity,
      color: Colors.grey[300],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        disabled ? '$name（準備中）' : name,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: disabled ? Colors.black45 : Colors.black87,
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final subcategories = theoryData[categoryName] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: [
          if (categoryName == '力学理論' || categoryName == '電磁気学理論' || categoryName == '熱力学理論')
            Padding(
  padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 16.0),
  child: GestureDetector(
    onTap: () {
      // 画像パスをカテゴリに応じて決定
      final imageAsset = categoryName == '力学理論'
          ? 'assets/mindMap/dynamicsLandScope.jpeg'
          : categoryName == '電磁気学理論'
              ? 'assets/mindMap/emTheoryLandScope.jpeg'
              : 'assets/mindMap/thermoDynamicsLandScope.jpeg';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullscreenImagePage(
            imageAsset: imageAsset,
          ),
        ),
      );
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.58,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                // 表示画像をカテゴリに応じて切り替え
                categoryName == '力学理論'
                    ? 'assets/mindMap/dynamicsLandScope.jpeg'
                    : categoryName == '電磁気学理論'
                        ? 'assets/mindMap/emTheoryLandScope.jpeg'
                        : 'assets/mindMap/thermoDynamicsLandScope.jpeg',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4), // 画像と文字の間隔
        Text(
          // ラベルもカテゴリで切り替え
          categoryName == '力学理論'
              ? '力学全体像'
              : categoryName == '電磁気学理論'
                  ? '電磁気学全体像'
                  : '熱力学全体像',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    ),
  ),
),


// --- ここを差し替える（元の ...subcategories.map(...) をこのブロックで置き換える） ---
...<Widget>[
  // フェーズ1：全サブカテゴリについて「アクティブ（inPreparation != true）だけ」を表示
  for (final sub in subcategories) ...[
    if (sub.topics.any((t) => t.inPreparation != true)) subHeader(sub.name),
    for (final topic in sub.topics.where((t) => t.inPreparation != true))
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.blue[50]?.withOpacity(0.1),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: parseTextWithMath(topic.title, isNew: topic.isNew),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TopicDetailPage(topic: topic)),
                );
              },
            ),
          ),
        ),
      ),
    const SizedBox(height: 4),
  ],

  // フェーズ2：全サブカテゴリについて「準備中（inPreparation == true）だけ」を表示
  for (final sub in subcategories) ...[
    if (sub.topics.any((t) => t.inPreparation == true)) subHeader(sub.name, disabled: true),
    for (final topic in sub.topics.where((t) => t.inPreparation == true))
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Material(
                color: Colors.grey[200],
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Opacity(
                    opacity: 0.6,
                    child: parseTextWithMath(topic.title, isNew: topic.isNew),
                  ),
                  trailing: null,
                  onTap: null, // 無効化
                ),
              ),
            ),

            // 「準備中」透かし
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
        ),
      ),
    const SizedBox(height: 4),
  ],
],

        ],
      ),
    );
  }
}

class TopicDetailPage extends StatelessWidget {
  final TheoryTopic topic;

  const TopicDetailPage({Key? key, required this.topic}) : super(key: key);

  /// rawHtml が full-document なら body の中身を取り出す。
  /// それ以外（断片 HTML / plain テキスト）はそのまま返す。
  String _extractBodyFragment(String rawHtml) {
    final s = rawHtml.trim();
    final lower = s.toLowerCase();
    if (lower.startsWith('<!doctype') || lower.startsWith('<html')) {
      final bodyMatch = RegExp(r'<body[^>]*>([\s\S]*?)<\/body>', caseSensitive: false)
          .firstMatch(s);
      if (bodyMatch != null) return bodyMatch.group(1) ?? '';
      final htmlMatch = RegExp(r'<html[^>]*>([\s\S]*?)<\/html>', caseSensitive: false)
          .firstMatch(s);
      if (htmlMatch != null) return htmlMatch.group(1) ?? '';
      return s;
    } else {
      return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawHtml = topic!.latexContent;
    final bodyFragment = _extractBodyFragment(rawHtml);

    return Scaffold(
      appBar: AppBar(
        title: Text(topic!.title.replaceAll(RegExp(r'\$.*?\$'), "")),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- 画像表示（タップで全画面） ---
              if (topic.imageAsset != null && topic.imageAsset!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullscreenImagePage(imageAsset: topic.imageAsset!),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FractionallySizedBox(
                        widthFactor: 0.58, // 画面幅の58%
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.asset(
                            topic.imageAsset!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (topic.imageAsset != null && topic.imageAsset!.isNotEmpty) 
                Text(
                  '全体像と本内容の位置付け',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 10), // 画像と文字の間隔
              // ↑ 挿入終わり

              // --- MathJax 表示 ---
              LatexWebView(
                latexHtml: bodyFragment,
              ),
               if (topic.videoURL != null && topic.videoURL!.isNotEmpty) ...[
                // 見出し（中央揃え、丸角の枠で囲む）
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 12),
                  child: Semantics(
                    header: true,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade800, // 濃いめグレー
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10.0), // 角丸
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '本内容の対応実験',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 動画（既存のコード）
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: TheoryYouTubeWebView(videoURL: topic.videoURL),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


// --- 全画面表示ページ ---
class FullscreenImagePage extends StatelessWidget {
  final String imageAsset;

  const FullscreenImagePage({Key? key, required this.imageAsset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
            child: Image.asset(
              imageAsset,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

Widget parseTextWithMath(String input, {bool isNew = false}) {
  final regex = RegExp(r'(\$\$(.+?)\$\$|\$(.+?)\$|\\\((.+?)\\\)|\\\[(.+?)\\\])', dotAll: true);
  final spans = <InlineSpan>[];

  int lastIndex = 0;
  bool insertedNewAfterFormula = false;
  final matches = regex.allMatches(input).toList();

  for (final match in matches) {
    if (match.start > lastIndex) {
      spans.add(TextSpan(text: input.substring(lastIndex, match.start)));
    }

    String? formula;
    for (int gi = 2; gi <= 5; gi++) {
      if (match.group(gi) != null) {
        formula = match.group(gi);
        break;
      }
    }
    formula ??= match.group(0);

    // --- 数式を「中央揃え」で挿入 ---
    try {
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Math.tex(
          formula!,
          mathStyle: MathStyle.text,
          textStyle: const TextStyle(
            fontFamily: 'Keifont',
            fontSize: 20,
          ),
        ),
      ));
    } catch (e) {
      spans.add(TextSpan(text: formula));
    }

    // 数式直後に new.gif を一度だけ追加（中央揃え）
    if (isNew && !insertedNewAfterFormula) {
      // 少し横スペース
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: const SizedBox(width: 6, height: 1),
      ));

      // 画像（中央揃え）。高さをテキストサイズに近づけると見た目自然。
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: SizedBox(
          width: 45,
          height: 30, // ← フォントサイズ20に合わせてみる（必要に応じ調整）
          child: Image.asset('assets/others/new.gif', fit: BoxFit.contain),
        ),
      ));

      // もしまだ上寄りなら微調整（コメントアウトを外して試す）
      /*
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Transform.translate(
          offset: const Offset(0, 2), // 下に2pxずらす（適宜変更）
          child: SizedBox(width: 40, height: 20, child: Image.asset('assets/others/new.gif', fit: BoxFit.contain)),
        ),
      ));
      */

      insertedNewAfterFormula = true;
    }

    lastIndex = match.end;
  }

  if (lastIndex < input.length) spans.add(TextSpan(text: input.substring(lastIndex)));

  // 数式が無いタイトルの場合は末尾に追加する挙動は省略せず残す（必要ならここで同様に middle 揃えで追加）
  if (isNew && !insertedNewAfterFormula) {
    spans.add(WidgetSpan(alignment: PlaceholderAlignment.middle, child: const SizedBox(width: 6, height: 1)));
    spans.add(WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: SizedBox(width: 45, height: 30, child: Image.asset('assets/others/new.gif', fit: BoxFit.contain)),
    ));
  }

  return RichText(
    text: TextSpan(
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
      children: spans,
    ),
    maxLines: null,
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

class TheoryYouTubeWebView extends StatefulWidget {
  final String? videoURL;
  const TheoryYouTubeWebView({super.key, required this.videoURL});

  @override
  State<TheoryYouTubeWebView> createState() => _TheoryYouTubeWebViewState();
}

class _TheoryYouTubeWebViewState extends State<TheoryYouTubeWebView> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.videoURL != null && widget.videoURL!.isNotEmpty) {
      final videoId = extractVideoId(widget.videoURL!);
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

