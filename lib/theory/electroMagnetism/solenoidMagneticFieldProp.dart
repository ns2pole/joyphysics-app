import '../../model.dart';
import '../../model.dart';
final solenoidMagneticFieldProp = TheoryTopic(
  title: '無限に長い理想ソレノイドの磁場(真空中)  内部:  \\( H = n I \\), 外部: \\( H = 0 \\)',
  latexContent: """
  <div style="text-align:center; margin:1em 0;">
    <img src="assets/electroMagnetismTheory/initSolenoid.png"
      alt="理想ソレノイド"
      style="max-width:75%; height:auto;" />
  </div>

  <div class="condition-box">条件と記号</div>
  <ul>
    <li>空間は真空</li>
    <li>半径 \$a\$、巻数密度 \$n\\,[\\text{turns/m}]\$、電流 \$I\\,[\\text{A}]\$ の無限に長い理想ソレノイド（巻線は円周方向に連続した表面電流 \$\\mathbf K = nI\\,\\hat{\\boldsymbol\\phi}\$ とみなす）</li>
    <li>系は \$z\$ 軸まわりの回転対称かつ \$z\$ 方向に並進対称</li>
    <li>変位電流は無視</li>
    <li>単位ベクトル \$\\hat{\\mathbf r},\\ \\hat{\\boldsymbol\\phi},\\ \\hat{\\mathbf z}\$ を用いる</li>
    <li>磁場を \$\\overrightarrow H=H_r(r,\\phi,z)\\,\\hat{\\mathbf r}+H_\\phi(r,\\phi,z)\\,\\hat{\\boldsymbol\\phi}+H_z(r,\\phi,z)\\,\\hat{\\mathbf z}\$ とする</li>
  </ul>
    <div style="text-align:center; margin:1em 0;">
      <img src="assets/electroMagnetismTheory/idealSolenoidCoodinate.png"
        alt=""
        style="max-width:70%; height:auto;" />
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

  <div class="theory-common-box">命題2：同心円柱（半径 \$r\$, 高さ \$L\$）を閉曲面とすると、\$\\displaystyle \\oint_A \\overrightarrow H\\cdot d\\overrightarrow A = 2\\pi r L\\, H_r(r)\$</div>
  <div style="text-align:center; margin:1em 0;">
    <img src="assets/electroMagnetismTheory/idealSolenoid_cylinder.png"
      alt="円柱ガウス面"
      style="max-width:90%; height:auto;" />
  </div>
  <div class="proof-box">証明</div>
  上下面は \$z\$ 成分のみ、側面は \$r\$ 成分のみが効く。上下面の寄与は互いに打ち消し合い、側面は側面積と \$H_r(r)\$ の積となるので式の通り。\\(\\square\\)

  <div class="theory-common-box">命題3：任意の \$r\$ で \$H_r(r)=0\$</div>
  <div class="proof-box">証明</div>
  磁場のガウスの法則より \$\\displaystyle \\oint_A \\overrightarrow H\\cdot d\\overrightarrow A = 0\$。命題2を用いて
  \$2\\pi r L\\,H_r(r)=0 \\Leftrightarrow H_r(r)=0\$。\\(\\square\\)

  <div class="theory-common-box">命題4：任意の \$r\$ で \$H_\\phi(r)=0\$</div>
  <div class="proof-box">証明</div>
  半径 \$r\$ の同心円周を積分経路とする。境界面が張る任意の開曲面を取ると、内部には円周方向の電流（表面電流 \$\\mathbf K\\parallel\\hat{\\boldsymbol\\phi}\$）しかなく、法線方向の電流は貫かないため、
  \$\\displaystyle \\oint_C \\overrightarrow H\\cdot d\\overrightarrow l = H_\\phi(r)\\,2\\pi r = 0\\Leftrightarrow H_\\phi(r)=0\$。\\(\\square\\)
  <div style="text-align:center; margin:1em 0;">
    <img src="assets/electroMagnetismTheory/idealSolenoidLoop4.png"
      alt="境界を跨ぐ長方形ループ"
      style="max-width:70%; height:auto;" />
  </div>
  <div class="theory-common-box">命題5：\$H_z\$ は内部・外部でそれぞれ一定で、境界 \$r=a\$ を跨ぐと
  \$\\displaystyle H_z^{\\text{(in)}} - H_z^{\\text{(out)}} = nI\$ が成り立つ</div>
  <div class="proof-box">証明</div>
  (i) ループが完全に内部（または外部）にあるとき、囲む電流は 0。よって \$\\oint \\overrightarrow H\\cdot d\\overrightarrow l=0\$ からその領域内で \$H_z\$ は一定。<br>
  (ii) 半径 \$a\$ の円筒面を跨ぐ微小長方形ループ（法線は円筒の外向き）を考える。横辺（法線方向）の寄与は命題3より 0、円周方向の寄与は命題4より 0。上下辺のみ残り、
  \$\\oint \\overrightarrow H\\cdot d\\overrightarrow l = (H_z^{\\text{(in)}}-H_z^{\\text{(out)}})\\,\\ell\$。
  一方、ループが貫く電流は表面電流密度 \$K=nI\$ によって \$K\\,\\ell\$。アンペールの法則
  \$\\oint \\overrightarrow H\\cdot d\\overrightarrow l = I_{\\text{enc}}\$ から
  \$H_z^{\\text{(in)}}-H_z^{\\text{(out)}}=nI\$。\\(\\square\\)
    <img src="assets/electroMagnetismTheory/idealSolenoidLoop5.png"
      alt="境界を跨ぐ長方形ループ"
      style="max-width:70%; height:auto;" />
  </div>
  <div class="theory-common-box">命題6：外部磁場は定数</div>
  <div class="proof-box">証明</div>
  外部領域（\\(r > a\\)）で長方形ループ（\\(rz\\) 平面）を取り、ソレノイド表面を跨がないように選ぶと、囲む電流は 0。<br>
  よってアンペールの法則より
  \\[
    \\oint_C \\overrightarrow H \\cdot d\\overrightarrow l = 0 \\Leftrightarrow H_z^{(\\mathrm{out})} = \\text{const} \\quad \\square
  \\]
  <div style="text-align:center; margin:1em 0;">
    <img src="assets/electroMagnetismTheory/idealSolenoidLoop6.png"
      alt="長方形ループ"
      style="max-width:70%; height:auto;" />
  </div>

  <div class="theory-common-box">命題7：無限遠境界条件から外部磁場は 0</div>
  <div class="proof-box">証明</div>
  \\( \\displaystyle \\lim_{r \\to \\infty} |\\overrightarrow H| = 0\\) という境界条件を課すと、外部定数は 0 となる。すなわち
  \\[
    H_z^{(\\mathrm{out})} = 0 \\quad \\square
  \\]

  <div class="theorem-box">定理：理想ソレノイドの磁場</div>
  <div class="proof-box">証明</div>
  命題3・命題4より \$H_r=H_\\phi=0\$。命題5と命題6より \$H_z^{\\text{(in)}}-0=nI\\Leftrightarrow H_z^{\\text{(in)}}=nI\$。
  以上より
\\begin{aligned}
  \\overrightarrow H(r)=
    \\begin{cases}
      nI \\hat{\\mathbf z} : r < a \\\\
      \\vec {0}  : r > a
    \\end{cases}
  \\end{aligned}
  \\(\\square\\)

  <div class="remark-box">補足</div>
  <ul>
    <li>有限長ソレノイドでは端面効果により外部磁場は厳密には 0 ではないが、長さ \\(\\gg a\\) で中心付近では本結果が高精度で成り立つ。</li>
    <li>磁束密度は \$\\mathbf B=\\mu_0\\mathbf H\$（真空）なので、内部は \$\\mathbf B=\\mu_0 n I\\,\\hat{\\mathbf z}\$。</li>
  </ul>
  """
);
