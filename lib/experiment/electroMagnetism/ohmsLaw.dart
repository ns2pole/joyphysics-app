import '../../model.dart'; // Videoクラス定義が別ならインポート

final ohmsLaw = Video(
  isExperiment: true,
  category: 'electroMagnetism', // または 'electricCircuit' でも可
  iconName: "ohmsLaw",
  title: "オームの法則",
  titleEn: "Ohm's law",
  videoURL: "srFoXxEUDIQ",
  equipment: ["乾電池3本", "100Ω抵抗", "200Ω抵抗", "マルチメーター", "導線"],
  equipmentEn: ["3 dry cells", "100 Ω resistor", "200 Ω resistor", "multimeter", "wires"],
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

<p>100Ωの抵抗にかかる電位差 $V_{100}$ と、200Ωの抵抗にかかる電位差 $V_{200}$ は：</p>
<p>$$
\begin{aligned}
V_{100} &= IR = 0.015 \times 100 = 1.5\,\text{V} \\
V_{200} &= IR = 0.015 \times 200 = 3.0\,\text{V}
\end{aligned}
$$</p>
<p>和は $1.5+3.0=4.5\,\text{V}$ で、電池電圧と一致します。</p>

<ul>
  <li>直列回路では電流はすべての抵抗に等しく流れる</li>
  <li>電位差は抵抗に比例して分配される</li>
  <li>電池電圧 = 各抵抗の電位差の和</li>
</ul>
""",
  latexEn: r"""
<div class="common-box">Key points</div>
<p>Using Ohm's law $V = IR$, you can find the current and potential differences in a series circuit.</p>

<p>Here, 100 Ω and 200 Ω resistors were connected in series to a 4.5 V battery.</p>

<div style="text-align:center; margin:1em 0;">
  <img src="assets/electroMagnetismDetail/ohmsLawSeriesCircuit.png"
       alt="Series circuit diagram"
       style="max-width:50%; height:auto;" />
</div>

<p>The total resistance of the circuit is:</p>
<p>$$ R_{\text{total}} = 100\,\Omega + 200\,\Omega = 300\,\Omega $$</p>

<p>The current $I$ is:</p>
<p>$$
\begin{aligned}
I &= \frac{V}{R_{\text{total}}} = \frac{4.5}{300} = 0.015\,\text{A} \\
  &= 15\,\text{mA}
\end{aligned}
$$</p>

<p>The potential difference across the 100 Ω resistor, $V_{100}$, and across the 200 Ω resistor, $V_{200}$, are:</p>
<p>$$
\begin{aligned}
V_{100} &= IR = 0.015 \times 100 = 1.5\,\text{V} \\
V_{200} &= IR = 0.015 \times 200 = 3.0\,\text{V}
\end{aligned}
$$</p>
<p>Their sum is $1.5+3.0=4.5\,\text{V}$, which matches the battery voltage.</p>

<ul>
  <li>In a series circuit, the same current flows through every resistor</li>
  <li>Potential difference is divided in proportion to resistance</li>
  <li>Battery voltage = sum of the potential differences across the resistors</li>
</ul>
"""
);
