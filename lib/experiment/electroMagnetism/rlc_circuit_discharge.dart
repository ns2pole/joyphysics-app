import '../../model.dart'; // Videoクラス定義

final rlc_circuit_discharge = Video(
  isExperiment: true,
  category: 'electroMagnetism',
  iconName: "", // アイコン未作成 → 空文字（UI側で空白を確保）
  title: "RLC回路（直列・放電）観測量：コンデンサ電圧 v_C(t)／代表値：周期T（L=5 mH, R=10 Ω, C=22 μF）",
  titleEn: "RLC circuit (series discharge): observe capacitor voltage v_C(t) / representative value: period T (L=5 mH, R=10 Ω, C=22 μF)",
  videoURL: "", // 動画があればIDを入れてください
  equipment: [
    "抵抗 10 Ω",
    "コンデンサ 22 μF",
    "インダクタ 5 mH（トロイダル自作）",
    "電源（初期充電 4.5 V）",
    "スイッチ（充電⇄放電）",
    "導線・クリップ",
    "マルチメータ（できればオシロスコープ）",
  ],
  equipmentEn: [
    "resistor 10 Ω",
    "capacitor 22 μF",
    "inductor 5 mH (homemade toroidal)",
    "power supply (initial charge 4.5 V)",
    "switch (charge ⇄ discharge)",
    "leads and clips",
    "multimeter (oscilloscope preferred)",
  ],
  costRating: "★★☆",
  latex: r"""
<div class="common-box">観測量と代表値</div>
<p>観測する物理量は <b>コンデンサ極板間電圧</b> \(v_C(t)\)。代表値として<b>周期 \(T\)</b>を比較する。</p>

<div class="common-box">条件</div>
<p>\(R=10\ \Omega,\quad L=5.0\ \mathrm{mH},\quad C=22\ \mu\mathrm{F},\quad V_0=4.5\ \mathrm{V}\)（初期電圧），印加電圧なし（自由放電）。</p>

<div class="common-box">理想LC（抵抗無視）</div>
\[
\begin{aligned}
T_{LC} &= 2\pi\sqrt{LC}\\
       &= 2\pi\sqrt{(5.0\,\mathrm{mH})(22\,\mu\mathrm{F})}\\
       &\fallingdotseq 2.0839\times 10^{-3}\ \mathrm{s} \\
       &\fallingdotseq \boxed{2.084\ \mathrm{ms}}
\end{aligned}
\]

<div class="common-box">実RLC（不足減衰・振動しつつ減衰）</div>
<p>不足減衰の判定： \(\displaystyle R<2\sqrt{\frac{L}{C}}\)。
数値的に \(\displaystyle 2\sqrt{\frac{L}{C}}\fallingdotseq 30.15\ \Omega > 10\ \Omega\) より不足減衰。</p>

<p>このときの振動周期 \(T\) は</p>
\[
\begin{aligned}
T &= \frac{2\pi}{\sqrt{\frac{1}{LC}-\left(\frac{R}{2L}\right)^2}}\\
  &= \frac{2\pi}{\sqrt{\frac{1}{(5.0\,\mathrm{mH})(22\,\mu\mathrm{F})}-\left(\frac{10}{2\cdot 5.0\,\mathrm{mH}}\right)^2}}\\
  &\fallingdotseq \boxed{2.209\ \mathrm{ms}}
\end{aligned}
\]

<div class="common-box">周期の比較</div>
\[
\begin{aligned}
\frac{T - T_{LC}}{T_{LC}}\times 100\% 
&\fallingdotseq \frac{2.209 - 2.084}{2.084}\times 100\%\\
&\fallingdotseq \boxed{+6.00\%}\quad(\text{実RLCの方が長い})
\end{aligned}
\]

<div class="common-box">時間応答（観測量 \(v_C(t)\) ）</div>
<p>一般解を初期条件 \(q(0)=Q_0=C V_0,\ i(0)=0\) に適用した \(v_C(t)=q(t)/C\) を、記号を増やさずに書く：</p>

\[
\begin{aligned}
v_C(t) 
&= V_0\,\exp\!\Big(-\frac{R}{2L}t\Big)\,
\Bigg[
\cos\!\Big(t\sqrt{\frac{1}{LC}-\Big(\frac{R}{2L}\Big)^2}\Big)
+ \frac{\frac{R}{2L}}{\sqrt{\frac{1}{LC}-\Big(\frac{R}{2L}\Big)^2}}\,
  \sin\!\Big(t\sqrt{\frac{1}{LC}-\Big(\frac{R}{2L}\Big)^2}\Big)
\Bigg]
\end{aligned}
\]

<p>数値代入（\(V_0=4.5\ \mathrm{V}\)）：</p>
\[
\begin{aligned}
v_C(t)
&= 4.5\,\exp(-1000\,t)\,
\Big[\cos(2844.452\,t)+0.35156\,\sin(2844.452\,t)\Big]\ \mathrm{V}
\end{aligned}
\]

<div class="common-box">メモ</div>
<ul style="line-height:1.6;">
  <li>周期は理想より約 6% 長い。抵抗が大きいほど長くなり、やがて振動しなくなる。</li>
  <li>オシロがあれば \(v_C(t)\) の減衰振動から周期を読み取れる。マルチメータならピーク間隔の目視でも可。</li>
</ul>
""",
  latexEn: r"""
<div class="common-box">Observed quantity and representative value</div>
<p>The observed physical quantity is the <b>voltage across the capacitor plates</b> \(v_C(t)\). As a representative value, we compare the <b>period \(T\)</b>.</p>

<div class="common-box">Conditions</div>
<p>\(R=10\ \Omega,\quad L=5.0\ \mathrm{mH},\quad C=22\ \mu\mathrm{F},\quad V_0=4.5\ \mathrm{V}\) (initial voltage), no applied voltage (free discharge).</p>

<div class="common-box">Ideal LC (neglecting resistance)</div>
\[
\begin{aligned}
T_{LC} &= 2\pi\sqrt{LC}\\
       &= 2\pi\sqrt{(5.0\,\mathrm{mH})(22\,\mu\mathrm{F})}\\
       &\fallingdotseq 2.0839\times 10^{-3}\ \mathrm{s} \\
       &\fallingdotseq \boxed{2.084\ \mathrm{ms}}
\end{aligned}
\]

<div class="common-box">Actual RLC (underdamped: oscillating while decaying)</div>
<p>Underdamped condition: \(\displaystyle R<2\sqrt{\frac{L}{C}}\).
Numerically \(\displaystyle 2\sqrt{\frac{L}{C}}\fallingdotseq 30.15\ \Omega > 10\ \Omega\), so the circuit is underdamped.</p>

<p>The oscillation period \(T\) is then</p>
\[
\begin{aligned}
T &= \frac{2\pi}{\sqrt{\frac{1}{LC}-\left(\frac{R}{2L}\right)^2}}\\
  &= \frac{2\pi}{\sqrt{\frac{1}{(5.0\,\mathrm{mH})(22\,\mu\mathrm{F})}-\left(\frac{10}{2\cdot 5.0\,\mathrm{mH}}\right)^2}}\\
  &\fallingdotseq \boxed{2.209\ \mathrm{ms}}
\end{aligned}
\]

<div class="common-box">Period comparison</div>
\[
\begin{aligned}
\frac{T - T_{LC}}{T_{LC}}\times 100\% 
&\fallingdotseq \frac{2.209 - 2.084}{2.084}\times 100\%\\
&\fallingdotseq \boxed{+6.00\%}\quad(\text{actual RLC is longer})
\end{aligned}
\]

<div class="common-box">Time response (observed quantity \(v_C(t)\))</div>
<p>Applying the general solution to the initial conditions \(q(0)=Q_0=C V_0,\ i(0)=0\), write \(v_C(t)=q(t)/C\) without introducing extra symbols:</p>

\[
\begin{aligned}
v_C(t) 
&= V_0\,\exp\!\Big(-\frac{R}{2L}t\Big)\,
\Bigg[
\cos\!\Big(t\sqrt{\frac{1}{LC}-\Big(\frac{R}{2L}\Big)^2}\Big)
+ \frac{\frac{R}{2L}}{\sqrt{\frac{1}{LC}-\Big(\frac{R}{2L}\Big)^2}}\,
  \sin\!\Big(t\sqrt{\frac{1}{LC}-\Big(\frac{R}{2L}\Big)^2}\Big)
\Bigg]
\end{aligned}
\]

<p>Numerical substitution (\(V_0=4.5\ \mathrm{V}\)):</p>
\[
\begin{aligned}
v_C(t)
&= 4.5\,\exp(-1000\,t)\,
\Big[\cos(2844.452\,t)+0.35156\,\sin(2844.452\,t)\Big]\ \mathrm{V}
\end{aligned}
\]

<div class="common-box">Note</div>
<ul style="line-height:1.6;">
  <li>The period is about 6% longer than the ideal value. Larger resistance makes it longer, and eventually oscillation ceases.</li>
  <li>With an oscilloscope you can read the period from the decaying oscillation of \(v_C(t)\). With a multimeter, visual timing of peak intervals is also possible.</li>
</ul>
"""
);
