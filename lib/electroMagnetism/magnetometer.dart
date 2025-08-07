import './MagnetometerExperimentWidget.dart';
import '../model.dart';

final magnetometer = Video(
  category: 'waves',  // または 'earth' など分類に応じて変更
  iconName: "magnet",
  title: "磁場の測定",
  videoURL: "",
  equipment: ["スマホ"],  // スマホの磁気センサーを使用
  costRating: "★☆☆",
  latex: """
<div class="common-box">地磁気とは？</div>
<p>地球は巨大な磁石のようにふるまっており、そのまわりには磁場（地磁気）が存在しています。スマートフォンに内蔵された磁気センサーを使えば、この地磁気を観測することができます。</p>

<div class="common-box">磁気センサーが測るもの</div>
<p>スマホの磁気センサーは、3 軸（x, y, z）方向の磁場強度（単位：μT）を検出します。これを使って、地磁気の大きさや方向の変化を調べることができます。</p>

<div class="common-box">実験：磁石を近づける</div>
<ul>
  <li>スマホを机の上に置き、画面上に x, y, z の磁場強度と合成磁場の大きさを表示します。</li>
  <li>磁石をスマホに近づけると、値が大きく変化することが確認できます。</li>
  <li>磁石の向きや距離を変えることで、磁場ベクトルがどう変わるか観察します。</li>
</ul>

<div class="common-box">実験：地磁気の向きを測る</div>
<ul>
  <li>磁石を使わずに、スマホの向きを変えて観測します。</li>
  <li>スマホを回転させたり上下逆さまにすることで、地磁気の方向を確認します。</li>
  <li>方位磁針アプリの仕組みや、コンパスの原理も理解する手助けになります。</li>
</ul>

<div class="common-box">まとめ</div>
<ol>
  <li>スマホの磁気センサーで x, y, z 軸の磁場強度を観測できる</li>
  <li>磁石を使えば磁場の変化を視覚化できる</li>
  <li>スマホの向きに応じて地磁気ベクトルが変化する様子を体験できる</li>
</ol>
""",
  experimentWidget: MagnetometerExperimentWidget(),
);