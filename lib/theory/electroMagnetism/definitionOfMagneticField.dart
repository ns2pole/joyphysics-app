import '../../model.dart';

final definitionOfMagneticField = TheoryTopic(
  title: '磁束密度の定義',
  titleEn: 'Definition of magnetic flux density',
  imageAsset: 'assets/mindMap/forTopics/definitionOfMagneticField.png',

  latexContent: r"""
<div class="theory-common-box">定義（磁束密度の大きさ）</div>
・長さ $\ell$ の導線に電流 $I_0$ が流れる時、導線に働く力 $\vec{F}$ によって、磁束密度の大きさ$|\vec B|$を下記の通り定義する。
$$
\vec{B} = \frac{\vec{F}}{I_0 \ell}
$$
<div class="theory-common-box">定義（磁束密度の向き）</div>
・磁束密度の向きは、常に電流の向きと力の向きの両方に垂直とし、右手の法則で定める。
""",
  latexContentEn: r"""
<div class="theory-common-box">Definition (magnitude of magnetic flux density)</div>
•When a current $I_0$ flows in a wire of length $\ell$, the magnitude $|\vec B|$ of the magnetic flux density is defined from the force $\vec{F}$ on the wire as follows.
$$
\vec{B} = \frac{\vec{F}}{I_0 \ell}
$$
<div class="theory-common-box">Definition (direction of magnetic flux density)</div>
•The direction of the magnetic flux density is always perpendicular to both the current and the force, and is fixed by the right-hand rule.
""",
);