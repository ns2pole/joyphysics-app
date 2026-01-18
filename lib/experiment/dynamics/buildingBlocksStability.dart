import '../../model.dart'; // Videoクラス定義が別ならインポート
final buildingBlocksStability = Video(
  isExperiment: true,
  category: 'dynamics', // ← 追加
    iconName: "buildingBlocksStability",
    title: "積み木",
    videoURL: "-HkXWEXjywc",
    equipment: ["木材ブロック"],
    costRating: "★☆☆", latex: r"""
        <div class="common-box">ポイント</div>
        <p>物体に働く全ての力を$\vec{F_1}, \vec{F_2}, \cdots$</p>
        <p>物体に働く全てのある点まわりのモーメントを$\tau_1, \tau_2, \cdots$ とすると</p>
        <div class="common-box">力とモーメントのつり合い</div>
        <p>$\displaystyle \vec{F_1} + \vec{F_2} + \cdots = \vec{0}$（力のつり合い）</p>
        <p>$\displaystyle \tau_1 + \tau_2 + \cdots = 0$（モーメントのつり合い）</p>
        <div class="common-box">積み木の安定条件</div>
        <p>物体が倒れずに安定しているためには、上記のつり合い条件を満たす必要がある。</p>
    """
);