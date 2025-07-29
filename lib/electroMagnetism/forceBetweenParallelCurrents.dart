import '../model.dart'; // Videoクラス定義が別ならインポート
final forceBetweenParallelCurrents = Video(
    category: 'electroMagnetism', // ← 追加
    iconName: "forceBetweenParallelCurrents",
    title: "平行電流間に働く力",
    videoURL: "mp8eFvdeuZE",
    equipment: ["アルミホイル", "導線", "電池"],
    costRating: "★☆☆", latex: """
<div class="common-box">ポイント</div>
<p>2本の平行導線に電流 \$I_1\$, \$I_2\$ が流れるとき、それらの間に働く磁気力 \$F\$ は次の式で表される：</p>
<p>\$\$ F = \\frac{\\mu_0 I_1 I_2 l}{2 \\pi r} \$\$</p>
<ul>
<li>同じ向きに流れる電流は引き合う力を生じる。</li>
<li>逆向きに流れる電流は反発する力を生じる。</li>
</ul>
<p>※記号の定義：</p>
<ul style="line-height:1.6;">
<li>\$F\$: 働く力の大きさ（N）</li>
<li>\$\\mu_0\$: 真空の透磁率（約 \$4\\pi \\times 10^{-7}\$ T·m/A）</li>
<li>\$I_1\$, \$I_2\$: それぞれの導線を流れる電流の大きさ（A）</li>
<li>\$l\$: 力が作用する導線の長さ（m）</li>
<li>\$r\$: 2本の導線間の距離（m）</li>
</ul>

<p><strong>※この式は導線の長さ \$l\$ が導線間の距離 \$r\$ に比べて十分長い（\$l \\gg r\$）場合の近似式である。</strong><br>
導線が短い場合は端の影響を無視できず、実際の力はこの式からずれる。</p>

<div style="text-align:center; margin:1em 0;">
  <img src="forceBetweenParallelCurrents.png"
       alt="平行電流間に働く力"
       style="max-width:50%; height:auto;" />
</div>
"""
);