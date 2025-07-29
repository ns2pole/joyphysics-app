import '../model.dart'; // Videoクラス定義が別ならインポート
final ampereLawTorque = Video(
    category: 'electroMagnetism', // ← 追加
    iconName: "ampereLawTorque",
    title: "アンペールの法則と直線電流の磁場",
    videoURL: "2gL0ET7XsVU",
    equipment: ["方位磁針", "導線", "電池", "マルチメータ"],
    costRating: "★☆☆", latex: """
<div class="common-box">ポイント</div>
<p>無限に長い直線電流 \$I\$ の周りの磁場の強さ \$B\$ は、距離 \$r\$ に対して次の式で与えられます（直線電流が作る磁場の大きさ）：</p>
<p>\$\$ B = \\frac{\\mu_0 I}{2 \\pi r} \$\$</p>
<p>※記号の定義：</p>
<ul style="line-height:1.6;">
<li>\$B\$：磁場ベクトルの大きさ（T）</li>
<li>\$\\mu_0\$：真空の透磁率（約 \$4\\pi \\times 10^{-7}\$ T·m/A）</li>
<li>\$I\$：直線電流の大きさ（A）</li>
<li>\$r\$：直線電流からの距離（m）</li>
</ul>
<div style="text-align:center; margin:1em 0;">
  <img src="ampereLawTorque.png"
       alt="直線電流の作る磁場"
       style="max-width:50%; height:auto;" />
</div>
<ul>
<li>アンペールの法則は磁場の閉回路性と電流の関係を示す</li>
<li>直線電流の磁場は距離に反比例して弱くなる</li>
<li>磁場の方向は電流の向きと右ねじの法則で決まる</li>
</ul>
"""
);

