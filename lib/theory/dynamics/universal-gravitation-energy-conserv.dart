import '../../model.dart';

final universalGravitationEnergyConserv = TheoryTopic(
  title: '万有引力エネルギー保存',
  titleEn: 'Energy conservation under universal gravitation',
  isNew: false,
  imageAsset: 'assets/mindMap/forTopics/universalGravitationEnergyConserv.png',
  latexContent: r"""
<div class="theory-common-box">
  前提および記号の定義</div>
</div>
・プライム記号「 ' 」と$\displaystyle \frac{d}{dt}$の記号は見やすさで使い分けているだけで、全く同じ意味。どちらも時間微分を表す。<br>
・$\vec e_x, \vec e_y, \vec e_z$をそれぞれ $x,y,z$ 方向の単位ベクトルとする。<br>
・位置ベクトルは $\vec r(t) = x(t)\vec e_x+y(t)\vec e_y+z(t)\vec e_z$<br>
・速度ベクトルは $\vec v(t) = \dfrac{d\vec r}{dt}(t) = v_x(t)\vec e_x+v_y(t)\vec e_y+v_z(t)\vec e_z$<br>
・加速度ベクトルは $\vec a(t) = \dfrac{d\vec v}{dt}(t) = a_x(t)\vec e_x+a_y(t)\vec e_y+a_z(t)\vec e_z$<br>
・位置ベクトルの大きさは $r(t) = \lVert \vec r(t)\rVert = \sqrt{x(t)^2+y(t)^2+z(t)^2}$<br>
・速度ベクトルの大きさは $v(t) = \lVert \vec v(t)\rVert = \sqrt{v_x(t)^2+v_y(t)^2+v_z(t)^2}$<br>
・加速度ベクトルの大きさは $a(t) = \lVert \vec a(t)\rVert = \sqrt{a_x(t)^2+a_y(t)^2+a_z(t)^2}$<br>
とする。<br>
・運動方程式は$\ \displaystyle m\vec{a}(t):=-\frac{GMm}{r^3(t)}\vec{r}(t)$である。

<div class="theory-common-box">
補題1.$\displaystyle r(t)\frac{dr}{dt}(t)=x(t)v_x(t)+y(t)v_y(t)+z(t)v_z(t)$が成り立つ。
</div>
<div class="proof-box">証明</div>
$$\begin{aligned}
\frac{dr}{dt}(t)&=\frac{x(t)v_x(t)+y(t)v_y(t)+z(t)v_z(t)} {\sqrt{x(t)^2+y(t)^2+z(t)^2}}\\ \\
\Leftrightarrow \frac{dr}{dt}(t)&=\frac{x(t)v_x(t)+y(t)v_y(t)+z(t)v_z(t)}{r(t)}
\end{aligned}$$
より、上式の両辺に$r(t)$を掛ければ所望の式を得られる。　⬜︎
<div class="theory-common-box">
命題1.（エネルギー保存）
万有引力ポテンシャル下の物体の運動において、$${\displaystyle \frac{1}{2}mv^2(t)-\frac{GMm}{r(t)}}$$は初期条件で決まる、時間に依らない定数。
</div>
<div class="proof-box">証明</div>
$\displaystyle \frac{1}{2}mv^2(t)-\frac{GMm}{r(t)}$の時間微分が$0$である事を示す。
運動方程式から出発して、両辺に対し、速度ベクトルとの内積を計算する。
$$\begin{aligned}
&\ \ \ m\vec{a}(t)=-\frac{GMm}{r^3(t)}\vec{r}(t)\\
&\Rightarrow m\vec{a}(t)\cdot \vec{v}(t) =-\frac{GMm}{r^3(t)}\vec{r}(t)\cdot \vec{v}(t)\\
\end{aligned}$$

<div class="paragraph-box">左辺</div><br>
$$\begin{aligned}
\ &m\vec{a}(t)\cdot \vec{v}(t)\\
&=m\Bigr(a_x(t)v_x(t)+a_y(t)v_y(t)+a_z(t)v_z(t)\Bigr)\\
&=\frac{1}{2}m\Biggr(\Bigr(v_x(t)^2\Bigr)'+\Bigr(v_y(t)^2\Bigr)'+\Bigr(v_z(t)^2\Bigr)'\Biggr)\\
&=\frac{d}{dt}\Bigr(\frac{1}{2}mv^2(t)\Bigr)
\end{aligned}$$

<div class="paragraph-box">右辺</div><br>

$$\begin{aligned}
&\ \ \  -\frac{GMm}{r^3(t)}\vec{r}(t)\cdot \vec{v}(t)\\
&= -\frac{GMm}{r^3(t)}\Bigr(x(t)v_x(t)+y(t)v_y(t)+z(t)v_z(t)\Bigr)\\
&=-\frac{GMm}{r^3(t)}r(t)\frac{dr}{dt}(t)\\
&=-\frac{GMm}{r^2(t)}\frac{dr}{dt}(t)\\
&=\frac{d}{dt}\Bigr(\frac{GMm}{r(t)}\Bigr)\\
\end{aligned}$$

よって、

$$\begin{aligned}
& \ \ \  m\vec{a}(t)=-\frac{GMm}{r^3(t)}\vec{r}(t)\\
& \Rightarrow m\vec{a}(t)\cdot \vec{v}(t)=-\frac{GMm}{r^3(t)}\vec{r}(t)\cdot \vec{v}(t)\\
& \Leftrightarrow \frac{d}{dt}\Bigr(\frac{1}{2}mv^2(t)\Bigr)=\frac{d}{dt}\Bigr(\frac{GMm}{r(t)}\Bigr)\\
& \Leftrightarrow \frac{d}{dt}\Bigr(\frac{1}{2}mv^2(t)-\frac{GMm}{r(t)}\Bigr)=0\\
\end{aligned}$$
　⬜︎
""",
  latexContentEn: r"""
<div class="theory-common-box">
  Assumptions and notation</div>
</div>
•The prime “ ' ” and $\displaystyle \frac{d}{dt}$ are used interchangeably for readability; both mean time differentiation.<br>
•Let $\vec e_x, \vec e_y, \vec e_z$ be unit vectors in the $x,y,z$ directions.<br>
•Position: $\vec r(t) = x(t)\vec e_x+y(t)\vec e_y+z(t)\vec e_z$<br>
•Velocity: $\vec v(t) = \displaystyle\frac{d\vec r}{dt}(t) = v_x(t)\vec e_x+v_y(t)\vec e_y+v_z(t)\vec e_z$<br>
•Acceleration: $\vec a(t) = \displaystyle\frac{d\vec v}{dt}(t) = a_x(t)\vec e_x+a_y(t)\vec e_y+a_z(t)\vec e_z$<br>
•Position magnitude: $r(t) = \lVert \vec r(t)\rVert = \sqrt{x(t)^2+y(t)^2+z(t)^2}$<br>
•Speed: $v(t) = \lVert \vec v(t)\rVert = \sqrt{v_x(t)^2+v_y(t)^2+v_z(t)^2}$<br>
•Acceleration magnitude: $a(t) = \lVert \vec a(t)\rVert = \sqrt{a_x(t)^2+a_y(t)^2+a_z(t)^2}$<br>
.<br>
•The equation of motion is $\ \displaystyle m\vec{a}(t):=-\frac{GMm}{r^3(t)}\vec{r}(t)$.

<div class="theory-common-box">
Lemma 1. $\displaystyle r(t)\frac{dr}{dt}(t)=x(t)v_x(t)+y(t)v_y(t)+z(t)v_z(t)$ holds.
</div>
<div class="proof-box">Proof</div>
$$\begin{aligned}
\frac{dr}{dt}(t)&=\frac{x(t)v_x(t)+y(t)v_y(t)+z(t)v_z(t)} {\sqrt{x(t)^2+y(t)^2+z(t)^2}}\\ \\
\Leftrightarrow \frac{dr}{dt}(t)&=\frac{x(t)v_x(t)+y(t)v_y(t)+z(t)v_z(t)}{r(t)}
\end{aligned}$$
Multiplying both sides by $r(t)$ yields the claim.　⬜︎
<div class="theory-common-box">
Proposition 1 (energy conservation)
In motion under the gravitational potential, $${\displaystyle \frac{1}{2}mv^2(t)-\frac{GMm}{r(t)}}$$ is a constant fixed by the initial conditions and independent of time.
</div>
<div class="proof-box">Proof</div>
Show that the time derivative of $\displaystyle \frac{1}{2}mv^2(t)-\frac{GMm}{r(t)}$ is $0$.
Starting from the equation of motion, take the inner product of both sides with the velocity.
$$\begin{aligned}
&\ \ \ m\vec{a}(t)=-\frac{GMm}{r^3(t)}\vec{r}(t)\\
&\Rightarrow m\vec{a}(t)\cdot \vec{v}(t) =-\frac{GMm}{r^3(t)}\vec{r}(t)\cdot \vec{v}(t)\\
\end{aligned}$$

<div class="paragraph-box">Left-hand side</div><br>
$$\begin{aligned}
\ &m\vec{a}(t)\cdot \vec{v}(t)\\
&=m\Bigr(a_x(t)v_x(t)+a_y(t)v_y(t)+a_z(t)v_z(t)\Bigr)\\
&=\frac{1}{2}m\Biggr(\Bigr(v_x(t)^2\Bigr)'+\Bigr(v_y(t)^2\Bigr)'+\Bigr(v_z(t)^2\Bigr)'\Biggr)\\
&=\frac{d}{dt}\Bigr(\frac{1}{2}mv^2(t)\Bigr)
\end{aligned}$$

<div class="paragraph-box">Right-hand side</div><br>

$$\begin{aligned}
&\ \ \  -\frac{GMm}{r^3(t)}\vec{r}(t)\cdot \vec{v}(t)\\
&= -\frac{GMm}{r^3(t)}\Bigr(x(t)v_x(t)+y(t)v_y(t)+z(t)v_z(t)\Bigr)\\
&=-\frac{GMm}{r^3(t)}r(t)\frac{dr}{dt}(t)\\
&=-\frac{GMm}{r^2(t)}\frac{dr}{dt}(t)\\
&=\frac{d}{dt}\Bigr(\frac{GMm}{r(t)}\Bigr)\\
\end{aligned}$$

Hence

$$\begin{aligned}
& \ \ \  m\vec{a}(t)=-\frac{GMm}{r^3(t)}\vec{r}(t)\\
& \Rightarrow m\vec{a}(t)\cdot \vec{v}(t)=-\frac{GMm}{r^3(t)}\vec{r}(t)\cdot \vec{v}(t)\\
& \Leftrightarrow \frac{d}{dt}\Bigr(\frac{1}{2}mv^2(t)\Bigr)=\frac{d}{dt}\Bigr(\frac{GMm}{r(t)}\Bigr)\\
& \Leftrightarrow \frac{d}{dt}\Bigr(\frac{1}{2}mv^2(t)-\frac{GMm}{r(t)}\Bigr)=0\\
\end{aligned}$$
　⬜︎
"""
);
