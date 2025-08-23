import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:joyphysics/theory/theoryData.dart';
import 'package:joyphysics/LatexView.dart';

Widget parseTextWithMath(String input) {
  // $...$ または \( ... \) にマッチ
  final regex = RegExp(r'(\$(.+?)\$|\\\((.+?)\\\))');
  final spans = <InlineSpan>[];

  int lastIndex = 0;
  for (final match in regex.allMatches(input)) {
    if (match.start > lastIndex) {
      spans.add(TextSpan(text: input.substring(lastIndex, match.start)));
    }

    // どっちのグループに入ったかを確認
    final formula = match.group(2) ?? match.group(3);

    spans.add(WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Math.tex(
        formula!,
        mathStyle: MathStyle.text,
        textStyle: const TextStyle(fontsize: 20),
      ),
    ));

    lastIndex = match.end;
  }

  if (lastIndex < input.length) {
    spans.add(TextSpan(text: input.substring(lastIndex)));
  }

  return RichText(
    text: TextSpan(
      style: const TextStyle(color: Colors.black),
      children: spans,
    ),
  );
}

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
                    fontsize: 20, 
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
                    title: parseTextWithMath(topic.title),
                    tileColor: Colors.blue[50]?.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Scaffold(
                            appBar: AppBar(
                              title: Text(
                                topic.title.replaceAll(RegExp(r'\$.*?\$'), ""), 
                              ),
                            ),
                            body: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: LatexWebView(
                                latexHtml: topic.latexContent,
                              ),
                            ),
                          ),
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
      ),
    );
  }
}
