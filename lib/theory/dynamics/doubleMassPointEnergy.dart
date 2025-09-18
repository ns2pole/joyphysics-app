import '../../model.dart';

final doubleMassPointEnergy = TheoryTopic(
  title: '2質点系のエネルギーについての命題',
  isNew: false,
  imageAsset: 'assets/mindMap/forTopics/doubleMassPointEnergy.png', // 実際の画像パス
  latexContent: r"""

<div class="theory-common-box">記法,記号の定義</div>
<ul>
<li>$a:=b\ $：$\ a$を$b$で定義する
<li>2つの質点の質量の合計：$ \displaystyle M := m_1 + m_2$
<li>2つの質点の重心速度：$ \displaystyle \overrightarrow{V}_{\mathrm{cm}} := \frac{m_1\overrightarrow{v}_1 + m_2\overrightarrow{v}_2}{M}$
<li>2つの質点の相対速度：$ \displaystyle \overrightarrow{v}_{\mathrm{rel}} := \overrightarrow{v}_1 - \overrightarrow{v}_2$
<li>2つの質点の重心の速さ：$ \displaystyle {V}_{\mathrm{cm}} := |\overrightarrow{V}_{\mathrm{cm}}|$
<li>2つの質点の相対速さ：$ v_{\mathrm{rel}} :=|\overrightarrow{v}_{\mathrm{rel}} |$
<li>換算質量：$ \displaystyle \mu := \frac{m_1 m_2}{M} = \frac{m_1 m_2}{m_1+m_2}$
</ul>

<div class="theory-common-box">定義(重心運動エネルギー)</div>
<p>
質量$m_1,m_2$の2質点について、重心の速度$\overrightarrow{V}_{\mathrm{cm}}$と質量合計$M$を用いて、重心運動エネルギーを
$\displaystyle K_{\mathrm{cm}} := \frac{1}{2} M V_{\mathrm{cm}}^2$で定義する。
</p>
<div class="theory-common-box">定義(相対運動エネルギー)</div>
<p>
質量$m_1,m_2$の2質点について、相対速度を $\overrightarrow{v}_{\mathrm{rel}}$,換算質量を$\mu$として、相対運動エネルギーを$\displaystyle K_{\mathrm{rel}} := \frac{1}{2} \mu v_{\mathrm{rel}}^2$で定義する。
</p>
<div class="theory-common-box">命題：2物体系の運動エネルギーの全体は、重心運動エネルギーと相対運動エネルギーの和に分解できる：</div>
$$\begin{aligned}
\frac{1}{2} m_1 v_1^2 + \frac{1}{2} m_2 v_2^2
=
\frac{1}{2} M V_{\mathrm{cm}}^2 + \frac{1}{2} \mu v_{\mathrm{rel}}^2
\end{aligned}$$

<p><div class="proof-box">証明</div>
$$\begin{aligned}
&\ \ \ \ \frac12\,M\,{V}_{\mathrm{cm}}^2
+ \frac12\,\mu\,{v}_{\mathrm{rel}}^2 \\[6pt]
&=\frac12\,M\,|\overrightarrow{V}_{\mathrm{cm}}|^2
+ \frac12\,\mu\,|\overrightarrow{v}_{\mathrm{rel}}|^2 \\[6pt]
&= \frac12\,(m_1 + m_2)\,
   \Bigl|\frac{m_1\overrightarrow{v}_1 + m_2\overrightarrow{v}_2}{m_1 + m_2}\Bigr|^2
   + \frac12\,\frac{m_1 m_2}{m_1 + m_2}\,
     |\overrightarrow{v}_1 - \overrightarrow{v}_2|^2\\[6pt]
&= \frac12\,\frac{\bigl|\,m_1\overrightarrow{v}_1 + m_2\overrightarrow{v}_2\,\bigr|^2}{m_1 + m_2}
   + \frac12\,\frac{m_1 m_2}{m_1 + m_2}\,
     \bigl(|\overrightarrow{v}_1|^2 - 2\,\overrightarrow{v}_1\!\cdot\!\overrightarrow{v}_2 + |\overrightarrow{v}_2|^2\bigr)\\[6pt]
&= \frac12\frac{m_1^2|\overrightarrow{v}_1|^2 + 2m_1m_2\,\overrightarrow{v}_1\!\cdot\!\overrightarrow{v}_2
              + m_2^2|\overrightarrow{v}_2|^2
        + m_1m_2|\overrightarrow{v}_1|^2 - 2m_1m_2\,\overrightarrow{v}_1\!\cdot\!\overrightarrow{v}_2+ m_1m_2|\overrightarrow{v}_2|^2}{m_1 + m_2}\\[6pt]
&= \frac12\frac{m_1(m_1 + m_2)|\overrightarrow{v}_1|^2 + m_2(m_1 + m_2)|\overrightarrow{v}_2|^2}{m_1 + m_2}\\[6pt]
&= \frac12\,m_1\,|\overrightarrow{v}_1|^2+ \frac12\,m_2\,|\overrightarrow{v}_2|^2\\[6pt]
&= \frac12\,m_1\,{v}_1^2+ \frac12\,m_2\,{v}_2^2
\end{aligned}$$
　　Q.E.D</p>
"""
);
