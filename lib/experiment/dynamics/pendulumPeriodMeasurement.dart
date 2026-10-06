import '../../model.dart'; // Videoクラス定義が別ならインポート
final pendulumPeriodMeasurement = Video(
  isExperiment: true,
  category: 'dynamics', // ← 追加
    iconName: "pendulumPeriodMeasurement",
    title: "単振り子の周期",
    titleEn: "Period of a simple pendulum",
    videoURL: "kE5I2WbKwJ0",
    equipment: ["糸", "おもり", "スマホ", "巻尺"],
    equipmentEn: ["string", "weight", "smartphone", "measuring tape"],
    costRating: "★☆☆", latex: r"""
        <div class="common-box">ポイント</div>
        <p>角度 $\theta(t)$ が十分小さいとき、$\sin \theta(t)$ を $\theta(t)$ で近似できる。</p>
        <p>この条件下でニュートンの運動方程式より、単振り子の周期 $T$ は次の式で表される：</p>
        <p>$$T = 2\pi\sqrt{\frac{L}{g}}$$</p>
        <p>ここで、$T$: 周期 [s], $L$: 紐の長さ [m], $g$: 重力加速度 (9.8 m/s²)</p>

        <div class="common-box">問題設定</div>
        <p>紐の長さが $30\ \mathrm{cm}$ および $60\ \mathrm{cm}$ の単振り子について、それぞれの周期を求めて下さい。</p>

        <div class="common-box">理論値計算</div>
        <p>・$L = 30\ \mathrm{cm} = 0.30\ \mathrm{m}$ の場合：</p>
        <p>$$T = 2\pi\sqrt{\frac{0.30}{9.8}} \fallingdotseq 1.10\,\mathrm{s}$$</p>
        <p>・$L = 60\ \mathrm{cm} = 0.60\ \mathrm{m}$ の場合：</p>
        <p>$$T = 2\pi\sqrt{\frac{0.60}{9.8}} \fallingdotseq 1.55\,\mathrm{s}$$</p>

        <div class="common-box">答え</div>
        <p>周期は、$\displaystyle \begin{cases}
        L = 30\,\mathrm{cm}: & T \fallingdotseq 1.10\,\mathrm{s} \\
        L = 60\,\mathrm{cm}: & T \fallingdotseq 1.55\,\mathrm{s}
        \end{cases}$</p>
        <p>30回振動するのにかかる時間は：
        $\begin{cases}
        L = 30\,\mathrm{cm}: & 30T \fallingdotseq 33.0\,\mathrm{s} \\
        L = 60\,\mathrm{cm}: & 30T \fallingdotseq 46.6\,\mathrm{s}
        \end{cases}$</p>
    """,
    latexEn: r"""
        <div class="common-box">Key points</div>
        <p>When the angle $\theta(t)$ is sufficiently small, $\sin \theta(t)$ can be approximated by $\theta(t)$.</p>
        <p>Under this condition, Newton's equation of motion gives the period $T$ of a simple pendulum as</p>
        <p>$$T = 2\pi\sqrt{\frac{L}{g}}$$</p>
        <p>Here $T$: period [s], $L$: string length [m], $g$: gravitational acceleration ($9.8\,\mathrm{m/s^2}$)</p>

        <div class="common-box">Setup</div>
        <p>Find the period of a simple pendulum for string lengths $30\ \mathrm{cm}$ and $60\ \mathrm{cm}$.</p>

        <div class="common-box">Theory</div>
        <p>・For $L = 30\ \mathrm{cm} = 0.30\ \mathrm{m}$:</p>
        <p>$$T = 2\pi\sqrt{\frac{0.30}{9.8}} \fallingdotseq 1.10\,\mathrm{s}$$</p>
        <p>・For $L = 60\ \mathrm{cm} = 0.60\ \mathrm{m}$:</p>
        <p>$$T = 2\pi\sqrt{\frac{0.60}{9.8}} \fallingdotseq 1.55\,\mathrm{s}$$</p>

        <div class="common-box">Answer</div>
        <p>The periods are $\displaystyle \begin{cases}
        L = 30\,\mathrm{cm}: & T \fallingdotseq 1.10\,\mathrm{s} \\
        L = 60\,\mathrm{cm}: & T \fallingdotseq 1.55\,\mathrm{s}
        \end{cases}$</p>
        <p>The time for 30 oscillations is
        $\begin{cases}
        L = 30\,\mathrm{cm}: & 30T \fallingdotseq 33.0\,\mathrm{s} \\
        L = 60\,\mathrm{cm}: & 30T \fallingdotseq 46.6\,\mathrm{s}
        \end{cases}$</p>
    """
);