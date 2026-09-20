import '../../model.dart';

final magneticDipole = TheoryTopic(
  title: '磁気双極子',
  // imageAsset: 'assets/mindMap/forTopics/magneticDipole.png',
  latexContent: r"""

<div class="theory-common-box">命題1：単一仮想仮想磁場が作る場（仮想磁荷モデル）</div>
<p>
仮想磁荷モデルを仮定するならば、仮想磁荷 $ \displaystyle q_m$ が位置 $ \displaystyle \vec r_q$ に存在するときに作る磁場は逆二乗則の場として表される：
$$
\vec B(\vec r) = \frac{q_m}{4\pi}\frac{\vec r-\vec r_q}{|\vec r-\vec r_q|^3}
$$
※ 実際には、仮想磁荷は未だ未発見なため、このモデルは便宜的・概念的な扱いであることに注意。
</p>


<div class="theory-common-box">命題2：テイラー展開</div>
$|\vec {\epsilon}|$が$|\vec r|$に比べて十分小さい時、$|\vec r + \vec \epsilon|^{-3} $の値は下記で近似できる。
$$
r^{-3} \left( 1 - 3 \frac{\hat r \cdot \vec \epsilon}{r} \right),
$$

<div class="proof-box">証明</div>
<p>
$$\begin{aligned}
\ \ &|\vec r+\vec\epsilon|^{-3}\\[6pt]
=&(|\vec r+\vec\epsilon|^2)^{-\frac 2 3}\\[6pt]
=&\bigl((\vec r+\vec\epsilon) \cdot (\vec r+ \vec \epsilon) )\bigr) ^{-\frac 2 3}\\[6pt]
=&\bigl(|\vec r|^2+2 \vec v \cdot \vec \epsilon+ |\epsilon|^2\bigr) ^{-\frac 2 3}\\[6pt]
=&\bigl(r^2+2 \vec v \cdot \vec \epsilon+ \epsilon^2 \bigr) ^{-\frac 2 3}\\[6pt]
=&\Biggl(r^{2}\Bigl(1+2 \frac {\vec v \cdot \vec \epsilon}{r^2}+ \frac {\epsilon^2}{r^2} \Bigr)\Biggr) ^{-\frac 2 3}\\[6pt]
=&r^{-3} \Bigl(1+2 \frac {\vec v \cdot \vec \epsilon}{r^2}+ \frac {\epsilon^2}{r^2} \Bigr) ^{-\frac 2 3}\\[6pt]
=&r^{-3} \Bigl(1+x \Bigr) ^{-\frac 2 3}\ \ ;\ \ x:=2\frac{\vec r\cdot\vec\epsilon}{r^2}+\frac{\epsilon^2}{r^2}
\end{aligned}$$

二項展開の一次まで取ると
$$
(1+x)^{-3/2}\fallingdotseq 1-\frac{3}{2}x
$$

したがって
$$\begin{aligned}
|\vec r+\vec\epsilon|^{-3}&\fallingdotseq r^{-3}\Bigl(1-\frac{3}{2}\Bigl(2\frac{\vec r\cdot\vec\epsilon}{r^2}+\frac{\epsilon^2}{r^2}\Bigr)\Bigr)\\[6pt]
&= r^{-3}\Bigl(1-3\frac{\vec r\cdot\vec\epsilon}{r^2}-\frac{3}{2}\frac{\epsilon^2}{r^2}\Bigr)
\end{aligned}$$
さらに、 $\epsilon$ の1次まで残すと
$$
|\vec r+\vec\epsilon|^{-3}\fallingdotseq r^{-3}\Bigl(1-3\frac{\vec r\cdot\vec\epsilon}{r^2}\Bigr)
\Bigr)
$$
Q.E.D
</p>

<div class="theory-common-box">命題3（仮想磁荷モデルによる磁気双極子の作る磁場）：
大きさが等しく符号が反対の仮想磁荷 $ \displaystyle \pm q_m$が、位置$\displaystyle \pm \frac {1}{2} {\vec d}$に存在する時、$ \displaystyle |\vec d|\ll |\vec r|$ の位置における磁場は下記で近似できる。
$$
\vec B(\vec r)=\frac{\mu_0}{4\pi r^3}\Bigl(-\vec m + 3(\vec m\cdot\hat r)\hat r\Bigr)
$$
ただし $ \displaystyle \vec m=\frac{q_m\vec d}{\mu_0}$, $ \displaystyle r=|\vec r|,\ \hat r=\displaystyle \frac{\vec r}{r}$ である。</div>
<div class="paragraph-box">証明</div>
<p>
2つの仮想磁荷による合成磁場は
$$\begin{aligned}
&\ \ \ \ \ \vec B(\vec r) = \vec B_+ + \vec B_- \\[6pt]
& = \frac{q_m}{4\pi}  \left( \frac{\vec r - \frac{1}{2}\vec d}{|\vec r - \frac{1}{2}\vec d|^3} - \frac{\vec r + \frac{1}{2}\vec d}{|\vec r + \frac{1}{2}\vec d|^3} \right)
\end{aligned}$$

上の命題2に、$ \displaystyle \vec \epsilon = \pm \frac{\vec d} {2} $ を代入して計算を行うと、
$$
\frac{1}{|\vec r \pm \frac{1}{2}\vec d|^3} \fallingdotseq \frac{1}{r^3} \left( 1 \mp 3 \frac{\vec r \cdot \vec d}{2 r^2} \right)
$$
となる。
よって、$\displaystyle \vec r \mp \frac{1}{2}\vec d $を掛け合わせると
これに分子 $ \displaystyle \vec r\mp\frac12\vec d$ を掛けた一次展開をそのまま書くと、
$$
\frac{\vec r-\frac12\vec d}{\bigl|\vec r-\frac12\vec d\bigr|^3}=\frac{\vec r}{r^3}-\frac{\vec d}{2r^3}+\frac{3(\vec r\cdot\vec d)\vec r}{2r^5}+O\!\Bigl(\frac{|\vec d|^2}{r^4}\Bigr),
$$
$$
\frac{\vec r+\frac12\vec d}{\bigl|\vec r+\frac12\vec d\bigr|^3}=\frac{\vec r}{r^3}+\frac{\vec d}{2r^3}-\frac{3(\vec r\cdot\vec d)\vec r}{2r^5}+O\!\Bigl(\frac{|\vec d|^2}{r^4}\Bigr)
$$
差を取ると 0 次の項 $ \displaystyle \frac{\vec {r}}{r^3} $ は打ち消され、一次の項のみが残る：
$$
\frac{\vec r-\frac12\vec d}{\bigl|\vec r-\frac12\vec d\bigr|^3}-\frac{\vec r+\frac12\vec d}{\bigl|\vec r+\frac12\vec d\bigr|^3}
= -\frac{\vec d}{r^3}+\frac{3(\vec r\cdot\vec d)\vec r}{r^5}+O\!\Bigl(\frac{|\vec d|^2}{r^4}\Bigr)
$$

この式の結果に係数 $ \displaystyle \dfrac{q_m}{4\pi}$ を掛けたものが磁場であるので、$\displaystyle \vec m=q_m\vec d,\ \hat r=\frac {\vec r}{r}$とすると、結局
$$\begin{aligned}
&\vec B(\vec r)\\[6pt]
\fallingdotseq &\frac{q_m}{4\pi r^3} \Biggl( - { \vec d}+\frac{3(\vec r\cdot\vec d)\vec r}{r^2}\Biggr)+O\!\Bigl(\frac{|\vec d|^3}{r^5}\Bigr)\\[6pt]
\fallingdotseq &\frac{q_m}{4\pi r^3} \Biggl( - { \vec d}+3 \frac{\vec r}{r} \cdot\vec d \frac{\vec r}{r} \Biggr)+O\!\Bigl(\frac{|\vec d|^3}{r^5}\Bigr)\\[6pt]
\fallingdotseq &\frac{\mu_0}{4\pi r^3} \Biggl( - \frac{q_m \vec d}{\mu_0}+3 \frac{\vec r}{r} \cdot \frac{q_m \vec d}{\mu_0} \frac{\vec r}{r} \Biggr)+O\!\Bigl(\frac{|\vec d|^3}{r^5}\Bigr)\\[6pt]
\fallingdotseq &\frac{\mu_0}{4\pi r^3} \Bigl(- \vec m + 3(\vec m\cdot\hat r)\hat r \Bigr) + O\!\Bigl(\frac{|\vec d|^3}{r^5}\Bigr)
\end{aligned}$$
ここで$|\vec d|$の2次以上を切り捨てると所望の近似式が得られる。
</p>

<div class="theory-common-box">定義（磁気双極子モーメント）</div>
<p>
平面のループに対して、磁気双極子モーメント $ \displaystyle \vec m$ を下記で定義する。
$$
\vec m = I\vec S
$$
ここで $ \displaystyle I$ はループ電流、$ \displaystyle \vec S$ はループの面積ベクトル（ベクトルの大きさは面積で、向きは右ねじの法則で定まる向き）である。
</p>

<div class="theory-common-box">例：円形ループの磁気モーメント</div>
<p>
半径 $ \displaystyle r$ の円形ループに電流 $ \displaystyle I$ が流れている時、電流ループの磁気モーメントは下記で与えられる。
$$
\vec m = I \pi r^2\hat n
$$
</p>

<div class="theory-common-box">命題4(正方形コイルに流れる電流に働くトルク)：辺長 $ \displaystyle a$ の正方形ループ（原点中心、xy 平面）に電流 $ \displaystyle I$ が流れており、一定磁場 $ \displaystyle \vec{B}=(B_x,B_y,B_z)$ のもとにある時、電流ループに働くトルクは下記で表される。
$$
\displaystyle \vec{\tau}=\vec{m}\times\vec{B},\ \ ; \ \ \vec{m}=I a^2\hat{k}
$$</div>

<div class="paragraph-box">証明</div>

<p>回路$C$について、トルクの一般式は</p>
$$
\displaystyle \vec{\tau}=\oint_{C} \vec{r}\times\bigl(Id\vec{l}\times\vec{B}\bigr)
$$
<p>電流は原点から見て半時計回りに流れるものとし、辺を AB → BC → CD → DA の順に取る。各辺ごとに被積分関数を展開し、積分を取る。</p>

<p><strong>辺 AB</strong>：$ \displaystyle y=-\frac{a}{2},\ x\in[-\frac{a}{2},\frac{a}{2}],\ d\vec{l}=dx\hat{i},\ \vec{r}=x\hat{i}-\frac{a}{2}\hat{j}$</p>
$$
\displaystyle d\vec{l}\times\vec{B}=dx\hat{i}\times(B_x\hat{i}+B_y\hat{j}+B_z\hat{k})
=dx(B_y\hat{k}-B_z\hat{j})
$$
次に
$$
\displaystyle \vec{r}\times(d\vec{l}\times\vec{B})
=(x\hat{i}-\frac{a}{2}\hat{j})\times(B_y\hat{k}-B_z\hat{j})dx
$$
成分ごとに展開すると
$$\begin{aligned}
(x\hat{i})\times(B_y\hat{k}-B_z\hat{j})
&=xB_y(\hat{i}\times\hat{k})-xB_z(\hat{i}\times\hat{j})\\[6pt]
&=xB_y(-\hat{j})-xB_z(\hat{k})=-xB_y\hat{j}-xB_z\hat{k},\\[6pt]
\left(-\frac{a}{2}\hat{j}\right)\times(B_y\hat{k}-B_z\hat{j})
&=-\frac{a}{2}B_y(\hat{j}\times\hat{k})+0=-\frac{a}{2}B_y\hat{i}
\end{aligned}$$
したがって
$$
\displaystyle \vec{r}\times(d\vec{l}\times\vec{B})
=dx\bigl(-\frac{a}{2}B_y\hat{i}-xB_y\hat{j}-xB_z\hat{k}\bigr)
$$
これを $ \displaystyle x$ について積分すると（$ \displaystyle  x$ に比例する項は奇関数で消える）
$$
\displaystyle \vec{\tau}_{AB}=I\int_{-a/2}^{a/2}\bigl(-\frac{a}{2}B_y\hat{i}-xB_y\hat{j}-xB_z\hat{k}\bigr)dx
=I\bigl(-\frac{a^2}{2}B_y\hat{i}\bigr)
$$

<p><strong>辺 BC</strong>：$ \displaystyle  x=\frac{a}{2},\ y\in[-\frac{a}{2},\frac{a}{2}],\ d\vec{l}=dy\hat{j},\ \vec{r}=\frac{a}{2}\hat{i}+y\hat{j}$</p>
$$
\displaystyle d\vec{l}\times\vec{B}=dy\hat{j}\times(B_x\hat{i}+B_y\hat{j}+B_z\hat{k})
=dy(-B_x\hat{k}+B_z\hat{i})
$$
よって
$$
\displaystyle \vec{r}\times(d\vec{l}\times\vec{B})
=(\frac{a}{2}\hat{i}+y\hat{j})\times(-B_x\hat{k}+B_z\hat{i})dy
$$
各項を計算すると
$$\begin{aligned}
(\frac{a}{2}\hat{i})\times(-B_x\hat{k})&=\frac{a}{2}B_x\hat{j},\\[6pt]
(y\hat{j})\times(-B_x\hat{k})&=-yB_x\hat{i},\\[6pt]
(y\hat{j})\times(B_z\hat{i})&=-yB_z\hat{k}
\end{aligned}$$
（$ \displaystyle \hat{i}\times\hat{i}=\hat{j}\times\hat{j}=0$ の項は省略）
従って
$$
\displaystyle \vec{r}\times(d\vec{l}\times\vec{B})=dy\bigl(-yB_x\hat{i}+\frac{a}{2}B_x\hat{j}-yB_z\hat{k}\bigr)
$$
これを $ \displaystyle y$ で積分すると
$$
\displaystyle \vec{\tau}_{BC}=I\int_{-a/2}^{a/2}\bigl(-yB_x\hat{i}+\frac{a}{2}B_x\hat{j}-yB_z\hat{k}\bigr)dy
=I\bigl(\frac{a^2}{2}B_x\hat{j}\bigr)
$$

<p><strong>辺 CD</strong>（$ \displaystyle y=+\frac{a}{2}$ を逆向きに進む）：AB と同様の計算で向きが反転する箇所を含めると</p>
$$
\displaystyle \vec{\tau}_{CD}=I\bigl(-\frac{a^2}{2}B_y\hat{i}\bigr)
$$

<p><strong>辺 DA</strong>（$ \displaystyle x=-\frac{a}{2}$ を逆向きに進む）：BC と同様に</p>
$$
\displaystyle \vec{\tau}_{DA}=I\bigl(\frac{a^2}{2}B_x\hat{j}\bigr)
$$

<p>以上を合算すると</p>
$$\begin{aligned}
\displaystyle \vec{\tau}
&=\vec{\tau}_{AB}+\vec{\tau}_{BC}+\vec{\tau}_{CD}+\vec{\tau}_{DA}\\[6pt]
&=I\Bigl(-\frac{a^2}{2}B_y\hat{i}+\frac{a^2}{2}B_x\hat{j}-\frac{a^2}{2}B_y\hat{i}+\frac{a^2}{2}B_x\hat{j}\Bigr)\\[6pt]
&=I\bigl(-a^2B_y\hat{i}+a^2B_x\hat{j}\bigr)\\[6pt]
&=I a^2\bigl(-B_y\hat{i}+B_x\hat{j}\bigr)
\end{aligned}
$$

<p>磁気モーメントを $ \displaystyle  \vec{m}=I a^2\hat{k}$ とすると、右辺は $ \displaystyle \vec{m}\times\vec{B}$ と一致する。Q.E.D</p>

<hr style="margin:1.0em 0;">

<div class="theory-common-box">命題5（円形コイルに対するトルク）：
半径 $ \displaystyle R$ の円形ループ（原点中心、xy 平面）に電流 $ \displaystyle I$ が流れており、一定磁場 $ \displaystyle \vec{B}=(B_x,B_y,B_z)$ のもとにあるとする。このときループに働くトルクは下記で表される。
$$
\displaystyle \vec{\tau}=\vec{m}\times\vec{B},\qquad \vec{m}=I\pi R^2\hat{k}
$$
</div>

<div class="paragraph-box">証明</div>

<p>位置ベクトルを角度パラメータ $ \displaystyle \theta$ を用いて</p>
$$
\displaystyle \vec{r}(\theta)=R\cos\theta\hat{i}+R\sin\theta\hat{j},\qquad 0\le\theta<2\pi,
$$
と取り、微小線分は
$$
\displaystyle d\vec{l}=\frac{d\vec{r}}{d\theta}d\theta =(-R\sin\theta\hat{i}+R\cos\theta\hat{j})d\theta.
$$

<p>トルクは</p>
$$
\displaystyle \vec{\tau}=I\oint \vec{r}\times\bigl(d\vec{l}\times\vec{B}\bigr)
=I\int_{0}^{2\pi}\vec{r}(\theta)\times\bigl(d\vec{l}(\theta)\times\vec{B}\bigr)
$$

<p>まず $ \displaystyle d\vec{l}\times\vec{B}$ を展開する：</p>
$$\begin{aligned}
\displaystyle d\vec{l}\times\vec{B}
&=(-R\sin\theta\hat{i}+R\cos\theta\hat{j})\times(B_x\hat{i}+B_y\hat{j}+B_z\hat{k})d\theta\\[6pt]
&= \Bigl[(-R\sin\theta)(B_x\hat{i}\times\hat{i})+(-R\sin\theta)(B_y\hat{i}\times\hat{j})+(-R\sin\theta)(B_z\hat{i}\times\hat{k})\\[6pt]
&\qquad +(R\cos\theta)(B_x\hat{j}\times\hat{i})+(R\cos\theta)(B_y\hat{j}\times\hat{j})+(R\cos\theta)(B_z\hat{j}\times\hat{k})\Bigr]d\theta\\[6pt]
&= \bigl(R\sin\theta B_z\hat{j} + R\sin\theta B_y\hat{k} - R\cos\theta B_x\hat{k} - R\cos\theta B_z\hat{i}\bigr)d\theta,
\end{aligned}$$
（単位ベクトルの積 $ \displaystyle \hat{i}\times\hat{j}=\hat{k},\ \hat{j}\times\hat{i}=-\hat{k}$ 等を用いて整理した）

<p>次に $ \displaystyle \vec{r}\times(d\vec{l}\times\vec{B})$ を求める。まずスカラー積を確認する：</p>
$$
\displaystyle \vec{r}\cdot\vec{B}=R\cos\theta B_x+R\sin\theta B_y,
\qquad
\displaystyle \vec{r}\cdot d\vec{l}=R\cos\theta(-R\sin\theta d\theta)+R\sin\theta(R\cos\theta d\theta)=0
$$
（$ \displaystyle \vec{r}\cdot d\vec{l}=0$ は円周上での接線と半径が直交することの表示）

<p>ここでは三重積恒等式を使わず直接成分展開する。上で得た $ \displaystyle d\vec{l}\times\vec{B}$ を用いて：</p>
$$\begin{aligned}
\displaystyle \vec{r}\times(d\vec{l}\times\vec{B})
&=(R\cos\theta\hat{i}+R\sin\theta\hat{j})\\
&\qquad\times\bigl( -R\cos\theta B_z\hat{i} + R\sin\theta B_z\hat{j} + (R\sin\theta B_y - R\cos\theta B_x)\hat{k} \bigr)d\theta
\end{aligned}$$
（上の括弧内は前式を成分ごとに再整理したもの）

<p>これを各項で計算する：</p>
$$\begin{aligned}
\displaystyle &(R\cos\theta\hat{i})\times\bigl(-R\cos\theta B_z\hat{i}\bigr)=0,\\[6pt]
\displaystyle &(R\cos\theta\hat{i})\times\bigl(R\sin\theta B_z\hat{j}\bigr)
=R^2\cos\theta\sin\theta B_z(\hat{i}\times\hat{j})=R^2\cos\theta\sin\theta B_z\hat{k},\\[6pt]
\displaystyle &(R\cos\theta\hat{i})\times\bigl((R\sin\theta B_y - R\cos\theta B_x)\hat{k}\bigr)\\[6pt]
&\qquad=R^2\cos\theta\bigl(\sin\theta B_y - \cos\theta B_x\bigr)(\hat{i}\times\hat{k})\\[6pt]
&\qquad=R^2\cos\theta\bigl(\sin\theta B_y - \cos\theta B_x\bigr)(-\hat{j})\\[6pt]
&\qquad=-R^2\cos\theta\bigl(\sin\theta B_y - \cos\theta B_x\bigr)\hat{j}
\end{aligned}$$
および
$$\begin{aligned}
\displaystyle &(R\sin\theta\hat{j})\times\bigl(-R\cos\theta B_z\hat{i}\bigr)
= -R^2\sin\theta\cos\theta B_z(\hat{j}\times\hat{i})\\[6pt]
&\qquad= -R^2\sin\theta\cos\theta B_z(-\hat{k})=R^2\sin\theta\cos\theta B_z\hat{k},\\[6pt]
\displaystyle &(R\sin\theta\hat{j})\times\bigl(R\sin\theta B_z\hat{j}\bigr)=0,\\[6pt]
\displaystyle &(R\sin\theta\hat{j})\times\bigl((R\sin\theta B_y - R\cos\theta B_x)\hat{k}\bigr)\\[6pt]
&\qquad=R^2\sin\theta\bigl(\sin\theta B_y - \cos\theta B_x\bigr)(\hat{j}\times\hat{k})\\[6pt]
&\qquad=R^2\sin\theta\bigl(\sin\theta B_y - \cos\theta B_x\bigr)\hat{i}
\end{aligned}$$

<p>以上を合算して、$ \displaystyle \vec{r}\times(d\vec{l}\times\vec{B})$ の空間ベクトル成分を整理すると（$ \displaystyle B_z$ に依存する $ \displaystyle \hat{k}$ 成分は上で打ち消される）：</p>
$$
\displaystyle \vec{r}\times(d\vec{l}\times\vec{B})
= d\theta R^2\Bigl( -B_y\cos\theta\sin\theta + B_x\cos^2\theta \Bigr)\hat{i}
+ d\theta R^2\Bigl( -B_y\sin^2\theta + B_x\sin\theta\cos\theta \Bigr)\hat{j}
$$

<p>これを $ \displaystyle 0$ から $ \displaystyle 2\pi$ まで積分してトルク成分を得る。</p>

<p><strong>(x 成分)</strong></p>
$$\begin{aligned}
\displaystyle \tau_x
&=I\int_0^{2\pi} R^2\bigl(-B_y\cos\theta\sin\theta + B_x\cos^2\theta\bigr)d\theta\\[6pt]
&=I R^2\Bigl(-B_y\int_0^{2\pi}\cos\theta\sin\theta d\theta + B_x\int_0^{2\pi}\cos^2\theta d\theta\Bigr)\\[6pt]
&=I R^2\Bigl(-B_y\cdot 0 + B_x\cdot \pi\Bigr)\quad\Bigl(\int_0^{2\pi}\cos\theta\sin\theta d\theta=0,\ \int_0^{2\pi}\cos^2\theta d\theta=\pi\Bigr)\\[6pt]
&=I\pi R^2 B_x
\end{aligned}$$
<p><strong>(y 成分)</strong></p>
$$\begin{aligned}
\displaystyle \tau_y
&=I\int_0^{2\pi} R^2\bigl(-B_y\sin^2\theta + B_x\sin\theta\cos\theta\bigr)d\theta\\[6pt]
&=I R^2\Bigl(-B_y\int_0^{2\pi}\sin^2\theta d\theta + B_x\int_0^{2\pi}\sin\theta\cos\theta d\theta\Bigr)\\[6pt]
&=I R^2\Bigl(-B_y\cdot \pi + B_x\cdot 0\Bigr)\\[6pt]
&=-I\pi R^2 B_y
\end{aligned}$$
<p><strong>(z 成分)</strong>：上の計算より明らかに $ \displaystyle \tau_z=0$</p>

<p>したがって</p>
$$
\displaystyle \vec{\tau}=I\pi R^2\bigl(-B_y\hat{i}+B_x\hat{j}\bigr)
$$
磁気モーメント $ \displaystyle \vec{m}=I\pi R^2\hat{k}$ を用いると、右辺は $ \displaystyle \vec{m}\times\vec{B}$ と一致する。　Q.E.D</p>

<hr style="margin:1.0em 0;">




<div class="theory-common-box">命題6(円形電流が遠方に作る磁場)：原点を中心とした,電流$I$,半径$a\ $の$xy$平面内の円形電流ループが作る磁場は、観測点がループから十分遠い($a \ll r$)ならば、下記で近似できる。
$$
\vec B(\vec r)= \displaystyle \frac{\mu_0}{4\pi r^3} \Bigl(-\vec m + 3(\vec m \cdot \hat{r})\hat{r}\Bigr)
$$
ただし、$\displaystyle \vec m= \pi a^2 I\hat{z}, \ \ r=|\vec r|, \ \ \hat{r}=\frac{\vec r}{r}$</div>

<div class="proof-box">証明</div>
<p>
円形電流の中心を原点に、ループ面$xy$-平面として座標を取ると、Biot–Savartの法則より、
$$\begin{aligned}
\vec{B}(\vec r)
&= \displaystyle \frac{\mu_0 I}{4\pi}\oint_{\mathcal C}\frac{d\vec{\ell'}\times(\vec r-\vec r')}{|\vec r-\vec r'|^3},
\end{aligned}$$
で与えられる。
次にカーネル（積分核）を $\displaystyle \vec r'$ に関して、命題2より、
$\displaystyle \dfrac{\vec r-\vec r'}{|\vec r-\vec r'|^3}$
については$\displaystyle \hat{r}=\frac{\vec r}{r} $として、
$$\begin{aligned}
\frac{\vec r-\vec r'}{|\vec r-\vec r'|^3}
&= \displaystyle \frac{\hat{r}}{r^2} + \frac{3\hat{r}(\hat{r}\cdot\vec r')-\vec r'}{r^3} + O\!\Bigl(\frac{r'^2}{r^4}\Bigr)
\end{aligned}$$
Biot–Savartの式は
$$\begin{aligned}
\vec B(\vec r)
&= \displaystyle \frac{\mu_0 I}{4\pi}\oint_{\mathcal C}\! d\vec{\ell'}\times\left[
\frac{\hat{r}}{r^2} + \frac{3\hat{r}(\hat{r}\cdot\vec r')-\vec r'}{r^3} + O\!\Bigl(\frac{r'^2}{r^4}\Bigr)
\right]
\end{aligned}$$
である。これを展開すると
$$\begin{aligned}
\vec B(\vec r)
&= \displaystyle \frac{\mu_0 I}{4\pi}\left[
\frac{1}{r^2}\oint_{\mathcal C} d\vec{\ell'}\times\hat{r}
+\frac{1}{r^3}\oint_{\mathcal C} d\vec{\ell'}\times\big(3\hat{r}(\hat{r}\cdot\vec r')-\vec r'\big)
+O\!\Bigl(\frac{a^2}{r^4}\Bigr)
\right].
\end{aligned}$$

第1項は閉曲線の線素の総和に依るもので、閉曲線上の線素の総和はゼロであるため消える：
$$\begin{aligned}
\oint_{\mathcal C} d\vec{\ell'} &= \displaystyle \vec 0
\quad\Longrightarrow\quad
\oint_{\mathcal C} d\vec{\ell'}\times\hat{r}=\vec 0.
\end{aligned}$$
したがって主たる寄与は第2項である。

以降は円形ループの具体的パラメータ表示を使って第2項を評価する。ループを角変数 $\displaystyle \varphi\in[0,2\pi)$ で
$$\begin{aligned}
\vec r'(\varphi) &= \displaystyle a(\cos\varphi,\ \sin\varphi,\ 0),\\[6pt]
d\vec{\ell'}(\varphi) &= \displaystyle a(-\sin\varphi,\ \cos\varphi,\ 0)d\varphi
\end{aligned}$$
と表す。観測方向を $\displaystyle \hat{r}=(n_x,n_y,n_z)$ と書くと（定数ベクトル）、被積分子
$$\begin{aligned}
\vec J(\varphi)
&:= \displaystyle d\vec{\ell'}(\varphi)\times\big(3\hat{r}(\hat{r}\cdot\vec r'(\varphi))-\vec r'(\varphi)\big)
\end{aligned}$$
は成分ごとに計算可能である。まず内積
$$\begin{aligned}
\hat{r}\cdot\vec r'(\varphi)
&= \displaystyle a\bigl(n_x\cos\varphi+n_y\sin\varphi\bigr).
\end{aligned}$$
したがって
$$\begin{aligned}
&\ \ 3\hat{r}(\hat{r}\cdot\vec r'(\varphi))-\vec r'(\varphi)\\[6pt]
&= \displaystyle a\Bigl(3\hat{r}(n_x\cos\varphi+n_y\sin\varphi)-(\cos\varphi,\sin\varphi,0)\Bigr).
\end{aligned}$$
これと $\displaystyle d\vec{\ell'}(\varphi)=a(-\sin\varphi,\cos\varphi,0)d\varphi$ を外積し、角度 $\varphi$ で積分すると、各三角関数の既知の積分を用いて
$$\begin{aligned}
\oint_{\mathcal C}\vec J(\varphi)
&= \displaystyle a^2\pi\begin{pmatrix}3 n_x n_z\\[6pt] 3 n_y n_z\\[6pt] 3 n_z^2-1\end{pmatrix}.
\end{aligned}$$
<br>
この結果はベクトル形式で簡潔に書くと
$$\begin{aligned}
\oint_{\mathcal C} d\vec{\ell'}\times\big(3\hat{r}(\hat{r}\cdot\vec r')-\vec r'\big)
&= \displaystyle \pi a^2\big(3\hat{r}(\hat{r}\cdot\hat{z})-\hat{z}\big),
\end{aligned}$$
である（ここで $\displaystyle \hat{z}$ はループ法線方向）。
<br>
一方、円形ループの磁気モーメント$\vec m$ は定義により
$$\begin{aligned}
& \vec m = \displaystyle \pi a^2 I\hat{z}\\[6pt]
\Leftrightarrow & \hat{z} = \vec m \displaystyle \frac{I}{\pi a^2}
\end{aligned}$$
を用いると、
$$\begin{aligned}
&\ \displaystyle \pi a^2\big(3\hat{r}(\hat{r}\cdot\hat{z})-\hat{z}\big)\\[6pt]
&= \displaystyle \frac{1}{I}\big(3\hat{r}(\hat{r}\cdot\vec m)-\vec m\big)
\end{aligned}$$

これを Biot–Savart の式に戻すと、主項は
$$\begin{aligned}
\vec B(\vec r)
&= \displaystyle \frac{\mu_0 I}{4\pi}\cdot\frac{1}{r^3}\cdot\frac{1}{I}\big(3\hat{r}(\hat{r}\cdot\vec m)-\vec m\big) + O\!\Bigl(\frac{a^2}{r^4}\Bigr)\\[6pt]
&= \displaystyle \frac{\mu_0}{4\pi r^3}\Bigl(-\vec m + 3(\vec m \cdot \hat{r})\hat{r}\Bigr) +O\!\Bigl(\frac{a^2}{r^4}\Bigr)
\end{aligned}$$
ここで、$r$に比べて$a$が十分小さいとして、$\displaystyle O\bigl(\frac{a^2}{r^4}\bigr)$の項を無視すると、所望の式が得られる。　Q.E.D<br>
※ 誤差項は四極子以上の高次多極成分に相当し、磁場では $\displaystyle O\bigl(\frac{a^2}{r^4}\bigr)$ 程度。
<div class="paragraph-box">補足</div><br>
最後に軸上（$\displaystyle \hat{r}\parallel\vec m$）の特殊例を示すと、$\displaystyle \hat{r}\cdot\vec m=|\vec m|$ だから
$$\begin{aligned}
&\ \ \  \vec B_{\text{axis}}(r)\\[6pt]
&= \displaystyle \frac{\mu_0}{4\pi}\frac{2\vec m}{r^3}\\[6pt]
&= \displaystyle \frac{\mu_0 I a^2}{2}\frac{\hat{z}}{r^3}
\end{aligned}$$
となり、これは軸上の既知の $ \displaystyle r^{-3} $ 減衰を示す結果と一致する。
</p>

<div class="theory-common-box">
命題7(円形電流と仮想磁荷対(双極子)の相等性)：$a \ll r$の時、電流$I$,半径$a$の円形電流ループの作る磁場は、仮想磁荷$q_m = \pm \mu_0 \pi a I$を距離$a$だけ離して置いた磁荷対(双極子)の作る磁場に等しい。
</div>
<div class="proof-box">証明</div>
上の2つの命題3,6(仮想磁荷モデルによる磁気双極子の作る磁場, 円形電流が遠方に作る磁場)より、下記2つの式が成り立つ。
<p>
[1]大きさが等しく符号が反対の仮想磁荷 $ \displaystyle \pm q_m$が、位置$(0,0, \pm \frac{a}{2})$に存在する時、$ \displaystyle |\vec a| = a \ll |\vec r|$ の位置における磁場は
$$\begin{aligned}
\vec B(\vec r)=&\frac{\mu_0}{4\pi r^3}\Bigl(-\frac{q_m\vec a}{\mu_0} + 3(\frac{q_m\vec a}{\mu_0} \cdot \hat r)\hat r\Bigr)\\[6pt]
=&\frac{\mu_0}{4\pi r^3}\Bigl(-\frac{q_m a \hat{z}}{\mu_0} + 3(\frac{q_m a \hat{z}}{\mu_0} \cdot \hat r)\hat r\Bigr)\\[6pt]
\end{aligned}$$

[2]原点を中心とした,電流$I$,半径$a\ $の$xy$平面内の円形電流ループが作る磁場は、観測点がループから十分遠い($a \ll r$ )ならば、下記で近似できる。
$$
\vec B(\vec r)= \displaystyle \frac{\mu_0}{4\pi r^3} \Bigl(-\pi a^2 I\hat{z} + 3(\pi a^2 I\hat{z} \cdot \hat{r})\hat{r}\Bigr)
$$
これらが遠方$a \ll r$を満たす場所で同様の磁場を形成するには、$q_m = \mu_0 \pi a I [Wb]$であれば良い。　 Q.E.D
</p>


<div class="theory-common-box">
命題8(磁場が仮想磁荷に与える力)：電流$I$,半径$a$の円形電流ループを、仮想磁荷$\pm \mu_0 \pi a I$を距離$a$だけ離して置いた磁荷対(双極子)と等価とみなした時、$Q[Wb]$の磁荷に与える力を$Q \vec H$とすると、磁場が回転電流に与える原点周りのトルクと磁場が磁荷に与える原点周りのトルクは一致する。
</div>
<div class="proof-box">証明</div>
<p>
[1]円形電流ループに対するトルクは命題5より
$$\displaystyle \vec{\tau}_{loop}=I \pi a^2\hat{k} \times\vec{B}$$

[2]仮想磁荷双極子側（磁荷は $+Q,-Q$ を位置 $ \vec r_\pm=\pm\frac{a}{2}\hat z$ に置く）：
各磁荷に与えられた力を $\vec F_\pm=\pm Q\,\vec H$ とする。
仮定より、 $Q = \mu_0 I\pi a$ を使うと
$$\begin{aligned}
\vec {\tau}
= \mu_0 I\pi a^2 \hat z \times \vec H
=I \pi a^2\hat{k} \times\vec{B}
= \vec {\tau}_{loop}
\end{aligned}$$
　Q.E.D
</p>
""",
);
// <div class="paragraph-box">一般性について</div>
// <ul>
//   <li>正方形・円形の両証明は具体的な形状に対して「三重積の恒等式を用いた一般議論」と同じ結論を直接示したものである。任意の閉ループ（有限の面積を持つ連続な境界）についても、均一な磁場中では同様に $ \displaystyle \displaystyle \vec{\tau}=\vec{m}\times\vec{B}$ が成り立つ（ここで $ \displaystyle \vec{m}=I\vec{A}$ はループの面積ベクトル）。</li>
//   <li>その一般命題の簡潔な理由：トルクの積分表現に三重積恒等式を適用すると境界で消える項と面積に対応する項が現れ、結果として $ \displaystyle \vec{m}\times\vec{B}$ に帰着するためである（詳細証明は本節では省略）。</li>
// </ul>