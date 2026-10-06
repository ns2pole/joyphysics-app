import '../../model.dart'; // Videoクラス定義が別ならインポート
final parallelResistance = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
    iconName: "parallelResistance",
    title: "抵抗の並列接続",
    titleEn: "Parallel connection of resistors",
    videoURL: "bwoeXAa8jt4",
    equipment: ["抵抗", "マルチメータ"],
    equipmentEn: ["resistor", "multimeter"],
    costRating: "★★☆", latex: r"""
        <div class="common-box">ポイント</div>
        <p>並列接続での合成抵抗は、$\displaystyle \frac{1}{R_{\mathrm{parallel}}} = \frac{1}{R_1} + \frac{1}{R_2} + \cdots + \frac{1}{R_n}$で得られる。</p>
        <p>すべて同じ抵抗 $R$ なら、</p>
        <p>$$R_{\mathrm{parallel}} = \frac{R}{n}$$</p>

        <div class="common-box">問題設定</div>
        <p>抵抗 $200\,\Omega$ の抵抗を 2 本並列に繋げるときの合成抵抗を求めて下さい。</p>

        <div class="common-box">理論値計算</div>
        <p>$$R_{\mathrm{parallel}} = \frac{200}{2} = 100 \, \Omega$$</p>

        <div class="common-box">答え</div>
        <p>並列接続した場合の合成抵抗は <p>$$\boxed{100 \Omega}$$</p></p>
    """,
    latexEn: r"""
        <div class="common-box">Key points</div>
        <p>The equivalent resistance of resistors in parallel is given by $\displaystyle \frac{1}{R_{\mathrm{parallel}}} = \frac{1}{R_1} + \frac{1}{R_2} + \cdots + \frac{1}{R_n}$.</p>
        <p>If all resistors have the same resistance $R$,</p>
        <p>$$R_{\mathrm{parallel}} = \frac{R}{n}$$</p>

        <div class="common-box">Setup</div>
        <p>Find the equivalent resistance when two $200\,\Omega$ resistors are connected in parallel.</p>

        <div class="common-box">Theoretical calculation</div>
        <p>$$R_{\mathrm{parallel}} = \frac{200}{2} = 100 \, \Omega$$</p>

        <div class="common-box">Answer</div>
        <p>The equivalent resistance for the parallel connection is <p>$$\boxed{100 \Omega}$$</p></p>
    """
);
