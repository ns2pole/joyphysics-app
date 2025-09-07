import '../../model.dart';

final conicalPendulum = TheoryTopic(
  title: '円錐振り子の周期',
  isNew: false,
  latexContent: r"""
<div class="theory-common-box">命題：図1の条件設定(円錐振り子,錘は水平に等速円運動)しているとすると、錘の周期$\ T \$は下記となる。
$$
\displaystyle T = 2\pi \sqrt {\frac{L \cos \theta }{g}}\ [s]
$$
<div style="text-align:center; margin:1em 0;">
    <img src="assets/dynamicsTheory/conicalPendulum.png"
          alt="回帰直線"
          style="max-width:75%; height:auto;" />
  </div>
</div>
<p><div class="proof-box">証明</div>
物体に働く鉛直方向の力は釣り合っているので、糸の張力を ${T \ [N]} $として
$$\displaystyle mg = T \cos \theta\ \Leftrightarrow \ T = \frac{mg}{\cos \theta} \ \cdots (1) $$
物体が等速円運動しているとすると、円の半径は ${r = L \sin \theta \ [m]} $であるので、向心方向運動方程式より
$$
\displaystyle m\frac{v^2}{r} = T\sin \theta  \\ \ \\\Leftrightarrow m\frac{v^2}{L \sin \theta } = T\sin \theta \ \cdots (2)
$$
${(1)} $を ${(2)} $に代入して、

\begin{aligned}
\ \ \ \ \ &\displaystyle m\frac{v^2}{L \sin \theta } = mg\frac{ \sin \theta }{\cos \theta}  \\[6pt]
\Leftrightarrow \ \ &\frac{v^2}{L \sin \theta } = g \tan \theta\\[6pt]
\Leftrightarrow \ \ &v^2 = g L \sin \theta \tan \theta \\[6pt]
\Leftrightarrow \ \ &v = \sqrt{g L \sin \theta \tan \theta} \ [m\cdot s^{-1}] \ \cdots (3)
\end{aligned}
ここで円錐振り子の周期は、$\displaystyle T = \frac{2\pi r}{v} \ [s]$で表せるので、結局 ${(3)} $より、
\begin{aligned}
T &= \frac{2\pi r}{v} \\[6pt]
 &= \frac{2\pi L \sin \theta }{\sqrt{g L \sin \theta \tan \theta}} \\[6pt]
 &= 2\pi \sqrt {\frac{L \sin \theta }{g \tan \theta}} \\[6pt]
 &= 2\pi \sqrt {\frac{L \cos \theta }{g}} \ [s]
\end{aligned}

Q.E.D

</p>
"""
);
