import './MagnetometerExperimentWidget.dart';
import '../../model.dart'; // Videoクラスが定義されている場合
import 'package:flutter/material.dart';
import 'dart:math';

final magnetometer = Video(
  isSmartPhoneOnly: true,
  category: 'electroMagnetism',
  iconName: "magnet",
  title: "磁場の測定",
  videoURL: "",
  equipment: ["スマホ"],
  costRating: "★☆☆",
  latex: r"""
<div class="common-box">地磁気とは？</div>
<p>地球は巨大な磁石のように振る舞っており、その周囲には磁場（地磁気）が存在しています。</p>
<p>地磁気の強さは場所によって異なり、地球上では約 24000 nT から 66000 nT（ナノテスラ、1μT=1000nT）ほどの範囲です。日本では、2015年の観測で沖縄本島で約44000 nT、北海道北端で約51000 nT、東京付近では約46000 nTとなっています。</p>
<p>日本付近の平均的な地磁気の水平分力（H）は約30000 nT（約30μT）で、静穏時の日変化の振幅は約50 nT程度ですが、磁気嵐の時には数百 nT の変化が観測されることもあります。</p>
<p><small>※これらの地磁気強さの数値はウィキペディア「地磁気」(2025年8月現在)を参照しています。</small></p>
<div class="common-box">磁気センサーが測るもの</div>
<p>スマホの磁気センサーは3軸（x, y, z）方向の磁場強度（μT）を検出します。これを使って地磁気の大きさや方向の変化を調べることができます。</p>

<div class="common-box">水平成分の計算と例</div>
<p>スマホを水平に置いた状態で、磁気センサーのx方向成分（Bx）とy方向成分（By）から三平方の定理により水平成分（H）を計算できます：</p>
<p>$$ H = \sqrt{B_x^2 + B_y^2} $$</p>
<p>例えば、x方向成分が 25 μT、y方向成分が 15 μT の場合、三平方の定理を使って水平成分 H は以下のように計算されます：</p>
$$\begin{aligned}
H &= \sqrt{B_x^2 + B_y^2} = \sqrt{25^2 + 15^2} \\[6pt]
& = \sqrt{625 + 225} = \sqrt{850} \\[6pt]
& \fallingdotseq 29.15 \mathrm{μT}
\end{aligned}$$
<p>この値は地磁気の水平分力の大きさを示しており、方位の検出に使われます。</p>

<div class="common-box">実験：磁石を近づける</div>
<ul>
  <li>スマホを机の上に水平に置き、画面上に x, y, z の磁場強度と合成磁場の大きさを表示します。</li>
  <li>磁石をスマホに近づけると、値が大きく変化することが確認できますが、磁石の強さによってはスマホのセンサーや機器に影響を与える場合があります。取り扱いには注意してください。</li>
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
  <li>スマホの磁気センサーで $x, y, z$ 軸の磁場強度を観測できる</li>
  <li>水平に置いて $x$ と $y$ の成分から三平方の定理で水平成分を計算できる</li>
  <li>磁石を使えば磁場の変化を視覚化できるが、強い磁石の取り扱いには注意が必要</li>
  <li>スマホの向きに応じて地磁気ベクトルが変化する様子を体験できる</li>
</ol>
""",
  experimentWidgets: [MagnetometerExperimentWidget(height: 380, useScaffold: false)],
);