import '../../model.dart';

final workAndEnergy = TheoryTopic(
  title: '仕事とエネルギー',
  latexContent: r"""

<div class="theory-common-box">運動エネルギーの定義</div>
<p>
質量 $m$ の質点の速さが$v$の時、  
$\displaystyle \frac{1}{2} m v^2$をこの質点の<b>運動エネルギー</b> という。
</p>

<div class="theory-common-box">仕事の定義</div>
<p>
質点に働く力を $\displaystyle \vec F(\vec r)$ とし、時刻 $t$ における位置を $\vec r(t)$、速度を $\vec v(t)=\dfrac{d\vec r}{dt}$ と表す。時刻$t_0$から$t_1$ を $N$ 等分して
小さい各時間幅での仕事をその始点での力と位置変化の内積で近似すると、
\[
S_N := \sum_{i=0}^{N-1} \vec F\big(\vec r(t_i)\big)\cdot\big(\vec r(t_{i+1})-\vec r(t_i)\big).
\]
となる。ここで、分割の極限
\begin{aligned}
W &:= \lim_{N\to\infty} S_N \\[6pt]
 &=  \lim_{N\to\infty} \sum_{i=0}^{N-1} \vec F\big(\vec r(t_i)\big)\cdot\big(\vec r(t_{i+1})-\vec r(t_i)\big)
\end{aligned}
を力$\vec F$が時刻$t_0$から$t_1$までにした仕事という。


<div class="theory-common-box">命題1:一次元における仕事は下記となる。
\[
W=\int_{x(t_0)}^{x(t_1)} F_x(x)\,dx
\]
</div>
<p>
特に運動が1次元（$x$ 軸）に沿う場合、$\vec r(t)=(x(t),0,0),\ \ \vec F=(F_x(x),0,0)$ とすると、仕事の定義より、
\begin{aligned}
W &= \lim_{N\to\infty} \sum_{i=0}^{N-1} \vec F\big(\vec r(t_i)\big)\cdot\big(\vec r(t_{i+1})-\vec r(t_i)\big)\\[6pt]
 &= \lim_{N\to\infty} \sum_{i=0}^{N-1} (F_x(x),0,0) \cdot \Big(x(t_{i+1}) - x(t_{i}),0,0 \Big)\\[6pt]
 &= \lim_{N\to\infty} \sum_{i=0}^{N-1} F_x \Big(x(t_{i+1})-x(t_i)\Big)
\end{aligned}
横軸$x$,縦軸$F$のグラフを考えると、分割幅を小さくすると区分求積の形となり
\[
W=\int_{x(t_0)}^{x(t_1)} F_x(x)\,dx
\]
に一致することが分かる。　Q.E.D
</p>

<div class="theory-common-box">命題2:力が一定の場合、一次元における仕事は下記となる。
\[W = F \bigr( x(t_1) - x(t_0) \bigl) = F \Delta x\]
</div>
<div class="proof-box">証明</div>
命題1を用いて、$F$を定数という条件のもと計算を行う。
\begin{aligned}
W &= \int_{x(t_0)}^{x(t_1)} Fdx = F \int_{x(t_0)}^{x(t_1)} dx \\[6pt]
&= F \bigr( x(t_1) - x(t_0) \bigl) = F \Delta x
\end{aligned}
Q.E.D


<div class="theory-common-box">命題3（一定の合力が働く場合の仕事）:質点が受ける合力$\vec F$が一定ならば、時刻$t_0$での質点の位置$\vec a= \vec r(t_0)$から時刻$t_1$での質点の位置$\vec b= \vec r(t_1)$までの質点の移動で、合力が質点にした仕事は
$W = \vec{f} \cdot \bigl(\vec{b} - \vec{a}\bigr)$となる。
</div>

<div class="proof-box">証明</div>
仕事の定義より、
\begin{aligned}
W = \lim_{N\to\infty} \sum_{i=0}^{N-1} \vec F\big(\vec r(t_i)\big)\cdot\big(\vec r(t_{i+1})-\vec r(t_i)\big)
\end{aligned}
仮定より \(\vec{F}\) は一定なので、
\begin{aligned}
W &= \lim_{N\to\infty} \sum_{i=0}^{N-1} \vec F\big(\vec r(t_i)\big)\cdot\big(\vec r(t_{i+1})-\vec r(t_i)\big)\\[6pt]
&=\lim_{N\to\infty} \sum_{i=0}^{N-1} \vec F \cdot\big(\vec r(t_{i+1})-\vec r(t_i)\big)\\[6pt]
&= \vec F \cdot \lim_{N\to\infty} \sum_{i=0}^{N-1}\big(\vec r(t_{i+1})-\vec r(t_i)\big)\\[6pt]
&= \vec F \cdot \lim_{N\to\infty}  \big(\vec r(t_{N})-\vec r(t_0)\big)\\[6pt]
&= \vec F \cdot \lim_{N\to\infty} \big(\vec r(t_{1})-\vec r(t_0)\big)\\[6pt]
&= \vec F \cdot \big(\vec r(t_{1})-\vec r(t_0)\big)\\[6pt]
&= \vec F \cdot \big(\vec b-\vec a \big)
\end{aligned}
　Q.E.D
<div class="theory-common-box">定理1：仕事$W$は次の積分に一致する。
\begin{aligned}
W = \int_{t_0}^{t_1} \vec F(t)\cdot \vec v(t)\,dt.
\end{aligned}
</div>

<div class="proof-box">証明</div>
<p>
極限を取る前の近似的な仕事$\displaystyle S_N = \sum_{i=0}^{N-1} \vec F\big(\vec r(t_i)\big)\cdot\big(\vec r(t_{i+1})-\vec r(t_i)\big)$を考える。<br>
各小区間で位置変化を速度で近似すると
\[
\vec r(t_{i+1})-\vec r(t_i) \approx \vec v(t_i)\,\Delta t.
\]
これを $S_N$ に代入すると
\begin{aligned}
S_N & \approx \sum_{i=0}^{N-1} \vec F\big(\vec r(t_i)\big)\cdot \vec v(t_i)\,\Delta t\\[6pt]
 & = \sum_{i=0}^{N-1} \vec F\big(\vec r(t_i)\big)\cdot \vec v(t_i)\,\frac{t_1-t_0}{N}
\end{aligned}
今、$N\to \infty$の極限で、$S_N$は定義より仕事$W$に一致。<br>
$\displaystyle \sum_{i=0}^{N-1} \vec F\big(\vec r(t_i)\big)\cdot \vec v(t_i)\,\frac{t_1-t_0}{N}$は関数 $g(t)=\vec F(\vec r(t))\cdot\vec v(t)$ の区分求積の形である。よって、
$\displaystyle W = \int_{t_0}^{t_1} \vec F(\vec r(t))\cdot\vec v(t)\,dt$　　Q.E.D
</p>

<div class="theory-common-box">定理2：仕事と運動エネルギーの関係
<p>
質量 $m$ の質点の時刻 $t_0$ から $t_1$ にかけての運動エネルギー変化は、  
質点に対して働く全ての力が時刻 $t_0$ から $t_1$にかけて質点にした仕事の総和に等しい。
</p>
</div>
<div class="proof-box">証明</div>
質点に働く合力を \(\vec{F}(t)\Bigl(= \displaystyle \sum_{i=1}^{n} \vec{F}_i(t) \Bigr) \) とする。<br>
運動方程式より$m \vec{a}(t) = \vec{F}(t)$が成り立つ。<br>
両辺について \(\vec{v}(t)\)との内積を取り、時刻 $t_0$ から $t_1$ にわたって積分すると
\[
\int_{t_0}^{t_1} m \vec{a}(t) \cdot \vec{v}(t)\, dt
= \int_{t_0}^{t_1} \vec{F}(t) \cdot \vec{v}(t)\, dt
\]
<div class="paragraph-box">右辺</div><br>
定義より、(1)の右辺は質点に働く合力が、時刻$t_0$から$t_1$に渡って質点にした仕事$W$である。
<p>
<div class="paragraph-box">左辺</div><br>
積の微分公式から$\displaystyle \frac{1}{2} \bigl(v(t)^2\bigr)' = \vec{a}(t) \cdot \vec{v}(t)$
が成り立つので、(1)の左辺は、下記のように変形できる。
\begin{aligned}
\ \ \ &\int_{t_0}^{t_1} \Bigl(\frac{1}{2} m v(t)^2\Bigr)'\, dt\\[6pt]
&=\Bigl[\frac{1}{2} m v(t)^2\Bigr]_{t_0}^{t_1} \\[6pt]
&=\frac{1}{2} m v(t_1)^2 - \frac{1}{2} m v(t_0)^2\\[6pt]
\end{aligned}
</p>
これは時刻$t_1$と時刻$t_0$での運動エネルギーの変化である。<br>
よって、質点に働く合力が、時刻$t_0$から$t_1$に渡って質点にした仕事は、時刻$t_1$と時刻$t_0$での運動エネルギーの変化と一致する。
　Q.E.D

<div class="theory-common-box">命題：質点の速度に垂直な力は仕事をしない</div>
<div class="proof-box">証明</div>
質点の速度に対して垂直な力を \(\vec{f}(t)\) とすると、任意の時刻 $t$ において  
\(\vec{f}(t) \cdot \vec{v}(t) = 0\) が成り立つ。
したがって、その力が $t_0$ から $t_1$ にかけてした仕事$W$は定理1より
\[
W = \int_{t_0}^{t_1} \vec{f}(t) \cdot \vec{v}(t)\, dt
= \int_{t_0}^{t_1} 0\, dt = 0
\]
である。よって、速度に垂直な力は仕事をしない。Q.E.D.

"""
);
