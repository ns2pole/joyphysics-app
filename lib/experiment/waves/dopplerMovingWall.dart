import 'package:joyphysics/experiment/waves/FrequencyMeasureWidget.dart';
import 'package:joyphysics/experiment/waves/ToneGeneratorWidget.dart';
import '../../model.dart';

final dopplerMovingWall = Video(
  isExperiment: true,
  isNew: true,
  warnsHighPitchSound: true,
  category: 'waves',
  iconName: "doppler1",
  title: "動く物体による反射と速度測定",
  videoURL: "C6Mq7apCUcU",
  equipment: ["スマホ2台", "板（ノートや下敷きでもいけると思います）"],
  costRating: "★☆☆",
  latex: r"""
<div class="common-box">壁が動くときのドップラー効果</div>
<p>固定した音源から周波数 $f$ の音を出し、壁で反射して戻ってくる音の周波数 $f_{\mathrm{ref}}$ を（音源位置で）観測します。音速は $v$ とします。</p>
<p>反射体が動いていると、反射波には<b>2回のドップラー効果</b>がかかります。下の動画は、その実験の様子です。</p>

<div class="common-box">実験によるデータ</div>
<p>設定と動画の実験で得られたデータは次の通りです。</p>
<ul>
  <li>音源周波数：$f_0 = 11074\,\mathrm{Hz}$</li>
  <li>音速：$v = 340\,\mathrm{m/s}$（標準値）</li>
</ul>
<table style="border-collapse: collapse; width: 100%; margin: 12px auto; border: 1px solid #333;">
  <thead>
    <tr>
      <th style="border: 1px solid #333; padding: 6px 8px; background-color: #f2f2f2;">回数</th>
      <th style="border: 1px solid #333; padding: 6px 8px; background-color: #f2f2f2;">種類</th>
      <th style="border: 1px solid #333; padding: 6px 8px; background-color: #f2f2f2;">反射波の周波数 [Hz]</th>
      <th style="border: 1px solid #333; padding: 6px 8px; background-color: #f2f2f2;">音源周波数との差 [Hz]</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="border: 1px solid #333; padding: 6px 8px;">1回目</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">最小値</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">11050</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">$-24$</td>
    </tr>
    <tr>
      <td style="border: 1px solid #333; padding: 6px 8px;">1回目</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">最大値</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">11094</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">$+20$</td>
    </tr>
    <tr>
      <td style="border: 1px solid #333; padding: 6px 8px;">2回目</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">最小値</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">11058</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">$-16$</td>
    </tr>
    <tr>
      <td style="border: 1px solid #333; padding: 6px 8px;">2回目</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">最大値</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">11090</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">$+16$</td>
    </tr>
  </tbody>
</table>

<div class="common-box">壁の速さの理論式</div>
<p><b>(i) 壁が音源に近づくとき</b></p>
<p>壁による反射で観測される周波数は $f_{\mathrm{ref}} = f\dfrac{v+u}{v-u}$ です。よって壁の速さ $u$ は</p>
$$
u = v\dfrac{f_{\mathrm{ref}}-f}{f_{\mathrm{ref}}+f}
$$
<p><b>(ii) 壁が音源から遠ざかるとき</b></p>
<p>壁による反射で観測される周波数は $f_{\mathrm{ref}} = f\dfrac{v-u}{v+u}$ です。よって壁の速さ $u$ は</p>
$$
u = v\dfrac{f-f_{\mathrm{ref}}}{f_{\mathrm{ref}}+f}
$$
<p><b>(iii) 壁の速さのまとめた表式</b></p>
<p>近づく場合も遠ざかる場合も、壁の速さは次のように書けます。</p>
$$
u = v\left|\dfrac{f-f_{\mathrm{ref}}}{f+f_{\mathrm{ref}}}\right|
$$

<div class="common-box">数値計算</div>
<p>以後は $v=340\,\mathrm{m/s}$、$f=11074\,\mathrm{Hz}$ とします。速さは $u$（$u\ge 0$）として求めます。</p>
<p>遠ざかるときの式 $u = v\left|\dfrac{f-f_{\mathrm{ref}}}{f_{\mathrm{ref}}+f}\right|$ を用いた計算結果は次の通りです。</p>

<p><b>(1) 1回目：遠ざかり</b></p>
$$\begin{aligned}
u_{1,\text{遠}}
&= 340\dfrac{11074-11050}{11050+11074} \\
&= 340\dfrac{24}{22124} \\
&\fallingdotseq 0.3688\,\mathrm{m/s}
\end{aligned}$$

<p><b>(2) 1回目：近づき</b></p>
$$\begin{aligned}
u_{1,\text{近}}
&= 340\dfrac{11094-11074}{11094+11074} \\
&= 340\dfrac{20}{22168} \\
&\fallingdotseq 0.3067\,\mathrm{m/s}
\end{aligned}$$

<p><b>(3) 2回目：遠ざかり</b></p>
$$\begin{aligned}
u_{2,\text{遠}}
&= 340\dfrac{11074-11058}{11058+11074} \\
&= 340\dfrac{16}{22132} \\
&\fallingdotseq 0.2458\,\mathrm{m/s}
\end{aligned}$$

<p><b>(4) 2回目：近づき</b></p>
$$\begin{aligned}
u_{2,\text{近}}
&= 340\dfrac{11090-11074}{11090+11074} \\
&= 340\dfrac{16}{22164} \\
&\fallingdotseq 0.2454\,\mathrm{m/s}
\end{aligned}$$

<p><b>(5) 結果のまとめ</b></p>
<table style="border-collapse: collapse; width: 100%; margin: 12px auto; border: 1px solid #333;">
  <thead>
    <tr>
      <th style="border: 1px solid #333; padding: 6px 8px; background-color: #f2f2f2;">回数</th>
      <th style="border: 1px solid #333; padding: 6px 8px; background-color: #f2f2f2;">種類</th>
      <th style="border: 1px solid #333; padding: 6px 8px; background-color: #f2f2f2;">反射波の周波数 [Hz]</th>
      <th style="border: 1px solid #333; padding: 6px 8px; background-color: #f2f2f2;">音源周波数との差 [Hz]</th>
      <th style="border: 1px solid #333; padding: 6px 8px; background-color: #f2f2f2;">壁の速さ [m/s]</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="border: 1px solid #333; padding: 6px 8px;">1回目</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">最小値</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">11050</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">$-24$</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">$0.3688$</td>
    </tr>
    <tr>
      <td style="border: 1px solid #333; padding: 6px 8px;">1回目</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">最大値</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">11094</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">$+20$</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">$0.3067$</td>
    </tr>
    <tr>
      <td style="border: 1px solid #333; padding: 6px 8px;">2回目</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">最小値</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">11058</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">$-16$</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">$0.2458$</td>
    </tr>
    <tr>
      <td style="border: 1px solid #333; padding: 6px 8px;">2回目</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">最大値</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">11090</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">$+16$</td>
      <td style="border: 1px solid #333; padding: 6px 8px;">$0.2454$</td>
    </tr>
  </tbody>
</table>
<p>※音源周波数は $f_0 = 11074\,\mathrm{Hz}$</p>

<div class="common-box">壁が動くときのドップラー効果の理論式（導出）</div>
<p><b>(1) 壁が受け取る周波数（観測者が動くドップラー）</b></p>
<p>壁が音源に近づくとき、壁が受け取る周波数 $f_1$ は</p>
$$
f_1 = f\dfrac{v+u}{v}
$$
<p>です（観測者が動く場合の式）。</p>

<p><b>(2) 反射後の周波数（壁を「動く音源」とみなす）</b></p>
<p>壁は音源に近づいているので、壁は周波数 $f_1 = f\dfrac{v+u}{v}$ の音を聞きます。さらにこの壁を「周波数 $f_1$ の音源が速さ $u$ で動く音源」と考えると、反射して音源位置へ戻る周波数は</p>
$$
f_{\mathrm{ref}} = f_1\dfrac{v}{v-u}\quad\cdots(1)
$$
<p>となります（音源が動く場合の式）。</p>
<p>式(1)に $f_1 = f\dfrac{v+u}{v}$ を代入すれば</p>
$$
f_{\mathrm{ref}} = f\dfrac{v+u}{v-u}
$$
<p>を得ます。</p>
<p>※壁が遠ざかるときは $u\to -u$ として</p>
$$
f_1 = f\dfrac{v-u}{v},\qquad f_{\mathrm{ref}} = f\dfrac{v-u}{v+u}
$$
<p>を得ます。</p>

<div class="common-box">実験の仕方</div>
<ol>
  <li>スマホ1台で下の音源を $11074\,\mathrm{Hz}$ 付近で鳴らす（音源は固定）</li>
  <li>もう1台のスマホで、音源のそばから反射音の周波数を測定する</li>
  <li>板（ノートや下敷きでもいけると思います）を音源に近づけたり遠ざけたりして、$f_{\mathrm{ref}}$ の最大・最小を読む</li>
  <li>上の式から壁の速さ $u$ を求める</li>
</ol>
<p>周波数測定は「センサーを使う」の<b>うなり</b>と同じ機能です。下の測定ウィジェットでも観測できます。</p>
""",
  experimentWidgets: [
    FrequencyMeasureWidget(height: 180, useScaffold: false),
    ToneGeneratorWidget(
      initialFreq: 11074,
      minFreq: 8000,
      maxFreq: 13000,
      height: 180,
      warnHighPitchSound: true,
    ),
  ],
);
