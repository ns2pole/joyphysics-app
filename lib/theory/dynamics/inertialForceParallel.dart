import '../../model.dart';

final inertialForceParallel = TheoryTopic(
  title: '慣性系に対し加速運動する座標系から見た時の慣性力',
  titleEn: 'Inertial force in a frame accelerating relative to an inertial frame',
  isNew: false,
  imageAsset: 'assets/mindMap/forTopics/inertialForceParallel.png', // 実際の画像パス
  latexContent: r"""
<div class="theory-common-box">慣性系の原点に対して非慣性系の原点が $\vec{R}(t)$ で運動しているとする。この時、非慣性系から見た物体の位置ベクトルを $\vec{\tilde{r}}(t)$ とすると、次の運動方程式が成り立つ。
$$
m\vec{\tilde{r}}''(t) = \vec{F}(t) - m\vec{R}''(t)
$$
</div>
<div class="proof-box">証明</div>
2つの座標系から見た物体の位置ベクトルの関係は下記の通り。
$$
 \vec{r}(t) = \vec{R}(t) + \vec{\tilde{r}}(t)
$$

両辺を2階微分すると：
$$\begin{aligned}
\vec{r}''(t) = \vec{R}''(t) + \vec{\tilde{r}}''(t)\ \  \cdots{(1)}
\end{aligned}$$

慣性系においては運動の法則が成り立つので、
$$\begin{aligned}
m\vec{r}''(t) = \vec{F}(t)\ \  \cdots{(2)}
\end{aligned}$$

(1), (2)より：
$$\begin{aligned}
\frac{\vec{F}(t)}{m} &= \vec{R}''(t) + \vec{\tilde{r}}''(t) \\[6pt]
\Leftrightarrow \vec{F}(t) &= m\vec{R}''(t) + m\vec{\tilde{r}}''(t) \\[6pt]
\Leftrightarrow m\vec{\tilde{r}}''(t) &= \vec{F}(t) - m\vec{R}''(t)
\ \ \ \ \text{Q.E.D}
\end{aligned}$$

""",
  latexContentEn: r"""
<div class="theory-common-box">Suppose the origin of a non-inertial frame moves as $\vec{R}(t)$ relative to the origin of an inertial frame. If the position vector of a body as seen from the non-inertial frame is $\vec{\tilde{r}}(t)$, then the following equation of motion holds.
$$
m\vec{\tilde{r}}''(t) = \vec{F}(t) - m\vec{R}''(t)
$$
</div>
<div class="proof-box">Proof</div>
The relation between the position vectors in the two frames is
$$
 \vec{r}(t) = \vec{R}(t) + \vec{\tilde{r}}(t)
$$

Differentiating twice with respect to time:
$$\begin{aligned}
\vec{r}''(t) = \vec{R}''(t) + \vec{\tilde{r}}''(t)\ \  \cdots{(1)}
\end{aligned}$$

In an inertial frame the law of motion holds,
$$\begin{aligned}
m\vec{r}''(t) = \vec{F}(t)\ \  \cdots{(2)}
\end{aligned}$$

From (1) and (2):
$$\begin{aligned}
\frac{\vec{F}(t)}{m} &= \vec{R}''(t) + \vec{\tilde{r}}''(t) \\[6pt]
\Leftrightarrow \vec{F}(t) &= m\vec{R}''(t) + m\vec{\tilde{r}}''(t) \\[6pt]
\Leftrightarrow m\vec{\tilde{r}}''(t) &= \vec{F}(t) - m\vec{R}''(t)
\ \ \ \ \text{Q.E.D}
\end{aligned}$$

"""
);
