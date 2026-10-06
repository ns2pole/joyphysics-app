import '../../model.dart'; // Videoクラス定義が別ならインポート
final fook = Video(
  isExperiment: true,
  category: 'dynamics', // ← 追加
    iconName: "fook",
    title: "バネの伸びと弾性力の関係",
    titleEn: "Spring extension and elastic force (Hooke's law)",
    videoURL: "x1iNnA55Jcw",
    equipment: ["ばね", "おもり", "巻尺", "スマホ"],
    equipmentEn: ["spring", "weight", "measuring tape", "smartphone"],
    costRating: "★★★", latex: r"""
    <div class="common-box">ポイント</div>
    <p>$\displaystyle F=-kx$（$F$: 弾性力, $k$: ばね定数, $x$: 変位）</p>
    <p>ばね定数$k$はばねの硬さを表します。</p>
    <div class="common-box">解説</div>
    <p>今回の実験の結果は下記の通り。</p>
    <div style="text-align:center; margin:1em 0;">
      <img src="assets/dynamicsDetail/fook_data.webp"
           alt="データ一覧"
           style="max-width:100%; height:auto;" />
    </div>
    <p>Pythonで最小二乗法での回帰直線を引いて見てみると、y=3.95x+0.09でかなり良くフィッティング出来ている事が分かる。</p>
    <div style="text-align:center; margin:1em 0;">
      <img src="assets/dynamicsDetail/fook_regression.webp"
           alt="回帰直線"
           style="max-width:100%; height:auto;" />
    </div>
    <div class="common-box">ちょっと一言</div>
    <p>実際のバネは伸び始めるのにある程度の力が必要です。</p>
    <p>バネの伸びが0の時の値（今回の場合0.09）を初張力と言います。</p>
    <p>xの係数（今回の場合3.95）がばね定数です。</p>
    """,
    latexEn: r"""
    <div class="common-box">Key points</div>
    <p>$\displaystyle F=-kx$（$F$: elastic force, $k$: spring constant, $x$: displacement）</p>
    <p>The spring constant $k$ measures how stiff the spring is.</p>
    <div class="common-box">Explanation</div>
    <p>The results of this experiment are shown below.</p>
    <div style="text-align:center; margin:1em 0;">
      <img src="assets/dynamicsDetail/fook_data.webp"
           alt="Data table"
           style="max-width:100%; height:auto;" />
    </div>
    <p>Fitting a least-squares regression line in Python gives $y=3.95x+0.09$, which matches the data well.</p>
    <div style="text-align:center; margin:1em 0;">
      <img src="assets/dynamicsDetail/fook_regression.webp"
           alt="Regression line"
           style="max-width:100%; height:auto;" />
    </div>
    <div class="common-box">Note</div>
    <p>A real spring needs a certain force before it begins to stretch.</p>
    <p>The value at zero extension (0.09 in this case) is called the initial tension.</p>
    <p>The coefficient of $x$ (3.95 here) is the spring constant.</p>
    """
);
