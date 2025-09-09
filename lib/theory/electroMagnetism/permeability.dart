import '../../model.dart';

final permeability = TheoryTopic(
  title: '磁化, 磁化率(磁気感受率), 透磁率, 比透磁率',
  latexContent: r"""

<div class="theory-common-box">定義（真空の透磁率：\(\mu_0\)）</div>
<p>
真空の透磁率は磁気に関する基準定数で、慣用的な値は
\[
\displaystyle \mu_0 \approx 4\pi\times 10^{-7}\ \mathrm{H/m}
\]
である（SIでの標準的な定数として扱われる）。真空中では \(\vec B=\mu_0\vec H\) が成り立つ。
</p>

<div class="theory-common-box">定義（磁化率：\(\chi_m\)）</div>
<p>
磁化率は媒質の磁化 \(\vec M\) が磁場強度 \(\vec H\) に対してどれだけ比例するかを表す無次元係数で、線形媒質では
\[
\displaystyle \vec M = \chi_m\,\vec H
\]
と表される。\(\chi_m\) は磁気応答（磁気双極子あるいは配向応答）の強さを示し、磁気感受率とも呼ばれる。
</p>


<div class="theory-common-box">定理（線形等方媒質における関係式）</div>
媒質を考慮する場合、磁束密度$\vec B$は磁化 \(\vec M\) と磁場$\vec H$を用いて
\(\vec B=\mu_0(\vec H+\vec M)\) となる。
</p>

<div class="theory-common-box">定義（透磁率：\(\mu\)）</div>
<p>
線形等方媒質では、磁束密度の式\( \vec B = \mu_0( \vec H+\vec M \)と磁化率の式$\displaystyle \vec M = \chi_m\,\vec H$をを合わせると、
\begin{aligned}
\vec B &= \mu_0( \vec H+\vec M) \\[5pt]
&= \mu_0( \vec H+ \chi_m\,\vec H) \\[5pt]
&= \mu\vec H \quad ;\ \mu=\mu_0(1+\chi_m)
\end{aligned}が得られる。
この、\(\mu=\mu_0(1+\chi_m)\)を線形等方媒質の透磁率という。単位はヘンリー毎メートル（\(\mathrm{H/m}\)）
</p>



<div class="theory-common-box">定理（真空における関係式）：
真空では磁束密度 \(\vec B\) と磁場の強さ \(\vec H\) との関係は下記の通り。
\[
\vec B = \mu_0 \vec H
\]
</div>

<p><div class="proof-box">証明</div>
真空中では、磁化は起きないので、$\vec M= \vec 0\ $となり直ちに命題の式を得る。
Q.E.D
</p>

<div class="theory-common-box">定義（比透磁率：\(\mu_r\)）</div>
<p>
\[
\displaystyle \mu_r \equiv \frac{\mu}{\mu_0} = 1+\chi_m
\]
を比透磁率と定義する。真空では \(\mu_r=1\) である。
</p>
""",
);
