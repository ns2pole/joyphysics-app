import '../../model.dart';

final twoDimPolarCoordinatesEqOfMotion = TheoryTopic(
  title: '極座標運動方程式(2次元）',
  isNew: true,
  imageAsset: 'assets/mindMap/forTopics/twoDimPolarCoordinatesEqOfMotion.png',
  latexContent: r"""
<div class="theory-common-box">記号の定義</div>
  <div style="margin-left: 22px; line-height: 1.5;">
  <p>
  $\cdot \  \displaystyle F_r\cdots\vec F$の動径（向心）方向成分<br>
  $\cdot \ \displaystyle F_\theta \cdots\vec F$の角度（接線）方向成分<br>
  $\cdot \ \displaystyle \theta(t) \cdots$ 質点の$x$軸からの角度<br>
  $\cdot \ \vec r(t) \cdots$ 質点の位置ベクトル<br>
  $\cdot \ \vec v(t) \cdots$ 質点の速度ベクトル<br>
  $\cdot \ \vec a(t) \cdots$ 質点の加速度ベクトル<br>
  $\cdot \ v(t)=|\vec v(t)|\cdots$ 質点の速さ
  </p>
  </div>

<div class="theory-common-box">定義（動径方向,角度方向単位ベクトル）</div>
下記の通り、動径方向単位ベクトルと角度方向単位ベクトルを定義する。
$$\begin{aligned}
\begin{cases}
\vec e_r(t) = \cos\theta(t)\vec e_x + \sin\theta(t)\vec e_y\\[6pt]
\vec e_{\theta}(t) = -\sin\theta(t)\vec e_x + \cos\theta(t)\vec e_y
\end{cases}
\end{aligned}$$

<div class="theory-common-box">命題1：動径方向,角度方向単位ベクトルの時間微分は下記の通りになる。
$$\begin{aligned}
\begin{cases}
\vec {e_r}'(t) = \theta'(t) \vec {e_{\theta}}(t)\\[6pt]
\vec {e_\theta}'(t) = -\theta'(t) \vec {e_r}(t)
\end{cases}
\end{aligned}$$
</div>
<p>
<div class="proof-box">証明</div>
定義より
$\displaystyle \vec e_r(t)=\cos\theta(t)\,\vec e_x + \sin\theta(t)\,\vec e_y$であるから，合成関数の微分法を用いて
$$\begin{aligned}
\vec e_r'(t) &= -\sin\theta(t)\,\theta'(t)\,\vec e_x + \cos\theta(t)\,\theta'(t)\,\vec e_y \\
&= \theta'(t)\bigl(-\sin\theta(t)\vec e_x + \cos\theta(t)\vec e_y\bigr)\\
&= \theta'(t)\,\vec e_{\theta}(t)
\end{aligned}$$
同様に、$e_{\theta}(t) = -\sin\theta(t)\,\vec e_x + \cos\theta(t)\,\vec e_y$についても
$$\begin{aligned}
\vec e_{\theta}'(t) &= -\cos\theta(t)\,\theta'(t)\,\vec e_x - \sin\theta(t)\,\theta'(t)\,\vec e_y \\
&= -\theta'(t)\bigl(\cos\theta(t)\vec e_x + \sin\theta(t)\vec e_y\bigr)\\
&= -\theta'(t)\,\vec e_r(t).
\end{aligned}$$
よって命題の等式が成り立つ。　Q.E.D
</p>

<div class="theory-common-box">命題2：一般の動径$r(t)$の場合の速度ベクトルは下記の通りになる。
$$\begin{aligned}
\vec v(t) = r'(t)\,\vec e_r(t) + r(t)\,\theta'(t)\,\vec e_\theta(t)
\end{aligned}$$</div>
<p>
<div class="proof-box">証明</div>
質点の位置ベクトルは$\vec r(t) = r(t)\,\vec e_r(t) = r(t)\bigl(\cos\theta(t)\vec e_x + \sin\theta(t)\vec e_y\bigr)$
なので、速度ベクトルは積の微分と命題1を用いて
$$\begin{aligned}
\vec v(t) &= \vec r'(t)\\[6pt]
&= \bigl(r(t)\,\vec e_r(t)\bigr)'\\[6pt]
&= r'(t)\,\vec e_r(t) + r(t)\,\vec e_r'(t)\\[6pt]
&\underset{\text{命題1}}{=} r'(t)\,\vec e_r(t) + r(t)\,\theta'(t)\,\vec e_\theta(t)
\end{aligned}$$
Q.E.D
</p>

<div class="theory-common-box">命題3：一般の動径$r(t)$の場合の速さ$v(t)$は下記の通りになる。
$$\begin{aligned}
v(t) = \sqrt{\bigl(r'(t)\bigr)^2 + \bigl(r(t)\,\theta'(t)\bigr)^2}
\end{aligned}$$</div>
<p>
<div class="proof-box">証明</div>
速さの定義は速度ベクトルの大きさであるので、
$$\begin{aligned}
\displaystyle v(t) &\underset{定義}{=} |\vec v (t)|\\[5pt] 
&\underset{命題2}{=} \sqrt{\bigl(r'(t)\bigr)^2 + \bigl(r(t)\,\theta'(t)\bigr)^2}
\end{aligned}$$
（ここで $\vec e_r$ と $ \vec e_\theta$ は直交単位ベクトルで大きさは1であり、互いの内積は0であることを用いた。）Q.E.D
</p>

<div class="theory-common-box">命題4：一般の動径$r(t)$の場合の加速度ベクトルは下記の通りになる。
（整理して）
$$\begin{aligned}
\vec a(t) &= \Bigl(r''(t)- r(t)\,(\theta'(t))^2\Bigr)\,\vec e_r(t) \\[7pt]
&+ \Bigl(r(t)\,\theta''(t) + 2 r'(t)\,\theta'(t)\Bigr)\,\vec e_\theta(t)
\end{aligned}$$
</div>
<p>
<div class="proof-box">証明</div>
命題2で得た速度ベクトル$\vec v(t) = r'(t)\,\vec e_r(t) + r(t)\,\theta'(t)\,\vec e_\theta(t)$を微分すればよい。積の微分と命題1を用いて、
$$\begin{aligned}
\vec a(t) &= \vec v'(t) \\[6pt]
&= \bigl(r''(t)\,\vec e_r(t) + r'(t)\,\vec e_r'(t)\bigr) + \bigl(r'(t)\,\theta'(t)\,\vec e_\theta(t) + r(t)\,\theta''(t)\,\vec e_\theta(t) + r(t)\,\theta'(t)\,\vec e_\theta'(t)\bigr)\\[6pt]
&= r''(t)\,\vec e_r(t) + r'(t)\,\theta'(t)\,\vec e_\theta(t) + r'(t)\,\theta'(t)\,\vec e_\theta(t) + r(t)\,\theta''(t)\,\vec e_\theta(t) - r(t)\,(\theta'(t))^2\,\vec e_r(t)\\[6pt]
&= \bigl(r''(t)- r(t)\,(\theta'(t))^2\bigr)\,\vec e_r(t) + \bigl(r(t)\,\theta''(t) + 2 r'(t)\,\theta'(t)\bigr)\,\vec e_\theta(t).
\end{aligned}$$
Q.E.D
</p>

<div class="theory-common-box">命題5：一般の動径$r(t)$の場合の、円の中心を原点とした時の運動方程式は下記の通り。</div>
$$\begin{aligned}
\begin{cases}
\displaystyle m\bigl(r''(t)- r(t)\,(\theta'(t))^2\bigr) = F_r\\[6pt]
\displaystyle m\bigl(r(t)\,\theta''(t) + 2 r'(t)\,\theta'(t)\bigr) = F_\theta
\end{cases}
\end{aligned}$$
<p>
<div class="proof-box">証明</div>
運動方程式$\displaystyle m \vec a(t) = \vec F(t)$と命題4より、
$$\begin{aligned} 
\displaystyle &m \vec a(t) = \vec F(t)\\[6pt]
\displaystyle \underset{命題4}{\Leftrightarrow} &m\bigl(r''(t)- r(t)\,(\theta'(t))^2\bigr)\,\vec e_r(t) + m\bigl(r(t)\,\theta''(t) + 2 r'(t)\,\theta'(t)\bigr)\,\vec e_\theta(t) \\[6pt]
&= F_r \vec e_r(t) + F_\theta \vec e_\theta(t)
\end{aligned}$$
ここで、ベクトルの各成分を比較すれば命題の成分方程式が得られる。Q.E.D
</p>

<div class="theory-common-box">補足1：$r(t)=R$ （一定）の場合</div>
命題5の一般式に $r(t)=R$ を代入すると、$r'=r''=0$ であるため、速度と加速度は
$$\begin{aligned}
\begin{cases}
\vec v(t) &= R\,\theta'(t)\,\vec e_{\theta}(t), \\
\vec a(t) &= -R\,\bigl(\theta'(t)\bigr)^2\,\vec e_r(t) + R\,\theta''(t)\,\vec e_{\theta}(t),
\end{cases}
\end{aligned}$$
となり非等速円運動の運動方程式に帰着する。
<div class="theory-common-box">補足2：$r(t)=R$ （一定）かつ、$\theta(t)=\omega t$ （$\omega$は一定値）の場合</div>
補足1の一般式に $\theta(t)=\omega t$ を代入すると、$\theta'(t)=\omega$,$\theta''(t)=0$となり、速度と加速度は
$$\begin{aligned}
\begin{cases}
\vec v(t) &= R\,\omega\,\vec e_{\theta}(t), \\
\vec a(t) &= -R\,\bigl(\omega\bigr)^2\,\vec e_r(t)
\end{cases}
\end{aligned}$$
となり等速円運動の運動方程式に帰着する。
"""
);
