import '../../model.dart';

final harmonic = TheoryTopic(
  title: '単振動型の微分方程式 — 命題と証明（純粋数学）',
  latexContent: """
<div class="common-box">命題</div>
<p>\\(\\omega>0\\) を定数とし、ベクトル値関数 \\(\\overrightarrow{P}(t)\\) が次の線形常微分方程式を満たすとする：</p>
<p>\\[
\\overrightarrow{P}''(t) + \\omega^2\\,\\overrightarrow{P}(t) = \\overrightarrow{0}. 
\\]</p>
<p>また正規直交基底 \\(\\overrightarrow{u},\\overrightarrow{v}\\) とスカラー函数 \\(\\theta(t)\\) が存在して</p>
<p>\\[
\\overrightarrow{P}(t)=\\overrightarrow{u}\\cos\\theta(t)+\\overrightarrow{v}\\sin\\theta(t)
\\]</p>
<p>が成り立つとき、次が成立する：</p>
<ul>
<li>エネルギー函数
\\(E(t):=\\dfrac{1}{2}\\|\\overrightarrow{P}'(t)\\|^2+\\dfrac{1}{2}\\omega^2\\|\\overrightarrow{P}(t)\\|^2\\)
は時間に対して不変（保存される）。</li>
<li>角函数の一階導関数 \\(\\theta'(t)\\) は定数である（すなわち \\(\\theta''(t)=0\\)）。</li>
</ul>

<div class="common-box">証明</div>
<p>（1）まずエネルギー保存の導出。</p>
<p>与えられた方程式に \\(\\overrightarrow{P}'(t)\\) と内積を取ると：</p>
<p>\\[
\\left\\langle\\overrightarrow{P}',\\,\\overrightarrow{P}''\\right\\rangle
+\\omega^2\\left\\langle\\overrightarrow{P}',\\,\\overrightarrow{P}\\right\\rangle=0.
\\]</p>
<p>左辺第一項は積の微分を利用して</p>
<p>\\[
\\left\\langle\\overrightarrow{P}',\\,\\overrightarrow{P}''\\right\\rangle
=\\tfrac{1}{2}\\frac{d}{dt}\\|\\overrightarrow{P}'\\|^2,
\\]</p>
<p>第二項も同様に</p>
<p>\\[
\\left\\langle\\overrightarrow{P}',\\,\\overrightarrow{P}\\right\\rangle
=\\tfrac{1}{2}\\frac{d}{dt}\\|\\overrightarrow{P}\\|^2.
\\]</p>
<p>したがって</p>
<p>\\[
\\tfrac{1}{2}\\frac{d}{dt}\\|\\overrightarrow{P}'\\|^2
+\\tfrac{1}{2}\\omega^2\\frac{d}{dt}\\|\\overrightarrow{P}\\|^2
=\\frac{d}{dt}\\Big(\\tfrac{1}{2}\\|\\overrightarrow{P}'\\|^2+\\tfrac{1}{2}\\omega^2\\|\\overrightarrow{P}\\|^2\\Big)=0.
\\]</p>
<p>ゆえに \\(E(t)\\) は定数である。これでエネルギー保存が示された。</p>

<p>（2）次に表示 \\(\\overrightarrow{P}=\\overrightarrow{u}\\cos\\theta+\\overrightarrow{v}\\sin\\theta\\) を用いて \\(\\theta'(t)\\) が定数であることを示す。</p>
<p>まず速さ（一次導関数）と二次導関数を計算する。便宜上 \\(\\theta=\\theta(t)\\) と略す。</p>
<p>\\[
\\overrightarrow{P}'=\\theta'\\big(-\\overrightarrow{u}\\sin\\theta+\\overrightarrow{v}\\cos\\theta\\big),
\\]</p>
<p>並びに（積の微分）</p>
<p>\\[
\\overrightarrow{P}''=\\theta''\\big(-\\overrightarrow{u}\\sin\\theta+\\overrightarrow{v}\\cos\\theta\\big)
-(\\theta')^2\\big(\\overrightarrow{u}\\cos\\theta+\\overrightarrow{v}\\sin\\theta\\big).
\\]</p>
<p>ここで便宜的に \\(\\overrightarrow{Q}:=-\\overrightarrow{u}\\sin\\theta+\\overrightarrow{v}\\cos\\theta\\) とおく。\\(\\overrightarrow{Q}\\) は \\(\\overrightarrow{P}\\) と直交し、かつ正規であることに注意する：</p>
<p>\\[
\\langle\\overrightarrow{P},\\overrightarrow{Q}\\rangle
=\\cos\\theta(-\\sin\\theta)\\langle\\overrightarrow{u},\\overrightarrow{u}\\rangle
+\\sin\\theta(\\cos\\theta)\\langle\\overrightarrow{v},\\overrightarrow{v}\\rangle
=0,
\\quad
\\|\\overrightarrow{Q}\\|^2=\\sin^2\\theta+\\cos^2\\theta=1.
\\]</p>
<p>元の方程式 \\(\\overrightarrow{P}''+\\omega^2\\overrightarrow{P}=0\\) に上の \\(\\overrightarrow{P}''\\) を代入すると：</p>
<p>\\[
\\theta''\\,\\overrightarrow{Q} - (\\theta')^2\\,\\overrightarrow{P} + \\omega^2\\,\\overrightarrow{P}=\\overrightarrow{0}.
\\]</p>
<p>この両辺と \\(\\overrightarrow{Q}\\) と内積を取ると、直交性により \\(\\langle\\overrightarrow{P},\\overrightarrow{Q}\\rangle=0\\) が消え、</p>
<p>\\[
\\theta''\\,\\langle\\overrightarrow{Q},\\overrightarrow{Q}\\rangle =0.
\\]</p>
<p>よって \\(\\theta''(t)=0\\) である。これは \\(\\theta'(t)\\) が定数であることを意味する。</p>

<div class="common-box">結論</div>
<p>以上より、命題の主張通り（i）エネルギー \\(E(t)\\) は保存され、（ii）表示 \\(\\overrightarrow{P}=\\overrightarrow{u}\\cos\\theta+\\overrightarrow{v}\\sin\\theta\\) の下では \\(\\theta'\\) は定数である。</p>
"""
);