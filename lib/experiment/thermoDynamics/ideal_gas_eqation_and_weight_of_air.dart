import '../../model.dart'; // Videoクラス定義が別ならインポート

final ideal_gas_eqation_and_weight_of_air = Video(
  isExperiment: true,
  category: 'thermodynamics',
  // inPreparation: true,
  iconName: "",
  title: "理想気体の状態方程式と空気の重さ",
  videoURL: "",
  equipment: [
    "円筒容器（半径7.5 cm, 高さ13 cm）",
    "真空ポンプ",
    "圧力計（絶対圧）",
    "温度計"
  ],
  costRating: "★★☆",
  latex: r"""
<div class="common-box">ポイント</div>
<p>等温・定容では理想気体の状態式 $pV=nRT$ より $n \propto p$（$V,T$一定）。よって容器内の気体量は圧力に比例する。</p>

<div class="common-box">問題設定</div>
<p>半径 $R=7.5\ \mathrm{cm}$、高さ $H=13\ \mathrm{cm}$ の円筒容器内の空気を、等温（$25^\circ\mathrm{C}$）で大気圧の $\dfrac{3}{5}$ に減圧した。容器から「どれだけ空気が抜けたか」を<b>質量[ g ]</b>で求めよ。
（仮定：乾燥空気、$T=25^\circ\mathrm{C}=298.15\ \mathrm{K}$、$p_0=1.013\times10^5\ \mathrm{Pa}$、モル質量 $M=28.97\ \mathrm{g/mol}$）</p>

<div class="common-box">理論値計算</div>
<p>容器体積：
$$
\begin{aligned}
V_0 &= \pi R^2 H
= \pi (0.075)^2 \times 0.13 \\
&= 7.3125\times10^{-4}\pi \ \mathrm{m^3}
\fallingdotseq 2.296\times10^{-3}\ \mathrm{m^3}\ (\fallingdotseq 2.296\ \mathrm{L})
\end{aligned}
$$
等温・定容 $\Rightarrow\ \dfrac{n_1}{n_0}=\dfrac{p_1}{p_0}=\dfrac{3}{5}$。
したがって抜けた割合：
$$
\frac{n_0-n_1}{n_0}=1-\frac{3}{5}=\frac{2}{5}=0.4\ (40\%).
$$
大気圧換算体積にすると
$$
V_{\text{removed @1atm}}=\frac{2}{5}V_0 = 0.4\times 2.296\ \mathrm{L}
= 0.9184\ \mathrm{L}
= 9.184\times10^{-4}\ \mathrm{m^3}.
$$
理想気体より抜けたモル数（$T=298.15\ \mathrm{K}$）：
$$
n_{\text{removed}}
=\frac{p_0\,V_{\text{removed}}}{RT}
=\frac{(1.013\times10^5)\times(9.184\times10^{-4})}{8.3145\times 298.15}
\fallingdotseq 3.753\times10^{-2}\ \mathrm{mol}.
$$
質量（乾燥空気 $M=28.97\ \mathrm{g/mol}$）：
$$
m_{\text{removed}} = n_{\text{removed}}\,M
\fallingdotseq 0.03753\times 28.97
\fallingdotseq 1.09\ \mathrm{g}.
$$
</p>

<div class="common-box">答え</div>
<p>抜けた量（質量）：$$\boxed{m \fallingdotseq 1.09\ \mathrm{g}}$$</p>
<p style="font-size:0.95em;">参考：密度近似（乾燥空気 $1.184\ \mathrm{kg/m^3}$ @25℃,1 atm）でも $0.9184\ \mathrm{L}\times1.184\ \mathrm{g/L}\fallingdotseq 1.09\ \mathrm{g}$ と整合。</p>
"""
);
