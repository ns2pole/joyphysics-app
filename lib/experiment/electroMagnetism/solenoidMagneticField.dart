import '../../model.dart'; // Videoクラス定義が別ならインポート

final solenoidMagneticField = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
  iconName: "solenoidMagneticField",
  title: "ソレノイドコイルの作る磁場",
  videoURL: "AzeN5ZFkuXE",
  equipment: ["導線", "細長いパイプ","カッターナイフ", "乾電池", "マルチメータ", "磁場測定器"],
  costRating: "★★★",
  latex: r"""
<div class="common-box">ポイント</div>
<p>長さ $L = 39\,\text{cm} = 0.39\,\text{m}$、巻き数 $N = 210$ の一様なソレノイドに電流 $I = 1.05\,\text{A}$ を流すと、内部の磁場の強さ $B$ は次の式で近似できます：</p>

<p>$$ B = \mu_0 n I = \mu_0 \frac{N}{L} I $$</p>

<p>※記号の定義：</p>
<ul style="line-height:1.6;">
  <li>$B$：ソレノイド内部の磁場の大きさ（T）</li>
  <li>$\mu_0$：真空の透磁率（$4\pi \times 10^{-7}\,\text{T·m/A}$）</li>
  <li>$N$：巻き数</li>
  <li>$L$：コイルの長さ（m）</li>
  <li>$n$：巻き数密度（$m^{-1} $）</li>
  <li>$I$：流れる電流（A）</li>
</ul>

<p>この値を代入すると：</p>
<p>$$
\begin{aligned}
B &= 4\pi \times 10^{-7} \cdot \frac{210}{0.39} \cdot 1.05 \\
  &\fallingdotseq 4\pi \times 10^{-7} \cdot 538.46 \cdot 1.05 \\
  &\fallingdotseq 4\pi \times 10^{-7} \cdot 565.38 \\
  &\fallingdotseq 7.1 \times 10^{-4}\,\text{T} \\
  &= 0.71\,\text{mT}
\end{aligned}
$$</p>

<div style="text-align:center; margin:1em 0;">
  <img src="assets/electroMagnetismDetail/solenoidMag.png"
       alt="ソレノイド内部の磁場"
       style="max-width:75%; height:auto;" />
</div>

<ul>
  <li>ソレノイド内部の磁場はほぼ一様である</li>
  <li>巻き数密度（巻き数÷長さ）が磁場の強さを決定する</li>
  <li>磁場の方向は電流の向きと右ねじの法則で決まる</li>
</ul>
"""
);