import '../../model.dart'; // Videoクラス定義が別ならインポート
final neodymiumMagnetFieldMeasurement = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
    iconName: "neodium",
    title: "ネオジム磁石の磁場の測定",
    titleEn: "Measuring the magnetic field of a neodymium magnet",
    videoURL: "etUEGohtVLY",
    videoURLEn: "xEImLZoI3XQ",
    equipment: ["ネオジム磁石", "磁力計"],
    equipmentEn: ["neodymium magnet", "magnetometer"],
    costRating: "★★★", latex: r"""
<div class="common-box">ポイント</div>
<p>磁場の強さは「テスラ (T)」で表され、1テスラは、1平方メートルあたり1ウェーバーの磁束密度に相当します。</p>
<p>日常的な磁場の例として、ネオジム磁石の磁場は動画中で約 <strong>180 mT (ミリテスラ)</strong> と測定された。</p>
<p>地球の磁場は約 50 μT (マイクロテスラ) 程度。</p>
""",
    latexEn: r"""
<div class="common-box">Key points</div>
<p>The strength of a magnetic field is expressed in tesla (T); 1 tesla corresponds to a magnetic flux density of 1 weber per square meter.</p>
<p>As an everyday example, the magnetic field of a neodymium magnet was measured in the video at about <strong>180 mT (millitesla)</strong>.</p>
<p>Earth's magnetic field is about 50 μT (microtesla).</p>
"""
);
