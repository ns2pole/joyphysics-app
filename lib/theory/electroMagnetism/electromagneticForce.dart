import '../../model.dart';

final electromagneticForce = TheoryTopic(
  title: 'クーロン力とローレンツ力',
  titleEn: 'Coulomb force and Lorentz force',
  imageAsset: 'assets/mindMap/forTopics/electromagneticForce.png',
  latexContent: r"""
<div class="theory-common-box">法則（荷電粒子が受ける力）</div>
<p>
荷電粒子が電場 $\vec{E}$ および磁場 $\vec{B}$ の中を速度 $\vec{v}$ で運動するとき，
この電磁場から受ける力は次式で与えられる。
</p>

$$
\vec{F} = q \bigl( \vec{E} + \vec{v} \times \vec{B} \bigr)
$$

<div class="paragraph-box">説明</div>
<ul>
  <li>$q \vec{E}$ は電場による力で <b>クーロン力</b> という。</li>
  <li>$q \vec{v} \times \vec{B}$ は磁場による力で <b>ローレンツ力</b> という。(電場による力(クーロン力)もまとめてローレンツ力と呼ぶこともある。)<br>
      （「$\times$」はベクトルの <b>クロス積</b> を表し、方向は右ねじの法則で決まる。）</li>
</ul>

<div class="paragraph-box">補足</div>
<ul>
  <li>磁場の力は常に $\vec{v}$ に直交するため，仕事をしない（速度の大きさは変えない）。</li>
  <li>力の見え方は観測者に依存する。<br>
    ある観測者には「静止電荷に働くクーロン力」と見えても，
    別の観測者には「運動する電荷に働くローレンツ力」として表される。<br>
  <li>同様に、観測者の慣性系によって電場と磁場は違って見える。<br>
    例えば，ある観測者にとって純粋な磁場でも，別の観測者にとっては電場と磁場の両方として現れる。ちなみに、相対論的では電場と磁場は統一的に「電磁場テンソル」として扱う。
  </li>
</li>
""",
  latexContentEn: r"""
<div class="theory-common-box">Law (force on a charged particle)</div>
<p>
When a charged particle moves with velocity $\vec{v}$ in an electric field $\vec{E}$ and a magnetic field $\vec{B}$,
the force it receives from the electromagnetic field is given by
</p>

$$
\vec{F} = q \bigl( \vec{E} + \vec{v} \times \vec{B} \bigr)
$$

<div class="paragraph-box">Explanation</div>
<ul>
  <li>$q \vec{E}$ is the force due to the electric field and is called the <b>Coulomb force</b>.</li>
  <li>$q \vec{v} \times \vec{B}$ is the force due to the magnetic field and is called the <b>Lorentz force</b>. (Sometimes the electric force is also included under the name Lorentz force.)<br>
      (The symbol “$\times$” denotes the vector <b>cross product</b>; its direction is fixed by the right-handed screw rule.)</li>
</ul>

<div class="paragraph-box">Remarks</div>
<ul>
  <li>The magnetic force is always orthogonal to $\vec{v}$, so it does no work (it does not change the speed).</li>
  <li>How the force appears depends on the observer.<br>
    What one observer sees as a “Coulomb force on a charge at rest”
    may appear to another as a “Lorentz force on a moving charge”.<br>
  <li>Likewise, the electric and magnetic fields look different in different inertial frames.<br>
    For example, a pure magnetic field for one observer may appear as both electric and magnetic fields to another. In relativity, the electric and magnetic fields are unified as the electromagnetic field tensor.
  </li>
</li>
""",
);
