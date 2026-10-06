import '../../model.dart'; // Videoクラス定義が別ならインポート
final solenoidSelfInductance = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
    iconName: "solenoidSelfInductance",
    title: "ソレノイドコイルの自己インダクタンス",
    titleEn: "Self-inductance of a solenoid coil",
    videoURL: "_M7kIijXf9M",
    videoURLEn: "ylrAUbqPow8",
    equipment: ["導線", "絶縁体パイプ", "マルチメーター（Co)"],
    equipmentEn: ["wire", "insulating pipe", "multimeter (Co)"],
    costRating: "★★★", latex: r"""
    <div class="common-box">ポイント</div>
    <p>・コイルの電圧 $V$ と電流 $I$ の関係は $\displaystyle V = L \frac{dI}{dt}$ で表される。</p>
    <p>・ソレノイドコイルの自己インダクタンスは $\displaystyle L = \mu_0 \mu_r \frac{N^2 A}{l}$</p>
    <p>※記号の定義：</p>
    <ul style="line-height:1.6;">
      <li>$B$：磁束密度（テスラ, T）</li>
      <li>$L$：自己インダクタンス（ヘンリー, H）</li>
      <li>$N$：コイルの巻き数（無次元）</li>
      <li>$A$：コイルの断面積（平方メートル, m²）</li>
      <li>$l$：コイルの長さ（メートル, m）</li>
      <li>$\mu_0$：真空の透磁率（$4\pi \times 10^{-7}$ H/m）</li>
      <li>$\mu_r$：コアの相対透磁率（無次元）<br>
          ※空芯ソレノイドの場合は $\mu_r = 1$ として計算</li>
      <li>$V$：電圧（ボルト, V）</li>
      <li>$I$：電流（アンペア, A）</li>
    </ul>
    <div class="common-box">問題設定</div>
    <p>単層のソレノイドコイル（長さ30cm、管半径4mm、巻き数300回、導線半径0.275mm）の自己インダクタンスを求めよ。</p>
    <div style="text-align:center; margin:1em 0;">
      <img src="assets/electroMagnetismDetail/solenoidCrossSection.png"
           alt=" ソレノイド断面"
           style="max-width:65%; height:auto;" />
    </div>
    <div class="common-box">理論計算</div>
    <p>条件：</p>
   <p>
   $$\begin{aligned}
   \text{巻き数} &\quad N = 300 \\
   \text{長さ} &\quad l = 30\,\mathrm{cm} = 0.30\,\mathrm{m} \\
   \text{管の半径} &\quad r_{\mathrm{core}} = 4.0\,\mathrm{mm} = 4.0 \times 10^{-3}\,\mathrm{m} \\
   \text{導線半径} &\quad r_w = 0.275\,\mathrm{mm} = 2.75 \times 10^{-4}\,\mathrm{m} \\
   \text{外半径} &\quad r_{\mathrm{outer}} = r_{\mathrm{core}} + r_w = 0.004275\,\mathrm{m} \\
   \text{断面積} &\quad A = \pi r_{\mathrm{outer}}^2 = \pi \times (0.004275)^2 \fallingdotseq 5.74 \times 10^{-5}\,\mathrm{m}^2 \\
   \mu_0 &= 4\pi \times 10^{-7}\,\mathrm{H/m},\quad \mu_r = 1
   \end{aligned}
   $$</p>

    <p>代入して：</p>
    <p>
    $$\begin{aligned}
    L &= 4\pi \times 10^{-7} \times \frac{300^2 \times 5.74 \times 10^{-5}}{0.30} \\
    &= 4\pi \times 10^{-7} \times 17.22  \\
    &\fallingdotseq 2.16 \times 10^{-5}\ \mathrm{H} = 21.6\ \mu\mathrm{H}
    \end{aligned}$$</p>

    <div class="common-box">答え</div>
    <p>ソレノイドの自己インダクタンスは約 $21.6\ \mu\mathrm{H}$ である。</p>
    <div class="common-box">補足（一般的な導出）</div>
    <p>ソレノイド内部の磁場 $ \displaystyle B = \mu_0 \mu_r \frac{N}{l} I$、1巻あたりの磁束 $\Phi_{\mathrm{turn}}=BA$ として</p>
    <p>$$\Phi = N \Phi_{\mathrm{turn}} = \mu_0 \mu_r \frac{N^2 A}{l} I$$</p>
    <p>より $\Phi = LI$ から $ \displaystyle L = \mu_0 \mu_r \frac{N^2 A}{l}$ を得る。</p>
""",
    latexEn: r"""
    <div class="common-box">Key points</div>
    <p>・The relation between the coil voltage $V$ and current $I$ is $\displaystyle V = L \frac{dI}{dt}$.</p>
    <p>・The self-inductance of a solenoid coil is $\displaystyle L = \mu_0 \mu_r \frac{N^2 A}{l}$</p>
    <p>※ Symbol definitions:</p>
    <ul style="line-height:1.6;">
      <li>$B$: magnetic flux density (tesla, T)</li>
      <li>$L$: self-inductance (henry, H)</li>
      <li>$N$: number of turns (dimensionless)</li>
      <li>$A$: cross-sectional area of the coil (square meters, m²)</li>
      <li>$l$: length of the coil (meters, m)</li>
      <li>$\mu_0$: vacuum permeability ($4\pi \times 10^{-7}$ H/m)</li>
      <li>$\mu_r$: relative permeability of the core (dimensionless)<br>
          ※ For an air-core solenoid, take $\mu_r = 1$</li>
      <li>$V$: voltage (volt, V)</li>
      <li>$I$: current (ampere, A)</li>
    </ul>
    <div class="common-box">Setup</div>
    <p>Find the self-inductance of a single-layer solenoid coil (length 30 cm, tube radius 4 mm, 300 turns, wire radius 0.275 mm).</p>
    <div style="text-align:center; margin:1em 0;">
      <img src="assets/electroMagnetismDetail/solenoidCrossSection.png"
           alt="Solenoid cross section"
           style="max-width:65%; height:auto;" />
    </div>
    <div class="common-box">Theoretical calculation</div>
    <p>Conditions:</p>
   <p>
   $$\begin{aligned}
   \text{number of turns} &\quad N = 300 \\
   \text{length} &\quad l = 30\,\mathrm{cm} = 0.30\,\mathrm{m} \\
   \text{tube radius} &\quad r_{\mathrm{core}} = 4.0\,\mathrm{mm} = 4.0 \times 10^{-3}\,\mathrm{m} \\
   \text{wire radius} &\quad r_w = 0.275\,\mathrm{mm} = 2.75 \times 10^{-4}\,\mathrm{m} \\
   \text{outer radius} &\quad r_{\mathrm{outer}} = r_{\mathrm{core}} + r_w = 0.004275\,\mathrm{m} \\
   \text{cross-sectional area} &\quad A = \pi r_{\mathrm{outer}}^2 = \pi \times (0.004275)^2 \fallingdotseq 5.74 \times 10^{-5}\,\mathrm{m}^2 \\
   \mu_0 &= 4\pi \times 10^{-7}\,\mathrm{H/m},\quad \mu_r = 1
   \end{aligned}
   $$</p>

    <p>Substituting:</p>
    <p>
    $$\begin{aligned}
    L &= 4\pi \times 10^{-7} \times \frac{300^2 \times 5.74 \times 10^{-5}}{0.30} \\
    &= 4\pi \times 10^{-7} \times 17.22  \\
    &\fallingdotseq 2.16 \times 10^{-5}\ \mathrm{H} = 21.6\ \mu\mathrm{H}
    \end{aligned}$$</p>

    <div class="common-box">Answer</div>
    <p>The self-inductance of the solenoid is about $21.6\ \mu\mathrm{H}$.</p>
    <div class="common-box">Note (general derivation)</div>
    <p>With the magnetic field inside the solenoid $ \displaystyle B = \mu_0 \mu_r \frac{N}{l} I$ and the flux per turn $\Phi_{\mathrm{turn}}=BA$,</p>
    <p>$$\Phi = N \Phi_{\mathrm{turn}} = \mu_0 \mu_r \frac{N^2 A}{l} I$$</p>
    <p>From $\Phi = LI$ we obtain $ \displaystyle L = \mu_0 \mu_r \frac{N^2 A}{l}$.</p>
"""
);
