import './BarometerExperimentWidget.dart';
import '../model.dart'; // Videoクラスが定義されている場合

final barometer = Video(
  category: 'dynamics',
  iconName: "barometer",
  title: "大気圧の測定",
  videoURL: "",
  equipment: ["スマホ（気圧センサー搭載）"],
  costRating: "★☆☆",
  latex: """
<div class="common-box">大気圧とは？</div>
<p>大気圧は、空気の重さによって生じる圧力で、標高や天気によって変化します。単位としては hPa（ヘクトパスカル）がよく使われます。</p>

<div class="common-box">スマホで大気圧を測定</div>
<ul>
  <li>スマホに内蔵されている <b>気圧センサー</b> を使うことで、周囲の大気圧をリアルタイムで測定できます。</li>
  <li>このデータから、標高や天候の変化を読み取ることも可能です。</li>
</ul>

<div class="common-box">実験：エレベーターで標高差を測る</div>
<ol>
  <li>気圧センサーアプリを起動し、大気圧を記録（例：1階）</li>
  <li>エレベーターで上の階に移動し、再度気圧を記録（例：10階）</li>
  <li>気圧の差からおおよその高度差を計算：
    <p>\$\$
    \\Delta h \\approx \\frac{\\Delta P}{1.2} \\quad (\\mathrm{m})
    \$\$</p>
    ※1 hPa ≒ 8.3 m の高度差として計算してもよい
  </li>
</ol>

<div class="common-box">注意点</div>
<ul>
  <li>すべてのスマホに気圧センサーが搭載されているわけではありません。</li>
  <li>気圧データは周囲の気温や気流の影響を受けるため、安定した状態で測定してください。</li>
</ul>
""",
  experimentWidget: BarometerExperimentWidget(),
);
