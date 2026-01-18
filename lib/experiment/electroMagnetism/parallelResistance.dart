import '../../model.dart'; // Videoクラス定義が別ならインポート
final parallelResistance = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
    iconName: "parallelResistance",
    title: "抵抗の並列接続",
    videoURL: "bwoeXAa8jt4",
    equipment: ["抵抗", "マルチメータ"],
    costRating: "★★☆", latex: r"""
        <div class="common-box">ポイント</div>
        <p>並列接続での合成抵抗は、$\frac{1}{R_{\mathrm{parallel}}} = \frac{1}{R_1} + \frac{1}{R_2} + \cdots + \frac{1}{R_n}$で得られる。</p>
        <p>すべて同じ抵抗 $R$ なら、</p>
        <p>$$R_{\mathrm{parallel}} = \frac{R}{n}$$</p>

        <div class="common-box">問題設定</div>
        <p>抵抗 $200\,\Omega$ の抵抗を 2 本並列に繋げるときの合成抵抗を求めて下さい。</p>

        <div class="common-box">理論値計算</div>
        <p>$$R_{\mathrm{parallel}} = \frac{200}{2} = 100 \, \Omega$$</p>

        <div class="common-box">答え</div>
        <p>並列接続した場合の合成抵抗は <p>$$\boxed{100 \Omega}$$</p></p>
    """
);