//https://marufuuwa.com/archives/5523 (quote:画像)
import '../../model.dart'; // Videoクラス定義が別ならインポート
final moonOrbit = Video(
  isExperiment: true,
  category: 'dynamics', // ← 追加
    iconName: "moon",
    title: "月までの距離とケプラー第3法則",
    titleEn: "Distance to the Moon and Kepler's third law",
    videoURL: "",
    equipment: ["なし"],
    equipmentEn: ["none"],
    costRating: "★☆☆",
    latex: r"""
        <div class="common-box">ポイント</div>
        <p>地球の質量を $M$、万有引力定数を $G$ とする。地球が月に比べて十分重いという近似のもとで、月の公転周期 $T$ と軌道長半径 $a$ は$\displaystyle \frac{T^2}{a^3} =  \frac{4\pi^2}{GM}$を満たす（ケプラーの第3法則）</p>
        
        <div class="common-box">地球の基本データから $GM$ を求める</div>
        <p>地球一周の長さは約 $4 \times 10^7$ m。この周長は地球の半径 $R$ を使って $2\pi R$ で表されるので：</p>
        <p>$$2\pi R = 4 \times 10^7 \Rightarrow R = \frac{4 \times 10^7}{2\pi} \fallingdotseq 6.37 \times 10^6 \ [\mathrm{m}]$$</p>
        <p>地表の重力加速度は $g = 9.8$ [m/s²] より、</p>
        <p>$$g = \frac{GM}{R^2} \Rightarrow GM = gR^2$$</p>
        <p>$$GM = 9.8 \times (6.37 \times 10^6)^2 \fallingdotseq 3.97 \times 10^{14}$$</p>
        <div class="common-box">① 月の公転周期を「30日」として計算</div>
        <p>$$T = 30 \times 24 \times 60 \times 60 = 2.592 \times 10^6 \ [\mathrm{s}]$$</p>
        <p>\begin{align}a^3 & \fallingdotseq \frac{GM T^2}{4\pi^2} \\ &= \frac{3.97 \times 10^{14} \times (2.592 \times 10^6)^2}{4\pi^2} \\ &\fallingdotseq \frac{3.97 \times 6.72}{39.5} \times 10^{26} \fallingdotseq 6.76 \times 10^{25}\end{align}</p>
        <p>$$\Rightarrow a \fallingdotseq \sqrt[3]{6.76 \times 10^{25}} \fallingdotseq 4.08 \times 10^8 \ [\mathrm{m}]$$</p>
        <div class="common-box">② 月の公転周期を「27.3日」として計算</div>
        <p>$$T = 27.3 \times 24 \times 60 \times 60 = 2.36 \times 10^6 \ [\mathrm{s}]$$</p>
        <p>$$a^3 = \frac{GM T^2}{4\pi^2} = \frac{3.97 \times 10^{14} \times (2.36 \times 10^6)^2}{4\pi^2}$$</p>
        <p>$$\Rightarrow a^3 \fallingdotseq \frac{3.97 \times 5.57}{39.5} \times 10^{26} \fallingdotseq 5.60 \times 10^{25}$$</p>
        <p>$$\Rightarrow a \fallingdotseq \sqrt[3]{5.60 \times 10^{25}} \fallingdotseq 3.84 \times 10^8 \ [\mathrm{m}]$$</p>
        <div class="common-box">答え</div>
        <p>・公転周期を30日とすると $a \displaystyle \fallingdotseq 4.08 \times 10^8$ [m]</p>
        <p>・現実により近い周期27.3日の計算では $\displaystyle a \fallingdotseq 3.84 \times 10^8$ [m]</p>
        <p>実際の月の平均距離（約 384,000 km）と、理論値がよく一致していることがわかる。</p>
    """,
    latexEn: r"""
        <div class="common-box">Key points</div>
        <p>Let Earth's mass be $M$ and the gravitational constant be $G$. Under the approximation that Earth is much heavier than the Moon, the Moon's orbital period $T$ and semi-major axis $a$ satisfy $\displaystyle \frac{T^2}{a^3} =  \frac{4\pi^2}{GM}$ (Kepler's third law).</p>
        
        <div class="common-box">Finding $GM$ from Earth's basic data</div>
        <p>Earth's circumference is about $4 \times 10^7$ m. With Earth's radius $R$, the circumference is $2\pi R$, so</p>
        <p>$$2\pi R = 4 \times 10^7 \Rightarrow R = \frac{4 \times 10^7}{2\pi} \fallingdotseq 6.37 \times 10^6 \ [\mathrm{m}]$$</p>
        <p>Surface gravity is $g = 9.8$ [m/s²], so</p>
        <p>$$\displaystyle g = \frac{GM}{R^2} \Rightarrow GM = gR^2$$</p>
        <p>$$GM = 9.8 \times (6.37 \times 10^6)^2 \fallingdotseq 3.97 \times 10^{14}$$</p>
        <div class="common-box">(1) Period taken as 30 days</div>
        <p>$$T = 30 \times 24 \times 60 \times 60 = 2.592 \times 10^6 \ [\mathrm{s}]$$</p>
        <p>\begin{align}a^3 & \fallingdotseq \frac{GM T^2}{4\pi^2} \\ &= \frac{3.97 \times 10^{14} \times (2.592 \times 10^6)^2}{4\pi^2} \\ &\fallingdotseq \frac{3.97 \times 6.72}{39.5} \times 10^{26} \fallingdotseq 6.76 \times 10^{25}\end{align}</p>
        <p>$$\Rightarrow a \fallingdotseq \sqrt[3]{6.76 \times 10^{25}} \fallingdotseq 4.08 \times 10^8 \ [\mathrm{m}]$$</p>
        <div class="common-box">(2) Period taken as 27.3 days</div>
        <p>$$T = 27.3 \times 24 \times 60 \times 60 = 2.36 \times 10^6 \ [\mathrm{s}]$$</p>
        <p>$$\displaystyle a^3 = \frac{GM T^2}{4\pi^2} = \frac{3.97 \times 10^{14} \times (2.36 \times 10^6)^2}{4\pi^2}$$</p>
        <p>$$\Rightarrow a^3 \fallingdotseq \frac{3.97 \times 5.57}{39.5} \times 10^{26} \fallingdotseq 5.60 \times 10^{25}$$</p>
        <p>$$\Rightarrow a \fallingdotseq \sqrt[3]{5.60 \times 10^{25}} \fallingdotseq 3.84 \times 10^8 \ [\mathrm{m}]$$</p>
        <div class="common-box">Answer</div>
        <p>・With a 30-day period, $\displaystyle a \fallingdotseq 4.08 \times 10^8$ [m]</p>
        <p>・With the more realistic 27.3-day period, $\displaystyle a \fallingdotseq 3.84 \times 10^8$ [m]</p>
        <p>This agrees well with the Moon's actual mean distance (about 384,000 km).</p>
    """
);
