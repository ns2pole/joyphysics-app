import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/theory/theoryData.dart';
import 'package:joyphysics/LatexView.dart';
import 'package:joyphysics/model.dart';

// ─────────────────────────────
// TheoryListView
// ─────────────────────────────
class TheoryListView extends StatelessWidget {
  final String categoryName;

  const TheoryListView({Key? key, required this.categoryName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subcategories = theoryData[categoryName] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: subcategories.map((sub) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── サブカテゴリ見出し ──
              Container(
                width: double.infinity,
                color: Colors.grey[300],
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Text(
                  sub.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // ── トピックリスト ──
              ...sub.topics.map((topic) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    title: parseTextWithMath(
                      topic.title,
                      isNew: topic.isNew,
                      context: context,
                    ),
                    tileColor: Colors.blue[50]?.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TopicDetailPage(topic: topic)),
                      );
                    },
                  ),
                );
              }).toList(),
              const SizedBox(height: 4),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// --- TopicDetailPage の簡潔版（_ensureScrollableHtml を使わない） ---
class TopicDetailPage extends StatelessWidget {
  final TheoryTopic topic;

  const TopicDetailPage({Key? key, required this.topic}) : super(key: key);

  /// rawHtml が full-document なら body の中身を取り出す。
  /// それ以外（断片 HTML / plain テキスト）はそのまま返す。
  String _extractBodyFragment(String rawHtml) {
    final s = rawHtml.trim();
    final lower = s.toLowerCase();
    if (lower.startsWith('<!doctype') || lower.startsWith('<html')) {
      final bodyMatch = RegExp(r'<body[^>]*>([\\s\\S]*?)<\\/body>', caseSensitive: false)
          .firstMatch(s);
      if (bodyMatch != null) return bodyMatch.group(1) ?? '';
      // body が見つからないが html タグはあるなら html の中身を抽出
      final htmlMatch = RegExp(r'<html[^>]*>([\\s\\S]*?)<\\/html>', caseSensitive: false)
          .firstMatch(s);
      if (htmlMatch != null) return htmlMatch.group(1) ?? '';
      // fallback: 全文を返す（安全策）
      return s;
    } else {
      // 既に断片（期待される形式）ならそのまま
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
          child: LatexWebView(
            // ← ここには「body の中身」だけを渡す（LatexWebView が完全な HTML にラップする）
            latexHtml: bodyFragment,
          ),
        ),
      ),
    );
  }
}


// ─────────────────────────────
// 数式と "new.gif" を表示するウィジェット
// ─────────────────────────────
Widget parseTextWithMath(String input, {bool isNew = false, BuildContext? context}) {
  final regex = RegExp(r'(\$(.+?)\$|\\\((.+?)\\\))');
  final spans = <InlineSpan>[];

  int lastIndex = 0;
  for (final match in regex.allMatches(input)) {
    if (match.start > lastIndex) {
      spans.add(TextSpan(text: input.substring(lastIndex, match.start)));
    }

    final formula = match.group(2) ?? match.group(3);

    // 数式本体
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

    // isNew のときだけ new.gif を数式横に表示
    if (isNew && context != null) {
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Image.asset(
            'assets/others/new.gif',
            width: 40,
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
      ));
    }

    lastIndex = match.end;
  }

  if (lastIndex < input.length) {
    spans.add(TextSpan(text: input.substring(lastIndex)));
  }

  return RichText(
    text: TextSpan(
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      children: spans,
    ),
  );
}
