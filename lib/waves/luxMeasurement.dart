import '../model.dart';
import './LuxMeasurementWidget.dart';

final luxMeasurement = Video(
  isSmartPhoneOnly: true,
  isNew: true,
  category: 'waves',
  iconName: "light",  // assets に luxmeter アイコンを用意してください
  title: "ルクス（照度）の測定",
  videoURL: "", // 実験動画のURLがあればここに
  equipment: ["スマホ（照度センサー搭載）"],
  costRating: "★☆☆",
  latex: """
<div class="common-box">ルクス（照度）とは？</div>
<p>ルクス（lux）は光の明るさを表す単位で、1平方メートルあたりの光束（ルーメン）の量を示します。<b>照度</b>の単位です。</p>
<p>スマホには多くの場合、周囲の明るさを感知する<b>照度センサー</b>が搭載されており、これを利用してリアルタイムにルクス値を測定できます。</p>

<div class="common-box">実験：スマホの照度センサーで明るさを測る</div>
<ol>
  <li>スマホに照度測定アプリを起動する</li>
  <li>部屋の明るい場所、暗い場所、または直射日光の当たる場所にスマホを移動させる</li>
  <li>リアルタイムで表示されるルクス値の変化を観察する</li>
  <li>手でセンサー部分を覆ったり明かりを遮ったりして、値の変化を確かめる</li>
</ol>

<div class="common-box">観察ポイント</div>
<ul>
  <li>暗い場所ではルクス値が低くなる</li>
  <li>明るい場所や直射日光下ではルクス値が大きくなる</li>
  <li>手で覆うと急激にルクス値が減少する</li>
  <li>部屋の照明のON/OFFで変化を確認できる</li>
</ul>

<div class="common-box">理論：ルクス値のイメージ</div>
<p>参考として一般的な環境の照度の目安：</p>
<ul>
  <li>直射日光：約100,000 ルクス</li>
  <li>曇り空：約10,000 ルクス</li>
  <li>室内の明るい場所：約500～1,000 ルクス</li>
  <li>暗い部屋：約50 ルクス以下</li>
</ul>

<div class="common-box">注意点</div>
<ul>
  <li>スマホのセンサー性能や機種によって測定精度は異なる</li>
  <li>センサーの位置やカバーが光を遮らないように注意すること</li>
  <li>急激な光の変化に対して反応が遅れる場合がある</li>
</ul>
""",
  experimentWidget: LuxMeasurementWidget(), // 実際の測定ウィジェットを用意したらここに指定
);