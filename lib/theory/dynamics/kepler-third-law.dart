import '../../model.dart';

final keplerThirdLaw= TheoryTopic(
  title: 'ケプラー第三法則',
  titleEn: 'Kepler\'s third law',
  isNew: false,
  imageAsset: 'assets/mindMap/forTopics/keplerThirdLaw.png', // 実際の画像パス
  latexContent: r"""
  <div class="theory-common-box">
記号の定義
</div>

<div style="text-align:center; margin:1em 0;">
    <img src="assets/dynamicsTheory/kepler-third1.png"
          style="max-width:100%; height:auto;" />
  </div>
<ul>
  <li>$G$ : 万有引力定数</li>
  <li>$M$ : 中心星（例えば太陽）の質量</li>
  <li>$m$ : 惑星の質量（運動方程式の途中で消えるが，便宜上導入する）</li>
  <li>$a$ : 近日点距離（中心から惑星が最も近づく距離）</li>
  <li>$b$ : 遠日点距離（中心から惑星が最も遠くなる距離）</li>
  <li>$l$ : 楕円軌道の長半径（半長軸）</li>
  <li>$m$ : 楕円軌道の短半径（半短軸）</li>
  <li>$S$ : 楕円の面積</li>
  <li>$v_a$ : 近日点（距離 $a$）における惑星の速さ</li>
  <li>$v_b$ : 遠日点（距離 $b$）における惑星の速さ</li>
  <li>$V_s$ : 面積速度（単位時間あたりに掃かれる面積）</li>
  <li>$T$ : 公転周期（軌道を一周するのに要する時間）</li>
</ul>

  
<div class="theory-common-box">
補題1：ケプラー第1法則より、惑星は中心星を焦点として楕円軌道をする。 
今、近日点距離 $a$, 遠日点距離 $b$ を用いて、楕円の面積$S$ は下記のように表される。
$$
S = \pi\frac{a+b}{2}\sqrt{ab}
$$
</div>
<div class="proof-box">証明</div>
軌道長半径を$l$, 軌道短半径を$m$とすると、
楕円の面積$S$は$\pi l m$である。<br>
ここで図より、$l = \displaystyle \frac {a+b}{2}$<br>
$m\ $は三平方の定理より、$l ^2 =  (l - a) ^2 + m ^2$を満たすので、これを計算すると、
$$\begin{aligned}
\ \ \ l ^2 &= (l - a) ^2 + m ^2 \\[6pt]
\Leftrightarrow \Bigl(\frac{a+b}{2}\Bigr)^2 &= \Bigl(\frac{a+b}{2} - a\Bigr)^2 + m ^2 \\[6pt]
\Leftrightarrow \Bigl(\frac{a+b}{2}\Bigr)^2 &= \Bigl(\frac{a-b}{2}\Bigr)^2 + m ^2 \\[6pt]
\Leftrightarrow \frac{a^2+2ab+b^2}{4} &= \frac{a^2-2ab+b^2}{4} + m ^2 \\[6pt]
\Leftrightarrow ab &=  m ^2 \\[6pt]
\Leftrightarrow m &=  \sqrt{ab}
\end{aligned}$$
よって、
$$
S = \pi l m = \pi\frac{a+b}{2}\sqrt{ab}
$$
<div style="text-align:center; margin:1em 0;">
    <img src="assets/dynamicsTheory/kepler-third2.png"
          style="max-width:100%; height:auto;" />
  </div>
　⬜︎
<div class="theory-common-box">
補題2：近日点距離 $a$, 遠日点距離 $b$を用いて、面積速度$V_s$は下記のように表される。
$$ \displaystyle V_s = \sqrt{GM\frac{ab}{2(a+b)}}$$
</div>
<div class="proof-box">証明</div>
近日点における速さを$v_a$,遠日点における速さを$v_b$と表すと、
エネルギー保存則およびケプラー第2法則より次の関係式が成立する。
$$
\begin{cases}
\displaystyle \frac{1}{2}mv_a^2 - \frac{GMm}{a} = \frac{1}{2}mv_b^2 - \frac{GMm}{b} \\
\displaystyle \frac{1}{2}av_a = \frac{1}{2}bv_b
\end{cases}
$$

$v_a, v_b$ を $a, b$ で表すと、
$$
\frac{1}{2}m\frac{b^2}{a^2}v_b^2 - \frac{GMm}{a}
= \frac{1}{2}mv_b^2 - \frac{GMm}{b}
$$
$$
\Leftrightarrow \frac{1}{2}m\Bigl(\frac{b^2}{a^2}-1\Bigr)v_b^2
= \frac{GMm}{a}- \frac{GMm}{b}
$$
$$
\Leftrightarrow \frac{1}{2}m\Bigl(\frac{b^2-a^2}{a^2}\Bigr)v_b^2
= \frac{GMm(b-a)}{ab}
$$
$$
\Leftrightarrow \frac{1}{2}m(a+b)v_b^2
= GMm\frac{a}{b}
$$
$$
\Leftrightarrow v_b^2 = 2GM\frac{a}{b(a+b)}
$$
$$
\Leftrightarrow v_b = \sqrt{2GM\frac{a}{b(a+b)}}\ \ (\ \because v_b > 0\ )
$$

同様にして
$$
v_a = \pm\sqrt{2GM\frac{b}{a(a+b)}}\ \  (\ \because v_a > 0\ )
$$
面積速度$V_s$は、$\displaystyle \frac 1 2 v_a a \sin 90^{\circ}$(または$\displaystyle \frac 1 2 v_b b \sin 90^{\circ}$)なのでこれを計算して、

$$
V_s = \frac 1 2 v_a a = \frac 1 2 v_b b = \sqrt{GM\frac{ab}{2(a+b)}}
$$　⬜︎

<div class="theory-common-box">
定理（ケプラー第3法則）：万有引力定数 $G$, 惑星の楕円軌道長半径 $l$, 公転周期 $T$, 中心星質量 $M$, , について、下記の式が成り立つ。
$$\frac{T^2}{l^3}=\frac{4\pi^2}{GM}$$
</div>
<div class="proof-box">証明</div>
公転周期は、楕円の面積$S$を面積速度$V_s$で割った値なので、補題1と補題2より、楕円の面積と面積速度を代入して計算する。
$$\begin{aligned}
\displaystyle T &=\frac{S}{V_s}\\[6pt]
\displaystyle &= \frac{\pi\frac{a+b}{2}\sqrt{ab}}{\sqrt{GM\frac{ab}{2(a+b)}}}\\[6pt]
\displaystyle &= \frac{\pi (a+b)}{\sqrt{\tfrac{2GM}{(a+b)}}}\\[6pt]
\displaystyle &= \frac{\pi (a+b)^{3/2}}{\sqrt{2GM}}
\end{aligned}$$

よって
$$\begin{aligned}
\ \ \ \ \frac{T^2}{(a+b)^3} &= \frac{\pi^2}{2GM}\\[6pt]
\Leftrightarrow \frac{T^2}{\Bigl(\tfrac{a+b}{2}\Bigr)^3} &= \frac{4\pi^2}{GM}\\[6pt]
\Leftrightarrow \frac{T^2}{l^3} &= \frac{4\pi^2}{GM}
\end{aligned}$$
Q.E.D.
""",
  latexContentEn: r"""
  <div class="theory-common-box">
Definition of symbols
</div>

<div style="text-align:center; margin:1em 0;">
    <img src="assets/dynamicsTheory/kepler-third1.png"
          style="max-width:100%; height:auto;" />
  </div>
<ul>
  <li>$G$ : gravitational constant</li>
  <li>$M$ : mass of the central star (e.g. the Sun)</li>
  <li>$m$ : mass of the planet (cancels in the equation of motion, but introduced for convenience)</li>
  <li>$a$ : perihelion distance (closest approach to the center)</li>
  <li>$b$ : aphelion distance (farthest distance from the center)</li>
  <li>$l$ : semi-major axis of the elliptical orbit</li>
  <li>$m$ : semi-minor axis of the elliptical orbit</li>
  <li>$S$ : area of the ellipse</li>
  <li>$v_a$ : speed of the planet at perihelion (distance $a$)</li>
  <li>$v_b$ : speed of the planet at aphelion (distance $b$)</li>
  <li>$V_s$ : areal velocity (area swept per unit time)</li>
  <li>$T$ : orbital period (time to complete one revolution)</li>
</ul>

  
<div class="theory-common-box">
Lemma 1: By Kepler's first law, a planet orbits in an ellipse with the central star at a focus.
In terms of perihelion distance $a$ and aphelion distance $b$, the area $S$ of the ellipse is
$$
S = \pi\frac{a+b}{2}\sqrt{ab}
$$
</div>
<div class="proof-box">Proof</div>
Let the semi-major and semi-minor axes be $l$ and $m$. The area is $\pi l m$.<br>
From the figure, $l = \displaystyle \frac {a+b}{2}$<br>
By the Pythagorean theorem, $l ^2 =  (l - a) ^2 + m ^2$, so
$$\begin{aligned}
\ \ \ l ^2 &= (l - a) ^2 + m ^2 \\[6pt]
\Leftrightarrow \Bigl(\frac{a+b}{2}\Bigr)^2 &= \Bigl(\frac{a+b}{2} - a\Bigr)^2 + m ^2 \\[6pt]
\Leftrightarrow \Bigl(\frac{a+b}{2}\Bigr)^2 &= \Bigl(\frac{a-b}{2}\Bigr)^2 + m ^2 \\[6pt]
\Leftrightarrow \frac{a^2+2ab+b^2}{4} &= \frac{a^2-2ab+b^2}{4} + m ^2 \\[6pt]
\Leftrightarrow ab &=  m ^2 \\[6pt]
\Leftrightarrow m &=  \sqrt{ab}
\end{aligned}$$
Hence
$$
S = \pi l m = \pi\frac{a+b}{2}\sqrt{ab}
$$
<div style="text-align:center; margin:1em 0;">
    <img src="assets/dynamicsTheory/kepler-third2.png"
          style="max-width:100%; height:auto;" />
  </div>
　⬜︎
<div class="theory-common-box">
Lemma 2: In terms of perihelion $a$ and aphelion $b$, the areal velocity $V_s$ is
$$ \displaystyle V_s = \sqrt{GM\frac{ab}{2(a+b)}}$$
</div>
<div class="proof-box">Proof</div>
Let $v_a$ and $v_b$ be the speeds at perihelion and aphelion. Energy conservation and Kepler's second law give
$$
\begin{cases}
\displaystyle \frac{1}{2}mv_a^2 - \frac{GMm}{a} = \frac{1}{2}mv_b^2 - \frac{GMm}{b} \\
\displaystyle \frac{1}{2}av_a = \frac{1}{2}bv_b
\end{cases}
$$

Expressing $v_a, v_b$ in terms of $a, b$,
$$
\frac{1}{2}m\frac{b^2}{a^2}v_b^2 - \frac{GMm}{a}
= \frac{1}{2}mv_b^2 - \frac{GMm}{b}
$$
$$
\Leftrightarrow \frac{1}{2}m\Bigl(\frac{b^2}{a^2}-1\Bigr)v_b^2
= \frac{GMm}{a}- \frac{GMm}{b}
$$
$$
\Leftrightarrow \frac{1}{2}m\Bigl(\frac{b^2-a^2}{a^2}\Bigr)v_b^2
= \frac{GMm(b-a)}{ab}
$$
$$
\Leftrightarrow \frac{1}{2}m(a+b)v_b^2
= GMm\frac{a}{b}
$$
$$
\Leftrightarrow v_b^2 = 2GM\frac{a}{b(a+b)}
$$
$$
\Leftrightarrow v_b = \sqrt{2GM\frac{a}{b(a+b)}}\ \ (\ \because v_b > 0\ )
$$

Similarly
$$
v_a = \pm\sqrt{2GM\frac{b}{a(a+b)}}\ \  (\ \because v_a > 0\ )
$$
The areal velocity is $\displaystyle \frac 1 2 v_a a \sin 90^{\circ}$ (or $\displaystyle \frac 1 2 v_b b \sin 90^{\circ}$), so

$$
V_s = \frac 1 2 v_a a = \frac 1 2 v_b b = \sqrt{GM\frac{ab}{2(a+b)}}
$$　⬜︎

<div class="theory-common-box">
Theorem (Kepler's third law): For gravitational constant $G$, semi-major axis $l$, period $T$, and central mass $M$,
$$\frac{T^2}{l^3}=\frac{4\pi^2}{GM}$$
</div>
<div class="proof-box">Proof</div>
The period is the elliptical area $S$ divided by the areal velocity $V_s$. Substituting Lemmas 1 and 2,
$$\begin{aligned}
\displaystyle T &=\frac{S}{V_s}\\[6pt]
\displaystyle &= \frac{\pi\frac{a+b}{2}\sqrt{ab}}{\sqrt{GM\frac{ab}{2(a+b)}}}\\[6pt]
\displaystyle &= \frac{\pi (a+b)}{\sqrt{\frac{2GM}{(a+b)}}}\\[6pt]
\displaystyle &= \frac{\pi (a+b)^{3/2}}{\sqrt{2GM}}
\end{aligned}$$

Hence
$$\begin{aligned}
\ \ \ \ \frac{T^2}{(a+b)^3} &= \frac{\pi^2}{2GM}\\[6pt]
\Leftrightarrow \frac{T^2}{\Bigl(\frac{a+b}{2}\Bigr)^3} &= \frac{4\pi^2}{GM}\\[6pt]
\Leftrightarrow \frac{T^2}{l^3} &= \frac{4\pi^2}{GM}
\end{aligned}$$
Q.E.D.
"""
);
