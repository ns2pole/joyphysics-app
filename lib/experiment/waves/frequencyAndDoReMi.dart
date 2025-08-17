import './FrequencyMeasureWidget.dart';
import './PianoWidget.dart';

import '../../model.dart'; // Videoクラス定義が別ならインポート

final frequencyAndDoReMi = Video(
  isSmartPhoneOnly: true,
  isNew: true,
  category: 'waves',
  iconName: "music_note",
  title: "周波数とドレミ",
  videoURL: "",
  equipment: ["スマホ"],  // スマホだけで実験
  costRating: "★☆☆",
  latex: """
<div class="common-box">周波数とドレミとは？</div>
<p>音の高さは周波数で決まります。周波数が高いほど音は高く、低いほど音は低く聞こえます。  
ドレミは音階の名前で、それぞれ対応する周波数があります。</p>
<div class="common-box">実験手順</div>
<ol>
  <li>スマホのアプリで鍵盤を開く</li>
  <li>周波数の高さとドレミの音階を耳で確認</li>
</ol>
""",
  experimentWidgets: [
    FrequencyMeasureWidget(),PianoWidget(), // ソ
  ],
);
