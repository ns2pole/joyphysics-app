import '../../model.dart';

final lorentzForceAndCircleMove = TheoryTopic(
  title: '一様磁場中の荷電粒子の運動',
  titleEn: 'Motion of a charged particle in a uniform magnetic field',
  // imageAsset: 'assets/mindMap/forTopics/lorentzForceAndCircleMove.png',
  latexContent: r"""
  <div style="text-align:center; margin:1em 0;">
      <img src="assets/electroMagnetismTheory/lorentz.png"
           alt="データ一覧"
           style="max-width:70%; height:auto;" />
    </div>
  <div class="theory-common-box">記号の定義</div>
  <ul>
    <li>$m$：質量，$q$：電荷</li>
    <li>$\vec{B}=(0,0,B)$：一様磁場</li>
    <li>$\vec{x}=(x,y,z)$：位置ベクトル（成分表示）</li>
    <li>$\vec{v}=(v_x,v_y,v_z)$：速度ベクトル（成分表示）</li>
    <li>$v=\sqrt{v_x^2+v_y^2+v_z^2}$：速さ</li>
    <li>$v_\parallel=v_z$：磁場平行成分速度成分</li>
    <li>$v_\perp=\sqrt{v_x^2+v_y^2}$：磁場平行成分速さ</li>
    <li>$x_0,y_0,z_0$：初期位置（成分表示）</li>
    <li>$v_{x0},v_{z0},v_{z0}$：初期速度（成分表示）</li>
    <li>$\omega_c=\dfrac{qB}{m}$：角周波数</li>
  </ul>

  <div class="theory-common-box">命題1(ローレンツ力の成分)：電荷 $q$ に働く力の成分は
    $
      \vec{F}=(F_x,F_y,F_z)=(qBv_y,\,-qBv_x,\,0)
    $
    である</div>
  <div class="proof-box">証明</div>
    速度 $\vec{v}$ と磁場 $\vec{B}$ のなす角を $\theta$ とする。内積より
    $
      \displaystyle \cos\theta = \frac{\vec{v}\cdot\vec{B}}{|\vec{v}||\vec{B}|} = \frac{v_z}{v}, \quad
      \displaystyle \sin\theta = \frac{\sqrt{v_x^2+v_y^2}}{v}.
    $<br>
    ローレンツ力の大きさは
    $
      |\vec{F}| = |q|vB\sin\theta = |q|B\sqrt{v_x^2+v_y^2}.
    $
    <br>また $\vec{F}$ は $\vec{v}$ に直交するので
    $
      v_x F_x + v_y F_y = 0.
    $<br>
    よって $F_x = k v_y, \; F_y = -k v_x, \; F_z=0$ と書ける。  <br>
    大きさ条件から $k^2 = (qB)^2$。正電荷のとき $k=qB$ を選べば
    $
      \vec{F} = (qBv_y, -qBv_x, 0).
    $
    $\square$
  </div>

  <div class="theory-common-box">命題 2：運動方程式（成分）</div>
    $m\vec{a}=m\vec{v}'=\vec{F}$ （運動方程式）と命題1より
  $$
    \begin{cases}
      m v_x' = qB v_y, \\
      m v_y' = -qB v_x, \\
      m v_z' = 0
    \end{cases}
  $$
  <div class="theory-common-box">命題 3：速さ $v=|\vec{v}|$ は時間一定</div>
  <div class="proof-box">証明</div>
    仕事率 $P=\vec{F}\cdot\vec{v}=0$（直交のため）。  
    したがって
    $$\begin{aligned}
      \displaystyle \left(\tfrac{1}{2} m v^2\right)'  &= 0 \\[6pt]
      \Leftrightarrow v v' &= 0 \\[6pt]
      \Leftrightarrow v = 0 &\text{または} v' = 0
    \end{aligned}$$
もし $v=0$ なら自明に一定、$v\neq 0$ なら $v'=0$ であり速さは一定である。
（磁場は仕事をしない）  $\square$

  <div class="theory-common-box">命題 4：速度成分$v_x,v_y$は、
    $
    \begin{cases}
      v_x(t)=v_{x0}\cos(\omega_c t)+v_{y0}\sin(\omega_c t)\\[6pt]
      v_y(t)=-v_{x0}\sin(\omega_c t)+v_{y0}\cos(\omega_c t)
    \end{cases}
    $
    　となる</div>
  <div class="proof-box">証明</div>
    $\omega_c=\dfrac{qB}{m}$ とすると
    $
      v_x' = \omega_c v_y,\quad v_y' = -\omega_c v_x
    $<br>
    よって
    $
      v_x''=-\omega_c^2 v_x,\quad v_y''=-\omega_c^2 v_y
    $
    である。<br>
    $v_x$ は調和振動の微分方程式に従うので解は
    $
      v_x=C_1\cos(\omega_c t)+C_2\sin(\omega_c t)
    $
    である。<br>命題2から $v_y=\tfrac{1}{\omega_c}v_x'$ が従い、初期条件から
    $
      \begin{cases}
      v_x(t)=v_{x0}\cos(\omega_c t)+v_{y0}\sin(\omega_c t),\\
      v_y(t)=-v_{x0}\sin(\omega_c t)+v_{y0}\cos(\omega_c t)
      \end{cases}
    $
    が得られる。  $\square$
  <div class="theory-common-box">命題 5：直交成分の速さ $v_\perp = \sqrt{v_x^2 + v_y^2}$ は時間によらず一定</div>
  <div class="proof-box">証明</div>
  $v_\perp^2$ を時間で微分すると
  $
    (v_x^2 + v_y^2)' = 2(v_x v_x' + v_y v_y') \cdots (1)
  $<br>
  命題2の運動方程式より
  $
    v_x' = \frac{qB}{m} v_y,\quad v_y' = -\frac{qB}{m} v_x.
  $<br>
  これを代入すると
  $
    v_x v_x' + v_y v_y' = v_x \frac{qB}{m} v_y + v_y (-\frac{qB}{m} v_x) = 0.
  $<br>
  よって$(1)$より、
  $
    (v_x^2 + v_y^2)' = 0
  $
  となり、直交成分の速さ $v_\perp = \sqrt{v_x^2 + v_y^2}$ は時間によらず一定である。  
  $\square$
</div>

  <div class="theory-common-box">命題 6：平行成分$v_z$は等速</div>
  <div class="proof-box">証明</div>
  $m v_z'=0$ より $v_z=v_{z0}$。積分すると
    $
      z(t)=z_0+v_{z0}t
    $
    である。よって示された。  $\square$

  <div class="theory-common-box">命題 7：物体の時刻$t$における$x,y$座標は$\ \ \ $
    $
      \begin{cases}
       \displaystyle x(t)=x_0+\tfrac{v_{x0}}{\omega_c}\sin(\omega_c t)+\tfrac{v_{y0}}{\omega_c}(1-\cos(\omega_c t))\\
        \displaystyle y(t)=y_0+\tfrac{v_{y0}}{\omega_c}\sin(\omega_c t)-\tfrac{v_{x0}}{\omega_c}(1-\cos(\omega_c t))
      \end{cases}
    \ \ \ $　となる</div>
  <div class="proof-box">証明</div>
    命題4より、直交成分の速度は
    $$\begin{aligned}
      &\begin{cases}
      v_x(t)=v_{x0}\cos(\omega_c t)+v_{y0}\sin(\omega_c t) \\
      v_y(t)=-v_{x0}\sin(\omega_c t)+v_{y0}\cos(\omega_c t)
    \end{cases}
      \end{aligned}$$
    と表される。<br>まず $x$ 成分は
    $$\begin{aligned}
      x(t)-x_0 &= \int_0^t v_x(s) ds \\
                &= \frac{v_{x0}}{\omega_c} \sin(\omega_c t)
                  + \frac{v_{y0}}{\omega_c}(1-\cos(\omega_c t)),
    \end{aligned}$$
    よって
    $
      x(t) = x_0 + \frac{v_{x0}}{\omega_c} \sin(\omega_c t)
                   + \frac{v_{y0}}{\omega_c}(1-\cos(\omega_c t)).
    $<br>
    $y$ 成分も同様に
    $
      y(t) = y_0 + \frac{v_{y0}}{\omega_c} \sin(\omega_c t)
                   - \frac{v_{x0}}{\omega_c}(1-\cos(\omega_c t)).
    $    <br>（注）$\omega_c=0$（磁場 $B=0$）の場合は極限を取り、等速直線運動に一致する。 $\square$
  <div class="theory-common-box">命題 8：物体のxyについての運動は、
  $$\begin{aligned}
  &半径：R = \dfrac{v_\perp}{|\omega_c|} \\
  &中心：(X_c,Y_c) = \bigl(x_0 + \tfrac{v_{y0}}{\omega_c},\, y_0 - \tfrac{v_{x0}}{\omega_c}\bigr) \\
  &周期：T = \dfrac{2\pi}{|\omega_c|} 
  \end{aligned}$$
  の等速円運動である</div>
  <div class="proof-box">証明</div>
  命題7より直交成分の位置は
    $
    \begin{cases}
    x(t)=x_0+\frac{v_{x0}}{\omega_c}\sin(\omega_c t)+\frac{v_{y0}}{\omega_c}(1-\cos(\omega_c t))\\
    y(t)=y_0+\frac{v_{y0}}{\omega_c}\sin(\omega_c t)-\frac{v_{x0}}{\omega_c}(1-\cos(\omega_c t))
    \end{cases}
    $
  と表される。ここで
  $
    X_c = x_0 + \frac{v_{y0}}{\omega_c},\quad Y_c = y_0 - \frac{v_{x0}}{\omega_c}
  $
  と定義すると
    $$\begin{aligned}
    \begin{cases}
    x(t) - X_c = \frac{v_{x0}}{\omega_c} \sin(\omega_c t) - \frac{v_{y0}}{\omega_c} \cos(\omega_c t) \\
    y(t)-Y_c = \frac{v_{y0}}{\omega_c} \sin(\omega_c t) + \frac{v_{x0}}{\omega_c} \cos(\omega_c t)
    \end{cases}
    \end{aligned}$$
  となる。<br>よって
    $
    (x-X_c)^2 + (y-Y_c)^2 = \frac{v_{x0}^2+v_{y0}^2}{\omega_c^2}= \frac{v_\perp^2}{\omega_c^2}
    $
  が成り立つ。<br>
  したがって直交成分は$\frac{v_\perp}{|\omega_c|} $半径の円運動をしていることがわかる。<br>
  角速度の大きさは $|\omega_c|$、周期は $\displaystyle T = \frac {2\pi}{|\omega_c|}$。
  $\square$

  <div class="theory-common-box">命題 9：物体は螺旋運動をする</div>
  <div class="proof-box">証明</div>
    命題8で磁場垂直方向については等速円運動、命題6で磁場平行方向には等速直線運動が示されたので、その合成は螺旋運動である。  $\square$
  <div class="theory-common-box">命題 10：螺旋運動のピッチ（螺旋における1回転での$z$方向進み量）は
    $ \displaystyle
      \frac{2\pi v_{z0}}{|\omega_c|}
    $
    である</div>
  <div class="proof-box">証明</div>
    1回転の周期は $\displaystyle T = \frac {2\pi}{|\omega_c|}$。<br>
    その間に進む距離は $v_{z0}T$ なので上式が得られる。  $\square$
""",
  latexContentEn: r"""
  <div style="text-align:center; margin:1em 0;">
      <img src="assets/electroMagnetismTheory/lorentz.png"
           alt="data"
           style="max-width:70%; height:auto;" />
    </div>
  <div class="theory-common-box">Definition of symbols</div>
  <ul>
    <li>$m$: mass，$q$: charge</li>
    <li>$\vec{B}=(0,0,B)$: uniform magnetic field</li>
    <li>$\vec{x}=(x,y,z)$: position vector (components)</li>
    <li>$\vec{v}=(v_x,v_y,v_z)$: velocity vector (components)</li>
    <li>$v=\sqrt{v_x^2+v_y^2+v_z^2}$: speed</li>
    <li>$v_\parallel=v_z$: velocity component parallel to the field</li>
    <li>$v_\perp=\sqrt{v_x^2+v_y^2}$: speed of the component perpendicular to $\vec{B}$</li>
    <li>$x_0,y_0,z_0$: initial position (components)</li>
    <li>$v_{x0},v_{z0},v_{z0}$: initial velocity (components)</li>
    <li>$\omega_c=\frac{qB}{m}$: angular frequency</li>
  </ul>

  <div class="theory-common-box">Proposition 1 (components of the Lorentz force): the force components on charge $q$ are
    $
      \vec{F}=(F_x,F_y,F_z)=(qBv_y,\,-qBv_x,\,0)
    $
     </div>
  <div class="proof-box">Proof</div>
    Let $\theta$ be the angle between $\vec{v}$ and $\vec{B}$. From the inner product,
    $
      \displaystyle \cos\theta = \frac{\vec{v}\cdot\vec{B}}{|\vec{v}||\vec{B}|} = \frac{v_z}{v}, \quad
      \displaystyle \sin\theta = \frac{\sqrt{v_x^2+v_y^2}}{v}.
    $<br>
    The magnitude of the Lorentz force is
    $
      |\vec{F}| = |q|vB\sin\theta = |q|B\sqrt{v_x^2+v_y^2}.
    $
    <br>Also $\vec{F}\perp\vec{v}$, so
    $
      v_x F_x + v_y F_y = 0.
    $<br>
    Hence $F_x = k v_y, \; F_y = -k v_x, \; F_z=0$ .  <br>
    From the magnitude condition, $k^2 = (qB)^2$. For positive charge, $k=qB$ so that
    $
      \vec{F} = (qBv_y, -qBv_x, 0).
    $
    $\square$
  </div>

  <div class="theory-common-box">Proposition 2: equation of motion (components)</div>
    $m\vec{a}=m\vec{v}'=\vec{F}$ (equation of motion) and Proposition 1 give
  $$
    \begin{cases}
      m v_x' = qB v_y, \\
      m v_y' = -qB v_x, \\
      m v_z' = 0
    \end{cases}
  $$
  <div class="theory-common-box">Proposition 3: the speed $v=|\vec{v}|$ is constant in time</div>
  <div class="proof-box">Proof</div>
    Power $P=\vec{F}\cdot\vec{v}=0$(by orthogonality).   
    Therefore
    $$\begin{aligned}
      \displaystyle \left(\frac{1}{2} m v^2\right)'  &= 0 \\[6pt]
      \Leftrightarrow v v' &= 0 \\[6pt]
      \Leftrightarrow v = 0 &\text{or} v' = 0
    \end{aligned}$$
If $v=0$ the claim is trivial; if $v\neq 0$ then $v'=0$, so the speed is constant.
(the magnetic field does no work)  $\square$

  <div class="theory-common-box">Proposition 4: the velocity components $v_x,v_y$ are
    $
    \begin{cases}
      v_x(t)=v_{x0}\cos(\omega_c t)+v_{y0}\sin(\omega_c t)\\[6pt]
      v_y(t)=-v_{x0}\sin(\omega_c t)+v_{y0}\cos(\omega_c t)
    \end{cases}
    $
    　 </div>
  <div class="proof-box">Proof</div>
    $\omega_c=\frac{qB}{m}$ Then
    $
      v_x' = \omega_c v_y,\quad v_y' = -\omega_c v_x
    $<br>
    Hence
    $
      v_x''=-\omega_c^2 v_x,\quad v_y''=-\omega_c^2 v_y
    $
     . <br>
    $v_x$ obeys the SHM ODE, so
    $
      v_x=C_1\cos(\omega_c t)+C_2\sin(\omega_c t)
    $
     . <br>From Proposition 2, $v_y=\frac{1}{\omega_c}v_x'$ and with initial conditions
    $
      \begin{cases}
      v_x(t)=v_{x0}\cos(\omega_c t)+v_{y0}\sin(\omega_c t),\\
      v_y(t)=-v_{x0}\sin(\omega_c t)+v_{y0}\cos(\omega_c t)
      \end{cases}
    $
    .  $\square$
  <div class="theory-common-box">Proposition 5: the perpendicular-component speed $v_\perp = \sqrt{v_x^2 + v_y^2}$ is constant in time</div>
  <div class="proof-box">Proof</div>
  $v_\perp^2$ Differentiating in time,
  $
    (v_x^2 + v_y^2)' = 2(v_x v_x' + v_y v_y') \cdots (1)
  $<br>
  From the equations of Proposition 2,
  $
    v_x' = \frac{qB}{m} v_y,\quad v_y' = -\frac{qB}{m} v_x.
  $<br>
  Substituting,
  $
    v_x v_x' + v_y v_y' = v_x \frac{qB}{m} v_y + v_y (-\frac{qB}{m} v_x) = 0.
  $<br>
  Hence$(1)$gives, 
  $
    (v_x^2 + v_y^2)' = 0
  $
  , so the perpendicular-component speed $v_\perp = \sqrt{v_x^2 + v_y^2}$ is constant in time.  
  $\square$
</div>

  <div class="theory-common-box">Proposition 6: the parallel component $v_z$ is uniform</div>
  <div class="proof-box">Proof</div>
  $m v_z'=0$ gives $v_z=v_{z0}$. Integrating,
    $
      z(t)=z_0+v_{z0}t
    $
     . Hence the claim follows.  $\square$

  <div class="theory-common-box">Proposition 7: the $x,y$ coordinates at time $t$ are$\ \ \ $
    $
      \begin{cases}
       \displaystyle x(t)=x_0+\frac{v_{x0}}{\omega_c}\sin(\omega_c t)+\frac{v_{y0}}{\omega_c}(1-\cos(\omega_c t))\\
        \displaystyle y(t)=y_0+\frac{v_{y0}}{\omega_c}\sin(\omega_c t)-\frac{v_{x0}}{\omega_c}(1-\cos(\omega_c t))
      \end{cases}
    \ \ \ $　 </div>
  <div class="proof-box">Proof</div>
    By Proposition 4, the perpendicular velocity is
    $$\begin{aligned}
      &\begin{cases}
      v_x(t)=v_{x0}\cos(\omega_c t)+v_{y0}\sin(\omega_c t) \\
      v_y(t)=-v_{x0}\sin(\omega_c t)+v_{y0}\cos(\omega_c t)
    \end{cases}
      \end{aligned}$$
    .<br>For the $x$ component,
    $$\begin{aligned}
      x(t)-x_0 &= \int_0^t v_x(s) ds \\
                &= \frac{v_{x0}}{\omega_c} \sin(\omega_c t)
                  + \frac{v_{y0}}{\omega_c}(1-\cos(\omega_c t)),
    \end{aligned}$$
    Hence
    $
      x(t) = x_0 + \frac{v_{x0}}{\omega_c} \sin(\omega_c t)
                   + \frac{v_{y0}}{\omega_c}(1-\cos(\omega_c t)).
    $<br>
    Similarly for the $y$-component,
    $
      y(t) = y_0 + \frac{v_{y0}}{\omega_c} \sin(\omega_c t)
                   - \frac{v_{x0}}{\omega_c}(1-\cos(\omega_c t)).
    $    <br>(Note) If $\omega_c=0$ ($B=0$), take the limit to recover uniform straight-line motion. $\square$
  <div class="theory-common-box">Proposition 8: the motion in the $xy$-plane is uniform circular motion with
  $$\begin{aligned}
  &radius: R = \frac{v_\perp}{|\omega_c|} \\
  &center: (X_c,Y_c) = \bigl(x_0 + \frac{v_{y0}}{\omega_c},\, y_0 - \frac{v_{x0}}{\omega_c}\bigr) \\
  &period: T = \frac{2\pi}{|\omega_c|} 
  \end{aligned}$$
  uniform circular motion </div>
  <div class="proof-box">Proof</div>
  By Proposition 7, the perpendicular position is
    $
    \begin{cases}
    x(t)=x_0+\frac{v_{x0}}{\omega_c}\sin(\omega_c t)+\frac{v_{y0}}{\omega_c}(1-\cos(\omega_c t))\\
    y(t)=y_0+\frac{v_{y0}}{\omega_c}\sin(\omega_c t)-\frac{v_{x0}}{\omega_c}(1-\cos(\omega_c t))
    \end{cases}
    $
  . Here
  $
    X_c = x_0 + \frac{v_{y0}}{\omega_c},\quad Y_c = y_0 - \frac{v_{x0}}{\omega_c}
  $
  Defining
    $$\begin{aligned}
    \begin{cases}
    x(t) - X_c = \frac{v_{x0}}{\omega_c} \sin(\omega_c t) - \frac{v_{y0}}{\omega_c} \cos(\omega_c t) \\
    y(t)-Y_c = \frac{v_{y0}}{\omega_c} \sin(\omega_c t) + \frac{v_{x0}}{\omega_c} \cos(\omega_c t)
    \end{cases}
    \end{aligned}$$
   . <br>Hence
    $
    (x-X_c)^2 + (y-Y_c)^2 = \frac{v_{x0}^2+v_{y0}^2}{\omega_c^2}= \frac{v_\perp^2}{\omega_c^2}
    $
  .<br>
  Therefore the perpendicular motion is circular with radius $\frac{v_\perp}{|\omega_c|}$.<br>
  The angular speed is $|\omega_c|$ and the period is $\displaystyle T = \frac{2\pi}{|\omega_c|}$.
  $\square$

  <div class="theory-common-box">Proposition 9: the particle moves in a helix</div>
  <div class="proof-box">Proof</div>
    Proposition 8 shows uniform circular motion perpendicular to $\vec{B}$, and Proposition 6 shows uniform rectilinear motion parallel to $\vec{B}$; their composition is helical motion.  $\square$
  <div class="theory-common-box">Proposition 10: the pitch of the helix (advance in $z$ per turn) is
    $ \displaystyle
      \frac{2\pi v_{z0}}{|\omega_c|}
    $
     </div>
  <div class="proof-box">Proof</div>
    The period of one revolution is $\displaystyle T = \frac{2\pi}{|\omega_c|}$.<br>
    The distance advanced is $v_{z0}T$, which gives the formula above.  $\square$
""",
);
