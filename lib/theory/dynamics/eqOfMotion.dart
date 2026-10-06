import '../../model.dart';

final eqOfMotion = TheoryTopic(
  title: '質点の運動について',
  titleEn: 'On the motion of a particle',
  isNew: false,
  imageAsset: 'assets/mindMap/forTopics/eqOfMotion.png', // 実際の画像パス
  latexContent: r"""

<div class="theory-common-box">用語の定義（簡潔）</div>
<ul>
  <li><strong>慣性</strong>：物体がその運動状態（静止または等速直線運動）を維持しようとする性質。</li>
  <li><strong>質量</strong>：物体の慣性の大きさを表す量。運動の変化に対する抵抗の尺度で、単位は kg。</li>
  <li><strong>質点</strong>：物体の形状や大きさを無視して1点で代表させ、ここに物体の全質量があると考えた時の点。</li>
  <li><strong>力</strong>：物体の運動を変化させる原因となるベクトル量。</li>
  <li><strong>慣性系</strong>：ニュートンの第一法則が成り立つ座標系。</li>
  <li><strong>代数方程式</strong>：未知数についての方程式。</li>
  <li><strong>関数方程式</strong>：未知関数についての方程式。</li>
  <li><strong>微分方程式</strong>：未知関数とその微分を含む関数方程式。</li>
</ul>

<div class="theory-common-box">ニュートンの第一法則（慣性の法則）</div>
<p>
質点は、その質点に働く力の総和が$\ \vec 0\ $ならば静止または等速直線運動を続ける。
</p>
$$
\sum_{i=1}^{n} \vec{F}_i = \vec{0}
\ \ \Rightarrow \ \ 
\vec{a} = \vec{0}
\quad (\text{即ち速度}\vec{v}\text{ は一定})
$$

<div class="theory-common-box">ニュートンの第二法則（運動方程式）</div>
<p>
質量$m$の質点に力 $\vec{F_i}\ (i=1\cdots n)$ が作用するとき、その質点の加速度 $\vec{a}$ は
$\displaystyle m \vec{a} = \sum_{i=1}^{n} \vec{F}_i$で与えられる。
</p>
<div class="theory-common-box">ニュートンの第三法則（作用反作用の法則）</div>
<p>
二つの質点 1, 2 の間に相互に力が働くとき、質点 2 が質点 1 に及ぼす力 
$\vec{F}_{{1} \leftarrow {2}} $ と、質点 1 が質点 2 に及ぼす力 $\vec{F}_{{2} \leftarrow {1}}$ は大きさが等しく逆向きである：
$\displaystyle \vec{F}_{{2} \leftarrow {1}} = -\vec{F}_{{1} \leftarrow {2}} $
</p>
""",
  latexContentEn: r"""

<div class="theory-common-box">Definitions of terms (brief)</div>
<ul>
  <li><strong>Inertia</strong>: the property of a body to maintain its state of motion (rest or uniform straight-line motion).</li>
  <li><strong>Mass</strong>: a quantity measuring the amount of inertia. It is a measure of resistance to change of motion; the unit is kg.</li>
  <li><strong>Particle (mass point)</strong>: an idealization in which the shape and size of a body are ignored and the entire mass is regarded as concentrated at a single point.</li>
  <li><strong>Force</strong>: a vector quantity that causes a change in the motion of a body.</li>
  <li><strong>Inertial frame</strong>: a coordinate system in which Newton's first law holds.</li>
  <li><strong>Algebraic equation</strong>: an equation for unknown numbers.</li>
  <li><strong>Functional equation</strong>: an equation for an unknown function.</li>
  <li><strong>Differential equation</strong>: a functional equation that involves an unknown function and its derivatives.</li>
</ul>

<div class="theory-common-box">Newton's first law (law of inertia)</div>
<p>
A particle continues at rest or in uniform straight-line motion if the total force acting on it is $\ \vec 0\ $.
</p>
$$
\sum_{i=1}^{n} \vec{F}_i = \vec{0}
\ \ \Rightarrow \ \ 
\vec{a} = \vec{0}
\quad (\text{i.e. the velocity }\vec{v}\text{ is constant})
$$

<div class="theory-common-box">Newton's second law (equation of motion)</div>
<p>
When forces $\vec{F_i}\ (i=1\cdots n)$ act on a particle of mass $m$, its acceleration $\vec{a}$ is given by
$\displaystyle m \vec{a} = \sum_{i=1}^{n} \vec{F}_i$.
</p>
<div class="theory-common-box">Newton's third law (action–reaction)</div>
<p>
When two particles 1 and 2 exert forces on each other, the force exerted by particle 2 on particle 1,
$\vec{F}_{{1} \leftarrow {2}} $, and the force exerted by particle 1 on particle 2, $\vec{F}_{{2} \leftarrow {1}}$, are equal in magnitude and opposite in direction:
$\displaystyle \vec{F}_{{2} \leftarrow {1}} = -\vec{F}_{{1} \leftarrow {2}} $
</p>
"""
);