import '../../model.dart';

final uniformCircularMotion = TheoryTopic(
  title: '等速円運動の運動方程式',
  isNew: false,
  latexContent: r"""
<div class="theory-common-box">記号の定義</div>
  <div style="margin-left: 22px; line-height: 1.5;">
  <p>
  $\cdot \  \displaystyle F_r\cdots\vec F$の向心方向成分<br>
  $\cdot \ \displaystyle F_\theta \cdots\vec F$の角度方向成分<br>
  $\cdot \ \displaystyle \theta(t)=\omega t \cdots$質点の$x$軸からの角度（角速度$\omega$は定数）<br>
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
\vec e_r(t) = \cos(\omega t)\vec e_x + \sin(\omega t)\vec e_y\\[6pt]
\vec e_{\theta}(t) = -\sin(\omega t)\vec e_x + \cos(\omega t)\vec e_y
\end{cases}
\end{aligned}

<div class="theory-common-box">命題1：動径方向,角度方向単位ベクトルの時間微分は下記の通りになる。
\begin{aligned}
\begin{cases}
\vec {e_r}'(t) = \omega \vec {e_{\theta}}(t)\\[6pt]
\vec {e_\theta}'(t) = -\omega \vec e_r(t)
\end{cases}
\end{aligned}
</div>
<p>
<div class="proof-box">証明</div>
定義より
$\displaystyle \vec e_r(t)=\cos(\omega t)\,\vec e_x + \sin(\omega t)\,\vec e_y$であるから，微分すると
\begin{aligned}
\vec e_r'(t) &= -\sin(\omega t)\,\omega\,\vec e_x + \cos(\omega t)\,\omega\,\vec e_y \\
&= \omega\bigl(-\sin(\omega t)\vec e_x + \cos(\omega t)\vec e_y\bigr)\\
&= \omega\,\vec e_{\theta}(t)
\end{aligned}
同様に$e_{\theta}(t) = -\sin(\omega t)\,\vec e_x + \cos(\omega t)\,\vec e_y$についても
\begin{aligned}
\vec e_{\theta}'(t) &= -\cos(\omega t)\,\omega\,\vec e_x - \sin(\omega t)\,\omega\,\vec e_y \\
&= -\omega\bigl(\cos(\omega t)\vec e_x + \sin(\omega t)\vec e_y\bigr)\\
&= -\omega\,\vec e_r(t).
\end{aligned}
よって命題の等式が成り立つ。
Q.E.D
</p>

<div class="theory-common-box">命題2：等速円運動をする質点の速度ベクトルは下記の通りになる。
\begin{aligned}
\vec v(t) = R \omega \vec e_\theta(t)
\end{aligned}
</div>
<p>
<div class="proof-box">証明</div>
質点の位置ベクトルは$\vec r(t) = R \vec e_r(t)$なので、速度ベクトルは Rが定数であることと命題1を用いて
\begin{aligned}
\vec v(t) &= \vec r'(t)\\[6pt]
&= \Bigl(R \vec e_r(t)\Bigr)'\\[6pt]
&= R \vec e_r'(t)\\[6pt]
&\underset{命題1}{=} R \omega \vec e_\theta(t)
\end{aligned}
Q.E.D
</p>

<div class="theory-common-box">命題3：等速円運動をする質点の速さ$v$は$R |\omega|$である。
</div>
<p>
<div class="proof-box">証明</div>
速さの定義は速度ベクトルの大きさであるので、
\begin{aligned}
\displaystyle v(t) &\underset{定義}{=} |\vec v (t)|\\[6pt] 
&= |R \omega \vec e_\theta(t)|\\[6pt] 
&= |R|\,|\omega|\,|\vec e_\theta(t)|\\[6pt]
&\underset{R>0}{=} R　|\omega| |\vec e_\theta(t)|
\end{aligned}
$e_\theta(t)$は単位ベクトルで大きさは1なので、$\displaystyle v(t) = R|\omega|$となる。　Q.E.D
</p>

<div class="theory-common-box">命題4：等速円運動をする質点の加速度ベクトルは下記の通りになる。
\begin{aligned}
\vec a(t) = - R \omega^2 \vec e_r(t)
\end{aligned}
</div>
<p>
<div class="proof-box">証明</div>
命題2で得た速度ベクトル$\vec v(t) = R \omega \vec e_\theta(t)$を微分すれば良い。積の微分と命題1を用いて、
\begin{aligned}
\vec a(t) &= \vec v'(t) \\[6pt]
&= \Bigl(R \omega \vec e_\theta(t)\Bigr)'\\[6pt]
&= R \omega \vec e_\theta'(t)\\[6pt]
&\underset{命題1}{=} R \omega (-\omega \vec e_r(t))\\[6pt]
&= - R \omega^2 \vec e_r(t)
\end{aligned}
Q.E.D
</p>

<div class="theory-common-box">命題5：等速円運動をする質点の、円の中心を原点とした時の運動方程式は下記の通り。
\begin{aligned}
\begin{cases}
\displaystyle -m \frac {v^2}{R} = F_r\\[6pt]
F_\theta = 0
\end{cases}
\end{aligned}
</div><p>
<div class="proof-box">証明</div>
運動方程式$\displaystyle m \vec a(t) = \vec F(t)$と命題4より、
\begin{aligned} 
m \vec a(t) &= m(- R \omega^2 \vec e_r(t))\\[6pt]
&= -m R \omega^2 \vec e_r(t)
\end{aligned}
一方、外力は$\ r, \theta$方向で分解を行うと、$\vec F(t) = F_r \vec e_r(t) + F_\theta \vec e_\theta(t)$である。よって、
運動方程式より、
\begin{aligned} 
-m R \omega^2 \vec e_r(t) &= F_r \vec e_r(t) + F_\theta \vec e_\theta(t)
\end{aligned}
命題3より、$v=R |\omega|$に注意して、$\vec e_r(t),\vec e_\theta(t)\ $の各成分を比較すると、下記を得る。
\begin{aligned}
\begin{cases}
\displaystyle -m R \omega^2 = -m \frac{v^2}{R} = F_r\\[6pt]
F_\theta = 0
\end{cases}
\end{aligned}
Q.E.D
</p>
"""
);
