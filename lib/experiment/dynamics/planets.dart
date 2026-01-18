//https://www.irasutoya.com/2017/05/blog-post_564.html (quote:画像)
import '../../model.dart'; // Videoクラス定義が別ならインポート
final planets = Video(
  isExperiment: true,
  category: 'dynamics', // ← 追加
    iconName: "planets",
    title: "太陽系惑星の天文データとケプラー第3法則",
    videoURL: "",
    equipment: ["なし"],
    costRating: "★☆☆",
    latex: r"""
        <div class="common-box">天文データ</div>
        <div style="text-align:center; margin:1em 0;">
          <img src="assets/dynamicsDetail/planets.webp"
               alt="惑星データ"
               style="max-width:98%; height:auto;" />
        </div>
        <div class="common-box">ポイント</div>
        <p>太陽の質量を $M$、万有引力定数を $G$ とする。中心星が各惑星に比べて十分重いという近似のもとで、全惑星の公転周期 $T$ と軌道長半径 $a$ は$\displaystyle \frac{T^2}{a^3} =  \frac{4\pi^2}{GM}$を満たす（ケプラーの第3法則）</p>
        <div class="common-box">具体的な理論値計算と天文データとの照合</div>    
        <p>実際のデータ：太陽の質量 $M = 1.98 \times 10^{30}$ [kg]、万有引力定数 $G = 6.67 \times 10^{-11}$ を用いてこの値を計算すると：</p>
        $$\begin{aligned}
        \frac{4\pi^2}{GM} &= \frac{4 \times 3.14^2}{6.67 \times 10^{-11} \times 1.98 \times 10^{30}} \\
        &= \frac{4 \times 3.14^2}{6.67 \times 1.98} \times 10^{-19} \\[5pt]
        &\fallingdotseq 2.97 \times 10^{-19} \ \ [\mathrm{s^2\cdot m^{-3}}]
        \end{aligned}$$

        <p>この値は、表の右端に示された $\displaystyle \frac{T^2}{a^3}$ の値とよく一致しており、ケプラーの法則が太陽系の惑星に対して良い近似になっていることがわかる。</p>
    """
);