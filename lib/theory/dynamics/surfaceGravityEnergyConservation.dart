import '../../model.dart';

final surfaceGravityEnergyConservation = TheoryTopic(
  title: '地上の重力下のエネルギー保存',
  isNew: true,
  latexContent: r"""
<div class="theory-common-box">命題（地上の重力下のエネルギー保存）：
運動方程式$mx''(t)= mg$が成り立つ時、
\begin{aligned}
E = \frac{1}{2}mv(t)^2 -mgx(t)
\end{aligned}
は時間によらず一定値である。
</div>
<p><div class="proof-box">証明</div>
時間微分が0になることを示せば良い。
両辺に \(x'(t)\) を掛けると
\begin{aligned}
\ \ \ \ \ \ \ &mx'(t)x''(t) = mgx'(t) \\[6pt]
\Leftrightarrow \ &\Bigl[\frac{1}{2}mx'(t)^2\Bigr]' = \bigl[m g x(t)\bigr]' \\[6pt]
\Leftrightarrow \ &\Bigl[\frac{1}{2}mx'(t)^2 - mgx(t)\Bigr]' = 0
\end{aligned}
Q.E.D.
</p>
"""
);