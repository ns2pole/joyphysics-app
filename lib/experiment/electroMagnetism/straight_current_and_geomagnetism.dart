import '../../model.dart'; // Videoクラス定義が別ならインポート

final straight_current_and_geomagnetism = Video(
  isExperiment: true,
  category: 'electroMagnetism',
  iconName: "",
  title: "直線電流と地磁気の重ね合わせ：方位磁石の向き（arctan回避・矢ベクトル）",
  videoURL: "",
  equipment: [
    "直線導線（電流 1 A）",
    "方位磁石（導線からの距離 1 cm）",
    "定規",
    "直流電源（1 A）"
  ],
  costRating: "★☆☆",
  latex: r"""
<div class="common-box">ポイント</div>
<p>方位磁石は<b>水平面内の合成磁場</b> \(\overrightarrow{B}_{\text{tot}}\) の方向を指す。長い直線電流の磁場は
\[
B_{\text{wire}}=\frac{\mu_0 I}{2\pi r}
\]
で、向きは右ねじ（接線）。</p>

<div class="common-box">問題設定</div>
<p>電流 \(I=1\,\mathrm{A}\)。距離 \(r=1\,\mathrm{cm}=0.01\,\mathrm{m}\)。地磁気の<b>水平成分</b>を
\(\overrightarrow{B}_{\text{E}}=(0,\ 3.0\times10^{-5})\ \mathrm{T}\)（北 \(+\hat{y}\)）とする。導線は \(z\) 軸、方位磁石は導線の<b>北側</b>に配置。</p>

<div class="common-box">理論値計算</div>
<p>導線磁場の大きさ：
\[
B_{\text{wire}}=\frac{4\pi\times10^{-7}\times 1}{2\pi\times 0.01}
\]
\[
B_{\text{wire}}=2.0\times10^{-5}\ \mathrm{T}\ (=20\ \mu\mathrm{T})
\]
この位置での向きは西（\(-\hat{x}\)）。よって
\(\overrightarrow{B}_{\text{wire}}=(-2.0\times10^{-5},\,0)\ \mathrm{T}\)。</p>

<p>合成磁場の成分：
\[
\overrightarrow{B}_{\text{tot}}=\overrightarrow{B}_{\text{E}}+\overrightarrow{B}_{\text{wire}}
\]
\[
\overrightarrow{B}_{\text{tot}}=\big(-2.0\times10^{-5},\ 3.0\times10^{-5}\big)\ \mathrm{T}
\]
大きさ：
\[
|\overrightarrow{B}_{\text{tot}}|=\sqrt{(2.0\times10^{-5})^2+(3.0\times10^{-5})^2}
\]
\[
|\overrightarrow{B}_{\text{tot}}|=3.606\times10^{-5}\ \mathrm{T}\ (=36.06\ \mu\mathrm{T})
\]
</p>

<p>偏れ角（北から西への角度 \(\theta\)）。<b>arctan は使わず</b>、余弦・正弦で求める：</p>
\[
\cos\theta=\frac{(\overrightarrow{B}_{\text{tot}})_y}{|\overrightarrow{B}_{\text{tot}}|}
\]
\[
\cos\theta=\frac{3.0\times10^{-5}}{3.606\times10^{-5}}\approx 0.8321
\]
同様に確認：
\[
\sin\theta=\frac{|(\overrightarrow{B}_{\text{tot}})_x|}{|\overrightarrow{B}_{\text{tot}}|}
\]
\[
\sin\theta=\frac{2.0\times10^{-5}}{3.606\times10^{-5}}\approx 0.5547
\]
したがって
\[
\theta\approx \cos^{-1}(0.8321)\approx 33.7^\circ
\]
方向は「北から<b>西へ</b> \(33.7^\circ\)」。</p>

<div class="common-box">答え</div>
<p>
\(\overrightarrow{B}_{\text{tot}}=\big(-20,\ 30\big)\ \mu\mathrm{T}\)、\(|\overrightarrow{B}_{\text{tot}}|\approx 36.1\ \mu\mathrm{T}\)。<br/>
方位磁石は<b>北から西へ \(33.7^\circ\)</b>の方向を指す（方位角 \(\approx 326.3^\circ\)）。</p>

<hr/>
<p style="font-size:0.95em;">
<b>位置を変えたとき</b>：東側に置けば \(\overrightarrow{B}_{\text{wire}}\) は北向きで増強（約 \(50\ \mu\mathrm{T}\)）。西側なら南向きで減少（約 \(10\ \mu\mathrm{T}\)）。評価は常に \(\overrightarrow{B}_{\text{E}}+\overrightarrow{B}_{\text{wire}}\) で行い、角度は \(\cos\theta=\dfrac{(\overrightarrow{B}_{\text{tot}})_y}{|\overrightarrow{B}_{\text{tot}}|}\) で求めるとよい。</p>
"""
);
