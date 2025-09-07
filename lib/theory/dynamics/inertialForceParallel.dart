import '../../model.dart';

final inertialForceParallel = TheoryTopic(
  title: '慣性系に対し加速運動する座標系から見た時の慣性力',
  isNew: false,
  latexContent: r"""
<div class="theory-common-box">慣性系の原点に対して非慣性系の原点が $\vec{R}(t)$ で運動しているとする。この時、非慣性系から見た物体の位置ベクトルを $\vec{\tilde{r}}(t)$ とすると、次の運動方程式が成り立つ。
\[
m\vec{\tilde{r}}''(t) = \vec{F}(t) - m\vec{R}''(t)
\]
</div>
<div class="proof-box">証明</div>
2つの座標系から見た物体の位置ベクトルの関係は下記の通り。
\[
 \vec{r}(t) = \vec{R}(t) + \vec{\tilde{r}}(t)
\]

両辺を2階微分すると：
\begin{aligned}
\vec{r}''(t) = \vec{R}''(t) + \vec{\tilde{r}}''(t)\ \  \cdots{(1)}
\end{aligned}

慣性系においては運動の法則が成り立つので、
\begin{aligned}
m\vec{r}''(t) = \vec{F}(t)\ \  \cdots{(2)}
\end{aligned}

(1), (2)より：
\begin{aligned}
\frac{\vec{F}(t)}{m} &= \vec{R}''(t) + \vec{\tilde{r}}''(t) \\[6pt]
\Leftrightarrow \vec{F}(t) &= m\vec{R}''(t) + m\vec{\tilde{r}}''(t) \\[6pt]
\Leftrightarrow m\vec{\tilde{r}}''(t) &= \vec{F}(t) - m\vec{R}''(t)
\ \ \ \ \text{Q.E.D}
\end{aligned}

"""
);
