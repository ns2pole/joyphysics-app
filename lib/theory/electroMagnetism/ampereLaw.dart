import '../../model.dart';

final ampereLaw = TheoryTopic(
  title: 'アンペールの法則（真空中、Hで表記）',
  latexContent: """
<div class="theory-common-box">ポイント</div>
<p>アンペールの法則は、自由電流が磁場を生じることを表す法則です。真空中では、磁場強度 \\(\\overrightarrow{H}\\) を用いて簡潔に表せます。</p>

<div class="theory-common-box">記号の定義</div>
<ul>
<li>\\(\\overrightarrow{H}\\) ：磁場強度（磁荷に対して仕事をする場）</li>
<li>\\(\\overrightarrow{B}\\) ：磁束密度（磁場の物理的強さ）</li>
<li>\\(I_{\\mathrm{free, enclosed}}\\) ：閉曲線が貫く面を流れる自由電流の総和</li>
<li>\\(C\\) ：線積分を行う閉曲線</li>
<li>\\(d\\overrightarrow{l}\\) ：線素ベクトル</li>
<li>\\(\\mu_0\\) ：真空の透磁率 \\(4\\pi \\times 10^{-7} \\ \\mathrm{T \\cdot m / A}\\)</li>
<li>1 Wb ：磁荷の単位（磁場による仕事を測る基準）</li>
</ul>

<div class="theory-common-box">理論（積分形式）</div>
<p>閉曲線 \\(C\\) に沿った磁場の線積分は、曲線が貫く面を流れる自由電流量に等しい：</p>
<p>\$\$\\oint_C \\overrightarrow{H} \\cdot d\\overrightarrow{l} = I_{\\mathrm{free, enclosed}} \$\$</p>

<div class="theory-common-box">磁束密度との関係</div>
<p>真空中では、磁束密度 \\(\\overrightarrow{B}\\) と磁場強度 \\(\\overrightarrow{H}\\) は比例関係にあります：</p>
<p>\$\$\\overrightarrow{B} = \\mu_0 \\overrightarrow{H}\$\$</p>
"""
);