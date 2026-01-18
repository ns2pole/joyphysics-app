import '../../model.dart'; // Videoクラス定義が別ならインポート
final parallelPlateCapacitanceMeasurement = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
    iconName: "parallelPlateCapacitanceMeasurement",
    title: "平行板コンデンサの電気容量の測定",
    videoURL: "vzdKFnLYhw0",
    equipment: ["金属板", "導線", "電源", "マルチメータ(C)", "洗濯バサミ", "絶縁物"],
    costRating: "★★★", latex: r"""
<div class="common-box">ポイント</div>
<p>平行板コンデンサの電気容量$C$は誘電率$\varepsilon$、面積$S$、板間距離$d$によって次式で与えられる：</p>
<p>$$C = \varepsilon \frac{S}{d}$$</p>
<p>ここで、誘電率$\varepsilon$は空気の場合は$\varepsilon_0$（真空の誘電率）で、誘電体を入れると$\varepsilon = \kappa \varepsilon_0$と増加し、$\kappa$は誘電体の比誘電率（誘電率比）である。</p>

<div class="common-box">問題設定</div>
<p>空気中に置かれた平行板コンデンサを考える。次の条件のもとで、コンデンサの静電容量$C$を求めて下さい。</p>
<ul>
  <li>空気の誘電率（ほぼ真空と同じ）：$$\varepsilon_0 = 8.854 \times 10^{-12} \ \mathrm{F \cdot m^{-1}}$$</li>
  <li>平行板の面積：$$S = 10^2 \ \mathrm{cm^2} = 1.0 \times 10^{-2} \ \mathrm{m^2}$$</li>
  <li>平行板間の距離：$$d = 0.7 \ \mathrm{mm} = 7 \times 10^{-4} \ \mathrm{m}$$</li>
</ul>

<div class="common-box">理論値計算</div>
<p>平行板コンデンサの静電容量は次式で求められる：</p>
<p>$$C = \varepsilon_0 \cdot \frac{S}{d}$$</p>
<p>数値を代入すると：</p>
<p>$$\begin{aligned}
C &= 8.854 \times 10^{-12} \times \frac{1.0 \times 10^{-2}}{7 \times 10^{-4}} \\
&= \frac{8.854 \times 10^{-14}}{7 \times 10^{-4}} \\
&\fallingdotseq 126.5 \times 10^{-12} \ \mathrm{F} = 126.5 \ \mathrm{pF}
\end{aligned}$$</p>

<div class="common-box">答え</div>
<p>この平行板コンデンサの静電容量は</p>
<p>$$\boxed{C \fallingdotseq 126.5 \ \mathrm{pF}}$$</p>

"""
);