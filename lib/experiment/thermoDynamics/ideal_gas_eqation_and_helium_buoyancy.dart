import '../../model.dart'; // Videoクラス定義が別ならインポート

final ideal_gas_eqation_and_helium_buoyancy = Video(
  isExperiment: true,
  category: 'thermodynamics',
  // inPreparation: true,
  iconName: "",
  title: "理想気体の状態方程式とヘリウムの浮力",
  titleEn: "Ideal gas law and helium buoyancy",
  videoURL: "",
  equipment: [
    "ヘリウム（気体）",
    "ポリ袋（質量 1 g, 容量 1 L 程度）",
    "糸（重さは無視）",
    "はかり"
  ],
  equipmentEn: [
    "helium (gas)",
    "plastic bag (mass ~1 g, capacity ~1 L)",
    "string (weight neglected)",
    "scale"
  ],
  costRating: "★☆☆",
  latex: r"""
<div class="common-box">ポイント</div>
<p>浮力は排除された空気の重さに等しい（アルキメデスの原理）。
袋に入れたヘリウムの<b>有効揚力</b>（重りが軽くなる量）は
$$F_{\rm net}=(\rho_{\rm air}-\rho_{\rm He})\,g\,V - m_{\rm bag}\,g,$$
これを $g$ で割れば<b>質量換算</b>（何グラム軽くなるか）が得られる：
$$\Delta m=\frac{F_{\rm net}}{g}=(\rho_{\rm air}-\rho_{\rm He})\,V - m_{\rm bag}.$$
</p>
<ul>
  <li>$V$: 袋の体積 [m$^3$]</li>
  <li>$m_{\rm bag}$: 袋の質量 [kg]</li>
  <li>$\rho_{\rm air}$: 空気密度 [kg/m$^3$]（25℃, 1 atm で $\fallingdotseq1.184$）</li>
  <li>$\rho_{\rm He}$: ヘリウム密度 [kg/m$^3$]（25℃, 1 atm で $\displaystyle \frac{MP}{RT}\fallingdotseq0.164$）</li>
</ul>

<div class="common-box">問題設定</div>
<p>25℃・1 atm。体積 $V=1.0\ {\rm L}=1.0\times10^{-3}\ {\rm m^3}$ のヘリウムを、
質量 $m_{\rm bag}=1.0\ {\rm g}=1.0\times10^{-3}\ {\rm kg}$ のポリ袋に入れ、
重りに糸で結んだ。重りは<b>何グラム軽くなるか？</b></p>

<div class="common-box">理論値計算</div>
<p>密度（25℃, 1 atm）：
$$\rho_{\rm air}\fallingdotseq1.184,\qquad
\rho_{\rm He}=\frac{M_{\rm He}P}{RT}
=\frac{0.0040026\times101325}{8.3145\times298.15}\fallingdotseq0.164\ \ [{\rm kg/m^3}].$$
質量換算の軽くなる量：
$$
\begin{aligned}
\Delta m&=(\rho_{\rm air}-\rho_{\rm He})\,V - m_{\rm bag}\\
&=(1.184-0.164)\times(1.0\times10^{-3})-1.0\times10^{-3}\\
&\fallingdotseq(1.020\times10^{-3})-1.0\times10^{-3}\\
&=2.0\times10^{-5}\ {\rm kg}
=0.020\ {\rm g}.
\end{aligned}
$$
</p>

<div class="common-box">答え</div>
<p>重りは<b>約 $0.020\ {\rm g}$</b> 軽くなる（ごくわずか）。</p>
<p style="font-size:0.9em;">備考：湿度・気圧・温度で $\rho_{\rm air}$ が変わるため数％の差が出ます。袋や糸の追加質量、ヘリウムの漏れがあるとさらに小さくなります。</p>
""",
  latexEn: r"""
<div class="common-box">Key points</div>
<p>Buoyancy equals the weight of the displaced air (Archimedes' principle).
The <b>net lift</b> of helium in the bag (how much lighter the weight becomes) is
$$F_{\rm net}=(\rho_{\rm air}-\rho_{\rm He})\,g\,V - m_{\rm bag}\,g,$$
and dividing by $g$ gives the <b>mass equivalent</b> (how many grams lighter):
$$\Delta m=\frac{F_{\rm net}}{g}=(\rho_{\rm air}-\rho_{\rm He})\,V - m_{\rm bag}.$$
</p>
<ul>
  <li>$V$: bag volume [m$^3$]</li>
  <li>$m_{\rm bag}$: bag mass [kg]</li>
  <li>$\rho_{\rm air}$: air density [kg/m$^3$] ($\fallingdotseq1.184$ at 25℃, 1 atm)</li>
  <li>$\rho_{\rm He}$: helium density [kg/m$^3$] ($\displaystyle \frac{MP}{RT}\fallingdotseq0.164$ at 25℃, 1 atm)</li>
</ul>

<div class="common-box">Setup</div>
<p>At 25℃ and 1 atm, put helium of volume $V=1.0\ {\rm L}=1.0\times10^{-3}\ {\rm m^3}$
into a plastic bag of mass $m_{\rm bag}=1.0\ {\rm g}=1.0\times10^{-3}\ {\rm kg}$,
and tie it to a weight with string. <b>By how many grams does the weight become lighter?</b></p>

<div class="common-box">Theory</div>
<p>Densities (25℃, 1 atm):
$$\rho_{\rm air}\fallingdotseq1.184,\qquad
\rho_{\rm He}=\frac{M_{\rm He}P}{RT}
=\frac{0.0040026\times101325}{8.3145\times298.15}\fallingdotseq0.164\ \ [{\rm kg/m^3}].$$
Mass-equivalent lightening:
$$
\begin{aligned}
\Delta m&=(\rho_{\rm air}-\rho_{\rm He})\,V - m_{\rm bag}\\
&=(1.184-0.164)\times(1.0\times10^{-3})-1.0\times10^{-3}\\
&\fallingdotseq(1.020\times10^{-3})-1.0\times10^{-3}\\
&=2.0\times10^{-5}\ {\rm kg}
=0.020\ {\rm g}.
\end{aligned}
$$
</p>

<div class="common-box">Answer</div>
<p>The weight becomes about <b>$0.020\ {\rm g}$</b> lighter (very little).</p>
<p style="font-size:0.9em;">Note: $\rho_{\rm air}$ varies with humidity, pressure, and temperature, so a few-percent difference is expected. Extra mass of bag/string or helium leakage makes it even smaller.</p>
"""
);
