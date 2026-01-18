import 'package:joyphysics/experiment/waves/FrequencyMeasureWidget.dart';
import '../../model.dart';

final doppler = Video(
  isSmartPhoneOnly: true,
  category: 'waves',
  iconName: "doppler1",  // assets に追加
  title: "ドップラー効果(音源が動く時)",
  videoURL: "", // 実験動画のURLがある場合はここに
  equipment: ["スマホ2台"],
  costRating: "★☆☆",
  latex: r"""
<div class="common-box">ドップラー効果とは？</div>
<p>音源や観測者が動くと、聞こえる音の <b>周波数</b> が変化します。これを <b>ドップラー効果</b> といいます。</p>
<p>例えば、走って近づいてくる救急車のサイレンは高く、遠ざかると低く聞こえる現象です。</p>

<div class="common-box">実験：歩く速度で3000Hzの音源を動かして観測</div>
<ol>
  <li>スマホ1台に周波数をリアルタイムで表示させる</li>
  <li>スマホ1台に3000Hzの一定周波数を発生させる</li>
  <li>周波数観測の方のスマホを、音源の方のスマホにゆっくり近づけたり遠ざけたりする</li>
  <li>周波数が変化する様子を観察する</li>
</ol>

<div class="common-box">観察ポイント</div>
<ul>
  <li>音源が近づくと周波数が約 <b>3013 Hz</b> に上昇する</li>
  <li>音源が遠ざかると周波数が約 <b>2987 Hz</b> に下降する</li>
  <li>音源が止まると、周波数は元の <b>3000 Hz</b> に戻る</li>
</ul>

<div class="common-box">理論：周波数の変化の計算例</div>
<p>音速を約 $v = 340 \text{ m/s}$、歩行速度を $v_{\text{音源}} = 1.5 \text{ m/s}$、音源の周波数を $f = 3000 \text{ Hz}$ とすると、</p>

<p>近づく場合の周波数は：</p>
$$
f' = f \times \frac{v}{v - v_{\text{音源}}} = 3000 \times \frac{340}{340 - 1.5} \fallingdotseq 3013 \text{ Hz}
$$
<p>遠ざかる場合の周波数は：</p>
$$
f' = f \times \frac{v}{v + v_{\text{音源}}} = 3000 \times \frac{340}{340 + 1.5} \fallingdotseq 2987 \text{ Hz}
$$
<div class="common-box">注意点</div>
<ul>
  <li>静かな環境で行うと正確な周波数変化が観測しやすい</li>
  <li>スマホマイクの性能によっては、高音やノイズに弱い場合がある</li>
  <li>歩行速度程度でも十分にドップラー効果を体感できる変化量（約 ±13Hz）がある</li>
</ul>
""",
  experimentWidgets: [FrequencyMeasureWidget(useScaffold: false)], // ドップラー効果用ウィジェット
);