import '../../model.dart';

final surfaceGravAndFookEnergyConservation = TheoryTopic(
  title: '地上の重力と弾性力の下でのエネルギー保存',
  isNew: true,
  latexContent: r"""
<div class="theory-common-box">命題（バネと重力が同時に働く系のエネルギー保存）：
運動方程式 $m x''(t) = -kx(t) + mg$ が成り立つ時、
\begin{aligned}
E = \frac{1}{2}m v(t)^2 + \frac{1}{2}k x(t)^2 - mgx(t)
\end{aligned}
は時間によらず一定値である。
</div>

<p><div class="proof-box">証明</div>
時間微分が0になることを示せば良い。両辺に $x'(t)$ を掛けると
\begin{aligned}
\ \ \ \ \ \ \ &m x'(t)x''(t) = -k x(t) x'(t) + mg x'(t) \\[6pt]
\Leftrightarrow \ &\Bigl[\tfrac{1}{2}m \bigl(x'(t)\bigr)^2\Bigr]' = \Bigl[-\tfrac{1}{2}k \bigl(x(t)\bigr)^2 + mg x(t)\Bigr]' \\[6pt]
\Leftrightarrow \ &\Bigl[\tfrac{1}{2}m \bigl(x'(t)\bigr)^2 + \tfrac{1}{2}k \bigl(x(t)\bigr)^2 - mg x(t)\Bigr]' = 0
\end{aligned}
Q.E.D.
</p>

<div class="theory-common-box">補足（座標系の取り方について）</div>
<p style="margin-left:22px; line-height:1.5;">
本命題では鉛直下向きを正に取っているため、エネルギー保存則は
\[
E = \tfrac{1}{2} m v(t)^2 + \tfrac{1}{2} k x(t)^2 - mgx(t)
\]
の形となる。<br>
もし鉛直上向きを正に取るなら、運動方程式は $m x''(t) = -kx(t) - mg$ となり、重力ポテンシャル項は $+mgx(t)$ に変わる。この場合の保存量は
\[
E = \tfrac{1}{2} m v(t)^2 + \tfrac{1}{2} k x(t)^2 + mgx(t)
\]
となる。符号の違いは座標系の取り方によるものであり、物理的な意味は基準エネルギーの定数差にすぎない。
</p>
"""
);