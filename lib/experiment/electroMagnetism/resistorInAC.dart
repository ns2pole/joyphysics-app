import '../../model.dart'; // Videoクラス定義が別ならインポート
final resistorInAC = Video(
  isExperiment: true,
  category: 'electroMagnetism',
  // inPreparation: true,
  iconName: "",
  title: "交流におけるオームの法則",
  videoURL: "（動画URLをここに）",
  equipment: ["抵抗（3.3 kΩ）", "信号発生器", "オシロスコープ", "マルチメータ"],
  costRating: "★★☆",
  latex: r"""
<div class="common-box">ポイント</div>
<p>理想的な抵抗では、交流でも直流と同様に<strong>電圧と電流は同相（位相差0°）</strong>で、インピーダンスは実数の $R$ のみとなる。したがって周波数$f$には依存しない。</p>
<p>交流のオームの法則：</p>
<p>$$\displaystyle I_{\mathrm{rms}}=\frac{V_{\mathrm{rms}}}{R}$$</p>
<ul>
  <li>$R$: 抵抗値 [Ω]</li>
  <li>$V_{\mathrm{rms}}$: 電圧の実効値 [V]</li>
  <li>$I_{\mathrm{rms}}$: 電流の実効値 [A]</li>
</ul>

<div class="common-box">問題設定</div>
<p>周波数 $f = 100\ \mathrm{Hz}$、抵抗 $R = 3.3\ \mathrm{k}\Omega$ の抵抗器に、電圧の実効値 $V = 2.0\ \mathrm{V}$ の交流を加えたとき、流れる電流の実効値 $I$ はいくらになるか？</p>

<div class="common-box">理論値計算</div>
<p>交流のオーム則より、</p>
<p>$$
\begin{aligned}
I_{\mathrm{rms}} &= \frac{V}{R}
= \frac{2.0}{3300} \\
&= 6.06\times10^{-4}\ \mathrm{A}
\end{aligned}
$$</p>

<div class="common-box">答え</div>
<p>電流の実効値：</p>
<p>$$\boxed{I_{\mathrm{rms}} \fallingdotseq 0.606\ \mathrm{mA}\ (\fallingdotseq 0.61\ \mathrm{mA})}$$</p>
<p style="font-size:0.95em;">（補足）理想抵抗では$f$に依らず一定。実験では配線の寄生インダクタ・コンデンサで高周波域にわずかな周波数依存が現れることがある。</p>
"""
);
