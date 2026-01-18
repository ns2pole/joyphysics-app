import '../../model.dart'; // Videoクラス定義が別ならインポート
final staticFriction = Video(
  isExperiment: true,
  category: 'dynamics', // ← 追加
    iconName: "staticFriction",
    title: "静止摩擦力と静止摩擦係数",
    videoURL: "nGueclGZVtc",
    equipment: ["糸", "ブロック", "ばねばかり"],
    costRating: "★★★",
    latex: r"""
    <div class="common-box">ポイント</div>
    <ul>
      <li><strong>最大静止摩擦力 $F_s$：</strong>：物体が動き出す直前に働く静止摩擦力の最大値。</li>
      <li><strong>静止摩擦係数 ${\mu_s}$</strong>：最大静止摩擦力と垂直抗力の比で定義される無次元量。</li>
      <li><strong>定義より、</strong>$ \mu_s = \frac{F_s}{N}$ が成り立つ。</li>
    </ul>
    <div class="common-box">問題設定</div>
    <p>（1）机の上にある質量 ${m}$ の物体に糸を取り付け徐々に引く力を増やしていき、物体が動き始める直前の最大の力 ${F_{s}}$ が測定できた。このときの静止摩擦係数 ${\mu_s}$ を求めて下さい。</p>
    <p>（2）具体的に、${m=651[g]}$ ${F_{s}=2.5[N]}$を代入して、静止摩擦係数 ${\mu_s}$ を求めて下さい。(数値は実験による値を参照した)</p>
    <div class="common-box">理論</div>
    <p>定義より、静止摩擦力の最大値は垂直抗力 ${N}$ と静止摩擦係数 ${\mu_s}$ の積で表される：$F_{s} = \mu_s N$</p>
    <p>水平面上での垂直抗力は物体の重力に等しいため：$N = mg$</p>
    <p>よって最大静止摩擦力は：$F_{s} = \mu_s mg$</p>
    <p>この式を変形して、静止摩擦係数は$\mu_s = \frac{F_{s}}{mg}$で求められる</p>
    具体的に、
    $m=651[g]=0.651[kg]$,$F_{s}=2.5[N]$を代入すると、$\displaystyle \mu_{s}=\frac{2.5}{0.651 \cdot 9.8} \fallingdotseq 0.39$
    <div class="common-box">答え</div>
    <p>静止摩擦係数 ${\mu_s}$ は$\ \displaystyle \mu_s = \frac{F_{s}}{mg}$で表される。右辺は全て測定可能なので、${\mu_s}$ を実験により求めることができる。
    $m=651[g]$,$F_{s}=2.5[N]$の数値を代入して計算すると、$\mu_s \fallingdotseq 0.39$</p>
    
    """
);