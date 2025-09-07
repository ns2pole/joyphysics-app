import '../../model.dart';

final momentum = TheoryTopic(
  title: '質点における運動量と力積',
  isNew: false,
  latexContent: r"""

<div class="theory-common-box">運動量の定義</div>
<p>
質量 $m$ の質点が速度 \(\vec{v}\) で動いているとき、  
\(\, m \vec{v}\,\) を質点の <b>運動量</b> という。
</p>

<div class="theory-common-box">力積の定義</div>
<p>
時刻 $t_0$ から $t_1$ までの間に質点に力 \(\vec{F}(t)\) が作用した時、
ベクトル量$\displaystyle \int_{t_0}^{t_1} \vec{F}(t)\, dt$を質点が受けた力積という。
</p>

<div class="theory-common-box">平均の力の定義</div>
<p>
質点に、時刻 $t_0$ から $t_1$ の間に力 \(\vec{F}(t)\) が働いている時、
$\displaystyle \vec{F}_{\mathrm{ave}} = \frac{1}{t_1 - t_0} \int_{t_0}^{t_1} \vec{F}(t)\, dt$
を時刻$t_0$から$t_1$の間に物体が受けた<b>平均の力</b> という。
</p>

<div class="theory-common-box">命題：ある時間区間において、質点の運動量の変化は、その時間区間に受けた <b>力積</b> に等しい。
</div>
<div class="proof-box">証明</div>
<p>
質量 $m$ の質点に時刻 $t_0$ から $t_1$ まで力 \(\vec{F}(t)\) が加わるとき、
\[
m \vec{v}(t_1) - m \vec{v}(t_0) = \int_{t_0}^{t_1} \vec{F}(t)\, dt
\]
が成り立つことを示す。
</p>
<p>
運動方程式 \(m \vec{a}(t) = \vec{F}(t)\) の両辺について時刻 $t_0$ から $t_1$ にわたって積分すると
\[
\int_{t_0}^{t_1} m \vec{a}(t)\, dt = \int_{t_0}^{t_1} \vec{F}(t)\, dt
\]
</p>
<p>
加速度 \(\vec{a}(t) = \vec{v}'(t)\) を代入すれば
\begin{aligned}
\ \ \ \ \ &\int_{t_0}^{t_1} m \vec{v}'(t)\, dt = \int_{t_0}^{t_1} \vec{F}(t)\, dt\\[7pt]
\Leftrightarrow &\Bigl[ m \vec{v}(t) \Bigr]_{t_0}^{t_1} = \int_{t_0}^{t_1} \vec{F}(t)\, dt\\[7pt]
\ \ \ \ \ &m \vec{v}(t_1) - m \vec{v}(t_0) = \int_{t_0}^{t_1} \vec{F}(t)\, dt
\qquad \text{Q.E.D.}
\end{aligned}
</p>

"""
);
