import 'package:joyphysics/experiment/dynamics/AccelerometerExperimentWidget.dart';
import '../../model.dart';

final accelerometer = Video(
  isSmartPhoneOnly: true,
  category: 'dynamics',
  iconName: "accelerometer",  // gravity.png などを assets に追加
  title: "加速度の測定",
  videoURL: "", // 実験動画のURLがある場合はここに
  equipment: ["スマホ（加速度センサー搭載）"],
  costRating: "★☆☆",
  latex: """
<div class="common-box">加速度センサーとは？</div>
<p>スマートフォンには <b>加速度センサー</b> が搭載されており、x, y, z 各軸の加速度（単位：m/s²）をリアルタイムで取得できます。</p>
<p>このセンサーは、物体の動きに加えて <b>重力加速度（9.8 m/s²）</b> も常に検出します。静止状態でも Z軸などに約 9.8 m/s² の値が表示されるのはそのためです。</p>

<div class="common-box">実験①：スマホの向きを変えて観察</div>
<ul>
  <li>スマホを机に水平に置く → Z軸に約 +9.8 m/s²</li>
  <li>スマホを垂直に立てる → Y軸または X軸に変化</li>
  <li>スマホの向きをゆっくり変えると、重力ベクトルの成分がリアルタイムに変化</li>
</ul>

<div class="common-box">実験②：自由落下による「無重力」状態</div>
<ul>
  <li>スマホを一瞬、低い位置から安全に落とす（クッションなどに着地させる）</li>
  <li>落下中、加速度が 0 m/s² 近くになる（= 自由落下では加速度センサーが無重力を示す）</li>
  <li>これはアインシュタインの「等価原理」の簡易体験としても面白い</li>
</ul>

<div class="common-box">観察ポイント</div>
<ol>
  <li>静止状態でも常に「重力加速度」が加わっている</li>
  <li>スマホの向きによって重力ベクトルの成分が変化する</li>
  <li>落下や振動などによる動きが、加速度の変化として現れる</li>
</ol>

<div class="common-box">注意点</div>
<ul>
  <li>落下実験ではスマホの破損に注意。必ず柔らかい場所に落とすこと。</li>
  <li>加速度の値は一時的なノイズやブレもあるため、何度か測定して傾向を見るとよい。</li>
</ul>
""",
  experimentWidgets: [AccelerometerExperimentWidget()],
);