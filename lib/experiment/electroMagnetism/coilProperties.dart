import '../../model.dart'; // Videoクラス定義が別ならインポート
final coilProperties = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
    iconName: "coilProperties",
    title: "コイル",
    titleEn: "Coil",
    videoURL: "UQocVo4qLgo",
    equipment: ["コイル", "電源", "LED", "抵抗", "導線"],
    equipmentEn: ["coil", "power supply", "LED", "resistor", "leads"],
    costRating: "★★☆", latex: r"""
<div class="common-box">ポイント</div>
<p>・コイルに電流が流れると磁場が発生し、その磁場の変化が再びコイルに起電力（誘導起電力）を生み出す。この現象を「自己誘導」という。</p>
<p>・コイルは電流の変化に対して自己誘導作用を示し、電流の変化を妨げる性質を持つ。</p>
""",
    latexEn: r"""
<div class="common-box">Key points</div>
<p>・When a current flows through a coil, a magnetic field is produced, and changes in that magnetic field in turn induce an emf (induced emf) in the coil. This phenomenon is called self-inductance (self-induction).</p>
<p>・A coil exhibits self-inductance in response to changes in current and tends to oppose those changes.</p>
"""
);
