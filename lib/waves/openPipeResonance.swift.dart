import './FrequencyMeasureWidget.dart';
import '../model.dart'; // Videoクラス定義が別ならインポート
final openPipeResonance = Video(
    category: 'waves', // ← 追加
    iconName: "openPipeResonance",
    title: "気柱の振動(開管)",
    videoURL: "08SRSu2SoGI",
    equipment: ["サランラップ", "水差し", "スマホ"],
    costRating: "★☆☆", latex: """
    <<div class="common-box">ポイント</div>
<ul style="line-height:1.6;">
  <li>両端が開いた管（開管）では、両端が腹（振幅最大）となるように定常波が形成される。</li>
  <li>このとき、共鳴周波数 \$f\$ は以下の式で表される：<br>
      \$\$f = \\frac{nv}{2L} \\quad (n = 1, 2, 3, \\dots)\$\$</li>
  <li>ただし、現実には音波が開口端からわずかに外へ漏れ出し、反射位置が実際の端よりも外側になる。</li>
  <li>この効果を考慮するため、**開口端補正** \$h\$ を加味し、管の両端で \$2h\$ だけ有効長さが長くなるとすると、以下の式となる：<br>
      \$\$f = \\frac{nv}{2(L + 2h)}\$\$</li>
</ul>

<p>※記号の定義：</p>
<ul style="line-height:1.6;">
  <li>\$f\$：共鳴周波数（ヘルツ, Hz）</li>
  <li>\$n\$：共鳴モード番号（自然数）</li>
  <li>\$v\$：音速（メートル毎秒, m/s）</li>
  <li>\$L\$：管の物理的な長さ（メートル, m）</li>
  <li>\$h\$：開口端補正長（メートル, m）</li>
  <li>\$r\$：管の内半径（メートル, m）</li>
</ul>
<div class="common-box">問題設定</div>
    <p>長さ\$L = 31\\ \\mathrm{cm}\$のサランラップ芯に息を吹きかけるとき、共鳴によって生じる基本振動および高調波の周波数を求めて下さい。</p>
    <p>（1）開口端補正を無視した場合、\$n=1,2,3,4\$の周波数を計算せよ。</p>
    <p>（2）開口端補正を\$h=0.6r\$または\$h=0.8r\$とし、\$r=1.15\\ \\mathrm{cm}\$としたとき、\$n=1,2,3\$の周波数を計算せよ。</p>

    <div class="common-box">理論</div>
    <p>両端が開放された管では、節と腹の関係から<br>
    \$\$L = \\frac{\\lambda}{2},\\; \\lambda,\\; \\frac{3\\lambda}{2},\\;\\dots\$\$<br>
    のような定常波が生じる。音速\$v\$と波長\$\\lambda\$の関係\$\\displaystyle v = f\\lambda\$を使うと、
    \$\$f = \\frac{nv}{2L}\$\$
    の関係式が得られる（\$n\$: 自然数）。</p>

    
    <p>音速\$v=340\\ \\mathrm{m/s}\$、管の長さ\$L = 0.31\\ \\mathrm{m}\$とする。</p>

    <p>（1）開口端補正なし：</p>
    \$\$\\begin{align*}
    f_1 &= \\frac{1 \\times 340}{2 \\times 0.31} \\fallingdotseq 548\\ [\\mathrm{Hz}] \\\\
    f_2 &= \\frac{2 \\times 340}{2 \\times 0.31} \\fallingdotseq 1097\\ [\\mathrm{Hz}] \\\\
    f_3 &= \\frac{3 \\times 340}{2 \\times 0.31} \\fallingdotseq 1645\\ [\\mathrm{Hz}] \\\\
    \\end{align*}\$\$

    <p>（2）開口端補正あり：</p>
    <p>\$r=1.15\\ \\mathrm{cm}\$のとき、</p>
    <ul>
    <li>\$h=0.6r=0.0069\\ \\mathrm{m}\$ → \$L+2h=0.3238\\ \\mathrm{m}\$</li>
    <li>\$h=0.8r=0.0092\\ \\mathrm{m}\$ → \$L+2h=0.3284\\ \\mathrm{m}\$</li>
    </ul>

    <p>補正ありの周波数：</p>

    <p>\$h=0.6r\$ のとき：</p>
    \$\$\\begin{align*}
    f_1 &\\fallingdotseq \\frac{340}{2 \\times 0.3238} \\fallingdotseq 525\\ [\\mathrm{Hz}] \\\\
    f_2 &\\fallingdotseq 1050\\ [\\mathrm{Hz}] \\\\
    f_3 &\\fallingdotseq 1575\\ [\\mathrm{Hz}]
    \\end{align*}\$\$

    <p>\$h=0.8r\$ のとき：</p>
    \$\$\\begin{align*}
    f_1 &\\fallingdotseq \\frac{340}{2 \\times 0.3284} \\fallingdotseq 518\\ [\\mathrm{Hz}] \\\\
    f_2 &\\fallingdotseq 1035\\ [\\mathrm{Hz}] \\\\
    f_3 &\\fallingdotseq 1553\\ [\\mathrm{Hz}]
    \\end{align*}\$\$

    <div class="common-box">答え</div>
    <ul>
        <li>開口端補正なし：\$f_1=548\\ \\mathrm{Hz}\$, \$f_2=1097\\ \\mathrm{Hz}\$, \$f_3=1645\\ \\mathrm{Hz}\$</li>
        <br>
        <li>開口端補正あり（\$h=0.6r\$）：\$f_1=525\\ \\mathrm{Hz}\$, \$f_2=1050\\ \\mathrm{Hz}\$, \$f_3=1575\\ \\mathrm{Hz}\$</li>
        <br>
        <li>開口端補正あり（\$h=0.8r\$）：\$f_1=518\\ \\mathrm{Hz}\$, \$f_2=1035\\ \\mathrm{Hz}\$, \$f_3=1553\\ \\mathrm{Hz}\$</li>
        <br>
        <li>実験値：\$f_1=527\\ \\mathrm{Hz}\$, \$f_2=1055\\ \\mathrm{Hz}\$, \$f_3=1594\\ \\mathrm{Hz}\$</li>
    </ul>
    <p>理論値と測定値は、開口端補正を加えることでより正確に予測できる。</p>
<br>
""",
  experimentWidget: FrequencyMeasureWidget(),
);