import './MagnetometerExperimentWidget.dart';
import '../../model.dart'; // Videoクラスが定義されている場合
import 'package:flutter/material.dart';
import 'dart:math';

final magnetometer = Video(
  isSmartPhoneOnly: true,
  category: 'electroMagnetism',
  iconName: "magnet",
  title: "磁場の測定",
  titleEn: "Measuring magnetic fields (magnetometer)",
  videoURL: "",
  equipment: ["スマホ"],
  equipmentEn: ["smartphone"],
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
  latexEn: r"""
<div class="common-box">What is the geomagnetic field?</div>
<p>The Earth behaves like a giant magnet, and a magnetic field (the geomagnetic field) surrounds it.</p>
<p>The strength of the geomagnetic field varies by location, ranging from about 24000 nT to 66000 nT (nanotesla; $1\,\mu\mathrm{T}=1000\,\mathrm{nT}$) on Earth. In Japan, 2015 observations give about 44000 nT on Okinawa Island, about 51000 nT at the northern tip of Hokkaido, and about 46000 nT near Tokyo.</p>
<p>Near Japan, the average horizontal component (H) of the geomagnetic field is about 30000 nT (about 30 μT). The amplitude of quiet-day variation is about 50 nT, but during magnetic storms changes of several hundred nT can be observed.</p>
<p><small>※ These geomagnetic field strength values refer to the Wikipedia article “Geomagnetic field” (as of August 2025).</small></p>
<div class="common-box">What the magnetic sensor measures</div>
<p>A smartphone magnetometer detects magnetic field strength (μT) along three axes (x, y, z). You can use this to study the magnitude and direction of the geomagnetic field and how they change.</p>

<div class="common-box">Horizontal component calculation and example</div>
<p>With the smartphone placed horizontally, the horizontal component (H) can be calculated from the sensor’s x-component ($B_x$) and y-component ($B_y$) using the Pythagorean theorem:</p>
<p>$$ H = \sqrt{B_x^2 + B_y^2} $$</p>
<p>For example, if the x-component is 25 μT and the y-component is 15 μT, the horizontal component H is calculated as follows:</p>
$$\begin{aligned}
H &= \sqrt{B_x^2 + B_y^2} = \sqrt{25^2 + 15^2} \\[6pt]
& = \sqrt{625 + 225} = \sqrt{850} \\[6pt]
& \fallingdotseq 29.15 \mathrm{μT}
\end{aligned}$$
<p>This value gives the magnitude of the horizontal component of the geomagnetic field and is used for determining direction.</p>

<div class="common-box">Experiment: bring a magnet close</div>
<ul>
  <li>Place the smartphone horizontally on a desk and display the x, y, and z magnetic field strengths and the total field magnitude on the screen.</li>
  <li>When you bring a magnet near the phone, the values change significantly. Depending on the magnet’s strength, it may affect the phone’s sensors or hardware—handle with care.</li>
  <li>Change the magnet’s orientation and distance to observe how the magnetic field vector changes.</li>
</ul>

<div class="common-box">Experiment: measure the direction of the geomagnetic field</div>
<ul>
  <li>Without using a magnet, change the orientation of the smartphone and observe.</li>
  <li>Rotate the phone or turn it upside down to confirm the direction of the geomagnetic field.</li>
  <li>This also helps you understand how compass apps and the compass principle work.</li>
</ul>

<div class="common-box">Summary</div>
<ol>
  <li>A smartphone magnetometer can observe magnetic field strength along the $x$, $y$, and $z$ axes</li>
  <li>Placed horizontally, the horizontal component can be calculated from the $x$ and $y$ components via the Pythagorean theorem</li>
  <li>A magnet can visualize field changes, but strong magnets must be handled with care</li>
  <li>You can experience how the geomagnetic field vector changes with the phone’s orientation</li>
</ol>
""",
  experimentWidgets: [MagnetometerExperimentWidget(height: 380, useScaffold: false)],
);
