import '../../model.dart';

final electoricGaussLaw = TheoryTopic(
  title: '電場のガウスの法則',
  latexContent: r"""
<div class="theory-common-box">電荷と電場とガウスの法則</div>
<p>正の電荷からは電場が湧き出し、負の電荷は電場を吸い込む。それゆえ、閉曲面を通る電場の総流束（外向き正）は、その閉曲面の内部に含まれる全電荷 $\displaystyle \sum_{S内部} Q$ に比例する。<br>
※比例定数は真空の誘電率 $\varepsilon_0$ の逆数である。
\[
\oint_{S} \vec{E}\cdot d\vec{S} = \frac{1}{\varepsilon_0} \displaystyle \sum_{S内部} Q
\]
</p>
""",
);
