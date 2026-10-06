import '../../model.dart'; // Videoクラス定義が別ならインポート
final lorentzForce = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
    iconName: "lorentzForce",
    title: "ローレンツ力",
    titleEn: "Lorentz force",
    videoURL: "FAh3rAxihgE",
    equipment: ["ネオジム磁石", "導線", "電源"],
    equipmentEn: ["neodymium magnet", "wire", "power supply"],
    costRating: "★☆☆", latex: r"""
<div class="common-box">ポイント</div>
<ul>
<li>運動する電荷に働く力の大きさは $F = qvB\sin\theta$</li>
<li>この力は、速度の方向と磁場の方向の両方に垂直な方向に働く（右ねじの法則）</li>
<li>電流 $I$ に磁場が及ぼす力の大きさは $F = IlB\sin\theta$</li>
<li>磁場と導線が垂直なとき（$\theta = 90^\circ$）力の大きさは最大となり、$F = IlB$</li>
<li>ローレンツ力は進行方向を曲げる力であり、運動エネルギーは変化しない</li>
</ul>

<p>記号の定義：</p>
<ul style="line-height: 1.8;">
<li>$F$: 力の大きさ（N）</li>
<li>$q$: 電荷（C）</li>
<li>$v$: 電荷の速度の大きさ（m/s）</li>
<li>$B$: 磁場の強さ（T）</li>
<li>$\theta$: 速度または電流と磁場のなす角</li>
<li>$I$: 電流（A）</li>
<li>$l$: 導線の長さ（m）</li>
</ul>
""",
    latexEn: r"""
<div class="common-box">Key points</div>
<ul>
<li>The magnitude of the force on a moving charge is $F = qvB\sin\theta$</li>
<li>This force acts perpendicular to both the velocity and the magnetic field (right-hand rule)</li>
<li>The magnitude of the force exerted by a magnetic field on a current $I$ is $F = IlB\sin\theta$</li>
<li>When the magnetic field and the wire are perpendicular ($\theta = 90^\circ$), the force is maximum and $F = IlB$</li>
<li>The Lorentz force changes the direction of motion but does not change the kinetic energy</li>
</ul>

<p>Definition of symbols:</p>
<ul style="line-height: 1.8;">
<li>$F$: magnitude of the force (N)</li>
<li>$q$: charge (C)</li>
<li>$v$: speed of the charge (m/s)</li>
<li>$B$: magnetic field strength (T)</li>
<li>$\theta$: angle between the velocity (or current) and the magnetic field</li>
<li>$I$: current (A)</li>
<li>$l$: length of the wire (m)</li>
</ul>
"""
);