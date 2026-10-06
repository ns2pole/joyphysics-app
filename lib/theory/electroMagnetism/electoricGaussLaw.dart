import '../../model.dart';

final electoricGaussLaw = TheoryTopic(
  title: '電場のガウスの法則',
  titleEn: 'Gauss\'s law for the electric field',
  imageAsset: 'assets/mindMap/forTopics/electoricGaussLaw.png',

  latexContent: r"""
<div class="theory-common-box">法則（電荷と電場とガウスの法則）：任意の閉曲面$S$に対し、下記が成り立つ。この法則を電場のガウスの法則という。
$$
\oint_{S} \vec{E}\cdot d\vec{S} = \frac{1}{\varepsilon_0} \displaystyle \sum_{S内部} Q
$$
※$\varepsilon_0 = \fallingdotseq 8.854 \times 10^{-12}\ \mathrm{F/m}$ : 真空の誘電率(定数)

</div>
<div class="paragraph-box">説明</div><br>
・右辺：閉曲面を通る電場の総流束（外向き正）<br>
・左辺：閉曲面の内部に含まれる全電気量<br>
・電場のガウスの法則は正の電荷からは電場が湧き出し、負の電荷は電場を吸い込む事を表している。<br>
・電場の総流束は閉曲面内部に含まれる全電気量に比例し、比例定数は真空の誘電率$\varepsilon_0$の逆数である。<br>
※ 電場のガウスの法則は勿論物質中でも成り立つのだが、物質中の電磁場については自由に動くことのできる自由電子の電荷と、そうでない誘電体の中の電荷に分けて$\vec D$を用いた表式に変える事がよく行われる。
""",
  latexContentEn: r"""
<div class="theory-common-box">Law (Gauss's law for charge and the electric field): For any closed surface $S$, the following holds. This is called Gauss's law for the electric field.
$$
\oint_{S} \vec{E}\cdot d\vec{S} = \frac{1}{\varepsilon_0} \displaystyle \sum_{\text{inside }S} Q
$$
※$\varepsilon_0 = \fallingdotseq 8.854 \times 10^{-12}\ \mathrm{F/m}$ : permittivity of free space (a constant)

</div>
<div class="paragraph-box">Explanation</div><br>
•Left-hand side: the net electric flux through the closed surface (outward positive)<br>
•Right-hand side: the total charge enclosed by the surface<br>
•Gauss's law for the electric field states that positive charge is a source of electric field lines and negative charge is a sink.<br>
•The net electric flux is proportional to the total enclosed charge, with proportionality constant equal to the reciprocal of the vacuum permittivity $\varepsilon_0$.<br>
※ The law also holds in matter; in material media one often rewrites it using $\vec D$ after separating free charges from bound charges in dielectrics.
""",
);