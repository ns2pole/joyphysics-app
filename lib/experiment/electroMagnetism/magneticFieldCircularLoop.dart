import 'package:joyphysics/experiment/electroMagnetism/MagnetometerExperimentWidget.dart';
import '../../model.dart'; // Videoクラス定義が別ならインポート

final magneticFieldCircularLoop = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
    iconName: "magneticFieldCircularLoop",
    title: "円形電流の中心における磁場の大きさ",
    titleEn: "Magnitude of the magnetic field at the center of a circular current",
    videoURL: "SDrXcpvY4Ac",
    equipment: ["導線", "電源", "磁力計"],
    equipmentEn: ["wire", "power supply", "magnetometer"],
    costRating: "★★★", latex: r"""
<div class="common-box">ポイント</div>
<p>半径 $a$ の円形電流の中心における磁場の強さ $B$ は次の式で与えられます：</p>
<p>$$ B = \frac{\mu_0 I}{2 a} $$</p>

<p>※記号の定義：</p>
<ul style="line-height:1.6;">
<li>$B$：磁場の大きさ（T）</li>
<li>$\mu_0$：真空の透磁率（約 $4\pi \times 10^{-7}$ T·m/A）</li>
<li>$I$：電流の大きさ（A）</li>
<li>$a$：円形ループの半径（m）</li>
</ul>

<div style="text-align:center; margin:1em 0;">
  <img src="assets/electroMagnetismDetail/magneticFieldCircularLoop.png"
       alt="円形電流の中心における磁場"
       style="max-width:50%; height:auto;" />
</div>


<ul>
<li>磁場の大きさは電流の大きさに比例し、ループの半径に反比例する</li>
<li>磁場の方向はループ面に垂直で、右ねじの法則で決まる</li>
<li>$B =\displaystyle \frac{\mu_0 I}{2 a}$の表式はビオ・サバールの法則から導くことができる</li>

</ul>
""",
    latexEn: r"""
<div class="common-box">Key points</div>
<p>The magnetic field strength $B$ at the center of a circular current of radius $a$ is given by:</p>
<p>$$ B = \frac{\mu_0 I}{2 a} $$</p>

<p>※ Definition of symbols:</p>
<ul style="line-height:1.6;">
<li>$B$: magnitude of the magnetic field (T)</li>
<li>$\mu_0$: permeability of free space (about $4\pi \times 10^{-7}$ T·m/A)</li>
<li>$I$: magnitude of the current (A)</li>
<li>$a$: radius of the circular loop (m)</li>
</ul>

<div style="text-align:center; margin:1em 0;">
  <img src="assets/electroMagnetismDetail/magneticFieldCircularLoop.png"
       alt="Magnetic field at the center of a circular current"
       style="max-width:50%; height:auto;" />
</div>


<ul>
<li>The magnitude of the magnetic field is proportional to the current and inversely proportional to the loop radius</li>
<li>The magnetic field direction is perpendicular to the plane of the loop and is given by the right-hand rule</li>
<li>The expression $B =\displaystyle \frac{\mu_0 I}{2 a}$ can be derived from the Biot–Savart law</li>

</ul>
"""
);