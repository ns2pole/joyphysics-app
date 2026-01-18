import '../../model.dart'; // Videoクラス定義が別ならインポート
final capacitanceParallelCombination = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
    iconName: "capacitanceParallelCombination",
    title: "コンデンサの合成容量(並列)",
    videoURL: "NE-Dzw0tjbI",
    equipment: ["コンデンサ", "電源", "マルチメータ(C)"],
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
"""
);