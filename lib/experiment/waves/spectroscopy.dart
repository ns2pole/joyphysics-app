import '../../model.dart'; // Videoクラス定義が別ならインポート
final spectroscopy = Video(
  isExperiment: true,
  category: 'waves', // ← 追加
    iconName: "spectroscopy",
    title: "回折格子(分光)",
    titleEn: "Diffraction grating (spectroscopy)",
    videoURL: "oCouUX9973w",
    videoURLEn: "2YkdB-PkvsQ",
    equipment: ["レーザーポインター", "回折格子", "メジャー"],
    equipmentEn: ["laser pointer", "diffraction grating", "measuring tape"],
    costRating: "★★★", latex: r"""
    <div class="common-box">ポイント</div>
    <p>回折格子における回折角の基本式：$d\sin\theta = m\lambda $</p>
    <div class="common-box">問題設定</div>
    <p>白色光を格子定数 $d = 1.0\,\mu\mathrm{m}$ の回折格子に入射させる。スクリーンまでの距離は $L = 0.15\,\mathrm{m}$。</p>
    <p>回折格子を通った白色光はスクリーンをどのように照らすか求めて下さい。</p>

    <div class="common-box">理論計算</div>
    <p>基本式：$ d\sin\theta = m\lambda $</p>
    <p>0次回折: $ m = 0 $ での回折角は、</p>
        $$ d\sin\theta = 0 \cdot \lambda $$    より、$\theta = 0 $。（全ての波長の光に対して）
    <br>
    <p>1次回折: $ m = 1 $ での回折角は、</p>
    $$
    \theta = \arcsin\left(\frac{\lambda}{d}\right)
    $$    <p>スクリーン上の位置 $y$ は、</p>
    $$
    y = L\tan\theta
    $$
    <p>紫: (λ = 400 nm)：</p>
 $$\begin{aligned}
    \theta_V &= \arcsin\left(\frac{400\times10^{-9}}{1.0\times10^{-6}}\right) \\
    &\fallingdotseq 23.5782^{\circ} \\ \ \\
    y_V &= 0.15\tan(23.5782^{\circ}) \\
    & \fallingdotseq 6.54\,\mathrm{cm}
    \end{aligned}$$
    <p>赤 :(λ = 700 nm)：</p>
 $$\begin{aligned}
    \theta_R &= \arcsin\left(\frac{700\times10^{-9}}{1.0\times10^{-6}}\right) \\
    &\fallingdotseq 44.4270^{\circ} \\ \ \\
    y_R &= 0.15\tan(44.4270^{\circ}) \\
    &\fallingdotseq 14.70\,\mathrm{cm}
    \end{aligned}$$
    <div class="common-box">答え</div>
    <p>紫の光はスクリーン中央から約 6.5cm の位置に、赤の光は約 14.7 cm の位置に現れる。</p>
    """,
    latexEn: r"""
    <div class="common-box">Key points</div>
    <p>Basic diffraction-angle formula for a grating: $d\sin\theta = m\lambda $</p>
    <div class="common-box">Setup</div>
    <p>White light is incident on a diffraction grating with spacing $d = 1.0\,\mu\mathrm{m}$. The distance to the screen is $L = 0.15\,\mathrm{m}$.</p>
    <p>How does the white light illuminate the screen after passing through the grating?</p>

    <div class="common-box">Theoretical calculation</div>
    <p>Basic formula: $ d\sin\theta = m\lambda $</p>
    <p>Zeroth order: for $ m = 0 $, the diffraction angle satisfies</p>
        $$ d\sin\theta = 0 \cdot \lambda $$ so $\theta = 0 $ (for every wavelength).
    <br>
    <p>First order: for $ m = 1 $, the diffraction angle is</p>
    $$
    \theta = \arcsin\left(\frac{\lambda}{d}\right)
    $$    <p>The position $y$ on the screen is</p>
    $$
    y = L\tan\theta
    $$
    <p>Violet ($\lambda = 400\,\mathrm{nm}$):</p>
 $$\begin{aligned}
    \theta_V &= \arcsin\left(\frac{400\times10^{-9}}{1.0\times10^{-6}}\right) \\
    &\fallingdotseq 23.5782^{\circ} \\ \ \\
    y_V &= 0.15\tan(23.5782^{\circ}) \\
    & \fallingdotseq 6.54\,\mathrm{cm}
    \end{aligned}$$
    <p>Red ($\lambda = 700\,\mathrm{nm}$):</p>
 $$\begin{aligned}
    \theta_R &= \arcsin\left(\frac{700\times10^{-9}}{1.0\times10^{-6}}\right) \\
    &\fallingdotseq 44.4270^{\circ} \\ \ \\
    y_R &= 0.15\tan(44.4270^{\circ}) \\
    &\fallingdotseq 14.70\,\mathrm{cm}
    \end{aligned}$$
    <div class="common-box">Answer</div>
    <p>Violet light appears about 6.5 cm from the screen centre, and red light about 14.7 cm from the centre.</p>
    """
);