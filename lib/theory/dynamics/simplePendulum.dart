import '../../model.dart';

final simplePendulum = TheoryTopic(
  title: '単振り子の周期',
  isNew: false,
  latexContent: r"""

<div class="theory-common-box">命題(単振り子の周期)：振れ角$\theta(t)$ が十分小さい時、紐の長さが$L$の振り子の周期周期 $T$ は下記で近似できる。
\begin{aligned}
T = 2\pi \sqrt{\frac{L}{g}} \quad [\text{s}]
\end{aligned}
<div style="text-align:center; margin:1em 0;">
  <img src="assets/dynamicsTheory/simplePendulum.png"
       alt=""
       style="max-width:100%; height:auto;" />
</div>
</div>
<div class="proof-box">証明</div>
図より、質点の位置を
\begin{aligned}
x(t) = L\sin\theta(t), \quad y(t) = L\cos\theta(t)
\end{aligned}
とおく。

$\theta(t)$ の関数として、運動ベクトルの成分を時間で微分すると：

\begin{aligned}
\begin{cases}
v_x(t) = \dfrac{dx}{dt} = L\cos\theta(t) \dfrac{d\theta}{dt} \\[6pt]
v_y(t) = \dfrac{dy}{dt} = -L\sin\theta(t) \dfrac{d\theta}{dt}
\end{cases}
\end{aligned}

さらにもう一度微分して加速度ベクトルを得る：
\begin{aligned}
\begin{cases}
a_x(t) = L \left( \dfrac{d^2\theta}{dt^2} \cos\theta(t) - \left( \dfrac{d\theta}{dt} \right)^2 \sin\theta(t) \right) \\[6pt]
a_y(t) = -L \left( \dfrac{d^2\theta}{dt^2} \sin\theta(t) + \left( \dfrac{d\theta}{dt} \right)^2 \cos\theta(t) \right)
\end{cases}
\end{aligned}

一方、物体に働く力の成分は：
\begin{aligned}
\begin{cases}
F_x = -T \sin \theta(t) \\[6pt]
F_y = mg - T \cos \theta(t)
\end{cases}
\end{aligned}

ニュートンの運動方程式 $ma = F$ を用いると、

\begin{aligned}
mL\left( \dfrac{d^2\theta}{dt^2} \cos\theta(t) - \left( \dfrac{d\theta}{dt} \right)^2 \sin\theta(t) \right) &= -T \sin\theta(t) \quad \cdots (1) \\[6pt]
-mL\left( \dfrac{d^2\theta}{dt^2} \sin\theta(t) + \left( \dfrac{d\theta}{dt} \right)^2 \cos\theta(t) \right) &= mg - T \cos\theta(t) \quad \cdots (2)
\end{aligned}

(1)式 $\times \cos\theta(t)$、(2)式 $\times \sin\theta(t)$ として引き算すると張力 $T$ を消去できる：

\begin{aligned}
& \ \ \ \ \ mL \dfrac{d^2\theta}{dt^2} (\cos^2\theta + \sin^2\theta) = -mg\sin\theta(t) \\[6pt]
& \Leftrightarrow mL \dfrac{d^2\theta}{dt^2} = -mg\sin\theta(t) \\[6pt]
& \Leftrightarrow \dfrac{d^2\theta}{dt^2} = -\dfrac{g}{L} \sin\theta(t)
\end{aligned}

ここで $\theta(t)$ が十分小さいと仮定し、$\displaystyle \sin\theta(t) \approx \theta(t)$と近似すれば、
\begin{aligned}
\dfrac{d^2\theta}{dt^2} = -\dfrac{g}{L} \theta(t)
\end{aligned}
となる。これは単振動の微分方程式であり、角振動数 $\omega$ と周期$T$はそれぞれ、
\begin{aligned}
\omega = \sqrt{\dfrac{g}{L}} \quad [\text{rad/s}],\ \ T = \dfrac{2\pi}{\omega} = 2\pi \sqrt{\dfrac{L}{g}} \quad [\text{s}]
\end{aligned}

"""
);


// <div class="theory-common-box">位置エネルギーの定義</div>

// 保存力の定義から、$\displaystyle - \int_{\overrightarrow a \to \overrightarrow b} \overrightarrow{F}(\overrightarrow{r}) \cdot \frac {d \overrightarrow{r}}{dt} dt$
// は$\overrightarrow a$から$\overrightarrow b$への経路によらず値が定まる。この値を地点$\overrightarrow a$を基準とした地点$\overrightarrow b$の<b>位置エネルギー</b>という。
// <br>
// ※同じ経路をとった場合、速度にも依存しないことは、置換積分で示すことができる。

// <div class="theory-common-box">力学的エネルギーの定義</div>
// 基準を任意に定めた時の、位置エネルギーと運動エネルギーの和を<b>力学的エネルギー</b>という。


// <div class="theory-common-box">命題：力学的エネルギーは時間によらず一定である</div>
// <div class="proof-box">証明</div>

// 力学的エネルギー$\displaystyle E = \frac12 m |\overrightarrow v|^2 + U_{\overrightarrow a}(\overrightarrow r)$
// を時間で微分して$0$になる事を示す。

// 経路$\overrightarrow r(t)$上で、質点の運動方程式$m \overrightarrow a = \overrightarrow F$を用いると、
// \begin{aligned}
// \ \ \ &\left( \frac12 m |\overrightarrow v|^2 + U_{\overrightarrow a}(\overrightarrow r) \right)'\\[6pt][6pt]
// &=  \frac12 m \left(\overrightarrow v \cdot \overrightarrow v\right)' +  U_{\overrightarrow a}(\overrightarrow r)'\\[6pt][6pt]
// &= m \overrightarrow a \cdot \overrightarrow v +  U_{\overrightarrow a}(\overrightarrow r)'\\[6pt][6pt]
// &= \overrightarrow F \cdot \overrightarrow v - \overrightarrow F \cdot \overrightarrow v\\[6pt][6pt]
// &= 0
// \end{aligned}
// よって力学的エネルギーは保存される。Q.E.D