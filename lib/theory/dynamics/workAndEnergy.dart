import '../../model.dart';

final workAndEnergy = TheoryTopic(
  title: 'エネルギーと仕事',
  latexContent: r"""

<div class="theory-common-box">運動エネルギーの定義</div>
<p>
質量 $m$ の質点の速さが$v$の時、  
$\displaystyle \frac{1}{2} m v^2$をこの質点の<b>運動エネルギー</b> という。
</p>

<div class="theory-common-box">仕事の定義</div>
<p>
質点に働く力を \(\vec{F}(t)\) とし、その時刻 $t$ における速度を \(\vec{v}(t)\) とするとき、
時刻 $t_0$ から $t_1$ にかけて \(\vec{F}(t)\) が質点にした <b>仕事</b>を
$\displaystyle \int_{t_0}^{t_1} \vec{F}(t) \cdot \vec{v}(t)\, dt$
で定義する。
</p>

<div class="theory-common-box">命題：運動エネルギーと仕事の関係（仕事とエネルギーの関係）
<p>
質量 $m$ の質点の時刻 $t_0$ から $t_1$ にかけての運動エネルギー変化は、  
質点に対して働く全ての力による仕事の総和に等しい。
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
<p>
ここで積の微分公式から
\[
\frac{1}{2} \bigl(v(t)^2\bigr)' = \vec{a}(t) \cdot \vec{v}(t)
\]
が成り立つので、これを (1) に代入すると、
\begin{aligned}
\ \ \ \ \ &\int_{t_0}^{t_1} \Bigl(\frac{1}{2} m v(t)^2\Bigr)'\, dt = \int_{t_0}^{t_1} \vec{F}(t) \cdot \vec{v}(t)\, dt \\[6pt]
\Leftrightarrow &\Bigl[\frac{1}{2} m v(t)^2\Bigr]_{t_0}^{t_1} = \int_{t_0}^{t_1} \vec{F}(t) \cdot \vec{v}(t)\, dt \\[6pt]
\Leftrightarrow &\frac{1}{2} m v(t_1)^2 - \frac{1}{2} m v(t_0)^2 = \int_{t_0}^{t_1} \vec{F}(t) \cdot \vec{v}(t)\, dt\\[6pt]
& \text{Q.E.D.}
\end{aligned}
</p>

<div class="theory-common-box">命題（一定の合力が働く場合の仕事）
<p>
質量 $m$ の質点に一定の合力 \(\vec{f}\) が働き、時刻 $t_0$ から $t_1$ にかけて  
位置 \(\vec{a}\) から \(\vec{b}\) に移動したとする。このとき下記の式が成り立つ。
\[
\frac{1}{2} m v(t_1)^2 - \frac{1}{2} m v(t_0)^2 = \vec{f} \cdot \bigl(\vec{b} - \vec{a}\bigr)
\]

</p>
</div>
<div class="proof-box">証明</div>
仮定より \(\vec{F}(t) = \vec{f}\) は一定なので、
\begin{aligned}
\ \ \ \ \ &\frac{1}{2} m v(t_1)^2 - \frac{1}{2} m v(t_0)^2\\[6pt]
&= \int_{t_0}^{t_1} \vec{f} \cdot \vec{v}(t)\, dt \\[6pt]
&= \vec{f} \cdot \int_{t_0}^{t_1} \vec{v}(t)\, dt \\[6pt]
&= \vec{f} \cdot \bigl(\vec{x}(t_1) - \vec{x}(t_0)\bigr) \\[6pt]
&= \vec{f} \cdot \bigl(\vec{b} - \vec{a}\bigr) \ \ \ \ \ \ \text{Q.E.D.}\\[6pt]
\end{aligned}
<div class="theory-common-box">命題：質点の速度に垂直な力は仕事をしない</div>
<div class="proof-box">証明</div>
質点の速度に対して垂直な力を \(\vec{f}(t)\) とすると、任意の時刻 $t$ において  
\(\vec{f}(t) \cdot \vec{v}(t) = 0\) が成り立つ。
したがって、その力が $t_0$ から $t_1$ にかけてした仕事は
\[
\int_{t_0}^{t_1} \vec{f}(t) \cdot \vec{v}(t)\, dt
= \int_{t_0}^{t_1} 0\, dt = 0
\]
である。よって、速度に垂直な力は仕事をしない。Q.E.D.

"""
);
