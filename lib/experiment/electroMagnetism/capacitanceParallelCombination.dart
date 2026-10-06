import '../../model.dart'; // Videoクラス定義が別ならインポート
final capacitanceParallelCombination = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
    iconName: "capacitanceParallelCombination",
    title: "コンデンサの合成容量(並列)",
    titleEn: "Equivalent capacitance of capacitors in parallel",
    videoURL: "NE-Dzw0tjbI",
    equipment: ["コンデンサ", "電源", "マルチメータ(C)"],
    equipmentEn: ["capacitor", "power supply", "multimeter (C)"],
    costRating: "★★☆", latex: r"""
<div class="common-box">ポイント</div>
<p>並列接続されたコンデンサの合成容量$C$は$$\displaystyle C = C_1 + C_2 + \cdots + C_n$$となる。</p>
<p>ここで、</p>
<ul>
  <li>$C$: 合成容量 [F]</li>
  <li>$C_1, C_2, \dots, C_n$: 各コンデンサの容量 [F]</li>
</ul>

<div class="common-box">問題設定</div>
<p>容量3300 μFのコンデンサを2つ並列に接続したとき、合成容量$C$を求めて下さい。</p>

<div class="common-box">理論</div>
<p>並列接続では、合成容量$C$は</p>
<p>$$\displaystyle C = C_1 + C_2$$</p>
<p>で与えられる。ここで $C_1 = C_2 = 3300\ \mu\mathrm{F}$ とすると、</p>
<p>$$C = 3300 + 3300 = 6600\ \mu\mathrm{F}$$</p>

<div class="common-box">答え</div>
<p>合成容量：</p>
<p>$$\boxed{6600\ \mu\mathrm{F}}$$</p>
""",
    latexEn: r"""
<div class="common-box">Key points</div>
<p>The equivalent capacitance $C$ of capacitors connected in parallel is $$\displaystyle C = C_1 + C_2 + \cdots + C_n$$.</p>
<p>Here,</p>
<ul>
  <li>$C$: equivalent capacitance [F]</li>
  <li>$C_1, C_2, \dots, C_n$: capacitance of each capacitor [F]</li>
</ul>

<div class="common-box">Setup</div>
<p>Find the equivalent capacitance $C$ when two $3300\,\mu\mathrm{F}$ capacitors are connected in parallel.</p>

<div class="common-box">Theory</div>
<p>For a parallel connection, the equivalent capacitance $C$ is</p>
<p>$$\displaystyle C = C_1 + C_2$$</p>
<p>With $C_1 = C_2 = 3300\ \mu\mathrm{F}$,</p>
<p>$$C = 3300 + 3300 = 6600\ \mu\mathrm{F}$$</p>

<div class="common-box">Answer</div>
<p>Equivalent capacitance:</p>
<p>$$\boxed{6600\ \mu\mathrm{F}}$$</p>
"""
);