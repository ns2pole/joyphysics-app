import '../../model.dart'; // Videoクラス定義が別ならインポート
final charles_s_law = Video(
  isExperiment: true,
  category: 'thermodynamics',
  // inPreparation: true,
  iconName: "",
  title: "シャルルの法則",
  videoURL: "",
  equipment: [
    "ガラス管（半径1.1 cm, 高さ8 cm）",
    "細いパイプ（半径2 mm）",
    "ゴム栓",
    "水（薄い膜の栓）",
    "温水/ヒーター",
    "温度計",
    "ものさし"
  ],
  costRating: "★★☆",
  latex: r"""
<div class="common-box">ポイント</div>
<p>水の栓がごく薄い膜なら重さによる圧力上昇は無視でき、ほぼ<b>等圧過程</b>（大気圧一定）。したがってシャルルの法則
$$\displaystyle \frac{V}{T}=\text{一定}\ \Rightarrow\ \Delta V = V_0\frac{\Delta T}{T_0}$$
をそのまま用いる。</p>
<p>増えた体積 $\Delta V$ はパイプ断面積 $A=\pi r^2$ で割ると上昇長さ $h$ に変換できる（$\Delta V=Ah$）。</p>

<div class="common-box">問題設定</div>
<p>半径 $R=1.1\ \mathrm{cm}$、高さ $H=8.0\ \mathrm{cm}$ のガラス管に空気を閉じ込め、半径 $r=2.0\ \mathrm{mm}$ の細いパイプ先端を<b>薄い水膜</b>で栓をする。温度を $24^\circ\mathrm{C}$ から $36^\circ\mathrm{C}$（12℃上昇）にしたとき、水の栓はどれだけ上昇するか？（理想気体、ガラス・水の熱膨張は無視）</p>

<div class="common-box">理論値計算</div>
<p>初期体積（円柱）：
$$
\begin{aligned}
V_0 &= \pi R^2 H = \pi (0.011)^2 \times 0.080 \\
&= 3.041\times10^{-5}\ \mathrm{m}^3 \quad (\fallingdotseq 30.41\ \mathrm{cm}^3)
\end{aligned}
$$
初期温度 $T_0=24^\circ\mathrm{C}=297.15\ \mathrm{K}$、上昇 $\Delta T=12\ \mathrm{K}$ より
$$
\Delta V = V_0\frac{\Delta T}{T_0}
= 3.041\times10^{-5}\times\frac{12}{297.15}
\fallingdotseq 1.228\times10^{-6}\ \mathrm{m}^3
\quad (\fallingdotseq 1.228\ \mathrm{cm}^3).
$$
パイプ断面積：
$$
A=\pi r^2=\pi(0.002)^2=1.257\times10^{-5}\ \mathrm{m}^2.
$$
上昇量（等圧）：
$$
h=\frac{\Delta V}{A}
=\frac{1.228\times10^{-6}}{1.257\times10^{-5}}
\fallingdotseq 9.77\times10^{-2}\ \mathrm{m}
= 9.77\ \mathrm{cm}.
$$
</p>

<div class="common-box">答え</div>
<p>$$\boxed{h \fallingdotseq 9.8\ \mathrm{cm}}$$</p>
"""
);
