import '../../model.dart'; // Videoクラス定義が別ならインポート
final resistivityTemperatureDependence = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
    iconName: "resistivityTemperatureDependence",
    title: "温度による銅線の抵抗変化",
    videoURL: "WRXY65C0pA4",
    equipment: ["銅線", "マルチメータ", "お湯"],
    costRating: "★★☆", latex: r"""
        <div class="common-box">ポイント</div>
        <p>抵抗は温度によって変化する。金属の抵抗値 $R_T$ は以下の式で表される。</p>
        <p>$$R_T = R_0 (1 + \alpha T)$$</p>
        <p>また、抵抗値の基本式は</p>
        <p>$$R = \rho \frac{ L}{A}$$</p>
        <p>ここで、$\rho$: 抵抗率、$L$: 長さ、$A$: 断面積。</p>

        <div class="common-box">問題設定</div>
        <p>線径 $d = 0.16 \mathrm{mm}$、長さ $L = 15 \mathrm{m}$ の銅線の抵抗を、温度 $10^{\circ}\mathrm{C}$ および $100^{\circ}\mathrm{C}$ で求めて下さい。</p>
        <p>条件：</p>
        <ul>
            <li>銅の抵抗率（0℃基準）：$\rho_0 = 1.55 \times 10^{-8} \, \Omega\cdot m$</li>
            <li>温度係数：$\alpha = 0.00393$</li>
        </ul>

        <div class="common-box">理論値計算</div>
        <p>断面積：$\displaystyle A = \frac{\pi d^2}{4} = \frac{\pi \times (0.00016)^2}{4} \fallingdotseq 2.0106 \times 10^{-8} \, m^2$</p>

        <p>(1)温度 $10^{\circ}\mathrm{C}$ のとき：</p>
        <p>$$R_{10} = \frac{\rho_0 (1 + \alpha \times 10) L}{A}$$</p>
        <p>$$R_{10} = \frac{1.55 \times 10^{-8} \times (1 + 0.00393 \times 10) \times 15}{2.0106 \times 10^{-8}} \fallingdotseq 12.01 \, \Omega$$</p>

        <p>(2)温度 $100^{\circ}\mathrm{C}$ のとき：</p>
        <p>$$R_{100} = \frac{\rho_0 (1 + \alpha \times 100) L}{A}$$</p>
        <p>$$R_{100} = \frac{1.55 \times 10^{-8} \times (1 + 0.00393 \times 100) \times 15}{2.0106 \times 10^{-8}} \fallingdotseq 16.10 \, \Omega$$</p>

        <div class="common-box">答え</div>
        <p>$$\boxed{
    $$\begin{aligned}
            10^{\circ}\mathrm{C} のとき：R \fallingdotseq 12.01 \, \Omega \\
            100^{\circ}\mathrm{C} のとき：R \fallingdotseq 16.10 \, \Omega
    \end{aligned}$$
    }$$</p>
    """
);