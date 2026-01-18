import '../../model.dart'; // Videoクラス定義が別ならインポート
final inductorReactance = Video(
  isExperiment: true,
  category: 'electroMagnetism',
  iconName: "",
  // inPreparation: true,
  title: "コイルのリアクタンス",
  videoURL: "（動画URLをここに）",
  equipment: ["コイル（300 μH）", "周波数発生器", "オシロスコープ", "マルチメータ"],
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

<p>交流のオーム則 $I = \dfrac{V}{X_L}$ より、</p>
<p>$$
\begin{aligned}
I_{\mathrm{rms}} &= \frac{2.0}{131.95} \\
                 &\fallingdotseq 1.52\times10^{-2}\ \mathrm{A}
\end{aligned}
$$</p>

<div class="common-box">答え</div>
<p>電流の実効値：</p>
<p>$$\boxed{I_{\mathrm{rms}} \fallingdotseq 15.2\ \mathrm{mA}}$$</p>
"""
);
