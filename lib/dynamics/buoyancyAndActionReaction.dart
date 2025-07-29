import '../model.dart'; // Videoクラス定義が別ならインポート
final buoyancyAndActionReaction = Video(
    category: 'dynamics', // ← 追加
    iconName: "buoyancyAndActionReaction",
    title: "浮力と作用反作用",
    videoURL: "N44Pevlnl00",
    equipment: ["水槽", "おもり", "台秤", "ばねばかり", "糸"],
    costRating: "★★☆", latex: """
    <div class="common-box">ポイント 1</div>
    <p>アルキメデスの原理:「流体中の物体は、その物体が押しのけた流体の重さに等しい浮力を受ける」</p>
    <p>浮力の大きさは\$ F = \\rho V g \$で表される：</p>
    <p>ここで、\$F\$ は浮力 [N]、\$\\rho\$ は流体の密度 [kg/m³]、\$V\$ は物体の体積 [m³]、\$g\$ は重力加速度 [m/s²]。</p>
    <div class="common-box">ポイント 2</div>
    <p>作用反作用の法則：\$\\overrightarrow{F}_{1 \\leftarrow 2} + \\overrightarrow{F}_{2 \\leftarrow 1} = \\overrightarrow{0}\$
    <div class="common-box">問題設定</div>
    <p>秤に水を入れた容器が乗っている。この水中に糸に釣った錘を沈めると、秤の数値はどう変化するか？</p>

    <div class="common-box">理論値計算</div>
    浮力とは、水が物体に及ぼす力で上向きに働くので、作用反作用の法則より、水は浮力と同じ大きさの力を下向きに受ける。
    <p>錘に働く浮力は\$F = \\rho V g \$</p>
    <p>よって、水は物体から、\$\\rho V g \$の力を下向きに受ける。
    <p>これを秤が支えるので、秤が水と容器に及ぼす垂直抗力\$N\$は錘の重力\$Mg\$と浮力の反作用 \$\\rho V g\$ の和：\$ N = Mg + \\rho V g \$となる。</p>
    <div class="common-box">答え</div>
    <p>秤の読みは錘を沈める前に比べて、浮力の大きさ\$\\rho V g\$の分だけ増加する。</p>
    """
);