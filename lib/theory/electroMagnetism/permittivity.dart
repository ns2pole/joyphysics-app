import '../../model.dart';

final permittivity = TheoryTopic(
  title: '分極, 電気感受率, 誘電率, 比誘電率',
  latexContent: r"""

<div class="theory-common-box">定義（真空の誘電率：\(\varepsilon_0\)）</div>
<p>
真空の誘電率は電磁定数の一つで、SI単位系における値は近似的に
\[
\displaystyle \varepsilon_0 \approx 8.854\,187\,817\times 10^{-12}\ \mathrm{F/m}
\]
である。
</p>

<div class="theory-common-box">定義（電気感受率：\(\chi_e\ \)）</div>
<p>
電気感受率は媒質の分極が電場にどれだけ比例するかを表す無次元係数であり、線形媒質では分極ベクトル \(\vec P\) は電場 \(\vec E\) に対して次のように与えられる：
\[
\displaystyle \vec P = \chi_e\,\varepsilon_0\,\vec E
\]
ここで \(\chi_e\) は電気感受率で、媒質中の双極子応答の強さを表す。
</p>
<div class="theory-common-box">定義（電束密度）</div>
電束密度 \(\vec D\) を電場と分極ベクトル \(\vec P\) を用いて下記で定義する。
\[
\vec D = \varepsilon_0 \vec E + \vec P
\]

<div class="theory-common-box">命題（真空中の電束密度）：
真空では電束密度と電場の関係は下記の通り。
\[
\vec D = \varepsilon_0 \vec E
\]  
</div>
<div class="proof-box">証明</div>
真空では分極が起きないので、$\vec P = \vec 0\ $となり直ちに得られる。 Q.E.D
</p>

<div class="theory-common-box">定義（誘電率：\(\varepsilon\)）</div>
<p>
電束密度の定義\(\vec D=\varepsilon_0\vec E+\vec P\) と電気感受率の式\(\vec P = \chi_e \varepsilon_0 \vec E\)を合わせると、線形等方媒質では
\begin{aligned}
\vec D &= \varepsilon_0\vec E+\vec P\\[5pt]
 &=\varepsilon_0\vec E + \chi_e\,\varepsilon_0\,\vec E\\[5pt]
&= \varepsilon \vec E \quad ;\ \varepsilon=\varepsilon_0(1+\chi_e)
\end{aligned}
が得られる。この\(\varepsilon\)を媒質の誘電率という。単位はファラド毎メートル（\(\mathrm{F/m}\)）。
</p>

<div class="theory-common-box">定義（比誘電率：\(\varepsilon_r\)）</div>
<p>
\[
\displaystyle \varepsilon_r \equiv \frac{\varepsilon}{\varepsilon_0} = 1+\chi_e
\]
を比誘電率という。真空では \(\varepsilon_r=1\) である。
</p>

""",
);
