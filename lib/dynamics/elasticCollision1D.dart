
import '../model.dart'; // Videoクラス定義が別ならインポート
final  elasticCollision1D = Video(
    category: 'dynamics', // ← 追加
    iconName: "elasticCollision1D",
    title: "弾性衝突(1次元)",
    videoURL: "eZbRztw8ARM",
    equipment: ["10円玉"],
    costRating: "★☆☆", latex: """
        
        <div class="common-box">ポイント</div>
        <p>運動量保存則:\$\\displaystyle m_1v_1 + m_2v_2 = m_1v_1' + m_2v_2'\$</p>
        <p>力学的エネルギー保存則:\$\\displaystyle \\frac12 m_1 v_1^2 + \\frac12 m_2 v_2^2 = \\frac12 m_1 v_1'^2 + \\frac12 m_2 v_2'^2\$</p>
        <p>（\$m_1\$, \$m_2\$: 質量, \$v_1\$, \$v_2\$: 衝突前の速度, \$v_1'\$, \$v_2'\$: 衝突後の速度）</p>
        <div class="common-box">問題設定</div>
        <p>
        質量 \$m\$ の2つの物体 A, B が滑らかな水平面上で正面衝突する。<br>
        衝突前、物体Aの速度は \$v_1\$、物体Bの速度は \$v_2\$ で、衝突は完全弾性衝突（反発係数 \$e=1\$）であるとする。<br>
        このとき、衝突後の両物体の速度 \$v_1'\$, \$v_2'\$ を一般式で求めて下さい。
        </p>

        <div class="common-box">理論計算</div>
        <p>
        反発係数の定義式は
        </p>

        \\[
        e = \\frac{v_2' - v_1'}{v_1 - v_2}.
        \\]

        <p>
        ここで \$e=1\$ を代入すると、
        </p>

        \\[
        v_1 - v_2 = v_2' - v_1'.
        \\quad (1)
        \\]
        <p>
        また、運動量保存より
        </p>
        \\begin{aligned}
        &m v_1 + m v_2 = m v_1' + m v_2'
        \\\\[6pt]
        \\Leftrightarrow
            \\ &v_1 + v_2 = v_1' + v_2'.
        \\quad (2)
        \\end{aligned}

        <p>
        (1) と (2) を連立すると、
        </p>

        \\begin{aligned}
        &\\begin{cases}
        v_1 - v_2 = v_2' - v_1' \\\\
        v_1 + v_2 = v_1' + v_2'
        \\end{cases}
        \\\\[3pt]
        \\Leftrightarrow
            &\\begin{cases}
        v_1' = v_2 \\\\
        v_2' = v_1
        \\end{cases}
        \\end{aligned}

        <div class="common-box">答え</div>
        <p>衝突後の速度は\$v_1' = v_2,\\quad v_2' = v_1\$すなわち、2物体の速度は衝突前後で完全に入れ替わる。</p>
        <p>今回の実験の場合、\$v_2=0\$では、\$v_1' = 0,\\quad v_2' = v_1\$となる。</p>
        """
);