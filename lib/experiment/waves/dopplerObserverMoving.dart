import 'package:joyphysics/experiment/waves/FrequencyMeasureWidget.dart';
import '../../model.dart';

final dopplerObserverMoving = Video(
  isSmartPhoneOnly: true,
  isNew: true,
  category: 'waves',
  iconName: "doppler2",  // assets に追加済みを想定
  title: "ドップラー効果（観測者が動く時）",
  videoURL: "", // 実験動画のURLがあれば挿入
  equipment: ["スマホ2台"],
  costRating: "★☆☆",
  latex: """
<div class="common-box">ドップラー効果とは？</div>
<p>音源や観測者が動くと、聞こえる音の <b>周波数</b> が変化します。これを <b>ドップラー効果</b> といいます。</p>
<p>例えば、救急車のサイレンが近づく時に高く、遠ざかる時に低く聞こえる現象です。</p>

<div class="common-box">実験：観測者が歩く速度で動いて周波数を観測</div>
<ol>
  <li>スマホ1台に周波数をリアルタイムで表示させる</li>
  <li>スマホ1台に3000Hzの一定周波数を発生させる</li>
  <li>音源の方のスマホを、周波数観測の方のスマホにゆっくり近づけたり遠ざけたりする</li>
  <li>周波数が変化する様子を観察する</li>
</ol>

<div class="common-box">観察ポイント</div>
<ul>
  <li>観測者が音源に近づくと周波数が約 <b>3013 Hz</b> に上昇する</li>
  <li>観測者が音源から遠ざかると周波数が約 <b>2987 Hz</b> に下降する</li>
  <li>観測者が静止すると周波数は元の <b>3000 Hz</b> に戻る</li>
</ul>

<div class="common-box">理論：周波数の変化の計算例</div>
<p>音速を約 \$v = 340 \\text{ m/s}\$、観測者の速度を \$v_{\\text{観測者}} = 1.5 \\text{ m/s}\$、音源の周波数を \$f = 3000 \\text{ Hz}\$ とすると、</p>

<p>近づく場合の周波数は：</p>
\\[
f' = f \\times \\frac{v + v_{\\text{観測者}}}{v} = 3000 \\times \\frac{340 + 1.5}{340} \\approx 3013 \\text{ Hz}
\\]

<p>遠ざかる場合の周波数は：</p>
\\[
f' = f \\times \\frac{v - v_{\\text{観測者}}}{v} = 3000 \\times \\frac{340 - 1.5}{340} \\approx 2987 \\text{ Hz}
\\]

<div class="common-box">注意点</div>
<ul>
  <li>静かな環境で行うと周波数変化を正確に観測しやすい</li>
  <li>スマホマイクの性能によってはノイズが入りやすい</li>
  <li>歩行速度でも十分ドップラー効果の変化が見られる</li>
</ul>
""",
  experimentWidgets: [FrequencyMeasureWidget()],
);
