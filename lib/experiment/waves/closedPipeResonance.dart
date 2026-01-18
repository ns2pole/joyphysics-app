import '../../model.dart'; // Videoクラス定義が別ならインポート
final closedPipeResonance = Video(
  isExperiment: true,
  category: 'waves', // ← 追加
    iconName: "closedPipeResonance",
    title: "気柱の振動(閉管)",
    videoURL: "fWCKCO0WTFA",
    equipment: ["ガラス管", "水差し", "スマホ"],
    costRating: "★☆☆", latex: r"""
        <ul style="line-height:1.6;">
          <li>一端が閉じた管（閉管）では、定常波が形成される際、閉じた端が節、開いた端が腹となる。</li>
          <li>共鳴周波数 $f_n$ は以下の式で表される：<br>
              $$f_n = \frac{(2n - 1)v}{4L} \quad (n = 1, 2, 3, \dots)$$</li>
          <li>現実には、開口端で音波がわずかに外に出て反射される影響があるため、開口端補正 $h$ を加味すると次の式になる：<br>
              $$f_n = \frac{(2n - 1)v}{4(L + h)}$$</li>
          </ul>

        <p>※記号の定義：</p>
        <ul style="line-height:1.6;">
          <li>$f_n$：第 $n$ 番目の共鳴周波数（ヘルツ, Hz）</li>
          <li>$n$：共鳴モード番号（自然数）</li>
          <li>$v$：音速（メートル毎秒, m/s）</li>
          <li>$L$：管の物理的な長さ（メートル, m）</li>
          <li>$h$：開口端補正長（メートル, m）</li>
          <li>$r$：管の内半径（メートル, m）</li>
        </ul>

        <div class="common-box">問題設定</div>
        <p>長さ$L=16\ \mathrm{cm}$のガラス管を使い、閉端側を口で塞いで息を吹きかけるとき、共鳴によって生じる基本振動および高調波の周波数を求めて下さい。</p>
        <p>（1）開口端補正を無視した場合、$n=1,3,5,7$の周波数を計算せよ。</p>
        <p>（2）開口端補正を$h=0.6r$または$h=0.8r$とし、$r=1.1\ \mathrm{cm}$としたとき、同様に周波数を求めて下さい。</p>

        <div class="common-box">理論</div>
        <p>片側が閉じた管（閉管）では、節と腹の関係から<br>
            $$L = \frac{\lambda}{4},\;\frac{3\lambda}{4},\;\frac{5\lambda}{4},\dots$$<br>
            のような定常波が生じ、振動数は<br>
            $$f_n = \frac{(2n-1)v}{4L}$$（$n$: 自然数）となる。</p>
        <p>音速$v=340\ \mathrm{m/s}$、管の長さ$L=0.16\ \mathrm{m}$とする。</p>

        <p>（1）開口端補正なし：</p>
        $$\begin{aligned}
        f_1 &= \frac{340}{4\times 0.16} = 531\ [\mathrm{Hz}] \\
        f_3 &= \frac{3\times 340}{4\times 0.16} = 1594\ [\mathrm{Hz}] \\
        f_5 &= \frac{5\times 340}{4\times 0.16} = 2656\ [\mathrm{Hz}] \\
        f_7 &= \frac{7\times 340}{4\times 0.16} = 3719\ [\mathrm{Hz}]
        \end{aligned}$$

        <p>（2）開口端補正あり：</p>
        <p>$r=1.1\ \mathrm{cm}$のとき：</p>
        <ul>
            <li>$h=0.6r = 6.6\ \mathrm{mm} = 0.0066\ \mathrm{m}$ → $L+h = 0.1666\ \mathrm{m}$</li>
            <li>$h=0.8r = 8.8\ \mathrm{mm} = 0.0088\ \mathrm{m}$ → $L+h = 0.1688\ \mathrm{m}$</li>
        </ul>

        <p>補正ありの周波数：</p>

        <p>$h=0.6r$ のとき：</p>
        $$\begin{aligned}
        f_1 &= \frac{340}{4\times 0.1666} \fallingdotseq 510\ [\mathrm{Hz}] \\
        f_3 &= \frac{3\times 340}{4\times 0.1666} \fallingdotseq 1531\ [\mathrm{Hz}] \\
        f_5 &= \frac{5\times 340}{4\times 0.1666} \fallingdotseq 2551\ [\mathrm{Hz}] \\
        f_7 &= \frac{7\times 340}{4\times 0.1666} \fallingdotseq 3571\ [\mathrm{Hz}]
        \end{aligned}$$

        <p>$h=0.8r$ のとき：</p>
        $$\begin{aligned}
        f_1 &= \frac{340}{4\times 0.1688} \fallingdotseq 503\ [\mathrm{Hz}] \\
        f_3 &= \frac{3\times 340}{4\times 0.1688} \fallingdotseq 1511\ [\mathrm{Hz}] \\
        f_5 &= \frac{5\times 340}{4\times 0.1688} \fallingdotseq 2518\ [\mathrm{Hz}] \\
        f_7 &= \frac{7\times 340}{4\times 0.1688} \fallingdotseq 3525\ [\mathrm{Hz}]
        \end{aligned}$$

        <div class="common-box">答え</div>
        <ul>
            <li>開口端補正なし：$f_1=531\ \mathrm{Hz}$, $f_3=1594\ \mathrm{Hz}$, $f_5=2656\ \mathrm{Hz}$, $f_7=3719\ \mathrm{Hz}$</li>
            <br>
            <li>開口端補正あり（$h=0.6r$）：$f_1=510\ \mathrm{Hz}$, $f_3=1531\ \mathrm{Hz}$, $f_5=2551\ \mathrm{Hz}$, $f_7=3571\ \mathrm{Hz}$</li>
            <br>
            <li>開口端補正あり（$h=0.8r$）：$f_1=503\ \mathrm{Hz}$, $f_3=1511\ \mathrm{Hz}$, $f_5=2518\ \mathrm{Hz}$, $f_7=3525\ \mathrm{Hz}$</li>
            <br>
            <li>実験値：$f_1=500\ \mathrm{Hz}$, $f_3=1520\ \mathrm{Hz}$, $f_5=2530\ \mathrm{Hz}$, $f_7=3500\ \mathrm{Hz}$</li>
        </ul>
    <p>理論値と測定値は、開口端補正を加えることでより正確に予測できる。</p>
<br>
""",
);