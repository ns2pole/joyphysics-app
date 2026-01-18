import '../../model.dart'; // Videoクラス定義が別ならインポート

final ohmsLaw = Video(
  isExperiment: true,
  category: 'electroMagnetism', // または 'electricCircuit' でも可
  iconName: "ohmsLaw",
  title: "オームの法則",
  videoURL: "srFoXxEUDIQ",
  equipment: ["乾電池3本", "100Ω抵抗", "200Ω抵抗", "マルチメーター", "導線"],
  costRating: "★★☆",
  latex: r"""
<div class="common-box">ポイント</div>
<p>オームの法則 $V = IR$ を使って、直列回路の中の電流や電位差を求められます。</p>

<p>ここでは、100Ωと200Ωの抵抗を直列に接続し、4.5Vの電池につなぎました。</p>

<div style="text-align:center; margin:1em 0;">
  <img src="assets/electroMagnetismDetail/ohmsLawSeriesCircuit.png"
       alt="直列回路の図"
       style="max-width:50%; height:auto;" />
</div>

<p>このとき、回路全体の抵抗は次の通り：</p>
<p>$$ R_{\text{total}} = 100\,\Omega + 200\,\Omega = 300\,\Omega $$</p>

<p>電流 $I$ は：</p>
<p>$$
\begin{aligned}
I &= \frac{V}{R_{\text{total}}} = \frac{4.5}{300} = 0.015\,\text{A} \\
  &= 15\,\text{mA}
\end{aligned}
$$</p>

<p>100Ωの抵抗にかかる電位差 $V_{100}$ は：</p>
<p>$$
\begin{aligned}
V_{100} &= IR = 0.015 \times 100 = 1.5\,\text{V}
\end{aligned}
$$</p>

<ul>
  <li>直列回路では電流はすべての抵抗に等しく流れる</li>
  <li>電位差は抵抗に比例して分配される</li>
  <li>電池電圧 = 各抵抗の電位差の和</li>
</ul>
"""
);