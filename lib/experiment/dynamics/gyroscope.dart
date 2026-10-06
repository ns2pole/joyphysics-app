import 'package:joyphysics/experiment/dynamics/GyroscopeExperimentWidget.dart';
import '../../model.dart';

final gyroscope = Video(
  isSmartPhoneOnly: true,
  category: 'dynamics',
  iconName: "",
  title: "角速度の測定",
  titleEn: "Measuring angular velocity",
  videoURL: "",
  equipment: ["スマホ（ジャイロセンサー搭載）"],
  equipmentEn: ["smartphone (with gyroscope)"],
  costRating: "★☆☆",
  latex: r"""
<div class="common-box">ジャイロセンサーとは？</div>
<p>このセンサーは「物体が空間でどれくらいの速さで回転しているか」（角速度）を表示します。単位は $\mathrm{rad/s}$ です。</p>
<div class="common-box">観察ポイント</div>
<ul>
  <li>机の上に静かに置く → 角速度は約 $0\,\mathrm{rad/s}$</li>
  <li>端末をゆっくり傾ける → 角速度は小さい（向きが変わっても、回転が遅ければ値は小さい）</li>
  <li>端末を素早く回す → 回しているあいだだけ大きな角速度が観測される</li>
  <li>1つの軸のまわりだけに回す → その軸に対応した成分が大きくなり、他の軸はほぼ $0$</li>
  <li>加速度センサーとの対比：一定方向に傾けるだけなら線形加速度は $0\,\mathrm{m/s^2}$ だが、傾けている最中はジャイロが非ゼロになる</li>
  <li>一定の速さで1回転させ、かかった時間を $T$ とすると、合成角速度は $\omega = 2\pi / T$ で見積もれる</li>
</ul>
<div class="common-box">注意点</div>
<ul>
  <li>軸の向き（アプリでどの軸を上向きに定義しているか）により符号が変わる。</li>
  <li>手で回すと角速度は一定になりにくい。合成角速度の大きさで回転の速さの目安を見る。</li>
</ul>
""",
  latexEn: r"""
<div class="common-box">What is a gyroscope sensor?</div>
<p>This sensor shows how fast an object is rotating in space (angular velocity). The unit is $\mathrm{rad/s}$.</p>
<div class="common-box">What to observe</div>
<ul>
  <li>Rest quietly on a desk → angular velocity is about $0\,\mathrm{rad/s}$</li>
  <li>Tilt the phone slowly → angular velocity is small (orientation changes, but a slow rotation gives a small reading)</li>
  <li>Spin the phone quickly → a large angular velocity appears only while it is spinning</li>
  <li>Rotate about a single axis → that axis component becomes large and the others stay near $0$</li>
  <li>Contrast with the accelerometer: a fixed tilt alone gives linear acceleration $0\,\mathrm{m/s^2}$, but while you are tilting, the gyro is nonzero</li>
  <li>For one full turn at roughly constant speed taking time $T$, the resultant angular speed is about $\displaystyle \omega = \frac{2\pi}{T}$</li>
</ul>
<div class="common-box">Note</div>
<ul>
  <li>The sign depends on axis orientation (which axis the app defines as upward).</li>
  <li>Hand rotation is rarely constant; use the magnitude of the resultant angular velocity as a guide to how fast you are spinning.</li>
</ul>
""",
  experimentWidgets: [GyroscopeExperimentWidget(useScaffold: false)],
);
