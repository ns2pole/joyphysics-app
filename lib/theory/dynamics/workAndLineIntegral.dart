import '../../model.dart';

final workAndLineIntegral = TheoryTopic(
  title :  '定義および命題',
  latexContent :  r"""
<div class="theory-common-box">一定の力かつ直線的な動きの場合の仕事の定義</div>

一定の力 $ \vec F $ を受けて，物体が直線的に$\Delta \vec x$動く時、力が質点にする仕事$W$ を下記で定義する。
\[
W = |\vec F| | \Delta \vec x| \cos\theta  = \vec F \cdot  \vec x
\]
※ここで、$ \theta $は力と質点の運動方向と力のなす角


<div class="theory-common-box">一般の仕事計算(線積分)の定義</div>
一般に向き,大きさが変化する力ベクトルを受けて，物体が曲線を描いて動く時、力が質点にする仕事 $W$ を下記で定義する。

\begin{aligned}
\quad \int_C \vec F\cdot d\vec r
&:= \lim_{| P | \to 0}
\sum_{i=1}^{N(P)} (\vec F_i\cdot\vec\tau_i)\,\Delta s_i \\[4pt] 
&\;\Bigl(= \lim_{| P | \to 0}
\sum_{i=1}^{N(P)} |\vec F_i|\cos\theta_i\,\Delta s_i\Bigr)
\end{aligned}

<div class="paragraph-box">記号</div>
<ul>
  <li> $ P = \{t_0 < t_1 < \cdots < t_N \}$ : 分割
<li> $N(P)$ : 分割の個数</li>
  <li>  $ | P| := \displaystyle \max_i |t_i-t_{i-1}| $ : メッシュ(最も大きい区間幅)
  <li> $\Delta s_i$ :  $i$番目区間の弧の長さ
  <li> $\vec F_i$ : $i$番目区間の弧の代表点でのベクトル場 $ \vec F $
  <li> $\vec\tau_i$ : $i$番目区間の弧の代表点での単位接線ベクトル
  <li> $\theta_i$ : $ \vec F_i $ と $ \vec\tau_i $ のなす角
  <li> $\vec F_i\cdot\vec\tau_i\,\Delta s_i,\ |\vec F_i|\cos\theta_i\,\Delta s_i$: $i$番目区間の弧での$\vec F$による仕事の近似値
</ul>


<div class="theory-common-box">命題：曲線 $C$ 上で $ |\vec F|$ が一定値$F$を取り、かつ接ベクトルとなす角が曲線上で一定 $ \theta $ のとき，曲線の長さを$L$とすると、
\[
\int_C \vec F\cdot d\vec r = F\cos\theta\cdot L
\]
</div>
<p><div class="proof-box">証明</div>
定義より
\[
\int_C \vec F\cdot d\vec r = \lim_{| P | \to 0}\sum_{i=1}^{N(P)} (\vec F_i\cdot\vec\tau_i)\,\Delta s_i.
\]
各代表点で $ |\vec F_i|=F$, $\vec F_i\cdot\vec\tau_i=F\cos\theta$ なので
\begin{aligned}
\sum_{i=1}^{N(P)} (\vec F_i\cdot\vec\tau_i)\,\Delta s_i
&= F\cos\theta \sum_{i=1}^{N(P)}\Delta s_i \\[5pt]
&= F \cos \theta \cdot L
\end{aligned}
よって、
\begin{aligned}
\int_C \vec F\cdot d\vec r
&= \lim_{| P | \to 0} \Bigl( F \cos \theta \cdot L\Bigr)\\[5pt]
&= F \cos \theta \cdot L
\end{aligned}
Q.E.D
</p>
"""
);