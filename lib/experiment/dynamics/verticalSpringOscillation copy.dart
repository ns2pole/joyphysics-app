import '../../model.dart'; // Videoクラス定義が別ならインポート
final verticalSpringOscillation = Video(
    category: 'dynamics', // ← 追加
    iconName: "verticalSpringOscillation",
    title: "単振動 (鉛直バネ振り子)",
    videoURL: "W6dxv-MvDxo",
    equipment: ["バネ", "おもり", "スマホ"],
    costRating: "★★☆", latex: """
        <div class="common-box">ポイント</div>
        <p>鉛直バネ振り子の周期は、重力の影響にかかわらず <strong>質量</strong> と <strong>ばね定数</strong> のみで決まる。</p>
        <p>\$\$T = 2\\pi \\sqrt{\\frac{m}{k}}\$\$</p>
        <p>ここで、\$T\$: 周期 [s], \$m\$: 質量 [kg], \$k\$: ばね定数 [N/m]</p>

        <div class="common-box">問題設定</div>
        <p>質量 \$m = 0.1\\,\\mathrm{kg}\$ のおもりを、ばね定数 \$k = 4.0\\,\\mathrm{N/m}\$ のバネに取り付けて垂直に吊るす。このとき、重力方向に沿って単振動を行わせた場合の周期 \$T\$ を求めて下さい。</p>

        <div class="common-box">理論値計算</div>
        <p>単振動の周期は次の式で表される：</p>
        <p>\$\$T = 2\\pi \\sqrt{\\frac{m}{k}}\$\$</p>
        <p>与えられた値を代入すると、</p>
        <p>\$\$T = 2\\pi \\sqrt{\\frac{0.1}{4.0}} = 2\\pi \\sqrt{0.025} \\fallingdotseq 0.99\\,\\mathrm{s}\$\$</p>
        <div class="common-box">答え</div>
        \$\$\\boxed{T \\fallingdotseq 0.99\\,\\mathrm{s}}\$\$
    """
);