import '../../model.dart';

final rcCircuitTheory = TheoryTopic(
  title: 'RC回路微分方程式の解(充電)',
  titleEn: 'Solution of the RC circuit differential equation (charging)',
  videoURL: "oVY3-umLN14",
  videoURLEn: "Z9iSewjr7DA",
  imageAsset: 'assets/mindMap/forTopics/rcCircuit.png', // 実際の画像パス
  latexContent: r"""

<div class="theory-common-box">定義(RC回路)</div>
・抵抗 ${R}$とコンデンサー ${C}$ を直列につないだ回路を RC 回路と呼ぶ。<br>
・RC 回路は電荷の蓄積と放出に伴う時間的な電圧変化を記述する回路である。<br>
  <div style="text-align:center; margin:1em 0;">
    <img src="assets/electroMagnetismTheory/rcCircuit.png"
          alt=""
          style="max-width:75%; height:auto;" />
  </div>
<div class="theory-common-box">記号と符号規約</div>
・${V_0}$：電源電圧<br>
・${V_c(t)}$：コンデンサー電圧(コンデンサーの正板と負板の電位差)<br>
・${I(t)}$：回路を流れる電流(正方向は電源から抵抗を通ってコンデンサーに向かう向きと定義)<br>
・${Q(t)}$：コンデンサーの電荷。正板に蓄えられる電荷量を意味し，${Q(t)=C\,V_c(t)}$ の関係を満たす(符号は上記の向きに合わせる)<br>

<div class="theory-common-box">基本方程式(キルヒホッフ)</div>
・キルヒホッフの法則により，電源電圧は抵抗での電圧降下とコンデンサー電圧の和に等しい：
$${\displaystyle R\,I(t) + V_c(t)=V_0}$$
・コンデンサーに流れる電流は電荷の時間変化で表される：
$${\displaystyle I(t)= Q'(t)=C\,V_c'(t)}$$
これらを組み合わせると基礎的な微分方程式が得られる
$${\displaystyle RC\,V_c'(t) + V_c(t) = V_0}$$


<div class="theory-common-box">命題 1(基礎方程式の導出)：コンデンサー極板間電圧の時間発展は次の微分方程式で記述される：
${\displaystyle RC\,V_c'(t) + V_c(t) = V_0.}$
</div>

<div class="proof-box">証明</div><p>
電源から抵抗を経てコンデンサーへ流れる電流が ${\displaystyle I(t)}$ なので、オームの法則より抵抗に生じる電圧降下は ${\displaystyle R\,I(t)}$ であり，回路を一周すると総和が電源電圧に等しいため
${\displaystyle R\,I(t)+V_c(t)=V_0}$
である。<br>
また、コンデンサーに流れる電流は電荷の時間変化に等しく，${\displaystyle I(t)=Q'(t)}$，かつ ${\displaystyle Q=C\,V_c}$ であるから
$${\displaystyle I(t)=C\,V_c'(t)}$$
これを先の式に代入して整理すると
\begin{aligned}
& R\bigl(C\,V_c'(t)\bigr)+V_c(t)=V_0\\[6pt]
\Leftrightarrow \ \  & RC\,V_c'(t)+V_c(t)=V_0
\end{aligned}
が得られる。　Q.E.D

</p><div class="theory-common-box">命題 2(特解と斉次形への変換)：非斉次方程式
微分方程式${\displaystyle RC\,V_c'(t)+V_c(t)=V_0}$
の定数解は ${\displaystyle V_p=V_0}$ である。
</div>

<div class="proof-box">証明</div><p>
微分方程式${\displaystyle RC\,V_c'(t)+V_c(t)=V_0}$の定数関数解 ${V_p}$を探す。${V_p' = 0}$ であるから，元の方程式に代入すると
$${RC\cdot 0 + V_p = V_0}$$
が得られる。したがって ${V_p=V_0}$　Q.E.D


</p><div class="theory-common-box">命題 3(特解と斉次形への変換)：非斉次方程式
${\displaystyle RC\,V_c'(t)+V_c(t)=V_0}$
ならば，$u(t):=V_c(t)-V_p$ は、下記の微分方程式を満たす。
$$RC\,u'(t) + u(t) = 0$$
</div>

<div class="proof-box">証明</div><p>
命題2より、定数$V_0$は微分方程式${\displaystyle RC\,V_c'(t)+V_c(t)=V_0}$
の解であるから、下式が成り立つ。
$$
\displaystyle RC\,V_0'+ V_0=V_0
$$
この式を微分方程式から引き算すると、
\begin{aligned}
&RC\,(V_c'(t)-V_0')+V_c(t)-V_0=V_0-V_0\\[6pt]
\Leftrightarrow \ & RC\,(V_c(t)-V_0)'+V_c(t)-V_0=0
\end{aligned}
ここで，${u(t):=V_c(t)-V_0}$ とおくと，
$${RC\,u'(t) + u(t) = 0}$$
が得られる。　Q.E.D

</p><div class="theory-common-box">命題 4(斉次方程式の解：指数関数解)：斉次方程式${\displaystyle RC\,u'(t)+u(t)=0}$の解は、下記で表される。
$${\displaystyle u(t)=u(0)\,e^{-\frac{t}{RC}}}$$</div>

<div class="proof-box">証明</div><p>
上の命題の式の両辺$をRC\cdot u(t)$で割って、変数分離すると、下式を得る。
$${\frac{1}{u(t)}u'(t)=-\frac{1}{RC}}$$
これを時刻 $t'$ を変数として $0$ から $t$ まで積分すると， $${\int_{0}^{t}\frac{1}{u(t')}\frac{du}{dt'}\,dt'=\int_{0}^{t}-\frac{1}{RC}\,dt'}$$ となる。<br> 
<div class="paragraph-box">右辺</div><br> 
定数の定積分により${\displaystyle -\frac{t}{RC}}$ となる。<br> 
<div class="paragraph-box">左辺</div><br> 
置換 $s=u(t')$ により \begin{aligned} \int_{u(0)}^{u(t)}\frac{1}{s}\,ds &=\ln|u(t)|-\ln|u(0)|\\[6pt] &=\ln\!\Biggl(\frac{|u(t)|}{|u(0)|}\Biggr) \end{aligned} となる。<br><br> 
以上より、右辺=左辺なので、$${\ln\!\Biggl(\frac{|u(t)|}{|u(0)|}\Biggr)=-\frac{t}{RC}}$$ 
ここで両辺の指数を取って下式が得られる。　
$${u(t)=u(0)\,e^{-\frac {t} {RC}}}$$　Q.E.D

</p><div class="theory-common-box">命題 5(充電過程の解)：初期条件 ${\displaystyle V_c(0)=0}$ のもとで，非斉次方程式
${\displaystyle RC\,V_c'(t)+V_c(t)=V_0}$
の解は下記となる。
$${\displaystyle V_c(t)=V_0\bigl(1-e^{-\frac{t}{RC}}\bigr)}$$
</div>

<div class="proof-box">証明</div><p>
命題 2 より ${\displaystyle V_c(t)=V_p+u(t)}$，${\displaystyle V_p=V_0}$，命題 3 より ${\displaystyle u(t)=u(0)e^{-\frac{t}{RC}}}$ である。初期条件から
${\displaystyle u(0)=V_c(0)-V_p=0-V_0=-V_0}$
であるため
${\displaystyle V_c(t)=V_0 + \bigl(-V_0\bigr)e^{-\frac{t}{RC}} = V_0\bigl(1-e^{-\frac{t}{RC}}\bigr)}$
となる。　Q.E.D

</p><div class="theory-common-box">命題 6(電流式と初期電流)：充電過程における回路電流は下記で表される。
$${\displaystyle I(t)=\frac{V_0}{R}\,e^{-\frac{t}{RC}}}$$
※特に、初期電流は${\displaystyle I(0)=\frac{V_0}{R}}$である。
</div>

<div class="proof-box">証明</div><p>
電流は ${\displaystyle I(t)=C\,V_c'(t)}$ である。命題 5 の ${\displaystyle V_c(t)=V_0(1-e^{-\frac{t}{RC}})}$ を微分すると
${\displaystyle V_c'(t)=V_0\cdot\frac{1}{RC}e^{-\frac{t}{RC}}}$
であるから
${\displaystyle I(t)=C\cdot V_0\cdot\frac{1}{RC}e^{-\frac{t}{RC}}=\frac{V_0}{R}e^{-\frac{t}{RC}}}$
となる。<br>
※特に$t=0$ を代入すれば ${\displaystyle I(0)=\frac{V_0}{R}}$ となる。　Q.E.D

</p><div class="theory-common-box">補足：時定数</div>
時定数 ${\displaystyle \tau=RC}$ は時間の尺度を与え，充電・放電の指数的変化の速さを決定する。特に ${\displaystyle t=\tau}$ において
${\displaystyle V_c(\tau)=V_0(1-e^{-1})\fallingdotseq 0.632\,V_0}$
が成立する。

""",
  latexContentEn: r"""

<div class="theory-common-box">Definition (RC circuit)</div>
•A circuit with a resistor ${R}$ and a capacitor ${C}$ in series is called an RC circuit.<br>
•An RC circuit describes the time-dependent voltage change associated with charge storage and release.<br>
  <div style="text-align:center; margin:1em 0;">
    <img src="assets/electroMagnetismTheory/rcCircuit.png"
          alt=""
          style="max-width:75%; height:auto;" />
  </div>
<div class="theory-common-box">Symbols and sign convention</div>
•${V_0}$: source voltage<br>
•${V_c(t)}$: capacitor voltage (potential difference between the positive and negative plates)<br>
•${I(t)}$: current in the circuit (positive direction defined from the source through the resistor toward the capacitor)<br>
•${Q(t)}$: capacitor charge (charge on the positive plate), satisfying ${Q(t)=C\,V_c(t)}$ (sign consistent with the above orientation)<br>

<div class="theory-common-box">Basic equation (Kirchhoff)</div>
•By Kirchhoff's law, the source voltage equals the sum of the resistor drop and the capacitor voltage:
$${\displaystyle R\,I(t) + V_c(t)=V_0}$$
•The current through the capacitor is the rate of change of charge:
$${\displaystyle I(t)= Q'(t)=C\,V_c'(t)}$$
Combining these yields the basic differential equation
$${\displaystyle RC\,V_c'(t) + V_c(t) = V_0}$$


<div class="theory-common-box">Proposition 1 (derivation of the basic equation): The capacitor voltage obeys
${\displaystyle RC\,V_c'(t) + V_c(t) = V_0.}$
</div>

<div class="proof-box">Proof</div><p>
With current ${\displaystyle I(t)}$ from the source through the resistor to the capacitor, Ohm's law gives a drop ${\displaystyle R\,I(t)}$, and going around the loop,
${\displaystyle R\,I(t)+V_c(t)=V_0}$
.<br>
Also ${\displaystyle I(t)=Q'(t)}$ and ${\displaystyle Q=C\,V_c}$, so
$${\displaystyle I(t)=C\,V_c'(t)}$$
. Substituting and rearranging,
\begin{aligned}
& R\bigl(C\,V_c'(t)\bigr)+V_c(t)=V_0\\[6pt]
\Leftrightarrow \ \  & RC\,V_c'(t)+V_c(t)=V_0
\end{aligned}
.　Q.E.D

</p><div class="theory-common-box">Proposition 2 (particular solution): For the nonhomogeneous equation
${\displaystyle RC\,V_c'(t)+V_c(t)=V_0}$,
the constant solution is ${\displaystyle V_p=V_0}$.
</div>

<div class="proof-box">Proof</div><p>
Seek a constant solution ${V_p}$ of ${\displaystyle RC\,V_c'(t)+V_c(t)=V_0}$. Since ${V_p' = 0}$,
$${RC\cdot 0 + V_p = V_0}$$
, hence ${V_p=V_0}$.　Q.E.D


</p><div class="theory-common-box">Proposition 3 (reduction to homogeneous form): If
${\displaystyle RC\,V_c'(t)+V_c(t)=V_0}$,
then $u(t):=V_c(t)-V_p$ satisfies
$$RC\,u'(t) + u(t) = 0$$
</div>

<div class="proof-box">Proof</div><p>
By Proposition 2, the constant $V_0$ solves ${\displaystyle RC\,V_c'(t)+V_c(t)=V_0}$, so
$$
\displaystyle RC\,V_0'+ V_0=V_0
$$
. Subtracting from the differential equation,
\begin{aligned}
&RC\,(V_c'(t)-V_0')+V_c(t)-V_0=V_0-V_0\\[6pt]
\Leftrightarrow \ & RC\,(V_c(t)-V_0)'+V_c(t)-V_0=0
\end{aligned}
. Setting ${u(t):=V_c(t)-V_0}$,
$${RC\,u'(t) + u(t) = 0}$$
.　Q.E.D

</p><div class="theory-common-box">Proposition 4 (homogeneous solution): The solution of ${\displaystyle RC\,u'(t)+u(t)=0}$ is
$${\displaystyle u(t)=u(0)\,e^{-\frac{t}{RC}}}$$</div>

<div class="proof-box">Proof</div><p>
Separating variables,
$${\displaystyle\frac{1}{u(t)}u'(t)=-\frac{1}{RC}}$$
. Integrating from $0$ to $t$,
$${\displaystyle\int_{0}^{t}\frac{1}{u(t')}\frac{du}{dt'}\,dt'=\int_{0}^{t}-\frac{1}{RC}\,dt'}$$
.<br> 
<div class="paragraph-box">Right-hand side</div><br> 
${\displaystyle -\frac{t}{RC}}$.<br> 
<div class="paragraph-box">Left-hand side</div><br> 
With $s=u(t')$, \begin{aligned} \int_{u(0)}^{u(t)}\frac{1}{s}\,ds &=\ln|u(t)|-\ln|u(0)|\\[6pt] &=\ln\!\Biggl(\frac{|u(t)|}{|u(0)|}\Biggr) \end{aligned}.<br><br> 
Hence $${\displaystyle\ln\!\Biggl(\frac{|u(t)|}{|u(0)|}\Biggr)=-\frac{t}{RC}}$$ 
and $${\displaystyle u(t)=u(0)\,e^{-\frac {t} {RC}}}$$.　Q.E.D

</p><div class="theory-common-box">Proposition 5 (charging solution): Under ${\displaystyle V_c(0)=0}$, the solution of
${\displaystyle RC\,V_c'(t)+V_c(t)=V_0}$
is
$${\displaystyle V_c(t)=V_0\bigl(1-e^{-\frac{t}{RC}}\bigr)}$$
</div>

<div class="proof-box">Proof</div><p>
By Propositions 2–4, ${\displaystyle V_c(t)=V_p+u(t)}$ with ${\displaystyle V_p=V_0}$ and ${\displaystyle u(t)=u(0)e^{-\frac{t}{RC}}}$. The initial condition gives
${\displaystyle u(0)=V_c(0)-V_p=0-V_0=-V_0}$,
so
${\displaystyle V_c(t)=V_0 + \bigl(-V_0\bigr)e^{-\frac{t}{RC}} = V_0\bigl(1-e^{-\frac{t}{RC}}\bigr)}$
.　Q.E.D

</p><div class="theory-common-box">Proposition 6 (current and initial current): During charging,
$${\displaystyle I(t)=\frac{V_0}{R}\,e^{-\frac{t}{RC}}}$$
※ In particular ${\displaystyle I(0)=\frac{V_0}{R}}$.
</div>

<div class="proof-box">Proof</div><p>
${\displaystyle I(t)=C\,V_c'(t)}$. Differentiating Proposition 5,
${\displaystyle V_c'(t)=V_0\cdot\frac{1}{RC}e^{-\frac{t}{RC}}}$,
so
${\displaystyle I(t)=C\cdot V_0\cdot\frac{1}{RC}e^{-\frac{t}{RC}}=\frac{V_0}{R}e^{-\frac{t}{RC}}}$
.<br>
At $t=0$, ${\displaystyle I(0)=\frac{V_0}{R}}$.　Q.E.D

</p><div class="theory-common-box">Remark: time constant</div>
The time constant ${\displaystyle \tau=RC}$ sets the time scale of exponential charging/discharging. At ${\displaystyle t=\tau}$,
${\displaystyle V_c(\tau)=V_0(1-e^{-1})\fallingdotseq 0.632\,V_0}$.

""",
);

// 放電の時
// 図を入れる
// いいのを1個作ってそれ使ってLCRL LRCを作る
// 常微分方程式の解の一意性調べる