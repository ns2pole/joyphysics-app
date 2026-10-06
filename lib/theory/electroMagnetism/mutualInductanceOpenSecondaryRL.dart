import '../../model.dart'; // TheoryTopic クラス

final mutualInductanceOpenSecondaryRL = TheoryTopic(
  title: '相互誘導：容量無視・開放二次（R–L–Rin）モデルと具体計算',
  titleEn: 'Mutual induction: open-secondary (R–L–Rin) model neglecting capacitance, with calculations',
  // imageAsset: 'assets/images/mutual_inductance_open_secondary_rl.png', // 未用意のためコメントアウト
  latexContent: r"""
<div class="common-box">記号（すべて冒頭に定義）</div>
\begin{aligned}
V_{1,\mathrm{rms}} &= \text{一次印加電圧の実効値} \\[2pt]
&= 5\,\mathrm{V} \\[6pt]
V_{1,\mathrm{peak}} &= \text{一次印加電圧のピーク値} \\[2pt]
&= \sqrt{2}\,V_{1,\mathrm{rms}} \\[6pt]
R_1 &= \text{一次抵抗} \\[2pt]
&= 10\,\Omega \\[6pt]
L_1 &= \text{一次自己インダクタンス} \\[2pt]
&= 10\,\mu\mathrm{H} \\[6pt]
I_{1,\mathrm{rms}} &= \text{一次電流の実効値} \\[2pt]
&= \dfrac{V_{1,\mathrm{rms}}}{\sqrt{R_1^2 + (\omega L_1)^2}} \\[6pt]
I_{1,\mathrm{peak}} &= \text{一次電流のピーク値} \\[2pt]
&= \sqrt{2}\,I_{1,\mathrm{rms}} \\[6pt]
R_2 &= \text{二次抵抗} \\[2pt]
&= 20\,\Omega \\[6pt]
L_2 &= \text{二次自己インダクタンス} \\[2pt]
&= 40\,\mu\mathrm{H}\ \bigl(N_2/N_1=2\bigr) \\[6pt]
R_{\mathrm{in}} &= \text{電圧計（測定器）の入力抵抗} \\[2pt]
&= 10\,\mathrm{M}\Omega \\[6pt]
R_\Sigma &= \text{二次直列合成抵抗} \\[2pt]
&= R_2 + R_{\mathrm{in}} \\[6pt]
i_{2,\mathrm{rms}} &= \text{二次回路電流の実効値} \\[2pt]
&= \dfrac{E_{\mathrm{rms}}}{\sqrt{R_\Sigma^2 + (\omega L_2)^2}} \\[6pt]
i_{2,\mathrm{peak}} &= \text{二次回路電流のピーク値} \\[2pt]
&= \sqrt{2}\,i_{2,\mathrm{rms}} \\[6pt]
V_{2,\mathrm{rms}} &= \text{二次端子の電圧（測定値：実効値）} \\[2pt]
&= i_{2,\mathrm{rms}}\,R_{\mathrm{in}} \\[6pt]
E_{\mathrm{rms}} &= \text{二次の誘起起電力（実効値）} \\[2pt]
&= M\,\omega\,I_{1,\mathrm{rms}} \\[6pt]
E_{\text{peak}} &= \text{二次の誘起起電力（ピーク）} \\[2pt]
&= M\,\omega\,I_{1,\mathrm{peak}} \\[6pt]
k &= \text{結合係数} \\[2pt]
&\fallingdotseq 0.98 \\[6pt]
M &= \text{相互インダクタンス} \\[2pt]
&= k\sqrt{L_1 L_2} \\[6pt]
f &= \text{周波数} \\[2pt]
&\text{（可変）} \\[6pt]
\omega &= 2\pi f \\[6pt]
\phi_1 &= \text{一次の電圧に対する一次電流の位相遅れ} \\[6pt]
\phi_2 &= \text{二次の起電力／電流の位相} \\[6pt]
v_1(t) &= \text{一次の瞬時電圧（例： } \sqrt{2}V_{1,\mathrm{rms}}\cos \omega t \text{）} \\[6pt]
i_1(t) &= \text{一次の瞬時電流} \\[6pt]
v_2(t) &= \text{二次端子の瞬時電圧} \\[6pt]
i_2(t) &= \text{二次回路の瞬時電流}
\end{aligned}

<div class="common-box">本記事の対象（微分方程式）</div>
\begin{aligned}
v_1(t) &= R_1\,i_1(t) \;+\; L_1\,i_1'(t) \;+\; M\,i_2'(t) \\[6pt]
0 &= R_\Sigma\,i_2(t) \;+\; L_2\,i_2'(t) \;+\; M\,i_1'(t)
\end{aligned}

<div class="common-box">問題設定／幾何</div>
\begin{aligned}
& \text{一次・二次は同軸で面を共有し（}k\fallingdotseq 1\text{）、容量は無視する。} \\[4pt]
& \text{一次は電圧源 }V_{1,\mathrm{rms}}\text{ で正弦駆動する。} \\[4pt]
& \text{二次は }R_2\text{ と }R_{\mathrm{in}}\text{ の直列（開放二次を高抵抗で閉回路化）とみなす。} \\[4pt]
& \text{観測量は }V_{2,\mathrm{rms}}\text{（電圧計の読み）とする。}
\end{aligned}

<div class="theory-common-box">命題 1（一次の実効電流）：一次が実効値 \(\displaystyle V_{1,\mathrm{rms}}\) の正弦電圧で駆動されるとき，下記を満たす。
\begin{aligned}
I_{1,\mathrm{rms}} &= \dfrac{V_{1,\mathrm{rms}}}{\sqrt{R_1^2 + (\omega L_1)^2}}
\end{aligned}
</div>

<div class="proof-box">
\begin{aligned}
v_1(t) &= R_1\,i_1(t) \;+\; L_1\,i_1'(t) \quad (\text{二次の反作用 }M i_2'\ \text{は }R_{\mathrm{in}}\ \text{巨大のため微小}) \\[6pt]
&\Rightarrow\ \text{定常正弦で }|Z_1| = \sqrt{R_1^2 + (\omega L_1)^2} \\[6pt]
&\Rightarrow\ I_{1,\mathrm{rms}} = \dfrac{V_{1,\mathrm{rms}}}{|Z_1|} \\[2pt]
&= \dfrac{V_{1,\mathrm{rms}}}{\sqrt{R_1^2 + (\omega L_1)^2}}
\end{aligned}
</div>

<div class="theory-common-box">命題 2（二次の誘起起電力）：一次電流が上の \(\displaystyle I_{1,\mathrm{rms}}\) を満たすとき，二次の誘起起電力（実効値）は下記で表される。
\begin{aligned}
E_{\mathrm{rms}} &= M\,\omega\,I_{1,\mathrm{rms}}
\end{aligned}
</div>

<div class="proof-box">
\begin{aligned}
e_2(t) &= -\,M\,i_1'(t) \\[6pt]
&\Rightarrow\ \text{正弦定常の振幅 }E_{\text{peak}} = M\,\omega\,I_{1,\text{peak}} \\[6pt]
&\Rightarrow\ E_{\mathrm{rms}} = \dfrac{E_{\text{peak}}}{\sqrt{2}} \\[2pt]
&= M\,\omega\,I_{1,\mathrm{rms}}
\end{aligned}
</div>

<div class="theory-common-box">命題 3（二次回路の電流と端子電圧）：二次直列回路 \(\displaystyle R_\Sigma\)–\(\displaystyle L_2\) を \(\displaystyle E_{\mathrm{rms}}\) が駆動するとき，下記を満たす。
\begin{aligned}
i_{2,\mathrm{rms}} &= \dfrac{E_{\mathrm{rms}}}{\sqrt{R_\Sigma^2 + (\omega L_2)^2}} \\[6pt]
V_{2,\mathrm{rms}} &= i_{2,\mathrm{rms}}\,R_{\mathrm{in}}
\end{aligned}
</div>

<div class="proof-box">
\begin{aligned}
E_{\mathrm{rms}} &= v_R \;+\; v_L \\[4pt]
&= R_\Sigma\,i_{2,\mathrm{rms}} \;+\; (\omega L_2)\,i_{2,\mathrm{rms}}\cdot(\text{直交和}) \\[6pt]
&\Rightarrow\ i_{2,\mathrm{rms}} = \dfrac{E_{\mathrm{rms}}}{\sqrt{R_\Sigma^2 + (\omega L_2)^2}} \\[6pt]
&\Rightarrow\ V_{2,\mathrm{rms}} = i_{2,\mathrm{rms}}\,R_{\mathrm{in}}
\end{aligned}
</div>

<div class="theory-common-box">命題 4（高周波極限の伝達比）：\(\displaystyle \omega L_1 \gg R_1\) かつ \(\displaystyle R_{in} \gg \omega L_2,\,R_2\) のとき，下記を満たす。
\begin{aligned}
\dfrac{V_{2,\mathrm{rms}}}{V_{1,\mathrm{rms}}}
&= \dfrac{M}{L_1} \\[4pt]
&= k\,\sqrt{\dfrac{L_2}{L_1}} \\[4pt]
&\fallingdotseq k\,\dfrac{N_2}{N_1}
\end{aligned}
</div>

<div class="proof-box">
\begin{aligned}
I_{1,\mathrm{rms}}
&= \dfrac{V_{1,\mathrm{rms}}}{\sqrt{R_1^{2} + (\omega L_1)^{2}}} \\[6pt]
\omega L_1 \gg R_1
&\Rightarrow \sqrt{R_1^{2} + (\omega L_1)^{2}}
= \omega L_1\,\sqrt{1 + \Bigl(\dfrac{R_1}{\omega L_1}\Bigr)^{2}} \\[2pt]
&\Rightarrow I_{1,\mathrm{rms}}
= \dfrac{V_{1,\mathrm{rms}}}{\omega L_1}\,
  \dfrac{1}{\sqrt{1 + \Bigl(\dfrac{R_1}{\omega L_1}\Bigr)^{2}}} \\[2pt]
&\Rightarrow I_{1,\mathrm{rms}}
\fallingdotseq \dfrac{V_{1,\mathrm{rms}}}{\omega L_1}
\end{aligned}

\begin{aligned}
E_{\mathrm{rms}}
&= M\,\omega\,I_{1,\mathrm{rms}} \\[2pt]
&\fallingdotseq M\,\omega\,\dfrac{V_{1,\mathrm{rms}}}{\omega L_1} \\[2pt]
&= \dfrac{M}{L_1}\,V_{1,\mathrm{rms}}
\end{aligned}

\begin{aligned}
R_{in} \gg \omega L_2,\,R_2
&\Rightarrow \sqrt{(R_2+R_{in})^{2} + (\omega L_2)^{2}}
= R_{in}\,\sqrt{1 + \Bigl(\dfrac{R_2}{R_{in}}\Bigr)^{2}
                 + \Bigl(\dfrac{\omega L_2}{R_{in}}\Bigr)^{2}} \\[2pt]
&\Rightarrow \sqrt{(R_2+R_{in})^{2} + (\omega L_2)^{2}}
\fallingdotseq R_{in} \\[4pt]
\Rightarrow V_{2,\mathrm{rms}}
&= i_{2,\mathrm{rms}}\,R_{in} \\[2pt]
&= \dfrac{E_{\mathrm{rms}}}{\sqrt{(R_2+R_{in})^{2} + (\omega L_2)^{2}}}\,R_{in} \\[2pt]
&\fallingdotseq E_{\mathrm{rms}}
\end{aligned}

\begin{aligned}
\Leftrightarrow\ \dfrac{V_{2,\mathrm{rms}}}{V_{1,\mathrm{rms}}}
&\fallingdotseq \dfrac{E_{\mathrm{rms}}}{V_{1,\mathrm{rms}}} \\[2pt]
&= \dfrac{M}{L_1} \\[6pt]
\Leftrightarrow\ \dfrac{M}{L_1}
&= \dfrac{k\sqrt{L_1L_2}}{L_1} \\[2pt]
&= k\,\sqrt{\dfrac{L_2}{L_1}} \\[2pt]
&\fallingdotseq k\,\dfrac{N_2}{N_1}\qquad\bigl(L\propto N^{2}\bigr)
\end{aligned}
</div>

<div class="common-box">数値代入</div>
\begin{aligned}
L_1 &= 10\,\mu\mathrm{H} \\[2pt]
R_1 &= 10\,\Omega \\[2pt]
N_2/N_1 &= 2 \\[2pt]
\Rightarrow\ L_2 &= 40\,\mu\mathrm{H} \\[2pt]
R_2 &= 20\,\Omega \\[2pt]
R_{\mathrm{in}} &= 10\,\mathrm{M}\Omega \\[2pt]
k &\fallingdotseq 1.00 \\[2pt]
M &= k\sqrt{L_1 L_2} \\[2pt]
&= \sqrt{10\times 40}\times 10^{-6}\,\mathrm{H} \\[2pt]
&= \boxed{2.00\times 10^{-5}\,\mathrm{H}} \\[6pt]
f_c &= \dfrac{R_1}{2\pi L_1} \\[2pt]
&= \dfrac{10}{2\pi\times 10^{-5}} \\[2pt]
&= \boxed{1.60\times 10^{5}\ \mathrm{Hz}}
\end{aligned}

\begin{aligned}
\text{例：}\ f &= 1.0\,\mathrm{kHz} \\[4pt]
\omega &= 2\pi f \\[2pt]
&= 6.2832\times 10^{3}\ \mathrm{rad/s} \\[4pt]
I_{1,\mathrm{rms}} &= \dfrac{5}{\sqrt{10^{2} + (\omega\times 10^{-5})^{2}}} \\[2pt]
&= 0.499990\ \mathrm{A} \\[4pt]
E_{\mathrm{rms}} &= M\,\omega\,I_{1,\mathrm{rms}} \\[2pt]
&= (2.00\times 10^{-5})\times (6.2832\times 10^{3})\times 0.499990 \\[2pt]
&= \boxed{6.28306\times 10^{-2}\ \mathrm{V}} \\[4pt]
i_{2,\mathrm{rms}} &= \dfrac{E_{\mathrm{rms}}}{\sqrt{(20+10^{7})^{2} + (\omega\times 40\times 10^{-6})^{2}}} \\[2pt]
&= 6.28306\times 10^{-9}\ \mathrm{A} \\[4pt]
V_{2,\mathrm{rms}} &= i_{2,\mathrm{rms}}\,R_{\mathrm{in}} \\[2pt]
&= \boxed{6.28306\times 10^{-2}\ \mathrm{V}}
\end{aligned}

\begin{aligned}
\text{例：}\ f &= 1.0\,\mathrm{MHz} \\[4pt]
\omega &= 2\pi f \\[2pt]
&= 6.2832\times 10^{6}\ \mathrm{rad/s} \\[4pt]
I_{1,\mathrm{rms}} &= \dfrac{5}{\sqrt{10^{2} + (\omega\times 10^{-5})^{2}}} \\[2pt]
&= 0.078588\ \mathrm{A} \\[4pt]
E_{\mathrm{rms}} &= M\,\omega\,I_{1,\mathrm{rms}} \\[2pt]
&= (2.00\times 10^{-5})\times (6.2832\times 10^{6})\times 0.078588 \\[2pt]
&= \boxed{9.87570\ \mathrm{V}} \\[4pt]
i_{2,\mathrm{rms}} &= \dfrac{E_{\mathrm{rms}}}{\sqrt{(20+10^{7})^{2} + (\omega\times 40\times 10^{-6})^{2}}} \\[2pt]
&= 9.87570\times 10^{-7}\ \mathrm{A} \\[4pt]
V_{2,\mathrm{rms}} &= i_{2,\mathrm{rms}}\,R_{\mathrm{in}} \\[2pt]
&= \boxed{9.87570\ \mathrm{V}}
\end{aligned}

\begin{aligned}
\text{高周波極限の確認}\quad
V_{2,\mathrm{rms}}^{(\infty)} &= \dfrac{M}{L_1}\,V_{1,\mathrm{rms}} \\[2pt]
&= \dfrac{2.00\times 10^{-5}}{10^{-5}}\times 5 \\[2pt]
&= \boxed{1.00\times 10^{1}\ \mathrm{V}}\ (=10.0\ \mathrm{V})
\end{aligned}

<div class="common-box">注記</div>
\begin{aligned}
& V_{2,\mathrm{rms}} \text{ は低周波で } \propto \omega,\ \text{高周波で } \to (M/L_1)V_1 \\[2pt]
& \text{巻数比と結合 }(kN_2/N_1)\text{ が高周波極限の伝達比を与える（ここでは }k\fallingdotseq 1\text{）。} \\[2pt]
& R_{\mathrm{in}}\ \text{は大きいほど }V_2\ \text{の読みが }E_{\mathrm{rms}}\ \text{に近づく}
\end{aligned}
""",
  latexContentEn: r"""
<div class="common-box">Symbols (all defined at the outset)</div>
\begin{aligned}
V_{1,\mathrm{rms}} &= \text{Primary applied voltage (RMS)} \\[2pt]
&= 5\,\mathrm{V} \\[6pt]
V_{1,\mathrm{peak}} &= \text{Primary applied voltage (peak)} \\[2pt]
&= \sqrt{2}\,V_{1,\mathrm{rms}} \\[6pt]
R_1 &= \text{Primary resistance} \\[2pt]
&= 10\,\Omega \\[6pt]
L_1 &= \text{Primary self-inductance} \\[2pt]
&= 10\,\mu\mathrm{H} \\[6pt]
I_{1,\mathrm{rms}} &= \text{Primary current (RMS)} \\[2pt]
&= \frac{V_{1,\mathrm{rms}}}{\sqrt{R_1^2 + (\omega L_1)^2}} \\[6pt]
I_{1,\mathrm{peak}} &= \text{Primary current (peak)} \\[2pt]
&= \sqrt{2}\,I_{1,\mathrm{rms}} \\[6pt]
R_2 &= \text{Secondary resistance} \\[2pt]
&= 20\,\Omega \\[6pt]
L_2 &= \text{Secondary self-inductance} \\[2pt]
&= 40\,\mu\mathrm{H}\ \bigl(N_2/N_1=2\bigr) \\[6pt]
R_{\mathrm{in}} &= \text{voltmeter (instrument) input resistance} \\[2pt]
&= 10\,\mathrm{M}\Omega \\[6pt]
R_\Sigma &= \text{secondary series combined resistance} \\[2pt]
&= R_2 + R_{\mathrm{in}} \\[6pt]
i_{2,\mathrm{rms}} &= \text{secondary circuit current (RMS)} \\[2pt]
&= \frac{E_{\mathrm{rms}}}{\sqrt{R_\Sigma^2 + (\omega L_2)^2}} \\[6pt]
i_{2,\mathrm{peak}} &= \text{secondary circuit current (peak)} \\[2pt]
&= \sqrt{2}\,i_{2,\mathrm{rms}} \\[6pt]
V_{2,\mathrm{rms}} &= \text{secondary terminal voltage (measured RMS)} \\[2pt]
&= i_{2,\mathrm{rms}}\,R_{\mathrm{in}} \\[6pt]
E_{\mathrm{rms}} &= \text{secondary induced emf (RMS)} \\[2pt]
&= M\,\omega\,I_{1,\mathrm{rms}} \\[6pt]
E_{\text{peak}} &= \text{secondary induced emf (peak)} \\[2pt]
&= M\,\omega\,I_{1,\mathrm{peak}} \\[6pt]
k &= \text{coupling coefficient} \\[2pt]
&\fallingdotseq 0.98 \\[6pt]
M &= \text{Mutual inductance} \\[2pt]
&= k\sqrt{L_1 L_2} \\[6pt]
f &= \text{frequency} \\[2pt]
&\text{(variable)} \\[6pt]
\omega &= 2\pi f \\[6pt]
\phi_1 &= \text{phase lag of primary current relative to primary voltage} \\[6pt]
\phi_2 &= \text{phase of secondary emf/current} \\[6pt]
v_1(t) &= \text{primary instantaneous voltage (e.g.\ } \sqrt{2}V_{1,\mathrm{rms}}\cos \omega t \text{）} \\[6pt]
i_1(t) &= \text{primary instantaneous current} \\[6pt]
v_2(t) &= \text{secondary terminal instantaneous voltage} \\[6pt]
i_2(t) &= \text{secondary circuit instantaneous current}
\end{aligned}

<div class="common-box">Target of this article (differential equation)</div>
\begin{aligned}
v_1(t) &= R_1\,i_1(t) \;+\; L_1\,i_1'(t) \;+\; M\,i_2'(t) \\[6pt]
0 &= R_\Sigma\,i_2(t) \;+\; L_2\,i_2'(t) \;+\; M\,i_1'(t)
\end{aligned}

<div class="common-box">Problem setup / geometry</div>
\begin{aligned}
& \text{Primary and secondary are coaxial and coplanar (}k\fallingdotseq 1\text{); capacitance is neglected.} \\[4pt]
& \text{The primary is driven sinusoidally by voltage source }V_{1,\mathrm{rms}}\text{.} \\[4pt]
& \text{The secondary is treated as }R_2\text{ in series with }R_{\mathrm{in}}\text{ (closing an open secondary through a high resistance).} \\[4pt]
& \text{The observed quantity is }V_{2,\mathrm{rms}}\text{ (voltmeter reading).}
\end{aligned}

<div class="theory-common-box">Proposition 1 (primary RMS current): When the primary is driven by a sinusoidal voltage of RMS value \(\displaystyle V_{1,\mathrm{rms}}\), we have:
\begin{aligned}
I_{1,\mathrm{rms}} &= \frac{V_{1,\mathrm{rms}}}{\sqrt{R_1^2 + (\omega L_1)^2}}
\end{aligned}
</div>

<div class="proof-box">
\begin{aligned}
v_1(t) &= R_1\,i_1(t) \;+\; L_1\,i_1'(t) \quad (\text{secondary reaction }M i_2'\ \text{is negligible because }R_{\mathrm{in}}\ \text{is huge}) \\[6pt]
&\Rightarrow\ \text{in steady sinusoids }|Z_1| = \sqrt{R_1^2 + (\omega L_1)^2} \\[6pt]
&\Rightarrow\ I_{1,\mathrm{rms}} = \frac{V_{1,\mathrm{rms}}}{|Z_1|} \\[2pt]
&= \frac{V_{1,\mathrm{rms}}}{\sqrt{R_1^2 + (\omega L_1)^2}}
\end{aligned}
</div>

<div class="theory-common-box">Proposition 2 (secondary induced emf): When the primary current satisfies \(\displaystyle I_{1,\mathrm{rms}}\) above, the secondary induced emf (RMS) is:
\begin{aligned}
E_{\mathrm{rms}} &= M\,\omega\,I_{1,\mathrm{rms}}
\end{aligned}
</div>

<div class="proof-box">
\begin{aligned}
e_2(t) &= -\,M\,i_1'(t) \\[6pt]
&\Rightarrow\ \text{steady sinusoidal amplitude }E_{\text{peak}} = M\,\omega\,I_{1,\text{peak}} \\[6pt]
&\Rightarrow\ E_{\mathrm{rms}} = \frac{E_{\text{peak}}}{\sqrt{2}} \\[2pt]
&= M\,\omega\,I_{1,\mathrm{rms}}
\end{aligned}
</div>

<div class="theory-common-box">Proposition 3 (secondary current and terminal voltage): When \(\displaystyle E_{\mathrm{rms}}\) drives the secondary series circuit \(\displaystyle R_\Sigma\)–\(\displaystyle L_2\), we have:
\begin{aligned}
i_{2,\mathrm{rms}} &= \frac{E_{\mathrm{rms}}}{\sqrt{R_\Sigma^2 + (\omega L_2)^2}} \\[6pt]
V_{2,\mathrm{rms}} &= i_{2,\mathrm{rms}}\,R_{\mathrm{in}}
\end{aligned}
</div>

<div class="proof-box">
\begin{aligned}
E_{\mathrm{rms}} &= v_R \;+\; v_L \\[4pt]
&= R_\Sigma\,i_{2,\mathrm{rms}} \;+\; (\omega L_2)\,i_{2,\mathrm{rms}}\cdot(\text{orthogonal sum}) \\[6pt]
&\Rightarrow\ i_{2,\mathrm{rms}} = \frac{E_{\mathrm{rms}}}{\sqrt{R_\Sigma^2 + (\omega L_2)^2}} \\[6pt]
&\Rightarrow\ V_{2,\mathrm{rms}} = i_{2,\mathrm{rms}}\,R_{\mathrm{in}}
\end{aligned}
</div>

<div class="theory-common-box">Proposition 4 (high-frequency transfer ratio): When \(\displaystyle \omega L_1 \gg R_1\) and \(\displaystyle R_{\mathrm{in}} \gg \omega L_2,\,R_2\), we have:
\begin{aligned}
\frac{V_{2,\mathrm{rms}}}{V_{1,\mathrm{rms}}}
&= \frac{M}{L_1} \\[4pt]
&= k\,\sqrt{\frac{L_2}{L_1}} \\[4pt]
&\fallingdotseq k\,\frac{N_2}{N_1}
\end{aligned}
</div>

<div class="proof-box">
\begin{aligned}
I_{1,\mathrm{rms}}
&= \frac{V_{1,\mathrm{rms}}}{\sqrt{R_1^{2} + (\omega L_1)^{2}}} \\[6pt]
\omega L_1 \gg R_1
&\Rightarrow \sqrt{R_1^{2} + (\omega L_1)^{2}}
= \omega L_1\,\sqrt{1 + \Bigl(\frac{R_1}{\omega L_1}\Bigr)^{2}} \\[2pt]
&\Rightarrow I_{1,\mathrm{rms}}
= \frac{V_{1,\mathrm{rms}}}{\omega L_1}\,
  \frac{1}{\sqrt{1 + \Bigl(\frac{R_1}{\omega L_1}\Bigr)^{2}}} \\[2pt]
&\Rightarrow I_{1,\mathrm{rms}}
\fallingdotseq \frac{V_{1,\mathrm{rms}}}{\omega L_1}
\end{aligned}

\begin{aligned}
E_{\mathrm{rms}}
&= M\,\omega\,I_{1,\mathrm{rms}} \\[2pt]
&\fallingdotseq M\,\omega\,\frac{V_{1,\mathrm{rms}}}{\omega L_1} \\[2pt]
&= \frac{M}{L_1}\,V_{1,\mathrm{rms}}
\end{aligned}

\begin{aligned}
R_{in} \gg \omega L_2,\,R_2
&\Rightarrow \sqrt{(R_2+R_{in})^{2} + (\omega L_2)^{2}}
= R_{in}\,\sqrt{1 + \Bigl(\frac{R_2}{R_{in}}\Bigr)^{2}
                 + \Bigl(\frac{\omega L_2}{R_{in}}\Bigr)^{2}} \\[2pt]
&\Rightarrow \sqrt{(R_2+R_{in})^{2} + (\omega L_2)^{2}}
\fallingdotseq R_{in} \\[4pt]
\Rightarrow V_{2,\mathrm{rms}}
&= i_{2,\mathrm{rms}}\,R_{in} \\[2pt]
&= \frac{E_{\mathrm{rms}}}{\sqrt{(R_2+R_{in})^{2} + (\omega L_2)^{2}}}\,R_{in} \\[2pt]
&\fallingdotseq E_{\mathrm{rms}}
\end{aligned}

\begin{aligned}
\Leftrightarrow\ \frac{V_{2,\mathrm{rms}}}{V_{1,\mathrm{rms}}}
&\fallingdotseq \frac{E_{\mathrm{rms}}}{V_{1,\mathrm{rms}}} \\[2pt]
&= \frac{M}{L_1} \\[6pt]
\Leftrightarrow\ \frac{M}{L_1}
&= \frac{k\sqrt{L_1L_2}}{L_1} \\[2pt]
&= k\,\sqrt{\frac{L_2}{L_1}} \\[2pt]
&\fallingdotseq k\,\frac{N_2}{N_1}\qquad\bigl(L\propto N^{2}\bigr)
\end{aligned}
</div>

<div class="common-box">Numerical substitution</div>
\begin{aligned}
L_1 &= 10\,\mu\mathrm{H} \\[2pt]
R_1 &= 10\,\Omega \\[2pt]
N_2/N_1 &= 2 \\[2pt]
\Rightarrow\ L_2 &= 40\,\mu\mathrm{H} \\[2pt]
R_2 &= 20\,\Omega \\[2pt]
R_{\mathrm{in}} &= 10\,\mathrm{M}\Omega \\[2pt]
k &\fallingdotseq 1.00 \\[2pt]
M &= k\sqrt{L_1 L_2} \\[2pt]
&= \sqrt{10\times 40}\times 10^{-6}\,\mathrm{H} \\[2pt]
&= \boxed{2.00\times 10^{-5}\,\mathrm{H}} \\[6pt]
f_c &= \frac{R_1}{2\pi L_1} \\[2pt]
&= \frac{10}{2\pi\times 10^{-5}} \\[2pt]
&= \boxed{1.60\times 10^{5}\ \mathrm{Hz}}
\end{aligned}

\begin{aligned}
\text{Example:}\ f &= 1.0\,\mathrm{kHz} \\[4pt]
\omega &= 2\pi f \\[2pt]
&= 6.2832\times 10^{3}\ \mathrm{rad/s} \\[4pt]
I_{1,\mathrm{rms}} &= \frac{5}{\sqrt{10^{2} + (\omega\times 10^{-5})^{2}}} \\[2pt]
&= 0.499990\ \mathrm{A} \\[4pt]
E_{\mathrm{rms}} &= M\,\omega\,I_{1,\mathrm{rms}} \\[2pt]
&= (2.00\times 10^{-5})\times (6.2832\times 10^{3})\times 0.499990 \\[2pt]
&= \boxed{6.28306\times 10^{-2}\ \mathrm{V}} \\[4pt]
i_{2,\mathrm{rms}} &= \frac{E_{\mathrm{rms}}}{\sqrt{(20+10^{7})^{2} + (\omega\times 40\times 10^{-6})^{2}}} \\[2pt]
&= 6.28306\times 10^{-9}\ \mathrm{A} \\[4pt]
V_{2,\mathrm{rms}} &= i_{2,\mathrm{rms}}\,R_{\mathrm{in}} \\[2pt]
&= \boxed{6.28306\times 10^{-2}\ \mathrm{V}}
\end{aligned}

\begin{aligned}
\text{Example:}\ f &= 1.0\,\mathrm{MHz} \\[4pt]
\omega &= 2\pi f \\[2pt]
&= 6.2832\times 10^{6}\ \mathrm{rad/s} \\[4pt]
I_{1,\mathrm{rms}} &= \frac{5}{\sqrt{10^{2} + (\omega\times 10^{-5})^{2}}} \\[2pt]
&= 0.078588\ \mathrm{A} \\[4pt]
E_{\mathrm{rms}} &= M\,\omega\,I_{1,\mathrm{rms}} \\[2pt]
&= (2.00\times 10^{-5})\times (6.2832\times 10^{6})\times 0.078588 \\[2pt]
&= \boxed{9.87570\ \mathrm{V}} \\[4pt]
i_{2,\mathrm{rms}} &= \frac{E_{\mathrm{rms}}}{\sqrt{(20+10^{7})^{2} + (\omega\times 40\times 10^{-6})^{2}}} \\[2pt]
&= 9.87570\times 10^{-7}\ \mathrm{A} \\[4pt]
V_{2,\mathrm{rms}} &= i_{2,\mathrm{rms}}\,R_{\mathrm{in}} \\[2pt]
&= \boxed{9.87570\ \mathrm{V}}
\end{aligned}

\begin{aligned}
\text{Check of the high-frequency limit}\quad
V_{2,\mathrm{rms}}^{(\infty)} &= \frac{M}{L_1}\,V_{1,\mathrm{rms}} \\[2pt]
&= \frac{2.00\times 10^{-5}}{10^{-5}}\times 5 \\[2pt]
&= \boxed{1.00\times 10^{1}\ \mathrm{V}}\ (=10.0\ \mathrm{V})
\end{aligned}

<div class="common-box">Notes</div>
\begin{aligned}
& V_{2,\mathrm{rms}} \text{ scales as } \propto \omega \text{ at low frequency and } \to (M/L_1)V_1 \text{ at high frequency} \\[2pt]
& \text{The turns ratio and coupling }(kN_2/N_1)\text{ give the high-frequency transfer ratio (here }k\fallingdotseq 1\text{).} \\[2pt]
& \text{the larger }R_{\mathrm{in}}\text{ is, the closer the }V_2\text{ reading approaches }E_{\mathrm{rms}}
\end{aligned}
""",
);
