import '../../model.dart';

final keplerFirstLaw = TheoryTopic(
  title: 'ケプラー第一法則',
  isNew: true,
  latexContent: """
<div class="theory-common-box">
設定・記法
</div>
中心質量 \$M\$ の重力場の下で質量 \$m\$ の粒子が運動するとする。
角運動量保存により運動は固定平面に制限されるので，その平面を \$(x,y)\$ 平面と取り，
三次元ベクトルは縦ベクトルで表す：

\\[
\\vec{r}(t)=\\begin{pmatrix}x(t)\\\\[4pt] y(t)\\\\[4pt] 0\\end{pmatrix},\\qquad
\\vec{v}(t)=\\vec{r}'(t)=\\begin{pmatrix}x'(t)\\\\[4pt] y'(t)\\\\[4pt] 0\\end{pmatrix},\\qquad
r(t)=\\sqrt{x(t)^2+y(t)^2}.
\\]

時間微分はプライム('\\'')表記。
角運動量ベクトルは

\\[
\\vec L:=\\begin{pmatrix}0\\\\[4pt] 0\\\\[4pt] m\\bigl(xy'-yx'\\bigr) \\end{pmatrix}
\\]

である。\\\\

万有引力の法則より、運動方程式は中心星を原点に取ると

\\[
m\\vec{r}''(t)=-\\frac{GMm}{r(t)^3}\\,\\vec{r}(t),
\\]

\$xy\$成分表示では

\\(\\displaystyle x''=-\\frac{GM}{r^3}x,\\quad y''=-\\frac{GM}{r^3}y.\\)

となる。
</div>

<div class="theory-common-box">
定義:レンツベクトル,離心ベクトル,離心率
</div>
天下りではあるが、

\\[
\\vec{A}=\\begin{pmatrix}mL\\,y' - \\frac{GM\\,m^2 x}{r}\\\\[4pt]
 -mL\\,x' - \\frac{GM\\,m^2 y}{r}\\\\[4pt] 0\\end{pmatrix},
\\]

という保存量が知られている。これをレンツベクトルと言う。
またこのベクトルを無次元化したベクトル

\\[
\\vec{e}:=\\frac{\\vec{A}}{GM\\,m^2},\\qquad e:=\\lvert\\vec{e}\\rvert,
\\]

を離心ベクトルと言い、離心ベクトルの大きさを離心率という。
</div>

<div class="theory-common-box">
命題1:レンツベクトル,離心ベクトルは時間に依らない定ベクトルである。
</div>

<div class="proof-box">証明</div>
両者は定数倍の関係であるから、離心ベクトルが時間によらないことを示せば十分。

\\(\\vec{e}\\) の成分は

\\[
e_x=\\frac{A_x}{GMm^2}=\\frac{L\\,y'}{GMm}-\\frac{x}{r},\\qquad
e_y=\\frac{A_y}{GMm^2}=-\\frac{L\\,x'}{GMm}-\\frac{y}{r}.
\\]

\\(e_x'\\) を計算する（\\(L\\) は角運動量保存により定数）：

\\[
e_x'=\\frac{L\\,y''}{GMm}-\\frac{\\mathrm d}{\\mathrm d t}\\Bigl(\\frac{x}{r}\\Bigr).
\\]

運動方程式より \\(y''=-\\dfrac{GM}{r^3}y\\) なので

\\[
\\frac{L\\,y''}{GMm}=-\\frac{L\\,y}{m r^3}.
\\]

また

\\[
\\frac{\\mathrm d}{\\mathrm d t}\\Bigl(\\frac{x}{r}\\Bigr)
=\\frac{x'}{r}-x\\frac{r'}{r^2},\\qquad
r'=\\frac{x x'+y y'}{r},
\\]

ゆえに

\\[
\\frac{\\mathrm d}{\\mathrm d t}\\Bigl(\\frac{x}{r}\\Bigr)
=\\frac{x'}{r}-\\frac{x^2 x'}{r^3}-\\frac{x y y'}{r^3}.
\\]

したがって

\\[
e_x'=-\\frac{L\\,y}{m r^3}-\\frac{x'}{r}+\\frac{x^2 x'}{r^3}+\\frac{x y y'}{r^3}.
\\]

ここで \\(L=m(xy'-yx')\\) を代入すると

\\[
\\begin{aligned}
e_x'&=\\Bigl(-\\frac{x y y'}{r^3}+\\frac{y^2 x'}{r^3}\\Bigr)-\\frac{x'}{r}+\\frac{x^2 x'}{r^3}+\\frac{x y y'}{r^3}\\\\
&=-\\frac{x'}{r}+\\frac{(x^2+y^2)x'}{r^3}=-\\frac{x'}{r}+\\frac{x' r^2}{r^3}=0.
\\end{aligned}
\\]

同様の計算で \\(e_y'=0\\) となり，\\(e_z\\equiv0\\) だから、各成分の時間微分が0となり、\\(\\vec{e}'=\\mathbf0\\) が示された。

</div>

<div class="theory-common-box">
命題2（軌道方程式）<br>
極座標 \\((r,\\theta)\\) を用いると軌道は\$r,\\theta\$の関係式で、下記のように表される。
\\(\\displaystyle r(\\theta)=\\dfrac{L^{2}}{GM\\,m^{2}\\bigl(1+e\\cos(\\theta-\\alpha)\\bigr)}\\)
</div>

<div class="proof-box">証明</div>
成分で \\(\\vec{e}\\cdot\\vec{r}=e_x x+e_y y\\) を計算すると

\\[
\\vec{e}\\cdot\\vec{r}=\\frac{L}{GMm}(x y'-y x')-\\frac{x^2+y^2}{r}
=\\frac{L^{2}}{GM m^2}-r\\quad\\cdots(1)
\\]

一方、離心ベクトルを\\(\\vec{e}=e(\\cos \\alpha, \\sin \\alpha)\\)のように\\(x\\)軸からの角度を用いて表すと

\\[
\\vec{e}\\cdot\\vec{r}=e\\,r\\cos(\\theta-\\alpha)\\quad\\cdots(2)
\\]

なので、(1)(2)より

\\begin{align*}
&e\\,r\\cos(\\theta-\\alpha)=\\frac{L^{2}}{GM m^2}-r\\\\[7pt]
&r\\bigl(1+e\\cos(\\theta-\\alpha)\\bigr)=\\frac{L^{2}}{GM m^2}\\\\[7pt]
\\Leftrightarrow\\quad & r=\\frac{L^{2}}{GM m^2\\bigl(1+e\\cos(\\theta-\\alpha)\\bigr)}
\\end{align*}

従って所望の形が得られた。

</div>

<div class="theory-common-box">
命題3（離心率と全エネルギー）<br>
離心率\\(e\\)とエネルギー \\(E\\) との間には、
\\(\\displaystyle e^{2}=1+\\dfrac{2E L^{2}}{G^{2}M^{2}m^{3}} \\)
の関係が成り立つ。</div>
<div class="proof-box">証明</div>
普通に計算していけば示せる。

\\begin{align*}
e^2 &= e_x^2 + e_y^2
= \\left(\\frac{L\\, y'}{GM m} - \\frac{x}{r}\\right)^2 + \\left(-\\frac{L\\, x'}{GM m} - \\frac{y}{r}\\right)^2 \\\\[6pt]
&= \\frac{L^2}{G^2 M^2 m^2} (x'^2 + y'^2) + \\frac{x^2 + y^2}{r^2} -\\frac{2L}{GM mr} ( xy'- x' y ) \\quad\\cdots(1) 
\\end{align*}

全エネルギーより
\\(\\displaystyle E = \\frac12 m v^2 - \\frac{GM m}{r} \\Leftrightarrow v^2 = \\frac{2E}{m} + \\frac{2 GM}{r}\\)

また、\\(\\displaystyle xy'- x' y  = \\frac L m \\)が成り立つ。
これを(1)に代入して

\\begin{align*}
e^2 &= \\frac{L^2}{G^2 M^2 m^2} \\Bigl(  \\frac{2E}{m} + \\frac{2 GM}{r} \\Bigr) + 1- \\frac{2L^2}{GM m^2r}\\\\[6pt]
&= \\frac{2EL^2}{G^2 M^2 m^3} + \\frac{2L^2}{GM m^2r} + 1 - \\frac{2L^2}{GM m^2r}\\\\[6pt]
&= 1 + \\frac{2EL^2}{G^2 M^2 m^3} 
\\end{align*}

</div>

<div class="theory-common-box">
命題4（離心率 \\(e\\) による分類）
</div>
極方程式
\\[
r(\\theta)=\\frac{L^{2}}{GM\\,m^2(1+e\\cos(\\theta-\\alpha))},\\qquad
\\]
（\\(L\\neq0\\)）により，離心率 \\(e\\) の値によって軌道は次のように分類される。
<div class="paragraph-box">
  (1) \(0 \\le e < 1\)（楕円：束縛軌道）
</div><br>
このケースがケプラー第一法則にあたる。極方程式の分母は常に正なので \\(r(\\theta)\\) は有界（最大値・最小値が存在する）である。
近点（pericenter）と遠点（apocenter）はそれぞれ
\\[
r_{\\min}=\\frac{L^{2}}{GM\\,m^{2}(1+e)},\\qquad
r_{\\max}=\\frac{L^{2}}{GM\\,m^{2}(1-e)}.
\\]
長半径は
\\[
a=\\frac{1}{2}\\,(r_{\\min}+r_{\\max})=\\frac{L^{2}}{GM\\,m^{2}(1-e^{2})},
\\]
であり、近点・遠点はそれぞれ \\(a(1-e)\\)、\\(a(1+e)\\) と表される。
また \\(\\theta=\\alpha\\) が近点方向で \\(r_{\\min}=\\dfrac{L^{2}}{GM\\,m^{2}(1+e)}\\) を与え、\\(\\theta=\\alpha+\\pi\\) が遠点方向で \\(r_{\\max}=\\dfrac{L^{2}}{GM\\,m^{2}(1-e)}\\) を与える。
特殊例：\\(e=0\\) のとき円軌道。

<div class="paragraph-box">
(2) \\(e=1\\)（放物線：臨界軌道）
</div><br>
極方程式は
\\[
r(\\theta)=\\frac{L^{2}}{GM\\,m^{2}(1+\\cos(\\theta-\\alpha))}.
\\]
分母が \\(1+\\cos(\\theta-\\alpha)=0\\) となる角、すなわち \\(\\theta=\\alpha+\\pi\\) に向かって \\(r\\to\\infty\\)。
したがって放物線は一意の発散方向 \\(\\theta=\\alpha+\\pi\\) を持つ。

<div class="paragraph-box">(3) \\(e>1\\)（双曲線：非束縛軌道）
</div><br>

近点は \\(\\cos(\\theta-\\alpha)=1\\)（すなわち \\(\\theta=\\alpha\\)）で達成され、
\\[
r_{\\min}=\\frac{L^{2}}{GM\\,m^{2}(1+e)}>0.
\\]
無限遠へ向かう角（漸近方向）は分母が零となる角で定まり、
\\[
1+e\\cos(\\theta-\\alpha)=0 \\iff \\cos(\\theta-\\alpha)=-\\frac{1}{e},
\\]
を満たす角が二つ存在する。これらが双曲線の二本の漸近方向に対応し、その方向に向かって \\(r\\to\\infty\\) となる。


<div class="theory-common-box">
命題5（軌道長半径とエネルギー）<br>
楕円軌道の時、全エネルギー\\(E\\)と軌道長半径\\(a\\)の間に
\\(\\displaystyle E=-\\frac{GM\\,m}{2a}\\quad(<0)\\)
の関係式が成り立つ。すなわち、エネルギーは軌道長半径のみで決まる。
</div>
<div class="proof-box">証明</div>
命題3の式

\\[
e^2=1+\\frac{2EL^2}{G^2M^2m^3}
\\]

を \\(E\\) について解くと

\\[
E=\\frac{G^2M^2m^3}{2L^2}(e^2-1)
   =-\\frac{G^2M^2m^3}{2L^2}(1-e^2).
\\]

上の式に軌道長半径

\\begin{align*}
 a= \\frac {r_{min} +r_{max}}{2} &= \\frac{L^{2}}{GM\\,m^{2}(1-e^{2})}\\\\[6pt]
 \\Leftrightarrow \\ 1-e^{2}&=\\frac{L^{2}}{GM\\,m^{2}a}
\\end{align*}

を代入すると、

\\[
E=-\\frac{GM\\,m}{2a}.
\\]
</div>

<div class="theory-common-box">
命題6（焦点が原点であることと準線の方程式）<br>
極方程式
\\(\\displaystyle r(\\theta)=\\frac{L^2}{GM\\,m^2(1+e\\cos(\\theta-\\alpha))}\\
\\text{(ただし}L\\neq0\\text{)}\\)によって表される曲線は，
原点が焦点，準線が
\\(\\displaystyle \\mathcal D:\\  x\\cos\\alpha+y\\sin\\alpha=\\frac{L^2}{GM\\,m^2e}\\)、離心率が \\(e\\)の円錐曲線である．
</div>
<div class="proof-box">証明</div>
焦点 \\(F\\)を原点とし、直線 \\(\\mathcal D\\)，離心率 \\(e>0\\)が与えられた時の
円錐曲線の方程式が命題2の軌道の式と一致する事を示す。

点\\(P\\)が円錐曲線上にあることの定義は

\$\$
\\frac{|PF|}{d(P,\\mathcal D)}=e,
\$\$

である．ここで \\(|PF|=r=\\sqrt{x^2+y^2}\\)，\\(d(P,\\mathcal D)\\) は点 \\(P\\) から直線 \\(\\mathcal D\\) までの垂直距離。

準線の候補として天下りではあるが、

\$\$
\\mathcal D:\\  x\\cos\\alpha+y\\sin\\alpha=\\frac{L^2}{GM\\,m^2e}
\$\$

を取ると，点 \\(P=(x,y)\\) から \\(\\mathcal D\\) までの距離は直線の距離公式より

\$\$
d(P,\\mathcal D)=\\Bigl|x\\cos\\alpha+y\\sin\\alpha-\\frac{L^2}{GM\\,m^2e}\\Bigr|
\$\$

である．定義式 \\(r=ed(P,\\mathcal D)\\) を書くと

\$\$
r=e\\Bigl|x\\cos\\alpha+y\\sin\\alpha-\\frac{L^2}{GM\\,m^2e}\\Bigr|
\$\$

となる．極座標 \\((r,\\theta)\\) を用いると \\(x=r\\cos\\theta,\\ y=r\\sin\\theta\\) より

\$\$
\\cos(\\theta-\\alpha)=\\frac{x\\cos\\alpha+y\\sin\\alpha}{r}.
\$\$

上の等式に代入すると、

\\begin{align*}
r=e\\Bigl|x\\cos\\alpha+y\\sin\\alpha-\\frac{L^2}{GM\\,m^2e}\\Bigr| \\\\[5pt]
r=e\\Bigl|r \\cos(\\theta-\\alpha)-\\frac{L^2}{GM\\,m^2e}\\Bigr| \\cdots(1)
\\end{align*}

ここで、補題より絶対値の中身は負。したがって(1)式より、符号に注意して整理すると

\$\$
r\\bigl(1+e\\cos(\\theta-\\alpha)\\bigr)=\\frac{L^2}{GM\\,m^2}
\$\$

を得る．これは、命題2の軌道の式と同じ。

</div>

<div class="theory-common-box">
[補題] \\ \\ \\ \$r\\cos(\\theta-\\alpha)-\\frac{L^2}{GM\\,m^2e}\$は負の数である。\\\\[6pt]
</div>
<div class="proof-box">証明</div>
\\[
r(\\theta)=\\frac{L^2}{GM\\,m^2}\\cdot\\frac{1}{1+e\\cos(\\theta-\\alpha)}
\\]
から、両辺に \\(1+e\\cos(\\theta-\\alpha)\\) を掛けて変形すると

\\begin{align*}
r\\bigl(1+e\\cos(\\theta-\\alpha)\\bigr)=\\frac{L^2}{GM\\,m^2}.\\\\[6pt]
\\Leftrightarrow \\ r\\cos(\\theta-\\alpha)-\\frac{L^2}{GM\\,m^2e}=-\\frac{r}{e}<0
\\end{align*}
</div>
"""
);
