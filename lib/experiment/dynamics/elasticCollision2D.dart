import '../../model.dart'; // Videoクラス定義が別ならインポート
final elasticCollision2D = Video(
  isExperiment: true,
  category: 'dynamics', // ← 追加
  iconName: 'elasticCollision2D',
  title: '弾性衝突(2次元)',
  titleEn: 'Elastic collision (2D)',
  videoURL: 'UU2CRiPpxDQ',
  equipment: ['10円玉'],
  equipmentEn: ['10-yen coin'],
  costRating: '★☆☆',
  latex: r"""
<div class="common-box">ポイント</div>
<p>・運動量保存則:$\displaystyle m_1\overrightarrow{v_1} + m_2\overrightarrow{v_2} = m_1\overrightarrow{v_1'} + m_2\overrightarrow{v_2'}$</p>
<p>・力学的エネルギー保存則:$\displaystyle \frac12 m_1 |\overrightarrow{v_1}|^2 + \frac12 m_2 |\overrightarrow{v_2}|^2 = \frac12 m_1 |\overrightarrow{v_1'}|^2 + \frac12 m_2 |\overrightarrow{v_2'}|^2$</p>
<p>$m_1$, $m_2$：質量, $\overrightarrow{v_1}$, $\overrightarrow{v_2}$：衝突前の速度, $\overrightarrow{v_1'}$, $\overrightarrow{v_2'}$：衝突後の速度</p>

<div class="common-box">問題設定</div>
<p>静止している質量$m$の物体に対して、同じ質量$m$の物体が速度$\overrightarrow{v}$で弾性衝突した場合、衝突後の2つの速度ベクトル$\overrightarrow{v_1}, \overrightarrow{v_2}$のなす角度を求めて下さい。</p>
<div style="text-align:center; margin:1em 0;">
  <img src="assets/dynamicsDetail/elasticCollision2D.png"
       alt="2次元弾性衝突"
       style="max-width:100%; height:auto;" />
</div>
<div class="common-box">理論計算</div>
<p>まず、2次元における運動量保存（ベクトル式）は次のように表される。</p>
$$\begin{aligned}
m \overrightarrow{v} &= m \overrightarrow{v_1} + m \overrightarrow{v_2} \\
\Longleftrightarrow \overrightarrow{v} &= \overrightarrow{v_1} + \overrightarrow{v_2}.
\end{aligned}$$

<p>また、弾性衝突では力学的エネルギーも保存されるので、</p>
$$\begin{aligned}
\frac{1}{2} m |\overrightarrow{v}|^2
&= \frac{1}{2} m |\overrightarrow{v_1}|^2 + \frac{1}{2} m |\overrightarrow{v_2}|^2 \\
\Longleftrightarrow |\overrightarrow{v}|^2 &= |\overrightarrow{v_1}|^2 + |\overrightarrow{v_2}|^2.
\end{aligned}$$
<p>この2つの条件を同時に満たすとき、衝突後の2つの速度がどちらも $0$ でなければ、それらは直角（90°）をなす。正面衝突では、止まっていた物体が $\overrightarrow{v}$ を受け取り、当たった物体は止まる。</p>
""",
  latexEn: r"""
<div class="common-box">Key points</div>
<p>・Conservation of momentum: $\displaystyle m_1\overrightarrow{v_1} + m_2\overrightarrow{v_2} = m_1\overrightarrow{v_1'} + m_2\overrightarrow{v_2'}$</p>
<p>・Conservation of mechanical energy: $\displaystyle \frac12 m_1 |\overrightarrow{v_1}|^2 + \frac12 m_2 |\overrightarrow{v_2}|^2 = \frac12 m_1 |\overrightarrow{v_1'}|^2 + \frac12 m_2 |\overrightarrow{v_2'}|^2$</p>
<p>$m_1$, $m_2$: masses; $\overrightarrow{v_1}$, $\overrightarrow{v_2}$: velocities before collision; $\overrightarrow{v_1'}$, $\overrightarrow{v_2'}$: velocities after collision</p>

<div class="common-box">Setup</div>
<p>An object of mass $m$ at rest is struck elastically by another object of the same mass $m$ with velocity $\overrightarrow{v}$. Find the angle between the two post-collision velocity vectors $\overrightarrow{v_1}$ and $\overrightarrow{v_2}$.</p>
<div style="text-align:center; margin:1em 0;">
  <img src="assets/dynamicsDetail/elasticCollision2D.png"
       alt="2D elastic collision"
       style="max-width:100%; height:auto;" />
</div>
<div class="common-box">Theory</div>
<p>Conservation of momentum in 2D (vector form) reads</p>
$$\begin{aligned}
m \overrightarrow{v} &= m \overrightarrow{v_1} + m \overrightarrow{v_2} \\
\Longleftrightarrow \overrightarrow{v} &= \overrightarrow{v_1} + \overrightarrow{v_2}.
\end{aligned}$$

<p>For an elastic collision, mechanical energy is also conserved:</p>
$$\begin{aligned}
\frac{1}{2} m |\overrightarrow{v}|^2
&= \frac{1}{2} m |\overrightarrow{v_1}|^2 + \frac{1}{2} m |\overrightarrow{v_2}|^2 \\
\Longleftrightarrow |\overrightarrow{v}|^2 &= |\overrightarrow{v_1}|^2 + |\overrightarrow{v_2}|^2.
\end{aligned}$$
<p>When both conditions hold and neither post-collision velocity is zero, the two velocities are at right angles (90°). In a head-on collision, the initially resting object takes $\overrightarrow{v}$ and the striking object stops.</p>
"""
);
