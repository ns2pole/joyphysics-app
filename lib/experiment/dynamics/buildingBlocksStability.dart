import '../../model.dart'; // Videoクラス定義が別ならインポート
final buildingBlocksStability = Video(
  isExperiment: true,
  category: 'dynamics', // ← 追加
    iconName: "buildingBlocksStability",
    title: "積み木",
    titleEn: "Building blocks",
    videoURL: "-HkXWEXjywc",
    equipment: ["木材ブロック"],
    equipmentEn: ["wooden blocks"],
    costRating: "★☆☆", latex: r"""
        <div class="common-box">ポイント</div>
        <p>物体に働く全ての力を$\vec{F_1}, \vec{F_2}, \cdots$</p>
        <p>物体に働く全てのある点まわりのモーメントを$\tau_1, \tau_2, \cdots$ とすると</p>
        <div class="common-box">力とモーメントのつり合い</div>
        <p>$\displaystyle \vec{F_1} + \vec{F_2} + \cdots = \vec{0}$（力のつり合い）</p>
        <p>$\displaystyle \tau_1 + \tau_2 + \cdots = 0$（モーメントのつり合い）</p>
        <div class="common-box">積み木の安定条件</div>
        <p>物体が倒れずに安定しているためには、上記のつり合い条件を満たす必要がある。</p>
    """,
    latexEn: r"""
        <div class="common-box">Key points</div>
        <p>Let all forces on the object be $\vec{F_1}, \vec{F_2}, \cdots$</p>
        <p>and all moments about a chosen point be $\tau_1, \tau_2, \cdots$. Then</p>
        <div class="common-box">Force and moment balance</div>
        <p>$\displaystyle \vec{F_1} + \vec{F_2} + \cdots = \vec{0}$（force balance）</p>
        <p>$\displaystyle \tau_1 + \tau_2 + \cdots = 0$（moment balance）</p>
        <div class="common-box">Stability condition for stacked blocks</div>
        <p>For the object to remain stable without tipping, the balance conditions above must hold.</p>
    """
);