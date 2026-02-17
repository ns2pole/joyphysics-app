import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:joyphysics/dataExporter.dart';
import 'package:joyphysics/model.dart';
import 'package:joyphysics/theory/TheoryView.dart';

// Web-only registry API
import 'dart:ui_web' as ui;

class LatexWebView extends StatefulWidget {
  final String latexHtml;
  const LatexWebView({super.key, required this.latexHtml});

  @override
  State<LatexWebView> createState() => _LatexWebViewState();
}

class _LatexWebViewState extends State<LatexWebView> {
  static int _idSeq = 0;
  late final int _id;
  late final String _viewType;
  double _height = 140;
  StreamSubscription<html.MessageEvent>? _msgSub;

  final Map<String, String> _base64Cache = {};

  @override
  void initState() {
    super.initState();
    _id = _idSeq++;
    _viewType = 'latex-iframe-$_id';

    _msgSub = html.window.onMessage.listen((event) {
      final data = event.data;
      if (data is! Map) return;
      if (data['type'] != 'latexView') return;
      if (data['id'] != _id) return;

      if (data['event'] == 'height') {
        final num? h = data['height'];
        if (h != null) {
          final newHeight = (h.toDouble() + 24).clamp(80.0, 5000.0);
          if ((newHeight - _height).abs() > 1 && mounted) {
            setState(() => _height = newHeight);
          }
        }
      } else if (data['event'] == 'appLink') {
        final url = data['url'];
        if (url is String) {
          _handleAppLink(context, url);
        }
      }
    });

    _registerAndLoad();
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    super.dispose();
  }

  Future<void> _registerAndLoad() async {
    final processedHtml = await _embedBase64Images(widget.latexHtml);
    final fullHtml = await _wrapHtmlWithFont(processedHtml);

    ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..srcdoc = fullHtml;
      return iframe;
    });
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

  Future<String> _embedBase64Images(String htmlText) async {
    final regex = RegExp(r'<img\s+[^>]*src="([^"]+)"[^>]*>', caseSensitive: false);
    var newHtml = htmlText;
    for (final match in regex.allMatches(htmlText)) {
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

    // iframe 内で height を親へ通知する
    final bridgeScript = '''
    function postHeight() {
      try {
        parent.postMessage({type: 'latexView', id: ${_id}, event: 'height', height: document.body.scrollHeight}, '*');
      } catch(e) {}
    }
    function interceptAppLinks() {
      try {
        document.querySelectorAll('a').forEach(function(a){
          a.addEventListener('click', function(ev){
            var href = a.getAttribute('href') || '';
            if (href.startsWith('app://')) {
              ev.preventDefault();
              parent.postMessage({type: 'latexView', id: ${_id}, event: 'appLink', url: href}, '*');
            }
          });
        });
      } catch(e) {}
    }
    window.addEventListener('load', function(){
      setTimeout(function(){ postHeight(); }, 50);
    });
    window.addEventListener('resize', function(){
      setTimeout(function(){ postHeight(); }, 100);
    });
    ''';

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
      background-color: transparent;
      font-family: 'KeiFont', sans-serif;
      font-size: 18px;
      line-height: 1.75;
    }
    .math-box {
      width: 100%;
      padding: 0;
      box-sizing: border-box;
    }
    .common-box {
      background: #cfc;
      padding: 8px 16px;
      margin: 0;
      font-size: 17px;
      border-radius: 12px;
      font-family: 'KeiFont', sans-serif;
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
    /* ブロック数式は横スクロール許可 */
    .math-box .MathJax_Display,
    .math-box .mjx-block,
    .math-box .MathJax_Display * {
      display: block;
      overflow-x: auto;
      white-space: nowrap;
      padding: 6px 0;
      margin: 6px 0;
      box-sizing: border-box;
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
  <script>
    $bridgeScript
    if (window.MathJax && MathJax.typesetPromise) {
      MathJax.typesetPromise().then(() => {
        interceptAppLinks();
        setTimeout(() => { postHeight(); }, 100);
      });
    } else {
      interceptAppLinks();
      setTimeout(() => { postHeight(); }, 150);
    }
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    // registerViewFactory は async で済ませるため、初回は短い placeholder を出す
    return SizedBox(
      width: double.infinity,
      height: _height,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}

