import '../../model.dart'; // Videoクラス定義が別ならインポート
final freeFall = Video(
        isExperiment: true,
        iconName: "freefall",
        category: 'dynamics', // ← 追加
        title: "自由落下",
    videoURL: "wfd5doLXUSg",
    equipment: ["スマホ", "球", "巻尺"],
    costRating: "★☆☆", latex: r"""
        <div class="common-box">ポイント</div>
        <p>$\displaystyle x(t)=\frac12 gt^2$（$x$: 変位, $g$: 重力加速度, $t$: 時間）</p>
        <p>$\displaystyle t=\sqrt{\frac{2x}{g}}$（$t$: 時間, $x$: 変位, $g$: 重力加速度）</p>
                <div class="common-box">問題設定</div>
        <p>高さ $h$ の地点から物体を静かに離す。空気抵抗を無視して、地面に落下するまでの <strong>時間</strong> と、落下した瞬間の <strong>速度</strong> を$h = 0.60$ m および $h = 1.00$ m の2つの場合について求めて下さい。</p>
        
        <div class="common-box">理論値計算</div>
        <p>自由落下では、初速度 $v_0 = 0$ とすると、$t = \sqrt{\frac{2h}{g}}$, &nbsp; $v = \sqrt{2gh}$</p>
        <p>ここで、$g = 9.8 \, [m/s^2]$ とする。</p>
                                            <p></p><p></p>
        <p>(1)高さ $h = 0.60$ m の場合：</p>
        <p>地面までの落下時間：$t = \sqrt{\frac{2 \times 0.60}{9.8}} \fallingdotseq 0.350$ s</p>
        <p>落下時の速度：$v = \sqrt{2 \times 9.8 \times 0.60} \fallingdotseq 3.43$ m/s</p>
        
        <p>(2)高さ $h = 1.00$ m の場合：</p>
        <p>地面までの落下時間：$t = \sqrt{\frac{2 \times 1.00}{9.8}} \fallingdotseq 0.452$ s</p>
        <p>落下時の速度：$v = \sqrt{2 \times 9.8 \times 1.00} \fallingdotseq 4.43$ m/s</p>
        
        <div class="common-box">答え</div>
        <p>・高さ 0.60 m の場合：$t \fallingdotseq 0.350$ s、$v \fallingdotseq 3.43$ m/s</p>
        <p>・高さ 1.00 m の場合：$t \fallingdotseq 0.452$ s、$v \fallingdotseq 4.43$ m/s</p>
        """
);