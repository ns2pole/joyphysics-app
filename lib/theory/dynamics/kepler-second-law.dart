import '../../model.dart';

final keplerSecondLaw = TheoryTopic(
  title: 'ケプラー第二法則',
  isNew: false,
  imageAsset: 'assets/mindMap/forTopics/keplerSecondLaw.png', // 実際の画像パス
  latexContent: r"""
<div class="theory-common-box">
設定・記法
</div>
「:=」は左辺の記号を右辺で定義することを意味する。<br>
中心質量 $M$ の重力場の下で質量 $m$ の粒子が運動するとする。<br>
三次元ベクトルは縦ベクトルで表す：
$$\begin{aligned}
\vec{r}(t)&=\begin{pmatrix}x(t)\\[6pt] y(t)\\[6pt] z(t)\end{pmatrix}\qquad
\vec{v}(t)=\vec{r}'(t)=\begin{pmatrix}x'(t)\\[6pt] y'(t)\\[6pt] z'(t)\end{pmatrix}\\[6pt]
r(t)&=\sqrt{x(t)^2+y(t)^2+z(t)^2}
\end{aligned}$$
<div class="paragraph-box">
クロス積の定義
</div><br>
任意のベクトル
$
\displaystyle \vec a=\begin{pmatrix}a_x\\[6pt] a_y\\[6pt] a_z\end{pmatrix},\quad
\displaystyle \vec b=\begin{pmatrix}b_x\\[6pt] b_y\\[6pt] b_z\end{pmatrix}
\text{に対して，}
$ベクトル同士の積$\times$(ベクトル2つからベクトルを生成する演算)を下記で定義する。
$$
\vec a\times\vec b=
\begin{pmatrix}
a_yb_z-a_zb_y\\[6pt]
a_zb_x-a_xb_z\\[6pt]
a_xb_y-a_yb_x
\end{pmatrix}
$$
<div class="paragraph-box">
角運動量ベクトルの定義
</div><br>
下記のベクトル量を角運動量ベクトルという。
$$\begin{aligned}
\vec L &= m\bigl(\vec r(t)\times \vec v(t)\bigr)\\[6pt]
&= \begin{pmatrix}
m\bigl(z(t)v_y(t)-y(t)v_z(t)\bigr)\\[6pt]
m\bigl(x(t)v_z(t)-z(t)v_x(t)\bigr)\\[6pt]
m\bigl(y(t)v_x(t)-x(t)v_y(t)\bigr)
\end{pmatrix}
\end{aligned}
$$

<div class="theory-common-box">補題1.（角運動量保存）
角運動量ベクトルは時間によらない定ベクトルである。
</div>

<div class="proof-box">証明</div>
$x$成分$m\bigl(z(t)v_y(t)-y(t)v_z(t)\bigr)$の微分が0であることを示す。(他成分もやり方は同様)
運動方程式より、
$$
m\vec a(t):=-\frac{G M m}{r^3(t)}\vec r(t)
$$
成分表示すると
$$
\begin{cases}
\displaystyle m a_x(t):=-\dfrac{GMm}{(x^2+y^2+z^2)^{3/2}}x(t)\quad\cdots(1)\\[6pt]
\displaystyle m a_y(t):=-\dfrac{GMm}{(x^2+y^2+z^2)^{3/2}}y(t)\quad\cdots(2)\\[6pt]
\displaystyle m a_z(t):=-\dfrac{GMm}{(x^2+y^2+z^2)^{3/2}}z(t)\quad\cdots(3)
\end{cases}
$$
ここで (1) に $y(t)$ を掛け、(2) に $x(t)$ を掛けて差を取ると
$$
m\bigl(y(t)a_x(t)-x(t)a_y(t)\bigr)=0\quad \cdots(4)
$$
ここで、天下り的ではあるが、
$$\begin{aligned}
&y(t)a_x(t)-x(t)a_y(t)=\frac{d}{dt}\bigl(y(t)v_x(t)-x(t)v_y(t)\bigr)
\end{aligned}$$
が成り立つので、
(4)式は下記のように変形できる。
$$\begin{aligned}
m\bigl(y(t)a_x(t)-x(t)a_y(t)\bigr)&=0\\[6pt]
\Leftrightarrow \frac{d}{dt}\Bigl(m \bigl(y(t)v_x(t)-x(t)v_y(t)\bigl)\Bigl)&=0
\end{aligned}$$

したがって角運動量ベクトルの$x$成分は定数である。<br>
同様に他の二成分についても同様に導け、角運動量ベクトルが時間によらない定ベクトルであることが示された。
これを角運動量保存則という。 ⬜︎



<div class="theory-common-box">補題2.外積ベクトルの大きさ
${\theta}$を${\vec a, \vec b}$のなす角度とすると、
$${|\vec a \times \vec b| = \Biggr| \left(\begin{smallmatrix} \displaystyle a_yb_z- a_zb_y \\ \ \\ \displaystyle a_zb_x- a_xb_z \\ \ \\ \displaystyle a_xb_y - a_yb_x \end{smallmatrix} \right)\Biggr| = |\vec a|  |\vec b| \sin \theta }$$
</div>

<div class="proof-box">証明</div>
それぞれを計算すればいい。

$$\begin{aligned}
&\Biggr| \left(\begin{smallmatrix} \displaystyle a_yb_z- a_zb_y \\ \ \\ \displaystyle a_zb_x- a_xb_z \\ \ \\ \displaystyle a_xb_y - a_yb_x \end{smallmatrix} \right)\Biggr| \\ \ \\
&=\sqrt {(a_yb_z- a_zb_y)^2+(a_zb_x- a_xb_z )^2+(a_xb_y - a_yb_x )^2} \\ \ \\
&=\sqrt {a_y^2b_z^2+ a_z^2b_y^2-2a_yb_za_zb_y+a_z^2b_x^2+ a_x^2b_z^2 -2a_zb_x a_xb_z+a_x^2b_y^2 + a_y^2b_x^2-2a_xb_y a_yb_x}
\end{aligned}$$
<br>
$$\begin{aligned}
&|\vec a|  |\vec b| \sin \theta  \\ \ \\
&=|\vec a|  |\vec b| \sqrt{1-\cos^2 \theta} \\ \ \\
&=|\vec a||\vec b|\sqrt {1-\Biggr(\frac{\vec a \cdot \vec b}{|\vec a||\vec b|}\Biggr)^2}\\ \ \\
&=\sqrt {|\vec a|^2|\vec b|^2-(\vec a \cdot \vec b)^2}\\ \ \\
&=\sqrt{(a_x^2+a_y^2+a_z^2)(b_x^2+b_y^2+b_z^2)-(a_xb_x+a_yb_y+a_zb_z)^2} \\ \ \\
&=\sqrt{a_x^2b_y^2+a_x^2b_z^2+a_y^2b_x^2+a_y^2b_z^2+a_z^2b_x^2+a_z^2b_y^2-2a_xb_xa_yb_y-2a_xb_xa_zb_z-2a_yb_ya_zb_z} \\ \ \\
&=\sqrt{a_x^2b_y^2+a_x^2b_z^2+a_y^2b_x^2+a_y^2b_z^2+a_z^2b_x^2+a_z^2b_y^2-2a_xb_xa_yb_y-2a_xb_xa_zb_z-2a_yb_ya_zb_z}
\end{aligned}$$
　⬜︎

<div class="theory-common-box">定理（ケプラー第2法則）${S(t)}$を粒子の軌跡が原点を中心として掃く面積とすると、${\displaystyle \frac{dS}{dt}}$は時間によらず一定である。
  <div style="text-align:center; margin:1em 0;">
    <img src="assets/dynamicsTheory/kepler-second.png"
          alt="面積速度"
          style="max-width:100%; height:auto;" />
  </div>
</div>

<div class="proof-box">証明</div>

${\vec a}$と${\vec b}$がなす角度を${\theta_{\vec a, \vec b}}$と書く。
ここで、$\Delta t$が十分小さいとして、緑の三角形の領域の面積$\Delta T$で、
面積の変化量$\Delta S$を近似した極限で面積速度が計算できることを認める。即ち、
$$
\lim_{\Delta t \rightarrow 0} \frac{\Delta S}{\Delta t} = \lim_{\Delta t \rightarrow 0} \frac{\Delta T}{\Delta t}
$$
を認めて使う。
<div style="text-align:center; margin:1em 0;">
    <img src="assets/dynamicsTheory/kepler-second-approx.png"
          alt="面積速度"
          style="max-width:70%; height:auto;" />
  </div>
すると、
$$\begin{aligned}
&\lim_{\Delta t \rightarrow 0} \frac{\Delta S}{\Delta t} = \lim_{\Delta t \rightarrow 0} \frac{\Delta T}{\Delta t} \\ \ \\
&= \lim_{\Delta t \rightarrow 0} \frac{1}{2}|\vec r(t)| \frac{ |\vec r(t+\Delta t)- \vec r(t)|}{\Delta t}\sin \theta_{\vec r(t), \vec r(t) - \vec r(t+\Delta t)}\\ \ \\
& = \frac{1}{2}|\vec r(t)||\vec v(t)|\sin \theta_{\vec r(t), \vec v(t)} \\ \ \\
&\underset{lemma.2}{=}\ \ \Biggr|\left(\begin{smallmatrix}\displaystyle y(t){v_x}(t) - x(t){v_y}(t) \\ \ \\ \displaystyle z(t){v_y}(t) - y(t){v_z}(t) \\ \ \\\displaystyle x(t){v_z}(t) - z(t){v_x}(t)\end{smallmatrix}\right)\Biggr|\\ \ \\ 
& \underset{lemma.1}{=}constant \ value
\end{aligned}$$　⬜︎


  <div class="theory-common-box">
    <p>命題1（外積ベクトルの直交性）
      平行でない2つのベクトル、$\vec a=\begin{pmatrix}a_x\\[6pt]a_y\\[6pt]a_z\end{pmatrix} \neq \vec 0, \quad \vec b=\begin{pmatrix}b_x\\[6pt]b_y\\[6pt]b_z\end{pmatrix} \neq \vec 0$
    に対して、
      $\vec a\times\vec b=\begin{pmatrix}a_yb_z-a_zb_y\\[6pt]a_zb_x-a_xb_z\\[6pt]a_xb_y-a_yb_x\end{pmatrix}$
      は $\vec a$ および $\vec b$ に直交する。
    </div>
    <div class="proof-box">証明</div>
    <p>内積を普通に計算して$0$になる事を示す：</p>
 $$\begin{aligned}
      & \ \ (\vec a\times\vec b)\cdot\vec a \\[6pt]
      &= (a_yb_z-a_zb_y)a_x + (a_zb_x-a_xb_z)a_y + (a_xb_y-a_yb_x)a_z\\[6pt]
      &= a_xa_yb_z - a_xa_zb_y + a_ya_zb_x - a_ya_xb_z + a_za_xb_y - a_za_yb_x.
    \end{aligned}$$
    上記の式は全てが打ち消し合い，0になる。従って $(\vec a\times\vec b)\cdot\vec a=0$．同様に計算すれば $(\vec a\times\vec b)\cdot\vec b=0$ となる．したがって $\vec a\times\vec b$ は $\vec a,\vec b$ に直交する。
  　⬜︎
  <div class="theory-common-box">
    命題2:位置ベクトル$\vec r (t) \neq \vec 0$と速度ベクトル$\vec v (t) \neq \vec 0$が互いに平行でないなら、角運量ベクトルは位置・速度に直交する。
  </div>

  <div class="proof-box">証明</div>
  命題1より直ちに従う。　⬜︎
    <div class="theory-common-box">
    命題3（外積が零であることと平行性）: $\vec a ,\vec b ,\neq \vec 0$ の時、$\vec a\times\vec b = \vec 0 \Leftrightarrow \vec a \parallel \vec b$
    </div>
  <div class="proof-box">証明</div>
    <div class="paragraph-box">$\Rightarrow$を示す</div><br>
    補題2より $ |\vec a\times\vec b|= |a||b| \sin \theta$<br>
    仮定より、$|a||b| \sin \theta = 0$より、$\sin\theta=0$なので $\theta=0\ or \  \pi$（平行または反平行）である。<br>
    <div class="paragraph-box">$\Leftarrow$を示す</div><br>
  補題2より $ |\vec a\times\vec b|= |a||b| \sin \theta$<br>
  仮定より、$\theta = 0 \ or \ \pi$ よって、$\sin \theta = 0$なので、 $ |\vec a\times\vec b|= |a||b| \sin \theta = \vec 0$<br>
    よって、$\vec a\times\vec b = \vec 0$

  <div class="theory-common-box">
    命題4:原点と軸(座標系)を上手く選び，初期時刻に $z(0)=0,\ v_z(0)=0$ を取り、かつ角運量ベクトルが $\vec L(0)\neq\vec0$ (非零)であるなら，任意の $t$ について $z(t)=0,\ v_z(t)=0$ が成り立つ。</p>
    </div>
    <div class="proof-box">証明</div>
    <p>角運動量保存則(補題1)と仮定より，成分表示は次の形で時間によらず一定である：</p>
    $$
    \begin{pmatrix}
      z(t)v_y(t) - y(t)v_z(t)\\[6pt]
      x(t)v_z(t) - z(t)v_x(t)\\[6pt]
      y(t)v_x(t) - x(t)v_y(t)
    \end{pmatrix}
    =
    \begin{pmatrix}
      0\\[6pt]
      0\\[6pt]
      y(0)v_x(0)-x(0)v_y(0)
    \end{pmatrix}.
    $$
    <p>これにより系は次の連立式を満たす：</p>

    $$
    \begin{cases}
      z(t)v_y(t) = y(t)v_z(t) &\quad\cdots(1)\\[6pt]
      x(t)v_z(t) = z(t)v_x(t) &\quad\cdots(2)\\[6pt]
      y(t)v_x(t) = x(t)v_y(t) + y(0)v_x(0)-x(0)v_y(0) &\quad\cdots(3)
    \end{cases}
    $$

    <p>式(3)の両辺に $v_z(t)$ を掛け、(1),(2) を用いて整理すると</p>
    $$\begin{aligned}
      \ \ \ &y(t)v_x(t) = x(t)v_y(t) + y(0)v_x(0)-x(0)v_y(0) &\quad\cdots(3)\\[6pt]
      \underset{\times v_z(t)}{\Leftrightarrow}\  &y(t)v_x(t)v_z(t) = x(t)v_y(t)v_z(t) + \Bigl(y(0)v_x(0)-x(0)v_y(0)\Bigr)v_z(t)\\[6pt]
      \underset{(1),(2)\text{代入}}{\Leftrightarrow}\  &v_x(t)z(t)v_y(t) = v_y(t)z(t)v_x(t) + \Bigl(y(0)v_x(0)-x(0)v_y(0)\Bigr)v_z(t)\\[6pt]
      \Leftrightarrow\  &v_z(t)\Bigl(y(0)v_x(0)-x(0)v_y(0)\Bigr) = 0
    \end{aligned}$$
    <p>初期角運量が非零である仮定は右辺括弧内がゼロでないことを意味するので，$v_z(t)=0$ が得られる。<br>
    これを(1),(2) に代入すると 、
    $$\begin{aligned}
    \begin{cases}
    z(t)v_y(t)=0\\[6pt]
    z(t)v_x(t)=0
    \end{cases}
    \end{aligned}$$
    速度 $\vec v(t)$ が零でないことにより $v_x(t)$ または $v_y(t)$ の少なくとも一方は非零なので，$z(t)=0$ が導かれる。Q.E.D.
    <div class="theory-common-box">
    定理:万有引力ポテンシャル配下の物体の運動は平面上で行われる。
    </div>
  <div class="proof-box">証明</div>
  命題4より、座標軸を適切に取ると、任意の時刻について$z(t)=0,\ v_z(t)=0$が成り立ち、z方向の運動が起きない。これはすなわち、物体の運動が平面上で運行する事を意味する。 Q.E.D

"""
);