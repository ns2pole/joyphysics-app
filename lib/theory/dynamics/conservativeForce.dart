import '../../model.dart';

final conservativeForce = TheoryTopic(
  title: '保存力',
  latexContent: r"""

<div class="theory-common-box">保存力の定義</div>
<p>
ある地点を原点として、地点$\overrightarrow a$から地点$\overrightarrow b$まで質点が力$\overrightarrow F$を受けながら動く時、力$\overrightarrow F$のする仕事が途中の経路によらず端点$\overrightarrow a ,\overrightarrow b$だけで決まるような力を保存力という。
</p>
<div class="theory-common-box">命題：一様な重力は保存力である</div>
<p>
<div class="proof-box">証明</div>
質量$m$の質点に働く一様な重力のする仕事が途中の経路によらない事を示せば良い。
質点の位置によらず、$\overrightarrow{F}=m\overrightarrow g$なので、$\overrightarrow r(t_0) = \overrightarrow a, \ \overrightarrow r(t_1) = \overrightarrow b$を満たす経路$\overrightarrow r(t)$を任意にとると、
\begin{aligned}
\ \ \ \ \ &\displaystyle \int_{t_0}^{t_1} \overrightarrow{F}(t) \cdot \overrightarrow{v}(t) dt\\[6pt]
&= \displaystyle \int_{t_0}^{t_1} m\overrightarrow g \cdot \frac {d\overrightarrow r}{dt} dt\\[6pt]
&=  \displaystyle \int_{t_0}^{t_1} mg\frac {dy}{dt} dt \\[6pt]
&=  \displaystyle mg \int_{t_0}^{t_1} \frac {dy}{dt} dt \\[6pt]
&=  \displaystyle mg \bigl[ y(t) \bigr]_{t_0}^{t_1} \\[6pt]
&=  \displaystyle mg \bigl( y(t_1) - y(t_0)\bigr)\\[6pt]
&=  \displaystyle mg \bigl( b_y - a_y\bigr)
\end{aligned}
よって、地点$\overrightarrow a, \overrightarrow b$のy座標のみで仕事が定まっているので、特に地点$\overrightarrow a, \overrightarrow b$のみで仕事が定まっている。Q.E.D
</p>
<div class="theory-common-box">命題：位置ベクトルに比例する力は保存力である</div>
<p>
<div class="proof-box">証明</div>
質点に働く、変位に比例する力$ -k\overrightarrow{r}(t)$のする仕事が途中の経路によらない事を示せば良い。
$\overrightarrow r(t_0) = \overrightarrow a,\  \overrightarrow r(t_1) = \overrightarrow b$を満たす経路$\overrightarrow r(t)$を任意にとると、
\begin{aligned}
\ \ \ \ \ &\displaystyle \int_{t_0}^{t_1} \overrightarrow{F}(t) \cdot \overrightarrow{v}(t) dt\\[6pt]
&= \displaystyle \int_{t_0}^{t_1} -k \overrightarrow{r}(t) \cdot \overrightarrow{v}(t) dt \\[6pt]
&= \Bigr[-\frac {1}{2k} |\overrightarrow r (t)|^2 \Bigr]_{t_0}^{t_1}  \\[6pt]
&= -\frac {1}{2k} \Bigl( |\overrightarrow b|^2 -  |\overrightarrow a|^2 \Bigr)
\end{aligned}
以上より、仕事が端点の位置ベクトル$\overrightarrow a, \overrightarrow b$のみに依存しているので、命題を示すことができた。Q.E.D
</p>
<div class="theory-common-box">補題</div>
ベクトル関数 $\overrightarrow r(t)$ に対し，$r(t)=|\overrightarrow r(t)|$ とすると
\[
\bigl(r^{-1}\bigr)'=-\,\frac{\overrightarrow r \cdot \overrightarrow v}{r^3}.
\]
<p>
<div class="proof-box">証明</div>
$r(t) = \sqrt{\overrightarrow r(t)\cdot\overrightarrow r(t)}$より$r'(t)=\displaystyle \frac{\overrightarrow r(t)\cdot\overrightarrow v(t)}{r(t)}$.
したがって
\[
\Bigl(\frac 1 {r(t)}\Bigr)'=-\frac{1}{r(t)^2} r(t)'=-\frac{\overrightarrow r(t)\cdot\overrightarrow v(t)}{r(t)^3}.
\]
Q.E.D.
</p>
<div class="theory-common-box">命題：万有引力は保存力である</div>
<p>
<div class="proof-box">証明</div>
質点質量 $m$ に対し、中心天体質量 $M$ の万有引力は
\[
\overrightarrow{F}(\overrightarrow{r})=-G\frac{Mm}{r^3}\,\overrightarrow{r},
\]
と表される。端点 $\overrightarrow r(t_0)=\overrightarrow a, \overrightarrow r(t_1)=\overrightarrow b$ を結ぶ経路 $\overrightarrow r(t)$ 上の仕事は
\begin{aligned}
\ \ \ \ \ &\int_{t_0}^{t_1}\overrightarrow{F}(\overrightarrow r)\cdot{\overrightarrow v}\,dt\\[6pt]
&=-GMm\int_{t_0}^{t_1}\frac{\overrightarrow r\cdot{\overrightarrow v}}{r^3}\,dt \\[6pt]
&=-{GMm}\Bigl[\frac{1}{|\overrightarrow{r}(t)|}\Bigr]_{t_0}^{t_1}\\[6pt]
&=-GMm\Bigl(\frac{1}{|\overrightarrow {r}(t_1)|}-\frac{1}{|\overrightarrow {r}(t_0)|}\Bigr) \\[6pt]
&=-GMm\Bigl(\frac{1}{|\overrightarrow b|}-\frac{1}{|\overrightarrow a|}\Bigr)
\end{aligned}
これは始点・終点の位置のみから定まるので、万有引力は保存力である。Q.E.D
</p>

<div class="theory-common-box">命題：動摩擦力は保存力ではない</div>
<p>
<div class="proof-box">証明</div>
物体が接触面上を速度 $\overrightarrow v$ で滑るとき，動摩擦力は
\[
\overrightarrow{F}_{\rm fr}=-\,\mu_{k}N\,\frac{\overrightarrow v}{|\overrightarrow v|},
\]
と表される。ここで $\mu_{k}$ は動摩擦係数，$N$ は垂直抗力である。始点 $\overrightarrow r(t_0)=\overrightarrow a$，終点 $\overrightarrow r(t_1)=\overrightarrow b$ を結ぶ任意の経路 $\overrightarrow r(t)$ 上の仕事は
\begin{aligned}
W_{\rm fr}&=-\mu_{k}N\int_{t_0}^{t_1}\frac{\overrightarrow v}{|\overrightarrow v|}\cdot\overrightarrow v\,dt\\[6pt]
&=-\mu_{k}N\int_{t_0}^{t_1}|\overrightarrow v|\,dt
\end{aligned}
となる。ここで $\displaystyle \int_{t_0}^{t_1}\|\overrightarrow v\|\,dt$ は$\overrightarrow a$から$\overrightarrow b$までの道のりの長さなので、始点・終点だけでは一意に定まらない。したがって動摩擦力は保存力ではない。Q.E.D

</p>
"""
);


// <div class="theory-common-box">位置エネルギーの定義</div>

// 保存力の定義から、$\displaystyle - \int_{\overrightarrow a \to \overrightarrow b} \overrightarrow{F}(\overrightarrow{r}) \cdot \frac {d \overrightarrow{r}}{dt} dt$
// は$\overrightarrow a$から$\overrightarrow b$への経路によらず値が定まる。この値を地点$\overrightarrow a$を基準とした地点$\overrightarrow b$の<b>位置エネルギー</b>という。
// <br>
// ※同じ経路をとった場合、速度にも依存しないことは、置換積分で示すことができる。

// <div class="theory-common-box">力学的エネルギーの定義</div>
// 基準を任意に定めた時の、位置エネルギーと運動エネルギーの和を<b>力学的エネルギー</b>という。


// <div class="theory-common-box">命題：力学的エネルギーは時間によらず一定である</div>
// <div class="proof-box">証明</div>

// 力学的エネルギー$\displaystyle E = \frac12 m |\overrightarrow v|^2 + U_{\overrightarrow a}(\overrightarrow r)$
// を時間で微分して$0$になる事を示す。

// 経路$\overrightarrow r(t)$上で、質点の運動方程式$m \overrightarrow a = \overrightarrow F$を用いると、
// \begin{aligned}
// \ \ \ &\left( \frac12 m |\overrightarrow v|^2 + U_{\overrightarrow a}(\overrightarrow r) \right)'\\[6pt]
// &=  \frac12 m \left(\overrightarrow v \cdot \overrightarrow v\right)' +  U_{\overrightarrow a}(\overrightarrow r)'\\[6pt]
// &= m \overrightarrow a \cdot \overrightarrow v +  U_{\overrightarrow a}(\overrightarrow r)'\\[6pt]
// &= \overrightarrow F \cdot \overrightarrow v - \overrightarrow F \cdot \overrightarrow v\\[6pt]
// &= 0
// \end{aligned}
// よって力学的エネルギーは保存される。Q.E.D