// main.dart
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:joyphysics/theory/theoryData.dart';
import 'package:joyphysics/theory/TheoryView.dart';
import 'package:joyphysics/update_checker.dart';
import 'package:joyphysics/experiment/ExperimentView.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/sensorListView.dart';
import 'package:joyphysics/store/ProductListPage.dart';
import 'package:joyphysics/aboutView.dart';
import 'package:joyphysics/model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'update_checker.dart'; // UpdateChecker (navigatorKey を受け取る実装にする)
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:joyphysics/dataExporter.dart' show thinFilmInterference1D;

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

        ],
      );
}


class CategoryList extends StatelessWidget {
  final List<Category> categories;
  const CategoryList({Key? key, required this.categories}) : super(key: key);

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
    // +3 = (スマホセンサー記事のテキスト, 解説記事のテキスト, 理論記事のテキスト)
    // +1 = 物販ボタン
    // アプリについてボタンは非表示
    final totalCount = categories.length + 0 + 5; // theoryButtons.length を 0 に変更、アプリについてボタンを非表示

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
        // ---------- 先頭部分 ----------
        if (index == 1) {
          return _buildInfoText('スマホセンサーを活用！');
        }
        if (index == 2) {
          return _buildSensorButton(context);
        }
        if (index == 3) {
          return _buildInfoText('実験&アニメーション記事');
        }

        final adjustedIndex = index - 4;

        // ---------- 実験カテゴリ ----------
        if (adjustedIndex < categories.length) {
          final cat = categories[adjustedIndex];
          // 「熱力学」の場合は下に物販ボタンを追加
          if (cat.name == '熱力学') {
            return Column(
              children: [
                _buildCategoryButton(context, cat),
                SizedBox(height: 16),
                _buildShopButton(context),
              ],
            );
          }
          return _buildCategoryButton(context, cat);
        }

        // ---------- 理論記事 ----------
        // final theoryIndex = adjustedIndex - categories.length;
        // if (theoryIndex == 0) {
        //   return _buildInfoText('理論記事45本 掲載中！');
        // }
        // if (theoryIndex >= 1 && theoryIndex <= theoryButtons.length) {
        //   final tb = theoryButtons[theoryIndex - 1];
        //   return _buildTheoryButton(context, tb);
        // }

        // ---------- アプリについて ----------
        // アプリについてボタンは非表示
        // if (index == totalCount - 1) {
        //   return _buildAboutButton(context);
        // }

        return SizedBox.shrink();
      },
    );
  }
    // ---------------- UI ビルダー ----------------
    Widget _buildShopButton(BuildContext context) => Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 75),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductListPage()),
        ),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            // グラデーションを止めて単色の水色に変更
            color: Color(0xFF64B5F6), // ← 水色（必要なら別の16進値に変えてください）
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_basket_outlined, color: Colors.white, size: 28),
              SizedBox(width: 10),
              Text(
                '実験グッズ',
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

  Widget _buildInfoText(String text) => Padding(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 40),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ),
        ),
      );

  Widget _buildSensorButton(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 75),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SensorListView()),
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
              children: [
                Icon(Icons.sensors, color: Colors.white, size: 35),
                SizedBox(width: 8),
                Text(
                  'センサーを使う！',
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
              color: Color(0xFFC3734F).withOpacity(0.95),
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
                    fontSize: 24,
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
