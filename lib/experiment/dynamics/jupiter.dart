import '../../model.dart'; // Videoクラス定義が別ならインポート

//https://www.illust-box.jp/s/sozai/209089/ (quote:画像)
final jupiter = Video(
    isExperiment: true,
    category: 'dynamics', // ← 追加
    iconName: "jupiter",
    title: "木星のガリレオ衛星とケプラー第3法則",
    videoURL: "",
    equipment: ["なし"],
    costRating: "★☆☆",
    latex: r"""
        <div class="common-box">データ</div>
        <div style="text-align:center; margin:1em 0;">
          <img src="assets/dynamicsDetail/jupiter.png"
               alt="ガリレオ衛星データ"
               style="max-width:98%; height:auto;" />
        </div>
                <div class="common-box">ポイント</div>
                <p>木星の質量を $M$、万有引力定数を $G$ とする。木星が衛星に比べて十分重いという近似のもとで、全衛星の公転周期 $T$ と軌道長半径 $a$ は$\displaystyle \frac{T^2}{a^3} =  \frac{4\pi^2}{GM}$を満たす（ケプラーの第3法則）</p>
                <div class="common-box">具体的な理論値計算とデータとの照合</div>    
        <p>木星質量 $M = 1.90 \times 10^{27}$ [kg]、万有引力定数 $G = 6.67 \times 10^{-11}$ より：</p>
        $$GM = 6.67 \times 10^{-11} \times 1.90 \times 10^{27} = 1.27 \times 10^{17}$$

        <p>ケプラー第3法則の定数項：</p>
        $$\frac{4\pi^2}{GM} = \frac{4 \times \pi^2}{1.27 \times 10^{17}} \fallingdotseq 3.11 \times 10^{-16} \ \mathrm{[s^2\cdot m^{-3}]}$$

        <p>表で計算した $T^2 / a^3$ とよく一致していることが確認できた。</p>
    """
);