import '../../model.dart'; // TheoryTopic クラス

final mutualInductanceOpenSecondaryRL = TheoryTopic(
  title: '相互誘導：容量無視・開放二次（R–L–Rin）モデルと具体計算',
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
);
