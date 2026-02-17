import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:joyphysics/dataExporter.dart';
import 'package:joyphysics/model.dart';
import 'package:joyphysics/theory/TheoryView.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            if (url.startsWith('app://')) {
              final handled = _handleAppLink(context, url);
              return handled ? NavigationDecision.prevent : NavigationDecision.navigate;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (String videoURL) async {
            await _controller.runJavaScript('''
              MathJax.typesetPromise().then(() => {
                try {
                  document.querySelectorAll('a[target="_blank"]').forEach(function(a){ a.target = '_self'; });
                } catch(e){}
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

  bool _handleAppLink(BuildContext context, String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.scheme != 'app') return false;
      if (uri.host != 'topic') return false;

      final key = uri.queryParameters['video'] ?? uri.queryParameters['topic'];
      if (key == null || key.isEmpty) return false;

      final Map<String, TheoryTopic> topicMap = {
        'runge_lenz_vector': runge_lenz_vector,
        'keplerSecondLaw': keplerSecondLaw,
        'magnetic': magneticDipole,
        'electric': electricDipole,
        'rcCircuit': rcCircuitTheory,
      };

      final target = topicMap[key];
      if (target == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('指定されたトピックが見つかりません： $key')),
          );
        }
        return true;
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TopicDetailPage(topic: target)),
        );
      }
      return true;
    } catch (e) {
      debugPrint('handleAppLink parse error: $e -- url: $url');
      return false;
    }
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
      src: url(data:font/ttf;base64,$fontBase64) format('truetype');
      font-weight: normal;
      font-style: normal;
    }
    html, body {
      margin: 0;
      padding: 0;
      overflow: auto;
      -webkit-overflow-scrolling: touch;
      background-color: transparent;
      font-family: 'KeiFont', sans-serif;
      font-size: 18px;
      line-height: 1.75;
    }

    .condition-box {
      background: rgba(255, 165, 244, 1);
      padding: 8px 16px;
      margin: 0px 0;
      border-radius: 12px;
      border: 0.7px solid rgba(0, 0, 0, 1);
    }

    li { margin-bottom: 0.5em; }

    .paragraph-box {
      border: 2px solid #333;
      border-radius: 6px;
      padding: 8px 12px;
      margin: 8px 0;
      display: inline-block;
      background-color: #f9f9f9;
    }

    .common-box {
      background: #cfc;
      padding: 8px 16px;
      margin: 0;
      font-size: 17px;
      border-radius: 12px;
      font-family: 'KeiFont', sans-serif;
    }

    .theory-common-box {
      background: #cfc;
      padding: 8px 16px;
      margin: 0px 0;
      border-radius: 12px;
      border: 0.7px solid rgba(0, 0, 0, 1);
    }

    .theorem-box {
      background: rgba(251, 223, 162, 1);
      padding: 8px 16px;
      margin: 0px 0;
      border-radius: 12px;
      border: 0.7px solid rgba(0, 0, 0, 1);
    }

    .proof-box {
      padding: 2px 2px;
      border-radius: 6px;
      font-size: 1.1em;
      font-weight: bold;
    }

    .math-box {
      width: 100%;
      padding: 0;
      box-sizing: border-box;
      white-space: normal;
      overflow-wrap: break-word;
      word-break: break-word;
      overflow-x: visible;
      -webkit-overflow-scrolling: touch;
    }

    .remark-box {
      display: inline-block;
      padding: 4px 12px;
      margin: 4px 0;
      border: 0.7px solid #333;
      border-radius: 12px;
      font-weight: bold;
      background: none;
    }

    .math-box img,
    .math-box table {
      max-width: 90%;
      height: auto;
      display: block;
      margin-left: auto;
      margin-right: auto;
      border-radius: 12px;
      overflow: hidden;
    }

    .math-box table td,
    .math-box table th {
      word-wrap: break-word;
      white-space: normal;
    }

    .math-box .MathJax_Display,
    .math-box .mjx-block,
    .math-box .MathJax_Display * {
      display: block;
      overflow-x: auto;
      -webkit-overflow-scrolling: touch;
      white-space: nowrap;
      padding: 6px 0;
      margin: 6px 0;
      box-sizing: border-box;
    }

    .math-box .MathJax_Display .MathJax,
    .math-box .MathJax_Display .mjx-svg-hbox,
    .math-box .MathJax_Display svg,
    .math-box .MathJax_Display mjx-container,
    .math-box .mjx-block svg {
      display: inline-block;
      max-width: none !important;
      height: auto !important;
      vertical-align: middle;
    }

    .math-box .MathJax_Chunk, 
    .math-box .MathJax_SVG,
    .math-box .mjx-chtml {
      max-width: none !important;
      overflow: visible !important;
    }

    @media (max-width: 480px) {
      .math-box .MathJax_Display { padding: 4px 0; }
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

