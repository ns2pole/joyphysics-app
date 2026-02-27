import 'package:flutter/material.dart';
import 'package:joyphysics/LatexView.dart';
import 'package:joyphysics/dataExporter.dart';
import 'package:joyphysics/model.dart';
import 'package:url_launcher/url_launcher.dart';

class SensorArticlesView extends StatelessWidget {
  const SensorArticlesView({super.key});

  static final Uri _appStoreUri = Uri.parse(
    'https://apps.apple.com/jp/app/%E5%AE%9F%E9%A8%93%E3%81%A7%E5%AD%A6%E3%81%B6%E9%AB%98%E6%A0%A1%E7%89%A9%E7%90%86-%E3%83%BC-joy-physics/id6748957698',
  );
  static final Uri _googlePlayUri = Uri.parse(
    'https://play.google.com/store/apps/details?id=com.joyphysics',
  );

  Future<void> _openStoreLink(Uri uri) async {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
  }

  static final Map<String, List<Video>> _articlesByCategory = {
    '加速度センサー': [accelerometer],
    '気圧センサー': [barometer],
    '磁気センサー': [magnetometer],
    '周波数センサー': [
      frequencyAndDoReMi,
      beat,
      doppler,
      dopplerObserverMoving,
    ],
    '光センサー': [luxMeasurement],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('センサー関係の記事')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            elevation: 0,
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'センサーを使いたい人はこちらから',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Web版ではセンサーが使えません。アプリをダウンロードしてね。',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _openStoreLink(_appStoreUri),
                        icon: const Icon(Icons.apple),
                        label: const Text('App Store'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _openStoreLink(_googlePlayUri),
                        icon: const Icon(Icons.android),
                        label: const Text('Google Play'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ..._articlesByCategory.entries.map((entry) {
            final categoryName = entry.key;
            final videos = entry.value;
            return _ArticleCategoryTile(
              categoryName: categoryName,
              videos: videos,
            );
          }),
        ],
      ),
    );
  }
}

class _ArticleCategoryTile extends StatelessWidget {
  final String categoryName;
  final List<Video> videos;

  const _ArticleCategoryTile({
    required this.categoryName,
    required this.videos,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        leading: const Icon(Icons.menu_book, color: Colors.blue),
        title: Text(
          categoryName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        children: videos
            .map(
              (video) => ListTile(
                title: Text(video.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SensorArticleOnlyView(video: video),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class SensorArticleOnlyView extends StatelessWidget {
  final Video video;

  const SensorArticleOnlyView({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(video.title)),
      body: video.latex == null
          ? const Center(
              child: Text(
                '記事は準備中です。',
                style: TextStyle(color: Colors.black54),
              ),
            )
          : Scrollbar(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: LatexWebView(latexHtml: video.latex!),
              ),
            ),
    );
  }
}

