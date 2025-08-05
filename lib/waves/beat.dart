import './BeatExperimentWidget.dart';
import '../model.dart'; // Videoクラス定義が別ならインポート

final beat = Video(
  category: 'waves',
  iconName: "beat",
  title: "うなり",
  videoURL: "",
  equipment: ["スマホ"],  // スマホだけで実験
  costRating: "★☆☆",
  latex: """
<div class="common-box">うなりとは？</div>
<p>周波数がわずかに異なる 2 つの音波が重なり合うと、干渉によって音の強弱が周期的に変化します。これを <b>うなり</b>（ビート）と呼びます。</p>
<p>うなりの周波数は次の式で表されます：</p>
<p>\$\$
f_{\\text{うなり}} = \\bigl| f_1 - f_2 \\bigr|
\$\$</p>

<div class="common-box">実験１：350 Hz vs 351 Hz</div>
<ul>
  <li>設定周波数：\$f_1 = 350\\,\!\\mathrm{Hz}\$, \$f_2 = 351\\,\\mathrm{Hz}\$</li>
  <li>うなり周波数：\$|351 - 350| = 1\\,\\mathrm{Hz}\$</li>
  <li>スマホアプリで 350 Hz と 351 Hz のトーンを同時再生し、1 秒間に 1 回のゆっくりとした強弱変化を体感する。</li>
</ul>

<div class="common-box">実験２：350 Hz vs 354 Hz</div>
<ul>
  <li>設定周波数：\$f_1 = 350\\,\!\\mathrm{Hz}\$, \$f_2 = 354\\,\\mathrm{Hz}\$</li>
  <li>うなり周波数：\$|354 - 350| = 4\\,\\mathrm{Hz}\$</li>
  <li>スマホアプリで 350 Hz と 354 Hz のトーンを同時再生し、1 秒間に 4 回の速い強弱変化を体感する。</li>
</ul>

<div class="common-box">実験手順</div>
<ol>
  <li>スマホの音声生成アプリでそれぞれの周波数トーンを準備</li>
  <li>同時再生モードをオンにして 2 つのトーンを鳴らす</li>
  <li>イヤホンまたはスピーカーでうなりの速さを耳で聴く</li>
  <li>周波数差を変えて聴き比べることで、うなり周波数と聞こえ方の関係を学ぶ</li>
</ol>
""",
  experimentWidget: BeatExperimentWidget(),
);