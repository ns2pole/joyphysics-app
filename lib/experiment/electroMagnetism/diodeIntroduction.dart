import '../../model.dart'; // Videoクラス定義が別ならインポート
final diodeIntroduction = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
    iconName: "diodeIntroduction",
    title: "ダイオードとはどういうものか",
    videoURL: "rnO5LfjFpp4",
    equipment: ["ダイオード", "電源", "導線"],
    costRating: "★★☆", latex: r"""
<div class="common-box">ポイント</div>
<div style="text-align:center; margin:1em 0;">
  <img src="assets/electroMagnetismDetail/diodeIntroduction.png"
       alt="ダイオード"
       style="max-width:40%; height:auto;" />
</div>
<p>ダイオードは電流を一方向にしか流さない素子であり、この性質は「整流作用」と呼ばれる。</p>
<p>PN接合で構成され、P側（アノード）からN側（カソード）へ電圧をかけると順方向バイアスとなり、電流が流れる。</p>
<p>逆にN側からP側へ電圧をかけると逆方向バイアスとなり、電流はほとんど流れない。</p>
<br>
"""
);
