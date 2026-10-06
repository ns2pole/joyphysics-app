import '../../model.dart'; // Videoクラス定義が別ならインポート
final bismuthDiamagnetism = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
    iconName: "bismuthDiamagnetism",
    title: "ビスマスの反磁性",
    titleEn: "Diamagnetism of bismuth",
    videoURL: "vi5uhB2IOBI",
    equipment: ["ネオジム磁石", "発泡スチロール", "水容器", "ビスマス"],
    equipmentEn: ["neodymium magnet", "styrofoam", "water container", "bismuth"],
    costRating: "★★☆", latex: r"""
<div class="common-box">ポイント1</div>
<p>反磁性とは、磁場に反発する性質である。</p>
<p>ビスマスは外部磁場に反発する反磁性を強く示す物質である。</p>
<div class="common-box">解説</div>
<p>ビスマス（原子番号83の金属）は金属のなかでは特に強い反磁性を持ち、磁場中に置くと明確に力を受けて移動する様子が観察できる。</p>
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
      <td>$\displaystyle -2.9\times10^{-5}$</td>
      <td>ビスマスより弱い反磁性</td>
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
""",
    latexEn: r"""
<div class="common-box">Key points 1</div>
<p>Diamagnetism is the property of being repelled by a magnetic field.</p>
<p>Bismuth is a material that shows strong diamagnetism and is repelled by an external magnetic field.</p>
<div class="common-box">Explanation</div>
<p>Bismuth (a metal with atomic number 83) has especially strong diamagnetism among metals, and when placed in a magnetic field it can clearly be seen to experience a force and move.</p>
<p>In this experiment, when a bismuth plate is brought near a neodymium magnet, a slight push-back due to the repulsive force can be observed.</p>

<div class="common-box">Main diamagnetic metals and their strength<br><small>(Measurement temperature: room temperature, about 20 °C)</small></div>
<table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse; width: 100%;">
  <thead>
    <tr>
      <th>Metal</th>
      <th>Magnetic susceptibility χ (room temperature 20 °C)</th>
      <th>Strength of diamagnetism</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Bismuth (Bi)</td>
      <td>$\displaystyle -1.66\times10^{-4}$</td>
      <td>Very strong diamagnetism</td>
    </tr>
    <tr>
      <td>Mercury (Hg, liquid)</td>
      <td>$\displaystyle -2.9\times10^{-5}$</td>
      <td>Weaker diamagnetism than bismuth</td>
    </tr>
    <tr>
      <td>Gold (Au)</td>
      <td>$\displaystyle -3.4\times10^{-5}$</td>
      <td>Weak diamagnetism</td>
    </tr>
    <tr>
      <td>Silver (Ag)</td>
      <td>$\displaystyle -2.7\times10^{-5}$</td>
      <td>Weak diamagnetism</td>
    </tr>
    <tr>
      <td>Thallium (Tl)</td>
      <td>$\displaystyle -2.5\times10^{-5}$</td>
      <td>Weak diamagnetism</td>
    </tr>
    <tr>
      <td>Copper (Cu)</td>
      <td>$\displaystyle -1.0\times10^{-5}$</td>
      <td>Very weak diamagnetism</td>
    </tr>
  </tbody>
</table>

<p><small>※ Source of susceptibility values: room-temperature data from CRC Handbook of Chemistry and Physics, 100th Edition (2019).</small></p>
"""
);
