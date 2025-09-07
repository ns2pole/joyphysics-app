import '../../model.dart';

final nonUniformCircularMotion = TheoryTopic(
  title: '非等速円運動の運動方程式',
  isNew: false,
  latexContent: r"""
<div class="theory-common-box">記号の定義</div>
  <div style="margin-left: 22px; line-height: 1.5;">
  <p>
  $\cdot \  \displaystyle F_r\cdots\vec F$の向心方向成分f<br>
  $\cdot \ \displaystyle F_\theta \cdots\vec F$の角度方向成分<br>
  $\cdot \ \displaystyle \theta \cdots$質点の$x$軸からの角度<br>
  $\cdot \ \vec r(t) \cdots$質点の位置ベクトル<br>
  $\cdot \ \vec v(t) \cdots$質点の速度ベクトル<br>
  $\cdot \ \vec a(t) \cdots$質点の加速度ベクトル<br>
  $\cdot \ v(t)=|\vec v(t)|\cdots$質点の速さ
  </p>
  </div>

<div class="theory-common-box">定義（動径方向,角度方向単位ベクトル）</div>
下記の通り、円運動の動径方向単位ベクトルと角度方向単位ベクトルを定義する。
\begin{aligned}
\begin{cases}
\vec e_r(t) = \cos\theta(t)\vec e_x + \sin\theta(t)\vec e_y\\[6pt]
\vec e_{\theta}(t) = -\sin\theta(t)\vec e_x + \cos\theta(t)\vec e_y
\end{cases}
\end{aligned}

<div class="theory-common-box">命題1：動径方向,角度方向単位ベクトルの時間微分は下記の通りになる。
\begin{aligned}
\begin{cases}
\vec {e_r}'(t) = \theta'(t) \vec {e_{\theta}}(t)\\[6pt]
\vec {e_\theta}'(t) = -\theta'(t) \vec {e_r}(t)
\end{cases}
\end{aligned}
</div>
<p>
<div class="proof-box">証明</div>
定義より
$\displaystyle \vec e_r(t)=\cos\theta(t)\,\vec e_x + \sin\theta(t)\,\vec e_y$であるから，合成関数の微分法を用いて
\begin{aligned}
\vec e_r'(t) &= -\sin\theta(t)\,\theta'(t)\,\vec e_x + \cos\theta(t)\,\theta'(t)\,\vec e_y \\
&= \theta'(t)\bigl(-\sin\theta(t)\vec e_x + \cos\theta(t)\vec e_y\bigr)\\
&= \theta'(t)\,\vec e_{\theta}(t)
\end{aligned}
同様に$e_{\theta}(t) = -\sin\theta(t)\,\vec e_x + \cos\theta(t)\,\vec e_y$についても
\begin{aligned}
\vec e_{\theta}'(t) &= -\cos\theta(t)\,\theta'(t)\,\vec e_x - \sin\theta(t)\,\theta'(t)\,\vec e_y \\
&= -\theta'(t)\bigl(\cos\theta(t)\vec e_x + \sin\theta(t)\vec e_y\bigr)\\
&= -\theta'(t)\,\vec e_r(t).
\end{aligned}
よって命題の等式が成り立つ。
Q.E.D
</p>
<div class="theory-common-box">命題2：等速とは限らない円運動をする質点の速度ベクトルは下記の通りになる。
\begin{aligned}
\vec v(t) = \vec r'(t) = R \theta'(t) \vec e_\theta(t)
\end{aligned}
</div>
<p>
<div class="proof-box">証明</div>
質点の位置ベクトルは$\vec r(t) = R \vec e_r(t) = R \Bigl( \cos\theta(t)\vec e_x + \sin\theta(t)\vec e_y \Bigr)$
なので、速度ベクトルは Rが定数であることと命題1を用いて
\begin{aligned}
\vec v(t) &= \vec r'(t)\\[6pt]
&= \Bigl(R \vec e_r(t)\Bigr)'\\[6pt]
&\underset{Rが定数}{=}  R \vec e_r'(t)\\[6pt]
&\underset{命題1}{=} R \theta'(t) \vec e_\theta(t)
\end{aligned}
Q.E.D
</p>


<div class="theory-common-box">命題3：等速とは限らない円運動をする質点の速さ$v(t)$は下記の通りになる。
\begin{aligned}
v(t) = R |\theta'(t)|
\end{aligned}
</div>
<p>
<div class="proof-box">証明</div>
速さの定義は速度ベクトルの大きさであるので、
\begin{aligned}
\displaystyle v(t) &\underset{定義}{=} |\vec v (t)|\\[6pt] 
&\underset{命題2}{=}|R \theta'(t) \vec e_\theta(t)|\\[6pt] 
&\underset{$||$は分配可}{=}|R| |\theta'(t)| |\vec e_\theta(t)|\\[6pt]
&\underset{$R>0$}{=}R |\theta'(t)| |\vec e_\theta(t)|\\[6pt] 
\end{aligned}
<br>
$e_\theta(t)$は単位ベクトルで大きさは1なので$\displaystyle v(t) = R |\theta'(t)|$となる。　Q.E.D
</p>

<div class="theory-common-box">命題4：等速とは限らない円運動をする質点の加速度ベクトルは下記の通りになる。
\begin{aligned}
\vec a(t) = R \theta''(t) \vec e_\theta(t) - R (\theta'(t))^2 \vec e_r(t)
\end{aligned}
</div>
<p>
<div class="proof-box">証明</div>
命題3で得た速度ベクトル$\vec v(t) = R \theta'(t) \vec e_\theta(t)$を微分すれば良い。積の微分と命題1を用いて、
\begin{aligned}
\vec a(t) &= \vec v'(t) \\[6pt]
&= \Bigl(R \theta'(t) \vec e_\theta(t)\Bigr)'\\[6pt]
&\underset{積の微分}{=} R \theta''(t) \vec e_\theta(t) + R \theta'(t) \vec e_\theta'(t)\\[6pt]
&\underset{命題1}{=} R \theta''(t) \vec e_\theta(t) - R (\theta'(t))^2 \vec e_r(t)
\end{aligned}
Q.E.D
</p>

<div class="theory-common-box">命題5：等速とは限らない円運動をする質点の、円の中心を原点とした時の運動方程式は下記の通り。</div>
\begin{aligned}
\begin{cases}
\displaystyle -m \frac {v(t)^2}{R} = F_r\\[6pt]
m R \theta''(t) = F_\theta
\end{cases}
\end{aligned}
<p>
<div class="proof-box">証明</div>
運動方程式$\displaystyle m \vec a(t) = \vec F(t)$と命題4より、
\begin{aligned} 
\displaystyle &m \vec a(t) = \vec F(t)\\[6pt]
\displaystyle \underset{命題4}{\Leftrightarrow} &- m R (\theta'(t))^2 \vec e_r(t) + m R \theta''(t) \vec e_\theta(t) \\[6pt]
\ \ \ \ \ \ \ \ &= F_r \vec e_r(t) + F_\theta \vec e_\theta(t)
\end{aligned}
ここで、ベクトルの各成分を比較すると、命題3：$v(t)= R|\theta'(t)|$を用いて、
\begin{aligned}
\begin{cases}
\displaystyle - m R (\theta'(t))^2 = -m \frac{v(t)^2}{R} = F_r\\[6pt]
\displaystyle m R \theta''(t) = F_\theta
\end{cases}
\end{aligned}
Q.E.D
</p>
"""
);
