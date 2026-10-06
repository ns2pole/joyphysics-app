import '../../model.dart';

final nonUniformCircularMotion = TheoryTopic(
  title: '非等速円運動の運動方程式',
  titleEn: 'Equation of motion for non-uniform circular motion',
  isNew: false,
  imageAsset: 'assets/mindMap/forTopics/nonUniformCircularMotion.png',

  latexContent: r"""
<p class="theory-common-box">記号の定義</p>
  <p>
  $\cdot \  \displaystyle F_r\cdots\vec F$の向心方向成分f<br>
  $\cdot \ \displaystyle F_\theta \cdots\vec F$の角度方向成分<br>
  $\cdot \ \displaystyle \theta \cdots$質点の$x$軸からの角度<br>
  $\cdot \ \vec r(t) \cdots$質点の位置ベクトル<br>
  $\cdot \ \vec v(t) \cdots$質点の速度ベクトル<br>
  $\cdot \ \vec a(t) \cdots$質点の加速度ベクトル<br>
  $\cdot \ v(t)=|\vec v(t)|\cdots$質点の速さ
  </p>

<p class="theory-common-box">定義（動径方向,角度方向単位ベクトル）</p>
下記の通り、円運動の動径方向単位ベクトルと角度方向単位ベクトルを定義する。
$$\begin{aligned}
\begin{cases}
\vec e_r(t) = \cos\theta(t)\vec e_x + \sin\theta(t)\vec e_y\\[6pt]
\vec e_{\theta}(t) = -\sin\theta(t)\vec e_x + \cos\theta(t)\vec e_y
\end{cases}
\end{aligned}$$

<p class="theory-common-box">命題1：動径方向,角度方向単位ベクトルの時間微分は下記の通りになる。
$$\begin{aligned}
\begin{cases}
\vec {e_r}'(t) = \theta'(t) \vec {e_{\theta}}(t)\\[6pt]
\vec {e_\theta}'(t) = -\theta'(t) \vec {e_r}(t)
\end{cases}
\end{aligned}$$
</p>
<p>
<div class="proof-box">証明</div>
定義より
$\displaystyle \vec e_r(t)=\cos\theta(t)\,\vec e_x + \sin\theta(t)\,\vec e_y$であるから，合成関数の微分法を用いて
$$\begin{aligned}
\vec e_r'(t) &= -\sin\theta(t)\,\theta'(t)\,\vec e_x + \cos\theta(t)\,\theta'(t)\,\vec e_y \\
&= \theta'(t)\bigl(-\sin\theta(t)\vec e_x + \cos\theta(t)\vec e_y\bigr)\\
&= \theta'(t)\,\vec e_{\theta}(t)
\end{aligned}$$
同様に$e_{\theta}(t) = -\sin\theta(t)\,\vec e_x + \cos\theta(t)\,\vec e_y$についても
$$\begin{aligned}
\vec e_{\theta}'(t) &= -\cos\theta(t)\,\theta'(t)\,\vec e_x - \sin\theta(t)\,\theta'(t)\,\vec e_y \\
&= -\theta'(t)\bigl(\cos\theta(t)\vec e_x + \sin\theta(t)\vec e_y\bigr)\\
&= -\theta'(t)\,\vec e_r(t).
\end{aligned}$$
よって命題の等式が成り立つ。
Q.E.D
</p>
<p class="theory-common-box">命題2：等速とは限らない円運動をする質点の速度ベクトルは下記の通りになる。
$$\begin{aligned}
\vec v(t) = \vec r'(t) = R \theta'(t) \vec e_\theta(t)
\end{aligned}$$
</p>
<p>
<div class="proof-box">証明</div>
質点の位置ベクトルは$\vec r(t) = R \vec e_r(t) = R \Bigl( \cos\theta(t)\vec e_x + \sin\theta(t)\vec e_y \Bigr)$
なので、速度ベクトルは Rが定数であることと命題1を用いて
$$\begin{aligned}
\vec v(t) &= \vec r'(t)\\[6pt]
&= \Bigl(R \vec e_r(t)\Bigr)'\\[6pt]
&\underset{Rが定数}{=}  R \vec e_r'(t)\\[6pt]
&\underset{命題1}{=} R \theta'(t) \vec e_\theta(t)
\end{aligned}$$
Q.E.D
</p>


<p class="theory-common-box">命題3：等速とは限らない円運動をする質点の速さ$v(t)$は下記の通りになる。
$$\begin{aligned}
v(t) = R |\theta'(t)|
\end{aligned}$$
</p>
<p>
<div class="proof-box">証明</div>
速さの定義は速度ベクトルの大きさであるので、
$$\begin{aligned}
\displaystyle v(t) &\underset{定義}{=} |\vec v (t)|\\[6pt] 
&\underset{命題2}{=}|R \theta'(t) \vec e_\theta(t)|\\[6pt] 
&\underset{$||$は分配可}{=}|R| |\theta'(t)| |\vec e_\theta(t)|\\[6pt]
&\underset{$R>0$}{=}R |\theta'(t)| |\vec e_\theta(t)|\\[6pt] 
\end{aligned}$$
<br>
$e_\theta(t)$は単位ベクトルで大きさは1なので$\displaystyle v(t) = R |\theta'(t)|$となる。　Q.E.D
</p>

<p class="theory-common-box">命題4：等速とは限らない円運動をする質点の加速度ベクトルは下記の通りになる。
$$\begin{aligned}
\vec a(t) = R \theta''(t) \vec e_\theta(t) - R (\theta'(t))^2 \vec e_r(t)
\end{aligned}$$
</p>
<p>
<div class="proof-box">証明</div>
命題3で得た速度ベクトル$\vec v(t) = R \theta'(t) \vec e_\theta(t)$を微分すれば良い。積の微分と命題1を用いて、
$$\begin{aligned}
\vec a(t) &= \vec v'(t) \\[6pt]
&= \Bigl(R \theta'(t) \vec e_\theta(t)\Bigr)'\\[6pt]
&\underset{積の微分}{=} R \theta''(t) \vec e_\theta(t) + R \theta'(t) \vec e_\theta'(t)\\[6pt]
&\underset{命題1}{=} R \theta''(t) \vec e_\theta(t) - R (\theta'(t))^2 \vec e_r(t)
\end{aligned}$$
Q.E.D
</p>

<p class="theory-common-box">命題5：等速とは限らない円運動をする質点の、円の中心を原点とした時の運動方程式は下記の通り。</p>
$$\begin{aligned}
\begin{cases}
\displaystyle -m \frac {v(t)^2}{R} = F_r\\[6pt]
m R \theta''(t) = F_\theta
\end{cases}
\end{aligned}$$
<p>
<div class="proof-box">証明</div>
運動方程式$\displaystyle m \vec a(t) = \vec F(t)$と命題4より、
$$\begin{aligned} 
\displaystyle &m \vec a(t) = \vec F(t)\\[6pt]
\displaystyle \underset{命題4}{\Leftrightarrow} &- m R (\theta'(t))^2 \vec e_r(t) + m R \theta''(t) \vec e_\theta(t) \\[6pt]
\ \ \ \ \ \ \ \ &= F_r \vec e_r(t) + F_\theta \vec e_\theta(t)
\end{aligned}$$
ここで、ベクトルの各成分を比較すると、命題3：$v(t)= R|\theta'(t)|$を用いて、
$$\begin{aligned}
\begin{cases}
\displaystyle - m R (\theta'(t))^2 = -m \frac{v(t)^2}{R} = F_r\\[6pt]
\displaystyle m R \theta''(t) = F_\theta
\end{cases}
\end{aligned}$$
Q.E.D
</p>
""",
  latexContentEn: r"""
<p class="theory-common-box">Definition of symbols</p>
  <p>
  $\cdot \  \displaystyle F_r\cdots$ radial (centripetal) component of $\vec F$<br>
  $\cdot \ \displaystyle F_\theta \cdots$ angular component of $\vec F$<br>
  $\cdot \ \displaystyle \theta \cdots$ angle of the particle from the $x$-axis<br>
  $\cdot \ \vec r(t) \cdots$ position vector<br>
  $\cdot \ \vec v(t) \cdots$ velocity vector<br>
  $\cdot \ \vec a(t) \cdots$ acceleration vector<br>
  $\cdot \ v(t)=|\vec v(t)|\cdots$ speed
  </p>

<p class="theory-common-box">Definition (radial and angular unit vectors)</p>
Define the radial and angular unit vectors for circular motion by
$$\begin{aligned}
\begin{cases}
\vec e_r(t) = \cos\theta(t)\vec e_x + \sin\theta(t)\vec e_y\\[6pt]
\vec e_{\theta}(t) = -\sin\theta(t)\vec e_x + \cos\theta(t)\vec e_y
\end{cases}
\end{aligned}$$

<p class="theory-common-box">Proposition 1: The time derivatives of the radial and angular unit vectors are
$$\begin{aligned}
\begin{cases}
\vec {e_r}'(t) = \theta'(t) \vec {e_{\theta}}(t)\\[6pt]
\vec {e_\theta}'(t) = -\theta'(t) \vec {e_r}(t)
\end{cases}
\end{aligned}$$
</p>
<p>
<div class="proof-box">Proof</div>
From $\displaystyle \vec e_r(t)=\cos\theta(t)\,\vec e_x + \sin\theta(t)\,\vec e_y$, by the chain rule
$$\begin{aligned}
\vec e_r'(t) &= -\sin\theta(t)\,\theta'(t)\,\vec e_x + \cos\theta(t)\,\theta'(t)\,\vec e_y \\
&= \theta'(t)\bigl(-\sin\theta(t)\vec e_x + \cos\theta(t)\vec e_y\bigr)\\
&= \theta'(t)\,\vec e_{\theta}(t)
\end{aligned}$$
Similarly for $e_{\theta}(t) = -\sin\theta(t)\,\vec e_x + \cos\theta(t)\,\vec e_y$,
$$\begin{aligned}
\vec e_{\theta}'(t) &= -\cos\theta(t)\,\theta'(t)\,\vec e_x - \sin\theta(t)\,\theta'(t)\,\vec e_y \\
&= -\theta'(t)\bigl(\cos\theta(t)\vec e_x + \sin\theta(t)\vec e_y\bigr)\\
&= -\theta'(t)\,\vec e_r(t).
\end{aligned}$$
Q.E.D
</p>
<p class="theory-common-box">Proposition 2: The velocity of a particle in (not necessarily uniform) circular motion is
$$\begin{aligned}
\vec v(t) = \vec r'(t) = R \theta'(t) \vec e_\theta(t)
\end{aligned}$$
</p>
<p>
<div class="proof-box">Proof</div>
With $\vec r(t) = R \vec e_r(t) = R \Bigl( \cos\theta(t)\vec e_x + \sin\theta(t)\vec e_y \Bigr)$
and Proposition 1 ($R$ constant),
$$\begin{aligned}
\vec v(t) &= \vec r'(t)\\[6pt]
&= \Bigl(R \vec e_r(t)\Bigr)'\\[6pt]
&=  R \vec e_r'(t)\\[6pt]
&= R \theta'(t) \vec e_\theta(t)
\end{aligned}$$
Q.E.D
</p>


<p class="theory-common-box">Proposition 3: The speed in (not necessarily uniform) circular motion is
$$\begin{aligned}
v(t) = R |\theta'(t)|
\end{aligned}$$
</p>
<p>
<div class="proof-box">Proof</div>
$$\begin{aligned}
\displaystyle v(t) &= |\vec v (t)|\\[6pt] 
&=|R \theta'(t) \vec e_\theta(t)|\\[6pt] 
&=|R| |\theta'(t)| |\vec e_\theta(t)|\\[6pt]
&=R |\theta'(t)| |\vec e_\theta(t)|\\[6pt] 
\end{aligned}$$
<br>
Since $e_\theta(t)$ is a unit vector, $\displaystyle v(t) = R |\theta'(t)|$.　Q.E.D
</p>

<p class="theory-common-box">Proposition 4: The acceleration in (not necessarily uniform) circular motion is
$$\begin{aligned}
\vec a(t) = R \theta''(t) \vec e_\theta(t) - R (\theta'(t))^2 \vec e_r(t)
\end{aligned}$$
</p>
<p>
<div class="proof-box">Proof</div>
Differentiate $\vec v(t) = R \theta'(t) \vec e_\theta(t)$ using the product rule and Proposition 1:
$$\begin{aligned}
\vec a(t) &= \vec v'(t) \\[6pt]
&= \Bigl(R \theta'(t) \vec e_\theta(t)\Bigr)'\\[6pt]
&= R \theta''(t) \vec e_\theta(t) + R \theta'(t) \vec e_\theta'(t)\\[6pt]
&= R \theta''(t) \vec e_\theta(t) - R (\theta'(t))^2 \vec e_r(t)
\end{aligned}$$
Q.E.D
</p>

<p class="theory-common-box">Proposition 5: With the circle center as the origin, the equation of motion for (not necessarily uniform) circular motion is</p>
$$\begin{aligned}
\begin{cases}
\displaystyle -m \frac {v(t)^2}{R} = F_r\\[6pt]
m R \theta''(t) = F_\theta
\end{cases}
\end{aligned}$$
<p>
<div class="proof-box">Proof</div>
From $m \vec a(t) = \vec F(t)$ and Proposition 4,
$$\begin{aligned} 
\displaystyle &m \vec a(t) = \vec F(t)\\[6pt]
\displaystyle \Leftrightarrow &- m R (\theta'(t))^2 \vec e_r(t) + m R \theta''(t) \vec e_\theta(t) \\[6pt]
\ \ \ \ \ \ \ \ &= F_r \vec e_r(t) + F_\theta \vec e_\theta(t)
\end{aligned}$$
. Comparing components and using Proposition 3, $v(t)= R|\theta'(t)|$,
$$\begin{aligned}
\begin{cases}
\displaystyle - m R (\theta'(t))^2 = -m \frac{v(t)^2}{R} = F_r\\[6pt]
\displaystyle m R \theta''(t) = F_\theta
\end{cases}
\end{aligned}$$
Q.E.D
</p>
"""
);
