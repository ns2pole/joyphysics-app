import '../../model.dart';

final fluxAndAreaIntegral = TheoryTopic(
  title :  '定義および命題',
  titleEn: 'Definitions and propositions',
  // imageAsset: 'assets/mindMap/forTopics/fluxAndAreaIntegral.png',
  latexContent :  r"""
<div class="theory-common-box">一様なベクトル場の平面に対する流束の定義
一様なベクトル場 $ \vec F $が面積$A$の平面$S$を貫く流速を下記で定義する。<br>
$$
\Phi = |\vec F | A \cos\theta = ( \vec F \cdot \vec n )A 
$$
※ここで、$\theta$は平面に対する単位法線ベクトル $ \vec n $ とベクトル場$\vec F$のなす角。
</div>
<div class="theory-common-box">一般の流束計算(面積分)の定義</div>
一般に、向き,大きさが変化するベクトル場$\vec F$が，曲面$S$を貫く流速を下記で定義する。

$$\begin{aligned}
\iint_S \vec F\cdot d\vec S
& : = \lim_{| P | \to 0}
\sum_{i=1}^{N(P)} (\vec F_i\cdot\vec n_i)\,\Delta S_i\\[4pt]
&\;\Bigl(= \lim_{| P | \to 0}
\sum_{i=1}^{N(P)} |\vec F_i|\cos\theta_i\,\Delta S_i\Bigr)
\end{aligned}$$

<div class="paragraph-box">記号の定義</div>
<ul>
  <li> $P$ : 曲面$S$の分割</li>
  <li> $N(P)$ : 分割領域の個数</li>
  <li> $R_i$ : $\ i$番目の分割領域</li>
  <li> $\operatorname{diam}(R_i) : $ $R_i$の直径。$R_i$の中で最も遠い点同士の距離</li>
  <li> $|P| : $ $ \displaystyle \max_i \operatorname{diam}(R_i)$ もっとも大きい分割領域の直径。</li>
  <li> $\vec F_i$ : $\ i$番目の分割領域の代表点でのベクトル場</li>
  <li> $\vec n_i$ : $\ i$番目の分割領域の代表点での単位法線ベクトル</li>
  <li> $\theta_i$ : $ \vec F_i $ と $ \vec n_i $ のなす角</li>
   <li> $\vec F_i\cdot\vec n_i\,\Delta S_i,\  |\vec F_i|\cos\theta_i\,\Delta S_i$：$i$番目の分割領域$R_i$におけるベクトル場$\vec F$の流束の近似値</li>
</ul>

<div class="theory-common-box">命題：曲面 $\Sigma $ 上で $ |\vec F|$ が一定値$F$を取り、かつ単位法線とのなす角が面上で一定 $ \theta $ のとき，曲面$S$の面積をAとすると、流束は下記となる。
$$
\iint_S \vec F\cdot d\vec S = F\cos\theta\cdot A
$$
</div>

<p><div class="proof-box">証明</div>
定義より
$$
\iint_S \vec F\cdot d\vec S
= \lim_{| P | \to 0}\sum_{i=1}^{N(P)} (\vec F_i\cdot\vec n_i)\,\Delta S_i
$$
各代表点で $ |\vec F_i|=F$, $ \vec F_i\cdot\vec n_i=F\cos\theta$ なので
$$
\sum_{i=1}^{N(P)} (\vec F_i\cdot\vec n_i)\,\Delta S_i
= F\cos\theta\sum_{i=1}^{N(P)}\Delta S_i
$$
ここで、$\sum_{i=1}^{N(P)}\Delta S_i$は全領域に渡って分割領域の面積を足すということなので$ A $となる。よって、
$$
\iint_S \vec F\cdot d\vec S
= \lim_{| P | \to 0}\Bigl(F\cos\theta\cdot A  \Bigr)= F\cos\theta\cdot A
$$　Q.E.D
</p>
""",
  latexContentEn: r"""
<div class="theory-common-box">Definition of flux of a uniform vector field through a plane
The flux of a uniform vector field $ \vec F $ through a plane $S$ of area $A$ is defined by<br>
$$
\Phi = |\vec F | A \cos\theta = ( \vec F \cdot \vec n )A 
$$
※ Here $\theta$ is the angle between the unit normal $ \vec n $ to the plane and the field $\vec F$.
</div>
<div class="theory-common-box">Definition of flux in general (surface integral)</div>
In general, the flux of a vector field $\vec F$ that may vary in direction and magnitude through a surface $S$ is defined by

$$\begin{aligned}
\iint_S \vec F\cdot d\vec S
& : = \lim_{| P | \to 0}
\sum_{i=1}^{N(P)} (\vec F_i\cdot\vec n_i)\,\Delta S_i\\[4pt]
&\;\Bigl(= \lim_{| P | \to 0}
\sum_{i=1}^{N(P)} |\vec F_i|\cos\theta_i\,\Delta S_i\Bigr)
\end{aligned}$$

<div class="paragraph-box">Definition of symbols</div>
<ul>
  <li> $P$ : a partition of the surface $S$</li>
  <li> $N(P)$ : number of partition regions</li>
  <li> $R_i$ : the $i$-th partition region</li>
  <li> $\operatorname{diam}(R_i) : $ diameter of $R_i$ (largest distance between points in $R_i$)</li>
  <li> $|P| : $ $ \displaystyle \max_i \operatorname{diam}(R_i)$, the largest diameter among partition regions.</li>
  <li> $\vec F_i$ : the vector field at a representative point of the $i$-th region</li>
  <li> $\vec n_i$ : the unit normal at a representative point of the $i$-th region</li>
  <li> $\theta_i$ : angle between $ \vec F_i $ and $ \vec n_i $</li>
   <li> $\vec F_i\cdot\vec n_i\,\Delta S_i,\  |\vec F_i|\cos\theta_i\,\Delta S_i$: approximate flux of $\vec F$ through region $R_i$</li>
</ul>

<div class="theory-common-box">Proposition: If $|\vec F|$ is a constant $F$ on a surface $\Sigma $ and the angle with the unit normal is a constant $ \theta $ on the surface, then with area $A$ of $S$, the flux is
$$
\iint_S \vec F\cdot d\vec S = F\cos\theta\cdot A
$$
</div>

<p><div class="proof-box">Proof</div>
By definition
$$
\iint_S \vec F\cdot d\vec S
= \lim_{| P | \to 0}\sum_{i=1}^{N(P)} (\vec F_i\cdot\vec n_i)\,\Delta S_i
$$
At each representative point $|\vec F_i|=F$ and $ \vec F_i\cdot\vec n_i=F\cos\theta$, so
$$
\sum_{i=1}^{N(P)} (\vec F_i\cdot\vec n_i)\,\Delta S_i
= F\cos\theta\sum_{i=1}^{N(P)}\Delta S_i
$$
Here $\sum_{i=1}^{N(P)}\Delta S_i$ is the sum of the areas of all partition regions, hence equals $ A $. Therefore
$$
\iint_S \vec F\cdot d\vec S
= \lim_{| P | \to 0}\Bigl(F\cos\theta\cdot A  \Bigr)= F\cos\theta\cdot A
$$　Q.E.D
</p>
"""
);