import '../../model.dart';

final collisionConservation = TheoryTopic(
  title: '衝突における運動量保存',
  isNew: false,
  latexContent: r"""

<div class="theory-common-box">記法,記号の定義</div>
<ul>
<li>衝突で質点1から質点2に対して働く力：$\overrightarrow{F_{2 \leftarrow 1} }(t)$
<li>衝突で質点2から質点1に対して働く力：$\overrightarrow{F_{1 \leftarrow 2} }(t)$とする。
<li>衝突の最中に質点1に働く外力を$\overrightarrow{f_1}(t)$
<li>衝突の最中に質点2に働く外力を$\overrightarrow{f_2}(t)$と表す。
<li>衝突開始時刻:$t_0$
<li>衝突終了時刻:$t_1$
</ul>
<div class="theory-common-box">命題：2物体の衝突において、衝突の時間が十分短いと見做せるならば、衝突の前後で運動量が保存する。</div>

<p><div class="proof-box">証明</div>
衝突で働く力は、2物体間の力なので、作用・反作用の法則を適用できる。

\begin{aligned}
\begin{cases}
m_1 \overrightarrow{a_1}(t) = \overrightarrow{F_{1 \leftarrow 2} }(t) + \overrightarrow{f_1}(t) \\[6pt] 
m_2 \overrightarrow{a_2}(t) = -\overrightarrow{F_{1 \leftarrow 2} }(t) + \overrightarrow{f_2}(t) 
\end{cases}
\end{aligned}
両式の和を取ると、
$m_1 \overrightarrow{a_1}(t) + m_2 \overrightarrow{a_2}(t) =  \overrightarrow{f_1}(t) + \overrightarrow{f_2}(t) $となり、両辺を$t_0\sim t_1$にかけて積分し、
\begin{aligned}
&\ \ \ \ \  \int_{t_0}^{t_1} m_1 \overrightarrow{a_1}(t) + m_2 \overrightarrow{a_2}(t) dt = \int_{t_0}^{t_1}\ \overrightarrow{f_1}(t) + \overrightarrow{f_2}(t)dt \\[8pt]
& \Leftrightarrow \Bigr[ m_1 \overrightarrow{v_1}(t) + m_2 \overrightarrow{v_2}(t) \Bigr]_{t_0}^{t_1} = \int_{t_0}^{t_1}\ \overrightarrow{f_1}(t) + \overrightarrow{f_2}(t)dt  \\[9pt]
& \Leftrightarrow \Bigr( m_1 \overrightarrow{v_1}(t_1) + m_2 \overrightarrow{v_2}(t_1) \Bigr) - \Bigr( m_1 \overrightarrow{v_1}(t_0) + m_2 \overrightarrow{v_2}(t_0) \Bigr)\\[5pt]
& \ \ \ \ \ = \int_{t_0}^{t_1}\ \overrightarrow{f_1}(t) + \overrightarrow{f_2}(t)dt \\[9pt]
&\Leftrightarrow \Bigr( m_1 \overrightarrow{v_1}(t_1) + m_2 \overrightarrow{v_2}(t_1) \Bigr)   \\[5pt]
& \ \ \ \ \ = \Bigr( m_1 \overrightarrow{v_1}(t_0) + m_2 \overrightarrow{v_2}(t_0) \Bigr) + \int_{t_0}^{t_1}\ \overrightarrow{f_1}(t) + \overrightarrow{f_2}(t)dt 
\end{aligned}
ここで、衝突の時間は十分短い事を考え、$t_1 - t_0 \rightarrow 0$の極限を取ると、$\displaystyle \int_{t_0}^{t_1}\ \overrightarrow{f_1}(t) + \overrightarrow{f_2}(t)dt \rightarrow 0$となり、$\displaystyle  m_1 \overrightarrow{v_1}(t_1) + m_2 \overrightarrow{v_2}(t_1)   =  m_1 \overrightarrow{v_1}(t_0) + m_2 \overrightarrow{v_2}(t_0)  \ \ \ $ Q.E.D
"""
);
