// main.dart
import 'package:joyphysics/update_checker.dart';
import 'package:joyphysics/experiment/ExperimentView.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/sensorListView.dart';
import 'package:joyphysics/joy_physics_store_uris.dart';
import 'package:joyphysics/aboutView.dart';
import 'package:joyphysics/model.dart';
import 'package:joyphysics/formulaCollectionView.dart';
import 'package:joyphysics/home_promo_links.dart';
import 'package:joyphysics/search/article_search_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:joyphysics/dataExporter.dart' show thinFilmInterference1D, rainbowDroplet2D, secondaryRainbowDroplet2D, twoBodySpring1D, keplerLaws2D, twoBodyKepler2D, coupledOscillatorTransverse1D, coupledOscillatorLongitudinal1D;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// 共有の navigatorKey を1つだけ作る
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  if (kIsWeb) {
    setUrlStrategy(const HashUrlStrategy());
  }
  runApp(JoyPhysicsApp());

  // runApp の後で非同期にアップデートチェックを開始（postFrame は安全）
  WidgetsBinding.instance.addPostFrameCallback((_) {
    UpdateChecker(
      iosId: '6748957698',
      androidId: 'com.joyphysics',
      skipDays: 3,
      navigatorKey: appNavigatorKey,      // ← ここを必ず渡す
      // forceShowForDebug: true, // デバッグ時に強制表示したいなら有効化
    ).checkOnAppStart();
  });
}

class JoyPhysicsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        navigatorKey: appNavigatorKey, // ← 同じキーを MaterialApp に渡す
        navigatorObservers: [homeRouteObserver],
        debugShowCheckedModeBanner: false,
        title: 'アニメと実験で学ぶ高校物理',
        theme: ThemeData(
          fontFamily: 'KeiFont',
          primarySwatch: Colors.blue,
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontSize: 18),
          ),
        ),
        onGenerateRoute: (settings) {
          final raw = settings.name ?? '/';
          // HashUrlStrategy では name は通常 '/foo' になるが、念のため repo prefix を除去
          var name = raw;
          if (name.startsWith('/joyphysics-app/')) {
            name = name.substring('/joyphysics-app'.length);
            if (name.isEmpty) name = '/';
          }

          Widget page;
          switch (name) {
            case '/':
              page = ContentView();
              break;
            case '/waves/thin-film-interference-1d':
              page = VideoDetailView(video: thinFilmInterference1D);
              break;
            case '/waves/rainbow-droplet-2d':
              page = VideoDetailView(video: rainbowDroplet2D);
              break;
            case '/waves/secondary-rainbow-droplet-2d':
              page = VideoDetailView(video: secondaryRainbowDroplet2D);
              break;
            case '/dynamics/two-body-spring-1d':
              page = VideoDetailView(video: twoBodySpring1D);
              break;
            case '/dynamics/kepler-laws-2d':
              page = VideoDetailView(video: keplerLaws2D);
              break;
            case '/dynamics/two-body-kepler-2d':
              page = VideoDetailView(video: twoBodyKepler2D);
              break;
            case '/waves/coupled-oscillator-transverse-1d':
              page = VideoDetailView(video: coupledOscillatorTransverse1D);
              break;
            case '/waves/coupled-oscillator-longitudinal-1d':
              page = VideoDetailView(video: coupledOscillatorLongitudinal1D);
              break;
            default:
              page = ContentView();
              break;
          }
          return MaterialPageRoute(builder: (_) => page, settings: settings);
        },
      );
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
        children: [
          const TutoringPromoLink(),
          const SizedBox(height: 6),
          Image.asset('assets/init/profile_arrange.png', width: 90, height: 60),
          SizedBox(height: 4),
          Text('アニメと実験で学ぶ',
              style: TextStyle(
                      fontFamily: 'KeiFont',fontSize: 34,  color: Colors.black
                  ),),
          Text('高校物理',
          style: TextStyle(
                  fontFamily: 'KeiFont',fontSize: 34, color: Colors.black,
                  height: 1.0, // 行間を揃える
                  )),
          const SizedBox(height: 6),
          const _AppVersionLabel(),
        ],
      );
}

class _AppVersionLabel extends StatefulWidget {
  const _AppVersionLabel();

  @override
  State<_AppVersionLabel> createState() => _AppVersionLabelState();
}

class _AppVersionLabelState extends State<_AppVersionLabel> {
  late final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: _packageInfo,
      builder: (context, snapshot) {
        final version = snapshot.data?.version;
        if (version == null || version.isEmpty) {
          return const SizedBox.shrink();
        }
        return Text(
          'ver $version',
          style: const TextStyle(
            fontFamily: 'KeiFont',
            fontSize: 13,
            color: Colors.black45,
            height: 1.0,
          ),
        );
      },
    );
  }
}


class CategoryList extends StatelessWidget {
  final List<Category> categories;
  const CategoryList({Key? key, required this.categories}) : super(key: key);

  static final Uri _appStoreUri = JoyPhysicsStoreUris.appStore;
  static final Uri _googlePlayUri = JoyPhysicsStoreUris.googlePlay;

  Future<void> _openStoreLink(Uri uri) async {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
  }

  @override
  Widget build(BuildContext context) {
    // final theoryButtons = [
    //   {
    //     'name': '物理のための数学',
    //     'gif': 'assets/init/number.gif',
    //     'page': TheoryListView(categoryName: '物理のための数学'),
    //   },
    //   {
    //     'name': '力学理論',
    //     'gif': 'assets/init/dynamics.gif',
    //     'page': TheoryListView(categoryName: '力学理論'),
    //   },
    //   {
    //     'name': '電磁気学理論',
    //     'gif': 'assets/init/electromag.gif',
    //     'page': TheoryListView(categoryName: '電磁気学理論'),
    //   },
    //   {
    //     'name': '熱力学理論',
    //     'gif': 'assets/init/fire.gif',
    //     'page': TheoryListView(categoryName: '熱力学理論'),
    //   },
    // ];

    // +1 = ヘッダー
    // +2 = センサー / 公式集
    // +1 = 他アプリ（微積ガチャ / 単位ガチャ）リンク
    final totalCount = categories.length + 4;

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: totalCount,
      itemBuilder: (context, index) {
        // ---------- ヘッダー ----------
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: _Header(),
          );
        }
        if (index == 1) {
          return Column(
            children: [
              const HomeArticleSearchBox(),
              if (kIsWeb) _buildSensorDownloadCta(context),
              _buildSensorButton(context),
            ],
          );
        }
        if (index == 2) {
          return _buildFormulaButton(context);
        }

        final adjustedIndex = index - 3;

        // ---------- 実験カテゴリ ----------
        if (adjustedIndex < categories.length) {
          final cat = categories[adjustedIndex];
          return _buildCategoryButton(context, cat);
        }

        // ---------- 単位ガチャ（末尾） ----------
        if (index == totalCount - 1) {
          return const UnitGachaPromoLink();
        }

        return SizedBox.shrink();
      },
    );
  }
    // ---------------- UI ビルダー ----------------
  Widget _buildSensorDownloadCta(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 40),
        child: Card(
          elevation: 0,
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
      );

  Widget _buildSensorButton(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 75),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SensorListView(),
            ),
          ),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.sensors, color: Colors.white, size: 35),
                SizedBox(width: 8),
                Text(
                  'センサーを使う！',
                  style: TextStyle(
                    fontFamily: 'KeiFont',
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildFormulaButton(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 75),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormulaCollectionView()),
          ),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.functions, color: Colors.white, size: 35),
                SizedBox(width: 8),
                Text(
                  '物理公式集',
                  style: TextStyle(
                    fontFamily: 'KeiFont',
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildCategoryButton(BuildContext context, Category cat) => Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 75),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VideoListView(category: cat)),
          ),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Color(0xFFC3734F).withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(cat.gifUrl, width: 35, height: 35),
                SizedBox(width: 8),
                Text(
                  cat.name,
                  style: TextStyle(
                    fontFamily: 'KeiFont',
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildTheoryButton(BuildContext context, Map<String, Object> tb) =>
      Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 75),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => tb['page'] as Widget),
          ),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.green[300]?.withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(tb['gif'] as String, width: 35, height: 35),
                SizedBox(width: 8),
                Text(
                  tb['name'] as String,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildAboutButton(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 48, horizontal: 75),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AboutView()),
          ),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/init/about.gif', width: 35, height: 35),
                SizedBox(width: 8),
                Text(
                  'アプリについて',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}


class ContentView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
                child: Image.asset('assets/init/init.png', fit: BoxFit.cover)),
            Positioned.fill(
                child: Container(color: Colors.white.withOpacity(0.7))),
            SafeArea(
              child: CategoryList(categories: categoriesData),
            ),
          ],
        ),
      );
}
