import '../../model.dart';

final ampereMaxwellLaw = TheoryTopic(
  title: 'アンペール–マクスウェルの法則',
  latexContent: r"""


<div class="theory-common-box">定義（電束）</div>
<p>
電束（電束密度の面積分）を
\[
\Psi_E := \iint_S \vec D\cdot d\vec S
\]
と定義する。
</p>


<div class="theory-common-box">定義（変位電流）</div>
<p>
電束 \(\Psi_E:=\iint_S\vec D\cdot d\vec S\) の時間微分 \(\dfrac{d\Psi_E}{dt}\) を変位電流という。
</p>

<div class="theory-common-box">アンペール–マクスウェルの法則（積分形）</div>
<p>
「自由電流と変位電流が仮想磁荷に対する磁場が行う周回仕事を生じさせる」<br>
この法則をアンペール–マクスウェルの法則といい、下式で表される。
\[
\oint_{\partial S} \vec{H}\cdot d\vec{r}
= I_{\mathrm{自由}}(S) + \frac{d}{dt}\iint_S \vec{D}\cdot d\vec{S}.
\]
ここで \(\vec D\) は電束密度である。
面 \(S\) の法線ベクトル \(\vec{n}\) と境界 \(\partial S\) の積分方向は右手則で連動して決める。
</p>




<div class="theory-common-box">補足：仮想磁荷に対する仕事</div>
<p>
磁場 \(\vec H\) に沿った周回積分
\[
\oint_{\partial S} \vec H\cdot d\vec r
\]
はアンペールマクスウェルの法則によって生じる磁場$\vec H$が仮想的な単位磁荷に対してする周回仕事を表す。
</p>

<div class="theory-common-box">定理：アンペールの法則</div>
<p>
電場が時間的に変化しない場合（\(\partial\vec D/\partial t=0\)）には変位電流項が消え、アンペールの法則の形に還元される：
\[
\oint_{\partial S}\vec H\cdot d\vec r = I_{\mathrm{自由}}(S).
\]
</p>

<div class="theory-common-box">定義（光速：真空中 \(c\)）</div>
<p>
真空中の光速は真空の誘電率と透磁率から決まり、
\[
\displaystyle c=\frac{1}{\sqrt{\varepsilon_0\mu_0}}\approx 2.99792458\times10^{8}\ \mathrm{m/s}
\]
である（SIにおける光速の定義値に一致する）。
</p>

<div class="theory-common-box">定義（光速：媒質中 \(v\)）</div>
<p>
線形・等方媒質中の電磁波の位相速度は媒質の誘電率・透磁率に依存し、
\[
\displaystyle v=\frac{1}{\sqrt{\varepsilon\,\mu}}=\frac{c}{\sqrt{\varepsilon_r\,\mu_r}}
\]
で与えられる。実際には周波数依存（分散）や損失により \(\varepsilon,\mu\) は複素値になり得るため、厳密には位相速度・群速度・減衰率を区別して扱う必要がある。
</p>

""",
);
// <div class="theory-common-box">補足（磁場のエネルギー）</div>
// <p>
// 線形媒質において、磁場に蓄えられる単位体積当たりのエネルギー密度は
// \[
// w_{\mathrm{mag}} = \tfrac{1}{2}\vec B\cdot\vec H
// \]
// で与えられる。全エネルギーはこれを体積積分することで求められる。
// </p>