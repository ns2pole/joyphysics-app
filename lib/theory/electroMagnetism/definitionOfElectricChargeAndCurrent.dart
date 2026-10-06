import '../../model.dart';

final definitionOfElectricChargeAndCurrent = TheoryTopic(
  title: '電荷,電流の定義',
  titleEn: 'Definitions of electric charge and current',
  // imageAsset: 'assets/mindMap/forTopics/definitionOfElectricChargeAndCurrent.png',

  latexContent: r"""
<div class="theory-common-box">定義（電荷）</div>
<p>
単位はクーロン ($\mathrm{C}$)で、$\mathrm{A \ s}$とも書ける。<br>
${1\ \mathrm{C}}$ は約 $6.2415\times10^{18}$個の電子が持つ電気量。
</p>
<div class="theory-common-box">定義（電流）</div>
<p>
<p>単位はアンペア（${\mathrm{A}}$）で、$\mathrm{C\ s^{-1}}$とも書ける。<br>
電流 ${I}$ は流れる電荷 ${Q}$ の時間微分${\displaystyle I=\frac{dQ}{dt}}$ で定義される。</p>
<p>$1\ \mathrm{A} = 1\ \mathrm{C\ s^{-1}}$は $1$ 秒で約 $ 6.2415\times10^{18}$ 個の電子が流れる量に相当する。</p>
</p>
""",
  latexContentEn: r"""
<div class="theory-common-box">Definition (electric charge)</div>
<p>
The unit is the coulomb ($\mathrm{C}$), also written $\mathrm{A \ s}$.<br>
${1\ \mathrm{C}}$ is the charge of about $6.2415\times10^{18}$ electrons.
</p>
<div class="theory-common-box">Definition (electric current)</div>
<p>
<p>The unit is the ampere (${\mathrm{A}}$), also written $\mathrm{C\ s^{-1}}$.<br>
The current ${I}$ is defined as the time derivative of the flowing charge ${Q}$: ${\displaystyle I=\frac{dQ}{dt}}$.</p>
<p>$1\ \mathrm{A} = 1\ \mathrm{C\ s^{-1}}$ corresponds to about $ 6.2415\times10^{18}$ electrons flowing per second.</p>
</p>
""",
);
