import '../../model.dart';

final permeability = TheoryTopic(
  title: '磁化, 磁化率, 透磁率, 比透磁率',
  titleEn: 'Magnetization, magnetic susceptibility, permeability, and relative permeability',
  imageAsset: 'assets/mindMap/forTopics/permeability.png',

  latexContent: r"""

<div class="theory-common-box">定義（真空の透磁率：$$\mu_0$s$）</div>
<p>
真空の透磁率は磁気に関する基準定数で、慣用的な値は
$$
\displaystyle \mu_0 \fallingdotseq 4\pi\times 10^{-7}\ \mathrm{H/m}
$$
である（SIでの標準的な定数として扱われる）。真空中では $\vec B=\mu_0\vec H$ が成り立つ。
</p>

<div class="theory-common-box">定義（磁気双極子）</div>
<p>
電流ループや局所的な回転電流が作る磁気的な双極子を <b>磁気双極子</b> と呼ぶ。
</p>

<div class="paragraph-box">性質</div>
<ul>
  <li>単一の磁気双極子は外部磁場 $\vec B$ に対してトルクを受ける：
    $\displaystyle \boldsymbol{\tau}=\vec m\times\vec B$。</li>
</ul>


<div class="theory-common-box">定義（磁化ベクトル：$M$）</div>
<p>磁場を物質に加えると、構成分子の回転電流の向きが揃い、これは磁気双極子として振る舞う。そこで、
単位体積あたりの磁気双極子モーメントを磁化ベクトルといい、$\vec M$で表すこととする。
</p>

<div class="theory-common-box">定義（磁場：$\vec H $）</div>
磁場$\vec H$を磁束密度 $\vec B$ と電場と磁化ベクトル $\vec M$ を用いて下記で定義する。
$$
\vec H = \frac {\vec B - \vec M}{\mu_0}
$$



<div class="theory-common-box">命題（真空における関係式）：
真空では磁束密度 $\vec B$ と磁場の強さ $\vec H$ との関係は下記の通り。
$$
\vec B = \mu_0 \vec H
$$
</div>
<div class="proof-box">証明</div><p>
真空中では、磁化は起きないので、$\vec {M}= \vec 0\ $となる。よって、
$$\begin{aligned}
&\vec H = \frac {\vec B}{\mu_0} \\[6pt]
\Leftrightarrow &  \vec B =  \mu_0 \vec H
\end{aligned}$$
　Q.E.D

<div class="theory-common-box">定義（磁化率：$\chi_m$）</div>
<p>
磁場をかけたときに線形に磁化ベクトルが生じる場合、磁化ベクトルは下記のように表すことができる。
$$
\vec M = \chi_m\,\mu_0\,\vec H
$$
ここで $\chi_m$ は磁化率(または磁気感受率)といい、媒質中の電子や原子の磁気応答の強さを表す。
</p>



<div class="theory-common-box">定理（線形等方媒質における関係式）</div>
線形等方媒質では、磁束密度$\vec B$は磁化 $ \vec {M}$ と磁場$\vec H$を用いて
$\vec B=\mu_0( 1 + \chi_m\,)\vec H$ となる。
<p>
<div class="proof-box">証明</div>
線形等方媒質では、磁束密度の式$ \vec B = \mu_0 \vec H + \vec {M} $と磁化率の式$\displaystyle \vec {M} = \chi_m\,\mu_0\,\vec H$をを合わせると、
$$\begin{aligned}
\vec B &= \mu_0 \vec H+\vec {M} \\[6pt]
&= \mu_0( 1 + \chi_m\,) \vec H \\[6pt]
\end{aligned}$$
が得られる。
</p>


<div class="theory-common-box">定義（透磁率：$\mu$）</div>
上式の$\vec H$の係数
$\mu_0(1+\chi_m)$を(この線形等方媒質の)透磁率といい単に$\mu$で表す。単位はヘンリー毎メートル（$\mathrm{H/m}$）
</p>

<div class="theory-common-box">定義（比透磁率：$\mu_r$）</div>
<p>
$$
\displaystyle \mu_r \equiv \frac{\mu}{\mu_0} = 1+\chi_m
$$
を比透磁率と定義する。真空では $\mu_r=1$ である。
</p>


<div class="theory-common-box">命題（線形媒質中の磁場$\vec H$）：線形媒質の時、上の透磁率、比透磁率の定義を用いると磁束密度$\vec B$は、磁場の強さ$\vec H$を用いて下記のように表すことが出来る。
$$
\displaystyle \vec B = \mu_r \mu_0 \vec H
$$
</div>
<p><div class="proof-box">証明</div>
線形媒質の場合、$\vec B = \mu \vec H\ $であるが、比透磁率の定義より、$\mu = \mu_r \mu_0\  $なので、
$\displaystyle \vec B = \mu \vec H = \mu_r \mu_0 \vec H\ $となる。　Q.E.D
</p>



</p>
""",
  latexContentEn: r"""

<div class="theory-common-box">Definition (vacuum permeability: $\mu_0$)</div>
<p>
The vacuum permeability is the reference magnetic constant; a conventional value is
$$
\displaystyle \mu_0 \fallingdotseq 4\pi\times 10^{-7}\ \mathrm{H/m}
$$
(treated as a standard SI constant). In vacuum $\vec B=\mu_0\vec H$ holds.
</p>

<div class="theory-common-box">Definition (magnetic dipole)</div>
<p>
A magnetic dipole produced by a current loop or a localized circulating current is called a <b>magnetic dipole</b>.
</p>

<div class="paragraph-box">Properties</div>
<ul>
  <li>A single magnetic dipole experiences a torque in an external field $\vec B$:
    $\displaystyle \boldsymbol{\tau}=\vec m\times\vec B$.</li>
</ul>


<div class="theory-common-box">Definition (magnetization vector: $M$)</div>
<p>When a magnetic field is applied to matter, the circulating currents of constituent molecules align and behave as magnetic dipoles.
The magnetic dipole moment per unit volume is the magnetization vector, denoted $\vec M$.
</p>

<div class="theory-common-box">Definition (magnetic field: $\vec H $)</div>
Define the magnetic field $\vec H$ from the magnetic flux density $\vec B$ and the magnetization $\vec M$ by
$$
\vec H = \frac {\vec B - \vec M}{\mu_0}
$$



<div class="theory-common-box">Proposition (relation in vacuum):
In vacuum the relation between $\vec B$ and $\vec H$ is
$$
\vec B = \mu_0 \vec H
$$
</div>
<div class="proof-box">Proof</div><p>
In vacuum there is no magnetization, so $\vec {M}= \vec 0\ $. Hence
$$\begin{aligned}
&\vec H = \frac {\vec B}{\mu_0} \\[6pt]
\Leftrightarrow &  \vec B =  \mu_0 \vec H
\end{aligned}$$
　Q.E.D

<div class="theory-common-box">Definition (magnetic susceptibility: $\chi_m$)</div>
<p>
When the magnetization responds linearly to an applied field, it can be written
$$
\vec M = \chi_m\,\mu_0\,\vec H
$$
where $\chi_m$ is the magnetic susceptibility, measuring the magnetic response of electrons and atoms in the medium.
</p>



<div class="theory-common-box">Theorem (relation in a linear isotropic medium)</div>
In a linear isotropic medium, $\vec B=\mu_0( 1 + \chi_m\,)\vec H$ in terms of magnetization $ \vec {M}$ and $\vec H$.
<p>
<div class="proof-box">Proof</div>
Combining $\vec B = \mu_0 \vec H + \vec {M} $ with $\displaystyle \vec {M} = \chi_m\,\mu_0\,\vec H$ gives
$$\begin{aligned}
\vec B &= \mu_0 \vec H+\vec {M} \\[6pt]
&= \mu_0( 1 + \chi_m\,) \vec H \\[6pt]
\end{aligned}$$
.
</p>


<div class="theory-common-box">Definition (permeability: $\mu$)</div>
The coefficient of $\vec H$ above,
$\mu_0(1+\chi_m)$, is the permeability of the linear isotropic medium, written simply $\mu$. The unit is henry per meter ($\mathrm{H/m}$).
</p>

<div class="theory-common-box">Definition (relative permeability: $\mu_r$)</div>
<p>
$$
\displaystyle \mu_r \equiv \frac{\mu}{\mu_0} = 1+\chi_m
$$
is defined as the relative permeability. In vacuum $\mu_r=1$.
</p>


<div class="theory-common-box">Proposition (magnetic field $\vec H$ in a linear medium): In a linear medium, using the definitions of permeability and relative permeability, $\vec B$ can be written in terms of $\vec H$ as
$$
\displaystyle \vec B = \mu_r \mu_0 \vec H
$$
</div>
<p><div class="proof-box">Proof</div>
In a linear medium $\vec B = \mu \vec H\ $, and by definition $\mu = \mu_r \mu_0\ $, so
$\displaystyle \vec B = \mu \vec H = \mu_r \mu_0 \vec H\ $.　Q.E.D
</p>



</p>
""",
);
// iv class="theory-common-box">定義（磁気双極子）</div>
// <p>
// 電流ループや局所的な回転電流が作る磁気的な双極子を <b>磁気双極子</b> と呼ぶ。
// 小さなループ電流 $I$ と面積ベクトル $\vec A$（右ねじの向きに沿う単位法線ベクトルを向きとする）を持つループの磁気双極子モーメント $\vec m$ は次で与えられる：
// $$
// \vec m = I\,\vec A
// $$
// （単位は A·m$^2$。慣習的に向きは電流の進行方向に右ねじを巻いたときの軸の向き。）
// また連続分布の場合の一般式として
// と書ける。
// </p>