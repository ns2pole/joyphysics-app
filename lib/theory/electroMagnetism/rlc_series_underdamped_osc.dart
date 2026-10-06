import '../../model.dart';

final rlc_series_underdamped_osc = TheoryTopic(
  title: '直列RLC：減衰振動（α<ω₀, v≡0）— alignedは \\[ \\] で囲まない版',
  titleEn: 'Series RLC: underdamped oscillation (α<ω₀, v≡0) — aligned not wrapped in \\[ \\]',
  videoURL: "",
  imageAsset: 'assets/mindMap/forTopics/rlcSeries.png',
  latexContent: r"""

<div class="common-box">記号の定義</div>
\begin{aligned}
R &:= \text{抵抗},\quad
L := \text{インダクタンス},\quad
C := \text{キャパシタンス} \\[4pt]
q(t) &:= \text{コンデンサ電荷},\quad
i(t) := q'(t) \\[6pt]
\alpha &:= {\displaystyle \frac{R}{2L}},\quad
\omega_0 := {\displaystyle \frac{1}{\sqrt{LC}}},\quad
\omega_d := \sqrt{\omega_0^{2}-\alpha^{2}}\ \ (\alpha<\omega_0)
\end{aligned}
<div class="common-box">本記事の対象（微分方程式）</div>
\begin{aligned}
& L\,q''(t) \;+\; R\,q'(t) \;+\; {\displaystyle \frac{1}{C}}\,q(t)
\;= 0
\end{aligned}

<div class="theory-common-box">
命題（置換で調和振動へ帰着）：微分方程式、
$$L\,q'' + R\,q' + {\displaystyle \frac{1}{C}}\,q \;=\; 0\ (\text{ただし}\ \ \alpha<\omega_0,\ v(t)\equiv 0)$$について、
\(q=e^{-\alpha t}u\) とおけば
$\displaystyle u'' + \omega_d^{2}\,u \;=\; 0$
を満たす。
</div>

<div class="proof-box">証明</div>
\begin{aligned}
q
&= e^{-\alpha t}\,u \\[6pt]
q'
&= (e^{-\alpha t})'\,u
\;+\; e^{-\alpha t}\,u' \\[2pt]
&= -\alpha e^{-\alpha t}\,u
\;+\; e^{-\alpha t}\,u' \\[6pt]
q''
&= (-\alpha e^{-\alpha t})'\,u
\;+\; (-\alpha e^{-\alpha t})\,u' \\[2pt]
&\quad +\ (e^{-\alpha t})'\,u'
\;+\; e^{-\alpha t}\,u'' \\[2pt]
&= \alpha^{2}e^{-\alpha t}\,u
\;-\; \alpha e^{-\alpha t}\,u'
\;-\; \alpha e^{-\alpha t}\,u'
\;+\; e^{-\alpha t}\,u'' \\[2pt]
&= e^{-\alpha t}\bigl(u'' - 2\alpha u' + \alpha^{2}u\bigr)
\end{aligned}
\begin{aligned}
& Lq'' + Rq' + {\displaystyle \frac{1}{C}}q \\[6pt]
=\, & L\,e^{-\alpha t}\bigl(u'' - 2\alpha u' + \alpha^{2}u\bigr) \\[2pt]
&\quad +\ R\,e^{-\alpha t}\bigl(u' - \alpha u\bigr)
\ +\ {\displaystyle \frac{1}{C}}\,e^{-\alpha t}u \\[6pt]
\Leftrightarrow\ &
e^{-\alpha t}\Bigl(
L u'' \;+\; (-2L\alpha+R)u' \;+\; (L\alpha^{2}-R\alpha + {\displaystyle \tfrac{1}{C}})u
\Bigr) \\[6pt]
\Leftrightarrow\ &
e^{-\alpha t}\,L\Bigl(
u'' \;+\; \bigl({\displaystyle \tfrac{1}{LC}} - {\displaystyle \tfrac{R^{2}}{4L^{2}}}\bigr)u
\Bigr) \\[6pt]
\Leftrightarrow\ &
e^{-\alpha t}\,L\Bigl(
u'' \;+\; (\omega_0^{2}-\alpha^{2})u
\Bigr) \\[6pt]
\Leftrightarrow\ &
e^{-\alpha t}\,L\Bigl(
u'' \;+\; \omega_d^{2}u
\Bigr)
\end{aligned}
よって、
\begin{aligned}
& Lq'' + Rq' + {\displaystyle \frac{1}{C}}q \;=\; 0 \\[6pt]
\Leftrightarrow\ &
u'' + \omega_d^{2}u \;=\; 0
\end{aligned}
Q.E.D.

<hr>

<div class="theory-common-box">
命題（減衰振動の解の形）：\(\alpha<\omega_0\) のとき，斉次解は下記で表される。
\begin{aligned}
q(t)
&= e^{-\alpha t}\Bigl(
C_1\cos\omega_d t \;+\; C_2\sin\omega_d t
\Bigr)
\end{aligned}
</div>

<div class="proof-box">証明</div>
\begin{aligned}
& u'' + \omega_d^{2}u = 0 \\[6pt]
\Leftrightarrow\ &
u(t)
= C_1\cos\omega_d t \;+\; C_2\sin\omega_d t \\[6pt]
\end{aligned}
よって、
\begin{aligned}
q(t)
= e^{-\alpha t}\,u(t)
= e^{-\alpha t}\Bigl(
C_1\cos\omega_d t \;+\; C_2\sin\omega_d t
\Bigr)
\end{aligned}
Q.E.D.

<hr>

<div class="theory-common-box">
命題（検算：cos・sin 係数の完全導出）：上の \(q(t)\) は下記を満たす。
\begin{aligned}
& L\,q'' \;+\; R\,q' \;+\; {\displaystyle \frac{1}{C}}\,q \;=\; 0
\end{aligned}
</div>

<div class="proof-box">証明</div>
\begin{aligned}
q
&= e^{-\alpha t}\Bigl(
C_1\cos\omega_d t \;+\; C_2\sin\omega_d t
\Bigr) \\[6pt]
q'
&= -\alpha e^{-\alpha t}\Bigl(
C_1\cos\omega_d t \;+\; C_2\sin\omega_d t
\Bigr) \\[2pt]
&\quad +\ e^{-\alpha t}\Bigl(
-\,C_1\omega_d\sin\omega_d t \;+\; C_2\omega_d\cos\omega_d t
\Bigr) \\[6pt]
q''
&= \alpha^{2}e^{-\alpha t}\Bigl(
C_1\cos\omega_d t \;+\; C_2\sin\omega_d t
\Bigr) \\[2pt]
&\quad +\ 2\alpha e^{-\alpha t}\Bigl(
C_1\omega_d\sin\omega_d t \;-\; C_2\omega_d\cos\omega_d t
\Bigr) \\[2pt]
&\quad -\ e^{-\alpha t}\Bigl(
C_1\omega_d^{2}\cos\omega_d t \;+\; C_2\omega_d^{2}\sin\omega_d t
\Bigr)
\end{aligned}

（cos成分の抽出）
\begin{aligned}
L q''\big|_{\cos}
&= L e^{-\alpha t}\Bigl[
(\alpha^{2}-\omega_d^{2})C_1 \;-\; 2\alpha\omega_d C_2
\Bigr]\cos\omega_d t \\[6pt]
R q'\big|_{\cos}
&= R e^{-\alpha t}\Bigl[
-\alpha C_1 \;+\; \omega_d C_2
\Bigr]\cos\omega_d t \\[6pt]
{\displaystyle \frac{1}{C}}q\big|_{\cos}
&= {\displaystyle \frac{1}{C}}\,e^{-\alpha t}\,
C_1\,\cos\omega_d t
\end{aligned}

（sin成分の抽出）
\begin{aligned}
L q''\big|_{\sin}
&= L e^{-\alpha t}\Bigl[
(\alpha^{2}-\omega_d^{2})C_2 \;+\; 2\alpha\omega_d C_1
\Bigr]\sin\omega_d t \\[6pt]
R q'\big|_{\sin}
&= R e^{-\alpha t}\Bigl[
-\alpha C_2 \;-\; \omega_d C_1
\Bigr]\sin\omega_d t \\[6pt]
{\displaystyle \frac{1}{C}}q\big|_{\sin}
&= {\displaystyle \frac{1}{C}}\,e^{-\alpha t}\,
C_2\,\sin\omega_d t
\end{aligned}

（係数方程式）
\begin{aligned}
\text{cos係数}
&= \Bigl[
L(\alpha^{2}-\omega_d^{2})
\;-\; R\alpha
\;+\; {\displaystyle \frac{1}{C}}
\Bigr]C_1
\;+\;
\Bigl[
-\,2L\alpha\omega_d
\;+\; R\omega_d
\Bigr]C_2 \\[8pt]
\text{sin係数}
&= \Bigl[
L(\alpha^{2}-\omega_d^{2})
\;-\; R\alpha
\;+\; {\displaystyle \frac{1}{C}}
\Bigr]C_2
\;+\;
\Bigl[
2L\alpha\omega_d
\;-\; R\omega_d
\Bigr]C_1
\end{aligned}

（\(\alpha={\displaystyle \tfrac{R}{2L}},\ \omega_0^{2}={\displaystyle \tfrac{1}{LC}},\ \omega_d^{2}=\omega_0^{2}-\alpha^{2}\) を代入）
\begin{aligned}
& L(\alpha^{2}-\omega_d^{2}) \;-\; R\alpha \;+\; {\displaystyle \frac{1}{C}} \\[6pt]
= &
L\!\left(\alpha^{2} - (\omega_0^{2}-\alpha^{2})\right)
\ -\ R\alpha
\ +\ {\displaystyle \frac{1}{C}} \\[6pt]
= &
L(2\alpha^{2}-\omega_0^{2})
\ -\ R\alpha
\ +\ {\displaystyle \frac{1}{C}} \\[6pt]
= &
2L\alpha^{2}
\ -\ {\displaystyle \frac{L}{LC}}
\ -\ R\alpha
\ +\ {\displaystyle \frac{1}{C}} \\[6pt]
= &
2L\alpha^{2}
\ -\ {\displaystyle \frac{1}{C}}
\ -\ R\alpha
\ +\ {\displaystyle \frac{1}{C}} \\[6pt]
= &
2L\alpha^{2} \;-\; R\alpha \\[6pt]
= &
\alpha(2L\alpha - R) \\[6pt]
= &
\alpha\!\left(
2L\cdot{\displaystyle \frac{R}{2L}} - R
\right) \\[6pt]
= &
0
\end{aligned}
\begin{aligned}
& -\,2L\alpha\omega_d \;+\; R\omega_d \\[6pt]
= &
\omega_d\bigl(-2L\alpha + R\bigr) \\[6pt]
= &
\omega_d\!\left(
-2L\cdot{\displaystyle \frac{R}{2L}} + R
\right) \\[6pt]
= &
0
\end{aligned}
ゆえに
\begin{aligned}
\text{cos係数} &= 0, \\[2pt]
\text{sin係数} &= 0
\end{aligned}
したがって
\begin{aligned}
& Lq'' + Rq' + {\displaystyle \frac{1}{C}}q \;=\; 0
\end{aligned}
が成り立つ。Q.E.D.

<hr>

<div class="theory-common-box">
命題（初期条件の実装）：\(\alpha<\omega_0\) のとき，
\(q(0)=q_0,\ i(0)=i_0\) を下記で満たす係数は下記となる。
\begin{aligned}
&\begin{cases}
C_1 \;=\; q_0, \\[10pt]
C_2 \;=\; {\displaystyle \frac{i_0 + \alpha q_0}{\omega_d}}
\end{cases}
\end{aligned}
</div>

<div class="proof-box">証明</div>
\begin{aligned}
& q(0)
= e^{0}\Bigl(
C_1\cos 0 \;+\; C_2\sin 0
\Bigr) \\[6pt]
\Leftrightarrow\ &
q_0 = C_1
\end{aligned}
\begin{aligned}
& i(0) = q'(0) \\[4pt]
\Leftrightarrow\ &
-\,\alpha C_1 \;+\; \omega_d C_2 = i(0)\\[4pt]
\Leftrightarrow\ &
\omega_d C_2 = i_0 \;+\; \alpha q_0 \\[4pt]
\Leftrightarrow\ &
C_2 = {\displaystyle \frac{i_0 + \alpha q_0}{\omega_d}}
\end{aligned}
Q.E.D.

<hr>
<div class="theory-common-box">
命題（振幅位相表示）：\(\alpha<\omega_0\) のとき，解は下記で表される。
\begin{aligned}
q(t)
&= e^{-\alpha t}\,Q_m\,\cos(\omega_d t - \delta)
\end{aligned}
ここで \(Q_m,\ \delta,\ T_d\) は下記を満たす（\(C_1=q_0,\ C_2={\displaystyle \frac{i_0+\alpha q_0}{\omega_d}}\) を用いた表示）。
\begin{aligned}
&\begin{cases}
Q_m \;=\; \sqrt{\,q_0^{2} \;+\; {\displaystyle \left(\frac{i_0+\alpha q_0}{\omega_d}\right)^{2}}\,}, \\[10pt]
\delta \;=\; \arctan\!\Bigl(\,{\displaystyle \frac{(i_0+\alpha q_0)/\omega_d}{\;q_0\;}}\,\Bigr), \\[10pt]
T_d \;=\; {\displaystyle \frac{2\pi}{\omega_d}}
\end{cases}
\end{aligned}
</div>

<div class="proof-box">証明</div>
\begin{aligned}
& q(t)
= e^{-\alpha t}\Bigl(
q_0\,\cos\omega_d t
\;+\;
{\displaystyle \frac{i_0+\alpha q_0}{\omega_d}}\,\sin\omega_d t
\Bigr) \\[8pt]
\Leftrightarrow\ &
q(t)
= e^{-\alpha t}\,Q_m\!\left(
{\displaystyle \frac{q_0}{Q_m}}\,\cos\omega_d t
\;+\;
{\displaystyle \frac{(i_0+\alpha q_0)}{\omega_d\,Q_m}}\,\sin\omega_d t
\right) \\[8pt]
\Leftrightarrow\ &
q(t)
= e^{-\alpha t}\,Q_m\!\left(
\cos\delta\,\cos\omega_d t
\;+\;
\sin\delta\,\sin\omega_d t
\right) \\[8pt]
\Leftrightarrow\ &
q(t)
= e^{-\alpha t}\,Q_m\,\cos(\omega_d t - \delta)
\end{aligned}
Q.E.D.

""",
  latexContentEn: r"""

<div class="common-box">Definition of symbols</div>
\begin{aligned}
R &:= \text{resistance},\quad
L := \text{inductance},\quad
C := \text{capacitance} \\[4pt]
q(t) &:= \text{capacitor charge},\quad
i(t) := q'(t) \\[6pt]
\alpha &:= {\displaystyle \frac{R}{2L}},\quad
\omega_0 := {\displaystyle \frac{1}{\sqrt{LC}}},\quad
\omega_d := \sqrt{\omega_0^{2}-\alpha^{2}}\ \ (\alpha<\omega_0)
\end{aligned}
<div class="common-box">Target of this article (differential equation)</div>
\begin{aligned}
& L\,q''(t) \;+\; R\,q'(t) \;+\; {\displaystyle \frac{1}{C}}\,q(t)
\;= 0
\end{aligned}

<div class="theory-common-box">
Proposition (reduction to SHM by substitution): For the differential equation
$$L\,q'' + R\,q' + {\displaystyle \frac{1}{C}}\,q \;=\; 0\ (\text{where}\ \ \alpha<\omega_0,\ v(t)\equiv 0)$$for
\(q=e^{-\alpha t}u\) Set
$\displaystyle u'' + \omega_d^{2}\,u \;=\; 0$
.
</div>

<div class="proof-box">Proof</div>
\begin{aligned}
q
&= e^{-\alpha t}\,u \\[6pt]
q'
&= (e^{-\alpha t})'\,u
\;+\; e^{-\alpha t}\,u' \\[2pt]
&= -\alpha e^{-\alpha t}\,u
\;+\; e^{-\alpha t}\,u' \\[6pt]
q''
&= (-\alpha e^{-\alpha t})'\,u
\;+\; (-\alpha e^{-\alpha t})\,u' \\[2pt]
&\quad +\ (e^{-\alpha t})'\,u'
\;+\; e^{-\alpha t}\,u'' \\[2pt]
&= \alpha^{2}e^{-\alpha t}\,u
\;-\; \alpha e^{-\alpha t}\,u'
\;-\; \alpha e^{-\alpha t}\,u'
\;+\; e^{-\alpha t}\,u'' \\[2pt]
&= e^{-\alpha t}\bigl(u'' - 2\alpha u' + \alpha^{2}u\bigr)
\end{aligned}
\begin{aligned}
& Lq'' + Rq' + {\displaystyle \frac{1}{C}}q \\[6pt]
=\, & L\,e^{-\alpha t}\bigl(u'' - 2\alpha u' + \alpha^{2}u\bigr) \\[2pt]
&\quad +\ R\,e^{-\alpha t}\bigl(u' - \alpha u\bigr)
\ +\ {\displaystyle \frac{1}{C}}\,e^{-\alpha t}u \\[6pt]
\Leftrightarrow\ &
e^{-\alpha t}\Bigl(
L u'' \;+\; (-2L\alpha+R)u' \;+\; (L\alpha^{2}-R\alpha + {\displaystyle \frac{1}{C}})u
\Bigr) \\[6pt]
\Leftrightarrow\ &
e^{-\alpha t}\,L\Bigl(
u'' \;+\; \bigl({\displaystyle \frac{1}{LC}} - {\displaystyle \frac{R^{2}}{4L^{2}}}\bigr)u
\Bigr) \\[6pt]
\Leftrightarrow\ &
e^{-\alpha t}\,L\Bigl(
u'' \;+\; (\omega_0^{2}-\alpha^{2})u
\Bigr) \\[6pt]
\Leftrightarrow\ &
e^{-\alpha t}\,L\Bigl(
u'' \;+\; \omega_d^{2}u
\Bigr)
\end{aligned}
Hence,
\begin{aligned}
& Lq'' + Rq' + {\displaystyle \frac{1}{C}}q \;=\; 0 \\[6pt]
\Leftrightarrow\ &
u'' + \omega_d^{2}u \;=\; 0
\end{aligned}
Q.E.D.

<hr>

<div class="theory-common-box">
Proposition (form of the underdamped solution):\(\alpha<\omega_0\) whenthe homogeneous solution is
\begin{aligned}
q(t)
&= e^{-\alpha t}\Bigl(
C_1\cos\omega_d t \;+\; C_2\sin\omega_d t
\Bigr)
\end{aligned}
</div>

<div class="proof-box">Proof</div>
\begin{aligned}
& u'' + \omega_d^{2}u = 0 \\[6pt]
\Leftrightarrow\ &
u(t)
= C_1\cos\omega_d t \;+\; C_2\sin\omega_d t \\[6pt]
\end{aligned}
Hence,
\begin{aligned}
q(t)
= e^{-\alpha t}\,u(t)
= e^{-\alpha t}\Bigl(
C_1\cos\omega_d t \;+\; C_2\sin\omega_d t
\Bigr)
\end{aligned}
Q.E.D.

<hr>

<div class="theory-common-box">
Proposition (check: full derivation of cos/sin coefficients):the above \(q(t)\) satisfies
\begin{aligned}
& L\,q'' \;+\; R\,q' \;+\; {\displaystyle \frac{1}{C}}\,q \;=\; 0
\end{aligned}
</div>

<div class="proof-box">Proof</div>
\begin{aligned}
q
&= e^{-\alpha t}\Bigl(
C_1\cos\omega_d t \;+\; C_2\sin\omega_d t
\Bigr) \\[6pt]
q'
&= -\alpha e^{-\alpha t}\Bigl(
C_1\cos\omega_d t \;+\; C_2\sin\omega_d t
\Bigr) \\[2pt]
&\quad +\ e^{-\alpha t}\Bigl(
-\,C_1\omega_d\sin\omega_d t \;+\; C_2\omega_d\cos\omega_d t
\Bigr) \\[6pt]
q''
&= \alpha^{2}e^{-\alpha t}\Bigl(
C_1\cos\omega_d t \;+\; C_2\sin\omega_d t
\Bigr) \\[2pt]
&\quad +\ 2\alpha e^{-\alpha t}\Bigl(
C_1\omega_d\sin\omega_d t \;-\; C_2\omega_d\cos\omega_d t
\Bigr) \\[2pt]
&\quad -\ e^{-\alpha t}\Bigl(
C_1\omega_d^{2}\cos\omega_d t \;+\; C_2\omega_d^{2}\sin\omega_d t
\Bigr)
\end{aligned}

(extract cos component)
\begin{aligned}
L q''\big|_{\cos}
&= L e^{-\alpha t}\Bigl[
(\alpha^{2}-\omega_d^{2})C_1 \;-\; 2\alpha\omega_d C_2
\Bigr]\cos\omega_d t \\[6pt]
R q'\big|_{\cos}
&= R e^{-\alpha t}\Bigl[
-\alpha C_1 \;+\; \omega_d C_2
\Bigr]\cos\omega_d t \\[6pt]
{\displaystyle \frac{1}{C}}q\big|_{\cos}
&= {\displaystyle \frac{1}{C}}\,e^{-\alpha t}\,
C_1\,\cos\omega_d t
\end{aligned}

(extract sin component)
\begin{aligned}
L q''\big|_{\sin}
&= L e^{-\alpha t}\Bigl[
(\alpha^{2}-\omega_d^{2})C_2 \;+\; 2\alpha\omega_d C_1
\Bigr]\sin\omega_d t \\[6pt]
R q'\big|_{\sin}
&= R e^{-\alpha t}\Bigl[
-\alpha C_2 \;-\; \omega_d C_1
\Bigr]\sin\omega_d t \\[6pt]
{\displaystyle \frac{1}{C}}q\big|_{\sin}
&= {\displaystyle \frac{1}{C}}\,e^{-\alpha t}\,
C_2\,\sin\omega_d t
\end{aligned}

(coefficient equations)
\begin{aligned}
\text{cos coefficient}
&= \Bigl[
L(\alpha^{2}-\omega_d^{2})
\;-\; R\alpha
\;+\; {\displaystyle \frac{1}{C}}
\Bigr]C_1
\;+\;
\Bigl[
-\,2L\alpha\omega_d
\;+\; R\omega_d
\Bigr]C_2 \\[8pt]
\text{sin coefficient}
&= \Bigl[
L(\alpha^{2}-\omega_d^{2})
\;-\; R\alpha
\;+\; {\displaystyle \frac{1}{C}}
\Bigr]C_2
\;+\;
\Bigl[
2L\alpha\omega_d
\;-\; R\omega_d
\Bigr]C_1
\end{aligned}

（\(\alpha={\displaystyle \frac{R}{2L}},\ \omega_0^{2}={\displaystyle \frac{1}{LC}},\ \omega_d^{2}=\omega_0^{2}-\alpha^{2}\)  substituted)
\begin{aligned}
& L(\alpha^{2}-\omega_d^{2}) \;-\; R\alpha \;+\; {\displaystyle \frac{1}{C}} \\[6pt]
= &
L\!\left(\alpha^{2} - (\omega_0^{2}-\alpha^{2})\right)
\ -\ R\alpha
\ +\ {\displaystyle \frac{1}{C}} \\[6pt]
= &
L(2\alpha^{2}-\omega_0^{2})
\ -\ R\alpha
\ +\ {\displaystyle \frac{1}{C}} \\[6pt]
= &
2L\alpha^{2}
\ -\ {\displaystyle \frac{L}{LC}}
\ -\ R\alpha
\ +\ {\displaystyle \frac{1}{C}} \\[6pt]
= &
2L\alpha^{2}
\ -\ {\displaystyle \frac{1}{C}}
\ -\ R\alpha
\ +\ {\displaystyle \frac{1}{C}} \\[6pt]
= &
2L\alpha^{2} \;-\; R\alpha \\[6pt]
= &
\alpha(2L\alpha - R) \\[6pt]
= &
\alpha\!\left(
2L\cdot{\displaystyle \frac{R}{2L}} - R
\right) \\[6pt]
= &
0
\end{aligned}
\begin{aligned}
& -\,2L\alpha\omega_d \;+\; R\omega_d \\[6pt]
= &
\omega_d\bigl(-2L\alpha + R\bigr) \\[6pt]
= &
\omega_d\!\left(
-2L\cdot{\displaystyle \frac{R}{2L}} + R
\right) \\[6pt]
= &
0
\end{aligned}
Hence
\begin{aligned}
\text{cos coefficient} &= 0, \\[2pt]
\text{sin coefficient} &= 0
\end{aligned}
Therefore
\begin{aligned}
& Lq'' + Rq' + {\displaystyle \frac{1}{C}}q \;=\; 0
\end{aligned}
holds. Q.E.D.

<hr>

<div class="theory-common-box">
Proposition (imposing initial conditions): When \(\alpha<\omega_0\),
the coefficients satisfying \(q(0)=q_0,\ i(0)=i_0\) are as follows.
\begin{aligned}
&\begin{cases}
C_1 \;=\; q_0, \\[10pt]
C_2 \;=\; {\displaystyle \frac{i_0 + \alpha q_0}{\omega_d}}
\end{cases}
\end{aligned}
</div>

<div class="proof-box">Proof</div>
\begin{aligned}
& q(0)
= e^{0}\Bigl(
C_1\cos 0 \;+\; C_2\sin 0
\Bigr) \\[6pt]
\Leftrightarrow\ &
q_0 = C_1
\end{aligned}
\begin{aligned}
& i(0) = q'(0) \\[4pt]
\Leftrightarrow\ &
-\,\alpha C_1 \;+\; \omega_d C_2 = i(0)\\[4pt]
\Leftrightarrow\ &
\omega_d C_2 = i_0 \;+\; \alpha q_0 \\[4pt]
\Leftrightarrow\ &
C_2 = {\displaystyle \frac{i_0 + \alpha q_0}{\omega_d}}
\end{aligned}
Q.E.D.

<hr>
<div class="theory-common-box">
Proposition (amplitude–phase form): When \(\alpha<\omega_0\), the solution is:
\begin{aligned}
q(t)
&= e^{-\alpha t}\,Q_m\,\cos(\omega_d t - \delta)
\end{aligned}
where \(Q_m,\ \delta,\ T_d\) satisfy (using \(C_1=q_0,\ C_2={\displaystyle \frac{i_0+\alpha q_0}{\omega_d}}\)):
\begin{aligned}
&\begin{cases}
Q_m \;=\; \sqrt{\,q_0^{2} \;+\; {\displaystyle \left(\frac{i_0+\alpha q_0}{\omega_d}\right)^{2}}\,}, \\[10pt]
\delta \;=\; \arctan\!\Bigl(\,{\displaystyle \frac{(i_0+\alpha q_0)/\omega_d}{\;q_0\;}}\,\Bigr), \\[10pt]
T_d \;=\; {\displaystyle \frac{2\pi}{\omega_d}}
\end{cases}
\end{aligned}
</div>

<div class="proof-box">Proof</div>
\begin{aligned}
& q(t)
= e^{-\alpha t}\Bigl(
q_0\,\cos\omega_d t
\;+\;
{\displaystyle \frac{i_0+\alpha q_0}{\omega_d}}\,\sin\omega_d t
\Bigr) \\[8pt]
\Leftrightarrow\ &
q(t)
= e^{-\alpha t}\,Q_m\!\left(
{\displaystyle \frac{q_0}{Q_m}}\,\cos\omega_d t
\;+\;
{\displaystyle \frac{(i_0+\alpha q_0)}{\omega_d\,Q_m}}\,\sin\omega_d t
\right) \\[8pt]
\Leftrightarrow\ &
q(t)
= e^{-\alpha t}\,Q_m\!\left(
\cos\delta\,\cos\omega_d t
\;+\;
\sin\delta\,\sin\omega_d t
\right) \\[8pt]
\Leftrightarrow\ &
q(t)
= e^{-\alpha t}\,Q_m\,\cos(\omega_d t - \delta)
\end{aligned}
Q.E.D.

"""
);
