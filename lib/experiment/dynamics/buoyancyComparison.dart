import '../../model.dart'; // Videoクラス定義が別ならインポート
final buoyancyComparison = Video(
  isExperiment: true,
  category: 'dynamics', // ← 追加
    iconName: "buoyancyComparison",
    title: "浮力（食塩水・普通の水・油での比較）",
    videoURL: "44vPx_0XeO0",
    equipment: ["ガラス容器", "木", "塩", "油"],
    costRating: "★☆☆", latex: r"""
        <div class="common-box">ポイント</div>
            <p>アルキメデスの原理:「流体中の物体は、その物体が押しのけた流体の重さに等しい浮力を受ける」</p>
            <p>浮力の大きさは$\  F = \rho V g $で表される</p>
            <p>ここで、$F$ は浮力 [N]、$\rho$ は流体の密度 [kg/m³]、$V$ は物体の体積 [m³]、$g$ は重力加速度 [m/s²]。</p>
        <div class="common-box">問題設定</div>
        <p>直径 $r=1\,\mathrm{cm}$、長さ $L=20\,\mathrm{cm}$、質量 $m=8\,\mathrm{g}$ の木の棒を体積 $V=5\pi\,[\mathrm{cm^3}]$ として、</p>
        <p>密度</p>
        <ul>
          <li>飽和食塩水：$\rho_{salt}=1.20\,[\mathrm{g/cm^3}]$</li>
          <li>普通の水：$\rho_{water}=0.998\,[\mathrm{g/cm^3}]$</li>
          <li>油：$\rho_{oil}=0.90\,[\mathrm{g/cm^3}]$</li>
        </ul>
        <p>に沈めると、沈む長さはそれぞれどうなるか？</p>

        <div class="common-box">理論値計算</div>
        <p>力のつり合いとアルキメデスの原理より、</p>
        <p>
            $$\begin{aligned}

            m g &= \rho_{fluid}\,\pi r^2\,l_{fluid}\,g \\ \ \\
            \Leftrightarrow \ l_{fluid} &= L\frac{\rho}{\rho_{fluid}}
                \end{aligned}$$
        </p>
        <p>ここで木材の密度 $\rho = m/(\pi r^2 L)=0.509\,[\mathrm{g/cm^3}]$。</p>
        <p>よって、</p>
        <p>
        $$ l_{salt} = 20 \times \frac{0.509}{1.20} \fallingdotseq 8.48\,[\mathrm{cm}] $$
        </p>
        <p>
        $$ l_{water} = 20 \times \frac{0.509}{0.998} \fallingdotseq 10.20\,[\mathrm{cm}] $$
        </p>
        <p>
        $$ l_{oil} = 20 \times \frac{0.509}{0.90} \fallingdotseq 11.31\,[\mathrm{cm}] $$
        </p>
    
    """
);