import '../../model.dart'; // Video クラス

final coil_self_induction_voltage = Video(
  isExperiment: true,
  category: 'electroMagnetism',
  iconName: "", // 空ならUI側で空ボックスで幅確保
  title: "自己誘導：スイッチ開閉によるコイルの高電圧発生（E=3V, R1=47Ω, R2=100Ω, L=5mH）",
  titleEn: "Self-inductance: high voltage from a coil when switching (E=3V, R1=47Ω, R2=100Ω, L=5mH)",
  videoURL: "",
  equipment: [
    "直流電源（3 V）",
    "抵抗 47 Ω, 100 Ω",
    "コイル（5 mH）",
    "押しボタンスイッチ",
    "オシロスコープ（10:1 プローブ推奨）"
  ],
  equipmentEn: [
    "DC power supply (3 V)",
    "resistors 47 Ω, 100 Ω",
    "coil (5 mH)",
    "push-button switch",
    "oscilloscope (10:1 probe recommended)"
  ],
  costRating: "★☆☆",
  latex: r"""
<div class="common-box">記号（すべて冒頭に定義）</div>
\[
\begin{aligned}
E & = \text{電源電圧} \\[2pt]
  & = 3\,\mathrm{V} \\[6pt]
R_1 & = \text{直列抵抗（ON/OFF 共通経路）} \\[2pt]
    & = 47\,\Omega \\[6pt]
R_2 & = \text{OFF 時経路に直列の抵抗} \\[2pt]
    & = 100\,\Omega \\[6pt]
L & = \text{インダクタンス} \\[2pt]
  & = 5.0\times 10^{-3}\,\mathrm{H} \\[6pt]
i_1(t) & = \text{ON 中のコイル電流} \\[6pt]
i(t) & = \text{OFF 後のコイル電流} \\[6pt]
\tau_1 & = \frac{L}{R_1} \\[6pt]
\tau_2 & = \frac{L}{R_1+R_2} \\[6pt]
I_0 & = \frac{E}{R_1}
\end{aligned}
\]

<div class="common-box">問題設定／幾何（観測量と配線）</div>
<p>
直流電源 \(E\)・抵抗 \(R_1\)・コイル \(L\) を直列接続し、押しボタンで ON/OFF を切替える。OFF 時、電流の逃げ道として \(R_2\) を直列に加えた経路を用意する。観測する主量は \(i_1(t),\, i(t),\, v_{R_2}(0^+),\, v_L(0^+)\)。
</p>

<div class="common-box">キルヒホッフの法則（KCL/KVL の立式）</div>
<p><b>KCL：</b> 直列回路なので枝電流は各素子で等しい（分岐なし）。</p>
\[
\begin{aligned}
i_{\text{源}}(t) & = i_{R_1}(t) \\[2pt]
                 & = i_L(t)
\end{aligned}
\]
<p><b>KVL（ON 中）：</b> 電源・抵抗・コイルを一周して電圧和がゼロ。</p>
\[
\begin{aligned}
E - R_1\,i_1(t) - L\,\frac{di_1}{dt} & = 0
\end{aligned}
\]
<p><b>KVL（OFF 直後以降）：</b> 電源は切り離され，抵抗 \(R_1+R_2\) とコイルを一周。</p>
\[
\begin{aligned}
- R_1\,i(t) - R_2\,i(t) - L\,\frac{di}{dt} & = 0
\end{aligned}
\]

<div class="common-box">微分方程式の形（KVL を整理）</div>
\[
\begin{aligned}
L\,\frac{di_1}{dt} + R_1\,i_1(t) & = E \\[6pt]
L\,\frac{di}{dt} + (R_1+R_2)\,i(t) & = 0
\end{aligned}
\]

<div class="common-box">初期条件と連続性（コイル電流は不連続に変化しない）</div>
\[
\begin{aligned}
i_1(0) & = 0 \\[6pt]
i_1(\infty) & = I_0 \\[6pt]
i(0^+) & = I_0
\end{aligned}
\]
<p>
コイル電流は瞬時にジャンプできないため，OFF の瞬間 \(t=0^+\) における電流は ON 終了直前の定常電流 \(I_0\) に等しい。
</p>

<div class="common-box">解法（ON：一次不定微分方程式）</div>
\[
\begin{aligned}
i_1(t) & = I_0\Bigl(1 - e^{-t/\tau_1}\Bigr)
\end{aligned}
\]

<div class="common-box">解法（OFF：同次方程式）</div>
\[
\begin{aligned}
i(t) & = I_0\,e^{-t/\tau_2}
\end{aligned}
\]

<div class="common-box">遮断直後の電圧（極性に注意）</div>
\[
\begin{aligned}
v_{R_2}(0^+) & = R_2\,I_0 \\[6pt]
v_L(0^+) & = -\bigl(R_1+R_2\bigr)\,I_0
\end{aligned}
\]
<p>
符号はコイルが流れていた電流を保とうとする向きで定まり、電源極性と逆向きの電圧が立つ。
</p>

<div class="common-box">数値代入（最後にまとめて）</div>
\[
\begin{aligned}
I_0 & \underset{definition}{:=} \text{定常電流（ON の最終値）} \\[2pt]
    & = \frac{E}{R_1} \\[2pt]
    & = \frac{3}{47} \\[2pt]
    & = \boxed{0.0638\ \mathrm{A}} \\[10pt]
\tau_1 & \underset{definition}{:=} \text{ON 時の時定数} \\[2pt]
      & = \frac{L}{R_1} \\[2pt]
      & = \frac{0.005}{47} \\[2pt]
      & = \boxed{1.06\times 10^{-4}\ \mathrm{s}} \\[10pt]
\tau_2 & \underset{definition}{:=} \text{OFF 時の時定数} \\[2pt]
      & = \frac{L}{R_1+R_2} \\[2pt]
      & = \frac{0.005}{147} \\[2pt]
      & = \boxed{3.40\times 10^{-5}\ \mathrm{s}} \\[10pt]
v_{R_2}(0^+) & \underset{definition}{:=} \text{遮断直後の }R_2\text{ 両端電圧} \\[2pt]
            & = R_2\,I_0 \\[2pt]
            & = 100 \times 0.0638 \\[2pt]
            & = \boxed{6.38\ \mathrm{V}} \\[10pt]
v_{L}(0^+) & \underset{definition}{:=} \text{遮断直後のコイル電圧（逆極性）} \\[2pt]
          & = -\bigl(R_1+R_2\bigr)\,I_0 \\[2pt]
          & = -147 \times 0.0638 \\[2pt]
          & = \boxed{-9.38\ \mathrm{V}} \\[10pt]
U & \underset{definition}{:=} \text{ON 時にコイルへ蓄えられる磁場エネルギー} \\[2pt]
  & = \frac{1}{2} L I_0^2 \\[2pt]
  & = \frac{1}{2}\times 0.005 \times (0.0638)^2 \\[2pt]
  & = \boxed{1.02\times 10^{-5}\ \mathrm{J}}
\end{aligned}
\]

<div class="common-box">まとめ（設計指針）</div>
<ul>
  <li>ON：\(\tau_1\) で \(I_0\) に漸近。OFF：\(\tau_2\) で指数減衰。</li>
  <li>\(R_2\) を大きくすると \(|v_L(0^+)|\) は増大し、\(\tau_2\) は短縮。</li>
  <li>観測時は 10:1 プローブ、短いグラウンド、十分な帯域・サンプルでスパイクを捉える。</li>
</ul>

<div class="common-box">安全メモ</div>
<ul>
  <li>蓄積エネルギーは \(\sim 10\,\mu\mathrm{J}\) と小さいが、極性反転・高速過渡に注意。</li>
  <li>OFF 直後は導体に触れない。測定器の定格を遵守。</li>
</ul>
""",
  latexEn: r"""
<div class="common-box">Symbols (all defined at the start)</div>
\[
\begin{aligned}
E & = \text{supply voltage} \\[2pt]
  & = 3\,\mathrm{V} \\[6pt]
R_1 & = \text{series resistance (common path ON/OFF)} \\[2pt]
    & = 47\,\Omega \\[6pt]
R_2 & = \text{resistance in series on the OFF path} \\[2pt]
    & = 100\,\Omega \\[6pt]
L & = \text{inductance} \\[2pt]
  & = 5.0\times 10^{-3}\,\mathrm{H} \\[6pt]
i_1(t) & = \text{coil current while ON} \\[6pt]
i(t) & = \text{coil current after OFF} \\[6pt]
\tau_1 & = \frac{L}{R_1} \\[6pt]
\tau_2 & = \frac{L}{R_1+R_2} \\[6pt]
I_0 & = \frac{E}{R_1}
\end{aligned}
\]

<div class="common-box">Setup / geometry (observed quantities and wiring)</div>
<p>
Connect DC supply \(E\), resistor \(R_1\), and coil \(L\) in series, and switch ON/OFF with a push button. For OFF, provide a path that adds \(R_2\) in series as a current escape route. The main observed quantities are \(i_1(t),\, i(t),\, v_{R_2}(0^+),\, v_L(0^+)\).
</p>

<div class="common-box">Kirchhoff's laws (KCL/KVL formulation)</div>
<p><b>KCL:</b> In a series circuit the branch current is the same in each element (no branching).</p>
\[
\begin{aligned}
i_{\mathrm{src}}(t) & = i_{R_1}(t) \\[2pt]
                 & = i_L(t)
\end{aligned}
\]
<p><b>KVL (while ON):</b> Around the supply, resistor, and coil, the sum of voltages is zero.</p>
\[
\begin{aligned}
E - R_1\,i_1(t) - L\,\frac{di_1}{dt} & = 0
\end{aligned}
\]
<p><b>KVL (from immediately after OFF):</b> The supply is disconnected; go around resistors \(R_1+R_2\) and the coil.</p>
\[
\begin{aligned}
- R_1\,i(t) - R_2\,i(t) - L\,\frac{di}{dt} & = 0
\end{aligned}
\]

<div class="common-box">Differential equation form (rearranged KVL)</div>
\[
\begin{aligned}
L\,\frac{di_1}{dt} + R_1\,i_1(t) & = E \\[6pt]
L\,\frac{di}{dt} + (R_1+R_2)\,i(t) & = 0
\end{aligned}
\]

<div class="common-box">Initial conditions and continuity (coil current cannot jump)</div>
\[
\begin{aligned}
i_1(0) & = 0 \\[6pt]
i_1(\infty) & = I_0 \\[6pt]
i(0^+) & = I_0
\end{aligned}
\]
<p>
Because the coil current cannot jump instantaneously, the current at the OFF instant \(t=0^+\) equals the steady current \(I_0\) just before the end of ON.
</p>

<div class="common-box">Solution (ON: first-order inhomogeneous DE)</div>
\[
\begin{aligned}
i_1(t) & = I_0\Bigl(1 - e^{-t/\tau_1}\Bigr)
\end{aligned}
\]

<div class="common-box">Solution (OFF: homogeneous equation)</div>
\[
\begin{aligned}
i(t) & = I_0\,e^{-t/\tau_2}
\end{aligned}
\]

<div class="common-box">Voltage immediately after interruption (note the polarity)</div>
\[
\begin{aligned}
v_{R_2}(0^+) & = R_2\,I_0 \\[6pt]
v_L(0^+) & = -\bigl(R_1+R_2\bigr)\,I_0
\end{aligned}
\]
<p>
The sign is set by the direction in which the coil tries to maintain the current that was flowing, so a voltage opposite to the supply polarity appears.
</p>

<div class="common-box">Numerical substitution (collected at the end)</div>
\[
\begin{aligned}
I_0 & \underset{definition}{:=} \text{steady current (final ON value)} \\[2pt]
    & = \frac{E}{R_1} \\[2pt]
    & = \frac{3}{47} \\[2pt]
    & = \boxed{0.0638\ \mathrm{A}} \\[10pt]
\tau_1 & \underset{definition}{:=} \text{time constant while ON} \\[2pt]
      & = \frac{L}{R_1} \\[2pt]
      & = \frac{0.005}{47} \\[2pt]
      & = \boxed{1.06\times 10^{-4}\ \mathrm{s}} \\[10pt]
\tau_2 & \underset{definition}{:=} \text{time constant while OFF} \\[2pt]
      & = \frac{L}{R_1+R_2} \\[2pt]
      & = \frac{0.005}{147} \\[2pt]
      & = \boxed{3.40\times 10^{-5}\ \mathrm{s}} \\[10pt]
v_{R_2}(0^+) & \underset{definition}{:=} \text{voltage across }R_2\text{ just after interruption} \\[2pt]
            & = R_2\,I_0 \\[2pt]
            & = 100 \times 0.0638 \\[2pt]
            & = \boxed{6.38\ \mathrm{V}} \\[10pt]
v_{L}(0^+) & \underset{definition}{:=} \text{coil voltage just after interruption (reversed polarity)} \\[2pt]
          & = -\bigl(R_1+R_2\bigr)\,I_0 \\[2pt]
          & = -147 \times 0.0638 \\[2pt]
          & = \boxed{-9.38\ \mathrm{V}} \\[10pt]
U & \underset{definition}{:=} \text{magnetic energy stored in the coil while ON} \\[2pt]
  & = \frac{1}{2} L I_0^2 \\[2pt]
  & = \frac{1}{2}\times 0.005 \times (0.0638)^2 \\[2pt]
  & = \boxed{1.02\times 10^{-5}\ \mathrm{J}}
\end{aligned}
\]

<div class="common-box">Summary (design guidelines)</div>
<ul>
  <li>ON: approaches \(I_0\) with \(\tau_1\). OFF: decays exponentially with \(\tau_2\).</li>
  <li>Larger \(R_2\) increases \(|v_L(0^+)|\) and shortens \(\tau_2\).</li>
  <li>For observation, use a 10:1 probe, a short ground, and sufficient bandwidth/sampling to catch the spike.</li>
</ul>

<div class="common-box">Safety note</div>
<ul>
  <li>Stored energy is small (\(\sim 10\,\mu\mathrm{J}\)), but watch for polarity reversal and fast transients.</li>
  <li>Do not touch conductors immediately after OFF. Observe instrument ratings.</li>
</ul>
"""
);
