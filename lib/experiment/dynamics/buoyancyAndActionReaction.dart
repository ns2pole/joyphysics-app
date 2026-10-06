import '../../model.dart'; // Videoクラス定義が別ならインポート
final buoyancyAndActionReaction = Video(
    isExperiment: true,
    category: 'dynamics', // ← 追加
    iconName: "buoyancyAndActionReaction",
    title: "浮力と作用反作用",
    titleEn: "Buoyancy and action–reaction",
    videoURL: "N44Pevlnl00",
    videoURLEn: "6ux5mqn8cKM",
    equipment: ["水槽", "おもり", "台秤", "ばねばかり", "糸"],
    equipmentEn: ["tank", "weight", "platform scale", "spring scale", "string"],
    costRating: "★★☆", latex: r"""
    <div class="common-box">ポイント 1</div>
    <p>アルキメデスの原理:「流体中の物体は、その物体が押しのけた流体の重さに等しい浮力を受ける」</p>
    <p>浮力の大きさは$ F = \rho V g $で表される：</p>
    <p>ここで、$F$ は浮力 [N]、$\rho$ は流体の密度 [kg/m³]、$V$ は物体の体積 [m³]、$g$ は重力加速度 [m/s²]。</p>
    <div class="common-box">ポイント 2</div>
    <p>作用反作用の法則：$\overrightarrow{F}_{1 \leftarrow 2} + \overrightarrow{F}_{2 \leftarrow 1} = \overrightarrow{0}$
    <div class="common-box">問題設定</div>
    <p>秤に水を入れた容器が乗っている。この水中に糸に釣った錘を沈めると、秤の数値はどう変化するか？</p>

    <div class="common-box">理論値計算</div>
    浮力とは、水が物体に及ぼす力で上向きに働くので、作用反作用の法則より、水は浮力と同じ大きさの力を下向きに受ける。
    <p>錘に働く浮力は$F = \rho V g $</p>
    <p>よって、水は物体から、$\rho V g $の力を下向きに受ける。
    <p>これを秤が支えるので、秤が水と容器に及ぼす垂直抗力 $N$ は、水と容器の重さ $Mg$ と浮力の反作用 $\rho V g$ の和です。錘の重さそのものは糸が支えていて、秤には載りません。</p>
    <p>$$\displaystyle N = Mg + \rho V g$$</p>
    <div class="common-box">答え</div>
    <p>秤の読みは錘を沈める前に比べて、浮力の大きさ$\rho V g$の分だけ増加する。</p>
    """,
    latexEn: r"""
    <div class="common-box">Key points 1</div>
    <p>Archimedes' principle: "An object in a fluid experiences a buoyancy equal to the weight of the fluid it displaces."</p>
    <p>The magnitude of the buoyancy is $ F = \rho V g $:</p>
    <p>Here, $F$ is the buoyancy [N], $\rho$ is the fluid density [kg/m³], $V$ is the object's volume [m³], and $g$ is the gravitational acceleration [m/s²].</p>
    <div class="common-box">Key points 2</div>
    <p>Action–reaction law: $\overrightarrow{F}_{1 \leftarrow 2} + \overrightarrow{F}_{2 \leftarrow 1} = \overrightarrow{0}$
    <div class="common-box">Setup</div>
    <p>A container of water sits on a scale. If a weight hung from a string is submerged in the water, how does the scale reading change?</p>

    <div class="common-box">Theory</div>
    Buoyancy is the upward force that water exerts on the object, so by the action–reaction law the water receives an equal downward force.
    <p>The buoyancy on the weight is $F = \rho V g $</p>
    <p>Therefore the water receives a downward force $\rho V g $ from the object.
    <p>The scale supports this, so the normal force $N$ that the scale exerts on the water and container is the sum of the weight $Mg$ of the water and container and the reaction to the buoyancy $\rho V g$. The weight of the hanging mass itself is supported by the string and does not rest on the scale.</p>
    <p>$$\displaystyle N = Mg + \rho V g$$</p>
    <div class="common-box">Answer</div>
    <p>Compared with before the weight was submerged, the scale reading increases by the buoyancy $\rho V g$.</p>
    """
);
