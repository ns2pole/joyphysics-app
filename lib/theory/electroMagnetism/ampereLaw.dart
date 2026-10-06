import '../../model.dart';

final ampereLaw = TheoryTopic(
  title: 'アンペールの法則（真空中、Hで表記）',
  titleEn: 'Ampère\'s law (in vacuum, written with H)',
  imageAsset: 'assets/mindMap/forTopics/ampereLaw.png',
  latexContent: r"""
<div class="theory-common-box">ポイント</div>
<p>アンペールの法則は、自由電流が磁場を生じることを表す法則です。真空中では、磁場強度 $\overrightarrow{H}$ を用いて簡潔に表せます。</p>

<div class="theory-common-box">記号の定義</div>
<ul>
<li>$\overrightarrow{H}$ ：磁場強度（磁荷に対して仕事をする場）</li>
<li>$\overrightarrow{B}$ ：磁束密度（磁場の物理的強さ）</li>
<li>$I_{\mathrm{free, enclosed}}$ ：閉曲線が貫く面を流れる自由電流の総和</li>
<li>$C$ ：線積分を行う閉曲線</li>
<li>$d\overrightarrow{l}$ ：線素ベクトル</li>
<li>$\mu_0$ ：真空の透磁率 $4\pi \times 10^{-7} \ \mathrm{T \cdot m / A}$</li>
<li>1 Wb ：磁荷の単位（磁場による仕事を測る基準）</li>
</ul>

<div class="theory-common-box">理論（積分形式）</div>
<p>閉曲線 $C$ に沿った磁場の線積分は、曲線が貫く面を流れる自由電流量に等しい：</p>
<p>$$\oint_C \overrightarrow{H} \cdot d\overrightarrow{l} = I_{\mathrm{free, enclosed}} $$</p>

<div class="theory-common-box">磁束密度との関係</div>
<p>真空中では、磁束密度 $\overrightarrow{B}$ と磁場強度 $\overrightarrow{H}$ は比例関係にあります：</p>
<p>$$\overrightarrow{B} = \mu_0 \overrightarrow{H}$$</p>
""",
  latexContentEn: r"""
<div class="theory-common-box">Key points</div>
<p>Ampère's law states that free current produces a magnetic field. In vacuum it can be written compactly using the magnetic field strength $\overrightarrow{H}$.</p>

<div class="theory-common-box">Definition of symbols</div>
<ul>
<li>$\overrightarrow{H}$ : magnetic field strength (the field that does work on magnetic charge)</li>
<li>$\overrightarrow{B}$ : magnetic flux density (physical strength of the magnetic field)</li>
<li>$I_{\mathrm{free, enclosed}}$ : total free current through a surface bounded by the closed curve</li>
<li>$C$ : the closed curve of the line integral</li>
<li>$d\overrightarrow{l}$ : line-element vector</li>
<li>$\mu_0$ : vacuum permeability $4\pi \times 10^{-7} \ \mathrm{T \cdot m / A}$</li>
<li>1 Wb : unit of magnetic charge (a reference for work done by the magnetic field)</li>
</ul>

<div class="theory-common-box">Theory (integral form)</div>
<p>The line integral of the magnetic field around a closed curve $C$ equals the free current through a surface spanned by the curve:</p>
<p>$$\oint_C \overrightarrow{H} \cdot d\overrightarrow{l} = I_{\mathrm{free, enclosed}} $$</p>

<div class="theory-common-box">Relation to magnetic flux density</div>
<p>In vacuum, the magnetic flux density $\overrightarrow{B}$ and the magnetic field strength $\overrightarrow{H}$ are proportional:</p>
<p>$$\overrightarrow{B} = \mu_0 \overrightarrow{H}$$</p>
"""
);