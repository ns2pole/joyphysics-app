import '../../model.dart';

final vectorComponent = TheoryTopic(
  title: 'ベクトルの成分分解',
  latexContent: """
<div class="common-box">ポイント</div>
<p>同じベクトルでも、軸によって成分の値は変わる。</p>

<div class="common-box">記号の定義</div>
<ul>
<li>\\(\\overrightarrow{A}\\) ：任意のベクトル</li>
<li>\\(A_x, A_y\\) ：それぞれ \\(x\\)、\\(y\\) 軸方向の成分</li>
<li>\$ \\overrightarrow{i}, \\overrightarrow{j} \$  ：直交座標系の単位ベクトル</li>
</ul>
<div class="common-box">理論</div>
    <div style="text-align:center; margin:1em 0;">
      <img src="assets/dynamicsTheory/vect1.png"
           alt="データ一覧"
           style="max-width:70%; height:auto;" />
    </div>
<p>2次元直交座標系では、ベクトルは</p>
<p>\$\$\\overrightarrow{A} = A_x \\overrightarrow{i} + A_y \\overrightarrow{j}\$\$</p>
<div class="common-box">1次元の例</div>
<p><b>例1：</b> 長さ \\(5\\) のベクトルを考えます。</p>
    <div style="text-align:center; margin:1em 0;">
      <img src="assets/dynamicsTheory/vect2.png"
           alt="データ一覧"
           style="max-width:70%; height:auto;" />
    </div>
<ul>
<li>\$\\overrightarrow{A}\$と同じ向きを正方向とする軸 → 成分は \\(+5\\)</li>
<li>\$\\overrightarrow{A}\$と逆向きを正方向とする軸 → 成分は → 成分は \\(-5\\)</li>
</ul>
<div class="common-box">2次元の例</div>
<p><b>例2：</b> 大きさ \\(5\\) のベクトル \\(\\overrightarrow{A}\\) を考えます。軸のとり方によって次のように成分が変わります。</p>
<ul>
    <div style="text-align:center; margin:1em 0;">
      <img src="assets/dynamicsTheory/vect3.png"
           alt="データ一覧"
           style="max-width:70%; height:auto;" />
    </div>
<li>水平右向きを \\(x\\) 軸、上向きを \\(y\\) 軸とする  
→ 成分は(3, 4)（ピタゴラスの定理で長さ 5）</li>
<li>ベクトルの向きに \\(x\\) 軸を合わせ、垂直方向を \\(y\\) 軸とする  
→ 成分は(5, 0)</li>
</ul>
"""
);
