import '../../model.dart'; // Videoクラス定義が別ならインポート
final coilProperties = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
    iconName: "coilProperties",
    title: "コイルの性質",
    videoURL: "UQocVo4qLgo",
    equipment: ["コイル", "電源", "LED", "抵抗", "導線"],
    costRating: "★★☆", latex: r"""
<div class="common-box">ポイント</div>
<p>・コイルに電流が流れると磁場が発生し、その磁場の変化が再びコイルに起電力（誘導起電力）を生み出す。この現象を「自己誘導」という。</p>
<p>・コイルは電流の変化に対して自己誘導作用を示し、電流の変化を妨げる性質を持つ。</p>
"""
);