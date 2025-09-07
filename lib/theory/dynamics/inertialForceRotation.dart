import '../../model.dart';

final inertialForceRotation = TheoryTopic(
  isNew: false,
  title: '慣性系に対し一定の角速度で回転する座標系から見た時の慣性力',
  latexContent: r"""

<div class="theory-common-box">命題：一定の角速度 $\omega$ で回転する座標系で見たときの質量 $m$ の質点の座標を $(\tilde{x}(t), \tilde{y}(t))$,質点に働く力の成分を$(\tilde{F}_x(t), \tilde{F}_y(t))$とすると、この座標系で成立する運動方程式は下記の通り。
\begin{aligned}
\begin{cases}
m\tilde{x}''(t) = \tilde{F}_x(t) + 2m\omega \tilde{y}'(t) + m\omega^2 \tilde{x}(t) \\[6pt]
m\tilde{y}''(t) = \tilde{F}_y(t) - 2m\omega \tilde{x}'(t) + m\omega^2 \tilde{y}(t)
\end{cases}
\end{aligned}
</div>
<p>
<div class="proof-box">証明</div>
慣性系の基底ベクトルを $\vec{e}_x, \vec{e}_y, \vec{e}_z$ とする。

回転している基底ベクトルは、角度 $\theta(t) = \omega t$ として次のように定義される：
\begin{aligned}
\begin{cases}
\vec{\tilde{e}}_x(t) = \cos(\omega t)\vec{e}_x + \sin(\omega t)\vec{e}_y \\[6pt]
\vec{\tilde{e}}_y(t) = -\sin(\omega t)\vec{e}_x + \cos(\omega t)\vec{e}_y \\[6pt]
\vec{\tilde{e}}_z = \vec{e}_z
\end{cases}
\end{aligned}

その時間微分は：
\begin{aligned}
\begin{cases}
\vec{\tilde{e}}_x'(t) = -\omega \sin(\omega t)\vec{e}_x + \omega \cos(\omega t)\vec{e}_y = \omega \vec{\tilde{e}}_y(t) \\[6pt]
\vec{\tilde{e}}_y'(t) = -\omega \cos(\omega t)\vec{e}_x - \omega \sin(\omega t)\vec{e}_y = -\omega \vec{\tilde{e}}_x(t) \\[6pt]
\vec{e}_z' = 0
\end{cases}
\end{aligned}

物体の位置ベクトル $\vec{r}(t)$ は以下のように両座標系で表せる：
\begin{aligned}
\vec{r}(t) = x(t)\vec{e}_x + y(t)\vec{e}_y = \tilde{x}(t)\vec{\tilde{e}}_x(t) + \tilde{y}(t)\vec{\tilde{e}}_y(t)
\end{aligned}

これを時間微分すると速度ベクトルになる：
\begin{aligned}
\vec{r}'(t) = (\tilde{x}'(t) - \omega \tilde{y}(t))\vec{\tilde{e}}_x(t) + (\omega \tilde{x}(t) + \tilde{y}'(t))\vec{\tilde{e}}_y(t)
\end{aligned}

さらに微分して加速度ベクトルを得る：
\begin{aligned}
\ \ \ \ \ \vec{r}''(t) &= (\tilde{x}''(t) - 2\omega \tilde{y}'(t) - \omega^2 \tilde{x}(t))\vec{\tilde{e}}_x(t) \\[3pt]
&+ (\tilde{y}''(t) + 2\omega \tilde{x}'(t) - \omega^2 \tilde{y}(t))\vec{\tilde{e}}_y(t)\\[8pt]
\Leftrightarrow m\vec{r}''(t) &= m(\tilde{x}''(t) - 2\omega \tilde{y}'(t) - \omega^2 \tilde{x}(t))\vec{\tilde{e}}_x(t) \\[3pt]
&+ m(\tilde{y}''(t) + 2\omega \tilde{x}'(t) - \omega^2 \tilde{y}(t))\vec{\tilde{e}}_y(t) \ \ \cdots(1) \\[8pt]
\end{aligned}

慣性系におけるニュートンの運動方程式より
\begin{aligned}
m\vec{r}''(t) = \vec{F}(t)
\end{aligned}
ここで、$\vec {F}(t)$を回転座標系の基底で分解すると
$\displaystyle \vec {F}(t) = \tilde{F}_x(t)\vec{\tilde{e}}_x(t) + \tilde{F}_y(t)\vec{\tilde{e}}_y(t)$となるので、
\begin{aligned}
m\vec{r}''(t) = \displaystyle \vec {F}(t) = \tilde{F}_x(t)\vec{\tilde{e}}_x(t) + \tilde{F}_y(t)\vec{\tilde{e}}_y(t)\ \ \cdots(2)
\end{aligned}
よって(1)(2)式より、下記の式が成立する。
\begin{aligned}
\ \ \ &m(\tilde{x}''(t) - 2\omega \tilde{y}'(t) - \omega^2 \tilde{x}(t))\vec{\tilde{e}}_x(t) \\[5pt]
 + \ &m(\tilde{y}''(t) + 2\omega \tilde{x}'(t) - \omega^2 \tilde{y}(t))\vec{\tilde{e}}_y(t) \\[5pt]
 &\ \ = \tilde{F}_x(t)\vec{\tilde{e}}_x(t) + \tilde{F}_y(t)\vec{\tilde{e}}_y(t)
\end{aligned}

ベクトルの成分を比較すると：
\begin{aligned}
&\begin{cases}
m\tilde{x}''(t) - 2m\omega \tilde{y}'(t) - m\omega^2 \tilde{x}(t) = \tilde{F}_x(t)\\[6pt]
m\tilde{y}''(t) + 2m\omega \tilde{x}'(t) - m\omega^2 \tilde{y}(t) = \tilde{F}_y(t) 
\end{cases}
\\[8pt]
\Leftrightarrow
& \begin{cases}
m\tilde{x}''(t) = \tilde{F}_x(t) + 2m\omega \tilde{y}'(t) + m\omega^2 \tilde{x}(t) \\[6pt]
m\tilde{y}''(t) = \tilde{F}_y(t) - 2m\omega \tilde{x}'(t) + m\omega^2 \tilde{y}(t)
\end{cases}\\[6pt]
\ \ \ \ &\text{Q.E.D}\end{aligned}
</p>
<div class="theory-common-box">定義：コリオリ力</div>
右辺第2項：$2m\omega \tilde{y}'(t),\ \ -2m\omega \tilde{x}'(t)$ をコリオリ力と言う。<br>
<div class="theory-common-box">定義：遠心力</div>
右辺第3項：$m\omega^2 \vec {F}(t)\tilde{x}(t),\ \ m\omega^2 \tilde{y}(t)$ を遠心力と言う。
"""
);
