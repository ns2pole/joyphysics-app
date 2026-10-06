import '../../model.dart';

final vectorComponent = TheoryTopic(
  title: 'ベクトルの成分分解',
  titleEn: 'Component decomposition of vectors',
  latexContent: r"""
<div class="common-box">ポイント</div>
<p>同じベクトルでも、軸によって成分の値は変わる。</p>

<div class="common-box">記号の定義</div>
<ul>
<li>$\overrightarrow{A}$ ：任意のベクトル</li>
<li>$A_x, A_y$ ：それぞれ $x$、$y$ 軸方向の成分</li>
<li>$ \overrightarrow{i}, \overrightarrow{j} $  ：直交座標系の単位ベクトル</li>
</ul>
<div class="common-box">理論</div>
    <div style="text-align:center; margin:1em 0;">
      <img src="assets/dynamicsTheory/vect1.png"
           alt="データ一覧"
           style="max-width:70%; height:auto;" />
    </div>
<p>2次元直交座標系では、ベクトルは</p>
<p>$$\overrightarrow{A} = A_x \overrightarrow{i} + A_y \overrightarrow{j}$$</p>
<div class="common-box">1次元の例</div>
<p><b>例1：</b> 長さ $5$ のベクトルを考えます。</p>
    <div style="text-align:center; margin:1em 0;">
      <img src="assets/dynamicsTheory/vect2.png"
           alt="データ一覧"
           style="max-width:80%; height:auto;" />
    </div>
<ul>
<li>$\overrightarrow{A}$と同じ向きを正方向とする軸 → 成分は $+5$</li>
<li>$\overrightarrow{A}$と逆向きを正方向とする軸 → 成分は → 成分は $-5$</li>
</ul>
<div class="common-box">2次元の例</div>
<p><b>例2：</b> 大きさ $5$ のベクトル $\overrightarrow{A}$ を考えます。軸のとり方によって次のように成分が変わります。</p>
    <div style="text-align:center; margin:1em 0;">
      <img src="assets/dynamicsTheory/vect3.png"
           alt="データ一覧"
           style="max-width:70%; height:auto;" />
</div>
<ul>
<li>水平右向きを $x$ 軸、上向きを $y$ 軸とする  
→ 成分は(3, 4)（ピタゴラスの定理で長さ 5）</li>
<li>ベクトルの向きに $x$ 軸を合わせ、垂直方向を $y$ 軸とする  
→ 成分は(5, 0)</li>
</ul>
""",
  latexContentEn: r"""
<div class="common-box">Key points</div>
<p>Even for the same vector, the component values change with the choice of axes.</p>

<div class="common-box">Definition of symbols</div>
<ul>
<li>$\overrightarrow{A}$ : an arbitrary vector</li>
<li>$A_x, A_y$ : components along the $x$ and $y$ axes</li>
<li>$ \overrightarrow{i}, \overrightarrow{j} $  : unit vectors of an orthogonal coordinate system</li>
</ul>
<div class="common-box">Theory</div>
    <div style="text-align:center; margin:1em 0;">
      <img src="assets/dynamicsTheory/vect1.png"
           alt="data list"
           style="max-width:70%; height:auto;" />
    </div>
<p>In a 2D orthogonal coordinate system, a vector is</p>
<p>$$\overrightarrow{A} = A_x \overrightarrow{i} + A_y \overrightarrow{j}$$</p>
<div class="common-box">1D examples</div>
<p><b>Example 1:</b> Consider a vector of length $5$.</p>
    <div style="text-align:center; margin:1em 0;">
      <img src="assets/dynamicsTheory/vect2.png"
           alt="data list"
           style="max-width:80%; height:auto;" />
    </div>
<ul>
<li>Axis with the positive direction along $\overrightarrow{A}$ → component $+5$</li>
<li>Axis with the positive direction opposite to $\overrightarrow{A}$ → component $-5$</li>
</ul>
<div class="common-box">2D examples</div>
<p><b>Example 2:</b> Consider a vector $\overrightarrow{A}$ of magnitude $5$. Depending on the axes, its components change as follows.</p>
    <div style="text-align:center; margin:1em 0;">
      <img src="assets/dynamicsTheory/vect3.png"
           alt="data list"
           style="max-width:70%; height:auto;" />
</div>
<ul>
<li>Horizontal right as the $x$-axis and upward as the $y$-axis  
→ components $(3, 4)$ (length $5$ by the Pythagorean theorem)</li>
<li>Align the $x$-axis with the vector and take the perpendicular direction as the $y$-axis  
→ components $(5, 0)$</li>
</ul>
"""
);
