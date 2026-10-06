import '../../model.dart';

final doubleMassPoint = TheoryTopic(
  title: '2質点系における諸命題',
  titleEn: 'Propositions for two-particle systems',
  isNew: false,
  imageAsset: 'assets/mindMap/forTopics/doubleMassPoint.png', // 実際の画像パス
  latexContent: r"""
<div class="theory-common-box">定義：2質点のみが登場する問題を二体問題という。</div>
<br>
<div class="theory-common-box">定義：質点1の質量が$m_1$,質点2の質量が$m_2$の時、$\mu= \displaystyle\frac {m_1 m_2}{m_1 + m_2}$を質点1,2の換算質量という。</div>
<br>
<div class="theory-common-box">定義：質点1,2の位置ベクトルをそれぞれ$\overrightarrow{r_1}(t),\overrightarrow{r_2}(t)$と置くと、質点1から見た質点2の位置ベクトルは$\overrightarrow{R}_{2 \leftarrow 1}(t) = \overrightarrow{r_2}(t) - \overrightarrow{r_1}(t)$を、質点1に対する質点2の相対位置ベクトルという。</div>
<br>
<div class="theory-common-box">定義：質点1に対する質点2の相対位置ベクトルの時間変化を記述する方程式を、質点1に対する質点2の相対運動方程式という(後述)。
</div>
<br>

<div class="theory-common-box">命題1：二体問題における二つの質点の重心は等速直線運動をする。</div>
<p><div class="proof-box">証明</div>
二体間に働く力は内部力のみで，質点1が受ける力を
$\overrightarrow{F}_{2\leftarrow1}(t)$ と書くと，運動方程式は
$$
\begin{cases}
m_1\,\overrightarrow{r}_1''(t) &= -\overrightarrow{F}_{2\leftarrow1}(t)\\[6pt]
m_2\,\overrightarrow{r}_2''(t) &= \overrightarrow{F}_{2\leftarrow1}(t) \end{cases}
$$ 
である．これらを足し合わせると内力が打ち消し合って 
$$ m_1\,\overrightarrow{r}_1''(t)+m_2\,\overrightarrow{r}_2''(t)=\vec 0. $$ 
重心位置ベクトルは定義より、
$\displaystyle \overrightarrow{R_G}(t)=\frac{m_1\overrightarrow{r}_1(t)+m_2\overrightarrow{r}_2(t)}{m_1+m_2} $なので、
上式より、
$$\begin{aligned}
&\ \ \ \ \ \ \ m_1\,\overrightarrow{r}_1''(t)+m_2\,\overrightarrow{r}_2''(t)=\vec 0 \\[6pt]
&\Leftrightarrow (m_1+m_2) \frac{m_1\,\overrightarrow{r}_1''(t)+m_2\,\overrightarrow{r}_2''(t)}{m_1+m_2}=\vec 0 \\[6pt]
&\Leftrightarrow (m_1+m_2)\,\overrightarrow{R_G}''(t)=\vec 0 \\[6pt]
&\Leftrightarrow \overrightarrow{R_G}''(t)=\vec 0, 
\end{aligned}$$

すなわち重心の加速度は零である．
これを積分すると重心速度は一定であり，
$$ \overrightarrow{R_G}'(t)=\overrightarrow{V}=\text{一定} $$
さらに一度積分して $$ \overrightarrow{R_G}(t)=\overrightarrow{V}t+\overrightarrow{R_G}(0) $$ が得られる．
よって重心は等速直線運動をする． Q.E.D</p>

<div class="theory-common-box">命題2：質点$1,2$の質量を$m_1$,$m_2$とし、$1$から$2$に及ぼす力を$\overrightarrow{F}_{2 \leftarrow 1}(t)$と書く。質点1,2の換算質量を$\mu$と表すと、二体問題において質点1に対する質点2の相対運動方程式は下記で与えられる。
$$ \displaystyle \mu \overrightarrow{R}_{2 \leftarrow 1}''(t) = \overrightarrow{F}(t)\ \ \ ;\ \ \ \overrightarrow{R}_{2 \leftarrow 1}(t):= \overrightarrow{r}_2(t)-\overrightarrow{r}_1(t)$$</div>
<p><div class="proof-box">証明</div>
$$\begin{aligned}
 \ \ \ \ \ \begin{cases}
 m_1\,\overrightarrow{r}_1''(t) &= -\overrightarrow{F}_{2 \leftarrow 1}(t)\ \ \cdots (1)\\[6pt]
 m_2\,\overrightarrow{r}_2''(t) &= \overrightarrow{F}_{2 \leftarrow 1}(t)\ \ \cdots (2)
\end{cases}\\[6pt]
\end{aligned}$$
$(2) \times m_1 - (1)\times m_2$　より、
$$\begin{aligned}
 m_1m_2\bigl(\overrightarrow{r}_2''(t)-\overrightarrow{r}_1''(t)\bigr) &= (m_1+m_2)\,\overrightarrow{F}_{2\leftarrow1}(t)\\[6pt]
\end{aligned}$$
ここで換算質量の定義より$\displaystyle \ \mu = \frac{m_1m_2}{m_1+m_2}$<br>
質点1から見た質点2の相対位置ベクトルを
$\displaystyle \overrightarrow{R}_{2 \leftarrow 1}(t) = \overrightarrow{r}_2(t)-\overrightarrow{r}_1(t)$と表すと、下式を得る。
$$ \mu\,\overrightarrow{R}_{2 \leftarrow 1}''(t) = \overrightarrow{F}_{2\leftarrow1}(t)$$
　　Q.E.D</p>
<div class="theory-common-box">命題3：二物体の位置ベクトルを$\overrightarrow{r_1}(t),\overrightarrow{r_2}(t)$とすると、
二物体の重心の位置ベクトル$\overrightarrow{R_G}(t)$と質点1から見た質点2の相対位置ベクトル$\overrightarrow{R}_{2 \leftarrow 1}(t)$が与えられた時、2物体の位置ベクトルは
$$\begin{aligned}
\begin{cases}
\overrightarrow{r_1}(t) = \displaystyle \overrightarrow{R_G}(t) - \frac{m_2}{m_1 + m_2} \overrightarrow{R}_{2 \leftarrow 1}(t)\\[6pt]
\overrightarrow{r_2}(t) =  \displaystyle \overrightarrow{R_G}(t) + \frac{m_1}{m_1 + m_2} \overrightarrow{R}_{2 \leftarrow 1}(t)
\end{cases}
\end{aligned}$$
で得ることができる。</div>
<p><div class="proof-box">証明</div>
与えられた量として重心位置と相対位置を
$$\begin{aligned}
\begin{cases}
\overrightarrow{R_G}(t)=\displaystyle \frac{m_1\overrightarrow{r}_1(t)+m_2\overrightarrow{r}_2(t)}{m_1+m_2}\\[6pt]
\overrightarrow{R}_{2\leftarrow1}(t)=\overrightarrow{r}_2(t)-\overrightarrow{r}_1(t)
\end{cases}
\end{aligned}$$
とおく。
相対位置の式から $\overrightarrow{r}_2(t)=\overrightarrow{r}_1(t)+\overrightarrow{R}_{2\leftarrow1}(t)$ を得るので，これを重心の式に代入すると
$$\begin{aligned}
\overrightarrow{R_G}(t)&=\frac{m_1\overrightarrow{r}_1(t)+m_2\bigl(\overrightarrow{r}_1(t)+\overrightarrow{R}_{2\leftarrow1}(t)\bigr)}{m_1+m_2}\\[6pt]
&=\overrightarrow{r}_1(t)+\frac{m_2}{m_1+m_2}\,\overrightarrow{R}_{2\leftarrow1}(t)
\end{aligned}$$

これを整理して
$$\begin{aligned}
\overrightarrow{r}_1(t)=\overrightarrow{R_G}(t)-\frac{m_2}{m_1+m_2}\,\overrightarrow{R}_{2\leftarrow1}(t)
\end{aligned}$$
同様に $\overrightarrow{r}_2=\overrightarrow{r}_1+\overrightarrow{R}_{2\leftarrow1}$
に代入して
$$\begin{aligned}
\overrightarrow{r}_2(t)&=\overrightarrow{R_G}(t)-\frac{m_2}{m_1+m_2}\,\overrightarrow{R}_{2\leftarrow1}(t)+\overrightarrow{R}_{2\leftarrow1}(t) \\[6pt]
 &=\overrightarrow{R_G}(t)+\frac{m_1}{m_1+m_2}\,\overrightarrow{R}_{2\leftarrow1}(t)
\end{aligned}$$
 が得られる．よって所望の式が導かれる。． Q.E.D</p>

<div class="theory-common-box">命題4：二体の運動方程式
$$\begin{aligned}
\begin{cases}
m_1\,\overrightarrow{r}_1''(t) = -\overrightarrow{F}_{2\leftarrow1}(t),\\[6pt]
m_2\,\overrightarrow{r}_2''(t) = \ \overrightarrow{F}_{2\leftarrow1}(t),
\end{cases}
\end{aligned}$$
は，重心方程式と相対運動方程式の組
$$\begin{aligned}
\begin{cases}
(m_1+m_2)\,\overrightarrow{R_G}''(t)=\vec{0}\\[6pt]
\mu\,\overrightarrow{R}_{2\leftarrow1}''(t)=\overrightarrow{F}_{2\leftarrow1}(t)
\end{cases}
\end{aligned}$$
の組と同値である（すなわち互いに導ける）．</div>

<p><div class="proof-box">証明</div>
2つの運動方程式から、重心運動方程式と相対運動方程式を導くことは命題1,命題2で行っているので、逆を示せばよい。<br>
即ち、重心運動方程式と相対運動方程式から、2つの質点についての運動方程式が導ける事を確認する。<br>
命題3より、
$$\begin{aligned}
\begin{cases}
\overrightarrow{r}_1(t) = \overrightarrow{R_G}(t) - \dfrac{m_2}{m_1+m_2}\,\overrightarrow{R}_{2\leftarrow1}(t)\\[6pt]
\overrightarrow{r}_2(t) = \overrightarrow{R_G}(t) + \dfrac{m_1}{m_1+m_2}\,\overrightarrow{R}_{2\leftarrow1}(t)
\end{cases}
\end{aligned}$$
が成り立つ。両辺を2回微分すると、加速度について
$$\begin{aligned}
\begin{cases}
\overrightarrow{r}_1''(t) = \overrightarrow{R_G}''(t) - \dfrac{m_2}{m_1+m_2}\,\overrightarrow{R}_{2\leftarrow1}''(t)\\[6pt]
\overrightarrow{r}_2''(t) = \overrightarrow{R_G}''(t) + \dfrac{m_1}{m_1+m_2}\,\overrightarrow{R}_{2\leftarrow1}''(t)
\end{cases}
\end{aligned}$$
を得る。それぞれの式に $m_1, m_2$ を掛けて整理すると
$$\begin{aligned}
\begin{cases}
m_1\overrightarrow{r}_1''(t) = m_1\overrightarrow{R_G}''(t) - \dfrac{m_1m_2}{m_1+m_2}\,\overrightarrow{R}_{2\leftarrow1}''(t),\\[6pt]
m_2\overrightarrow{r}_2''(t) = m_2\overrightarrow{R_G}''(t) + \dfrac{m_1m_2}{m_1+m_2}\,\overrightarrow{R}_{2\leftarrow1}''(t).
\end{cases}
\end{aligned}$$
命題1より $\overrightarrow{R_G}''(t)=\overrightarrow{0}$，換算質量の定義より $\dfrac{m_1m_2}{m_1+m_2}=\mu$ を代入し，さらに相対方程式 $\mu\,\overrightarrow{R}_{2\leftarrow1}''(t)=\overrightarrow{F}_{2\leftarrow1}(t)$ を用いると
$$\begin{aligned}
\begin{cases}
m_1\overrightarrow{r}_1''(t) = -\overrightarrow{F}_{2\leftarrow1}(t),\\[6pt]
m_2\overrightarrow{r}_2''(t) = \ \overrightarrow{F}_{2\leftarrow1}(t),
\end{cases}
\end{aligned}$$
すなわち元の二つの運動方程式が得られる。　 Q.E.D</p>
""",
  latexContentEn: r"""
<div class="theory-common-box">Definition: A problem involving only two particles is called the two-body problem.</div>
<br>
<div class="theory-common-box">Definition: For masses $m_1$ and $m_2$, $\mu= \displaystyle\frac {m_1 m_2}{m_1 + m_2}$ is the reduced mass of particles 1 and 2.</div>
<br>
<div class="theory-common-box">Definition: With position vectors $\overrightarrow{r_1}(t),\overrightarrow{r_2}(t)$, the relative position of particle 2 as seen from particle 1 is $\overrightarrow{R}_{2 \leftarrow 1}(t) = \overrightarrow{r_2}(t) - \overrightarrow{r_1}(t)$.</div>
<br>
<div class="theory-common-box">Definition: The equation describing the time evolution of that relative position is the relative equation of motion of particle 2 with respect to particle 1 (see below).
</div>
<br>

<div class="theory-common-box">Proposition 1: In the two-body problem the center of mass of the two particles moves in uniform straight-line motion.</div>
<p><div class="proof-box">Proof</div>
The only forces between the bodies are internal. Writing the force on particle 1 as
$\overrightarrow{F}_{2\leftarrow1}(t)$, the equations of motion are
$$
\begin{cases}
m_1\,\overrightarrow{r}_1''(t) &= -\overrightarrow{F}_{2\leftarrow1}(t)\\[6pt]
m_2\,\overrightarrow{r}_2''(t) &= \overrightarrow{F}_{2\leftarrow1}(t) \end{cases}
$$ 
. Adding them cancels the internal forces:
$$ m_1\,\overrightarrow{r}_1''(t)+m_2\,\overrightarrow{r}_2''(t)=\vec 0. $$ 
By definition
$\displaystyle \overrightarrow{R_G}(t)=\frac{m_1\overrightarrow{r}_1(t)+m_2\overrightarrow{r}_2(t)}{m_1+m_2} $, so
$$\begin{aligned}
&\ \ \ \ \ \ \ m_1\,\overrightarrow{r}_1''(t)+m_2\,\overrightarrow{r}_2''(t)=\vec 0 \\[6pt]
&\Leftrightarrow (m_1+m_2) \frac{m_1\,\overrightarrow{r}_1''(t)+m_2\,\overrightarrow{r}_2''(t)}{m_1+m_2}=\vec 0 \\[6pt]
&\Leftrightarrow (m_1+m_2)\,\overrightarrow{R_G}''(t)=\vec 0 \\[6pt]
&\Leftrightarrow \overrightarrow{R_G}''(t)=\vec 0, 
\end{aligned}$$

i.e. the center-of-mass acceleration vanishes.
Integrating, the center-of-mass velocity is constant,
$$ \overrightarrow{R_G}'(t)=\overrightarrow{V}=\text{constant} $$
and integrating again $$ \overrightarrow{R_G}(t)=\overrightarrow{V}t+\overrightarrow{R_G}(0) $$.
Hence the center of mass moves uniformly in a straight line. Q.E.D</p>

<div class="theory-common-box">Proposition 2: Let the masses be $m_1$,$m_2$ and the force from 1 on 2 be $\overrightarrow{F}_{2 \leftarrow 1}(t)$. With reduced mass $\mu$, the relative equation of motion of 2 with respect to 1 is
$$ \displaystyle \mu \overrightarrow{R}_{2 \leftarrow 1}''(t) = \overrightarrow{F}(t)\ \ \ ;\ \ \ \overrightarrow{R}_{2 \leftarrow 1}(t):= \overrightarrow{r}_2(t)-\overrightarrow{r}_1(t)$$</div>
<p><div class="proof-box">Proof</div>
$$\begin{aligned}
 \ \ \ \ \ \begin{cases}
 m_1\,\overrightarrow{r}_1''(t) &= -\overrightarrow{F}_{2 \leftarrow 1}(t)\ \ \cdots (1)\\[6pt]
 m_2\,\overrightarrow{r}_2''(t) &= \overrightarrow{F}_{2 \leftarrow 1}(t)\ \ \cdots (2)
\end{cases}\\[6pt]
\end{aligned}$$
From $(2) \times m_1 - (1)\times m_2$,
$$\begin{aligned}
 m_1m_2\bigl(\overrightarrow{r}_2''(t)-\overrightarrow{r}_1''(t)\bigr) &= (m_1+m_2)\,\overrightarrow{F}_{2\leftarrow1}(t)\\[6pt]
\end{aligned}$$
With $\displaystyle \ \mu = \frac{m_1m_2}{m_1+m_2}$ and
$\displaystyle \overrightarrow{R}_{2 \leftarrow 1}(t) = \overrightarrow{r}_2(t)-\overrightarrow{r}_1(t)$,
$$ \mu\,\overrightarrow{R}_{2 \leftarrow 1}''(t) = \overrightarrow{F}_{2\leftarrow1}(t)$$
　　Q.E.D</p>
<div class="theory-common-box">Proposition 3: Given the center-of-mass position $\overrightarrow{R_G}(t)$ and the relative position $\overrightarrow{R}_{2 \leftarrow 1}(t)$, the individual positions are
$$\begin{aligned}
\begin{cases}
\overrightarrow{r_1}(t) = \displaystyle \overrightarrow{R_G}(t) - \frac{m_2}{m_1 + m_2} \overrightarrow{R}_{2 \leftarrow 1}(t)\\[6pt]
\overrightarrow{r_2}(t) =  \displaystyle \overrightarrow{R_G}(t) + \frac{m_1}{m_1 + m_2} \overrightarrow{R}_{2 \leftarrow 1}(t)
\end{cases}
\end{aligned}$$
.</div>
<p><div class="proof-box">Proof</div>
$$\begin{aligned}
\begin{cases}
\overrightarrow{R_G}(t)=\displaystyle \frac{m_1\overrightarrow{r}_1(t)+m_2\overrightarrow{r}_2(t)}{m_1+m_2}\\[6pt]
\overrightarrow{R}_{2\leftarrow1}(t)=\overrightarrow{r}_2(t)-\overrightarrow{r}_1(t)
\end{cases}
\end{aligned}$$
. From the relative-position equation $\overrightarrow{r}_2(t)=\overrightarrow{r}_1(t)+\overrightarrow{R}_{2\leftarrow1}(t)$; substitute into the center-of-mass equation:
$$\begin{aligned}
\overrightarrow{R_G}(t)&=\frac{m_1\overrightarrow{r}_1(t)+m_2\bigl(\overrightarrow{r}_1(t)+\overrightarrow{R}_{2\leftarrow1}(t)\bigr)}{m_1+m_2}\\[6pt]
&=\overrightarrow{r}_1(t)+\frac{m_2}{m_1+m_2}\,\overrightarrow{R}_{2\leftarrow1}(t)
\end{aligned}$$

Rearranging,
$$\begin{aligned}
\overrightarrow{r}_1(t)=\overrightarrow{R_G}(t)-\frac{m_2}{m_1+m_2}\,\overrightarrow{R}_{2\leftarrow1}(t)
\end{aligned}$$
. Likewise, substituting into $\overrightarrow{r}_2=\overrightarrow{r}_1+\overrightarrow{R}_{2\leftarrow1}$,
$$\begin{aligned}
\overrightarrow{r}_2(t)&=\overrightarrow{R_G}(t)-\frac{m_2}{m_1+m_2}\,\overrightarrow{R}_{2\leftarrow1}(t)+\overrightarrow{R}_{2\leftarrow1}(t) \\[6pt]
 &=\overrightarrow{R_G}(t)+\frac{m_1}{m_1+m_2}\,\overrightarrow{R}_{2\leftarrow1}(t)
\end{aligned}$$
. Q.E.D</p>

<div class="theory-common-box">Proposition 4: The two-body equations of motion
$$\begin{aligned}
\begin{cases}
m_1\,\overrightarrow{r}_1''(t) = -\overrightarrow{F}_{2\leftarrow1}(t),\\[6pt]
m_2\,\overrightarrow{r}_2''(t) = \ \overrightarrow{F}_{2\leftarrow1}(t),
\end{cases}
\end{aligned}$$
are equivalent to the pair of center-of-mass and relative equations
$$\begin{aligned}
\begin{cases}
(m_1+m_2)\,\overrightarrow{R_G}''(t)=\vec{0}\\[6pt]
\mu\,\overrightarrow{R}_{2\leftarrow1}''(t)=\overrightarrow{F}_{2\leftarrow1}(t)
\end{cases}
\end{aligned}$$
(each set implies the other).</div>

<p><div class="proof-box">Proof</div>
Propositions 1 and 2 derive the CM and relative equations from the two equations of motion; it remains to show the converse.<br>
From Proposition 3,
$$\begin{aligned}
\begin{cases}
\overrightarrow{r}_1(t) = \overrightarrow{R_G}(t) - \frac{m_2}{m_1+m_2}\,\overrightarrow{R}_{2\leftarrow1}(t)\\[6pt]
\overrightarrow{r}_2(t) = \overrightarrow{R_G}(t) + \frac{m_1}{m_1+m_2}\,\overrightarrow{R}_{2\leftarrow1}(t)
\end{cases}
\end{aligned}$$
. Differentiating twice,
$$\begin{aligned}
\begin{cases}
\overrightarrow{r}_1''(t) = \overrightarrow{R_G}''(t) - \frac{m_2}{m_1+m_2}\,\overrightarrow{R}_{2\leftarrow1}''(t)\\[6pt]
\overrightarrow{r}_2''(t) = \overrightarrow{R_G}''(t) + \frac{m_1}{m_1+m_2}\,\overrightarrow{R}_{2\leftarrow1}''(t)
\end{cases}
\end{aligned}$$
. Multiplying by $m_1, m_2$,
$$\begin{aligned}
\begin{cases}
m_1\overrightarrow{r}_1''(t) = m_1\overrightarrow{R_G}''(t) - \frac{m_1m_2}{m_1+m_2}\,\overrightarrow{R}_{2\leftarrow1}''(t),\\[6pt]
m_2\overrightarrow{r}_2''(t) = m_2\overrightarrow{R_G}''(t) + \frac{m_1m_2}{m_1+m_2}\,\overrightarrow{R}_{2\leftarrow1}''(t).
\end{cases}
\end{aligned}$$
Using $\overrightarrow{R_G}''(t)=\overrightarrow{0}$, $\frac{m_1m_2}{m_1+m_2}=\mu$, and $\mu\,\overrightarrow{R}_{2\leftarrow1}''(t)=\overrightarrow{F}_{2\leftarrow1}(t)$,
$$\begin{aligned}
\begin{cases}
m_1\overrightarrow{r}_1''(t) = -\overrightarrow{F}_{2\leftarrow1}(t),\\[6pt]
m_2\overrightarrow{r}_2''(t) = \ \overrightarrow{F}_{2\leftarrow1}(t),
\end{cases}
\end{aligned}$$
recovering the original equations.　 Q.E.D</p>
"""
);
