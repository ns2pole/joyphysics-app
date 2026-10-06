import '../../model.dart'; // Videoクラス定義が別ならインポート
final resistanceMeasurement = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
    iconName: "resistance",
    title: "抵抗の測定",
    titleEn: "Measuring resistance",
    videoURL: "Cjf2dvf7ltY",
    equipment: ["抵抗", "マルチメータ"],
    equipmentEn: ["resistor", "multimeter"],
    costRating: "★★☆", latex: r"""
<div class="common-box">ポイント</div>
<p>抵抗器に電圧 $V$ を加えたとき電流 $I$ が流れると、抵抗値はオームの法則から</p>
<p>$$\displaystyle R=\frac{V}{I}$$</p>
<p>です。デジタルマルチメータの抵抗レンジは、内部の電源で小さな電流を流し、この関係から $R$ を表示します。</p>
""",
    latexEn: r"""
<div class="common-box">Key points</div>
<p>When a voltage $V$ is applied to a resistor and a current $I$ flows, Ohm's law gives the resistance as</p>
<p>$$\displaystyle R=\frac{V}{I}$$</p>
<p>A digital multimeter on the resistance range drives a small current from its internal supply and displays $R$ using this relation.</p>
"""
);
