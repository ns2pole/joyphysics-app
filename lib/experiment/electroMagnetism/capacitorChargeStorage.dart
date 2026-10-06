import '../../model.dart'; // Videoクラス定義が別ならインポート
final capacitorChargeStorage = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
    iconName: "capacitorChargeStorage",
    title: "コンデンサに蓄えられる電気量",
    titleEn: "Charge stored in a capacitor",
    videoURL: "J00dA2UExvM",
    equipment: ["コンデンサ", "電源", "マルチメータ(C)"],
    equipmentEn: ["capacitor", "power supply", "multimeter (C)"],
    costRating: "★★★", latex: r"""
<div class="common-box">ポイント</div>
<p>コンデンサに加えられた電圧$V$に比例して電荷量$Q$が蓄えられる。</p>
<p>その関係は以下の式で表される：</p>
<p>$$\displaystyle Q = CV$$</p>
<ul>
  <li>$Q$: 蓄えられる電荷量 [C]</li>
  <li>$C$: 容量 [F]</li>
  <li>$V$: 電圧 [V]</li>
</ul>

<div class="common-box">問題設定</div>
<p>容量 $5\,\mathrm{F}$ のコンデンサに $1.5\,\mathrm{V}$ の電圧を加えたとき、蓄えられる電荷量 $Q$ を求めて下さい。$5\,\mathrm{F}$ は通常の $\mu\mathrm{F}$ 級よりずっと大きく、電気二重層コンデンサの桁です。</p>

<div class="common-box">理論</div>
<p>コンデンサに蓄えられる電荷量は容量$C$と加えられた電圧$V$の積で与えられる：</p>
<p>$$\displaystyle Q = CV$$</p>
<p>数値を代入すると：</p>
<p>$$Q = 5 \times 1.5 = 7.5\ [\mathrm{C}]$$</p>

<div class="common-box">答え</div>
<p>蓄えられる電荷量$Q$は：</p>
<p>$$\boxed{7.5\ \mathrm{C}}$$</p>
""",
    latexEn: r"""
<div class="common-box">Key points</div>
<p>The charge $Q$ stored in a capacitor is proportional to the applied voltage $V$.</p>
<p>This relation is written as:</p>
<p>$$\displaystyle Q = CV$$</p>
<ul>
  <li>$Q$: stored charge [C]</li>
  <li>$C$: capacitance [F]</li>
  <li>$V$: voltage [V]</li>
</ul>

<div class="common-box">Setup</div>
<p>Find the charge $Q$ stored when a voltage of $1.5\,\mathrm{V}$ is applied to a capacitor of capacitance $5\,\mathrm{F}$. A value of $5\,\mathrm{F}$ is much larger than ordinary $\mu\mathrm{F}$-class capacitors and is typical of electric double-layer capacitors.</p>

<div class="common-box">Theory</div>
<p>The charge stored in a capacitor is the product of the capacitance $C$ and the applied voltage $V$:</p>
<p>$$\displaystyle Q = CV$$</p>
<p>Substituting the values:</p>
<p>$$Q = 5 \times 1.5 = 7.5\ [\mathrm{C}]$$</p>

<div class="common-box">Answer</div>
<p>The stored charge $Q$ is:</p>
<p>$$\boxed{7.5\ \mathrm{C}}$$</p>
"""
);
