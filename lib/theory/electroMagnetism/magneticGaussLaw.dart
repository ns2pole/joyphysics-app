import '../../model.dart';

final magneticGaussLaw = TheoryTopic(
  title: '磁場のガウスの法則',
  latexContent: r"""
<div class="theory-common-box">磁場とガウスの法則</div>
<p>単独の磁荷は存在しない為、磁場は湧き出したり吸い込まれたりすることはない。
そのため、磁場 $\vec{B}$ は常に閉じたループを形成し、閉曲面を通る磁束の総和は常にゼロである。  
\[
\oint_{S} \vec{B} \cdot d\vec{S} = 0
\]
</p>
"""
);