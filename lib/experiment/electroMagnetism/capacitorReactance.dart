import '../../model.dart'; // Videoクラス定義が別ならインポート
final capacitorReactance = Video(
  isExperiment: true,
  category: 'electroMagnetism',
  // inPreparation: true,
  iconName: "",
  title: "コンデンサのリアクタンス",
  videoURL: "（動画URLをここに）",
  equipment: ["コンデンサ（1.5 μF）", "信号発生器", "オシロスコープ", "マルチメータ"],
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

<p>オームの法則（交流では $I = V/X_C$）より、電流の実効値 $I$ は</p>
<p>$$
\begin{aligned}
I &= \frac{V}{X_C} = \frac{2.0}{1.06\times10^{3}} \\
  &= 1.9\times10^{-3}\ \mathrm{A}
\end{aligned}
$$</p>

<div class="common-box">答え</div>
<p>電流の実効値：</p>
<p>$$\boxed{I \fallingdotseq 1.9\ \mathrm{mA}}$$</p>
"""
);
