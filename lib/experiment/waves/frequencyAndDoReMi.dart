import './FrequencyMeasureWidget.dart';
import './PianoWidget.dart';
import '../../model.dart'; // Videoクラス定義が別ならインポート

final frequencyAndDoReMi = Video(
  isSmartPhoneOnly: true,
  isNew: false,
  category: 'waves',
  iconName: "doremi",
  title: "ドレミの周波数測定",
  titleEn: "Measuring Do-Re-Mi frequencies",
  videoURL: "",
  equipment: ["スマホ"],  // スマホだけで実験
  equipmentEn: ["smartphone"],
  costRating: "★☆☆",
  latex: r"""
<div class="common-box">周波数とドレミとは？</div>
<p>音の高さは周波数で決まります。周波数が高いほど音は高く、低いほど音は低く聞こえます。  
ドレミは音階の名前で、それぞれ対応する周波数があります。</p>
<div class="common-box">ドレミの周波数（C4〜C5）</div>
<br>
<table style="border-collapse: collapse; width: 50%; margin: 20px auto; border: 2px solid #333;">
    <thead>
        <tr>
            <th style="border: 1px solid #333; padding: 8px 12px; background-color: #f2f2f2;">音名</th>
            <th style="border: 1px solid #333; padding: 8px 12px; background-color: #f2f2f2;">周波数 (Hz)</th>
        </tr>
    </thead>
    <tbody>
        <tr><td style="border: 1px solid #333; padding: 8px 12px;">ド (C4)</td><td style="border: 1px solid #333; padding: 8px 12px;">261.63</td></tr>
        <tr><td style="border: 1px solid #333; padding: 8px 12px;">レ (D4)</td><td style="border: 1px solid #333; padding: 8px 12px;">293.66</td></tr>
        <tr><td style="border: 1px solid #333; padding: 8px 12px;">ミ (E4)</td><td style="border: 1px solid #333; padding: 8px 12px;">329.63</td></tr>
        <tr><td style="border: 1px solid #333; padding: 8px 12px;">ファ (F4)</td><td style="border: 1px solid #333; padding: 8px 12px;">349.23</td></tr>
        <tr><td style="border: 1px solid #333; padding: 8px 12px;">ソ (G4)</td><td style="border: 1px solid #333; padding: 8px 12px;">392.00</td></tr>
        <tr><td style="border: 1px solid #333; padding: 8px 12px;">ラ (A4)</td><td style="border: 1px solid #333; padding: 8px 12px;">440.00</td></tr>
        <tr><td style="border: 1px solid #333; padding: 8px 12px;">シ (B4)</td><td style="border: 1px solid #333; padding: 8px 12px;">493.88</td></tr>
        <tr><td style="border: 1px solid #333; padding: 8px 12px;">ド (C5)</td><td style="border: 1px solid #333; padding: 8px 12px;">523.25</td></tr>
    </tbody>
</table>

<p><strong>ポイント：</strong> 
C5（1オクターブ上のド）の周波数は C4 のちょうど2倍です。  
オクターブが1つ上がるごとに周波数は倍になります。</p>

<div class="common-box">数学的にみる和音と調和</div>
<p>音の組み合わせが心地よく聞こえる理由は、周波数比が単純な整数比になると音が調和して聞こえるためです。</p>
<ul>
  <li>完全5度：周波数比 3:2（例: ドとソ）</li>
  <li>完全4度：周波数比 4:3（例: ドとファ）</li>
  <li>オクターブ：周波数比 2:1（例: C4 と C5）</li>
</ul>
<p>このような単純な比率の音の組み合わせは「和音」と呼ばれ、音楽的に安定した響きになります。</p>

<div class="common-box">実験手順</div>
<ol>
  <li>スマホのアプリで鍵盤を開く</li>
  <li>周波数の高さとドレミの音階を耳で確認</li>
  <li>和音（例えばドとソ）を同時に鳴らして、調和して聞こえるか確認</li>
</ol>
""",
  latexEn: r"""
<div class="common-box">What are frequency and Do-Re-Mi?</div>
<p>Pitch is determined by frequency. Higher frequency sounds higher; lower frequency sounds lower.
Do-Re-Mi are solfège names for scale degrees, each with a corresponding frequency.</p>
<div class="common-box">Do-Re-Mi frequencies (C4–C5)</div>
<br>
<table style="border-collapse: collapse; width: 50%; margin: 20px auto; border: 2px solid #333;">
    <thead>
        <tr>
            <th style="border: 1px solid #333; padding: 8px 12px; background-color: #f2f2f2;">Note</th>
            <th style="border: 1px solid #333; padding: 8px 12px; background-color: #f2f2f2;">Frequency (Hz)</th>
        </tr>
    </thead>
    <tbody>
        <tr><td style="border: 1px solid #333; padding: 8px 12px;">Do (C4)</td><td style="border: 1px solid #333; padding: 8px 12px;">261.63</td></tr>
        <tr><td style="border: 1px solid #333; padding: 8px 12px;">Re (D4)</td><td style="border: 1px solid #333; padding: 8px 12px;">293.66</td></tr>
        <tr><td style="border: 1px solid #333; padding: 8px 12px;">Mi (E4)</td><td style="border: 1px solid #333; padding: 8px 12px;">329.63</td></tr>
        <tr><td style="border: 1px solid #333; padding: 8px 12px;">Fa (F4)</td><td style="border: 1px solid #333; padding: 8px 12px;">349.23</td></tr>
        <tr><td style="border: 1px solid #333; padding: 8px 12px;">Sol (G4)</td><td style="border: 1px solid #333; padding: 8px 12px;">392.00</td></tr>
        <tr><td style="border: 1px solid #333; padding: 8px 12px;">La (A4)</td><td style="border: 1px solid #333; padding: 8px 12px;">440.00</td></tr>
        <tr><td style="border: 1px solid #333; padding: 8px 12px;">Si (B4)</td><td style="border: 1px solid #333; padding: 8px 12px;">493.88</td></tr>
        <tr><td style="border: 1px solid #333; padding: 8px 12px;">Do (C5)</td><td style="border: 1px solid #333; padding: 8px 12px;">523.25</td></tr>
    </tbody>
</table>

<p><strong>Key point:</strong>
The frequency of C5 (Do one octave up) is exactly twice that of C4.
Each octave up doubles the frequency.</p>

<div class="common-box">Chords and harmony, mathematically</div>
<p>Combinations of tones sound pleasant when their frequency ratios are simple integers, so the sounds blend harmoniously.</p>
<ul>
  <li>Perfect fifth: frequency ratio 3:2 (e.g. Do and Sol)</li>
  <li>Perfect fourth: frequency ratio 4:3 (e.g. Do and Fa)</li>
  <li>Octave: frequency ratio 2:1 (e.g. C4 and C5)</li>
</ul>
<p>Such simple-ratio combinations are called chords and sound musically stable.</p>

<div class="common-box">Procedure</div>
<ol>
  <li>Open the keyboard in the smartphone app</li>
  <li>Listen and check how frequency relates to the Do-Re-Mi scale</li>
  <li>Play a chord (e.g. Do and Sol) together and check that it sounds harmonious</li>
</ol>
""",
  experimentWidgets: [
    FrequencyMeasureWidget(useScaffold: false),
    PianoWidget(),
  ],
);
