import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class LatexWebView extends StatefulWidget {
  final String latexHtml;
  const LatexWebView({super.key, required this.latexHtml});

  @override
  State<LatexWebView> createState() => _LatexWebViewState();
}

class _LatexWebViewState extends State<LatexWebView> {
  late final WebViewController _controller;
  double webViewHeight = 100;
  final Map<String, String> _base64Cache = {};

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'SizeChannel',
        onMessageReceived: (JavaScriptMessage message) {
          final height = double.tryParse(message.message);
          if (height != null && (height - webViewHeight).abs() > 1) {
            setState(() {
              webViewHeight = height + 24;
            });
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (videoURL) async {
            await _controller.runJavaScript('''
              MathJax.typesetPromise().then(() => {
                setTimeout(() => {
                  SizeChannel.postMessage(document.body.scrollHeight.toString());
                }, 100);
              });
            ''');
          },
        ),
      );

    _prepareAndLoad();
  }

  Future<void> _prepareAndLoad() async {
    final processedHtml = await _embedBase64Images(widget.latexHtml);
    final fullHtml = await _wrapHtmlWithFont(processedHtml);
    _controller.loadHtmlString(fullHtml);
  }

  Future<String> _embedBase64Images(String html) async {
    final regex = RegExp(r'<img\s+[^>]*src="([^"]+)"[^>]*>', caseSensitive: false);
    var newHtml = html;
    for (final match in regex.allMatches(html)) {
      final src = match.group(1);
      if (src != null && src.startsWith('assets/')) {
        if (!_base64Cache.containsKey(src)) {
          try {
            final bytes = await rootBundle.load(src);
            final b64 = base64Encode(bytes.buffer.asUint8List());
            _base64Cache[src] = b64;
          } catch (_) {
            _base64Cache[src] = '';
          }
        }
        final b64 = _base64Cache[src];
        if (b64 != null && b64.isNotEmpty) {
          newHtml = newHtml.replaceAll(src, 'data:image/png;base64,$b64');
        }
      }
    }
    return newHtml;
  }

  Future<String> _wrapHtmlWithFont(String bodyHtml) async {
    final fontData = await rootBundle.load('assets/fonts/keifont.ttf');
    final fontBase64 = base64Encode(fontData.buffer.asUint8List());

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <style>
    @font-face {
      font-family: 'KeiFont';
      src: videoURL(data:font/ttf;base64,$fontBase64) format('truetype');
    }
    html, body {
      margin: 0;
      padding: 0;
      font-family: 'KeiFont', sans-serif;
      font-size: 17px;
      background-color: transparent;
      line-height: 1.75;  /* ← 行間を少し広く */
    }
    .common-box {
      background: #cfc;
      padding: 8px 16px;
      margin: 0px 0;
      border-radius: 4px;
    }
    .proof-box {
      padding: 2px 2px;   /* 少し広めに */
      border-radius: 6px;   /* 丸みも少し強調 */
      font-size: 1.1em;     /* フォントを少し大きめに */
      font-weight: bold;    /* 太字 */
    }
    ..math-box {
    width: 100%;
    padding: 0;
    box-sizing: border-box;
    white-space: normal;
    overflow-wrap: break-word;
    word-break: break-word;
    /* 親で隠さない。子要素（表示式）をスクロールさせる */
    overflow-x: visible;
    -webkit-overflow-scrolling: touch;
  }

  /* 画像・表は従来どおり最大幅に抑える */
  .math-box img,
  .math-box table {
    max-width: 90%;
    height: auto;
    display: block;
    margin-left: auto;
    margin-right: auto;
  }

  .math-box table td,
  .math-box table th {
    word-wrap: break-word;
    white-space: normal;
  }

  /* --- ここから MathJax（表示式）対応 --- */

  /* ブロック表示の MathJax 出力を横スクロール可能にする */
  /* MathJax のバージョン/出力形式に依ってクラス名が変わるため複数を指定 */
  .math-box .MathJax_Display,
  .math-box .mjx-block,
  .math-box .MathJax_Display * {
    /* ブロック数式領域を横スクロール用の領域にする */
    display: block;
    overflow-x: auto;                 /* ← 横スクロールを許可 */
    -webkit-overflow-scrolling: touch; /* スムーズスクロール（iOS） */
    white-space: nowrap;               /* 数式全体を折り返さず横に並べる */
    padding: 6px 0;                    /* 任意：見た目の余白 */
    margin: 6px 0;
    box-sizing: border-box;
  }

  /* MathJax が生成する SVG / 内部コンテナを切られないようにする */
  .math-box .MathJax_Display .MathJax,
  .math-box .MathJax_Display .mjx-svg-hbox,
  .math-box .MathJax_Display svg,
  .math-box .MathJax_Display mjx-container,
  .math-box .mjx-block svg {
    display: inline-block;
    max-width: none !important; /* 親の max-width 制限を解除 */
    height: auto !important;
    vertical-align: middle;
  }

  /* CHTML 出力にも対応（もし出力モードが HTML/CSS なら） */
  .math-box .MathJax_Chunk, 
  .math-box .MathJax_SVG,
  .math-box .mjx-chtml {
    max-width: none !important;
    overflow: visible !important;
  }

  /* 小さい画面での見栄え調整（任意） */
  @media (max-width: 480px) {
    .math-box .MathJax_Display {
      padding: 4px 0;
    }
  }
  </style>
  <script>
    window.MathJax = {
      options: {localStorage: false},
      tex: {inlineMath: [['\$','\$'], ['\\\\(','\\\\)']]},
      svg: {fontCache: 'global'}
    };
  </script>
  <script src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
</head>
<body>
  <div class="math-box">
    $bodyHtml
  </div>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: webViewHeight,
      child: WebViewWidget(controller: _controller),
    );
  }
}