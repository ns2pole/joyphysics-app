import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/sensorArticlesData.dart';
import 'package:joyphysics/model.dart';
import 'package:joyphysics/search/article_search_page.dart';
import 'package:joyphysics/search/searchable_articles.dart';

Video _video({
  required String title,
  bool inPreparation = false,
  String videoURL = 'abcdEFGhi12',
  List<Widget>? experimentWidgets,
}) {
  return Video(
    category: 'dynamics',
    iconName: '',
    title: title,
    videoURL: videoURL,
    equipment: const [],
    costRating: '★',
    inPreparation: inPreparation,
    experimentWidgets: experimentWidgets,
  );
}

Category _category(String name, List<Video> videos) {
  return Category(
    name: name,
    gifUrl: '',
    subcategories: [Subcategory(name: 'テスト', videos: videos)],
  );
}

void main() {
  testWidgets('検索画面へ切り替わったあと入力欄にフォーカスが残る', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: HomeArticleSearchBox())),
    );

    await tester.tap(find.text('キーワード検索'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
    expect(tester.testTextInput.isVisible, isTrue);
    expect(
      tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
      isTrue,
    );

    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.testTextInput.isVisible, isTrue);
    expect(
      tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
      isTrue,
    );
  });

  test('「落下」は「自由落下」にヒットする', () {
    final articles = flattenSearchableArticles([
      _category('力学', [_video(title: '自由落下'), _video(title: '円運動')]),
    ]);

    final results = filterArticlesByTitle(articles, '落下');
    expect(results.map((a) => a.video.title), ['自由落下']);
    expect(results.single.categoryName, '力学');
  });

  test('英数字は大小を無視して絞り込む', () {
    final articles = flattenSearchableArticles([
      _category('電磁気学', [_video(title: 'RC回路')]),
    ]);

    expect(filterArticlesByTitle(articles, 'rc').map((a) => a.video.title), [
      'RC回路',
    ]);
    expect(filterArticlesByTitle(articles, 'Rc').map((a) => a.video.title), [
      'RC回路',
    ]);
  });

  test('空クエリは 0 件', () {
    final articles = flattenSearchableArticles([
      _category('力学', [_video(title: '自由落下')]),
    ]);

    expect(filterArticlesByTitle(articles, ''), isEmpty);
    expect(filterArticlesByTitle(articles, '   '), isEmpty);
  });

  test('準備中と空コンテンツは候補から除外する', () {
    final usable = _video(title: '自由落下');
    final preparing = _video(title: '準備中の落下', inPreparation: true);
    final empty = _video(title: '中身のない落下', videoURL: '');
    final placeholderUrl = _video(title: 'プレースホルダの落下', videoURL: '（動画URLをここに）');
    final widgetOnly = _video(
      title: 'ウィジェットだけの落下',
      videoURL: '',
      experimentWidgets: const [SizedBox.shrink()],
    );

    final articles = flattenSearchableArticles([
      _category('力学', [usable, preparing, empty, placeholderUrl, widgetOnly]),
    ]);

    expect(articles.map((a) => a.video.title), ['自由落下', 'ウィジェットだけの落下']);
    expect(filterArticlesByTitle(articles, '落下').map((a) => a.video.title), [
      '自由落下',
      'ウィジェットだけの落下',
    ]);
  });

  test('単元の並びを保ったままカテゴリ帯用にグループ化する', () {
    final articles = flattenSearchableArticles([
      _category('力学', [_video(title: '自由落下'), _video(title: '円運動')]),
      _category('電磁気学', [_video(title: 'RC回路')]),
      _category('波動', [_video(title: '定常波')]),
    ]);

    final groups = groupArticlesByCategory(articles);

    expect(groups.map((g) => g.categoryName), ['力学', '電磁気学', '波動']);
    expect(groups[0].articles.map((a) => a.video.title), ['自由落下', '円運動']);
    expect(groups[1].articles.map((a) => a.video.title), ['RC回路']);
    expect(groups[2].articles.map((a) => a.video.title), ['定常波']);
  });

  test('同じ Video が複数カテゴリにあっても一度だけ出す', () {
    final shared = _video(title: '磁場の測定');
    final articles = flattenSearchableArticles([
      _category('電磁気学', [shared]),
      _category('センサー', [shared]),
    ]);

    expect(articles, hasLength(1));
    expect(articles.single.categoryName, '電磁気学');
  });

  test('センサー記事はセンサー帯に入り、センサー名でもヒットする', () {
    final gyro = _video(title: '角速度の測定');
    final articles = flattenAllSearchableArticles(
      [
        _category('力学', [_video(title: '自由落下')]),
      ],
      {
        'ジャイロセンサー': [gyro],
      },
    );

    expect(articles.map((a) => a.video.title), ['自由落下', '角速度の測定']);
    expect(articles.last.categoryName, 'センサー');
    expect(filterArticlesByTitle(articles, 'ジャイロ').map((a) => a.video.title), [
      '角速度の測定',
    ]);
    expect(filterArticlesByTitle(articles, 'センサー').map((a) => a.video.title), [
      '角速度の測定',
    ]);
    expect(filterArticlesByTitle(articles, '角速度').map((a) => a.video.title), [
      '角速度の測定',
    ]);
  });

  test('カテゴリ名でも絞り込める', () {
    final articles = flattenSearchableArticles([
      _category('力学', [_video(title: '自由落下')]),
      _category('電磁気学', [_video(title: 'RC回路')]),
    ]);

    expect(filterArticlesByTitle(articles, '力学').map((a) => a.video.title), [
      '自由落下',
    ]);
  });

  test('単元名でもその単元の記事が全てヒットする', () {
    final articles = flattenSearchableArticles([
      Category(
        name: '力学',
        gifUrl: '',
        subcategories: [
          Subcategory(
            name: '滑車',
            videos: [
              _video(title: 'アトウッドの器械'),
              _video(title: '定滑車と動滑車'),
            ],
          ),
          Subcategory(
            name: '摩擦',
            videos: [_video(title: '静止摩擦')],
          ),
        ],
      ),
    ]);

    expect(filterArticlesByTitle(articles, '滑車').map((a) => a.video.title), [
      'アトウッドの器械',
      '定滑車と動滑車',
    ]);
    expect(filterArticlesByTitle(articles, '摩擦').map((a) => a.video.title), [
      '静止摩擦',
    ]);
  });

  test('実データの滑車と剛体は単元名で全件出る', () {
    final articles = flattenAllSearchableArticles(
      categoriesData,
      sensorArticlesByCategory,
      sensorCategoryName: kSensorCategoryName,
    );

    expect(
      filterArticlesByTitle(articles, '滑車').map((a) => a.video.title),
      contains('定滑車(アトウッドの器械)'),
    );
    expect(
      filterArticlesByTitle(articles, '剛体').map((a) => a.video.title),
      containsAll(['片側持ち上げ', '積み木']),
    );
    expect(
      filterArticlesByTitle(
        articles,
        '力学',
      ).where((a) => a.categoryName == '力学').map((a) => a.video.title),
      containsAll(['定滑車(アトウッドの器械)', '片側持ち上げ', '積み木']),
    );
  });

  test('センサー記事が力学側にもあるときは力学側だけ出す', () {
    final shared = _video(title: '磁場の測定');
    final articles = flattenAllSearchableArticles(
      [
        _category('電磁気学', [shared]),
      ],
      {
        '磁気センサー': [shared],
      },
    );

    expect(articles, hasLength(1));
    expect(articles.single.categoryName, '電磁気学');
  });

  test('実データの検索にジャイロと加速度が入る', () {
    final articles = flattenAllSearchableArticles(
      categoriesData,
      sensorArticlesByCategory,
      sensorCategoryName: kSensorCategoryName,
    );

    expect(filterArticlesByTitle(articles, 'ジャイロ').map((a) => a.video.title), [
      '角速度の測定',
    ]);
    expect(
      filterArticlesByTitle(articles, '加速度センサー').map((a) => a.video.title),
      ['加速度の測定'],
    );
    expect(
      filterArticlesByTitle(articles, '速度測定').map((a) => a.video.title),
      contains('動く物体による反射と速度測定'),
    );
    expect(
      filterArticlesByTitle(articles, '動く物体').map((a) => a.video.title),
      contains('動く物体による反射と速度測定'),
    );
    expect(
      filterArticlesByTitle(articles, 'センサー')
          .where((a) => a.categoryName == kSensorCategoryName)
          .map((a) => a.video.title),
      containsAll(['加速度の測定', '角速度の測定', '1階と2階での大気圧の測定', '磁場の測定']),
    );
  });

  test('ドップラー効果に動く物体の反射と速度測定があり、Shorts の ID を持つ', () {
    final waves = categoriesData.firstWhere((c) => c.name == '波動');
    final doppler = waves.subcategories.firstWhere((s) => s.name == 'ドップラー効果');
    expect(doppler.videos.map((v) => v.title), contains('動く物体による反射と速度測定'));
    final article = doppler.videos.firstWhere(
      (v) => v.title == '動く物体による反射と速度測定',
    );
    expect(article.videoURL, 'C6Mq7apCUcU');
    expect(article.playsSound, isFalse);
    expect(article.warnsHighPitchSound, isTrue);
    expect(article.latex, contains('f_{\\mathrm{ref}}'));
    expect(
      extractVideoId('https://www.youtube.com/shorts/C6Mq7apCUcU'),
      'C6Mq7apCUcU',
    );
  });
}
