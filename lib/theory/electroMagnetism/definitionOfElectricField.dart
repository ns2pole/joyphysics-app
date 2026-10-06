import '../../model.dart';

final definitionOfElectricField = TheoryTopic(
  title: '電場の定義',
  titleEn: 'Definition of the electric field',
  imageAsset: 'assets/mindMap/forTopics/definitionOfElectricField.png',

  latexContent: r"""
<div class="theory-common-box">定義（電場の大きさ）</div>
・磁場 $\vec{B}$ が存在しない場合、点電荷 $q$ に働く力 $\vec{F}$ から電場 $\vec{E}$ の大きさを下記の通り定義する。
$$
\vec{E} = \frac{\vec{F}}{q}
$$
※ この定義は 電荷 $q$ が既知としている。

<div class="theory-common-box">定義（電場の向き）</div>
・電場の向きは、正の電荷に働く力の向きと同じとする。<br>
・負の電荷の場合、力の向きは電場の向きと逆になる。
""",
  latexContentEn: r"""
<div class="theory-common-box">Definition (magnitude of the electric field)</div>
•When no magnetic field $\vec{B}$ is present, the magnitude of the electric field $\vec{E}$ is defined from the force $\vec{F}$ on a point charge $q$ as follows.
$$
\vec{E} = \frac{\vec{F}}{q}
$$
※ This definition assumes that the charge $q$ is known.

<div class="theory-common-box">Definition (direction of the electric field)</div>
•The direction of the electric field is the same as the direction of the force on a positive charge.<br>
•For a negative charge, the force is opposite to the electric field.
""",
);
