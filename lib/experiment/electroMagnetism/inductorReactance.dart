import '../../model.dart'; // Videoクラス定義が別ならインポート
final inductorReactance = Video(
  isExperiment: true,
  category: 'electroMagnetism',
  iconName: "",
  // inPreparation: true,
  title: "コイルのリアクタンス",
  titleEn: "Inductor reactance",
  videoURL: "（動画URLをここに）",
  equipment: ["コイル（300 μH）", "周波数発生器", "オシロスコープ", "マルチメータ"],
  equipmentEn: ["coil (300 μH)", "frequency generator", "oscilloscope", "multimeter"],
  costRating: "★★☆",
  latex: r"""
<div class="common-box">ポイント</div>
<p>コイルは交流に対して電流を流れにくくする性質を持つ。この性質を表す量が<strong>誘導リアクタンス</strong>で、</p>
<p>$$\displaystyle X_L = 2\pi f L$$</p>
<ul>
  <li>$X_L$: 誘導リアクタンス [Ω]</li>
  <li>$f$: 周波数 [Hz]</li>
  <li>$L$: インダクタンス [H]</li>
</ul>
<p>（補足）コイルでは<strong>電流が電圧より90°遅れる</strong>。</p>

<div class="common-box">問題設定</div>
<p>周波数 $f = 70{,}000\ \mathrm{Hz}$、インダクタンス $L = 300\ \mu\mathrm{H}$ のコイルに、電圧の実効値 $V = 2.0\ \mathrm{V}$ の交流を加えたとき、流れる電流の実効値 $I$ はいくらになるか？</p>

<div class="common-box">理論値計算</div>
<p>まず、誘導リアクタンスは</p>
<p>$$
\begin{aligned}
X_L &= 2\pi f L \\
    &= 2\pi \times 70{,}000 \times 300\times10^{-6} \\
    &= 2\pi \times 21 \\
    &= 42\pi \\
    &\fallingdotseq 131.95\ \mathrm{Ω}
\end{aligned}
$$</p>

<p>交流のオーム則 $\displaystyle I = \frac{V}{X_L}$ より、</p>
<p>$$
\begin{aligned}
I_{\mathrm{rms}} &= \frac{2.0}{131.95} \\
                 &\fallingdotseq 1.52\times10^{-2}\ \mathrm{A}
\end{aligned}
$$</p>

<div class="common-box">答え</div>
<p>電流の実効値：</p>
<p>$$\boxed{I_{\mathrm{rms}} \fallingdotseq 15.2\ \mathrm{mA}}$$</p>
""",
  latexEn: r"""
<div class="common-box">Key points</div>
<p>A coil impedes alternating current. The quantity that expresses this property is <strong>inductive reactance</strong>,</p>
<p>$$\displaystyle X_L = 2\pi f L$$</p>
<ul>
  <li>$X_L$: inductive reactance [Ω]</li>
  <li>$f$: frequency [Hz]</li>
  <li>$L$: inductance [H]</li>
</ul>
<p>(Note) In a coil, <strong>the current lags the voltage by 90°</strong>.</p>

<div class="common-box">Setup</div>
<p>When an AC voltage of rms value $V = 2.0\ \mathrm{V}$ is applied to a coil of inductance $L = 300\ \mu\mathrm{H}$ at frequency $f = 70{,}000\ \mathrm{Hz}$, what is the rms current $I$?</p>

<div class="common-box">Theoretical calculation</div>
<p>First, the inductive reactance is</p>
<p>$$
\begin{aligned}
X_L &= 2\pi f L \\
    &= 2\pi \times 70{,}000 \times 300\times10^{-6} \\
    &= 2\pi \times 21 \\
    &= 42\pi \\
    &\fallingdotseq 131.95\ \mathrm{Ω}
\end{aligned}
$$</p>

<p>From Ohm's law for AC, $\displaystyle I = \frac{V}{X_L}$,</p>
<p>$$
\begin{aligned}
I_{\mathrm{rms}} &= \frac{2.0}{131.95} \\
                 &\fallingdotseq 1.52\times10^{-2}\ \mathrm{A}
\end{aligned}
$$</p>

<div class="common-box">Answer</div>
<p>rms current:</p>
<p>$$\boxed{I_{\mathrm{rms}} \fallingdotseq 15.2\ \mathrm{mA}}$$</p>
"""
);
