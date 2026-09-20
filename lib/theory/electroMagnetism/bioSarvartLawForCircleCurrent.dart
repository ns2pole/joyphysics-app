import '../../model.dart';

final bioSarvartLawForCircleCurrent = TheoryTopic(
  title: '円形電流が円の中心に作る磁場',
  videoURL: "",
  inPreparation: true,
  imageAsset: 'assets/mindMap/forTopics/bioSarvartLawForCircleCurrent.png',
  latexContent: r"""

<div class="theorem-box">命題（最終）</div>


$$
\text{半径 } R \text{ の円形導線に電流 } I \text{ が流れるとき、円の中心（軸上 } z=0\text{）における磁場は}
$$


$$
\mathbf{B}(0)=B_z(0)\,\hat{\mathbf{z}},\qquad
B_z(0)=\frac{\mu_0 I}{2R}.
$$


---

<div class="proof-box">証明（有限和 → 区分求積の形式で補題を使って示す）</div>


<div class="theory-common-box">補題 1（有限分割の設定）</div>


**主張.** 円周を $N$ 等分し，角座標を
$$
\phi_k=\frac{2\pi k}{N}\quad(k=0,1,\dots,N-1)
$$
とする．


対応する位置ベクトルと（近似）線素は
$$
\mathbf{r}'_k=\mathbf{r}'(\phi_k)=R\cos\phi_k\,\hat{\mathbf{x}}+R\sin\phi_k\,\hat{\mathbf{y}},
$$

$$
\Delta\mathbf{l}_k \fallingdotseq \mathbf{r}'(\phi_{k+1})-\mathbf{r}'(\phi_k)
\fallingdotseq \frac{d\mathbf{r}'}{d\phi}(\phi_k)\,\Delta\phi,
\quad \Delta\phi=\frac{2\pi}{N}.
$$


**証明.** 定義どおり。$N$ を大きくとれば差分は導関数による一次近似で表せる（区分求積の前段階）。


---

<div class="theory-common-box">補題 2（評価点と差ベクトル — $z=0$）</div>


**主張.** 評価点を円の中心に取る（$\mathbf{r}=\mathbf{0}$），すると
$$
\mathbf{r}-\mathbf{r}'_k = -\mathbf{r}'_k = -R\cos\phi_k\,\hat{\mathbf{x}} - R\sin\phi_k\,\hat{\mathbf{y}},
$$

距離は
$$
|\mathbf{r}-\mathbf{r}'_k| = |\mathbf{r}'_k| = R,
$$

よって三乗は
$$
|\mathbf{r}-\mathbf{r}'_k|^3 = R^3.
$$


**証明.** $\mathbf{r}=\mathbf{0}$ を代入するのみ。三平方の恒等式で $R$ が得られる。


---

<div class="theory-common-box">補題 3（クロス積の有限和での評価 — $z=0$）</div>


**主張.** 各区間でのクロス積は（近似）
$$
\Delta\mathbf{l}_k \times (\mathbf{r}-\mathbf{r}'_k)
\fallingdotseq \left(\frac{d\mathbf{r}'}{d\phi}(\phi_k)\,\Delta\phi\right)\times(-\mathbf{r}'(\phi_k))
=R^2\,\hat{\mathbf{z}}\,\Delta\phi.
$$


**証明.** 連続式での計算を $z=0$ に代入して示す。実際，
$$
\frac{d\mathbf{r}'}{d\phi}(\phi)
= -R\sin\phi\,\hat{\mathbf{x}}+R\cos\phi\,\hat{\mathbf{y}},
\qquad
-\mathbf{r}'(\phi) = -R\cos\phi\,\hat{\mathbf{x}}-R\sin\phi\,\hat{\mathbf{y}},
$$

の行列式展開により
$$
\frac{d\mathbf{r}'}{d\phi}\times(-\mathbf{r}') = R^2\hat{\mathbf{z}}.
$$

したがって差分近似を掛け合わせれば上の式になる。


---

<div class="theory-common-box">補題 4（ビオ・サバールの区分和表現 — $z=0$）</div>


**主張.** ビオ・サバール則の区分近似を用いると，円中心での各区間寄与は
$$
\Delta\mathbf{B}_k
= \frac{\mu_0}{4\pi}\frac{I\,(\Delta\mathbf{l}_k\times(\mathbf{r}-\mathbf{r}'_k))}{|\mathbf{r}-\mathbf{r}'_k|^3}
\fallingdotseq \frac{\mu_0 I}{4\pi}\frac{R^2\Delta\phi}{R^3}\,\hat{\mathbf{z}}
= \frac{\mu_0 I}{4\pi R}\,\Delta\phi\,\hat{\mathbf{z}}.
$$


**証明.** 補題2 と補題3 を代入するだけで得られる．


---

<div class="theory-common-box">補題 5（有限和の計算：定数の和）</div>


**主張.** 全磁場の有限和（$N$ 分割）は
$$
\mathbf{B}_N(0)=\sum_{k=0}^{N-1}\Delta\mathbf{B}_k
\fallingdotseq \sum_{k=0}^{N-1}\frac{\mu_0 I}{4\pi R}\,\Delta\phi\,\hat{\mathbf{z}}
= \frac{\mu_0 I}{4\pi R}\left(\sum_{k=0}^{N-1}\Delta\phi\right)\hat{\mathbf{z}}
= \frac{\mu_0 I}{4\pi R}\cdot N\Delta\phi\,\hat{\mathbf{z}}.
$$


**証明.** 各項が $\phi_k$ に依存しない定数近似のため，和は定数の和になる．


---

<div class="theory-common-box">補題 6（区分和の極限：区分求積）</div>


**主張.** $\Delta\phi=\frac{2\pi}{N}$ とすると $N\Delta\phi=2\pi$ 固定なので，極限 $N\to\infty$ を取れば
$$
\mathbf{B}(0)=\lim_{N\to\infty}\mathbf{B}_N(0)
= \frac{\mu_0 I}{4\pi R}\cdot 2\pi\,\hat{\mathbf{z}}
= \frac{\mu_0 I}{2R}\,\hat{\mathbf{z}}.
$$


**証明.** 有界な定数和の極限計算であり，Riemann 和の一般理論に従う．ここでは各和の項は定数であるため，区分和の極限は定数×区間長で与えられる．


---

<div class="theory-common-box">命題の結論</div>


補題6 により円中心 $z=0$ における磁場は
$$
B_z(0)=\frac{\mu_0 I}{2R}
$$
である。向きは右手則に従って $\hat{\mathbf{z}}$（電流方向に依存）となる。


---

<div class="remark-box">補足（有限和・収束に関するコメント）</div>


- 本証明では各区間の寄与を有限和として明示し，その極限 $N\to\infty$ を取ることで積分（区分求積）の形式を厳密に経由している．

- $z=0$ の場合は寄与が $\phi$ に依存しないため和が特に簡潔に評価できるが，$z\neq0$ の場合も同様に区分和→積分の枠組みで扱える（その場合は被積分関数が $\phi$ に依存する）．

- 数値的にはこの有限和を実装して $N$ を増やすことで漸近的に中心磁場の値を得られる（区分求積の直感的意味がここにある）。


<div class="proof-box">証明終了</div>

"""
);
