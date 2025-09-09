// main.dart
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:joyphysics/theory/theoryData.dart';
import 'package:joyphysics/theory/TheoryView.dart';
import 'package:joyphysics/experiment/ExperimentView.dart';
import 'package:joyphysics/experiment/categoriesData.dart';
import 'package:joyphysics/experiment/sensorListView.dart';
import 'package:joyphysics/aboutView.dart';
import 'package:joyphysics/model.dart';

void main() => runApp(JoyPhysicsApp());

class JoyPhysicsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '実験で学ぶ高校物理',
        theme: ThemeData(
          fontFamily: 'Quicksand',
          primarySwatch: Colors.blue,
        ),
        home: ContentView(),
      );
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Image.asset('assets/init/profile_arrange.png', width: 90, height: 60),
          SizedBox(height: 4),
          Text('実験で学ぶ高校物理',
              style: TextStyle(
                  fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      );
}

/// フッター（更新日情報）
class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            'Updated: 2025/09/09  Version 2.3.2',
            style: TextStyle(fontSize: 17, color: Colors.black54),
          ),
        ),
      );
}

class CategoryList extends StatelessWidget {
  final List<Category> categories;
  const CategoryList({Key? key, required this.categories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theoryButtons = [
      {
        'name': '物理のための数学',
        'gif': 'assets/init/number.gif',
        'page': TheoryListView(categoryName: '物理のための数学'),
      },
      {
        'name': '力学理論',
        'gif': 'assets/init/dynamics.gif',
        'page': TheoryListView(categoryName: '力学理論'),
      },
      {
        'name': '電磁気学理論',
        'gif': 'assets/init/electromag.gif',
        'page': TheoryListView(categoryName: '電磁気学理論'),
      },
    ];

    // +3 = (スマホセンサー記事のテキスト, 解説記事のテキスト, 理論記事のテキスト)
    final totalCount = categories.length + theoryButtons.length + 3 + 2; 
    // +1 は「アプリについて」ボタン
    // +1 さらにフッター

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: totalCount + 1, // フッター分を追加
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildInfoText('スマホセンサーだけでできる\n実験記事8本掲載中！');
        }
        if (index == 1) {
          return _buildSensorButton(context);
        }
        if (index == 2) {
          return _buildInfoText('実験&解説記事 46本掲載中！');
        }

        final adjustedIndex = index - 3;

        if (adjustedIndex < categories.length) {
          final cat = categories[adjustedIndex];
          return _buildCategoryButton(context, cat);
        }

        // 理論記事案内
        final theoryIndex = adjustedIndex - categories.length;
        if (theoryIndex == 0) {
          return _buildInfoText('理論記事38本掲載中！');
        }

        if (theoryIndex >= 1 && theoryIndex <= theoryButtons.length) {
          final tb = theoryButtons[theoryIndex - 1];
          return _buildTheoryButton(context, tb);
        }

        // 最後から2つ目は「アプリについて」
        if (index == totalCount - 1) {
          return _buildAboutButton(context);
        }

        // 最後はフッター
        return _Footer();
      },
    );
  }

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
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
                    fontSize: 22,
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
                    fontSize: 22,
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
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
              child: Column(
                children: [
                  SizedBox(height: 20),
                  _Header(),
                  Expanded(
                    child: CategoryList(categories: categoriesData),
                  ),
                  // ← Footer は削除
                ],
              ),
            ),
          ],
        ),
      );
}
