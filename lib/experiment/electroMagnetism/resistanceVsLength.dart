import '../../model.dart'; // Videoクラス定義が別ならインポート
final resistanceVsLength = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
    iconName: "resistance",
    title: "抵抗の長さと抵抗値",
    videoURL: "dBMA0r6J6ns",
    equipment: ["ニクロム線", "電源", "豆電球", "導線"],
    costRating: "★★☆", latex: r"""
<div class="common-box">ポイント</div>
<p>導体の抵抗値 $R$ は以下の式で表される：</p>
<p>$$
R = \rho \frac{L}{A}
$$</p>
<ul>
  <li>$R$：抵抗値（$\Omega$）</li>
  <li>$\rho$：抵抗率（$\Omega \cdot m$）</li>
  <li>$L$：導体の長さ（$m$）</li>
  <li>$A$：断面積（$m^2$）</li>
</ul>

<div class="common-box">問題設定</div>
<p>以下の条件でニクロム線の抵抗値を求めて下さい。</p>
<ul>
  <li>抵抗率 $\rho = 1.10 \times 10^{-6}\,\Omega\cdot\mathrm{m}$</li>
  <li>直径 $d = 0.5,\mathrm{mm}$ または $0.35\mathrm{mm}$</li>
  <li>長さ $L = 0.5,\mathrm{m}$ または $1.0\mathrm{m}$</li>
</ul>

<div class="common-box">理論計算</div>
<p>断面積 $A$ は直径 $d$ から以下の式で求める：</p>
<p>$$
A = \pi \left( \frac{d}{2} \right)^2
$$</p>

<p>抵抗値は式：</p>
<p>$$
R = \rho \frac{L}{A}
$$</p>

<div class="common-box">答え</div>
<p>計算結果は以下の通り。</p>
<table border="1" cellspacing="0" cellpadding="5">
  <thead>
    <tr>
      <th>直径 $d$ (mm)</th>
      <th>長さ $L$ (m)</th>
      <th>断面積 $A$ ($m^2$)</th>
      <th>抵抗 $R$ ($\Omega$)</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>0.5</td>
      <td>0.5</td>
      <td>$$7.85 \times 10^{-8}$$</td>
      <td>7.01</td>
    </tr>
    <tr>
      <td>0.5</td>
      <td>1.0</td>
      <td>$$7.85 \times 10^{-8}$$</td>
      <td>14.03</td>
    </tr>
    <tr>
      <td>0.35</td>
      <td>0.5</td>
      <td>$$9.62 \times 10^{-8}$$</td>
      <td>12.14</td>
    </tr>
    <tr>
      <td>0.35</td>
      <td>1.0</td>
      <td>$$9.62 \times 10^{-8}$$</td>
      <td>24.29</td>
    </tr>
  </tbody>
</table>
"""
);