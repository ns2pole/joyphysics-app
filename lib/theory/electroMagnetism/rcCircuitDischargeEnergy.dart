import '../../model.dart';

final rcCircuitDischargeEnergy = TheoryTopic(
  title: 'RC回路におけるエネルギー(放電)',
  titleEn: 'Energy in an RC circuit (discharging)',
  inPreparation: true,
  imageAsset: 'assets/mindMap/forTopics/rcCircuitDischarge.png',
  latexContent: r"""
<div class="theory-common-box">出発点（キルヒホッフ式に \(\displaystyle I(t)\) を掛ける）</div>

<div class="proof-box">記号,記法の定義</div>


<div class="theory-common-box">命題 1：\(\displaystyle \dfrac{Q(t)}{C}\,I(t) - R I(t)^2 = 0\) が成り立つ。</div>

<div class="proof-box">証明</div>
上記の符号系の下でキルヒホッフの法則は
$$\begin{aligned}
\frac{Q(t)}{C} - R I(t) = 0
\end{aligned}$$
である（向きの定義により符号はこの形になる）。<br>
この式の両辺に電流 \(\displaystyle I(t)\) を掛けると
$$\begin{aligned}
\frac{Q(t)}{C}\,I(t) - R I(t)^2 = 0
\end{aligned}$$
となりこれは所望の式である。
Q.E.D
<div class="theory-common-box">命題 2：コンデンサーエネルギーの時間微分$\times (-1)$は \(\displaystyle \dfrac{Q}{C}I\) と等しい</div>

<div class="proof-box">証明</div>

コンデンサーのエネルギーを
$$\begin{aligned}
U_C(t) = \frac{Q(t)^2}{2C}
\end{aligned}$$
と定義する。これを時間微分すれば
$$\begin{aligned}
\frac{\mathrm{d}}{\mathrm{d}t}U_C(t) = \frac{Q(t)}{C}\frac{\mathrm{d}Q}{\mathrm{d}t}.
\end{aligned}$$
符号の定義 \(\displaystyle I(t) = -\dfrac{\mathrm{d}Q}{\mathrm{d}t}\) を用いると
$$\begin{aligned}
\frac{\mathrm{d}}{\mathrm{d}t}U_C(t) = -\frac{Q(t)}{C} I(t).
\end{aligned}$$
従って（符号に注意すると）恒等式
$$\begin{aligned}
\frac{Q(t)}{C} I(t) = -\frac{\mathrm{d}}{\mathrm{d}t}U_C(t)
\end{aligned}$$
が成り立つ。Q.E.D

<div class="theory-common-box">命題 3：抵抗の消費電力はコンデンサーのエネルギーの変化率の$-1$倍に等しい。</div>

<div class="proof-box">証明</div>

命題1と命題2の関係を組み合わせると
$$\begin{aligned}
- \frac{\mathrm{d}}{\mathrm{d}t}U_C(t) - R I(t)^2 = 0.
\end{aligned}$$
よって瞬時消費電力 \(\displaystyle P_R(t) = R I(t)^2\) とコンデンサーエネルギーの時間微分は
$$\begin{aligned}
P_R(t) = -\frac{\mathrm{d}}{\mathrm{d}t}U_C(t)
\end{aligned}$$
の関係にある。すなわち抵抗で瞬時に消費される電力はコンデンサーのエネルギー減少率に等しい。Q.E.D

<div class="theory-common-box">命題 4：時刻 \(\displaystyle 0\) から \(\displaystyle t\) までに抵抗が消費した累積エネルギーは、コンデンサーの初期エネルギーと時刻 \(\displaystyle t\) におけるエネルギーの差と等しい。</div>

<div class="proof-box">証明</div>

命題3の両辺を時刻 \(\displaystyle 0\) から \(\displaystyle t\) まで積分すると
$$
\begin{aligned}
&\ \int_0^{t} P_R(t')\mathrm{d}t' = - \int_0^{t}\frac{\mathrm{d}}{\mathrm{d}t}U_C(t')\mathrm{d}t'\\[6pt]
\Leftrightarrow &\ \int_0^{t} P_R(t')\mathrm{d}t' = - \Bigl(U_C(t) - U_C(0) \Bigr)\\[6pt]
\end{aligned}$$
ここで、$U_C(t) - U_C(0)$はコンデンサーの時刻0から$t$にかけてのエネルギー変化量を意味するのでこれを$\Delta U_C$と書くと、上式は
\begin{aligned}
\int_0^{t} P_R(t')\mathrm{d}t' = - \Delta U_C
\end{aligned}
左辺は抵抗で消費した電力(ジュール熱)を意味し、コンデンサーのエネルギー変化量が、抵抗で熱として消費された事を表している。Q.E.D

<div class="theory-common-box">命題 5：\(\displaystyle U_C(t)\) と \(\displaystyle P_R(t)\)、および \(\displaystyle E_R(t)\) の時間挙動は解析的に得られる。</div>

<div class="proof-box">証明</div>
<a href="app://topic?video=rcCircuitDischarge">こちらの記事で求めた</a>微分方程式 \(\displaystyle \dfrac{dQ}{dt} = -\displaystyle \frac{Q}{RC}\) の解
$$\begin{aligned}
\begin{cases}
Q(t)=\displaystyle Q_0 e^{-\frac{t}{RC}}\\[6pt]
I(t)=\displaystyle -\frac{Q_0}{RC}e^{-\frac{t}{RC}}
\end{cases}
\end{aligned}$$
を用いれば
$$\begin{aligned}
\displaystyle P_R(t)&=R I(t)^2=\frac{V_0^2}{R}e^{-\frac{2t}{RC}}\\[6pt]
\displaystyle U_C(t)&=\frac{Q_0^2}{2C}e^{-\frac{2t}{RC}}\\[6pt]
\displaystyle E_R(t) &= \int_0^t P_R(t') \, dt' \\[6pt]
&= \frac{1}{2} C V_0^2 \Bigl(1 - e^{-\frac{2t}{RC}}\Bigr)

\end{aligned}$$
を得る。Q.E.D

""",
  latexContentEn: r"""
<div class="theory-common-box">Starting point (multiply the Kirchhoff equation by \(\displaystyle I(t)\))</div>

<div class="proof-box">Definition of symbols and notation</div>


<div class="theory-common-box">Proposition 1: \(\displaystyle \frac{Q(t)}{C}\,I(t) - R I(t)^2 = 0\) holds.</div>

<div class="proof-box">Proof</div>
Under the sign convention above, Kirchhoff’s law is
$$\begin{aligned}
\frac{Q(t)}{C} - R I(t) = 0
\end{aligned}$$
(the signs take this form by the definition of orientation).<br>
Multiplying both sides by the current \(\displaystyle I(t)\) gives
$$\begin{aligned}
\frac{Q(t)}{C}\,I(t) - R I(t)^2 = 0
\end{aligned}$$
which is the desired equation.
Q.E.D
<div class="theory-common-box">Proposition 2: \((-1)\) times the time derivative of the capacitor energy equals \(\displaystyle \frac{Q}{C}I\)</div>

<div class="proof-box">Proof</div>

Define the capacitor energy by
$$\begin{aligned}
U_C(t) = \frac{Q(t)^2}{2C}
\end{aligned}$$
. Differentiating with respect to time yields
$$\begin{aligned}
\frac{\mathrm{d}}{\mathrm{d}t}U_C(t) = \frac{Q(t)}{C}\frac{\mathrm{d}Q}{\mathrm{d}t}.
\end{aligned}$$
Using the sign convention \(\displaystyle I(t) = -\frac{\mathrm{d}Q}{\mathrm{d}t}\),
$$\begin{aligned}
\frac{\mathrm{d}}{\mathrm{d}t}U_C(t) = -\frac{Q(t)}{C} I(t).
\end{aligned}$$
Hence (watching the signs) the identity
$$\begin{aligned}
\frac{Q(t)}{C} I(t) = -\frac{\mathrm{d}}{\mathrm{d}t}U_C(t)
\end{aligned}$$
holds. Q.E.D

<div class="theory-common-box">Proposition 3: The power dissipated in the resistor equals \((-1)\) times the rate of change of the capacitor energy.</div>

<div class="proof-box">Proof</div>

Combining Propositions 1 and 2 gives
$$\begin{aligned}
- \frac{\mathrm{d}}{\mathrm{d}t}U_C(t) - R I(t)^2 = 0.
\end{aligned}$$
Therefore the instantaneous dissipated power \(\displaystyle P_R(t) = R I(t)^2\) and the time derivative of the capacitor energy satisfy
$$\begin{aligned}
P_R(t) = -\frac{\mathrm{d}}{\mathrm{d}t}U_C(t)
\end{aligned}$$
. That is, the power instantly dissipated in the resistor equals the rate at which the capacitor energy decreases. Q.E.D

<div class="theory-common-box">Proposition 4: The cumulative energy dissipated in the resistor from time \(\displaystyle 0\) to \(\displaystyle t\) equals the difference between the capacitor’s initial energy and its energy at time \(\displaystyle t\).</div>

<div class="proof-box">Proof</div>

Integrating both sides of Proposition 3 from time \(\displaystyle 0\) to \(\displaystyle t\) yields
$$
\begin{aligned}
&\ \int_0^{t} P_R(t')\mathrm{d}t' = - \int_0^{t}\frac{\mathrm{d}}{\mathrm{d}t}U_C(t')\mathrm{d}t'\\[6pt]
\Leftrightarrow &\ \int_0^{t} P_R(t')\mathrm{d}t' = - \Bigl(U_C(t) - U_C(0) \Bigr)\\[6pt]
\end{aligned}$$
Here \(U_C(t) - U_C(0)\) is the change in capacitor energy from time 0 to \(t\); writing this as \(\Delta U_C\), the relation becomes
\begin{aligned}
\int_0^{t} P_R(t')\mathrm{d}t' = - \Delta U_C
\end{aligned}
The left-hand side is the energy (Joule heat) dissipated in the resistor, so the change in capacitor energy has been consumed as heat in the resistor. Q.E.D

<div class="theory-common-box">Proposition 5: The time dependence of \(\displaystyle U_C(t)\), \(\displaystyle P_R(t)\), and \(\displaystyle E_R(t)\) can be obtained analytically.</div>

<div class="proof-box">Proof</div>
Using the solution of the differential equation \(\displaystyle \frac{dQ}{dt} = -\frac{Q}{RC}\) obtained <a href="app://topic?video=rcCircuitDischarge">in this article</a>,
$$\begin{aligned}
\begin{cases}
Q(t)=\displaystyle Q_0 e^{-\frac{t}{RC}}\\[6pt]
I(t)=\displaystyle -\frac{Q_0}{RC}e^{-\frac{t}{RC}}
\end{cases}
\end{aligned}$$
one obtains
$$\begin{aligned}
\displaystyle P_R(t)&=R I(t)^2=\frac{V_0^2}{R}e^{-\frac{2t}{RC}}\\[6pt]
\displaystyle U_C(t)&=\frac{Q_0^2}{2C}e^{-\frac{2t}{RC}}\\[6pt]
\displaystyle E_R(t) &= \int_0^t P_R(t') \, dt' \\[6pt]
&= \frac{1}{2} C V_0^2 \Bigl(1 - e^{-\frac{2t}{RC}}\Bigr)

\end{aligned}$$
. Q.E.D

""",
);
