import 'package:joyphysics/experiment/waves/FrequencyMeasureWidget.dart';
import '../../model.dart';

final dopplerObserverMoving = Video(
  isSmartPhoneOnly: true,
  category: 'waves',
  iconName: "doppler2",  // assets に追加済みを想定
  title: "ドップラー効果(観測者が動く時)",
  titleEn: "Doppler effect (moving observer)",
  videoURL: "", // 実験動画のURLがあれば挿入
  equipment: ["スマホ2台"],
  equipmentEn: ["2 smartphones"],
  costRating: "★☆☆",
  latex: r"""
<div class="common-box">ドップラー効果とは？</div>
<p>音源や観測者が動くと、聞こえる音の <b>周波数</b> が変化します。これを <b>ドップラー効果</b> といいます。</p>
<p>例えば、救急車のサイレンが近づく時に高く、遠ざかる時に低く聞こえる現象です。</p>

<div class="common-box">実験：観測者が歩く速度で動いて周波数を観測</div>
<ol>
  <li>スマホ1台に周波数をリアルタイムで表示させる</li>
  <li>スマホ1台に3000Hzの一定周波数を発生させる</li>
  <li>周波数観測の方のスマホを、音源の方のスマホにゆっくり近づけたり遠ざけたりする</li>
  <li>周波数が変化する様子を観察する</li>
</ol>

<div class="common-box">観察ポイント</div>
<ul>
  <li>観測者が音源に近づくと周波数が約 <b>3013 Hz</b> に上昇する</li>
  <li>観測者が音源から遠ざかると周波数が約 <b>2987 Hz</b> に下降する</li>
  <li>観測者が静止すると周波数は元の <b>3000 Hz</b> に戻る</li>
</ul>

<div class="common-box">理論：周波数の変化の計算例</div>
<p>音速を約 $v = 340 \text{ m/s}$、観測者の速度を $v_{\text{観測者}} = 1.5 \text{ m/s}$、音源の周波数を $f = 3000 \text{ Hz}$ とすると、</p>

<p>近づく場合の周波数は：</p>
$$
f' = f \times \frac{v + v_{\text{観測者}}}{v} = 3000 \times \frac{340 + 1.5}{340} \fallingdotseq 3013 \text{ Hz}
$$

<p>遠ざかる場合の周波数は：</p>
$$
f' = f \times \frac{v - v_{\text{観測者}}}{v} = 3000 \times \frac{340 - 1.5}{340} \fallingdotseq 2987 \text{ Hz}
$$

<div class="common-box">注意点</div>
<ul>
  <li>静かな環境で行うと周波数変化を正確に観測しやすい</li>
  <li>スマホマイクの性能によってはノイズが入りやすい</li>
  <li>歩行速度でも十分ドップラー効果の変化が見られる</li>
</ul>
""",
  latexEn: r"""
<div class="common-box">What is the Doppler effect?</div>
<p>When a sound source or an observer moves, the heard <b>frequency</b> changes. This is the <b>Doppler effect</b>.</p>
<p>For example, an ambulance siren sounds higher as it approaches and lower as it moves away.</p>

<div class="common-box">Experiment: move the observer at walking speed</div>
<ol>
  <li>Display frequency in real time on one smartphone</li>
  <li>Generate a constant 3000 Hz tone on the other smartphone</li>
  <li>Slowly move the measuring phone toward and away from the source phone</li>
  <li>Observe how the frequency changes</li>
</ol>

<div class="common-box">Key observations</div>
<ul>
  <li>When the observer approaches the source, the frequency rises to about <b>3013 Hz</b></li>
  <li>When the observer moves away from the source, the frequency falls to about <b>2987 Hz</b></li>
  <li>When the observer stops, the frequency returns to <b>3000 Hz</b></li>
</ul>

<div class="common-box">Theory: sample frequency-shift calculation</div>
<p>Taking the speed of sound $v = 340\,\mathrm{m/s}$, observer speed $v_{\mathrm{o}} = 1.5\,\mathrm{m/s}$, and source frequency $f = 3000\,\mathrm{Hz}$,</p>

<p>Approaching frequency:</p>
$$
f' = f \times \frac{v + v_{\mathrm{o}}}{v} = 3000 \times \frac{340 + 1.5}{340} \fallingdotseq 3013\,\mathrm{Hz}
$$

<p>Receding frequency:</p>
$$
f' = f \times \frac{v - v_{\mathrm{o}}}{v} = 3000 \times \frac{340 - 1.5}{340} \fallingdotseq 2987\,\mathrm{Hz}
$$

<div class="common-box">Note</div>
<ul>
  <li>A quiet environment makes the frequency shift easier to measure accurately</li>
  <li>Depending on the microphone, noise can be an issue</li>
  <li>Even walking speed shows a clear Doppler shift</li>
</ul>
""",
  experimentWidgets: [FrequencyMeasureWidget(useScaffold: false)],
);
