import '../../model.dart';

final fookEnergyConservation = TheoryTopic(
  title: '単振動のエネルギー保存',
  isNew: true,
  latexContent: r"""
<div class="theory-common-box">命題（単振動エネルギー保存）：
運動方程式$mx''(t)= -kx(t)$が成り立つ時、
\begin{aligned}
E = \frac{1}{2}mv(t)^2 + \frac {1}{2}kx(t)^2
\end{aligned}
は時間によらず一定値である。
</div>

<p><div class="proof-box">証明</div>
時間微分が0になることを示せば良い。
両辺に \(x'(t)\) を掛けると
\begin{aligned}
\ \ \ \ \ \ \ & mx'(t)x''(t) = -kx'(t)x(t) \\[6pt]
\Leftrightarrow \ &\Bigl[\frac{1}{2}mx'(t)^2\Bigr]' = -\Bigl[\frac{1}{2}k x(t)^2\Bigr]' \\[6pt]
\Leftrightarrow \ &\Bigl[\frac{1}{2}mx'(t)^2 + \frac {1}{2}k x(t)^2\Bigr]' = 0
\end{aligned}
Q.E.D.
</p>
"""
);