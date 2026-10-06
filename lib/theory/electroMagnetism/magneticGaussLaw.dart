import '../../model.dart';

final magneticGaussLaw = TheoryTopic(
  title: '磁場のガウスの法則',
  titleEn: 'Gauss\'s law for the magnetic field',
  imageAsset: 'assets/mindMap/forTopics/magneticGaussLaw.png',
  latexContent: r"""
<div class="theory-common-box">法則（磁場のガウスの法則）：任意の閉曲面$S$に対し、下記が成り立つ。この法則を磁場のガウスの法則という。
$$
\oint_{S} \vec{B} \cdot d\vec{S} = 0
$$
</div>
<div class="paragraph-box">説明</div><br>

・右辺：閉曲面を通る磁場の総流束（外向き正）<br>
・単独の磁荷は存在しない為、磁場が湧き出したり吸い込まれたりすることはない。そのため、磁場 $\vec{B}$ は常に閉じたループを形成し、閉曲面を通る磁束（磁場の流束）は常にゼロとなる<br>
※ 磁場のガウスの法則は勿論物質中でも成り立つのだが、電流や電荷を自由に動ける自由電子によるものと、そうでない束縛された電子によるものに分けて議論し、$\vec D, H$を用いた表式を変える事がよく行われる。
""",
  latexContentEn: r"""
<div class="theory-common-box">Law (Gauss's law for the magnetic field): For any closed surface $S$, the following holds. This is called Gauss's law for the magnetic field.
$$
\oint_{S} \vec{B} \cdot d\vec{S} = 0
$$
</div>
<div class="paragraph-box">Explanation</div><br>

•Right-hand side: the net magnetic flux through the closed surface (outward positive)<br>
•Because isolated magnetic charges do not exist, magnetic field lines neither begin nor end. Hence $\vec{B}$ always forms closed loops, and the magnetic flux through any closed surface is always zero<br>
※ Gauss's law for the magnetic field also holds in matter; it is often rewritten using $\vec D$ and $\vec H$ after separating free and bound contributions of currents and charges.
""",
);