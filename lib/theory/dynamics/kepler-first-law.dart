import '../../model.dart';

final keplerFirstLaw = TheoryTopic(
  title: 'ケプラー第一法則',
  titleEn: 'Kepler\'s first law',
  isNew: false,
  imageAsset: 'assets/mindMap/forTopics/keplerFirstLaw.png', // 実際の画像パス
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
万有引力の法則より、運動方程式は中心星を原点に取ると
$$
m\vec{r}''(t)=-\frac{GMm}{r(t)^3}\,\vec{r}(t)
$$
$xy$成分表示では
$\displaystyle x''=-\frac{GM}{r^3}x,\quad y''=-\frac{GM}{r^3}y$
となる。<br>
また、この運動方程式に従う質点について下記の3つの物理量が時間によらず一定である事は<a href="app://topic?video=keplerSecondLaw">こちらの記事</a>と<a href="app://topic?video=runge_lenz_vector">こちらの記事</a>で証明を行なっている。<br>
<div class="paragraph-box">角運動量ベクトル</div><br>
$$
\vec L:=\begin{pmatrix}0\\[6pt] 0\\[6pt] m\bigl(xy'-yx'\bigr) \end{pmatrix}
$$
<div class="paragraph-box">レンツベクトル</div><br>
$$\displaystyle \vec{A}:=\begin{pmatrix}mL\,y' - \frac{GM\,m^2 x}{r}\\[6pt]
 \displaystyle -mL\,x' - \frac{GM\,m^2 y}{r}\\[6pt] 0\end{pmatrix}
$$
<div class="paragraph-box">離心ベクトル(レンツベクトルを${GM\,m^2}$で割り無次元化したベクトル)</div><br>
$$\vec{e}:=\frac{\vec{A}}{GM\,m^2}$$

  
<div class="theory-common-box">
命題1（軌道方程式）<br>
極座標 $(r,\theta)$ を用いると軌道は$r,\theta$の関係式で、下記のように表される。
$\displaystyle r(\theta)=\dfrac{L^{2}}{GM\,m^{2}\bigl(1+e\cos(\theta-\alpha)\bigr)}$
</div>

<div class="proof-box">証明</div>
成分で $\vec{e}\cdot\vec{r}=e_x x+e_y y$ を計算すると

$$\begin{aligned}
\vec{e}\cdot\vec{r}&=\frac{L}{GMm}(x y'-y x')-\frac{x^2+y^2}{r}\\[6pt]
&=\frac{L^{2}}{GM m^2}-r\quad\cdots(1)
\end{aligned}$$

一方、離心ベクトルを$\vec{e}=e(\cos \alpha, \sin \alpha)$のように$x$軸からの角度を用いて表すと

$$
\vec{e}\cdot\vec{r}=e\,r\cos(\theta-\alpha)\quad\cdots(2)
$$

なので、(1)(2)より

$$\begin{aligned}
&e\,r\cos(\theta-\alpha)=\frac{L^{2}}{GM m^2}-r\\[6pt]
&r\bigl(1+e\cos(\theta-\alpha)\bigr)=\frac{L^{2}}{GM m^2}\\[6pt]
\Leftrightarrow\quad & r=\frac{L^{2}}{GM m^2\bigl(1+e\cos(\theta-\alpha)\bigr)}
\end{aligned}$$

従って所望の形が得られた。

</div>　⬜︎

<div class="theory-common-box">
命題2（離心率と全エネルギー）<br>
離心率$e$とエネルギー $E$ との間には、
$\displaystyle e^{2}=1+\dfrac{2E L^{2}}{G^{2}M^{2}m^{3}} $
の関係が成り立つ。</div>
<div class="proof-box">証明</div>
普通に計算していけば示せる。

$$\begin{aligned}
e^2 &= e_x^2 + e_y^2 \\[6pt]
&= \left(\frac{L\, y'}{GM m} - \frac{x}{r}\right)^2 + \left(-\frac{L\, x'}{GM m} - \frac{y}{r}\right)^2 \\[6pt]
&= \frac{L^2(x'^2 + y'^2)}{G^2 M^2 m^2}  + \frac{x^2 + y^2}{r^2} -\frac{2L( xy'- x' y )}{GM mr} 
\end{aligned}$$

全エネルギーより
$\displaystyle E = \frac12 m v^2 - \frac{GM m}{r} \Leftrightarrow v^2 = \frac{2E}{m} + \frac{2 GM}{r}$
<br>
また、$\displaystyle xy'- x' y  = \frac L m $が成り立つ。
これを$e^2$の計算途中の式に代入して、引き続き計算すると、
$$\begin{aligned}
e^2 &= \frac{L^2}{G^2 M^2 m^2} \Bigl(  \frac{2E}{m} + \frac{2 GM}{r} \Bigr) + 1- \frac{2L^2}{GM m^2r}\\[6pt]
&= \frac{2EL^2}{G^2 M^2 m^3} + \frac{2L^2}{GM m^2r} + 1 - \frac{2L^2}{GM m^2r}\\[6pt]
&= 1 + \frac{2EL^2}{G^2 M^2 m^3} 
\end{aligned}$$

</div>　⬜︎

<div class="theory-common-box">
命題3（離心率 $e$ による分類）
</div>
極方程式
$$
r(\theta)=\frac{L^{2}}{GM\,m^2(1+e\cos(\theta-\alpha))} ; \quad L\neq0
$$ により，離心率 $e$ の値によって軌道は次のように分類される。<br>
<div class="paragraph-box">
  (1) $0 \le e < 1$（楕円：束縛軌道）
</div><br>
・このケースがケプラー第一法則にあたる。極方程式の分母は常に正なので $r(\theta)$ は有界（最大値・最小値が存在）である。<br>
・近点（pericenter）と遠点（apocenter）はそれぞれ
$$
\begin{aligned}
\begin{cases}
\displaystyle r_{\min}=\frac{L^{2}}{GM\,m^{2}(1+e)}\quad\\[6pt]
\displaystyle r_{\max}=\frac{L^{2}}{GM\,m^{2}(1-e)}
\end{cases}
\end{aligned}
$$
長半径は
$$
a=\frac{1}{2}\,(r_{\min}+r_{\max})=\frac{L^{2}}{GM\,m^{2}(1-e^{2})}
$$
である。<br>
・近点・遠点はそれぞれ $a(1-e)$、$a(1+e)$ と表される。<br>
・$\theta=\alpha$ が近点方向で $r_{\min}=\dfrac{L^{2}}{GM\,m^{2}(1+e)}$ を与え、$\theta=\alpha+\pi$ が遠点方向で $r_{\max}=\dfrac{L^{2}}{GM\,m^{2}(1-e)}$ を与える。<br>
・特殊例：$e=0$ のとき円軌道。<br>
<div class="paragraph-box">
(2) $e=1$（放物線：臨界軌道）
</div><br>
極方程式は
$$
r(\theta)=\frac{L^{2}}{GM\,m^{2}(1+\cos(\theta-\alpha))}
$$
分母が $1+\cos(\theta-\alpha)=0$ となる角、すなわち $\theta=\alpha+\pi$ に向かって $r\to\infty$。
したがって放物線は唯一つの発散方向 $\theta=\alpha+\pi$ を持つ。<br>
<div class="paragraph-box">
(3) $e>1$（双曲線：非束縛軌道）
</div><br>
・近点は $\cos(\theta-\alpha)=1$（すなわち $\theta=\alpha$）で達成され、値は
$$
r_{\min}=\frac{L^{2}}{GM\,m^{2}(1+e)}>0
$$
・無限遠へ向かう角（漸近方向）は分母が零となる角で定まり、
$$
1+e\cos(\theta-\alpha)=0 \iff \cos(\theta-\alpha)=-\frac{1}{e}
$$
を満たす角が二つ存在する。これらが双曲線の二本の漸近方向に対応し、その方向に向かって $r\to\infty$ となる。


<div class="theory-common-box">
命題4（軌道長半径とエネルギー）<br>
楕円軌道の時、全エネルギー$E$と軌道長半径$a$の間に
$\displaystyle E=-\frac{GM\,m}{2a}\quad(<0)$
の関係式が成り立つ。すなわち、エネルギーは軌道長半径のみで決まる。
</div>
<div class="proof-box">証明</div>
命題2の式

$$
e^2=1+\frac{2EL^2}{G^2M^2m^3}
$$

を $E$ について解くと

$$
E=\frac{G^2M^2m^3}{2L^2}(e^2-1)
   =-\frac{G^2M^2m^3}{2L^2}(1-e^2)
$$

上の式に軌道長半径

$$\begin{aligned}
 a= \frac {r_{min} +r_{max}}{2} &= \frac{L^{2}}{GM\,m^{2}(1-e^{2})}\\[6pt]
 \Leftrightarrow \ 1-e^{2}&=\frac{L^{2}}{GM\,m^{2}a}
\end{aligned}$$

を代入すると、

$$
E=-\frac{GM\,m}{2a}
$$
</div>
　⬜︎
<div class="theory-common-box">
命題5（焦点が原点であることと準線の方程式）<br>
極方程式
$\displaystyle r(\theta)=\frac{L^2}{GM\,m^2(1+e\cos(\theta-\alpha))}; \quad L\neq 0 $によって表される曲線は，
原点が焦点，準線が
$\displaystyle \mathcal D:\  x\cos\alpha+y\sin\alpha=\frac{L^2}{GM\,m^2e}$、離心率が $e$の円錐曲線である．
</div>
<div class="proof-box">証明</div>

焦点$F$、直線 $\mathcal D$，離心率 $e>0$ を与えた時、円錐曲線の方程式が命題1の軌道の式と一致する事を示す。

焦点$F$を原点として、準線は天下りではあるが、$\displaystyle \mathcal D:   x\cos\alpha+y\sin\alpha=\frac{L^2}{GM m^2e}$を取る。

点 $P=(x,y)$ から $\mathcal D$ までの距離$d(P,\mathcal D)$は直線の距離公式より
$$
d(P,\mathcal D)=\Bigl|x\cos\alpha+y\sin\alpha-\frac{L^2}{GM m^2e}\Bigr|
$$

である．離心率の定義より$\overline{PF}=ed(P,\mathcal D)$なので

$\displaystyle r=e\Bigl|x\cos\alpha+y\sin\alpha-\frac{L^2}{GM m^2e}\Bigr|$

となる．極座標 $(r,\theta)$ を用いると $x=r\cos\theta,\ y=r\sin\theta$ より

$$
\cos(\theta-\alpha)=\frac{x\cos\alpha+y\sin\alpha}{r}
$$

上の等式に代入すると、

$$\begin{aligned}
r=e\Bigl|x\cos\alpha+y\sin\alpha-\frac{L^2}{GM\,m^2e}\Bigr| \\[6pt]
r=e\Bigl|r \cos(\theta-\alpha)-\frac{L^2}{GM\,m^2e}\Bigr| \cdots(1)
\end{aligned}$$

ここで、下の補題より絶対値の中身は負。したがって(1)式より、符号に注意して整理すると

$$
r\bigl(1+e\cos(\theta-\alpha)\bigr)=\frac{L^2}{GM\,m^2}
$$

を得る．これは、命題1の軌道の式と同じ。 ⬜︎

</div>

<div class="theory-common-box">
[補題]$\quad \displaystyle r\cos(\theta-\alpha)-\frac{L^2}{GM\,m^2e}$は負の数である。
</div>
<div class="proof-box">証明</div>
$$
r(\theta)=\frac{L^2}{GM\,m^2}\cdot\frac{1}{1+e\cos(\theta-\alpha)}
$$
から、両辺に $1+e\cos(\theta-\alpha)$ を掛けて変形すると

$$\begin{aligned}
r\bigl(1+e\cos(\theta-\alpha)\bigr)=\frac{L^2}{GM\,m^2}\\[6pt]
\Leftrightarrow \ r\cos(\theta-\alpha)-\frac{L^2}{GM\,m^2e}=-\frac{r}{e}<0
\end{aligned}$$
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
By the law of universal gravitation, with the central star at the origin,
$$
m\vec{r}''(t)=-\frac{GMm}{r(t)^3}\,\vec{r}(t)
$$
In $xy$ components,
$\displaystyle x''=-\frac{GM}{r^3}x,\quad y''=-\frac{GM}{r^3}y$
.<br>
For a particle obeying this equation, the following three quantities are constant in time, as proved in <a href="app://topic?video=keplerSecondLaw">this article</a> and <a href="app://topic?video=runge_lenz_vector">this article</a>.<br>
<div class="paragraph-box">Angular momentum vector</div><br>
$$
\vec L:=\begin{pmatrix}0\\[6pt] 0\\[6pt] m\bigl(xy'-yx'\bigr) \end{pmatrix}
$$
<div class="paragraph-box">Runge–Lenz vector</div><br>
$$\displaystyle \vec{A}:=\begin{pmatrix}mL\,y' - \frac{GM\,m^2 x}{r}\\[6pt]
 \displaystyle -mL\,x' - \frac{GM\,m^2 y}{r}\\[6pt] 0\end{pmatrix}
$$
<div class="paragraph-box">Eccentricity vector (Runge–Lenz vector divided by ${GM\,m^2}$ to make it dimensionless)</div><br>
$$\vec{e}:=\frac{\vec{A}}{GM\,m^2}$$

  
<div class="theory-common-box">
Proposition 1 (orbit equation)<br>
In polar coordinates $(r,\theta)$ the orbit is
$\displaystyle r(\theta)=\frac{L^{2}}{GM\,m^{2}\bigl(1+e\cos(\theta-\alpha)\bigr)}$
</div>

<div class="proof-box">Proof</div>
Computing $\vec{e}\cdot\vec{r}=e_x x+e_y y$ in components,

$$\begin{aligned}
\vec{e}\cdot\vec{r}&=\frac{L}{GMm}(x y'-y x')-\frac{x^2+y^2}{r}\\[6pt]
&=\frac{L^{2}}{GM m^2}-r\quad\cdots(1)
\end{aligned}$$

Writing $\vec{e}=e(\cos \alpha, \sin \alpha)$ with angle from the $x$-axis,

$$
\vec{e}\cdot\vec{r}=e\,r\cos(\theta-\alpha)\quad\cdots(2)
$$

From (1) and (2),

$$\begin{aligned}
&e\,r\cos(\theta-\alpha)=\frac{L^{2}}{GM m^2}-r\\[6pt]
&r\bigl(1+e\cos(\theta-\alpha)\bigr)=\frac{L^{2}}{GM m^2}\\[6pt]
\Leftrightarrow\quad & r=\frac{L^{2}}{GM m^2\bigl(1+e\cos(\theta-\alpha)\bigr)}
\end{aligned}$$

as claimed.

</div>　⬜︎

<div class="theory-common-box">
Proposition 2 (eccentricity and total energy)<br>
Eccentricity $e$ and energy $E$ are related by
$\displaystyle e^{2}=1+\frac{2E L^{2}}{G^{2}M^{2}m^{3}} $.
</div>
<div class="proof-box">Proof</div>
Direct computation:

$$\begin{aligned}
e^2 &= e_x^2 + e_y^2 \\[6pt]
&= \left(\frac{L\, y'}{GM m} - \frac{x}{r}\right)^2 + \left(-\frac{L\, x'}{GM m} - \frac{y}{r}\right)^2 \\[6pt]
&= \frac{L^2(x'^2 + y'^2)}{G^2 M^2 m^2}  + \frac{x^2 + y^2}{r^2} -\frac{2L( xy'- x' y )}{GM mr} 
\end{aligned}$$

From total energy,
$\displaystyle E = \frac12 m v^2 - \frac{GM m}{r} \Leftrightarrow v^2 = \frac{2E}{m} + \frac{2 GM}{r}$
<br>
and $\displaystyle xy'- x' y  = \frac L m $. Substituting,
$$\begin{aligned}
e^2 &= \frac{L^2}{G^2 M^2 m^2} \Bigl(  \frac{2E}{m} + \frac{2 GM}{r} \Bigr) + 1- \frac{2L^2}{GM m^2r}\\[6pt]
&= \frac{2EL^2}{G^2 M^2 m^3} + \frac{2L^2}{GM m^2r} + 1 - \frac{2L^2}{GM m^2r}\\[6pt]
&= 1 + \frac{2EL^2}{G^2 M^2 m^3} 
\end{aligned}$$

</div>　⬜︎

<div class="theory-common-box">
Proposition 3 (classification by eccentricity $e$)
</div>
From the polar equation
$$
r(\theta)=\frac{L^{2}}{GM\,m^2(1+e\cos(\theta-\alpha))} ; \quad L\neq0
$$
orbits are classified by $e$ as follows.<br>
<div class="paragraph-box">
  (1) $0 \le e < 1$ (ellipse: bound orbit)
</div><br>
•This case is Kepler's first law. The denominator is always positive, so $r(\theta)$ is bounded (has a max and min).<br>
•Pericenter and apocenter are
$$
\begin{aligned}
\begin{cases}
\displaystyle r_{\min}=\frac{L^{2}}{GM\,m^{2}(1+e)}\quad\\[6pt]
\displaystyle r_{\max}=\frac{L^{2}}{GM\,m^{2}(1-e)}
\end{cases}
\end{aligned}
$$
The semi-major axis is
$$
a=\frac{1}{2}\,(r_{\min}+r_{\max})=\frac{L^{2}}{GM\,m^{2}(1-e^{2})}
$$
.<br>
•Pericenter and apocenter are also $a(1-e)$ and $a(1+e)$.<br>
•$\theta=\alpha$ is the pericenter direction giving $r_{\min}=\displaystyle\frac{L^{2}}{GM\,m^{2}(1+e)}$, and $\theta=\alpha+\pi$ the apocenter giving $r_{\max}=\displaystyle\frac{L^{2}}{GM\,m^{2}(1-e)}$.<br>
•Special case: $e=0$ is a circular orbit.<br>
<div class="paragraph-box">
(2) $e=1$ (parabola: critical orbit)
</div><br>
The polar equation is
$$
r(\theta)=\frac{L^{2}}{GM\,m^{2}(1+\cos(\theta-\alpha))}
$$
. As $1+\cos(\theta-\alpha)=0$, i.e. $\theta=\alpha+\pi$, one has $r\to\infty$.
Thus a parabola has a single escape direction $\theta=\alpha+\pi$.<br>
<div class="paragraph-box">
(3) $e>1$ (hyperbola: unbound orbit)
</div><br>
•Pericenter occurs at $\cos(\theta-\alpha)=1$ ($\theta=\alpha$), with
$$
r_{\min}=\frac{L^{2}}{GM\,m^{2}(1+e)}>0
$$
•Asymptotic directions where the denominator vanishes satisfy
$$
1+e\cos(\theta-\alpha)=0 \iff \cos(\theta-\alpha)=-\frac{1}{e}
$$
; there are two such angles, the two asymptotes of the hyperbola, along which $r\to\infty$.


<div class="theory-common-box">
Proposition 4 (semi-major axis and energy)<br>
For an elliptical orbit,
$\displaystyle E=-\frac{GM\,m}{2a}\quad(<0)$
; energy is determined by the semi-major axis alone.
</div>
<div class="proof-box">Proof</div>
From Proposition 2,

$$
e^2=1+\frac{2EL^2}{G^2M^2m^3}
$$

solving for $E$,

$$
E=\frac{G^2M^2m^3}{2L^2}(e^2-1)
   =-\frac{G^2M^2m^3}{2L^2}(1-e^2)
$$

Substitute the semi-major axis

$$\begin{aligned}
 a= \frac {r_{min} +r_{max}}{2} &= \frac{L^{2}}{GM\,m^{2}(1-e^{2})}\\[6pt]
 \Leftrightarrow \ 1-e^{2}&=\frac{L^{2}}{GM\,m^{2}a}
\end{aligned}$$

to obtain

$$
E=-\frac{GM\,m}{2a}
$$
</div>
　⬜︎
<div class="theory-common-box">
Proposition 5 (focus at the origin and directrix)<br>
The curve
$\displaystyle r(\theta)=\frac{L^2}{GM\,m^2(1+e\cos(\theta-\alpha))}; \quad L\neq 0 $
is a conic with focus at the origin, directrix
$\displaystyle \mathcal D:\  x\cos\alpha+y\sin\alpha=\frac{L^2}{GM\,m^2e}$, and eccentricity $e$.
</div>
<div class="proof-box">Proof</div>

Show that the conic definition with focus $F$, line $\mathcal D$, and eccentricity $e>0$ yields the orbit of Proposition 1.

Take $F$ at the origin and (by fiat) $\displaystyle \mathcal D:   x\cos\alpha+y\sin\alpha=\frac{L^2}{GM m^2e}$.

The distance from $P=(x,y)$ to $\mathcal D$ is
$$
d(P,\mathcal D)=\Bigl|x\cos\alpha+y\sin\alpha-\frac{L^2}{GM m^2e}\Bigr|
$$

. By definition of eccentricity $\overline{PF}=ed(P,\mathcal D)$, so

$\displaystyle r=e\Bigl|x\cos\alpha+y\sin\alpha-\frac{L^2}{GM m^2e}\Bigr|$

. In polar coordinates $x=r\cos\theta,\ y=r\sin\theta$,

$$
\cos(\theta-\alpha)=\frac{x\cos\alpha+y\sin\alpha}{r}
$$

so

$$\begin{aligned}
r=e\Bigl|x\cos\alpha+y\sin\alpha-\frac{L^2}{GM\,m^2e}\Bigr| \\[6pt]
r=e\Bigl|r \cos(\theta-\alpha)-\frac{L^2}{GM\,m^2e}\Bigr| \cdots(1)
\end{aligned}$$

By the lemma below the expression inside the absolute value is negative. Rearranging (1) carefully,

$$
r\bigl(1+e\cos(\theta-\alpha)\bigr)=\frac{L^2}{GM\,m^2}
$$

which matches Proposition 1. ⬜︎

</div>

<div class="theory-common-box">
[Lemma]$\quad \displaystyle r\cos(\theta-\alpha)-\frac{L^2}{GM\,m^2e}$ is negative.
</div>
<div class="proof-box">Proof</div>
$$
r(\theta)=\frac{L^2}{GM\,m^2}\cdot\frac{1}{1+e\cos(\theta-\alpha)}
$$
. Multiplying by $1+e\cos(\theta-\alpha)$,

$$\begin{aligned}
r\bigl(1+e\cos(\theta-\alpha)\bigr)=\frac{L^2}{GM\,m^2}\\[6pt]
\Leftrightarrow \ r\cos(\theta-\alpha)-\frac{L^2}{GM\,m^2e}=-\frac{r}{e}<0
\end{aligned}$$
</div>　⬜︎
"""
);
