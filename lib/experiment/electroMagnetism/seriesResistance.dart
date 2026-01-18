import '../../model.dart'; // Videoクラス定義が別ならインポート
final seriesResistance = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
    iconName: "seriesResistance",
    title: "抵抗の直列接続",
    videoURL: "4-ZxiXh-xiE",
    equipment: ["抵抗", "マルチメータ"],
    costRating: "★★☆", latex: r"""
        <div class="common-box">ポイント</div>
        <p>直列接続の合成抵抗はすべての抵抗の和、$R_{\mathrm{series}} = R_1 + R_2 + \cdots + R_n$で得られる。</p>

        <div class="common-box">問題設定</div>
        <p>抵抗 $200\,\Omega$ の抵抗を 2 本直列に繋げるときの合成抵抗を求めて下さい。</p>

        <div class="common-box">理論値計算</div>
        <p>$$R_{\mathrm{series}} = 200 + 200 = 400 \, \Omega$$</p>

        <div class="common-box">答え</div>
        <p>直列接続した場合の合成抵抗は $$\boxed{400 \Omega}$$</p>
    """
);