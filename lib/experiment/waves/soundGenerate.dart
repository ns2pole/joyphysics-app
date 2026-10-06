//「ツカッテ」 https://tsukatte.com/megaphone/

import './BeatExperimentWidget.dart';
import './FrequencyMeasureWidget.dart';
import './ToneGeneratorWidget.dart';

import '../../model.dart'; // Videoクラス定義が別ならインポート

final soundGenerate = Video(
  isSmartPhoneOnly: true,
  isNew: false,
  category: 'waves',
  iconName: "megaphone",
  title: "スマホによる音波の生成",
  titleEn: "Generating sound waves with a smartphone",
  videoURL: "",
  equipment: [],
  costRating: "★☆☆",
  latex: r"""
<div class="common-box">スマホによる音波の生成</div>
<p>
スマホから音を出力し、その周波数を調整することで音の高さを自由に変えることができます。<br>
この機能を利用すると、以下のような物理現象を実際に体験できます。
</p>

<ul>
  <li><b>音の高さ：</b> 周波数 $f$ を変化させると、音の高低が変わる。</li>
  <li><b>共鳴：</b> 楽器や容器などに音を当てると、特定の周波数で大きく響く現象。</li>
  <li><b>干渉（うなり）：</b> 周波数のわずかに異なる2つの音を同時に出すと、音が強弱を繰り返すうなりが聞こえる。</li>
  <li><b>ドップラー効果：</b> 音源（スマホ）や観測者を動かすと、聞こえる音の高さが変化する現象。</li>
</ul>
<p>
スマホだけでこれらの現象を手軽に観察できます。ぜひ試してみて下さい。
</p>
""",
  latexEn: r"""
<div class="common-box">Generating sound waves with a smartphone</div>
<p>
By playing sound from a smartphone and adjusting its frequency, you can freely change the pitch.<br>
With this, you can experience physical phenomena such as the following.
</p>

<ul>
  <li><b>Pitch:</b> Changing the frequency $f$ changes how high or low the sound is.</li>
  <li><b>Resonance:</b> Sound directed at an instrument or container rings loudly at particular frequencies.</li>
  <li><b>Interference (beats):</b> Two tones with slightly different frequencies played together produce beats that repeatedly grow louder and softer.</li>
  <li><b>Doppler effect:</b> Moving the source (smartphone) or the observer changes the heard pitch.</li>
</ul>
<p>
You can observe these phenomena casually with only a smartphone. Give them a try.
</p>
""",
  experimentWidgets: [ToneGeneratorWidget(initialFreq: 340, height: 180)],
);