import '../../model.dart';
import 'package:joyphysics/experiment/waves/LuxMeasurementWidget.dart';

final luxMeasurement = Video(
  isSmartPhoneOnly: true,
  category: 'waves',
  iconName: "light",  // assets に luxmeter アイコンを用意してください
  title: "ルクス（照度）の測定",
  titleEn: "Measuring lux (illuminance)",
  videoURL: "", // 実験動画のURLがあればここに
  equipment: ["スマホ（照度センサー搭載）"],
  equipmentEn: ["smartphone (with illuminance sensor)"],
  costRating: "★☆☆",
  latex: r"""
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
  latexEn: r"""
<div class="common-box">What is lux (illuminance)?</div>
<p>Lux is a unit of brightness: the luminous flux (lumens) per square metre. It is the unit of <b>illuminance</b>.</p>
<p>Many smartphones have an <b>illuminance sensor</b> that senses ambient light, which you can use to measure lux in real time.</p>

<div class="common-box">Experiment: measure brightness with the phone sensor</div>
<ol>
  <li>Start the illuminance-measurement feature on the smartphone</li>
  <li>Move the phone to a bright spot, a dark spot, or into direct sunlight</li>
  <li>Watch the lux value change in real time</li>
  <li>Cover the sensor with your hand or block the light and check how the value changes</li>
</ol>

<div class="common-box">Key observations</div>
<ul>
  <li>In dark places the lux value is low</li>
  <li>In bright places or direct sunlight the lux value is large</li>
  <li>Covering the sensor with your hand drops the lux value sharply</li>
  <li>You can also see changes by turning room lights on and off</li>
</ul>

<div class="common-box">Theory: typical lux values</div>
<p>Rough illuminance levels for common environments:</p>
<ul>
  <li>Direct sunlight: about 100,000 lux</li>
  <li>Overcast sky: about 10,000 lux</li>
  <li>Bright indoor area: about 500–1,000 lux</li>
  <li>Dark room: about 50 lux or less</li>
</ul>

<div class="common-box">Note</div>
<ul>
  <li>Accuracy depends on the phone model and sensor quality</li>
  <li>Make sure the sensor position or case does not block the light</li>
  <li>The reading may lag when light changes suddenly</li>
</ul>
""",
  experimentWidgets: [LuxMeasurementWidget(useScaffold: false)], // 実際の測定ウィジェットを用意したらここに指定
);