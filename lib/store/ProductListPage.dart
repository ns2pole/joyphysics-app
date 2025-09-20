import '../../model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:joyphysics/experiment/ExperimentView.dart';
import 'package:joyphysics/dataExporter.dart';


class ProductListPage extends StatelessWidget {
  ProductListPage({super.key});

  final List<Product> products = [
    Product(
      title: 'オシロスコープ',
      url: 'https://amzn.to/4gy0h9l',
      imageUrl: 'assets/goods/oscilloscope.png',
      price: '約4,000円',
      rating: 2,
      description: '数千円するが波形を観測できる。回路の実験で活躍する。',
      videos: [rcCircuit],
    ),
    Product(
      title: 'ニュートンメーター',
      url: 'https://amzn.to/4nwclL7',
      imageUrl: 'assets/goods/newtonmeter.png',
      price: '約5,000円',
      rating: 2,
      description: '力を測れる。グラム表示も可能。',
      videos: [fook],
    ),
    Product(
      title: '磁場測定器',
      url: 'https://amzn.to/4mmRVmb',
      imageUrl: 'assets/goods/teslameter.png',
      price: '約13,000円',
      rating: 1,
      description: '磁場(磁束密度B)が測れる。スマホで測ると壊れそうな磁場でもこれで測れる。',
      videos: [neodymiumMagnetFieldMeasurement, magneticFieldCircularLoop, solenoidMagneticField],
    ),
  ];

  Future<void> _openExternalUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final can = await canLaunchUrl(uri);
    debugPrint('canLaunch: $can for $url');

    if (!can) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('リンクを開けませんでした（端末に対応アプリが見つかりません）。')),
      );
      return;
    }

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      debugPrint('launchUrl returned: $launched for $url');
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('外部アプリで開けませんでした。端末設定を確認してください。')),
        );
      }
    } catch (e, st) {
      debugPrint('launch error: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('リンクを開く際にエラーが発生しました')),
      );
    }
  }

  Widget _buildRatingStars(int rating) {
    final r = rating.clamp(0, 3).toInt();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Icon(i < r ? Icons.star : Icons.star_border, size: 18, color: Colors.amber);
      }),
    );
  }

Widget _buildProductImageWithAttribution(String? imageUrl, String? attribution, String? sourceUrl) {
  const double w = 120, h = 135;
  // 見た目調整用：外枠半径と内側パディング
  final outerRadius = BorderRadius.circular(12);
  const double inset = 4.0; // ← ここを大きくすると画像が内側に縮まり、元画像の四角い余白が見えにくくなる

  Widget imageBox;
  if (imageUrl == null || imageUrl.trim().isEmpty) {
    // プレースホルダも同じ構造にする
    imageBox = ClipRRect(
      borderRadius: outerRadius,
      child: Container(
        width: w,
        height: h,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(inset),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(outerRadius.topLeft.x - inset),
            child: Container(
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: const Icon(Icons.image_not_supported, size: 36, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  } else {
    final trimmed = imageUrl.trim();
    final lower = trimmed.toLowerCase();
    Widget inner;
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      inner = Image.network(
        trimmed,
        width: w - inset * 2,
        height: h - inset * 2,
        fit: BoxFit.cover, // 重要：必ずボックスを埋める
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (context, error, stack) {
          return Container(
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image, size: 36, color: Colors.grey),
          );
        },
      );
    } else {
      inner = Image.asset(
        trimmed,
        width: w - inset * 2,
        height: h - inset * 2,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) {
          return Container(
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image, size: 36, color: Colors.grey),
          );
        },
      );
    }

    imageBox = ClipRRect(
      borderRadius: outerRadius,
      child: Container(
        width: w,
        height: h,
        color: Colors.transparent, // 親カードの背景に馴染ませたい場合は Colors.white ではなく transparent に
        child: Padding(
          padding: const EdgeInsets.all(inset),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12 - inset),
            child: SizedBox(
              width: w - inset * 2,
              height: h - inset * 2,
              child: inner,
            ),
          ),
        ),
      ),
    );
  }

  // Attribution は元のまま
  Widget attributionWidget = const SizedBox.shrink();
  if ((attribution ?? '').isNotEmpty || (sourceUrl ?? '').isNotEmpty) {
    attributionWidget = Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: GestureDetector(
        onTap: () {
          if ((sourceUrl ?? '').isNotEmpty) launchUrl(Uri.parse(sourceUrl!));
        },
        child: RichText(
          text: TextSpan(
            children: [
              if ((attribution ?? '').isNotEmpty)
                TextSpan(
                  text: attribution,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              if ((attribution ?? '').isNotEmpty && (sourceUrl ?? '').isNotEmpty)
                const TextSpan(text: '  '),
              if ((sourceUrl ?? '').isNotEmpty)
                TextSpan(
                  text: '(出典)',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade700, decoration: TextDecoration.underline),
                ),
            ],
          ),
        ),
      ),
    );
  }

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      imageBox,
      attributionWidget,
    ],
  );
}

  void _onVideoTap(BuildContext context, dynamic item) {
    try {
      if (item == null) return;

      if (item is Video) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => VideoDetailView(video: item)));
        return;
      }
      if (item is String) {
        _openExternalUrl(context, item);
        return;
      }
      if (item is Map) {
        if (item['video'] is Video) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => VideoDetailView(video: item['video'])));
          return;
        }
        final url = item['url'] ?? item['videoURL'] ?? item['link'];
        if (url is String && url.isNotEmpty) {
          _openExternalUrl(context, url);
          return;
        }
      }
    } catch (e, st) {
      debugPrint('video tap error: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('動画リンクを開けませんでした')));
    }
  }

  String _videoLabel(dynamic item) {
    if (item == null) return '動画';
    if (item is Video) return item.title ?? '動画';
    if (item is String) return item;
    if (item is Map) {
      if (item['title'] is String && (item['title'] as String).isNotEmpty) return item['title'];
      if (item['label'] is String) return item['label'];
      final url = item['url'] ?? item['videoURL'] ?? item['link'];
      if (url is String) return url;
    }
    return '動画';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('おすすめ実験グッズ')),
      body: Column(
        children: [
          // --- ページ最初のアフィリエイト注意書き
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                  color: Colors.yellow.shade50, // ←薄め
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.yellow.shade300), // ←柔らかめの枠
            ),
            child: const Text(
              '※このページのリンクはアフィリエイトです。購入されると運営者に報酬が入ります。',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          // --- 残りは既存の ListView.builder
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                final videos = (p.videos is List) ? (p.videos as List).cast<dynamic>() : <dynamic>[];

                // ここから下は既存のコードをそのまま
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- 上段: 画像 + タイトル/価格/評価/Amazonボタン
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProductImageWithAttribution(p.imageUrl, p.imageAttribution, p.imageSourceUrl),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text('おすすめ度', style: TextStyle(fontSize: 14)),
                                      const SizedBox(width: 8),
                                      _buildRatingStars(p.rating),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      if (p.price != null) Text(p.price!, style: const TextStyle(fontSize: 18)),
                                      const Spacer(),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.shopping_cart_outlined),
                                          label: const Text('Amazonで見る'),
                                          onPressed: () {
                                            if (p.url.isNotEmpty) _openExternalUrl(context, p.url);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // --- 商品説明タイトル（角丸枠）
                        if ((p.description ?? '').isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400, width: 1),
                            ),
                            child: const Text(
                              '商品説明',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),

                        // --- 商品説明本文
                        if ((p.description ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            p.description!,
                            style: const TextStyle(fontSize: 17, color: Colors.black87, height: 1.4),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        // --- 関連実験動画タイトル（角丸枠）
                        if (videos.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400, width: 1),
                            ),
                            child: const Text(
                              '関連実験動画',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 4),

                          // --- 動画ボタン
                          LayoutBuilder(builder: (context, constraints) {
                            final available = constraints.maxWidth;
                            final buttonWidth = available * 0.9;
                            return Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: videos.map((videoItem) {
                                final label = _videoLabel(videoItem);
                                return SizedBox(
                                  width: buttonWidth,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.play_circle_outline),
                                    label: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(fontSize: 16)),
                                    ),
                                    onPressed: () => _onVideoTap(context, videoItem),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      alignment: Alignment.centerLeft,
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}