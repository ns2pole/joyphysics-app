import '../../model.dart'; // Videoクラス定義が別ならインポート
final boyleLaw = Video(
  isExperiment: true,
  category: 'thermoDynamics', // ← 追加
    iconName: "boyleLaw",
    title: "ボイルの法則",
    titleEn: "Boyle's law",
    videoURL: "tQNsVK5cxEw",
    videoURLEn: "HzKUyjBQukk",
    equipment: ["巻尺", "台秤", "シリンジ"],
    equipmentEn: ["measuring tape", "platform scale", "syringe"],
    costRating: "★★☆", latex: r"""
        <div class="common-box">ポイント</div>
        <p>温度一定のとき、気体の圧力 $P$ と体積 $V$ の積は一定。（ボイルの法則）</p>
        <p>$$PV = \text{一定}$$</p>
        <p>ここで、$P$: 圧力 [Pa], $V$: 体積 [m³]</p>

        <div class="common-box">問題設定</div>
        <p>半径 $r = 7.5\times10^{-3}\,\mathrm{m}$ のシリンジに最初 $V_1 = 20\,\mathrm{mL}$ の空気を封入し、</p>
        <p>体積を半分の $V_2 = 10\,\mathrm{mL}$ にしたとき、追加で必要な力 $F$ を求めて下さい。</p>

        <div class="common-box">理論値計算</div>
        <p>ボイルの法則より：</p>
        <p>$$P_1 V_1 = P_2 V_2$$</p>
        <p>体積が半分になるので、$$P_2 = 2P_1$$</p>
        <p>大気圧を $P_1 = 101300\,\mathrm{Pa}$ とすると、$$P_2 = 202600\,\mathrm{Pa}$$</p>
        <p>ピストンにかかる差圧を使って：</p>
        <p>$$F = (P_2 - P_1)\times A$$</p>
        <p>断面積 
        $$\begin{aligned}
            A &= \pi r^2 = \pi (7.5\times10^{-3})^2 \\ & \fallingdotseq 1.77\times10^{-4}\,\mathrm{m^2}
        \end{aligned}$$
        </p>
        <p>よって、</p>
        <p>
        $$\begin{aligned}
            F &= (202600 - 101300) \times 1.77\times10^{-4} \\ &\fallingdotseq 18\,\mathrm{N}
        \end{aligned}$$    
        </p>

        <div class="common-box">単位換算</div>
        <p>この力を kgf（重さ）に換算：</p>
        <p>$$m = \frac{F}{g} = \frac{18}{9.8} \fallingdotseq 1.84\,\mathrm{kg}$$</p>

        <div class="common-box">答え</div>
        <p>理論的にバネはかりが指す力は
            $$\boxed{F \fallingdotseq 18\,\mathrm{[N]}}$$
            （これは約 <strong>1.8 kg</strong>の物体の重さ分の力）</p>
    """,
    latexEn: r"""
        <div class="common-box">Key points</div>
        <p>At constant temperature, the product of a gas's pressure $P$ and volume $V$ is constant (Boyle's law).</p>
        <p>$$PV = \text{constant}$$</p>
        <p>Here, $P$: pressure [Pa], $V$: volume [m³]</p>

        <div class="common-box">Setup</div>
        <p>A syringe of radius $r = 7.5\times10^{-3}\,\mathrm{m}$ initially holds $V_1 = 20\,\mathrm{mL}$ of air.</p>
        <p>Find the additional force $F$ needed when the volume is halved to $V_2 = 10\,\mathrm{mL}$.</p>

        <div class="common-box">Theory</div>
        <p>From Boyle's law:</p>
        <p>$$P_1 V_1 = P_2 V_2$$</p>
        <p>Since the volume is halved, $$P_2 = 2P_1$$</p>
        <p>Taking atmospheric pressure as $P_1 = 101300\,\mathrm{Pa}$, $$P_2 = 202600\,\mathrm{Pa}$$</p>
        <p>Using the pressure difference on the piston:</p>
        <p>$$F = (P_2 - P_1)\times A$$</p>
        <p>Cross-sectional area
        $$\begin{aligned}
            A &= \pi r^2 = \pi (7.5\times10^{-3})^2 \\ & \fallingdotseq 1.77\times10^{-4}\,\mathrm{m^2}
        \end{aligned}$$
        </p>
        <p>Therefore,</p>
        <p>
        $$\begin{aligned}
            F &= (202600 - 101300) \times 1.77\times10^{-4} \\ &\fallingdotseq 18\,\mathrm{N}
        \end{aligned}$$    
        </p>

        <div class="common-box">Unit conversion</div>
        <p>Convert this force to an equivalent mass (kgf):</p>
        <p>$$m = \frac{F}{g} = \frac{18}{9.8} \fallingdotseq 1.84\,\mathrm{kg}$$</p>

        <div class="common-box">Answer</div>
        <p>The spring scale should read
            $$\boxed{F \fallingdotseq 18\,\mathrm{[N]}}$$
            (about the weight of a <strong>1.8 kg</strong> object)</p>
    """
);