import '../../model.dart';

final lorentzForceAndCircleMove = TheoryTopic(
  title: '一様磁場中の荷電粒子の運動',
  latexContent: """
  <div class="common-box">記号の定義</div>
  <ul>
    <li>\$m\$：質量，\$q\$：電荷，\$\\vec{B}=(0,0,B)\$：一様磁場</li>
    <li>\$\\vec{v}=(v_x,v_y,v_z)\$：速度，\$v_\\parallel=v_z\$，\$v_\\perp=\\sqrt{v_x^2+v_y^2}\$</li>
    <li>\$\\omega_c=\\dfrac{qB}{m}\$：サイクロトロン角周波数</li>
  </ul>

  <div class="common-box">命題1(ローレンツ力の成分)：電荷 \$q\$ に働く力の成分は
    \$
      \\vec{F}=(F_x,F_y,F_z)=(qBv_y,\,-qBv_x,\,0)
    \$
    である。</div>
  <p>
  </p>
  <div class="proof-box">証明</div>
    速度 \$\\vec{v}\$ と磁場 \$\\vec{B}\$ のなす角を \$\\theta\$ とする。内積より
    \$
      \\cos\\theta = \\frac{\\vec{v}\\cdot\\vec{B}}{|\\vec{v}||\\vec{B}|} = \\frac{v_z}{v}, \\quad
      \\sin\\theta = \\frac{\\sqrt{v_x^2+v_y^2}}{v}.
    \$
    ローレンツ力の大きさは
    \$
      |\\vec{F}| = |q|vB\\sin\\theta = |q|B\\sqrt{v_x^2+v_y^2}.
    \$
    また \$\\vec{F}\$ は \$\\vec{v}\$ に直交するので
    \$
      v_x F_x + v_y F_y = 0.
    \$
    よって \$F_x = k v_y, \; F_y = -k v_x, \; F_z=0\$ と書ける。  
    大きさ条件から \$k^2 = (qB)^2\$。正電荷のとき \$k=qB\$ を選べば
    \$
      \\vec{F} = (qBv_y, -qBv_x, 0).
    \$
    \$\\square\$
  </div>

  <div class="common-box">命題 2：運動方程式（成分）</div>
  <p>
    \$m\\vec{v}'=\\vec{F}\$ と命題1より
  </p>
  \$
    \\begin{cases}
      m v_x' = qB v_y, \\\\
      m v_y' = -qB v_x, \\\\
      m v_z' = 0
    \\end{cases}
  \$

  <div class="common-box">命題 3：磁場は仕事をしない（速さ一定）</div>
  <p>
    速さ \$v=|\\vec{v}|\$ は時間一定である。
  </p>
  <div class="proof-box">証明</div>
  <p>
    仕事率 \$P=\\vec{F}\\cdot\\vec{v}=0\$（直交のため）。  
    したがって
    \$
      \\left(\\tfrac{1}{2} m v^2\\right)' = 0
    \$
    より速さは一定である。
  </p>

  <div class="common-box">命題 4：速度成分\$v_x,v_y\$は単振動である</div>
  <p>
    \$\\omega_c=\\dfrac{qB}{m}\$ とすると
    \$
      v_x' = \\omega_c v_y,\\quad v_y' = -\\omega_c v_x
    \$
    よって
    \$
      v_x''=-\\omega_c^2 v_x,\\quad v_y''=-\\omega_c^2 v_y
    \$
    である。
  </p>
  <div class="proof-box">証明</div>
  <p>
    \$v_x\$ は調和振動方程式に従うので解は
    \$
      v_x=C_1\\cos(\\omega_c t)+C_2\\sin(\\omega_c t)
    \$
    である。命題2から \$v_y=\\tfrac{1}{\\omega_c}v_x'\$ が従い、初期条件から
    \$
      v_x(t)=v_{x0}\\cos(\\omega_c t)+v_{y0}\\sin(\\omega_c t),\\\\
      v_y(t)=-v_{x0}\\sin(\\omega_c t)+v_{y0}\\cos(\\omega_c t)
    \$
    が得られる。
  </p>

  <div class="common-box">命題 5：直交成分の速さは一定である</div>
<p>
  直交成分の速度 \$v_\\perp^2 = v_x^2 + v_y^2\$ は時間一定である。
</p>
  <div class="proof-box">証明</div>
  \$v_\\perp^2\$ を時間で微分すると
  \$
    (v_x^2 + v_y^2)' = 2(v_x v_x' + v_y v_y').
  \$
  命題2の運動方程式より
  \$
    v_x' = \\frac{qB}{m} v_y,\\quad v_y' = -\\frac{qB}{m} v_x.
  \$<br>
  これを代入すると
  \$
    v_x v_x' + v_y v_y' = v_x \\frac{qB}{m} v_y + v_y (-\\frac{qB}{m} v_x) = 0.
  \$
  よって
  \$
    (v_x^2 + v_y^2)' = 0
  \$
  となり、直交成分の速さ \$v_\\perp = \\sqrt{v_x^2 + v_y^2}\$ は時間一定である。  
  \$\\square\$
</div>

  <div class="common-box">命題 6：平行成分\$v_z\$は等速である</div>
  <p>
    \$m v_z'=0\$ より \$v_z=v_{z0}\$。積分すると
    \$
      z(t)=z_0+v_{z0}t
    \$
    である。
  </p>
  <div class="proof-box">証明</div>
  <p>
    \$v_z'=0\$ を積分すればただちに得られる。
  </p>

  <div class="common-box">命題 7：磁場の直交成分の位置</div>
  <p>
    物体の\$x,y\$座標は\$\ \ \ \$
    \$
      \\begin{cases}
        x(t)=x_0+\\tfrac{v_{x0}}{\\omega_c}\\sin(\\omega_c t)+\\tfrac{v_{y0}}{\\omega_c}(1-\\cos(\\omega_c t)), \\\\
        y(t)=y_0+\\tfrac{v_{y0}}{\\omega_c}\\sin(\\omega_c t)-\\tfrac{v_{x0}}{\\omega_c}(1-\\cos(\\omega_c t))
      \\end{cases}
    \ \ \ \$となる。
  </p>
  <div class="proof-box">証明</div>
  <p>
    命題4より、直交成分の速度は
    \\begin{aligned}
      &\\begin{cases}
      v_x(t)=v_{x0}\\cos(\\omega_c t)+v_{y0}\\sin(\\omega_c t) \\\\
      v_y(t)=-v_{x0}\\sin(\\omega_c t)+v_{y0}\\cos(\\omega_c t)
    \\end{cases}
      \\end{aligned}
    と表される。<br>まず \$x\$ 成分は
    \$
      x(t)-x_0 = \\int_0^t v_x(s) ds
                = \\frac{v_{x0}}{\\omega_c} \\sin(\\omega_c t)
                  + \\frac{v_{y0}}{\\omega_c}(1-\\cos(\\omega_c t)),
    \$
    よって
    \$
      x(t) = x_0 + \\frac{v_{x0}}{\\omega_c} \\sin(\\omega_c t)
                   + \\frac{v_{y0}}{\\omega_c}(1-\\cos(\\omega_c t)).
    \$<br>
    \$y\$ 成分も同様に
    \$
      y(t) = y_0 + \\frac{v_{y0}}{\\omega_c} \\sin(\\omega_c t)
                   - \\frac{v_{x0}}{\\omega_c}(1-\\cos(\\omega_c t)).
    \$    （注）\$\\omega_c=0\$（磁場 \$B=0\$）の場合は極限を取り、等速直線運動に一致する。
  </p>
  <div class="common-box">命題 8：物体のxyについての運動は等速円運動である</div>
<ul>
  <li>半径：\$ R = \\dfrac{v_\\perp}{|\\omega_c|} \$</li>
  <li>中心：\$ (X_c,Y_c) = \\bigl(x_0 + \\tfrac{v_{y0}}{\\omega_c},\, y_0 - \\tfrac{v_{x0}}{\\omega_c}\\bigr) \$</li>
  <li>周期：\$ T = \\dfrac{2\\pi}{|\\omega_c|} \$</li>
</ul>

  <div class="proof-box">証明</div>
  <b>証明.</b><br>
  命題7より直交成分の位置は
  \\begin{aligned}
        &\\begin{cases}
    x(t)=x_0+\\frac{v_{x0}}{\\omega_c}\\sin(\\omega_c t)+\\frac{v_{y0}}{\\omega_c}(1-\\cos(\\omega_c t))\\\\
    y(t)=y_0+\\frac{v_{y0}}{\\omega_c}\\sin(\\omega_c t)-\\frac{v_{x0}}{\\omega_c}(1-\\cos(\\omega_c t))
  \\end{cases}
    \\end{aligned}
  と表される。ここで
  \$
    X_c = x_0 + \\frac{v_{y0}}{\\omega_c},\\quad Y_c = y_0 - \\frac{v_{x0}}{\\omega_c}
  \$
  と定義すると
  \$
    x(t) - X_c = \\frac{v_{x0}}{\\omega_c} \\sin(\\omega_c t) - \\frac{v_{y0}}{\\omega_c} \\cos(\\omega_c t) 
  \$ <br>
  同様に
  \$
    y(t)-Y_c = \\frac{v_{y0}}{\\omega_c} \\sin(\\omega_c t) + \\frac{v_{x0}}{\\omega_c} \\cos(\\omega_c t)
  \$
  となる。よって
  \$
    (x-X_c)^2 + (y-Y_c)^2 = \\frac{v_{x0}^2+v_{y0}^2}{\\omega_c^2} = \\frac{v_\\perp^2}{\\omega_c^2}
  \$
  が成り立つ。したがって直交成分は\$\\frac{v_\\perp}{|\\omega_c|} \$半径の円運動をしていることがわかる。<br>
  角速度の大きさは \$|\\omega_c|\$、周期は \$T=2\\pi/|\\omega_c|\$。
  \$\\square\$
</div>


  <div class="common-box">命題 9：物体の運動は螺旋運動である</div>
  <p>
    平面内での等速円運動と、平行方向の等速直線運動の合成により、粒子は螺旋運動をする。
  </p>
  <div class="proof-box">証明</div>
  <p>
    命題8で円運動、命題6で直線運動が示されたので、その合成は螺旋運動である。
  </p>

  <div class="common-box">命題 10：運動の螺旋のピッチ</div>
  <p>
    螺旋運動のピッチは
    \$
      p=\\frac{2\\pi v_{z0}}{|\\omega_c|}
    \$
    である。
  </p>
  <div class="proof-box">証明</div>
  <p>
    1回転の周期は \$T=2\\pi/|\\omega_c|\$。その間に進む距離は \$v_{z0}T\$ なので上式が得られる。
  </p>
""",
);
