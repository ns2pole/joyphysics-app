import '../../model.dart'; // Videoクラス定義が別ならインポート
final capacitorReactance = Video(
  isExperiment: true,
  category: 'electroMagnetism',
  // inPreparation: true,
  iconName: "",
  title: "コンデンサのリアクタンス",
  titleEn: "Capacitor reactance",
  videoURL: "（動画URLをここに）",
  equipment: ["コンデンサ（1.5 μF）", "信号発生器", "オシロスコープ", "マルチメータ"],
  equipmentEn: ["capacitor (1.5 μF)", "signal generator", "oscilloscope", "multimeter"],
  costRating: "★★☆",
  latex: r"""
<div class="common-box">ポイント</div>
<p>コンデンサは交流電流を通すが、周波数が低いほど電流が流れにくくなる。この性質を表す量を<strong>リアクタンス</strong>という。</p>
<p>コンデンサのリアクタンス$X_C$は次式で与えられる。</p>
<p>$$\displaystyle X_C = \frac{1}{2\pi f C}$$</p>
<p>ここで、</p>
<ul>
  <li>$X_C$: 容量性リアクタンス [Ω]</li>
  <li>$f$: 周波数 [Hz]</li>
  <li>$C$: 静電容量 [F]</li>
</ul>

<div class="common-box">問題設定</div>
<p>周波数 $f = 100\ \mathrm{Hz}$、静電容量 $C = 1.5\ \mu\mathrm{F}$ のコンデンサに、電圧の実効値 $V = 2.0\ \mathrm{V}$ の交流を加えたとき、流れる電流の実効値 $I$ はいくらになるか？</p>

<div class="common-box">理論値計算</div>
<p>まず、リアクタンスは次式で求められる。</p>
<p>$$
\begin{aligned}
X_C &= \frac{1}{2\pi f C} \\
    &= \frac{1}{2\pi \times 100 \times 1.5\times10^{-6}} \\
    &= 1.06\times10^{3}\ \mathrm{Ω}
\end{aligned}
$$</p>

<p>オームの法則（交流では $\displaystyle I = \frac{V}{X_C}$）より、電流の実効値 $I$ は</p>
<p>$$
\begin{aligned}
I &= \frac{V}{X_C} = \frac{2.0}{1.06\times10^{3}} \\
  &= 1.9\times10^{-3}\ \mathrm{A}
\end{aligned}
$$</p>

<div class="common-box">答え</div>
<p>電流の実効値：</p>
<p>$$\boxed{I \fallingdotseq 1.9\ \mathrm{mA}}$$</p>
""",
  latexEn: r"""
<div class="common-box">Key points</div>
<p>A capacitor passes alternating current, but current flows less readily at lower frequencies. The quantity that expresses this property is called <strong>reactance</strong>.</p>
<p>The capacitor reactance $X_C$ is given by</p>
<p>$$\displaystyle X_C = \frac{1}{2\pi f C}$$</p>
<p>where</p>
<ul>
  <li>$X_C$: capacitive reactance [Ω]</li>
  <li>$f$: frequency [Hz]</li>
  <li>$C$: capacitance [F]</li>
</ul>

<div class="common-box">Setup</div>
<p>When an AC voltage of rms value $V = 2.0\ \mathrm{V}$ is applied to a capacitor of capacitance $C = 1.5\ \mu\mathrm{F}$ at frequency $f = 100\ \mathrm{Hz}$, what is the rms current $I$?</p>

<div class="common-box">Theoretical calculation</div>
<p>First, the reactance is</p>
<p>$$
\begin{aligned}
X_C &= \frac{1}{2\pi f C} \\
    &= \frac{1}{2\pi \times 100 \times 1.5\times10^{-6}} \\
    &= 1.06\times10^{3}\ \mathrm{Ω}
\end{aligned}
$$</p>

<p>From Ohm's law for AC ($\displaystyle I = \frac{V}{X_C}$), the rms current $I$ is</p>
<p>$$
\begin{aligned}
I &= \frac{V}{X_C} = \frac{2.0}{1.06\times10^{3}} \\
  &= 1.9\times10^{-3}\ \mathrm{A}
\end{aligned}
$$</p>

<div class="common-box">Answer</div>
<p>rms current:</p>
<p>$$\boxed{I \fallingdotseq 1.9\ \mathrm{mA}}$$</p>
"""
);
