import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/theory/theoryData.dart';
import 'package:joyphysics/LatexView.dart';
import 'package:joyphysics/model.dart';
import 'package:flutter/material.dart';
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
        children: [
          if (categoryName == '力学理論' || categoryName == '電磁気学理論')
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullscreenImagePage(
                        imageAsset: categoryName == '力学理論'
                            ? 'assets/dynamicsTheory/dynamicsLandScope.jpeg'
                            : 'assets/electroMagnetismTheory/emTheoryLandScope.jpeg',
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
                            categoryName == '力学理論'
                                ? 'assets/dynamicsTheory/dynamicsLandScope.jpeg'
                                : 'assets/electroMagnetismTheory/emTheoryLandScope.jpeg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4), // 画像と文字の間隔
                    Text(
                      categoryName == '力学理論' ? '力学全体像' : '電磁気学全体像',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // --- 既存のサブカテゴリ表示 ---
          ...subcategories.map((sub) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // サブカテゴリ見出し
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

                // トピックリスト
                ...sub.topics.map((topic) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                      title: parseTextWithMath(
                        topic.title,
                        isNew: topic.isNew,
                      ),
                      tileColor: Colors.blue[50]?.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TopicDetailPage(topic: topic),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
                const SizedBox(height: 4),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}

class FullscreenImagePage extends StatelessWidget {
  final String imageAsset;

  const FullscreenImagePage({Key? key, required this.imageAsset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context), // タップで戻る
        child: Center(
          child: InteractiveViewer(
            panEnabled: true, // 移動
            scaleEnabled: true, // 拡大縮小
            child: Image.asset(
              imageAsset,
              fit: BoxFit.contain, // 画面に収まるよう比率維持
            ),
          ),
        ),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LatexWebView(
            latexHtml: bodyFragment,
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
