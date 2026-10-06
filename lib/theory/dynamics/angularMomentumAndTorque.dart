import '../../model.dart';

final angularMomentumAndTorque = TheoryTopic(
  title: '質点の角運動量ベクトルと力のモーメント',
  titleEn: 'Angular momentum vector and torque of a particle',
  isNew: false,
  imageAsset: 'assets/mindMap/forTopics/angularMomentumAndTorque.png', // 実際の画像パス
  latexContent: r"""
<div class="theory-common-box">定義(質点の原点回りの角運動量ベクトル)</div>
<p>
質点の原点回りの角運動量ベクトル$\vec L$をクロス積$\times$を用いて、下記の通り定義する。
$$\overrightarrow{L} = \overrightarrow{r}(t) \times \overrightarrow{p}(t)$$
</p>
<div class="theory-common-box">定義（力のモーメント）</div>
<p>
位置ベクトルが$\overrightarrow{r}(t)$の質点に力$\overrightarrow{F}(t)$が働いているとき、$\overrightarrow{r}(t) \times \overrightarrow{F}(t)$を原点回りの力のモーメントという。
</p>
<div class="theory-common-box">命題1：質点に力のモーメント$\overrightarrow{M} = \displaystyle  \overrightarrow{r}(t) \times \overrightarrow{F}(t)$ が作用しているとき、質点の原点回りの角運動量ベクトルを$\overrightarrow{L}(t)$とすると、
$\overrightarrow{L}(t)' = \overrightarrow{M}(t)$が成り立つ。</div>
<p><div class="proof-box">証明</div>
質点の原点回りの角運動量の定義$\displaystyle \overrightarrow{L}(t)=\overrightarrow{r}(t)\times\overrightarrow{p}(t)$
の両辺を微分して命題を示す。
$$\begin{aligned}
\overrightarrow{L}(t)'
&= \bigl(\overrightarrow{r}(t)\times\overrightarrow{p}(t)\bigr)'\\[6pt]
&= \overrightarrow{r}(t)'\times\overrightarrow{p}(t)
   + \overrightarrow{r}(t)\times\overrightarrow{p}(t)'
\end{aligned}$$
ところで右辺第1項について、運動量の定義より、$\overrightarrow{p}=m\overrightarrow{r}'$は速度ベクトル$\overrightarrow {r}(t)' $と平行であるから、クロス積の性質より
$\displaystyle \overrightarrow{r}(t)' \times \overrightarrow{p}(t) = \vec 0$
よって、
$$\begin{aligned}
\overrightarrow{L}(t)'
&= \overrightarrow{r}(t)'\times\overrightarrow{p}(t)
   + \overrightarrow{r}(t)\times\overrightarrow{p}(t)'\\[6pt]
&= \overrightarrow{r}(t)\times\overrightarrow{p}(t)'
\end{aligned}$$

ここで、ニュートンの第2法則 $\overrightarrow{p}(t)'=\overrightarrow{F}(t)$ を用いると
$$
{\overrightarrow{L}}(t)'=\overrightarrow{r}(t)\times\overrightarrow{F}(t)=\overrightarrow{M}(t)
$$
  Q.E.D
</p>
<div class="theory-common-box">定義（中心力）</div>
力の大きさが質点と原点との距離の関数でかつ、力の方向が原点と物体を結ぶ線に沿っている力。即ち、下記のように表される力を指す。
$$\overrightarrow{F}= F(|\overrightarrow{r}|) \frac{\overrightarrow{r}}{|\overrightarrow{r}|}$$
<div class="theory-common-box">例（中心力）</div>
万有引力は、$\displaystyle \overrightarrow{F} = \frac{GMm}{r^2}\frac{\overrightarrow{r}}{r}$と表されるので、中心力。
<div class="theory-common-box">定義（向心力）</div>
<p>
等速円運動をする物体にはたらく,円の中心に向かう向きの力を向心力という。
</p>
<div class="theory-common-box">命題2：原点を中心力の中心に取ると、中心力を受ける質点の原点回りの角運動量ベクトルは保存量である。</div>
<p>
<div class="proof-box">証明</div>
中心力の定義より、力のモーメントは下記となる。
$$
\overrightarrow{M}(t) = \overrightarrow{r}(t) \times F(|\overrightarrow{r}|) \frac{\overrightarrow{r}}{|\overrightarrow{r}|}
$$
今$\overrightarrow{r}(t)$と中心力$F(|\overrightarrow{r}|) \frac{\overrightarrow{r}}{|\overrightarrow{r}|}$
は平行なので、クロス積の性質より、$\displaystyle \overrightarrow{r}(t) \times F(|\overrightarrow{r}|) \frac{\overrightarrow{r}}{|\overrightarrow{r}|}=\vec 0$<br>
よって、 $\overrightarrow{M}(t) = \vec 0\ $ここで、命題1より
$\displaystyle \overrightarrow{L}(t)'=\overrightarrow{M}(t)=\vec{0}$<br>
従って、中心力を受ける質点の原点回りの角運動量ベクトル$\overrightarrow{L}(t)$は保存する。
</p>
    Q.E.D
""",
  latexContentEn: r"""
<div class="theory-common-box">Definition (angular momentum of a particle about the origin)</div>
<p>
Define the angular momentum $\vec L$ of a particle about the origin using the cross product $\times$ by
$$\overrightarrow{L} = \overrightarrow{r}(t) \times \overrightarrow{p}(t)$$
.
</p>
<div class="theory-common-box">Definition (moment of force / torque)</div>
<p>
When a force $\overrightarrow{F}(t)$ acts on a particle at position $\overrightarrow{r}(t)$, $\overrightarrow{r}(t) \times \overrightarrow{F}(t)$ is the moment of the force about the origin.
</p>
<div class="theory-common-box">Proposition 1: When a torque $\overrightarrow{M} = \displaystyle  \overrightarrow{r}(t) \times \overrightarrow{F}(t)$ acts on a particle, with angular momentum $\overrightarrow{L}(t)$ about the origin,
$\overrightarrow{L}(t)' = \overrightarrow{M}(t)$ holds.</div>
<p><div class="proof-box">Proof</div>
Differentiate the definition $\displaystyle \overrightarrow{L}(t)=\overrightarrow{r}(t)\times\overrightarrow{p}(t)$.
$$\begin{aligned}
\overrightarrow{L}(t)'
&= \bigl(\overrightarrow{r}(t)\times\overrightarrow{p}(t)\bigr)'\\[6pt]
&= \overrightarrow{r}(t)'\times\overrightarrow{p}(t)
   + \overrightarrow{r}(t)\times\overrightarrow{p}(t)'
\end{aligned}$$
For the first term on the right, $\overrightarrow{p}=m\overrightarrow{r}'$ is parallel to $\overrightarrow {r}(t)' $, so by properties of the cross product
$\displaystyle \overrightarrow{r}(t)' \times \overrightarrow{p}(t) = \vec 0$
. Hence
$$\begin{aligned}
\overrightarrow{L}(t)'
&= \overrightarrow{r}(t)'\times\overrightarrow{p}(t)
   + \overrightarrow{r}(t)\times\overrightarrow{p}(t)'\\[6pt]
&= \overrightarrow{r}(t)\times\overrightarrow{p}(t)'
\end{aligned}$$

Using Newton's second law $\overrightarrow{p}(t)'=\overrightarrow{F}(t)$,
$$
{\overrightarrow{L}}(t)'=\overrightarrow{r}(t)\times\overrightarrow{F}(t)=\overrightarrow{M}(t)
$$
  Q.E.D
</p>
<div class="theory-common-box">Definition (central force)</div>
A force whose magnitude is a function of the distance from the origin and whose direction lies along the line from the origin to the body; that is, a force of the form
$$\overrightarrow{F}= F(|\overrightarrow{r}|) \frac{\overrightarrow{r}}{|\overrightarrow{r}|}$$
<div class="theory-common-box">Example (central force)</div>
Universal gravitation $\displaystyle \overrightarrow{F} = \frac{GMm}{r^2}\frac{\overrightarrow{r}}{r}$ is a central force.
<div class="theory-common-box">Definition (centripetal force)</div>
<p>
The force toward the center of the circle that acts on a body in uniform circular motion is called the centripetal force.
</p>
<div class="theory-common-box">Proposition 2: Taking the origin as the center of a central force, the angular momentum of a particle about the origin is conserved under a central force.</div>
<p>
<div class="proof-box">Proof</div>
By definition of a central force, the torque is
$$
\overrightarrow{M}(t) = \overrightarrow{r}(t) \times F(|\overrightarrow{r}|) \frac{\overrightarrow{r}}{|\overrightarrow{r}|}
$$
. Since $\overrightarrow{r}(t)$ and $F(|\overrightarrow{r}|) \frac{\overrightarrow{r}}{|\overrightarrow{r}|}$
are parallel, $\displaystyle \overrightarrow{r}(t) \times F(|\overrightarrow{r}|) \frac{\overrightarrow{r}}{|\overrightarrow{r}|}=\vec 0$<br>
. Hence $\overrightarrow{M}(t) = \vec 0\ $. By Proposition 1,
$\displaystyle \overrightarrow{L}(t)'=\overrightarrow{M}(t)=\vec{0}$<br>
. Therefore the angular momentum $\overrightarrow{L}(t)$ about the origin is conserved.
</p>
    Q.E.D
"""
);
// 特に、重心を原点に取る体固定系では$$\begin{aligned}  \overrightarrow{L} = I\,\overrightarrow{\omega}\end{aligned}$$と表せる。
