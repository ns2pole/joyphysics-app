import '../../model.dart'; // Videoクラス定義が別ならインポート
final diffractionGrating = Video(
  isExperiment: true,
  category: 'waves', // ← 追加
    iconName: "diffractionGrating",
    title: "回折格子(単色光)",
    titleEn: "Diffraction grating (monochromatic light)",
    videoURL: "meaeB8JV4qw",
    videoURLEn: "9ZzSZD9r8ug",
    equipment: ["レーザーポインター", "回折格子", "メジャー"],
    equipmentEn: ["laser pointer", "diffraction grating", "measuring tape"],
    costRating: "★★★", latex: r"""
    <div class="common-box">ポイント</div>
    <p>格子定数$d$、回折角$\theta$、波長$\lambda$、回折次数$m$の関係式：</p>
     <p>$$
      d\sin\theta = m\lambda
    $$</p>
    <div class="common-box">問題設定</div>
    <p>波長$\lambda = 532\,\mathrm{nm}$の単色光を、格子定数:$d = 1.0\,\mu\mathrm{m}$の回折格子に垂直に入射させる。</p>
    <p>スクリーンまでの距離は$L = 0.20\,\mathrm{m}$とする。回折格子を通った緑のレーザー光はスクリーン上のどの位置に現れるか求めて下さい。</p>

    <div class="common-box">理論計算</div>
    <p>基本式：</p>
    <p>$$
      \theta = \arcsin\left(\frac{\lambda}{d}\right)
    $$</p>
    <p>スクリーン上の位置$y$：</p>
    <p>$$
      y = L \tan\theta
    $$</p>

    <p>数値代入：</p>
    $$\begin{aligned}
    \theta &= \arcsin\left(\frac{532\times10^{-9}}{1.0\times10^{-6}}\right) \fallingdotseq 32.14^{\circ} \\
    y &= 0.20 \tan(32.14^{\circ}) \fallingdotseq 12.6\mathrm{cm}
    \end{aligned}$$

    <div class="common-box">答え</div>
    <p>第1次回折光はスクリーン中央から左右それぞれ約 12.6 cm の位置に現れる。$2\lambda/d=1.064>1$ なので、第2次以降は出ない。</p>
    """,
    latexEn: r"""
    <div class="common-box">Key points</div>
    <p>Relation among grating spacing $d$, diffraction angle $\theta$, wavelength $\lambda$, and diffraction order $m$:</p>
     <p>$$
      d\sin\theta = m\lambda
    $$</p>
    <div class="common-box">Setup</div>
    <p>Monochromatic light of wavelength $\lambda = 532\,\mathrm{nm}$ is incident normally on a diffraction grating with spacing $d = 1.0\,\mu\mathrm{m}$.</p>
    <p>The distance to the screen is $L = 0.20\,\mathrm{m}$. Find where the green laser light appears on the screen after passing through the grating.</p>

    <div class="common-box">Theoretical calculation</div>
    <p>Basic formula (for first order $m=1$):</p>
    <p>$$
      \theta = \arcsin\left(\frac{\lambda}{d}\right)
    $$</p>
    <p>Position $y$ on the screen:</p>
    <p>$$
      y = L \tan\theta
    $$</p>

    <p>Numerical substitution:</p>
    $$\begin{aligned}
    \theta &= \arcsin\left(\frac{532\times10^{-9}}{1.0\times10^{-6}}\right) \fallingdotseq 32.14^{\circ} \\
    y &= 0.20 \tan(32.14^{\circ}) \fallingdotseq 12.6\mathrm{cm}
    \end{aligned}$$

    <div class="common-box">Answer</div>
    <p>The first-order diffracted beams appear about 12.6 cm to the left and right of the screen centre. Since $\displaystyle \frac{2\lambda}{d}=1.064>1$, second and higher orders do not appear.</p>
    """
);