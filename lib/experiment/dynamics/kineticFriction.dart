import '../../model.dart'; // Videoクラス定義が別ならインポート
final kineticFriction = Video(
  isExperiment: true,
  category: 'dynamics', // ← 追加
    iconName: "kineticFriction",
    title: "動摩擦力と動摩擦係数",
    videoURL: "kAXShjUdJOU",
    equipment: ["糸", "ブロック", "ばねばかり"],
    costRating: "★★★",
    latex: r"""
    <div class="common-box">ポイント</div>
    <ul>
      <li><strong>動摩擦力 $F_k$</strong>：物体が動いているときに働く摩擦力で、進行方向と逆向き。</li>
      <li><strong>動摩擦係数 $\mu_k$</strong>：動摩擦力と垂直抗力の比で定義される。</li>
      <li><strong>定義より、</strong>$ \mu_k = \frac{F_k}{N}$ が成り立つ。</li>
      <li>水平面上では $N = mg$ より、$\displaystyle \mu_k = \frac{F_k}{mg}$ が導かれる。</li>
      <li>等速ならば張力 $T$ と動摩擦力 $F_k$ はつり合う：$F_k = T$。</li>
    </ul>

    <div class="common-box">問題設定</div>
    <p>（１）机の上にある質量 ${m}$ の物体に糸を取り付けゆっくりと等速で動かして張力$T$ を測定できた。この時、動摩擦係数 $\mu_k$ を求めて下さい。
    <p>（2）具体的に、${m=151[g]}$ ${T=0.3[N]}$を代入して、静止摩擦係数 ${\mu_s}$ を求めて下さい。(数値は実験による値を参照した)</p>

    <div class="common-box">理論</div>
    <p>物体が等速で動いているとき、加速度 $a$ は $0$ と見なせる。したがって、運動方程式 $ma = F$ より合力 $F = 0$ である。</p>
    <p>つまり、張力 $T$ と動摩擦力 $F_k$ はつり合っている：$F_k = T$</p>
    <p>動摩擦力$F_k$は垂直抗力 $N$ と動摩擦係数 $\mu_k$ の積で表される：$F_k = \mu_k N$</p>
    <p>水平面上では $N = mg$ より：$F_k = \mu_k mg$</p>
    <p>よって、動摩擦係数は$\displaystyle \mu_k = \frac{F_k}{mg} = \frac{T}{mg}$で求められる：</p>
    <p>具体的に、$m = 151[g] = 0.151[kg]$, $T = 0.3[N]$ を代入すると：$\mu_k =\displaystyle \frac{0.3}{0.151 \cdot 9.8} \fallingdotseq 0.20$</p>
    <div class="common-box">答え</div>
    <p>動摩擦係数 $\mu_k$ は$\ \mu_k = \frac{T}{mg}$で表される。右辺はすべて測定可能なので、$\mu_k$ を実験により求めることができる。</p>
    <p>$m=151[g]$, $T=0.3[N]$ の数値を代入して計算すると、$\mu_k \fallingdotseq 0.20$</p>
    """
);