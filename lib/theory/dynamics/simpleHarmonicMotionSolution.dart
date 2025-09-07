import '../../model.dart';

final simpleHarmonicMotionSolution = TheoryTopic(
  title: '単振動の運動方程式の解',
  isNew: true,
  latexContent: r"""
<div class="theory-common-box">命題（単振動の運動方程式の解）：
運動方程式$mx''(t)= -kx(t)$の解は下記である。
\begin{aligned}
x(t) = A\sin \Bigl(\sqrt {\frac{k}{m}}t + C\Bigr)
\end{aligned}
（\(E,C\) は初期位置と初期速度で決まる定数）
</div>

<p><div class="proof-box">証明</div>
エネルギー保存則より
$\displaystyle E = \frac{1}{2}mx'(t)^2 + \frac {1}{2}k x(t)^2$
は時間によらない定数である。この式の両辺を$E$で割って
\begin{aligned}
1 &=  \displaystyle \frac{x'(t)^2}{\frac{2E}{m}} + \displaystyle \frac{x(t)^2}{\frac{2E}{k}} \\[6pt]
\end{aligned}
これは楕円の方程式であるから、媒介変数 \(\psi\) を用いて
\begin{aligned}
\begin{cases}
x(t) = \displaystyle \sqrt{\frac{2E}{k}} \sin \psi(t), \\[6pt]
x'(t) = \displaystyle \sqrt{\frac{2E}{m}} \cos \psi(t)\  \cdots (1)
\end{cases}
\end{aligned}
上式の両辺を微分して
\begin{aligned}
x'(t) &= \psi '(t)\,\sqrt {\frac{2E}{k}}\cos\psi(t) \cdots (2)
\end{aligned}
これが下式と一致することから
\begin{aligned}
\sqrt {\frac{2E}{m}}\cos\psi(t) = \psi '(t)\,\sqrt {\frac{2E}{k}}\cos\psi(t) \\[6pt]
\end{aligned}
両辺が一致するには
\[\Rightarrow \psi '(t) = \sqrt{\frac{k}{m}}\]
であることが必要。(十分性については下記の補足を参照。)
従って$\ C$を積分定数として、
\begin{aligned}
\psi(t)=\sqrt{\frac{k}{m}}t + C,
\end{aligned}
ゆえに
\begin{aligned}
x(t) &= \sqrt { \frac{2E}{k}} \sin\psi(t)\\[6pt]
&= \sqrt { \frac{2E}{k}}\sin\Bigl(\sqrt {\frac{k}{m}}t + C\Bigr).
\end{aligned}
ここで改めて、$\displaystyle \frac{2E}{k}$を$A$と置くと、解の表式である下記を得る。
\[
x(t) = A\sin \Bigl(\sqrt {\frac{k}{m}}t + C\Bigr)
\]
Q.E.D</p>

<div class="theory-common-box">命題（$\psi(t)$の関数形）：$\psi(t)$が狭義単調連続関数ならば
\begin{aligned}
\sqrt {\frac{2E}{m}}\cos\psi(t) &= \psi '(t)\,\sqrt {\frac{2E}{k}}\cos\psi(t) \\[6pt]
\Rightarrow \psi '(t) &= \sqrt{\frac{k}{m}}
\end{aligned}
が成り立つ。</div>
<p><div class="proof-box">証明</div>
下記の補題により、$\cos\psi(t)=0$ となる時刻は孤立点となり$\psi(t)$の連続性により自然に埋めることができ、任意の$t$で
$\displaystyle \psi(t)=\sqrt{\frac{k}{m}}t + C\ $（Cは積分定数）を得られる。 したがって、$\displaystyle \psi '(t) = \sqrt{\frac{k}{m}}$が成り立つ。  Q.E.D
</p>
<div class="theory-common-box">補題：関数 $\psi(t)$ が連続で狭義単調（単調増加または単調減少）であるなら，
$\cos\psi(t)=0$ を満たす時刻$t$は孤立点である．
</div>
<p><div class="proof-box">証明</div>
$\displaystyle \cos\psi(t)=0$ は $\displaystyle \psi(t)=\frac{\pi}{2}+n\pi\ (\text{nは整数})$ に同値である．<br>
$\psi$ が狭義単調かつ連続ならば，任意の定数 $\alpha$ に対して方程式
$\psi(t)=\alpha$
は高々1つの解しか持たない。<br>
したがってある時刻 $t_0$ で $\displaystyle \psi(t_0)=\frac{\pi}{2}+n\pi$ が成り立つならば，
近傍の任意の $\displaystyle t\neq t_0$ では $\displaystyle \psi(t)\neq\frac{\pi}{2}+n\pi$ である．<br>
すなわち $\cos\psi(t)\neq0$ が $t_0$ の十分小さい近傍で成り立つので，
$t_0$ は孤立点である．　Q.E.D
</p>
"""
);