import './AccelerometerExperimentWidget.dart';
import '../model.dart';

final accelerometer = Video(
  category: 'motion',
  iconName: "gravity",  // 適宜用意
  title: "重力加速度の観測",
  videoURL: "",
  equipment: ["スマホ"],  // 加速度センサー搭載スマホ
  costRating: "★☆☆",
  latex: """
<div class="common-box">加速度センサーとは？</div>
<p>スマートフォンには加速度センサーが搭載されており、x, y, z 軸の加速度（単位：m/s²）をリアルタイムで取得できます。</p>
<p>この加速度には <b>重力加速度</b>（9.8 m/s²）が含まれており、スマホが静止しているときは、センサーにかかる加速度 = 重力加速度となります。</p>

<div class="common-box">実験：スマホの向きを変えて観察</div>
<ul>
  <li>スマホを机に水平に置いたとき、z軸方向に約9.8 m/s²</li>
  <li>スマホを立てたときは、y軸やx軸に値が現れる</li>
  <li>スマホの向きを変えることで、重力加速度ベクトルの向きを観察できます</li>
</ul>

<div class="common-box">実験：自由落下</div>
<ul>
  <li>一瞬スマホを落とすと、加速度が 0 m/s² 近くになります（自由落下中）</li>
  <li>高精度な観測には注意が必要ですが、センサーで「無重量状態」を再現できます</li>
</ul>

<div class="common-box">まとめ</div>
<ol>
  <li>加速度センサーで、重力加速度の大きさと方向を観察できる</li>
  <li>スマホの向きによってベクトルの成分が変化する</li>
  <li>自由落下や振動でも加速度の変化が記録できる</li>
</ol>
""",
  experimentWidget: AccelerometerExperimentWidget(),
);
