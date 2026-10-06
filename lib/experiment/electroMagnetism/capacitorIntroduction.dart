import '../../model.dart'; // Videoクラス定義が別ならインポート
final capacitorIntroduction = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
    iconName: "capacitorIntroduction",
    title: "コンデンサーとはどういうものか？",
    titleEn: "What is a capacitor?",
    videoURL: "Zo6fNi6aCKU",
    videoURLEn: "LJPWOCbNZFs",
    equipment: ["コンデンサ", "電源","LED"],
    equipmentEn: ["capacitor", "power supply", "LED"],
    costRating: "★★☆", latex: r"""
<div class="common-box">ポイント</div>
<p>コンデンサの電気容量とは、単位電圧あたりに蓄えられる電荷量を表す量であり、次の式で定義される：</p>
<p>$$\displaystyle Q = CV$$</p>
<ul>
  <li>$Q$: 電荷量 [C]</li>
  <li>$C$: 容量 [F]</li>
  <li>$V$: 電圧 [V]</li>
</ul>

""",
    latexEn: r"""
<div class="common-box">Key points</div>
<p>The capacitance of a capacitor is the amount of charge stored per unit voltage, and is defined by:</p>
<p>$$\displaystyle Q = CV$$</p>
<ul>
  <li>$Q$: charge [C]</li>
  <li>$C$: capacitance [F]</li>
  <li>$V$: voltage [V]</li>
</ul>

"""
);
