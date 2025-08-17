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
        debugShowCheckedModeBanner: false, // ← ここで設定
        title: '実験で学ぶ高校物理',
        theme: ThemeData(
          // フォントファミリーを指定
          fontFamily: 'Quicksand', // ここでカスタムフォント名を指定
          primarySwatch: Colors.blue),
          home: ContentView(),
      );
}


class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Image.asset('assets/init/profile_arrange.png', width: 120, height: 80),
          SizedBox(height: 4),
          Text('実験で学ぶ高校物理',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      );
}
class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Text('Updated: 2025/08/17  Version 2.1.0', style: TextStyle(fontSize: 20, color: Colors.black)),
      );
}


class CategoryList extends StatelessWidget {
  final List<Category> categories;
  const CategoryList({Key? key, required this.categories}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // ホームに追加したい理論ボタン
    final theoryButtons = [
      {
        'name': '物理のための数学',
        'gif': 'assets/init/number.gif',
        'page': TheoryListView(categoryName: '物理のための数学'),
      },
      // {
      //   'name': '力学理論',
      //   'gif': 'assets/init/dynamics.gif',
      //   'page': TheoryListView(categoryName: '力学理論'),
      // },
      {
        'name': '電磁気学理論',
        'gif': 'assets/init/electromag.gif',
        'page': TheoryListView(categoryName: '電磁気学理論'),
      },
    ];

    final totalCount = categories.length + theoryButtons.length + 2;

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (index >= categories.length && index < categories.length + theoryButtons.length) {
          // 理論ボタン
          final tb = theoryButtons[index - categories.length];
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 75),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => tb['page'] as Widget),
              ),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green[300]?.withOpacity(0.9), // ← 少し明るめ・透明度も少し下げる
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
        }

        if (index == totalCount - 2) {
          // 「センサーを使う」ボタン
          return Padding(
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
        }

        if (index == totalCount - 1) {
          // 「アプリについて」ボタン
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 75),
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

        // 実験系カテゴリー
        final cat = categories[index];
        return Padding(
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
      },
    );
  }
}

class ContentView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/init/init.png', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.white.withOpacity(0.7))),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 20),
                _Header(),
                Expanded(
                  child: CategoryList(categories: categoriesData),
                ),
                _Footer(),
              ],
            ),
          ),
        ],
      ),
    );
}