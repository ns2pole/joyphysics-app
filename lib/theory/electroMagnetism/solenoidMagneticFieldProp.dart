import '../../model.dart';
import '../../model.dart';
final solenoidMagneticFieldProp = TheoryTopic(
  title: '無限に長い理想ソレノイドの磁場(真空中)  内部:  \\( H = n I \\), 外部: \\( H = 0 \\)',
  latexContent: """
  <div style="text-align:center; margin:1em 0;">
    <img src="assets/electroMagnetismTheory/initSolenoid.png"
      alt="理想ソレノイド"
      style="max-width:95%; height:auto;" />
  </div>

  <div class="condition-box">条件と記号</div>
  <ul>
    <li>空間は真空</li>
    <li>半径 \$a\$、巻数密度 \$n\\,[\\text{/m}]\$、電流 \$I\\,[\\text{A}]\$ の無限に長い理想ソレノイド</li>
    <li>系は \$z\$ 軸まわりの回転対称かつ \$z\$ 方向に並進対称</li>
    <li>変位電流は無視</li>
    <li>単位ベクトル \$\\hat{\\mathbf r},\\ \\hat{\\boldsymbol\\phi},\\ \\hat{\\mathbf z}\$ を用いる</li>
    <li>磁場を \$\\overrightarrow H=H_r(r,\\phi,z)\\,\\hat{\\mathbf r}+H_\\phi(r,\\phi,z)\\,\\hat{\\boldsymbol\\phi}+H_z(r,\\phi,z)\\,\\hat{\\mathbf z}\$ とする</li>
  </ul>
    <div style="text-align:center; margin:1em 0;">
      <img src="assets/electroMagnetismTheory/idealSolenoidCoodinate.png"
        alt=""
        style="max-width:95%; height:auto;" />
    </div>
  <div class="theorem-box">
  定理（理想ソレノイドの磁場）：
  \\begin{aligned}
  \\overrightarrow H(r)=
    \\begin{cases}
      nI \\hat{\\mathbf z} : r < a \\\\
      \\vec {0}  : r > a
    \\end{cases}
  \\end{aligned}
  </div>
  この定理を、命題1〜命題6を示し用いることで証明する。
  <br><br>

  <div class="theory-common-box">命題1：磁場成分は半径 \$r\$ のみの関数で、\$\\displaystyle
    \\overrightarrow H=H_r(r)\\,\\hat{\\mathbf r}+H_\\phi(r)\\,\\hat{\\boldsymbol\\phi}+H_z(r)\\,\\hat{\\mathbf z}
  \$ と書ける</div>
  <div class="proof-box">証明</div>
  系は回転対称かつ \$z\$ 方向に並進対称。よって任意の点での場は \$\\phi, z\$ に依らず、各成分は \$r\$ のみの関数となる。\\(\\square\\)

  <div class="theory-common-box">命題2：同心円柱（半径 \$r\$, 高さ \$L\$）を閉曲面とすると、\$ \\displaystyle \\oint_A \\overrightarrow H\\cdot d\\overrightarrow A = 2\\pi r L\\, H_r(r)\$</div>
  <div style="text-align:center; margin:1em 0;">
    <img src="assets/electroMagnetismTheory/idealSolenoid_cylinder.png"
      alt="円柱ガウス面"
      style="max-width:95%; height:auto;" />
  </div>
  <div class="proof-box">証明</div>
  上下面は \$z\$ 成分のみ、側面は \$r\$ 成分のみが効く。上下面の寄与は命題1より貫く方向が逆であるだけなので、互いに打ち消し合い、側面は側面積と \$H_r(r)\$ の積となるので式の通り。\\(\\square\\)

  <div class="theory-common-box">命題3：任意の \$r\$ で \$H_r(r)=0\$</div>
  <div class="proof-box">証明</div>
  磁場のガウスの法則より \$\\displaystyle \\oint_A \\overrightarrow H\\cdot d\\overrightarrow A = 0\$。命題2を用いて
  \$2\\pi r L\\,H_r(r)=0 \\Leftrightarrow H_r(r)=0\$。\\(\\square\\)

  <div class="theory-common-box">命題4：任意の \$r\$ で \$H_\\phi(r)=0\$</div>
  <div style="text-align:center; margin:1em 0;">
    <img src="assets/electroMagnetismTheory/idealSolenoidLoop4.png"
      alt=""
      style="max-width:95%; height:auto;" />
  </div>
  <div class="proof-box">証明</div>
  半径 \$r\$ の同心円周を積分経路とする。境界面が張る任意の開曲面を取ると、電流はこの面を貫かないため、
  \$\\displaystyle \\oint_C \\overrightarrow H\\cdot d\\overrightarrow l = H_\\phi(r)\\,2\\pi r = 0\\Leftrightarrow H_\\phi(r)=0\$。\\(\\square\\)
  
  <div class="theory-common-box">命題5：ソレノイド内部の \$H_z(r)\$ は場所によらず一定</div>
  <div style="text-align:center; margin:1em 0;">
    <img src="assets/electroMagnetismTheory/idealSolenoidLoop5.png"
        alt="長方形ループ（内部）"
        style="max-width:95%; height:auto;" />
  </div>
<div class="proof-box">証明</div>
\$rz\$ 平面内で、ソレノイド表面を跨がないように、ソレノイド内部で長方形ループを取る。<br>
この時ループが囲む電流は \$0\$ である。したがってアンペールの法則の積分形から
\\[
\\oint_C \\overrightarrow H \\cdot d\\overrightarrow l = 0.
\\]
また、この長方形のループについて，垂直辺の\$r\$の値を\$r_1,r_2 \< a\$とすると、\$H_r=0\$であることから、
\\[
\\oint_C \\overrightarrow H \\cdot d\\overrightarrow l
  = H_z(r_2)\\,L - H_z(r_1)\\,L.
\\]
よって
\\begin{aligned}
H_z(r_2)-H_z(r_1) &=0 \\\\
\\Leftrightarrow \\quad H_z(r_1)&=H_z(r_2).
\\end{aligned}
\$r_1,r_2 \< a\$ は任意なので，ソレノイド内部では
\\[
H_z^{(\\mathrm{in})}(r)=\\text{定数}. \\quad\\square
\\]

<div class="theory-common-box">命題6：ソレノイド外部の \$H_z(r)\$ は場所によらず一定</div>
  <div style="text-align:center; margin:1em 0;">
    <img src="assets/electroMagnetismTheory/idealSolenoidLoop6.png"
        alt="長方形ループ（外部）"
        style="max-width:95%; height:auto;" />
  </div>
<div class="proof-box">証明</div>
\$rz\$ 平面内で、ソレノイド表面を跨がないように、ソレノイド外部で長方形ループを取る。<br>
この時ループが囲む電流は \$0\$ である。したがってアンペールの法則の積分形から
\\[
\\oint_C \\overrightarrow H \\cdot d\\overrightarrow l = 0.
\\]
また、この長方形のループについて，垂直辺の\$r\$の値を\$r_1,r_2 \> a\$とすると、\$H_r=0\$であることから、
\\[
\\oint_C \\overrightarrow H \\cdot d\\overrightarrow l
  = H_z(r_2)\\,L - H_z(r_1)\\,L,
\\]
従って
\\begin{aligned}
H_z(r_2)-H_z(r_1) &=0 \\\\
\\Leftrightarrow \\quad H_z(r_1)&=H_z(r_2).
\\end{aligned}
\$r_1,r_2 \> a \$ は任意なので，外部でも
\\[
H_z^{(\\mathrm{out})}(r)=\\text{定数}. \\quad\\square
\\]

<div class="theory-common-box">命題7：ソレノイド内部と外部の \$H_z\$ の差は \$nI\$ である</div>
<div style="text-align:center; margin:1em 0;">
  <img src="assets/electroMagnetismTheory/idealSolenoidLoop7.png"
       alt="長方形ループ（円筒面を跨ぐ）"
       style="max-width:95%; height:auto;" />
</div>
<div class="proof-box">証明</div>
\$rz\$ 平面内で、ソレノイド表面を跨ぐように、長方形ループを取る。<br>
この時ループが囲む電流は \$nI\\ell \$ である。したがってアンペールの法則の積分形から
\\[
\\oint_C \\overrightarrow H \\cdot d\\overrightarrow l = nI\\ell .
\\]
また、この長方形のループについて，垂直辺の\$r\$の値をそれぞれ\$r_1 \< a ,r_2 \> a\$とすると、\$H_r=0\$であることから、

\\[
\\oint_C \\overrightarrow H \\cdot d\\overrightarrow l
  = H_z(r_2)\\,L - H_z(r_1)\\,L,
\\]
従って、
\\begin{aligned}
H_z(r_2)\\ell  - H_z(r_1)\\ell &= nI\\ell. \\\\
\\Leftrightarrow H_z(r_2)  - H_z(r_1) &= nI 
\\end{aligned}
\$r_1 \< a,r_2\> a \$ は任意なので，内部と外部の\$z\$方向磁場の大きさの差が\$nI\$であることが示された。\$\\square\$

<div class="theory-common-box">命題8：無限遠境界条件により外部の磁場は 0</div>
<div class="proof-box">証明</div>
無限遠境界条件として
\\[
\\lim_{r\\to\\infty} |\\overrightarrow H(r)| = 0
\\]
を課すと（物理的に場は遠方で消える），命題6 より外部の磁場は全域で同じ定数であるから，その定数は 0 である：
\\[
H_z^{(\\mathrm{out})}=0. \\quad\\square
\\]

<div class="theory-common-box">命題9：命題7 と 命題8 からソレノイド内部の磁場は \$nI\$ である</div>
<div class="proof-box">証明</div>
命題7 より
\\[
H_z^{(\\mathrm{in})}-H_z^{(\\mathrm{out})}=nI,
\\]
命題8 より \$H_z^{(\\mathrm{out})}=0\$ なので，
\\[
H_z^{(\\mathrm{in})}=nI.
\\]
したがって
\\[
\\overrightarrow H^{(\\mathrm{in})}=nI\\,\\hat{\\mathbf z},\\qquad\\square
\\]


  <div class="theorem-box">定理：理想ソレノイドの磁場</div>
  <div class="proof-box">証明</div>
  命題3・命題4より \$H_r=H_\\phi=0\$。命題8と命題9より下記が従う。
\\begin{aligned}
  \\overrightarrow H(r)=
    \\begin{cases}
      nI \\hat{\\mathbf z} : r < a \\\\
      \\vec {0}  : r > a
    \\end{cases}
  \\end{aligned}
  \\(\\square\\)
 <br> 
  <div class="remark-box">補足</div><br>
    磁束密度は \$\\mathbf B=\\mu_0\\mathbf H\$（真空）なので、下記の通りとなる。
    \\begin{aligned}
    \\overrightarrow B(r)=
      \\begin{cases}
        \\mu_0 nI \\hat{\\mathbf z} : r < a \\\\
        \\vec {0}  : r > a
      \\end{cases}
    \\end{aligned}
  """
);
