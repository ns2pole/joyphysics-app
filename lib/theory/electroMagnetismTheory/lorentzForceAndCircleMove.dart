import '../../model.dart';

final lorentzForceAndCircleMove = TheoryTopic(
  title: '一様磁場中の荷電粒子の運動（非相対論、命題・証明形式）',
  latexContent: """
<div class="common-box">前提・設定</div>
<p>荷電粒子はローレンツ力の下で運動する。ここでは磁場が一様かつ時間に依存しないものとし、電場はゼロと仮定する。</p>
<p>運動方程式：</p>
<p>\$\$
m\\frac{d\\mathbf{v}}{dt}=q\\,\\mathbf{v}\\times\\mathbf{B},
\$\$</p>
<p>座標軸を磁場方向に取り、\$\$\\mathbf{B}=(0,0,B),\\qquad \\mathbf{v}=(v_x,v_y,v_z)\$\$ とする。</p>

<div class="common-box">命題・証明</div>

<div style="font-weight:bold; margin-top:10px;">命題 1（磁場に平行な成分）</div>
<p>磁場 \$\\mathbf{B}\$ に平行な速度成分 \$v_{\\parallel}=v_z\$ は時間に対して一定である。</p>
<div style="font-style:italic;">証明</div>
<p>運動方程式の \$z\$ 成分を見ると、</p>
<p>\$\$
m\\dot v_z = q(v_x B_y - v_y B_x)=0,
\$\$</p>
<p>ここで \$B_x=B_y=0\$ であるため \$\\dot v_z=0\$、よって \$v_z\$ は定数である。</p>

<div style="font-weight:bold; margin-top:10px;">命題 2（磁場に直交する成分）</div>
<p>磁場に直交する速度成分 \$(v_x,v_y)\$ は等速円運動を行う（大きさ一定）。</p>
<div style="font-style:italic;">証明</div>
<p>サイクロトロン周波数を定義する：</p>
<p>\$\$
\\omega_c=\\frac{qB}{m}.
\$\$</p>
<p>運動方程式の \$x,y\$ 成分は次の連立で表される：</p>
<p>\$\$
\\dot v_x = \\omega_c v_y,\\qquad
\\dot v_y = -\\omega_c v_x.
\$\$</p>
<p>両辺を整理して、例えば \$\\dot v_x\$ をもう一度微分すると</p>
<p>\$\$
\\ddot v_x = \\omega_c \\dot v_y = -\\omega_c^2 v_x,
\$\$</p>
<p>となり、\$v_x\$ は単振動方程式に従う。よって解は</p>
<p>\$\$
v_x(t)=C_1\\cos(\\omega_c t)+C_2\\sin(\\omega_c t),
\$\$</p>
<p>および</p>
<p>\$\$
v_y(t)=-C_1\\sin(\\omega_c t)+C_2\\cos(\\omega_c t)
\$\$</p>
<p>で表される。初期条件 \$v_x(0)=v_{x0},\\; v_y(0)=v_{y0}\$ より \$C_1=v_{x0},\\; C_2=v_{y0}\$ である。すると</p>
<p style="background:#f7f7f7; padding:8px; display:inline-block;">\$\$
\\boxed{\\;
v_x(t)=v_{x0}\\cos(\\omega_c t)+v_{y0}\\sin(\\omega_c t),\\qquad
v_y(t)=-v_{x0}\\sin(\\omega_c t)+v_{y0}\\cos(\\omega_c t)
\\; }\$\$</p>
<p>であり、瞬時速度の大きさ \$v_\\perp=\\sqrt{v_x^2+v_y^2}\$ は時間に依らず一定であることが確認できる。</p>

<div style="font-weight:bold; margin-top:10px;">命題 3（位置の式と円運動の中心・半径）</div>
<p>初期位置を \$(x_0,y_0)\$ とすると、位置ベクトルは円運動の中心と半径を持つことが示される。</p>
<div style="font-style:italic;">証明</div>
<p>速度を時間積分して位置を得る：</p>
<p>\$\$
x(t)=x_0+\\int_0^t v_x(s)\\,ds
= x_0 + \\frac{v_{x0}}{\\omega_c}\\sin(\\omega_c t) - \\frac{v_{y0}}{\\omega_c}\\cos(\\omega_c t) + \\frac{v_{y0}}{\\omega_c},
\$\$</p>
<p>\$\$
y(t)=y_0+\\int_0^t v_y(s)\\,ds
= y_0 - \\frac{v_{x0}}{\\omega_c}\\cos(\\omega_c t) + \\frac{v_{y0}}{\\omega_c}\\sin(\\omega_c t) + \\frac{v_{x0}}{\\omega_c}.
\$\$</p>
<p>これらを次のように整理する：</p>
<p>\$\$
X(t):=x(t)-x_0+\\frac{v_{y0}}{\\omega_c}=\\frac{v_{x0}}{\\omega_c}\\sin(\\omega_c t)-\\frac{v_{y0}}{\\omega_c}\\cos(\\omega_c t),
\$\$</p>
<p>\$\$
Y(t):=y(t)-y_0-\\frac{v_{x0}}{\\omega_c}=-\\frac{v_{x0}}{\\omega_c}\\cos(\\omega_c t)+\\frac{v_{y0}}{\\omega_c}\\sin(\\omega_c t).
\$\$</p>
<p>すると</p>
<p>\$\$
X(t)^2+Y(t)^2=\\frac{v_{x0}^2+v_{y0}^2}{\\omega_c^2},
\$\$</p>
<p>であるから、粒子は中心</p>
<p>\$\$
\\left( x_0-\\frac{v_{y0}}{\\omega_c},\\; y_0+\\frac{v_{x0}}{\\omega_c} \\right)
\$\$</p>
<p>半径</p>
<p>\$\$
R=\\frac{\\sqrt{v_{x0}^2+v_{y0}^2}}{|\\omega_c|}
\$\$</p>
<p>の円を角速度 \$\\omega_c\$ で回っていることが分かる。</p>

<div style="font-weight:bold; margin-top:10px;">命題 4（螺旋運動）</div>
<p>粒子の全運動は磁場方向の等速直線運動と直交平面内での等速円運動の合成であり、磁場方向を軸とするらせん（円筒螺旋）を描く。</p>
<div style="font-style:italic;">証明</div>
<p>\$v_\\parallel=v_z\$ は定数であり、直交成分は半径 \$R\$ の円運動を行うので位置ベクトルは次で表される：</p>
<p>\$\$
\\mathbf{r}(t)=
\\begin{pmatrix}
R\\cos(\\omega_c t + \\phi) \\\\
R\\sin(\\omega_c t + \\phi) \\\\
v_\\parallel t + z_0
\\end{pmatrix},
\$\$</p>
<p>ここで \$R=v_\\perp/|\\omega_c|\$, \$v_\\perp=\\sqrt{v_{x0}^2+v_{y0}^2}\$、ピッチは \$p=2\\pi v_\\parallel/|\\omega_c|\$ である。</p>

<div class="common-box" style="margin-top:12px;">まとめ</div>
<ul>
<li>磁場方向成分は保存され、\$v_\\parallel\$ は一定。</li>
<li>磁場に直交する成分は等速円運動を行い、その結果全運動は円筒らせんとなる。</li>
<li>円運動の半径は \$R=v_\\perp/|\\omega_c|\$、角速度は \$\\omega_c=qB/m\$、ピッチは \$p=2\\pi v_\\parallel/|\\omega_c|\$ で与えられる。</li>
</ul>
""",
);
