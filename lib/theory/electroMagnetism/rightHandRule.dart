

// faraday_electromagnetic_induction_law.dart
import '../../model.dart';


final rightHandRule = TheoryTopic(
  title: '右手則,右ねじの法則',
  titleEn: 'Right-hand rule and right-handed screw rule',
  imageAsset: 'assets/mindMap/forTopics/rightHandRule.png',
  inPreparation: true,
  latexContent: r"""
  <div class="theory-common-box">定義（右手則）</div>
  $\vec{n}$ の方向に右手の親指を立てたとき、指の巻き方向が境界の正方向。
  """,
  latexContentEn: r"""
  <div class="theory-common-box">Definition (right-hand rule)</div>
  When the thumb of the right hand points in the direction of $\vec{n}$, the curling direction of the fingers gives the positive orientation of the boundary.
  """,
);