import 'package:joyphysics/experiment/dynamics/AccelerometerExperimentWidget.dart';
import '../../model.dart';

final accelerometer = Video(
  isSmartPhoneOnly: true,
  category: 'dynamics',
  iconName: "accelerometer",
  title: "加速度の測定",
  titleEn: "Measuring acceleration",
  videoURL: "",
  equipment: ["スマホ（加速度センサー搭載）"],
  equipmentEn: ["smartphone (with accelerometer)"],
  costRating: "★☆☆",
  latex: r"""
<div class="common-box">加速度センサーとは？</div>
<p>このセンサーは「物体が空間でどのように加速しているか」を表示します。</p>
<div class="common-box">観察ポイント</div>
<ul>
  <li>机の上に静かに置く → 加速度は$0 m/s²$</li>
  <li>端末を一定方向に傾けるだけ → 加速度は$0 m/s²$(向き変化は速度変化を伴わない）</li>
  <li>前後・上下に加速させる → その方向に対応した軸で非ゼロの加速度が観測される</li>
  <li>自由落下させる → 加速度は約$9.8 m/s²$を示す（重力による加速度）</li>
  <li>着地・衝撃の瞬間 → 撃力による大きなスパイクが出る（正負は向きに依存）</li>
  <li>軸の向き（アプリでどの軸を上向きに定義しているか）により符号が変わる。</li>
</ul>
<div class="common-box">注意点</div>
<ul>
  <li>自由落下や衝撃実験は機器破損のおそれがある。必ず安全対策をすること。</li>
</ul>
""",
  latexEn: r"""
<div class="common-box">What is an accelerometer?</div>
<p>This sensor shows how an object is accelerating in space.</p>
<div class="common-box">What to observe</div>
<ul>
  <li>Rest quietly on a desk → acceleration is $0\,\mathrm{m/s^2}$</li>
  <li>Only tilt the phone in a fixed direction → acceleration is $0\,\mathrm{m/s^2}$ (a change of orientation alone is not a change of velocity)</li>
  <li>Accelerate forward/back or up/down → a nonzero acceleration appears on the corresponding axis</li>
  <li>In free fall → acceleration is about $9.8\,\mathrm{m/s^2}$ (gravitational acceleration)</li>
  <li>At landing or impact → a large spike from an impulsive force (sign depends on direction)</li>
  <li>The sign depends on axis orientation (which axis the app defines as upward).</li>
</ul>
<div class="common-box">Note</div>
<ul>
  <li>Free-fall and impact tests can damage the device. Always take safety precautions.</li>
</ul>
""",
  experimentWidgets: [AccelerometerExperimentWidget(useScaffold: false)],
);
