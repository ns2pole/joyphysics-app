import '../../model.dart';

final electoricGaussLawInMatter = TheoryTopic(
  title: '電場のガウスの法則',
  titleEn: 'Gauss\'s law for the electric field (in matter)',
  imageAsset: 'assets/mindMap/forTopics/electoricGaussLawInMatter.png',

  latexContent: r"""
<div class="theory-common-box">定理（線形媒質中の電場のガウスの法則）：電荷の種類を自由電荷$Q_{free}$と誘電体の中で束縛されている束縛電荷$Q_{bound}$に分けるとすると、
線形媒質物質中の電束密度は下記の物質中のマクスウェル方程式を満たす。
$$
\oint_{S}\vec{E}\cdot d\vec{S}=\frac{1}{\varepsilon}\sum_{S内部}Q_{free}
$$
</div>
<div class="proof-box">証明</div>
真空中のマクスウェル方程式より、
線形媒質による分極の効果で、
<p>

<div class="theory-common-box">定理（物質中の電場のガウスの法則）：電荷の種類を自由電荷$Q_{free}$と誘電体の中で束縛されている束縛電荷$Q_{bound}$に分けるとすると、
線形媒質物質中の電束密度は下記の物質中のマクスウェル方程式を満たす。
$$
\oint_{S}\vec{D}\cdot d\vec{S}=Q_{free}
$$
</div>
<div class="proof-box">証明</div>
<p>

""",
  latexContentEn: r"""
<div class="theory-common-box">Theorem (Gauss's law for the electric field in a linear medium): Separating charge into free charge $Q_{free}$ and bound charge $Q_{bound}$ in a dielectric,
the electric displacement in a linear medium satisfies the following Maxwell equation in matter.
$$
\oint_{S}\vec{E}\cdot d\vec{S}=\frac{1}{\varepsilon}\sum_{\text{inside }S}Q_{free}
$$
</div>
<div class="proof-box">Proof</div>
From Maxwell's equations in vacuum,
accounting for polarization in a linear medium,
<p>

<div class="theory-common-box">Theorem (Gauss's law for the electric field in matter): Separating charge into free charge $Q_{free}$ and bound charge $Q_{bound}$ in a dielectric,
the electric displacement in a linear medium satisfies the following Maxwell equation in matter.
$$
\oint_{S}\vec{D}\cdot d\vec{S}=Q_{free}
$$
</div>
<div class="proof-box">Proof</div>
<p>

""",
);