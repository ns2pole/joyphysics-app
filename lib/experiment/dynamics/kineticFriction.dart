import '../../model.dart'; // Videoクラス定義が別ならインポート
final kineticFriction = Video(
  isExperiment: true,
  category: 'dynamics', // ← 追加
    iconName: "kineticFriction",
    title: "動摩擦力と動摩擦係数",
    titleEn: "Kinetic friction and the coefficient of kinetic friction",
    videoURL: "kAXShjUdJOU",
    videoURLEn: "kAXShjUdJOU",
    equipment: ["糸", "ブロック", "ばねばかり"],
    equipmentEn: ["string", "block", "spring scale"],
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
    <p>（2）具体的に、${m=151[g]}$ ${T=0.3[N]}$を代入して、動摩擦係数 ${\mu_k}$ を求めて下さい。(数値は実験による値を参照した)</p>

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
    """,
    latexEn: r"""
    <div class="common-box">Key points</div>
    <ul>
      <li><strong>Kinetic friction $F_k$</strong>: the friction force while the object is moving, opposite to the direction of motion.</li>
      <li><strong>Coefficient of kinetic friction $\mu_k$</strong>: defined as the ratio of kinetic friction to the normal force.</li>
      <li><strong>By definition,</strong> $\displaystyle \mu_k = \frac{F_k}{N}$.</li>
      <li>On a horizontal surface, $N = mg$, so $\displaystyle \mu_k = \frac{F_k}{mg}$.</li>
      <li>At constant speed, tension $T$ balances kinetic friction $F_k$: $F_k = T$.</li>
    </ul>

    <div class="common-box">Setup</div>
    <p>(1) A string is attached to an object of mass ${m}$ on a table and pulled slowly at constant speed so that the tension $T$ can be measured. Find the coefficient of kinetic friction $\mu_k$.</p>
    <p>(2) Substitute the measured values ${m=151[g]}$ and ${T=0.3[N]}$ to find ${\mu_k}$.</p>

    <div class="common-box">Theory</div>
    <p>When the object moves at constant speed, the acceleration $a$ is $0$, so the net force from $ma = F$ is $F = 0$.</p>
    <p>Thus tension $T$ and kinetic friction $F_k$ are in balance: $F_k = T$</p>
    <p>Kinetic friction is the product of the normal force $N$ and the coefficient of kinetic friction $\mu_k$: $F_k = \mu_k N$</p>
    <p>On a horizontal surface, $N = mg$, so $F_k = \mu_k mg$</p>
    <p>Therefore $\displaystyle \mu_k = \frac{F_k}{mg} = \frac{T}{mg}$:</p>
    <p>Substituting $m = 151[g] = 0.151[kg]$, $T = 0.3[N]$ gives $\displaystyle \mu_k =\frac{0.3}{0.151 \cdot 9.8} \fallingdotseq 0.20$</p>
    <div class="common-box">Answer</div>
    <p>The coefficient of kinetic friction $\mu_k$ is $\displaystyle \mu_k = \frac{T}{mg}$. Every quantity on the right-hand side can be measured, so $\mu_k$ can be found experimentally.</p>
    <p>With $m=151[g]$ and $T=0.3[N]$, $\mu_k \fallingdotseq 0.20$.</p>
    """
);