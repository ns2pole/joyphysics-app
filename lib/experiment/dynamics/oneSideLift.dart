import '../../model.dart'; // Videoクラス定義が別ならインポート
final oneSideLift = Video(
  isExperiment: true,
  category: 'dynamics', // ← 追加
    iconName: "oneSideLift",
    title: "片側持ち上げ",
    videoURL: "wtxRRKArApU",
    equipment: ["板", "バネ秤"],
    costRating: "★★★", latex: r"""
        <div class="common-box">ポイント</div>
            <p>物体に働く全ての力を $\vec{F_1}, \vec{F_2}, \cdots$</p>
            <p>物体に働く全てのある点まわりのモーメントを $\tau_1, \tau_2, \cdots$ とすると</p>
            <div class="common-box">力とモーメントのつり合い</div>
            <p>$\displaystyle \vec{F_1} + \vec{F_2} + \cdots = \vec{0}$（力のつり合い）</p>
            <p>$\displaystyle \tau_1 + \tau_2 + \cdots = 0$（モーメントのつり合い）</p>
        <div class="common-box">問題設定</div>
        <p>質量$m = 273\mathrm{g}\;)$ の木のブロックを剛体とみなす。片側を持ち上げた時に秤は何グラムを指すか？</p>
        <div class="common-box">理論値計算</div>
        <p>力とモーメントのつり合い条件により、持ち上げに必要な力を求める。</p>
        <div style="text-align:center; margin:1em 0;">
          <img src="assets/dynamicsDetail/oneSideLift.png"
               alt="片側持ち上げの模式図"
               style="max-width:100%; height:auto;" />
        </div>
        <p>ブロックの重心は中央にあるため、一端を持ち上げるときには全体の重さの半分を支える必要がある。</p>
        <p>よって持ち上げに必要な力は、$136.5\mathrm{g}$を持ち上げるのと同等の力。</p>
        <div class="common-box">答え</div>
        <p>バネ秤が指す値は $136.5 \mathrm{g} $</p>
    """
);