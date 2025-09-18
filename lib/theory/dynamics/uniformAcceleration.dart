import '../../model.dart';

final uniformAcceleration = TheoryTopic(
  title: '等加速度直線運動',
  imageAsset: 'assets/mindMap/forTopics/uniformAcceleration.png',
  latexContent: r"""
<div class="theory-common-box">命題1（1次元運動の運動方程式）：質量 $m$ の質点に一定の力 $F$ が、直線上に働くとする。このとき運動方程式は
$
F = m a
$である。</div>
<div class="proof-box">証明</div>
<p>ベクトル方程式 $\vec{F} = m\vec{a}$ を1次元上で軸を取れば、ベクトルの成分比較により $F = ma$ を得る。$\square$</p>


<div class="theory-common-box">命題2（等加速度運動）質量 $m$ の質点に一定の力 $F$ が働くならば、質点の加速度は一定である。</div>
<div class="proof-box">証明</div>
<p>命題1より、$\displaystyle a= \frac{F}{m} $となり、$m,F$が一定ならば$a$も一定である。</p>
(注)この一定値$a$は軸の向きに依存する。<br>
(注)初期速度が力の向きと一致している場合、等加速度直線運動となる。<br><br>
<div class="theory-common-box">命題3（速度の式）：質量 $m$ の質点の加速度が一定値 $a$ である時、速度は
$
v(t) = v_0 + a t
$
である。</div>

<div class="proof-box">証明</div>
$$\begin{aligned}
v' &= a \quad \quad \\[6pt]
\Leftrightarrow \int_{0}^{t} v' \, dt &= \int_{0}^{t} a \, dt \\[6pt]
\Leftrightarrow v(t) - v_0 &= a t \\[6pt]
\Leftrightarrow v(t) &= v_0 + at
\end{aligned}$$
$\square$


<div class="theory-common-box">命題4（位置の式）：質量 $m$ の質点が初期位置 $x_0$、初速度 $v_0$ で運動を始め、一定の加速度 $a$ を受けるとき、位置は$ \displaystyle
x(t) = x_0 + v_0 t + \frac{1}{2} a t^2$である。</div>



<div class="proof-box">証明</div>
$$\begin{aligned}
x' &= v \quad  \quad \\[6pt]
\Leftrightarrow \int_{0}^{t} x' \, dt &= \int_{0}^{t} (v_0 + a t) \, dt \\[6pt]
\Leftrightarrow x(t) - x_0 &= v_0 t + \frac{1}{2} a t^2 \\[6pt]
\Leftrightarrow x(t) &= x_0 + v_0 t + \frac{1}{2} a t^2
\end{aligned}$$
$\square$

<div class="theory-common-box">命題5（速度と変位の関係）：質点の速度と変位には次の関係が成り立つ：
$$
v^2 - v_0^2 = 2 a (x - x_0)
$$</div>

<div class="proof-box">証明</div>
命題3,4 より
$$\begin{aligned}
\begin{cases}
 & v = v_0 + a t& \quad \\[6pt]
&x - x_0 = v_0 t + \frac{1}{2} a t^2 &
\end{cases}
\end{aligned}$$
上式を$「t=」$の形に変形した式、$\displaystyle t = \frac{v - v_0}{a} $を下式に代入すると、

$$\begin{aligned}
x - x_0 &= v_0\frac{v-v_0}{a} + \frac{1}{2}a \left(\frac{v-v_0}{a}\right)^2 \\[6pt]
\Leftrightarrow x - x_0 &= \frac{v_0(v-v_0)}{a} + \frac{1}{2a}(v-v_0)^2 \\[6pt]
\Leftrightarrow a(x-x_0) &= v_0(v-v_0) +\frac{1}{2}(v-v_0)^2 \\[6pt]
\Leftrightarrow v^2 &= v_0^2 + 2a(x-x_0)\\[6pt]
\Leftrightarrow v^2 - v_0^2 &= 2a(x-x_0)\\[6pt]
\end{aligned}$$
$\square$

<div class="theory-common-box">命題6（仕事とエネルギー）：質点に一定の力 $F$ が働くとき、運動エネルギーの変化と力の仕事は一致する：
$$
\frac12 m v^2 - \frac12 m v_0^2 = F (x - x_0)
$$</div>

<div class="proof-box">証明</div>
命題5の式に質量 $ \displaystyle \frac {m} {2} $ を掛けて
$$
\frac{1}{2} m (v^2 - v_0^2) = m a (x - x_0)
$$
を得る。ここで $F=ma$ より
$$
\frac{1}{2} m v^2 - \frac{1}{2} m v_0^2 = F(x-x_0)
$$
となる。左辺は運動エネルギーの変化、右辺は力のした仕事である。
""",
);
