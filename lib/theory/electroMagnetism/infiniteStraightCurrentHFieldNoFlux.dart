import '../../model.dart';

final infiniteStraightCurrentHFieldNoFlux = TheoryTopic(
  title: '無限に長い直線電流の磁場強度 \\(\\overrightarrow{H}\\)（真空中・積分形のみで導出）',
  latexContent: """
<div class="common-box">前提・仮定</div>
<ul>
<li>定常状態（時間変化なし）。</li>
<li>真空中での記述：\\(\\overrightarrow{B}=\\mu_0\\,\\overrightarrow{H}\\)。</li>
<li>電流は z 軸上に局在する無限長直線電流で、分布としては \\(I\\,\\delta(x)\\delta(y)\\,\\overrightarrow{z}\\)。</li>
<li>議論は軸外領域（\\(\\rho>0\\)）について行う。境界条件として「孤立系：無限遠で場が 0 に収束」を仮定する。</li>
</ul>

<div class="common-box">記号</div>
<ul>
<li>円筒座標：\\((\\rho,\\phi,z)\\)。</li>
<li>単位ベクトル：\\(\\overrightarrow{\\rho},\\overrightarrow{\\phi},\\overrightarrow{z}\\)。</li>
<li>閉曲面積分：\\(\\displaystyle \\iint_{\\partial V} \\overrightarrow{B}\\cdot d\\overrightarrow{S}\\)。</li>
<li>線積分（閉曲線）：\\(\\displaystyle \\oint_C \\overrightarrow{H}\\cdot d\\overrightarrow{l}\\)。</li>
</ul>

<div class="common-box">命題と証明（積分形のみ）</div>

<p><b>命題 1（一般形）</b><br>
円筒座標における任意の磁場強度は次のように表される：</p>
<p>\$\$
\\overrightarrow{H}(\\rho,\\phi,z)=H_\\rho(\\rho,\\phi,z)\\,\\overrightarrow{\\rho}
+H_\\phi(\\rho,\\phi,z)\\,\\overrightarrow{\\phi}
+H_z(\\rho,\\phi,z)\\,\\overrightarrow{z}.
\$\$</p>
<p><b>証明</b><br>
座標基底の展開としての定義であるため省略。</p>

<p><b>命題 2（対称性：\\(\\phi, z\\) 非依存）</b><br>
無限に長い直線電流のもとでは各成分は方位角 \\(\\phi\\) と軸方向 \\(z\\) に依存しない。</p>

<p><b>証明</b><br>
系は (i) z 軸方向への平行移動で不変、(ii) 軸まわり回転で不変である。  
したがって任意点での場は z と \\(\\phi\\) に依存しない。すなわち各成分は \\(\\rho\\) のみの関数となる。</p>

<p><b>命題 3（ガウスの法則で放射成分を消す）</b><br>
任意の \\(\\rho>0\\) について、放射成分はゼロである：\\(H_\\rho(\\rho)=0\\)。</p>

<p><b>証明</b><br>
磁束密度についてのガウスの法則（積分形）を用いる：
\$\$
\\iint_{\\partial V} \\overrightarrow{B}\\cdot d\\overrightarrow{S} = 0.
\$\$
ここで \\(\\overrightarrow{B}=\\mu_0\\overrightarrow{H}\\)。半径 \\(\\rho\\)、長さ \\(L\\) の同軸円筒を閉曲面 \\(\\partial V\\) とする。側面の外向き法線は \\(\\overrightarrow{\\rho}\\) なので側面を通る垂直成分の合計は
\$\$
\\int_{\\text{side}} \\overrightarrow{B}\\cdot d\\overrightarrow{S}
=\\mu_0 \\int_{0}^{L}\\int_{0}^{2\\pi} H_\\rho(\\rho)\\,\\rho\\,d\\phi\\,dz
=2\\pi\\rho L\\,\\mu_0 H_\\rho(\\rho).
\$\$
上下の蓋については、対称性により上面と下面の垂直成分が互いに打ち消す（同じ大きさで符号が逆）ので合計は 0 になる。したがって全閉曲面積分が 0 であることから
\$\$
2\\pi\\rho L\\,\\mu_0 H_\\rho(\\rho)=0
\$\$
が任意の \\(\\rho,L\\) で成り立ち、よって \\(H_\\rho(\\rho)=0\\)。</p>

<p><b>命題 4（アンペールの法則で周方向成分を決定）</b><br>
周方向成分は
\$\$
H_\\phi(\\rho)=\\frac{I}{2\\pi\\rho}
\$\$
である。</p>

<p><b>証明</b><br>
積分形アンペールの法則を用いる：
\$\$
\\oint_C \\overrightarrow{H}\\cdot d\\overrightarrow{l} = I_{\\mathrm{enc}}.
\$\$
円周対称性により、半径 \\(\\rho\\) の円周 \\(C\\) 上での \\(H_\\phi\\) は一定である。線積分は
\$\$
\\oint_C \\overrightarrow{H}\\cdot d\\overrightarrow{l} = \\int_0^{2\\pi} H_\\phi(\\rho)\\, (\\rho\\,d\\phi) = 2\\pi\\rho H_\\phi(\\rho).
\$\$
この曲線が軸上の電流全体を囲むため、右辺は \\(I\\)、したがって
\$\$
2\\pi\\rho H_\\phi(\\rho) = I
\\quad\\Rightarrow\\quad
H_\\phi(\\rho)=\\dfrac{I}{2\\pi\\rho}.
\$\$</p>

<p><b>命題 5（アンペールの法則で軸方向成分は定数）</b><br>
軸外領域では \\(H_z(\\rho)\\) は定数である。</p>

<p><b>証明</b><br>
アンペールの法則を、電流を囲まない形の閉経路に適用する。具体的には、方位角を一定に固定した面内に、半径 \\(\\rho_1\\) と \\(\\rho_2\\) に沿う 2 本の縦の線分（長さ \\(L\\)）とそれらを結ぶ短い横辺から成る矩形閉路を取る。矩形が軸を囲まないので囲まれる自由電流は 0 である。したがって線積分は 0：
\$\$
\\oint_{\\text{rect}} \\overrightarrow{H}\\cdot d\\overrightarrow{l} = 0.
\$\$
横辺の寄与は短くできる（\\(L\\) を有限に取り、横辺の長さを極限で 0 に近づける構成）ため無視できるとして、縦の 2 辺の寄与のみを考えると
\$\$
H_z(\\rho_1)\\,L - H_z(\\rho_2)\\,L = 0 \\quad\\Rightarrow\\quad H_z(\\rho_1)=H_z(\\rho_2).
\$\$
任意の \\(\\rho_1,\\rho_2>0\\) に対して成立するので、軸外で \\(H_z\\) は定数である。</p>

<p><b>命題 6（無限遠境界条件で一様成分を除去）</b><br>
孤立系（外部に一様場が無い）かつ無限遠での減衰を仮定すると、上述の定数は 0 である。したがって最終解は</p>
<p>\$\$
\\boxed{\\;\\overrightarrow{H}(\\rho)=\\dfrac{I}{2\\pi\\rho}\\,\\overrightarrow{\\phi}\\; }
\$\$</p>

<p><b>証明</b><br>
命題 5 によって得られた一様成分 \\(H_z=C_z\\) を残すと、無限遠（\\(\\rho\\to\\infty\\)）における磁場強度は有限な定数 \\(C_z\\) を含むため消えない。孤立系の境界条件
\$\$
\\lim_{\\rho\\to\\infty}\\overrightarrow{H}(\\rho)=\\overrightarrow{0}
\$\$
を課すと、これを満たすのは \\(C_z=0\\) のみである。加えて、アンペールの法則により周方向成分は上で示した通りで一意に決まるので、最終形が得られる。</p>

<div class="common-box">補足（軸上の特異点扱い）</div>
<p>軸 \\(\\rho=0\\) 上は電流がデルタ分布を持つ点（線）であり、ここでは微分的な議論はできない。だが積分形アンペールはそのまま適用可能で、軸を囲む経路の循環が \\(I\\) であるという情報が本質である。</p>

<div class="common-box">結論（解の向き）</div>
<p>向きは積分の向きと面法線の約束によって決まり、通常は右ねじの法則によって「電流が +z の向きのとき磁場は正の \\(\\overrightarrow{\\phi}\\) 向き」を取る。</p>
"""
);
