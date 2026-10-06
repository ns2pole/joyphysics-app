
import 'package:joyphysics/experiment/dynamics/BarometerExperimentWidget.dart';
import '../../model.dart'; // Videoクラスが定義されている場合

final barometer = Video(
  isSmartPhoneOnly: true,
  category: 'dynamics',
  iconName: "barometer",
  title: "1階と2階での大気圧の測定",
  titleEn: "Atmospheric pressure on the 1st and 2nd floors",
  videoURL: "CYyNcLxpYYg",
  videoURLEn: "CYyNcLxpYYg",
  equipment: ["スマホ（気圧センサー搭載）"],
  equipmentEn: ["smartphone (with barometer)"],
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
  latexEn: r"""
<div class="common-box">What is atmospheric pressure?</div>
<p>Atmospheric pressure is the pressure due to the weight of air; it varies with altitude and weather. The unit hPa (hectopascal) is commonly used.</p>

<div class="common-box">Force balance on an air column</div>
<p>Consider an air column of cross section $S$ and height $\Delta h$. The force on the top face is $P(h+\Delta h)S$, on the bottom face $P(h)S$, and the weight of the column is $\rho g S \Delta h$.</p>
<div style="text-align:center; margin:1em 0;">
    <img src="assets/dynamicsDetail/barometer.png"
          alt="Regression line"
          style="max-width:100%; height:auto;" />
  </div>
<p>From force balance,</p>
<p>
$$\begin{aligned}
P(h)S &= P(h+\Delta h)S + \rho g S \Delta h \\[6pt]
\Leftrightarrow P(h) &= P(h+\Delta h) + \rho g  \Delta h
\end{aligned}$$
</p>
Hence the pressure difference $\Delta P = P(h+\Delta h) - P(h)$ is
<p>
$$
\Delta P  =\rho g  \Delta h
$$
</p>

<div class="common-box">Numerical estimate</div>
<p>Near the ground, take the air density as about $\rho \fallingdotseq 1.2\,\mathrm{kg/m^3}$ and
$g \fallingdotseq 9.8\,\mathrm{m/s^2}$. Then, for a rise of $h=1\,\mathrm{m}$,</p>
<p>
$$
\Delta P \fallingdotseq -1.2 \times 9.8 \times 1 
\fallingdotseq -12 \, \mathrm{Pa}
= -0.12 \, \mathrm{hPa}
$$
</p>

<p>For a rise of 3 m (one floor up by stairs),</p>
<p>
$$
\Delta P \fallingdotseq -36 \, \mathrm{Pa}
= -0.36 \, \mathrm{hPa}
$$
</p>

<div class="common-box">Experiment: climb to the 2nd floor</div>
<ol>
  <li>Record atmospheric pressure on the 1st floor</li>
  <li>Climb the stairs and record on the 2nd floor</li>
  <li>Compare with the theory (about a 0.36 hPa drop for a 3 m height difference)</li>
</ol>

<div class="common-box">Note</div>
<ul>
  <li>Not every smartphone has a barometer.</li>
  <li>The pressure change is small, so drafts and sensor noise can matter.</li>
</ul>
""",
  experimentWidgets: [BarometerExperimentWidget(useScaffold: false)],
);
