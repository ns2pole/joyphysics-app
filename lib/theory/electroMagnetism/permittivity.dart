import '../../model.dart';

final permittivity = TheoryTopic(
  title: '分極, 電気感受率, 誘電率, 比誘電率',
  titleEn: 'Polarization, electric susceptibility, permittivity, and relative permittivity',
  imageAsset: 'assets/mindMap/forTopics/permittivity.png',

  latexContent: r"""

<div class="theory-common-box">定義（真空の誘電率：$\varepsilon_0$）</div>
<p>
真空の誘電率は電磁定数の一つで、SI単位系における値は近似的に
$$
\displaystyle \varepsilon_0 \fallingdotseq 8.854\,187\,817\times 10^{-12}\ \mathrm{F/m}
$$
である。
</p>


<div class="theory-common-box">定義（電気双極子）</div>
<p>
2つの大きさが等しく符号が反対の点電荷 $+q$, $-q$ が分離ベクトル $\vec d$ だけ隔てられて存在するとき、
その組を電気双極子という。慣習として分離ベクトル $\vec d$ は負電荷から正電荷へ向かう向きに取り、
電気双極子モーメント $\vec p$ は
$$
\vec p = q \vec d
$$
で定義される（単位は $C\cdot m$ ）。
</p>

<div class="theory-common-box">定義（分極）</div>
<p>
外部から電場を加えると，誘電体中の分子や原子において，電子雲が核に対してわずかに変位し，
正電荷と負電荷の重心がずれる。この現象を分極という。（分極の結果，誘電体の各分子や原子には電気双極子が誘起される。）
</p>

<div class="theory-common-box">定義（分極ベクトル）</div>
<p>
誘電体に電場を掛けると、誘電体中の構成分子が分極を起こし、電気双極子が発生する。そこで、単位体積あたりの電気双極子モーメントを分極ベクトルという。
</p>


<div class="theory-common-box">定義（電気感受率：$\chi_e\ $）</div>
<p>
誘電体にかけた電場に応じて線形に分極ベクトルが生じる時、分極ベクトルは下記のように表すことができる。
$$
\displaystyle \vec P = \chi_e\,\varepsilon_0\,\vec E
$$
ここで $\chi_e$ は電気感受率といい、媒質中の双極子応答の強さを表す。
</p>

<div class="theory-common-box">定義（電束密度）</div>
電束密度 $\vec D$ を電場と分極ベクトル $\vec P$ を用いて下記で定義する。
$$
\vec D = \varepsilon_0 \vec E + \vec P
$$


<div class="theory-common-box">命題（真空中の電束密度）：
真空では電束密度と電場の関係は下記の通り。
$$
\vec D = \varepsilon_0 \vec E
$$  
</div>
<div class="proof-box">証明</div>
真空では分極が起きないので、$\vec P = \vec 0\ $となり直ちに得られる。 Q.E.D
</p>

<div class="theory-common-box">定義（誘電率：$\varepsilon$）</div>
<p>
電束密度の定義$\vec D=\varepsilon_0\vec E+\vec P$ と電気感受率の式$\vec P = \chi_e \varepsilon_0 \vec E$を合わせると、線形等方媒質では
$$\begin{aligned}
\vec D &= \varepsilon_0\vec E+\vec P\\[6pt]
 &=\varepsilon_0\vec E + \chi_e\,\varepsilon_0\,\vec E\\[6pt]
&= \varepsilon \vec E \quad ;\ \varepsilon=\varepsilon_0(1+\chi_e)
\end{aligned}$$
が得られる。この$\varepsilon$を媒質の誘電率という。単位はファラド毎メートル（$\mathrm{F/m}$）。
</p>

<div class="theory-common-box">定義（比誘電率：$\varepsilon_r$）</div>
<p>
$$
\displaystyle \varepsilon_r \equiv \frac{\varepsilon}{\varepsilon_0} = 1+\chi_e
$$
を比誘電率という。真空では $\varepsilon_r=1$ である。
</p>


<div class="theory-common-box">命題（線形媒質中の電場$\vec E$）：線形媒質の時、上の透磁率、比透磁率の定義を用いると磁束密度$\vec B$は、磁場の強さ$\vec H$を用いて下記のように表すことが出来る。
$$
\displaystyle \vec D = \varepsilon_r \varepsilon_0 \vec E
$$
</div>
<p><div class="proof-box">証明</div>
線形媒質の場合、$\vec D = \varepsilon \vec E\ $であるが、比透磁率の定義より、$\varepsilon = \varepsilon_r \varepsilon_0\  $なので、
$\displaystyle \vec D = \varepsilon \vec E = \varepsilon_r \varepsilon_0 \vec E\ $となる。　Q.E.D
</p>

""",
  latexContentEn: r"""

<div class="theory-common-box">Definition (vacuum permittivity: $\varepsilon_0$)</div>
<p>
The vacuum permittivity is an electromagnetic constant; in SI units its approximate value is
$$
\displaystyle \varepsilon_0 \fallingdotseq 8.854\,187\,817\times 10^{-12}\ \mathrm{F/m}
$$
.
</p>


<div class="theory-common-box">Definition (electric dipole)</div>
<p>
When two point charges $+q$ and $-q$ of equal magnitude and opposite sign are separated by a displacement vector $\vec d$,
the pair is an electric dipole. By convention $\vec d$ points from the negative to the positive charge, and the electric dipole moment $\vec p$ is
$$
\vec p = q \vec d
$$
(unit: $C\cdot m$).
</p>

<div class="theory-common-box">Definition (polarization)</div>
<p>
When an external electric field is applied, electron clouds in molecules or atoms of a dielectric shift slightly relative to the nuclei,
so the centers of positive and negative charge separate. This phenomenon is polarization. (As a result, an electric dipole is induced in each molecule or atom.)
</p>

<div class="theory-common-box">Definition (polarization vector)</div>
<p>
When an electric field is applied to a dielectric, its constituent molecules polarize and electric dipoles appear. The electric dipole moment per unit volume is called the polarization vector.
</p>


<div class="theory-common-box">Definition (electric susceptibility: $\chi_e\ $)</div>
<p>
When the polarization vector responds linearly to the applied field, it can be written
$$
\displaystyle \vec P = \chi_e\,\varepsilon_0\,\vec E
$$
where $\chi_e$ is the electric susceptibility, measuring the strength of the dipole response in the medium.
</p>

<div class="theory-common-box">Definition (electric displacement)</div>
Define the electric displacement $\vec D$ from the electric field and the polarization $\vec P$ by
$$
\vec D = \varepsilon_0 \vec E + \vec P
$$


<div class="theory-common-box">Proposition (electric displacement in vacuum):
In vacuum the relation between $\vec D$ and $\vec E$ is
$$
\vec D = \varepsilon_0 \vec E
$$  
</div>
<div class="proof-box">Proof</div>
In vacuum there is no polarization, so $\vec P = \vec 0\ $, and the result follows at once. Q.E.D
</p>

<div class="theory-common-box">Definition (permittivity: $\varepsilon$)</div>
<p>
Combining $\vec D=\varepsilon_0\vec E+\vec P$ with $\vec P = \chi_e \varepsilon_0 \vec E$, in a linear isotropic medium one obtains
$$\begin{aligned}
\vec D &= \varepsilon_0\vec E+\vec P\\[6pt]
 &=\varepsilon_0\vec E + \chi_e\,\varepsilon_0\,\vec E\\[6pt]
&= \varepsilon \vec E \quad ;\ \varepsilon=\varepsilon_0(1+\chi_e)
\end{aligned}$$
. This $\varepsilon$ is the permittivity of the medium. The unit is farad per meter ($\mathrm{F/m}$).
</p>

<div class="theory-common-box">Definition (relative permittivity: $\varepsilon_r$)</div>
<p>
$$
\displaystyle \varepsilon_r \equiv \frac{\varepsilon}{\varepsilon_0} = 1+\chi_e
$$
is the relative permittivity. In vacuum $\varepsilon_r=1$.
</p>


<div class="theory-common-box">Proposition (electric field $\vec E$ in a linear medium): In a linear medium, using the definitions above, the electric displacement can be written in terms of $\vec E$ as
$$
\displaystyle \vec D = \varepsilon_r \varepsilon_0 \vec E
$$
</div>
<p><div class="proof-box">Proof</div>
In a linear medium $\vec D = \varepsilon \vec E\ $, and by definition $\varepsilon = \varepsilon_r \varepsilon_0\ $, so
$\displaystyle \vec D = \varepsilon \vec E = \varepsilon_r \varepsilon_0 \vec E\ $.　Q.E.D
</p>

""",
);
