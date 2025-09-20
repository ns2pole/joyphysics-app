import '../../model.dart';

final rcCircuitDischarge = TheoryTopic(
  title: 'RC回路微分方程式の解(放電)',
  imageAsset: 'assets/mindMap/forTopics/rcCircuitDischarge.png',
  latexContent: r"""

<div class="theory-common-box">設定,記号の定義</div>
  <div style="text-align:center; margin:1em 0;">
    <img src="assets/electroMagnetismTheory/rcCircuitDischarge.png"
         alt=""
         style="max-width:75%; height:auto;" />
  </div>
・$C$：コンデンサの電気容量<br>
・$R$：電気抵抗の大きさ<br>
・${V_0}$：放電開始直前のコンデンサー電圧（初期電圧）${\displaystyle V_c(0)=V_0}$<br>
・${Q_0}$：放電開始直前のコンデンサー充電電気量。${\displaystyle Q_0=Q(0)=CV_0}$<br>
・${V_c(t)}$：コンデンサーの電圧（正板と負板の電位差）。<br>
・${I(t)}$：回路を流れる電流。符号は「抵抗からコンデンサーに向かう方向（充電時と同じ向き）」を正と定義する（この符号規約により放電では${I(t)}$は負となる）。<br>
・${Q(t)}$：コンデンサーに蓄えられた電荷（正板の電荷）${\ \displaystyle Q(t)=C\,V_c(t)}$ が成り立つ（符号は上記の向きに合わせる）<br>

<div class="theory-common-box">命題 1（基礎方程式の導出）：コンデンサーに蓄えられた電荷の時間発展は次の微分方程式で記述される：
$$\begin{aligned}
Q'(t) = -\frac{Q(t)}{RC}
\end{aligned}$$
</div>

<div class="proof-box">証明</div><p>
回路を一周して抵抗とコンデンサーの両端電圧の和を取ると電源が無いため
$$\begin{aligned}
R\,I(t) + V_c(t) = 0
\end{aligned}$$
が成り立つ。コンデンサーの極板間電圧$V_c(t)$はコンデンサーの極板に蓄えられた電荷$Q(t)$を用いて、
$$ \displaystyle V_c(t)=\dfrac{Q(t)}{C}$$ なので、上式より
$$\begin{aligned}
R\,I(t) + \dfrac{Q(t)}{C} = 0
\end{aligned}$$
ここで、電流と電荷の関係から、$Q'(t)=I(t)$なので、
$$\begin{aligned}
&\ R\,Q'(t) + \dfrac{Q(t)}{C} = 0\\[6pt]
\Leftrightarrow &\ Q'(t) = -\frac{Q(t)}{RC}
\end{aligned}$$
　Q.E.D
</p>

<div class="theory-common-box">命題 2（放電過程の解）：初期条件 ${\displaystyle Q(0)=Q_0=C V_0}$ のもとで，微分方程式
$\displaystyle Q'(t) = -\frac{Q(t)}{RC}$の解は
$ \displaystyle Q(t)=Q_0\,e^{-\frac{t}{RC}}$となる。<br>
また、コンデンサー極板間電圧は \( \displaystyle V_c(t)=\frac{Q(t)}{C}\) より
$\displaystyle V_c(t)= \displaystyle V_0\,e^{-\frac{t}{RC}}$となる。
</div>
<div class="proof-box">証明</div><p>
一次線形斉次微分方程式 \( \displaystyle Q'(t) + \dfrac{1}{RC}Q(t)=0\) を解くと，初期条件 \( \displaystyle Q(0)=Q_0\) のもとで
$$\begin{aligned}
Q(t)=Q_0 e^{-\frac{t}{RC}}
\end{aligned}$$
が得られる。これを \( \displaystyle V_c(t)=\frac{Q(t)}{C}\) に代入すれば \( \displaystyle V_c(t)=V_0 e^{-\frac{t}{RC}}\) が得られる。Q.E.D
</p>

<div class="theory-common-box">命題 3（電流式と初期電流）：放電過程における回路電流は次で与えられる：
$$\begin{aligned}
I(t)= -\frac{V_0}{R}\,e^{-\frac{t}{RC}}
\end{aligned}$$
※ 特に初期電流は ${\displaystyle I(0)=-\frac{V_0}{R}}$ であり，符号は定義した正方向に対して逆向きであることを意味する。
</div>

<div class="proof-box">証明</div><p>
命題2 より \( \displaystyle Q(t)=Q_0 e^{-\frac{t}{RC}}\) であるからその時間微分は
$\displaystyle Q'(t) = -\frac{Q_0}{RC} e^{-\frac{t}{RC}}.$
したがって
$$\begin{aligned}
I(t) = -\frac{Q_0}{RC} e^{-\frac{t}{RC}} = -\frac{V_0}{R} e^{-\frac{t}{RC}}
\end{aligned}$$
となる．　Q.E.D
</p>

<div class="theory-common-box">命題 4（常微分方程式の解の一意性）
一階線形常微分方程式
$$\begin{aligned}
Q'(t) = -\frac{Q(t)}{RC}
\end{aligned}$$
について、任意の初期条件 ${\displaystyle Q(0)=Q_0}$ に対し解が一意に存在する。</div>

<div class="proof-box">証明</div><p>
<div class="paragraph-box">存在性</div><br>
解の存在については、上の命題ですでに示してある。<br>
<div class="paragraph-box">一意性</div><br>
同じ初期条件を満たす二つの解 ${\displaystyle Q_1(t)}$ と ${\displaystyle Q_2(t)}$ があると仮定する。差 ${\displaystyle w(t):=Q_1(t)-Q_2(t)}$ を取ると，両者が元の方程式を満たすことから
$$\begin{aligned}
w'(t) = -\frac{1}{RC} w(t)
\end{aligned}$$
かつ初期条件により ${\displaystyle w(0)=0}$ である。上と同様に解法を行うと \( \displaystyle w(t)=w(0)e^{-\frac{t}{RC}}=0\) となるため，${\displaystyle Q_1(t)=Q_2(t)}$ が従い解は一意である。　Q.E.D
</p>

<div class="theory-common-box">補遺：時定数と物理的意味</div>
時定数 ${\displaystyle \tau=RC}$ は放電の指数減衰の時間尺度を与える。特に ${\displaystyle t=\tau}$ において
$$\begin{aligned}
V_c(\tau) = V_0\,e^{-1} \fallingdotseq 0.368\,V_0
\end{aligned}$$
すなわち初期値の約 $36.8\%$ に減衰する。電流の絶対値も同様の指数減衰を示す。

<div class="theory-common-box">まとめ</div>
・放電ではコンデンサー電荷は指数関数的に減衰し，$Q(t)=Q_0 e^{-\frac{t}{RC}}$ が成り立つ。結果としてコンデンサー電圧は $V_c(t)=V_0 e^{-\frac{t}{RC}}$ となる。<br>
・回路電流は $I(t)=-\dfrac{V_0}{R}e^{-\frac{t}{RC}}$ であり，定義した正方向に対しては負（すなわち実際の流れは逆向き）である。<br>
・時定数 $\tau=RC$ が放電の速さを決める。<br>
・方程式は一階線形常微分方程式であり，任意の初期条件に対して解は一意に存在する。

""",
);
