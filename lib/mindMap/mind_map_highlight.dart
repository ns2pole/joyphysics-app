import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 全体像画像上の正規化矩形（原点は左上、値は 0〜1）。
/// 常に「画像ピクセル空間」基準。画面レイアウトには依存しない。
@immutable
class MindMapRect {
  final double left;
  final double top;
  final double width;
  final double height;

  const MindMapRect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  factory MindMapRect.fromJson(Map<String, dynamic> json) {
    return MindMapRect(
      left: (json['left'] as num).toDouble(),
      top: (json['top'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
  }

  /// OCR の文字枠に少し余白を足して、理論記事の赤枠に近づける。
  MindMapRect padded({double pad = 0.006}) {
    final l = (left - pad).clamp(0.0, 1.0);
    final t = (top - pad).clamp(0.0, 1.0);
    final r = (left + width + pad).clamp(0.0, 1.0);
    final b = (top + height + pad).clamp(0.0, 1.0);
    return MindMapRect(left: l, top: t, width: r - l, height: b - t);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MindMapRect &&
          left == other.left &&
          top == other.top &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => Object.hash(left, top, width, height);
}

@immutable
class MindMapHighlightData {
  final String imageAsset;
  final List<MindMapRect> rects;
  final List<String> matchedTexts;

  const MindMapHighlightData({
    required this.imageAsset,
    required this.rects,
    required this.matchedTexts,
  });

  bool get isEmpty => rects.isEmpty;
}

/// Video.category → 単元 home と同じ全体像 + OCR キャッシュ。
class MindMapCatalog {
  static const Map<String, ({String image, String ocr})> byCategory = {
    'dynamics': (
      image: 'assets/mindMap/dynamicsLandScope.jpeg',
      ocr: 'assets/mindMap/ocr/dynamicsLandScope.json',
    ),
    'electroMagnetism': (
      image: 'assets/mindMap/emTheoryLandScope.jpeg',
      ocr: 'assets/mindMap/ocr/emTheoryLandScope.json',
    ),
    'thermoDynamics': (
      image: 'assets/mindMap/thermoDynamicsLandScope.jpeg',
      ocr: 'assets/mindMap/ocr/thermoDynamicsLandScope.json',
    ),
    'waves': (
      image: 'assets/mindMap/waveLandScope.jpeg',
      ocr: 'assets/mindMap/ocr/waveLandScope.json',
    ),
  };

  static ({String image, String ocr})? assetsForCategory(String category) {
    return byCategory[_canonicalCategory(category)];
  }

  static String _canonicalCategory(String category) {
    const aliases = {
      'thermodynamics': 'thermoDynamics',
      'wave': 'waves',
      'electromagnetism': 'electroMagnetism',
    };
    return aliases[category] ?? category;
  }
}

class _OcrBox {
  final String text;
  final MindMapRect rect;
  final double confidence;

  const _OcrBox({
    required this.text,
    required this.rect,
    required this.confidence,
  });
}

/// OCR 結果から記事タイトル／クエリに最も近い文字枠を選ぶ。
class MindMapHighlightResolver {
  MindMapHighlightResolver._();
  static final MindMapHighlightResolver instance = MindMapHighlightResolver._();

  static const _queriesAsset = 'assets/mindMap/video_mindmap_queries.json';

  /// テスト用: タイトルキーワード照合だけを走らせ、採用された OCR 文言を返す。
  @visibleForTesting
  static List<String> titleKeywordMatches(String title, List<String> ocrTexts) {
    final boxes = <_OcrBox>[
      for (var i = 0; i < ocrTexts.length; i++)
        _OcrBox(
          text: ocrTexts[i],
          rect: MindMapRect(
            left: 0,
            top: i * 0.01,
            width: 0.1,
            height: 0.008,
          ),
          confidence: 1,
        ),
    ];
    final data = _dataFromScores(
      'test',
      boxes,
      _scoreTitleKeywords(boxes, title),
    );
    return data?.matchedTexts ?? const [];
  }

  final Map<String, Future<List<_OcrBox>>> _ocrCache = {};
  Future<Map<String, Map<String, List<String>>>>? _queriesFuture;

  Future<List<_OcrBox>> _loadOcr(String assetPath) {
    return _ocrCache.putIfAbsent(assetPath, () async {
      try {
        final raw = await rootBundle.loadString(assetPath);
        final list = jsonDecode(raw) as List<dynamic>;
        return list.map((e) {
          final m = e as Map<String, dynamic>;
          return _OcrBox(
            text: (m['text'] as String?)?.trim() ?? '',
            rect: MindMapRect.fromJson(m),
            confidence: (m['confidence'] as num?)?.toDouble() ?? 0,
          );
        }).where((b) => b.text.isNotEmpty).toList();
      } catch (_) {
        return const <_OcrBox>[];
      }
    });
  }

  Future<Map<String, Map<String, List<String>>>> _loadQueries() {
    return _queriesFuture ??= () async {
      try {
        final raw = await rootBundle.loadString(_queriesAsset);
        final root = jsonDecode(raw) as Map<String, dynamic>;
        return root.map((cat, value) {
          final m = <String, List<String>>{};
          for (final e in (value as Map<String, dynamic>).entries) {
            final v = e.value;
            if (v is List) {
              m[e.key] = v.map((x) => x.toString()).toList();
            } else {
              m[e.key] = [v.toString()];
            }
          }
          return MapEntry(cat, m);
        });
      } catch (_) {
        return <String, Map<String, List<String>>>{};
      }
    }();
  }

  /// 照合順:
  /// 1. 明示 [query]
  /// 2. [video_mindmap_queries.json] の上書き（タイトル語だけでは足りない／誤る記事）
  /// 3. タイトルのキーワード ⊆ OCR（またはその逆の長め一致）
  Future<MindMapHighlightData?> resolve({
    required String category,
    required String title,
    String? query,
  }) async {
    final assets = MindMapCatalog.assetsForCategory(category);
    if (assets == null) return null;

    final boxes = await _loadOcr(assets.ocr);
    if (boxes.isEmpty) return null;

    List<String> queries = const [];
    if (query != null && query.isNotEmpty) {
      queries = [query];
    } else {
      final all = await _loadQueries();
      final catKey = MindMapCatalog._canonicalCategory(category);
      queries = all[catKey]?[title] ?? all[category]?[title] ?? const [];
    }

    if (queries.isNotEmpty) {
      final scores = List<double>.filled(boxes.length, 0);
      for (final q in queries) {
        final nq = _normalize(q);
        if (nq.isEmpty) continue;
        for (var i = 0; i < boxes.length; i++) {
          final score = _score(nq, _normalize(boxes[i].text));
          if (score > scores[i]) scores[i] = score;
        }
      }
      return _dataFromScores(assets.image, boxes, scores);
    }

    return _dataFromScores(
      assets.image,
      boxes,
      _scoreTitleKeywords(boxes, title),
    );
  }

  static MindMapHighlightData? _dataFromScores(
    String imageAsset,
    List<_OcrBox> boxes,
    List<double> scores,
  ) {
    const threshold = 0.55;
    var best = 0.0;
    for (final s in scores) {
      if (s > best) best = s;
    }
    if (best < threshold) return null;

    // 最高点付近だけ残す（「等速円運動」が「非等速円運動」にも当たるのを防ぐ）。
    final floor = best >= 0.99 ? best - 0.02 : best - 0.08;
    final hits = <({_OcrBox box, double score})>[];
    for (var i = 0; i < boxes.length; i++) {
      if (scores[i] >= threshold && scores[i] >= floor) {
        hits.add((box: boxes[i], score: scores[i]));
      }
    }
    if (hits.isEmpty) return null;

    hits.sort((a, b) => b.score.compareTo(a.score));
    final selected = <_OcrBox>[];
    for (final hit in hits) {
      final r = hit.box.rect;
      final dup = selected.any((s) => _rectsAlmostSame(s.rect, r));
      if (!dup) selected.add(hit.box);
    }

    return MindMapHighlightData(
      imageAsset: imageAsset,
      rects: selected.map((b) => b.rect.padded()).toList(),
      matchedTexts: selected.map((b) => b.text).toList(),
    );
  }

  static bool _rectsAlmostSame(MindMapRect a, MindMapRect b, {double eps = 0.01}) {
    return (a.left - b.left).abs() < eps &&
        (a.top - b.top).abs() < eps &&
        (a.width - b.width).abs() < eps &&
        (a.height - b.height).abs() < eps;
  }

  /// 括弧の条件書きを除いたタイトルを haystack にし、OCR 側の語が含まれるかを見る。
  /// 例: 「動摩擦力と動摩擦係数」→ OCR「動摩擦力」、
  /// 「静止摩擦力と…」→ OCR「例：静止摩擦力，浮力」。
  /// スコアは一致した核の長さ優先（短い「磁場」「反射」より長い語を勝たせる）。
  static List<double> _scoreTitleKeywords(List<_OcrBox> boxes, String title) {
    final withoutParen = title.replaceAll(RegExp(r'[（(].*?[）)]'), '');
    final haystack = _normalize(withoutParen);
    final segments = <String>{};
    if (haystack.length >= 2) segments.add(haystack);
    for (final part in haystack.split(RegExp(r'[と・、，,/／|]'))) {
      final p = part.trim();
      if (p.length >= 2) segments.add(p);
    }

    List<double> scoreWith(String hay, Set<String> segs) {
      final scores = List<double>.filled(boxes.length, 0);
      for (var i = 0; i < boxes.length; i++) {
        final raw = boxes[i].text.trim();
        // 年表の「（ガリレオ）」だけ、のような括弧だけの枠は除外
        if (RegExp(r'^[（(][^）)]+[）)]$').hasMatch(raw)) {
          continue;
        }

        var best = 0.0;
        final boxNorm = _normalize(raw);
        for (final core in _ocrCores(raw)) {
          if (core.length < 2) continue;
          if (hay.contains(core)) {
            final s = 0.55 + 0.45 * (core.length.clamp(1, 8) / 8);
            if (s > best) best = s;
            continue;
          }
          for (final seg in segs) {
            if (seg.length < 3) continue;
            if (!_containsAsTopic(boxNorm, seg) &&
                !_containsAsTopic(core, seg)) {
              continue;
            }
            final longer =
                core.length > seg.length ? core.length : seg.length;
            final s = 0.55 + 0.40 * (seg.length / longer);
            if (s > best) best = s;
          }
        }
        scores[i] = best;
      }
      return scores;
    }

    final primary = scoreWith(haystack, segments);
    if (primary.any((s) => s >= 0.55)) return primary;

    // 括弧の外で当たらないときだけ括弧内（固定端反射など）を使う
    final segs2 = {...segments};
    final hay2Buf = StringBuffer(haystack);
    for (final m in RegExp(r'[（(]([^）)]+)[）)]').allMatches(title)) {
      final inner = _normalize(m.group(1)!);
      if (inner.length >= 3) {
        segs2.add(inner);
        hay2Buf.write(inner);
      }
    }
    return scoreWith(hay2Buf.toString(), segs2);
  }

  /// 「等速円運動」が「非等速円運動」に含まれるような、否定接頭辞つき誤爆を除く。
  static bool _containsAsTopic(String hay, String needle) {
    final idx = hay.indexOf(needle);
    if (idx < 0) return false;
    if (idx > 0 && hay.substring(idx - 1, idx) == '非') return false;
    return true;
  }

  /// OCR 文言から照合用の核を取り出す（装飾・列挙の分割）。
  static List<String> _ocrCores(String text) {
    final n = _normalize(text);
    if (n.isEmpty) return const [];
    final stripped = n
        .replaceFirst(RegExp(r'^[◎©⑥▶→↓★◆・\-–—＼]+'), '')
        .replaceFirst(RegExp(r'^例[：:]'), '');
    final out = <String>[];
    void add(String s) {
      final t = s.trim();
      if (t.isEmpty) return;
      if (!out.contains(t)) out.add(t);
    }

    add(stripped);
    for (final part in stripped.split(RegExp(r'[、，,/／]'))) {
      add(part);
    }
    // 「変位に比例する力…（単振動）」の括弧内
    for (final m in RegExp(r'[（(]([^）)]+)[）)]').allMatches(n)) {
      add(_normalize(m.group(1)!));
    }
    return out;
  }

  static String _normalize(String s) {
    return s
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('　', '')
        .replaceAll(RegExp(r'[【】\[\]「」『』？?]'), '')
        .replaceAll('－', '-')
        .replaceAll('−', '-')
        .replaceAll('，', '、')
        .toLowerCase();
  }

  static double _score(String query, String text) {
    if (query.isEmpty || text.isEmpty) return 0;
    if (query == text) return 1.0;
    // 上書き対応表用: 短い汎用語の部分一致は抑える
    if (query.length <= 2 && text != query) {
      return text.contains(query) ? 0.5 : 0;
    }
    if (query.contains(text) || text.contains(query)) {
      final shorter = query.length < text.length ? query.length : text.length;
      final longer = query.length > text.length ? query.length : text.length;
      return 0.7 + 0.25 * (shorter / longer);
    }
    final qSet = query.split('').toSet();
    final tSet = text.split('').toSet();
    final inter = qSet.intersection(tSet).length;
    final union = qSet.union(tSet).length;
    if (union == 0) return 0;
    final jaccard = inter / union;
    return jaccard >= 0.7 ? jaccard * 0.6 : 0;
  }
}

/// 理論記事と同じ見た目: 全体像 + 赤枠（薄い塗り・角丸）+ キャプション。
class MindMapPositionBanner extends StatelessWidget {
  final MindMapHighlightData data;
  final double widthFactor;

  const MindMapPositionBanner({
    super.key,
    required this.data,
    this.widthFactor = 0.58,
  });

  static const _caption = '全体像と本内容の位置付け';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MindMapHighlightFullscreenPage(data: data),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FractionallySizedBox(
                widthFactor: widthFactor,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: MindMapHighlightImage(data: data, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            _caption,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

/// 画像の実描画矩形に正規化座標を乗せる。ズーム／レターボックスでも枠が画像に追従する。
class MindMapHighlightImage extends StatefulWidget {
  final MindMapHighlightData data;
  final BoxFit fit;

  const MindMapHighlightImage({
    super.key,
    required this.data,
    this.fit = BoxFit.contain,
  });

  /// [BoxFit] 後に画像が実際に占める矩形（親座標系）。
  static Rect imageDestinationRect({
    required Size layoutSize,
    required Size imageSize,
    required BoxFit fit,
  }) {
    final fitted = applyBoxFit(fit, imageSize, layoutSize);
    return Alignment.center.inscribe(
      fitted.destination,
      Offset.zero & layoutSize,
    );
  }

  @override
  State<MindMapHighlightImage> createState() => _MindMapHighlightImageState();
}

class _MindMapHighlightImageState extends State<MindMapHighlightImage> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  Size? _imageSize;

  @override
  void initState() {
    super.initState();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant MindMapHighlightImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.imageAsset != widget.data.imageAsset) {
      _resolveImage();
    }
  }

  @override
  void dispose() {
    _detachStream();
    super.dispose();
  }

  void _detachStream() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    _stream = null;
    _listener = null;
  }

  void _resolveImage() {
    _detachStream();
    final provider = AssetImage(widget.data.imageAsset);
    final stream = provider.resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener((info, _) {
      final size = Size(
        info.image.width.toDouble(),
        info.image.height.toDouble(),
      );
      if (!mounted) return;
      if (_imageSize != size) {
        setState(() => _imageSize = size);
      }
    }, onError: (error, stack) {
      debugPrint('MindMapHighlightImage load error: $error');
    });
    stream.addListener(listener);
    _stream = stream;
    _listener = listener;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = Size(
          constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width,
          constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : MediaQuery.sizeOf(context).height,
        );
        // 画像サイズ未取得時も 16:9 仮置きでレイアウトし、取得後に正確化
        final imageSize = _imageSize ?? const Size(16, 9);
        final dest = MindMapHighlightImage.imageDestinationRect(
          layoutSize: layout,
          imageSize: imageSize,
          fit: widget.fit,
        );

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fromRect(
              rect: dest,
              // この箱 ＝ 画像そのもの。枠も同じ箱の 0〜1 で描くので必ず追従する。
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    widget.data.imageAsset,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.medium,
                  ),
                  CustomPaint(
                    painter: _MindMapRectPainter(rects: widget.data.rects),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MindMapRectPainter extends CustomPainter {
  final List<MindMapRect> rects;

  _MindMapRectPainter({required this.rects});

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color.fromARGB(80, 255, 180, 180);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color.fromARGB(255, 255, 0, 0);

    for (final rect in rects) {
      final box = Rect.fromLTWH(
        rect.left * size.width,
        rect.top * size.height,
        rect.width * size.width,
        rect.height * size.height,
      );
      final radius = (box.shortestSide * 0.12).clamp(4.0, 16.0);
      final r = RRect.fromRectAndRadius(box, Radius.circular(radius));
      canvas.drawRRect(r, fill);
      canvas.drawRRect(r, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _MindMapRectPainter oldDelegate) {
    if (oldDelegate.rects.length != rects.length) return true;
    for (var i = 0; i < rects.length; i++) {
      if (oldDelegate.rects[i] != rects[i]) return true;
    }
    return false;
  }
}

class MindMapHighlightFullscreenPage extends StatefulWidget {
  final MindMapHighlightData data;

  const MindMapHighlightFullscreenPage({super.key, required this.data});

  @override
  State<MindMapHighlightFullscreenPage> createState() =>
      _MindMapHighlightFullscreenPageState();
}

class _MindMapHighlightFullscreenPageState
    extends State<MindMapHighlightFullscreenPage> {
  final _viewerKey = GlobalKey();
  final _transformController = TransformationController();
  double _scale = 1.0;

  static const _minScale = 1.0;
  static const _maxScale = 6.0;
  static const _zoomStep = 0.5;

  @override
  void initState() {
    super.initState();
    _transformController.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _transformController.removeListener(_onTransformChanged);
    _transformController.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final next = _transformController.value.getMaxScaleOnAxis();
    if ((next - _scale).abs() > 0.01) {
      setState(() => _scale = next);
    }
  }

  Size _viewerSize() {
    final box = _viewerKey.currentContext?.findRenderObject() as RenderBox?;
    return box?.size ?? MediaQuery.sizeOf(context);
  }

  void _applyScale(double nextScale) {
    final current = _transformController.value.getMaxScaleOnAxis();
    final next = nextScale.clamp(_minScale, _maxScale);
    if ((next - current).abs() < 0.001) return;

    final size = _viewerSize();
    final focal = Offset(size.width / 2, size.height / 2);
    final sceneFocal = _transformController.toScene(focal);

    _transformController.value = Matrix4.identity()
      ..translateByDouble(focal.dx, focal.dy, 0, 1)
      ..scaleByDouble(next, next, 1, 1)
      ..translateByDouble(-sceneFocal.dx, -sceneFocal.dy, 0, 1);

    setState(() => _scale = next);
  }

  @override
  Widget build(BuildContext context) {
    final canZoomOut = _scale > _minScale + 0.01;
    final canZoomIn = _scale < _maxScale - 0.01;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('全体像と本内容の位置付け'),
      ),
      body: Stack(
        key: _viewerKey,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return InteractiveViewer(
                transformationController: _transformController,
                minScale: _minScale,
                maxScale: _maxScale,
                boundaryMargin: EdgeInsets.zero,
                clipBehavior: Clip.hardEdge,
                // 画像＋枠を同じ SizedBox 内に置き、Viewer の変換を共有する。
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: MindMapHighlightImage(
                    data: widget.data,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
          Positioned(
            right: 16,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MindMapZoomButton(
                  icon: Icons.add,
                  enabled: canZoomIn,
                  onPressed: () => _applyScale(_scale + _zoomStep),
                ),
                const SizedBox(height: 8),
                _MindMapZoomButton(
                  icon: Icons.remove,
                  enabled: canZoomOut,
                  onPressed: () => _applyScale(_scale - _zoomStep),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MindMapZoomButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  const _MindMapZoomButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: enabled ? 0.22 : 0.1),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }
}

/// VideoDetail 用: OCR マッチできればバナーを出す。
class VideoMindMapBanner extends StatefulWidget {
  final String category;
  final String title;
  final String? mindMapQuery;

  const VideoMindMapBanner({
    super.key,
    required this.category,
    required this.title,
    this.mindMapQuery,
  });

  @override
  State<VideoMindMapBanner> createState() => _VideoMindMapBannerState();
}

class _VideoMindMapBannerState extends State<VideoMindMapBanner> {
  late final Future<MindMapHighlightData?> _future;

  @override
  void initState() {
    super.initState();
    _future = MindMapHighlightResolver.instance.resolve(
      category: widget.category,
      title: widget.title,
      query: widget.mindMapQuery,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MindMapHighlightData?>(
      future: _future,
      builder: (context, snap) {
        final data = snap.data;
        if (data == null) return const SizedBox.shrink();
        return MindMapPositionBanner(data: data);
      },
    );
  }
}
