import '../../model.dart'; // Videoクラス定義が別ならインポート
final lorentzForce = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
    iconName: "lorentzForce",
    title: "ローレンツ力",
    videoURL: "FAh3rAxihgE",
    equipment: ["ネオジム磁石", "導線", "電源"],
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
"""
);