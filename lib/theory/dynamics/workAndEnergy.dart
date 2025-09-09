import '../../model.dart';

final workAndEnergy = TheoryTopic(
  title: '仕事とエネルギー',
  isNew: false,
  latexContent: r"""

<div class="theory-common-box">運動エネルギーの定義</div>
<p>
質量 $m$ の質点の速さが$v$の時、  
$\displaystyle \frac{1}{2} m v^2$をこの質点の<b>運動エネルギー</b> という。
</p>

<div class="theory-common-box">命題1:1次元で力と運動方向が揃っている場合、質点の運動の始点を$x_0$,終点を$x_1$とすると、仕事は下記となる。
\[
W=\int_{x(t_0)}^{x(t_1)} F_x(x)\,dx
\]
</div>
<p><div class="proof-box">証明</div>
仕事の定義より、
\begin{aligned}
W &= \int_C \vec F\cdot d\vec r\\[4pt]
&= \lim_{| P | \to 0}
\sum_{i=1}^{N(P)} (\vec F_i\cdot\vec\tau_i)\,\Delta s_i \\[4pt] 
&\;\Bigl(= \lim_{| P | \to 0}
\sum_{i=1}^{N(P)} |\vec F_i| \,\Delta s_i\Bigr)\\[4pt]
\end{aligned}
上記は、分割幅を小さくすると区分求積の形となり
\[
W=\int_{x1}^{x0} F_x(x)\,dx
\]
に一致することが分かる。　Q.E.D
</p>

<div class="theory-common-box">定理1：仕事$W$は次の積分に一致する。
\begin{aligned}
W = \int_{t_0}^{t_1} \vec F(t)\cdot \vec v(t)\,dt.
\end{aligned}
</div>

<div class="proof-box">証明</div>
<p>
仕事の定義より、
\begin{aligned}
W = \int_C \vec F\cdot d\vec r = \lim_{| P | \to 0}
\sum_{i=1}^{N(P)} (\vec F_i\cdot\vec\tau_i)\,\Delta s_i
\end{aligned}

ここで曲線のパラメータ$t$を導入する。<br>
上の$\Delta s_i$は、各区間 \([t_{i-1},t_i]\) について積分の平均値の定理より点 \(\eta_i\in[t_{i-1},t_i]\) が存在して
\[
\Delta s_i=\int_{t_{i-1}}^{t_i}|\vec v(t)|\,dt=|\vec v(\eta_i)|(t_i-t_{i-1}).
\]とできる。
この \(\eta_i\) を各分割区間の代表点として取れば
\[
\vec F_i\cdot\vec\tau_i\,\Delta s_i
=\vec F(\vec r(\eta_i))\cdot\vec v(\eta_i)\,(t_i-t_{i-1}).
\]
したがって \(|P|\to0\) とすると区分求積法より
\begin{aligned}
W&=\vec F(\vec r(\eta_i))\cdot\vec v(\eta_i)\,(t_i-t_{i-1}) \\[5pt]
&= \int_{t_0}^{t_1}\vec F(\vec r(t))\cdot\vec v(t)\,dt.
\end{aligned}
Q.E.D
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
定理1より、質点に働く合力が時刻$t_0$から$t_1$に渡って質点にした仕事$W$そのもの
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

// <div class="theory-common-box">命題3（一定の合力が働く場合の仕事）:質点が受ける合力$\vec F$が一定ならば、時刻$t_0$での質点の位置$\vec a= \vec r(t_0)$から時刻$t_1$での質点の位置$\vec b= \vec r(t_1)$までの質点の移動で、合力が質点にした仕事は
// $W = \vec{f} \cdot \bigl(\vec{b} - \vec{a}\bigr)$となる。
// </div>
// <div class="proof-box">証明</div>
// 仕事の定義より、
// \begin{aligned}
// W &= \int_C \vec F\cdot d\vec r
// &= \lim_{| P | \to 0}
// \sum_{i=1}^{N(P)} (\vec F_i\cdot\vec\tau_i)\,\Delta s_i \\[4pt] 
// \end{aligned}
// 仮定より \(\vec{F}\) は一定なので、
// \begin{aligned}
// W &= \lim_{| P | \to 0} \sum_{i=1}^{N(P)} (\vec F \cdot\vec\tau_i)\,\Delta s_i \\[4pt] 
// = \lim_{| P | \to 0} \sum_{i=1}^{N(P)} (\vec F \cdot\vec\tau_i)\,\Delta s_i \\[4pt] 

// \end{aligned}
// 　Q.E.D