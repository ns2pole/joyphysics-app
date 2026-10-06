import '../../model.dart';

final runge_lenz_vector = TheoryTopic(
  imageAsset: 'assets/mindMap/forTopics/runge_lenz_vector.png',
  
  title: 'レンツベクトルの定義と保存について',
  titleEn: 'Definition and conservation of the Runge–Lenz vector',
  latexContent: r"""
  <div class="theory-common-box">
設定・記法
</div>
中心質量 $M$ の重力場の下で質量 $m$ の粒子が運動するとする。<br>
ケプラー第二法則により運動は固定平面に制限される事が導けるので，その平面を $(x,y)$ 平面と取り，
三次元ベクトルは縦ベクトルで表す：
$$\begin{aligned}
\vec{r}(t)=\begin{pmatrix}x(t)\\[6pt] y(t)\\[6pt] 0\end{pmatrix}\\[6pt]
\vec{v}(t)=\vec{r}'(t)=\begin{pmatrix}x'(t)\\[6pt] y'(t)\\[6pt] 0\end{pmatrix} \\[6pt]
r(t)=\sqrt{x(t)^2+y(t)^2}
\end{aligned}$$
角運動量ベクトルは
$$
\vec L:=\begin{pmatrix}0\\[6pt] 0\\[6pt] m\bigl(xy'-yx'\bigr) \end{pmatrix}
$$

である。<br>
万有引力の法則より、運動方程式は中心星を原点に取ると

$$
m\vec{r}''(t)=-\frac{GMm}{r(t)^3}\,\vec{r}(t)
$$

$xy$成分表示では

$\displaystyle x''=-\frac{GM}{r^3}x,\quad y''=-\frac{GM}{r^3}y$

となる。
</div>

<div class="theory-common-box">
定義:レンツベクトル,離心ベクトル,離心率
</div>
天下りではあるが、

$$\displaystyle \vec{A}:=\begin{pmatrix}mL\,y' - \frac{GM\,m^2 x}{r}\\[6pt]
 \displaystyle -mL\,x' - \frac{GM\,m^2 y}{r}\\[6pt] 0\end{pmatrix}
$$

という保存量が知られている。これをレンツベクトルと言う。
またこのベクトルを無次元化したベクトル

$$\vec{e}:=\frac{\vec{A}}{GM\,m^2}
$$

を離心ベクトルと言い、離心ベクトルの大きさ$ \displaystyle e:=\lvert\vec{e}\lvert $を離心率という。
</div>

<div class="theory-common-box">
定理:レンツベクトル,離心ベクトルは時間に依らない定ベクトルである。
</div>

<div class="proof-box">証明</div>
レンツベクトルと離心ベクトルは定数倍の関係であるから、離心ベクトルが時間によらないことを示せば十分。

$\vec{e}$ の成分は

$$\begin{aligned}
\begin{cases}
\displaystyle e_x=\frac{A_x}{GMm^2}=\frac{L\,y'}{GMm}-\frac{x}{r}\\[6pt]
\displaystyle e_y=\frac{A_y}{GMm^2}=-\frac{L\,x'}{GMm}-\frac{y}{r}
\end{cases}
\end{aligned}$$
$e_x'$ を計算する（$L$ はケプラー第二法則により定数）：

$$
e_x'=\frac{Ly''}{GMm}-\Bigl(\frac{x}{r}\Bigr)'
$$

右辺第一項:<br>
$ \displaystyle \frac{Ly''}{GMm} $は、運動方程式より$y''=-\dfrac{GM}{r^3}y$ なので

$$
\displaystyle \frac{Ly''}{GMm}=-\frac{Ly}{m r^3}
$$

右辺第二項:
$$\begin{aligned}
&\quad \Bigl(\frac{x}{r}\Bigr)'\\[6pt]
&=\frac{x'}{r}-\frac{x}{r^2}r'\\[6pt]
&=\frac{x'}{r}-\frac{x}{r^2}\Bigr(\frac{xx'+yy'}{\sqrt{x^2+y^2}}\Bigl)\\[6pt]
&=\frac{x'}{r}-x\frac{x x'+y y'}{r^3}\\[6pt]
&=\frac{x'(x^2+y^2)}{r^3}-x\frac{x x'+y y'}{r^3}\\[6pt]
&=\frac{x'y^2-xy y'}{r^3}\\[6pt]
&=y\frac{x'y-xy'}{r^3}\\[6pt]
&=-y\frac{L}{r^3}
\end{aligned}$$
よって、

$$\begin{aligned}
e_x' &= \frac{Ly''}{GMm}-\Bigl(\frac{x}{r}\Bigr)' \\[6pt]
&=-\frac{Ly}{mr^3} -\Bigl(-y\frac{L}{r^3}\Bigr) = 0
\end{aligned}$$
同様の計算で $e_y'=0$ となり，$e_z\equiv0$ だから、各成分の時間微分が0となり、$\vec{e}'=\mathbf0$ が示された。

</div>　⬜︎
  
  """,
  latexContentEn: r"""
  <div class="theory-common-box">
Setup and notation
</div>
A particle of mass $m$ moves in the gravitational field of a central mass $M$.<br>
Kepler's second law implies the motion is confined to a fixed plane; take that plane as the $(x,y)$ plane and write 3D vectors as columns:
$$\begin{aligned}
\vec{r}(t)=\begin{pmatrix}x(t)\\[6pt] y(t)\\[6pt] 0\end{pmatrix}\\[6pt]
\vec{v}(t)=\vec{r}'(t)=\begin{pmatrix}x'(t)\\[6pt] y'(t)\\[6pt] 0\end{pmatrix} \\[6pt]
r(t)=\sqrt{x(t)^2+y(t)^2}
\end{aligned}$$
The angular momentum vector is
$$
\vec L:=\begin{pmatrix}0\\[6pt] 0\\[6pt] m\bigl(xy'-yx'\bigr) \end{pmatrix}
$$

.<br>
By the law of universal gravitation, with the central star at the origin, the equation of motion is

$$
m\vec{r}''(t)=-\frac{GMm}{r(t)^3}\,\vec{r}(t)
$$

In $xy$ components,

$\displaystyle x''=-\frac{GM}{r^3}x,\quad y''=-\frac{GM}{r^3}y$

.
</div>

<div class="theory-common-box">
Definition: Runge–Lenz vector, eccentricity vector, eccentricity
</div>
Although introduced by fiat,

$$\displaystyle \vec{A}:=\begin{pmatrix}mL\,y' - \frac{GM\,m^2 x}{r}\\[6pt]
 \displaystyle -mL\,x' - \frac{GM\,m^2 y}{r}\\[6pt] 0\end{pmatrix}
$$

is a known conserved quantity, called the Runge–Lenz vector.
The dimensionless vector

$$\vec{e}:=\frac{\vec{A}}{GM\,m^2}
$$

is the eccentricity vector, and its magnitude $ \displaystyle e:=\lvert\vec{e}\rvert $ is the eccentricity.
</div>

<div class="theory-common-box">
Theorem: The Runge–Lenz vector and the eccentricity vector are constant in time.
</div>

<div class="proof-box">Proof</div>
Since they differ only by a constant factor, it suffices to show that the eccentricity vector is time-independent.

The components of $\vec{e}$ are

$$\begin{aligned}
\begin{cases}
\displaystyle e_x=\frac{A_x}{GMm^2}=\frac{L\,y'}{GMm}-\frac{x}{r}\\[6pt]
\displaystyle e_y=\frac{A_y}{GMm^2}=-\frac{L\,x'}{GMm}-\frac{y}{r}
\end{cases}
\end{aligned}$$
Compute $e_x'$ ($L$ is constant by Kepler's second law):

$$
e_x'=\frac{Ly''}{GMm}-\Bigl(\frac{x}{r}\Bigr)'
$$

First term on the right:<br>
$\displaystyle \frac{Ly''}{GMm}$ with $y''=-\frac{GM}{r^3}y$ from the equation of motion gives

$$
\displaystyle \frac{Ly''}{GMm}=-\frac{Ly}{m r^3}
$$

Second term:
$$\begin{aligned}
&\quad \Bigl(\frac{x}{r}\Bigr)'\\[6pt]
&=\frac{x'}{r}-\frac{x}{r^2}r'\\[6pt]
&=\frac{x'}{r}-\frac{x}{r^2}\Bigr(\frac{xx'+yy'}{\sqrt{x^2+y^2}}\Bigl)\\[6pt]
&=\frac{x'}{r}-x\frac{x x'+y y'}{r^3}\\[6pt]
&=\frac{x'(x^2+y^2)}{r^3}-x\frac{x x'+y y'}{r^3}\\[6pt]
&=\frac{x'y^2-xy y'}{r^3}\\[6pt]
&=y\frac{x'y-xy'}{r^3}\\[6pt]
&=-y\frac{L}{r^3}
\end{aligned}$$
Hence

$$\begin{aligned}
e_x' &= \frac{Ly''}{GMm}-\Bigl(\frac{x}{r}\Bigr)' \\[6pt]
&=-\frac{Ly}{mr^3} -\Bigl(-y\frac{L}{r^3}\Bigr) = 0
\end{aligned}$$
A similar calculation gives $e_y'=0$, and $e_z\equiv0$, so every component has vanishing time derivative and $\vec{e}'=\mathbf0$.

</div>　⬜︎
  
  """
);
