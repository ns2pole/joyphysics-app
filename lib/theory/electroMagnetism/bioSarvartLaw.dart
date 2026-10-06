import '../../model.dart';

final biotSavartLaw = TheoryTopic(
  title: 'ビオ・サバールの法則',
  titleEn: 'Biot–Savart law',
  videoURL: "",
  inPreparation: true,
  imageAsset: 'assets/mindMap/forTopics/biotSavartLaw.png',
  latexContent: r"""

<div class="theorem-box">命題（概要）</div>

本項では，ビオ・サバール則を **（1）記号を丁寧に定義する →（2）有限和（リーマン和）の形で書く →（3）その極限が線積分（積分表現）に収束する** という順で、分かりやすく示します。  
最後に円形ループでの具体例（軸上評価：任意 \(z\) と特に \(z=0\)）を丁寧に計算し、数値実装上の注意点もまとめます。

---

<div class="theory-common-box">記号と前提（やさしく）</div>

- \(C\)：向き付きの導線の軌跡（曲線）。曲線は区分的に滑らか（piecewise smooth）であると仮定します。  
- \(I\)：導線を流れる（定常）電流（定数）。  
- \(\mathbf r\)：磁場を評価する観測点。解析では観測点が導線上にない（分母がゼロとならない）ことを仮定します。  
- \(\mathbf r' \in C\)：導線上の任意の点（位置ベクトル）。  
- \(d\boldsymbol\ell'\)：導線に沿った向き付き微小線素ベクトル（向きと長さを持つ）。  
- \(\Delta\boldsymbol\ell_k\)：有限分割したときの \(k\) 番目の線素（差分ベクトル）：\(\Delta\boldsymbol\ell_k = \mathbf r'_{k+1}-\mathbf r'_k\)。  
- \(|\cdot|\)：ユークリッドノルム（長さ）。  
- \(\mu_0\)：真空の透磁率（数値 \(\mu_0=4\pi\times10^{-7}\ \mathrm{H/m}\)）。

---

<div class="theory-common-box">1. ビオ・サバール則を「有限和（リーマン和）」で書く — 直感と定式化</div>

**直感（何をしているか）**：導線を細かい小区間に切り、それぞれの微小電流要素が観測点に与える微小な磁場を計算して足し合わせます。これが「有限和」の形です。分割を細かくすれば真の値に近づきます。

**有限和（リーマン和）の定式**：曲線 \(C\) をノード \(\{\mathbf r'_0,\mathbf r'_1,\dots,\mathbf r'_N\}\) で分割し、各線素を \(\Delta\boldsymbol\ell_k=\mathbf r'_{k+1}-\mathbf r'_k\) とする。観測点 \(\mathbf r\) に対する有限近似は
$$
\boxed{%
\mathbf B_N(\mathbf r)
\;=\;
\sum_{k=0}^{N-1}
\frac{\mu_0}{4\pi}\,
\frac{I\,\Delta\boldsymbol\ell_k\times(\mathbf r-\mathbf r'_k)}
{|\mathbf r-\mathbf r'_k|^3}.
}
$$

- これは **各区間の「微小電流要素」\(I\Delta\boldsymbol\ell_k\)** が観測点に与える磁場を単純に足し合わせたものです。  
- ノードの取り方（どのように分割するか）は任意ですが、分割を細かくすることでより正確になります（次の節で極限を取ります）。

---

<div class="theory-common-box">2. 極限（線積分への移行） — なぜ積分になるか（直観）</div>

- 分割の最大区間長 \(\max_k|\Delta\boldsymbol\ell_k|\) が \(0\) に近づく（\(N\to\infty\)）とき、\(\Delta\boldsymbol\ell_k\) は真の微小線素 \(d\boldsymbol\ell'\) に近づく。  
- したがってリーマン和 \(\mathbf B_N(\mathbf r)\) は線積分に収束し、次が成り立ちます：

$$
\boxed{%
\mathbf B(\mathbf r)
=\lim_{N\to\infty}\mathbf B_N(\mathbf r)
= \frac{\mu_0 I}{4\pi} \int_{C}\frac{d\boldsymbol\ell'\times(\mathbf r-\mathbf r')}{|\mathbf r-\mathbf r'|^3}.
}
$$

**注（再パラメータ化不変性）**：上の線積分はパラメータ化に依存しません。もし便宜上パラメータ \(\xi\) を導入して \( \mathbf r'=\mathbf r'(\xi)\) と書いても、置き換え \(\xi=\xi(\eta)\) を行えば \(d\boldsymbol\ell'=\dfrac{d\mathbf r'}{d\xi}d\xi=\dfrac{d\mathbf r'}{d\eta}d\eta\) となり値は変わりません。これが「パラメータに本来依らない」ことの数学的な説明です。

---

<div class="theory-common-box">3. 円形ループの具体例（手順を丁寧に）</div>

**状況**：半径 \(R\) の円形導線に電流 \(I\) が流れる。観測点は軸上 \(\mathbf r=(0,0,z)\)（任意の \(z\)）とする。  

**ステップ 1 — 幾何**：円を角度 \(\phi\) で表す（ここは「計算の便宜」のためのパラメータ）：
$$
\mathbf r'(\phi) = \begin{pmatrix} R\cos\phi \\[4pt] R\sin\phi \\[4pt] 0 \end{pmatrix},\qquad
\frac{d\mathbf r'}{d\phi} = \begin{pmatrix} -R\sin\phi \\[4pt] R\cos\phi \\[4pt] 0 \end{pmatrix}.
$$

**ステップ 2 — 分母（距離）**：
$$
\begin{aligned}
\mathbf r - \mathbf r'(\phi) = \begin{pmatrix} -R\cos\phi \\[4pt] -R\sin\phi \\[4pt] z \end{pmatrix}\\[6pt]
|\mathbf r - \mathbf r'(\phi)| = \sqrt{R^2 + z^2}.
\end{aligned}
$$
→ ここで重要な点：分母は**\(\phi\) に依らない**（円対称性の効果）。これが積分を大幅に簡単にします。

**ステップ 3 — 分子（クロス積）**：
直接計算すると
$$
\begin{aligned}

\frac{d\mathbf r'}{d\phi}\times(\mathbf r-\mathbf r'(\phi))
= R^2\,\hat{\mathbf z} + Rz(\cos\phi\,\hat{\mathbf x} + \sin\phi\,\hat{\mathbf y}).
\end{aligned}

$$

**ステップ 4 — 角方向成分の消去**：  
\(\cos\phi\) および \(\sin\phi\) を \(0\) から \(2\pi\) まで積分すると消えるので（またはリーマン和で合計してもゼロ）残るのは \(\hat{\mathbf z}\) 成分のみ。

**ステップ 5 — 積分（解析解）**：
被積分関数は \(\phi\) に依らない部分 \(R^2/(R^2+z^2)^{3/2}\) を持つので
$$
B_z(z) = \frac{\mu_0 I}{4\pi} \int_0^{2\pi} \frac{R^2}{(R^2+z^2)^{3/2}}\, d\phi
= \frac{\mu_0 I R^2}{4\pi (R^2+z^2)^{3/2}} \cdot 2\pi
= \frac{\mu_0 I R^2}{2(R^2+z^2)^{3/2}}.
$$

**特別なケース \(z=0\)**：
$$
B_z(0) = \frac{\mu_0 I R^2}{2(R^2)^{3/2}} = \frac{\mu_0 I}{2R}.
$$

---

<div class="theory-common-box">4. 有限和（リーマン和）を数値で使う場合の実務メモ</div>

- **中点ルール**（各区間の中点で評価する）は実装が簡単で安定的。公式では \(\phi_k^*=(k+\tfrac12)\Delta\phi\) を用いる。  
- **収束確認**：分割数 \(N\) を増やして結果が安定するか確認する（例：N=32,128,512 で比較）。  
- **特異点処理**：観測点が導線上に近い場合は分母が小さくなり数値発散する。実装では近傍区間を解析的に処理するか、principal value を取る工夫が必要。  
- **計算効率**：ループは独立なので並列化（Isolate 等）で高速化可能。  
- **精度向上**：中点法で不十分な場合は台形則・Simpson などを検討。

---

<div class="remark-box">5. 最後に（丁寧なまとめ）</div>

- ビオ・サバール則は **「微小電流要素の寄与を足し合わせる」** という直感そのままにリーマン和で表現できます。  
- その有限和が十分に細かい分割の極限で線積分に収束することが、数学的にも物理的にも自然な流れです。  
- パラメータ導入は計算の便宜に過ぎず、線積分という形式に戻せば「パラメータに依らない」ことが明確です。  
- 円形ループの軸上評価は対称性により非常に簡単になり、解析解も得られるため数値実装の検算に最適です。

""",
  latexContentEn: r"""

<div class="theorem-box">Proposition (overview)</div>

In this article we present the Biot–Savart law in a clear order: **(1) define the symbols carefully → (2) write it as a finite sum (Riemann sum) → (3) show that the limit converges to a line integral (integral form)**.
Finally we compute a concrete example for a circular loop (on-axis evaluation: arbitrary \(z\) and especially \(z=0\)), and summarize practical notes for numerical implementation.

---

<div class="theory-common-box">Symbols and assumptions (gentle introduction)</div>

- \(C\): oriented path of the wire (a curve). We assume the curve is piecewise smooth.
- \(I\): (steady) current in the wire (a constant).
- \(\mathbf r\): observation point where the magnetic field is evaluated. In the analysis we assume the observation point does not lie on the wire (so the denominator does not vanish).
- \(\mathbf r' \in C\): an arbitrary point on the wire (position vector).
- \(d\boldsymbol\ell'\): oriented infinitesimal line-element vector along the wire (has direction and length).
- \(\Delta\boldsymbol\ell_k\): the \(k\)-th line element after a finite partition (difference vector): \(\Delta\boldsymbol\ell_k = \mathbf r'_{k+1}-\mathbf r'_k\).
- \(|\cdot|\): Euclidean norm (length).
- \(\mu_0\): vacuum permeability (numerical value \(\mu_0=4\pi\times10^{-7}\ \mathrm{H/m}\)).

---

<div class="theory-common-box">1. Writing the Biot–Savart law as a finite sum (Riemann sum) — intuition and formulation</div>

**Intuition (what we are doing)**: Cut the wire into small segments, compute the tiny magnetic field that each current element produces at the observation point, and add them up. That is the “finite-sum” form. Making the partition finer brings the result closer to the true value.

**Finite-sum (Riemann-sum) formulation**: Partition the curve \(C\) by nodes \(\{\mathbf r'_0,\mathbf r'_1,\dots,\mathbf r'_N\}\), and set each line element to \(\Delta\boldsymbol\ell_k=\mathbf r'_{k+1}-\mathbf r'_k\). The finite approximation at the observation point \(\mathbf r\) is
$$
\boxed{%
\mathbf B_N(\mathbf r)
\;=\;
\sum_{k=0}^{N-1}
\frac{\mu_0}{4\pi}\,
\frac{I\,\Delta\boldsymbol\ell_k\times(\mathbf r-\mathbf r'_k)}
{|\mathbf r-\mathbf r'_k|^3}.
}
$$

- This simply adds the magnetic field that each segment’s **“current element” \(I\Delta\boldsymbol\ell_k\)** produces at the observation point.
- The choice of nodes (how you partition) is arbitrary, but refining the partition makes the result more accurate (we take the limit in the next section).

---

<div class="theory-common-box">2. The limit (passage to a line integral) — why it becomes an integral (intuition)</div>

- When the maximum segment length \(\max_k|\Delta\boldsymbol\ell_k|\) approaches \(0\) (\(N\to\infty\)), \(\Delta\boldsymbol\ell_k\) approaches the true infinitesimal line element \(d\boldsymbol\ell'\).
- Therefore the Riemann sum \(\mathbf B_N(\mathbf r)\) converges to a line integral, and the following holds:

$$
\boxed{%
\mathbf B(\mathbf r)
=\lim_{N\to\infty}\mathbf B_N(\mathbf r)
= \frac{\mu_0 I}{4\pi} \int_{C}\frac{d\boldsymbol\ell'\times(\mathbf r-\mathbf r')}{|\mathbf r-\mathbf r'|^3}.
}
$$

**Note (reparameterization invariance)**: The line integral above does not depend on the parameterization. Even if, for convenience, one introduces a parameter \(\xi\) and writes \(\mathbf r'=\mathbf r'(\xi)\), after a change of parameter \(\xi=\xi(\eta)\) one has \(\displaystyle d\boldsymbol\ell'=\frac{d\mathbf r'}{d\xi}d\xi=\frac{d\mathbf r'}{d\eta}d\eta\), so the value is unchanged. This is the mathematical reason that the integral “does not intrinsically depend on the parameter.”

---

<div class="theory-common-box">3. Concrete example: circular loop (step by step)</div>

**Setup**: A circular wire of radius \(R\) carries current \(I\). The observation point is on the axis, \(\mathbf r=(0,0,z)\) (arbitrary \(z\)).

**Step 1 — Geometry**: Parameterize the circle by the angle \(\phi\) (a parameter chosen for computational convenience):
$$
\mathbf r'(\phi) = \begin{pmatrix} R\cos\phi \\[4pt] R\sin\phi \\[4pt] 0 \end{pmatrix},\qquad
\frac{d\mathbf r'}{d\phi} = \begin{pmatrix} -R\sin\phi \\[4pt] R\cos\phi \\[4pt] 0 \end{pmatrix}.
$$

**Step 2 — Denominator (distance)**:
$$
\begin{aligned}
\mathbf r - \mathbf r'(\phi) = \begin{pmatrix} -R\cos\phi \\[4pt] -R\sin\phi \\[4pt] z \end{pmatrix}\\[6pt]
|\mathbf r - \mathbf r'(\phi)| = \sqrt{R^2 + z^2}.
\end{aligned}
$$
→ Important point: the denominator is **independent of \(\phi\)** (an effect of circular symmetry). This greatly simplifies the integral.

**Step 3 — Numerator (cross product)**:
A direct computation gives
$$
\begin{aligned}

\frac{d\mathbf r'}{d\phi}\times(\mathbf r-\mathbf r'(\phi))
= R^2\,\hat{\mathbf z} + Rz(\cos\phi\,\hat{\mathbf x} + \sin\phi\,\hat{\mathbf y}).
\end{aligned}

$$

**Step 4 — Cancellation of angular components**:
Integrating \(\cos\phi\) and \(\sin\phi\) from \(0\) to \(2\pi\) makes them vanish (or summing them in a Riemann sum also yields zero), so only the \(\hat{\mathbf z}\) component remains.

**Step 5 — Integration (analytic solution)**:
The integrand has a \(\phi\)-independent factor \(\displaystyle \frac{R^2}{(R^2+z^2)^{3/2}}\), so
$$
B_z(z) = \frac{\mu_0 I}{4\pi} \int_0^{2\pi} \frac{R^2}{(R^2+z^2)^{3/2}}\, d\phi
= \frac{\mu_0 I R^2}{4\pi (R^2+z^2)^{3/2}} \cdot 2\pi
= \frac{\mu_0 I R^2}{2(R^2+z^2)^{3/2}}.
$$

**Special case \(z=0\)**:
$$
B_z(0) = \frac{\mu_0 I R^2}{2(R^2)^{3/2}} = \frac{\mu_0 I}{2R}.
$$

---

<div class="theory-common-box">4. Practical notes when using the finite sum (Riemann sum) numerically</div>

- The **midpoint rule** (evaluate at the midpoint of each segment) is easy to implement and stable. In formulas one uses \(\displaystyle \phi_k^*=\bigl(k+\frac{1}{2}\bigr)\Delta\phi\).
- **Convergence check**: Increase the number of segments \(N\) and verify that the result stabilizes (e.g. compare \(N=32,128,512\)).
- **Singularities**: If the observation point is close to the wire, the denominator becomes small and the numerics can blow up. Near such intervals one may need an analytic treatment or a principal-value approach.
- **Efficiency**: Segments are independent, so parallelization (e.g. Isolates) can speed things up.
- **Higher accuracy**: If the midpoint rule is not enough, consider the trapezoidal rule, Simpson’s rule, etc.

---

<div class="remark-box">5. Closing remarks (careful summary)</div>

- The Biot–Savart law can be written as a Riemann sum that matches the intuition of **“adding contributions from current elements.”**
- That the finite sum converges to a line integral under a sufficiently fine partition is a natural flow both mathematically and physically.
- Introducing a parameter is only a computational convenience; returning to the line-integral form makes clear that the result does not depend on the parameter.
- On-axis evaluation for a circular loop is especially simple by symmetry, and the analytic solution is ideal for checking a numerical implementation.

"""
);
