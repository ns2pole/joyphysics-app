import '../../model.dart'; // Videoクラス定義が別ならインポート
final rcCircuit = Video(
    category: 'electroMagnetism', // ← 追加
    iconName: "rcCircuit",
    title: "RC回路",
    videoURL: "oVY3-umLN14",
    equipment: ["抵抗", "コンデンサ", "マルチメータ", "導線", "電池"],
    costRating: "★★★", latex: """
<div class="common-box">記号</div>
・\$t\$：時刻<br>
・\$I(t)\$：時刻 \$t\$ における回路に流れる電流<br>
・\$Q(t)\$：時刻 \$t\$ にコンデンサに蓄えられている電荷<br>
・\$RI(t)\$：抵抗による電圧降下<br>
<div class="common-box">ポイント</div>
<ul style="line-height:1.6;">
  <li>RC回路では、コンデンサの電荷や電流の時間変化を微分方程式で表すことができる。</li>
  <li>キルヒホッフの第2法則（電圧則）により、電源電圧は抵抗とコンデンサの電圧降下の和に等しい：<br>
      \$\$V = RI(t) + \\frac{Q(t)}{C}\$\$</li>
  <li>また、電流 \$I(t)\$ は電荷の時間微分である：<br>
      \$\$I(t) = \\frac{dQ(t)}{dt}\$\$</li>
</ul>

<div class="common-box">問題設定</div>
<div style="text-align:center; margin:1em 0;">
  <img src="assets/electroMagnetismDetail/rcCircuit.webp"
       alt="RC回路"
       style="max-width:100%; height:auto;" />
</div>

（1）抵抗 \$R\$、コンデンサ \$C\$、電源電圧 \$V\$ を持つ直列RC回路において、時刻 \$t=0\$ にスイッチを入れたときの、電荷 \$Q(t)\$ および電流 \$I(t)\$ の時間変化を求めて下さい。

<p>（2）電圧 \$V=3\\ [\\mathrm{V}]\$、抵抗 \$R=2000\\ [\\Omega]\$、容量 \$C=3300\\ [\\mu\\mathrm{F}]=3.3\\times 10^{-3}\\ [\\mathrm{F}]\$のとき、\$Q(t)\$,\$I(t)\$,\$RI(t)\$ を具体的に求めて下さい。</p>

<div class="common-box">理論計算 
<a href="app://topic?video=rcCircuit">詳しくはこちら</a>
</div>
<p>キルヒホッフの法則より以下の微分方程式を立てる：</p>

<p>\$\$
\\begin{cases}
\\displaystyle V = RI(t) + \\frac{Q(t)}{C} \\\\
\\displaystyle I(t) = \\frac{dQ}{dt}(t)
\\end{cases}
\$\$</p>

<p>初期条件 \$Q(0) = 0\$ より、積分定数 \$A = -CV\$ を代入すると：</p>

<p>\$\$
\\begin{aligned}
Q(t) &= CV \\left(1 - e^{-\\frac{t}{RC}} \\right) \\\\
     &\\quad \\text{（コンデンサにたまる電荷）} \\\\
I(t) &= \\frac{V}{R} e^{-\\frac{t}{RC}} \\\\
     &\\quad \\text{（回路に流れる電流）} \\\\
RI(t) &= V e^{-\\frac{t}{RC}} \\\\
      &\\quad \\text{（抵抗による電圧降下）}
\\end{aligned}
\$\$</p>

<p>電圧降下が \$\\frac{V}{2}\$、\$\\frac{V}{4}\$ となる時刻：</p>

<p>\$\$
\\begin{aligned}
t &= RC\\log 2 \\fallingdotseq 0.693 RC \\\\
t &= 2RC\\log 2 \\fallingdotseq 1.386 RC
\\end{aligned}
\$\$</p>

<div class="common-box">答え</div>
<p>与えられた数値を代入すると：</p>

<ul>
  <li>\$\$RC = 6.6\\ [\\mathrm{s}]\$\$</li>
</ul>

<p>電荷と電流の式は：</p>

<p>\$\$
\\begin{aligned}
Q(t) &= 9.9 \\times 10^{-3} \\left(1 - e^{-\\frac{t}{6.6}}\\right) \\\\
     &\\quad \\text{（コンデンサにたまる電荷）} \\\\
I(t) &= \\frac{3}{2000} e^{-\\frac{t}{6.6}} = 1.5 \\times 10^{-3} e^{-\\frac{t}{6.6}} \\\\
     &\\quad \\text{（回路に流れる電流）} \\\\
RI(t) &= 3 e^{-\\frac{t}{6.6}} \\\\
      &\\quad \\text{（抵抗による電圧降下）}
\\end{aligned}
\$\$</p>

<p>電圧降下が \$\\frac{3}{2}\\ [\\mathrm{V}]\$、\$\\frac{3}{4}\\ [\\mathrm{V}]\$ になる時刻は：</p>

<p>\$\$
\\begin{aligned}
t &= 6.6 \\times 0.693 \\fallingdotseq 4.6\\ [\\mathrm{s}] \\\\
t &= 6.6 \\times 1.386 \\fallingdotseq 9.2\\ [\\mathrm{s}]
\\end{aligned}
\$\$</p>
"""
);