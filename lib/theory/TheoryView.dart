import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/theory/theoryData.dart';
import 'package:joyphysics/LatexView.dart';
import 'package:joyphysics/model.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:joyphysics/shared_components.dart';

// ─────────────────────────────
// TheoryListView
// ─────────────────────────────
class TheoryListView extends StatelessWidget {
  final String categoryName;

  const TheoryListView({Key? key, required this.categoryName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subcategories = theoryData[categoryName] ?? [];
    final imageAsset = Category.getMindMapAssetByName(categoryName);

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: [
          if (imageAsset != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhysicsFullscreenImagePage(
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
                            imageAsset,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4), // 画像と文字の間隔
                    Text(
                      Category.getMindMapLabelByName(categoryName),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ...<Widget>[
            // フェーズ1：全サブカテゴリについて「アクティブ（inPreparation != true）だけ」を表示
            for (final sub in subcategories) ...[
              if (sub.topics.any((t) => t.inPreparation != true))
                SectionHeader(name: sub.name, fontSize: 20),
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
              if (sub.topics.any((t) => t.inPreparation == true))
                SectionHeader(name: sub.name, disabled: true, fontSize: 20),
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
                      const PreparationWatermark(),
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
    final rawHtml = topic.latexContent;
    final bodyFragment = _extractBodyFragment(rawHtml);

    return Scaffold(
      appBar: AppBar(
        title: Text(topic.title.replaceAll(RegExp(r'\$.*?\$'), "")),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (topic.imageAsset != null && topic.imageAsset!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PhysicsFullscreenImagePage(imageAsset: topic.imageAsset!),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FractionallySizedBox(
                        widthFactor: 0.58,
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
                const Text(
                  '全体像と本内容の位置付け',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              const SizedBox(height: 10),

              LatexWebView(
                latexHtml: bodyFragment,
              ),
              if (topic.videoURL != null && topic.videoURL!.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 12),
                  child: Semantics(
                    header: true,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade800,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
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
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: PhysicsYouTubePlayer(videoURL: topic.videoURL),
                ),
              ],
            ],
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

    if (isNew && !insertedNewAfterFormula) {
      spans.add(const WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: SizedBox(width: 6, height: 1),
      ));
      spans.add(const WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: PhysicsBadge(isNew: true),
      ));
      insertedNewAfterFormula = true;
    }
    lastIndex = match.end;
  }

  if (lastIndex < input.length) spans.add(TextSpan(text: input.substring(lastIndex)));

  if (isNew && !insertedNewAfterFormula) {
    spans.add(const WidgetSpan(alignment: PlaceholderAlignment.middle, child: SizedBox(width: 6, height: 1)));
    spans.add(const WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: PhysicsBadge(isNew: true),
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
