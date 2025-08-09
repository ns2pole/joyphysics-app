// main.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:joyphysics/data.dart';
import 'package:joyphysics/model.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:joyphysics/waves/LuxMeasurementWidget.dart';
import 'package:joyphysics/dynamics/AccelerometerExperimentWidget.dart';
import 'package:joyphysics/electroMagnetism/MagnetometerExperimentWidget.dart';
import 'package:joyphysics/dynamics/BarometerExperimentWidget.dart';

// 色コードからColor生成拡張
extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    String hex = hexString.replaceFirst('#', '');
    if (hex.length == 3) {
      // RGB (12-bit)
      hex = hex.split('').map((c) => '$c$c').join();
    }
    if (hex.length == 6) buffer.write('ff');
    buffer.write(hex);
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

// 表示モード
enum VideoViewMode { byCategory, byFormula }

class FormulaEntry {
  final String latex; // 数式部分（Math.texで表示）
  final Video relatedVideo;
  final String categoryName;

  FormulaEntry({
    required this.latex,
    required this.relatedVideo,
    required this.categoryName,
  });
}
class Subcategory {
  final String name;
  final List<Video> videos;
  Subcategory({required this.name, required this.videos});
}

class Category {
  final String name;
  final String gifUrl;
  final List<Subcategory> subcategories;
  Category({required this.name, required this.gifUrl, required this.subcategories});
}

final categories = <Category>[
  // 力学
  Category(
    name: '力学',
    gifUrl: 'assets/init/dynamics.gif',
    subcategories: [
      Subcategory(        
        name: '加速度センサー',
        videos: [
          accelerometer
        ],
      ),
      Subcategory(
        name: '色々な力',
        videos: [
          fook,
          staticFriction,
          kineticFriction,
          buoyancyAndActionReaction,
          buoyancyComparison,
          barometer
        ],
      ),
      Subcategory(
        name: '運動方程式',
        videos: [
          freeFall,
          verticalSpringOscillation,
          pendulumPeriodMeasurement,
        ],
      ),
      Subcategory(
        name: '保存則',
        videos: [
          elasticCollision1D,
          elasticCollision2D,
        ],
      ),
      Subcategory(
        name: '剛体',
        videos: [
          oneSideLift,
          buildingBlocksStability,
        ],
      ),
      Subcategory(
        name: 'ケプラーの法則',
        videos: [
          planets,
          moonOrbit,
          jupiter,
        ],
      ),
    ],
  ),

  // 電磁気学
  Category(
    name: '電磁気学',
    gifUrl: 'assets/init/electromag.gif',
    subcategories: [
      Subcategory(
        name: 'コンデンサ',
        videos: [
          capacitorIntroduction,
          parallelPlateCapacitanceMeasurement,
          capacitanceSeriesCombination,
          capacitanceParallelCombination,
          capacitorChargeStorage,
        ],
      ),
      Subcategory(
        name: '抵抗',
        videos: [
          resistanceMeasurement,
          resistanceVsLength,
          seriesResistance,
          parallelResistance,
          resistivityTemperatureDependence,
        ],
      ),
      Subcategory(
        name: '電流',
        videos: [
          lemonBatteryVoltage,
          ohmsLaw,
          rcCircuit,
        ],
      ),
      Subcategory(
        name: '半導体・電子素子',
        videos: [
          diodeIntroduction,
        ],
      ),
      Subcategory(
        name: '磁場',
        videos: [
          magnetometer,
          neodymiumMagnetFieldMeasurement,
          ampereLawTorque,
          magneticFieldCircularLoop,
          solenoidMagneticField,
          lorentzForce,
          forceBetweenParallelCurrents,
          neodymiumMagnetFieldMeasurement,
        ],
      ),
      Subcategory(
        name: 'コイルの性質',
        videos: [
          coilProperties,
          solenoidSelfInductance,
        ],
      ),
      Subcategory(
        name: '磁性体',
        videos: [
          bismuthDiamagnetism,
        ],
      ),
    ],
  ),

  // 波動
  Category(
    name: '波動',
    gifUrl: 'assets/init/wave.gif',
    subcategories: [
      Subcategory(
        name: '音波',
        videos: [
          closedPipeResonance,
          openPipeResonance,
          beat,
          // doppler
        ],
      ),
      Subcategory(
        name: '光波',
        videos: [
          diffractionGrating,
          spectroscopy,
          luxMeasurement
        ],
      ),
    ],
  ),

  // 熱力学
  Category(
    name: '熱力学',
    gifUrl: 'assets/init/fire.gif',
    subcategories: [
      Subcategory(
        name: '気体の法則',
        videos: [
          boyleLaw,
        ],
      ),
    ],
  )
];


final List<FormulaEntry> formulaList = [
  FormulaEntry(
    latex: "f = \\rho g V",
    relatedVideo: buoyancyAndActionReaction,
    categoryName: "浮力・圧力",
  ),
  FormulaEntry(
    latex: "\\overrightarrow{F}_{1 \\leftarrow 2} + \\overrightarrow{F}_{2 \\leftarrow 1} = \\overrightarrow{0}",
    relatedVideo: buoyancyAndActionReaction,
    categoryName: "運動の第3法則",
  ),
  FormulaEntry(
    latex: "p = p_{0} + \\rho g h",
    relatedVideo: barometer,
    categoryName: "浮力・圧力",
  ),
  FormulaEntry(
    latex: "x(t) = \\frac12 g t^2",
    relatedVideo: freeFall,
    categoryName: "等加速度運動",
  ),
  FormulaEntry(
    latex: "t(x) = \\sqrt{\\frac{2x}{g}}",
    relatedVideo: freeFall,
    categoryName: "等加速度運動",
  ),
  FormulaEntry(
    latex: "F(x) = -k x",
    relatedVideo: verticalSpringOscillation,
    categoryName: "バネ・単振動",
  ),
  FormulaEntry(
    latex: "T = 2\\pi \\sqrt{\\frac{m}{k}}",
    relatedVideo: verticalSpringOscillation,
    categoryName: "バネ・単振動",
  ),
  FormulaEntry(
    latex: "F_{s} = \\mu_{s} N",
    relatedVideo: staticFriction,
    categoryName: "摩擦力",
  ),
  FormulaEntry(
    latex: "F_{k} = \\mu_{k} N",
    relatedVideo: kineticFriction,
    categoryName: "摩擦力",
  ),
  FormulaEntry(
    latex: "T = 2\\pi \\sqrt{\\frac{l}{g}}",
    relatedVideo: pendulumPeriodMeasurement,
    categoryName: "バネ・単振動",
  ),
  FormulaEntry(
    latex: "m_{1} v_{1} + m_{2} v_{2} = m_{1} v_{1}' + m_{2} v_{2}'",
    relatedVideo: elasticCollision1D,
    categoryName: "運動量保存則",
  ),
  FormulaEntry(
    latex: "m_{1} \\vec{v}_{1} + m_{2} \\vec{v}_{2} = m_{1} \\vec{v}_{1}' + m_{2} \\vec{v}_{2}'",
    relatedVideo: elasticCollision2D,
    categoryName: "運動量保存則",
  ),
  FormulaEntry(
    latex: "\\tfrac12 m_{1} v_{1}^{2} + \\tfrac12 m_{2} v_{2}^{2} = \\tfrac12 m_{1} v_{1}'^{2} + \\tfrac12 m_{2} v_{2}'^{2}",
    relatedVideo: elasticCollision2D,
    categoryName: "力学的エネルギー保存",
  ),
  FormulaEntry(
    latex: "\\frac{T^{2}}{a^{3}} = \\frac{4\\pi^{2}}{GM}",
    relatedVideo: planets,
    categoryName: "ケプラーの第3法則",
  ),
  FormulaEntry(
    latex: "F = q v B \\sin\\theta",
    relatedVideo: lorentzForce,
    categoryName: "電磁力・ローレンツ力",
  ),
  FormulaEntry(
    latex: "F = I \\ell B \\sin\\theta",
    relatedVideo: lorentzForce,
    categoryName: "電磁力・ローレンツ力",
  ),
  FormulaEntry(
    latex: "B = \\dfrac{\\mu_{0} I}{2\\pi r}",
    relatedVideo: ampereLawTorque,
    categoryName: "磁場",
  ),
  FormulaEntry(
    latex: "B = \\dfrac{\\mu_{0} I}{2a}",
    relatedVideo: magneticFieldCircularLoop,
    categoryName: "磁場",
  ),
  FormulaEntry(
    latex: "B = \\mu n I",
    relatedVideo: solenoidMagneticField,
    categoryName: "磁場",
  ),
  FormulaEntry(
    latex: "F = \\dfrac{\\mu_{0} I_{1} I_{2} \\ell}{2\\pi r}",
    relatedVideo: forceBetweenParallelCurrents,
    categoryName: "電磁力・ローレンツ力",
  ),
  FormulaEntry(
    latex: "L = \\mu_{0} \\mu_{r} \\dfrac{N^{2} A}{\\ell}",
    relatedVideo: solenoidSelfInductance,
    categoryName: "電磁誘導・インダクタンス",
  ),
  FormulaEntry(
    latex: "R = \\rho \\dfrac{\\ell}{A}",
    relatedVideo: resistanceVsLength,
    categoryName: "電流",
  ),
  FormulaEntry(
    latex: "V = RI",
    relatedVideo: ohmsLaw,
    categoryName: "電流",
  ),
  FormulaEntry(
    latex: "R = \\sum_{i=1}^{n} R_{i}",
    relatedVideo: seriesResistance,
    categoryName: "電流",
  ),
  FormulaEntry(
    latex: "\\dfrac{1}{R} = \\sum_{i=1}^{n} \\dfrac{1}{R_{i}}",
    relatedVideo: parallelResistance,
    categoryName: "電流",
  ),
  FormulaEntry(
    latex: "R = R_{0} \\bigl(1 + \\alpha (T - T_{0})\\bigr)",
    relatedVideo: resistivityTemperatureDependence,
    categoryName: "電流",
  ),
  FormulaEntry(
    latex: "C = \\varepsilon_{0} \\dfrac{S}{d}",
    relatedVideo: parallelPlateCapacitanceMeasurement,
    categoryName: "コンデンサ・静電気",
  ),
  FormulaEntry(
    latex: "\\dfrac{1}{C} = \\sum_{i=1}^{n} \\dfrac{1}{C_{i}}",
    relatedVideo: capacitanceSeriesCombination,
    categoryName: "コンデンサ・静電気",
  ),
  FormulaEntry(
    latex: "C = \\sum_{i=1}^{n} C_{i}",
    relatedVideo: capacitanceParallelCombination,
    categoryName: "コンデンサ・静電気",
  ),
  FormulaEntry(
    latex: "Q = CV",
    relatedVideo: capacitorChargeStorage,
    categoryName: "コンデンサ・静電気",
  ),
  FormulaEntry(
    latex: "L = \\frac{(2n-1)\\lambda}{4} （n=1,3,5,\\cdots）",
    relatedVideo: closedPipeResonance,
    categoryName: "音・共鳴",
  ),
  FormulaEntry(
    latex: "L = \\frac{n\\lambda}{2} （n=1,2,3,\\cdots）",
    relatedVideo: openPipeResonance,
    categoryName: "音・共鳴",
  ),
  FormulaEntry(
    latex: "f = \\bigl| f_1 - f_2 \\bigr| ",
    relatedVideo: beat,
    categoryName: "うなり",
  ),
  FormulaEntry(
    latex: "f' = f \cdot \frac{v \pm v_{\text{観測者}}}{v}",
      relatedVideo: doppler,
      categoryName: "ドップラー効果（観測者が動く場合）",
  ),
  FormulaEntry(
    latex: "f' = f \cdot \frac{v}{v \mp v_{\text{音源}}} \quad (v: 音速, \quad v_{\text{音源}}: 音源の速度)",
      relatedVideo: doppler,
      categoryName: "ドップラー効果（音源が動く場合）",
  ),
  FormulaEntry(
    latex: "d \\sin\\theta = n\\lambda",
    relatedVideo: diffractionGrating,
    categoryName: "光の干渉・回折",
  ),
  FormulaEntry(
    latex: "PV = \\text{一定}",
    relatedVideo: boyleLaw,
    categoryName: "気体の法則・熱力学",
  ),
];




void main() => runApp(JoyPhysicsApp());

class JoyPhysicsApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: '実験で学ぶ高校物理',
        theme: ThemeData(
          // フォントファミリーを指定
          fontFamily: 'Quicksand', // ここでカスタムフォント名を指定
          primarySwatch: Colors.blue),
          home: ContentView(),
      );
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
                Expanded(child: _CategoryList()),
                _Footer(),
              ],
            ),
          ),
        ],
      ),
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

class _CategoryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: categories.length + 2, // +2に変更（既存 + アプリについて + センサーを使う）
        itemBuilder: (context, index) {
          if (index == categories.length) {
            // 「センサーを使う」ボタン（追加）
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 75),
              child: GestureDetector(
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => SensorListView())),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.9), // 適宜色を変えてください
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
                          fontSize: 20,
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
          if (index == categories.length + 1) {
            // 「アプリについて」のボタン（そのまま）
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 75),
              child: GestureDetector(
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => AboutView())),
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
                          fontSize: 20,
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

          final cat = categories[index];
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 75),
            child: GestureDetector(
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => VideoListView(category: cat))),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFFC3734F).withOpacity(0.95), // 淡い茶色
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
                        fontSize: 25,
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




class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Text('Updated 2025/08/08', style: TextStyle(fontSize: 20, color: Colors.black)),
      );
}

class AboutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('アプリについて')),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Text('''

コンテンツはこれからも随時追加していく予定です。

扱ってほしいテーマがあれば、YouTubeやTikTokのコメント欄、またはアプリの評価欄にぜひご記入ください。できる限り、リクエストにお応えしていきます。

このアプリのテーマは、「実験を通して物理を楽しんで学んでもらう」こと。
「物理がわからない」「楽しくない」「もっとちゃんと学びたい」——そんな悩みや思いを持つ方の力になれたら嬉しいです。

AIの発展によって、多くの情報が無料で手に入るようになりました。だからこそ今、体験を通じて学ぶことの価値がより大きくなっていると感じています。
物理を、もっと身近に。もっと楽しく。あなたの学びの一歩になれば幸いです。
''', style: TextStyle(fontSize: 17)),
        ),
      );
}

class VideoListView extends StatefulWidget {
  final Category category;
  VideoListView({required this.category});
  @override
  _VideoListViewState createState() => _VideoListViewState();
}

class _VideoListViewState extends State<VideoListView> {
  VideoViewMode viewMode = VideoViewMode.byCategory;

  List<Video> get videosInCategory =>
      widget.category.subcategories.expand((s) => s.videos).toList();
  List<FormulaEntry> get formulasInCategory =>
      formulaList.where((f) => videosInCategory.contains(f.relatedVideo)).toList();

  @override
  Widget build(BuildContext context) {
    // 公式をカテゴリ毎にグループ化
    final groupMap = <String, List<FormulaEntry>>{};
    for (var f in formulasInCategory) {
      groupMap.putIfAbsent(f.categoryName, () => []).add(f);
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name)),
      body: Column(
        children: [
          // ─── 単元一覧 / 公式一覧 トグル ───
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ToggleButtons(
              constraints: const BoxConstraints(minWidth: 120, minHeight: 40),
              borderRadius: BorderRadius.circular(8),
              isSelected: [
                viewMode == VideoViewMode.byCategory,
                viewMode == VideoViewMode.byFormula,
              ],
              onPressed: (i) => setState(() {
                viewMode =
                    i == 0 ? VideoViewMode.byCategory : VideoViewMode.byFormula;
              }),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '単元一覧',
                    style: TextStyle(fontSize: 20), // フォントサイズ大きく
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '公式一覧',
                    style: TextStyle(fontSize: 20), // フォントサイズ大きく
                  ),
                ),
              ],
            ),
          ),

          // ─── 実験コスト凡例 ───
          const CostLegendSection(),

          // ─── コンテンツ本体（一覧 or 公式） ───
          Expanded(
            child: viewMode == VideoViewMode.byCategory
                ? _VideoCategoryList(
                    subcategories: widget.category.subcategories)
                : _FormulaList(groupedFormulas: groupMap),
          ),
        ],
      ),
    );
  }
}

class _VideoCategoryList extends StatelessWidget {
  final List<Subcategory> subcategories;
  _VideoCategoryList({required this.subcategories});

  @override
  Widget build(BuildContext context) => ListView(
        children: subcategories.expand((sub) {
          final videos = sub.videos;

          return [
            // ── サブカテゴリ見出し帯 ──
            Container(
              width: double.infinity,
              color: Colors.grey[300], // 薄いグレー
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                sub.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // ▼ サブカテゴリに属する動画リスト（線入り）
            ...List.generate(videos.length, (index) {
              final v = videos[index];
              final isLast = index == videos.length - 1;

              return Column(
                children: [
                  ListTile(
                    leading: Image.asset(
                      'assets/${v.category}/${v.iconName}.png',
                      width: 48,
                      height: 27,
                    ),
                    title: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 5,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 150,
                          ),
                          child: Text(
                            v.title,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        if (v.isSmartPhoneOnly == true)
                          Image.asset(
                            'assets/others/smartPhoneOnly.gif',
                            width: 68,
                            height: 45,
                            fit: BoxFit.contain,
                          ),
                        if (v.isNew == true)
                          Image.asset(
                            'assets/others/new.gif',
                            width: 60,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                      ],
                    ),
                    trailing: Text(
                      v.costRating,
                      style: TextStyle(
                        fontFamily: 'Keifont',
                        color: HexColor.fromHex('#FF9900'),
                        fontSize: 19,
                      ),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => VideoDetailView(video: v)),
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      thickness: 1.0,
                      height: 0,
                      indent: 16,
                      endIndent: 16,
                      color: Colors.grey[300],
                    ),
                ],
              );
            }),
            SizedBox(height: 8), // 次の帯との間隔
          ];
        }).toList(),
      );
}


class _FormulaList extends StatelessWidget {
  final Map<String, List<FormulaEntry>> groupedFormulas;
  _FormulaList({required this.groupedFormulas});

  @override
  Widget build(BuildContext context) => ListView(
        children: groupedFormulas.entries.expand((entry) {
          final formulas = entry.value;

          return [
            // サブカテゴリヘッダー
            Container(
              width: double.infinity,
              color: Colors.grey[300],
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                entry.key,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            // 各公式
            ...List.generate(formulas.length, (index) {
              final f = formulas[index];
              final isLast = index == formulas.length - 1;

              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoDetailView(video: f.relatedVideo),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 本文部
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // タイトル＋isNewマーク表示部分
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        f.relatedVideo.title,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (f.relatedVideo.isSmartPhoneOnly == true) ...[
                                      SizedBox(width: 10), // タイトルと画像の隙間
                                      Image.asset(
                                        'assets/others/smartPhoneOnly.gif',
                                        width: 68,
                                        height: 45,
                                        fit: BoxFit.contain,
                                      ),
                                    ],
                                    if (f.relatedVideo.isNew == true) ...[
                                      SizedBox(width: 10),
                                      Image.asset(
                                        'assets/others/new.gif',
                                        width: 60,
                                        height: 40,
                                        fit: BoxFit.contain,
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 4),
                                Math.tex(
                                  f.latex,
                                  textStyle: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Text(
                              f.relatedVideo.costRating,
                              style: TextStyle(
                                fontFamily: 'Keifont',
                                color: HexColor.fromHex('#FF9900'),
                                fontSize: 19,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      thickness: 1.0,
                      height: 0,
                      indent: 16,
                      endIndent: 16,
                      color: Colors.grey[300],
                    ),
                ],
              );
            }),
          ];
        }).toList(),
      );
}
class VideoDetailView extends StatelessWidget {
  final Video video;
  const VideoDetailView({required this.video, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(video.videoURL.isEmpty ? '' : video.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (video.experimentWidget != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  height: 450,  // 実験ウィジェットの高さ調整
                  width: double.infinity,
                  child: video.experimentWidget,
                ),
              ),

            if (video.videoURL.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  height: 200,  // YouTube埋め込みの高さ調整
                  width: double.infinity,
                  child: YouTubeWebView(videoURL: video.videoURL),
                ),
              ),

            if (video.equipment.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: EquipmentListView(equipment: video.equipment),
              ),

            if (video.latex != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  height: 300,  // Latex表示の高さ調整
                  width: double.infinity,
                  child: LatexWebView(latexHtml: video.latex!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


class CostLegendSection extends StatelessWidget {
  const CostLegendSection({super.key});

  @override
  Widget build(BuildContext context) {
    const starColor = Color.fromRGBO(255, 153, 0, 1.0);

    const legendTextStyle = TextStyle(fontSize: 18);  // ← ここでフォントサイズ指定

    return Container(
      width: double.infinity,
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 上部タイトル
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("★", style: TextStyle(color: starColor, fontSize: 18)),
              Text("・・・実験コスト", style: TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 4),

          // 凡例項目
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("★☆☆", style: TextStyle(color: starColor, fontSize: 18)),
              Text(" = 500円未満", style: legendTextStyle),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("★★☆", style: TextStyle(color: starColor, fontSize: 18)),
              Text(" = 1500円未満", style: legendTextStyle),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("★★★", style: TextStyle(color: starColor, fontSize: 18)),
              Text(" = 1500円以上", style: legendTextStyle),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/others/smartPhoneOnly.png', width: 60, height: 40),
              const SizedBox(width: 8),
              const Text("・・・スマホのみで実験可能", style: legendTextStyle),
            ],
          ),
        ],
      ),
    );
  }
}



class EquipmentListView extends StatelessWidget {
  final List<String> equipment;
  EquipmentListView({required this.equipment});

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: HexColor.fromHex('#E5E5E5'),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                '実験道具',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18, // ← フォントサイズ16に指定
                ),
              ),
            ),
            ...equipment.map((e) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: Text(
                    '・$e',
                    style: TextStyle(fontSize: 16), // ← フォントサイズ16に指定
                  ),
                )),
          ],
        ),
      );
}

class YouTubeWebView extends StatefulWidget {
  final String videoURL;
  const YouTubeWebView({super.key, required this.videoURL});

  @override
  State<YouTubeWebView> createState() => _YouTubeWebViewState();
}

class _YouTubeWebViewState extends State<YouTubeWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://www.youtube.com/embed/${widget.videoURL}'));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 550,
      child: WebViewWidget(controller: _controller),
    );
  }
}

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
          onPageFinished: (url) async {
            await _controller.runJavaScript('''
              MathJax.typesetPromise().then(() => {
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
    }
    html, body {
      margin: 0;
      padding: 0;
      font-family: 'KeiFont', sans-serif;
      font-size: 17px;
      background-color: transparent;
      line-height: 1.75;  /* ← 行間を少し広く */
    }
    .common-box {
      background: #eee;
      padding: 8px 16px;
      margin: 0px 0;
      border-radius: 4px;
    }
    .math-box {
      width: 100%;
      padding: 0px 0px;
      box-sizing: border-box;
      white-space: normal;
      overflow-wrap: break-word;
      word-break: break-word;
      overflow-x: hidden;
      -webkit-overflow-scrolling: touch;
    }
    .math-box img,
    .math-box table {
      max-width: 90%;
      height: auto;
      display: block;
      margin-left: auto;
      margin-right: auto;
    }
    .math-box table td,
    .math-box table th {
      word-wrap: break-word;
      white-space: normal;
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

class SensorListView extends StatelessWidget {
  final List<Map<String, dynamic>> sensors = [
    {
      'name': '加速度センサー',
      'icon': Icons.speed,
      'widget': AccelerometerExperimentWidget(), // 例: 実装済みのウィジェット
    },
    {
      'name': '光センサー',
      'icon': Icons.wb_sunny,
      'widget': LuxMeasurementWidget(),
    },
    {
      'name': '磁場センサー',
      'icon': Icons.sensors,
      'widget': MagnetometerExperimentWidget(),
    },
    {
      'name': '気圧センサー',
      'icon': Icons.compress,
      'widget': BarometerExperimentWidget(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('センサーを使う')),
      body: ListView.separated(
        itemCount: sensors.length,
        separatorBuilder: (_, __) => Divider(),
        itemBuilder: (context, index) {
          final sensor = sensors[index];
          return ListTile(
            leading: Icon(sensor['icon']),
            title: Text(sensor['name']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => sensor['widget']),
              );
            },
          );
        },
      ),
    );
  }
}
