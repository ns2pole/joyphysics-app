import 'package:joyphysics/experiment/waves/FrequencyMeasureWidget.dart';
import '../../model.dart';

final doppler = Video(
  isSmartPhoneOnly: true,
  category: 'waves',
  iconName: "doppler1",  // assets に追加
  title: "ドップラー効果(音源が動く時)",
  titleEn: "Doppler effect (moving source)",
  videoURL: "", // 実験動画のURLがある場合はここに
  equipment: ["スマホ2台"],
  equipmentEn: ["2 smartphones"],
  costRating: "★☆☆",
  latex: r"""
<div class="common-box">ドップラー効果とは？</div>
<p>音源や観測者が動くと、聞こえる音の <b>周波数</b> が変化します。これを <b>ドップラー効果</b> といいます。</p>
<p>例えば、走って近づいてくる救急車のサイレンは高く、遠ざかると低く聞こえる現象です。</p>

<div class="common-box">実験：歩く速度で3000Hzの音源を動かして観測</div>
<ol>
  <li>スマホ1台に周波数をリアルタイムで表示させる</li>
  <li>スマホ1台に3000Hzの一定周波数を発生させる</li>
  <li>音源の方のスマホを、周波数観測の方のスマホにゆっくり近づけたり遠ざけたりする</li>
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
  latexEn: r"""
<div class="common-box">What is the Doppler effect?</div>
<p>When a sound source or an observer moves, the heard <b>frequency</b> changes. This is the <b>Doppler effect</b>.</p>
<p>For example, an ambulance siren sounds higher as it approaches and lower as it moves away.</p>

<div class="common-box">Experiment: move a 3000 Hz source at walking speed</div>
<ol>
  <li>Display frequency in real time on one smartphone</li>
  <li>Generate a constant 3000 Hz tone on the other smartphone</li>
  <li>Slowly move the source phone toward and away from the measuring phone</li>
  <li>Observe how the frequency changes</li>
</ol>

<div class="common-box">Key observations</div>
<ul>
  <li>When the source approaches, the frequency rises to about <b>3013 Hz</b></li>
  <li>When the source recedes, the frequency falls to about <b>2987 Hz</b></li>
  <li>When the source stops, the frequency returns to <b>3000 Hz</b></li>
</ul>

<div class="common-box">Theory: sample frequency-shift calculation</div>
<p>Taking the speed of sound $v = 340\,\mathrm{m/s}$, walking speed $v_{\mathrm{s}} = 1.5\,\mathrm{m/s}$, and source frequency $f = 3000\,\mathrm{Hz}$,</p>

<p>Approaching frequency:</p>
$$
f' = f \times \frac{v}{v - v_{\mathrm{s}}} = 3000 \times \frac{340}{340 - 1.5} \fallingdotseq 3013\,\mathrm{Hz}
$$
<p>Receding frequency:</p>
$$
f' = f \times \frac{v}{v + v_{\mathrm{s}}} = 3000 \times \frac{340}{340 + 1.5} \fallingdotseq 2987\,\mathrm{Hz}
$$
<div class="common-box">Note</div>
<ul>
  <li>A quiet environment makes the frequency shift easier to measure accurately</li>
  <li>Depending on the microphone, high tones or noise can be hard to handle</li>
  <li>Even walking speed gives a noticeable Doppler shift (about $\pm 13\,\mathrm{Hz}$)</li>
</ul>
""",
  experimentWidgets: [FrequencyMeasureWidget(useScaffold: false)], // ドップラー効果用ウィジェット
);