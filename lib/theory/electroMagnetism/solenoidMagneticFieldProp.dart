import '../../model.dart';
import '../../model.dart';
final solenoidMagneticFieldProp = TheoryTopic(
  title: '無限に長いソレノイドコイルに流れる電流の作る磁場(真空中)',
  titleEn: 'Magnetic field of a current in an infinitely long solenoid (in vacuum)',
  imageAsset: 'assets/mindMap/forTopics/solenoidMagneticFieldProp.png',
  latexContent: r"""
  <div style="text-align:center; margin:1em 0;">
    <img src="assets/electroMagnetismTheory/initSolenoid.png"
      alt="理想ソレノイド"
      style="max-width:95%; height:auto;" />
  </div>

  <div class="condition-box">条件と記号</div>
  <ul>
    <li>空間は真空</li>
    <li>半径 $a$、巻数密度 $n\,[\text{/m}]$、電流 $I\,[\text{A}]$ の無限に長い理想ソレノイド</li>
    <li>系は $z$ 軸まわりの回転対称かつ $z$ 方向に並進対称</li>
    <li>変位電流は無視</li>
    <li>単位ベクトル $\hat{\mathbf r},\ \hat{\boldsymbol\phi},\ \hat{\mathbf z}$ を用いる</li>
    <li>磁場を $\overrightarrow H=H_r(r,\phi,z)\,\hat{\mathbf r}+H_\phi(r,\phi,z)\,\hat{\boldsymbol\phi}+H_z(r,\phi,z)\,\hat{\mathbf z}$ とする</li>
  </ul>
    <div style="text-align:center; margin:1em 0;">
      <img src="assets/electroMagnetismTheory/idealSolenoidCoodinate.png"
        alt=""
        style="max-width:95%; height:auto;" />
    </div>
  <div class="theorem-box">
  定理（理想ソレノイドの磁場）：
  $$\begin{aligned}
  \overrightarrow H(r)=
    \begin{cases}
      nI \hat{\mathbf z} : r < a \\
      \vec {0}  : r > a
    \end{cases}
  \end{aligned}$$
  </div>
  この定理を、命題1〜命題6を示し用いることで証明する。
  <br><br>

  <div class="theory-common-box">命題1：磁場成分は半径 $r$ のみの関数で、$\displaystyle
    \overrightarrow H=H_r(r)\,\hat{\mathbf r}+H_\phi(r)\,\hat{\boldsymbol\phi}+H_z(r)\,\hat{\mathbf z}
  $ と書ける</div>
  <div class="proof-box">証明</div>
  系は回転対称かつ $z$ 方向に並進対称。よって任意の点での場は $\phi, z$ に依らず、各成分は $r$ のみの関数となる。<br>$\square$

  <div class="theory-common-box">命題2：同心円柱（半径 $r$, 高さ $L$）を閉曲面とすると、$ \displaystyle \oint_A \overrightarrow H\cdot d\overrightarrow A = 2\pi r L\, H_r(r)$</div>
  <div style="text-align:center; margin:1em 0;">
    <img src="assets/electroMagnetismTheory/idealSolenoid_cylinder.png"
      alt="円柱ガウス面"
      style="max-width:95%; height:auto;" />
  </div>
  <div class="proof-box">証明</div>
  上下面は $z$ 成分のみ、側面は $r$ 成分のみが効く。上下面の寄与は命題1より貫く方向が逆であるだけなので、互いに打ち消し合い、側面は側面積と $H_r(r)$ の積となるので式の通り。<br>$\square$

  <div class="theory-common-box">命題3：任意の $r$ で $H_r(r)=0$</div>
  <div class="proof-box">証明</div>
  磁場のガウスの法則より $\displaystyle \oint_A \overrightarrow H\cdot d\overrightarrow A = 0$。命題2を用いて
  $2\pi r L\,H_r(r)=0 \Leftrightarrow H_r(r)=0$。<br>$\square$

  <div class="theory-common-box">命題4：任意の $r$ で $H_\phi(r)=0$</div>
  <div style="text-align:center; margin:1em 0;">
    <img src="assets/electroMagnetismTheory/idealSolenoidLoop4.png"
      alt=""
      style="max-width:95%; height:auto;" />
  </div>
  <div class="proof-box">証明</div>
  半径 $r$ の同心円周を積分経路とする。境界面が張る任意の開曲面を取ると、電流はこの面を貫かないため、
  $\displaystyle \oint_C \overrightarrow H\cdot d\overrightarrow l = H_\phi(r)\,2\pi r = 0\Leftrightarrow H_\phi(r)=0$
  <br>$\square$
  
  <div class="theory-common-box">命題5：ソレノイド内部の $H_z(r)$ は場所によらず一定</div>
  <div style="text-align:center; margin:1em 0;">
    <img src="assets/electroMagnetismTheory/idealSolenoidLoop5.png"
        alt="長方形ループ（内部）"
        style="max-width:95%; height:auto;" />
  </div>
<div class="proof-box">証明</div>
$rz$ 平面内で、ソレノイド表面を跨がないように、ソレノイド内部で長方形ループを取る。<br>
この時ループが囲む電流は $0$ である。したがってアンペールの法則の積分形から
$$
\oint_C \overrightarrow H \cdot d\overrightarrow l = 0.
$$
また、この長方形のループについて，垂直辺の$r$の値を$r_1,r_2 \< a$とすると、$H_r=0$であることから、縦辺の赤の部分の線積分のみが寄与して
$$
\oint_C \overrightarrow H \cdot d\overrightarrow l
  = H_z(r_2)\,L - H_z(r_1)\,L.
$$
よって
$$\begin{aligned}
H_z(r_2)-H_z(r_1) &=0 \\
\Leftrightarrow \quad H_z(r_1)&=H_z(r_2).
\end{aligned}$$
$r_1,r_2 < a$ は任意なので，ソレノイド内部では
$$
H_z^{(\mathrm{in})}(r)=\text{定数}. \quad\square
$$

<div class="theory-common-box">命題6：ソレノイド外部の $H_z(r)$ は場所によらず一定</div>
  <div style="text-align:center; margin:1em 0;">
    <img src="assets/electroMagnetismTheory/idealSolenoidLoop6.png"
        alt="長方形ループ（外部）"
        style="max-width:95%; height:auto;" />
  </div>
<div class="proof-box">証明</div>
$rz$ 平面内で、ソレノイド表面を跨がないように、ソレノイド外部で長方形ループを取る。<br>
この時ループが囲む電流は $0$ である。したがってアンペールの法則の積分形から
$$
\oint_C \overrightarrow H \cdot d\overrightarrow l = 0.
$$
また、この長方形のループについて，垂直辺の$r$の値を$r_1,r_2 \> a$とすると、$H_r=0$であることから、縦辺の赤の部分の線積分のみが寄与して
$$
\oint_C \overrightarrow H \cdot d\overrightarrow l
  = H_z(r_2)\,L - H_z(r_1)\,L,
$$
従って
$$\begin{aligned}
H_z(r_2)-H_z(r_1) &=0 \\
\Leftrightarrow \quad H_z(r_1)&=H_z(r_2).
\end{aligned}$$
$r_1,r_2 \> a $ は任意なので，外部でも
$$
H_z^{(\mathrm{out})}(r)=\text{定数}. \quad\square
$$

<div class="theory-common-box">命題7：ソレノイド内部と外部の $H_z$ の差は $nI$ である</div>
<div style="text-align:center; margin:1em 0;">
  <img src="assets/electroMagnetismTheory/idealSolenoidLoop7.png"
       alt="長方形ループ（円筒面を跨ぐ）"
       style="max-width:95%; height:auto;" />
</div>
<div class="proof-box">証明</div>
$rz$ 平面内で、ソレノイド表面を跨ぐように、長方形ループを取る。<br>
この時ループが囲む電流は $nI\ell $ である。したがってアンペールの法則の積分形から
$$
\oint_C \overrightarrow H \cdot d\overrightarrow l = nI\ell .
$$
また、この長方形のループについて，垂直辺の$r$の値をそれぞれ$r_1 \< a ,r_2 > a$とすると、$H_r=0$であることから、縦辺の赤の部分の線積分のみが寄与して

$$
\oint_C \overrightarrow H \cdot d\overrightarrow l
  = H_z(r_2)\,L - H_z(r_1)\,L,
$$
従って、
$$\begin{aligned}
H_z(r_2)\ell  - H_z(r_1)\ell &= nI\ell. \\
\Leftrightarrow H_z(r_2)  - H_z(r_1) &= nI 
\end{aligned}$$
$r_1 \< a,r_2\> a $ は任意なので，内部と外部の$z$方向磁場の大きさの差が$nI$であることが示された。
<br>$\square$
<div class="theory-common-box">命題8：無限遠境界条件により外部の磁場は 0</div>
<div class="proof-box">証明</div>
無限遠境界条件として
$$
\lim_{r\to\infty} |\overrightarrow H(r)| = 0
$$
を課すと（物理的に場は遠方で消える），命題6 より外部の磁場は全域で同じ定数であるから，その定数は 0 である：
$$
H_z^{(\mathrm{out})}=0. \quad\square
$$

<div class="theory-common-box">命題9：命題7 と 命題8 からソレノイド内部の磁場は $nI$ である</div>
<div class="proof-box">証明</div>
命題7 より
$$
H_z^{(\mathrm{in})}-H_z^{(\mathrm{out})}=nI,
$$
命題8 より $H_z^{(\mathrm{out})}=0$ なので，
$$
H_z^{(\mathrm{in})}=nI.
$$
したがって
$$
\overrightarrow H^{(\mathrm{in})}=nI\,\hat{\mathbf z},\qquad\square
$$


  <div class="theorem-box">定理：理想ソレノイドの磁場</div>
  <div class="proof-box">証明</div>
  命題3・命題4より $H_r=H_\phi=0$。命題8と命題9より下記が従う。
$$\begin{aligned}
  \overrightarrow H(r)=
    \begin{cases}
      nI \hat{\mathbf z} : r < a \\
      \vec {0}  : r > a
    \end{cases}
  \end{aligned}$$
  $\square$
 <br> 
  <div class="remark-box">補足</div><br>
    磁束密度は $\mathbf B=\mu_0\mathbf H$（真空）なので、下記の通りとなる。
    $$\begin{aligned}
    \overrightarrow B(r)=
      \begin{cases}
        \mu_0 nI \hat{\mathbf z} : r < a \\
        \vec {0}  : r > a
      \end{cases}
    \end{aligned}$$
  """,
  latexContentEn: r"""
  <div style="text-align:center; margin:1em 0;">
    <img src="assets/electroMagnetismTheory/initSolenoid.png"
      alt="ideal solenoid"
      style="max-width:95%; height:auto;" />
  </div>

  <div class="condition-box">Assumptions and notation</div>
  <ul>
    <li>Space is vacuum</li>
    <li>Infinitely long ideal solenoid of radius $a$, turn density $n\,[\text{/m}]$, current $I\,[\text{A}]$</li>
    <li>Rotational symmetry about $z$ and translational symmetry in $z$</li>
    <li>Displacement current neglected</li>
    <li>Unit vectors $\hat{\mathbf r},\ \hat{\boldsymbol\phi},\ \hat{\mathbf z}$</li>
    <li>Magnetic field $\overrightarrow H=H_r(r,\phi,z)\,\hat{\mathbf r}+H_\phi(r,\phi,z)\,\hat{\boldsymbol\phi}+H_z(r,\phi,z)\,\hat{\mathbf z}$</li>
  </ul>
    <div style="text-align:center; margin:1em 0;">
      <img src="assets/electroMagnetismTheory/idealSolenoidCoodinate.png"
        alt=""
        style="max-width:95%; height:auto;" />
    </div>
  <div class="theorem-box">
  Theorem (magnetic field of an ideal solenoid):
  $$\begin{aligned}
  \overrightarrow H(r)=
    \begin{cases}
      nI \hat{\mathbf z} : r < a \\
      \vec {0}  : r > a
    \end{cases}
  \end{aligned}$$
  </div>
  We prove this using Propositions 1–9.
  <br><br>

  <div class="theory-common-box">Proposition 1: Field components depend only on $r$: $\displaystyle
    \overrightarrow H=H_r(r)\,\hat{\mathbf r}+H_\phi(r)\,\hat{\boldsymbol\phi}+H_z(r)\,\hat{\mathbf z}
  $</div>
  <div class="proof-box">Proof</div>
  Rotational and $z$-translational symmetry imply independence of $\phi,z$; each component is a function of $r$ alone.<br>$\square$

  <div class="theory-common-box">Proposition 2: For a closed concentric cylinder (radius $r$, height $L$), $ \displaystyle \oint_A \overrightarrow H\cdot d\overrightarrow A = 2\pi r L\, H_r(r)$</div>
  <div style="text-align:center; margin:1em 0;">
    <img src="assets/electroMagnetismTheory/idealSolenoid_cylinder.png"
      alt="cylindrical Gaussian surface"
      style="max-width:95%; height:auto;" />
  </div>
  <div class="proof-box">Proof</div>
  Top/bottom contribute only via $H_z$ (and cancel by opposite orientation); the side contributes area times $H_r(r)$.<br>$\square$

  <div class="theory-common-box">Proposition 3: $H_r(r)=0$ for any $r$</div>
  <div class="proof-box">Proof</div>
  Gauss's law for $\overrightarrow H$: $\displaystyle \oint_A \overrightarrow H\cdot d\overrightarrow A = 0$. With Proposition 2,
  $2\pi r L\,H_r(r)=0 \Leftrightarrow H_r(r)=0$.<br>$\square$

  <div class="theory-common-box">Proposition 4: $H_\phi(r)=0$ for any $r$</div>
  <div style="text-align:center; margin:1em 0;">
    <img src="assets/electroMagnetismTheory/idealSolenoidLoop4.png"
      alt=""
      style="max-width:95%; height:auto;" />
  </div>
  <div class="proof-box">Proof</div>
  On a concentric circle of radius $r$, any spanning surface is not pierced by the solenoid current, so
  $\displaystyle \oint_C \overrightarrow H\cdot d\overrightarrow l = H_\phi(r)\,2\pi r = 0\Leftrightarrow H_\phi(r)=0$
  <br>$\square$
  
  <div class="theory-common-box">Proposition 5: Inside the solenoid, $H_z(r)$ is constant</div>
  <div style="text-align:center; margin:1em 0;">
    <img src="assets/electroMagnetismTheory/idealSolenoidLoop5.png"
        alt="rectangular loop (interior)"
        style="max-width:95%; height:auto;" />
  </div>
<div class="proof-box">Proof</div>
In the $rz$-plane take a rectangular loop entirely inside (not crossing the surface).<br>
Enclosed current is $0$, so
$$
\oint_C \overrightarrow H \cdot d\overrightarrow l = 0.
$$
With sides at $r_1,r_2 < a$ and $H_r=0$, only the vertical segments contribute:
$$
\oint_C \overrightarrow H \cdot d\overrightarrow l
  = H_z(r_2)\,L - H_z(r_1)\,L.
$$
Hence
$$\begin{aligned}
H_z(r_2)-H_z(r_1) &=0 \\
\Leftrightarrow \quad H_z(r_1)&=H_z(r_2).
\end{aligned}$$
Since $r_1,r_2 < a$ are arbitrary,
$$
H_z^{(\mathrm{in})}(r)=\text{constant}. \quad\square
$$

<div class="theory-common-box">Proposition 6: Outside the solenoid, $H_z(r)$ is constant</div>
  <div style="text-align:center; margin:1em 0;">
    <img src="assets/electroMagnetismTheory/idealSolenoidLoop6.png"
        alt="rectangular loop (exterior)"
        style="max-width:95%; height:auto;" />
  </div>
<div class="proof-box">Proof</div>
Likewise for a rectangular loop entirely outside: enclosed current $0$, so
$$
\oint_C \overrightarrow H \cdot d\overrightarrow l = 0.
$$
With $r_1,r_2 > a$ and $H_r=0$,
$$
\oint_C \overrightarrow H \cdot d\overrightarrow l
  = H_z(r_2)\,L - H_z(r_1)\,L,
$$
hence
$$\begin{aligned}
H_z(r_2)-H_z(r_1) &=0 \\
\Leftrightarrow \quad H_z(r_1)&=H_z(r_2).
\end{aligned}$$
Thus
$$
H_z^{(\mathrm{out})}(r)=\text{constant}. \quad\square
$$

<div class="theory-common-box">Proposition 7: The jump of $H_z$ across the solenoid is $nI$</div>
<div style="text-align:center; margin:1em 0;">
  <img src="assets/electroMagnetismTheory/idealSolenoidLoop7.png"
       alt="rectangular loop crossing the cylinder"
       style="max-width:95%; height:auto;" />
</div>
<div class="proof-box">Proof</div>
Take a rectangular loop in the $rz$-plane that crosses the solenoid surface.<br>
Enclosed current is $nI\ell$, so
$$
\oint_C \overrightarrow H \cdot d\overrightarrow l = nI\ell .
$$
With $r_1 < a$ and $r_2 > a$, and $H_r=0$,

$$
\oint_C \overrightarrow H \cdot d\overrightarrow l
  = H_z(r_2)\,L - H_z(r_1)\,L,
$$
hence
$$\begin{aligned}
H_z(r_2)\ell  - H_z(r_1)\ell &= nI\ell. \\
\Leftrightarrow H_z(r_2)  - H_z(r_1) &= nI 
\end{aligned}$$
. The interior–exterior difference of $H_z$ is $nI$.
<br>$\square$
<div class="theory-common-box">Proposition 8: Exterior field vanishes by the condition at infinity</div>
<div class="proof-box">Proof</div>
Imposing
$$
\lim_{r\to\infty} |\overrightarrow H(r)| = 0
$$
and using Proposition 6 (exterior field is a single constant), that constant is 0:
$$
H_z^{(\mathrm{out})}=0. \quad\square
$$

<div class="theory-common-box">Proposition 9: Interior field is $nI$</div>
<div class="proof-box">Proof</div>
By Proposition 7,
$$
H_z^{(\mathrm{in})}-H_z^{(\mathrm{out})}=nI,
$$
and by Proposition 8 $H_z^{(\mathrm{out})}=0$, so
$$
H_z^{(\mathrm{in})}=nI.
$$
Hence
$$
\overrightarrow H^{(\mathrm{in})}=nI\,\hat{\mathbf z},\qquad\square
$$


  <div class="theorem-box">Theorem: magnetic field of an ideal solenoid</div>
  <div class="proof-box">Proof</div>
  By Propositions 3–4, $H_r=H_\phi=0$. Propositions 8–9 then give
$$\begin{aligned}
  \overrightarrow H(r)=
    \begin{cases}
      nI \hat{\mathbf z} : r < a \\
      \vec {0}  : r > a
    \end{cases}
  \end{aligned}$$
  $\square$
 <br> 
  <div class="remark-box">Remark</div><br>
    With $\mathbf B=\mu_0\mathbf H$ in vacuum,
    $$\begin{aligned}
    \overrightarrow B(r)=
      \begin{cases}
        \mu_0 nI \hat{\mathbf z} : r < a \\
        \vec {0}  : r > a
      \end{cases}
    \end{aligned}$$
  """
);
