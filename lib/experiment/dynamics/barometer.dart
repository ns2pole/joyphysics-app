
import 'package:joyphysics/experiment/dynamics/BarometerExperimentWidget.dart';
import '../../model.dart'; // Videoクラスが定義されている場合

final barometer = Video(
  isSmartPhoneOnly: true,
  category: 'dynamics',
  iconName: "barometer",
  title: "1階と2階での大気圧の測定",
  videoURL: "CYyNcLxpYYg",
  equipment: ["スマホ（気圧センサー搭載）"],
  costRating: "★☆☆",
  latex: r"""
<div class="common-box">大気圧とは？</div>
<p>大気圧は空気の重さによって生じる圧力で、標高や天気によって変化する。単位は hPa（ヘクトパスカル）がよく使われる。</p>

<div class="common-box">空気の柱の力のつり合い</div>
<p>断面積 $S$、高さ \(\Delta h\) の空気柱を考える。上面にかかる力は \(P(h+\Delta h)S\)、下面にかかる力は \(P(h)S\)、空気柱の重さは \(\rho g S \Delta h\) となる。</p>
<div style="text-align:center; margin:1em 0;">
    <img src="assets/dynamicsDetail/barometer.png"
          alt="回帰直線"
          style="max-width:100%; height:auto;" />
  </div>
<p>力のつり合いより</p>
<p>
$$\begin{aligned}
P(h)S &= P(h+\Delta h)S + \rho g S \Delta h \\[6pt]
\Leftrightarrow P(h) &= P(h+\Delta h) + \rho g  \Delta h
\end{aligned}$$
</p>
よって、気圧差\( \Delta P = P(h+\Delta h)  - P(h)\)は、
<p>
$$
\Delta P  =\rho g  \Delta h
$$
</p>

<div class="common-box">数値評価</div>
<p>地表付近で空気の密度はおおよそ \(\rho \fallingdotseq 1.2\,\mathrm{kg/m^3}\)程度であるとすると、
重力加速度を \(g \fallingdotseq 9.8\,\mathrm{m/s^2}\) とすると、</p>
1 m 上昇あたりの気圧変化を計算するには、$h=1 [m]$として
<p>
$$
\Delta P \fallingdotseq -1.2 \times 9.8 \times 1 
\fallingdotseq -12 \, \mathrm{Pa}
= -0.12 \, \mathrm{hPa}
$$
</p>

<p>3 m 上昇（階段で2階）では</p>
<p>
$$
\Delta P \fallingdotseq -36 \, \mathrm{Pa}
= -0.36 \, \mathrm{hPa}
$$
</p>

<div class="common-box">実験：階段で2階まで上がる</div>
<ol>
  <li>1階で大気圧を記録する</li>
  <li>階段を使って2階で記録する</li>
  <li>理論値（高低差3mなら、約0.36 hPa 低下）と比較する</li>
</ol>

<div class="common-box">注意点</div>
<ul>
  <li>すべてのスマホに気圧センサーが搭載されているわけではない。</li>
  <li>気圧変化は小さいため、気流やセンサーの誤差の影響を受けやすい。</li>
</ul>
""",
  experimentWidgets: [BarometerExperimentWidget(useScaffold: false)],
);
