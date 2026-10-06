import '../../model.dart'; // Videoクラス定義が別ならインポート
final capacitanceSeriesCombination = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
    iconName: "capacitanceSeriesCombination",
    title: "コンデンサの合成容量(直列)",
    titleEn: "Equivalent capacitance of capacitors in series",
    videoURL: "bde6LgMjf2k",
    equipment: ["コンデンサ", "電源", "マルチメータ(C)"],
    equipmentEn: ["capacitor", "power supply", "multimeter (C)"],
    costRating: "★★☆", latex: r"""
<div class="common-box">ポイント</div>
<p>直列接続されたコンデンサの合成容量$C$は$$\displaystyle \frac{1}{C} = \frac{1}{C_1} + \frac{1}{C_2} + \cdots + \frac{1}{C_n}$$で与えられる。</p>
<p>ここで、</p>
<ul>
  <li>$C$: 合成容量 [F]</li>
  <li>$C_1, C_2, \dots, C_n$: 各コンデンサの容量 [F]</li>
</ul>

<div class="common-box">問題設定</div>
<p>容量3300 μFのコンデンサを2つ直列に接続したとき、合成容量$C$を求めて下さい。</p>

<div class="common-box">理論</div>
<p>直列接続では、合成容量$C$は次の式に従う：</p>
<p>$$\displaystyle \frac{1}{C} = \frac{1}{C_1} + \frac{1}{C_2}$$</p>
<p>ここで $C_1 = C_2 = 3300\ \mu\mathrm{F}$ とすれば、</p>
<p>$$\displaystyle \frac{1}{C} = \frac{1}{3300} + \frac{1}{3300} = \frac{2}{3300}$$</p>
<p>したがって、</p>
<p>$$C = \frac{3300}{2} = 1650\ \mu\mathrm{F}$$</p>

<div class="common-box">答え</div>
<p>合成容量：</p>
<p>$$\boxed{1650\ \mu\mathrm{F}}$$</p>
""",
    latexEn: r"""
<div class="common-box">Key points</div>
<p>The equivalent capacitance $C$ of capacitors connected in series is given by $$\displaystyle \frac{1}{C} = \frac{1}{C_1} + \frac{1}{C_2} + \cdots + \frac{1}{C_n}$$.</p>
<p>Here,</p>
<ul>
  <li>$C$: equivalent capacitance [F]</li>
  <li>$C_1, C_2, \dots, C_n$: capacitance of each capacitor [F]</li>
</ul>

<div class="common-box">Setup</div>
<p>Find the equivalent capacitance $C$ when two $3300\,\mu\mathrm{F}$ capacitors are connected in series.</p>

<div class="common-box">Theory</div>
<p>For a series connection, the equivalent capacitance $C$ follows:</p>
<p>$$\displaystyle \frac{1}{C} = \frac{1}{C_1} + \frac{1}{C_2}$$</p>
<p>With $C_1 = C_2 = 3300\ \mu\mathrm{F}$,</p>
<p>$$\displaystyle \frac{1}{C} = \frac{1}{3300} + \frac{1}{3300} = \frac{2}{3300}$$</p>
<p>Therefore,</p>
<p>$$C = \frac{3300}{2} = 1650\ \mu\mathrm{F}$$</p>

<div class="common-box">Answer</div>
<p>Equivalent capacitance:</p>
<p>$$\boxed{1650\ \mu\mathrm{F}}$$</p>
"""
);
