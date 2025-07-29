import '../model.dart'; // Videoクラス定義が別ならインポート
final capacitorChargeStorage = Video(
    category: 'electroMagnetism', // ← 追加
    iconName: "capacitorChargeStorage",
    title: "コンデンサに蓄えられる電気量",
    videoURL: "J00dA2UExvM",
    equipment: ["コンデンサ", "電源", "マルチメータ(C)"],
    costRating: "★★★", latex: """
<div class="common-box">ポイント</div>
<p>コンデンサに加えられた電圧\$V\$に比例して電荷量\$Q\$が蓄えられる。</p>
<p>その関係は以下の式で表される：</p>
<p>\$\$\\displaystyle Q = CV\$\$</p>
<ul>
  <li>\$Q\$: 蓄えられる電荷量 [C]</li>
  <li>\$C\$: 容量 [F]</li>
  <li>\$V\$: 電圧 [V]</li>
</ul>

<div class="common-box">問題設定</div>
<p>容量\$5{F}\$のコンデンサに1.5Vの電圧を加えたとき、蓄えられる電荷量\$Q\$を求めて下さい。</p>

<div class="common-box">理論</div>
<p>コンデンサに蓄えられる電荷量は容量\$C\$と加えられた電圧\$V\$の積で与えられる：</p>
<p>\$\$\\displaystyle Q = CV\$\$</p>
<p>数値を代入すると：</p>
<p>\$\$Q = 5 \\times 1.5 = 7.5\\ [\\mathrm{C}]\$\$</p>

<div class="common-box">答え</div>
<p>蓄えられる電荷量\$Q\$は：</p>
<p>\$\$\\boxed{7.5\\ \\mathrm{C}}\$\$</p>
"""
);