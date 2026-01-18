import '../../model.dart'; // Videoクラス定義が別ならインポート
final bismuthDiamagnetism = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
    iconName: "bismuthDiamagnetism",
    title: "ビスマスの反磁性",
    videoURL: "vi5uhB2IOBI",
    equipment: ["ネオジム磁石", "発泡スチロール", "水容器", "ビスマス"],
    costRating: "★★☆", latex: r"""
<div class="common-box">ポイント1</div>
<p>反磁性とは、磁場に反発する性質である。</p>
<p>ビスマスは外部磁場に反発する反磁性を強く示す物質である。</p>
<div class="common-box">解説</div>
<p>ビスマス（原子番号83の金属）はすべての物質の中でも特に強い反磁性を持ち、磁場中に置くと明確に力を受けて移動する様子が観察できる。</p>
<p>この実験では、ビスマス板をネオジム磁石に近づけたときに、反発力によってわずかに押し戻される現象が確認できる。</p>

<div class="common-box">反磁性を持つ主な金属とその強さ<br><small>（測定温度：室温 約20 °C）</small></div>
<table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse; width: 100%;">
  <thead>
    <tr>
      <th>金属名</th>
      <th>磁化率 χ（室温20 °C）</th>
      <th>反磁性の強さ</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>ビスマス (Bi)</td>
      <td>$\displaystyle -1.66\times10^{-4}$</td>
      <td>非常に強い反磁性</td>
    </tr>
    <tr>
      <td>水銀 (Hg（液体）)</td>
      <td>$\displaystyle -2.0\times10^{-4}$</td>
      <td>強い反磁性</td>
    </tr>
    <tr>
      <td>金 (Au)</td>
      <td>$\displaystyle -3.4\times10^{-5}$</td>
      <td>弱い反磁性</td>
    </tr>
    <tr>
      <td>銀 (Ag)</td>
      <td>$\displaystyle -2.7\times10^{-5}$</td>
      <td>弱い反磁性</td>
    </tr>
    <tr>
      <td>タリウム (Tl)</td>
      <td>$\displaystyle -2.5\times10^{-5}$</td>
      <td>弱い反磁性</td>
    </tr>
    <tr>
      <td>銅 (Cu)</td>
      <td>$\displaystyle -1.0\times10^{-5}$</td>
      <td>非常に弱い反磁性</td>
    </tr>
  </tbody>
</table>

<p><small>※ 磁化率の出典：CRC Handbook of Chemistry and Physics, 100th Edition (2019) の室温データ。</small></p>
"""
);