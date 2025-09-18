import '../../model.dart';

final systemsOfParticles = TheoryTopic(
  title: '質点系の力学の諸命題',
  isNew: false,
  imageAsset: 'assets/mindMap/forTopics/systemsOfParticles.png', // 実際の画像パス
  latexContent: r"""
<div class="theory-common-box">定義（質点系）</div>
<p>2個以上の質点の集合を質点系という。</p>
<div class="theory-common-box">定義（質点系の重心の位置ベクトル）</div>
<p>質点系の重心位置ベクトル $\displaystyle \overrightarrow{R_G}$ を下記で定義する。
$$\begin{aligned}
\displaystyle 
\overrightarrow{R_G} = \frac{1}{M} \sum_{i=1}^n m_i \overrightarrow{r_i}
\end{aligned}$$
</p>
<div class="theory-common-box">
定義（質点系の重心速度,重心加速度）</div>
質点系の重心速度 $\displaystyle \overrightarrow{V_G}$ と重心加速度 $\displaystyle \overrightarrow{A_G}$ を下記でそれぞれ定義する。
$$\begin{aligned}
\begin{cases}
\displaystyle 
\overrightarrow{V_G} &= \overrightarrow{R_G}' 
= \displaystyle \frac{1}{M} \sum_{i=1}^n m_i \overrightarrow{r_i}' \\[6pt]
\displaystyle \overrightarrow{A_G} &= \overrightarrow{R_G}'' 
= \displaystyle \frac{1}{M} \sum_{i=1}^n m_i \overrightarrow{r_i}''
\end{cases}
\end{aligned}$$

<div class="theory-common-box">定義（重心運動量）</div>
<p>
重心運動量 $\displaystyle \overrightarrow{P_G}$ を下記で定義する。
$$\begin{aligned}
\displaystyle 
\overrightarrow{P_G} = M \overrightarrow{V_G} 
= \sum_{i=1}^n m_i \overrightarrow{r_i}'
\end{aligned}$$
</p>
<div class="theory-common-box">命題：質点系の全質量×重心加速度は外力の総和と一致する。</div>
<p><div class="proof-box">証明</div>
質点 $j$ から $i$ に作用する力を $\overrightarrow{F_{i\leftarrow j}}$，  
外力を $\overrightarrow{f_i}$ とすると
$$\begin{aligned}
\displaystyle 
m_i \overrightarrow{r_i}'' 
= \overrightarrow{f_i} + \sum_{j\neq i} \overrightarrow{F_{i \leftarrow j}}
\end{aligned}$$
である。全質点について和を取ると、作用反作用の法則により$\sum_{j\neq i} \overrightarrow{F_{i \leftarrow j}}$の項が全て相殺され、下記を得る。
$$\begin{aligned}
\displaystyle 
\sum_{i=1}^n m_i \overrightarrow{r_i}'' 
&= \sum_{i=1}^n \overrightarrow{f_i} \\[6pt]
M \frac{\sum_{i=1}^n m_i \overrightarrow{r_i}''}{M} &= \sum_{i=1}^n \overrightarrow{f_i} \\[6pt]
\end{aligned}$$
ここで、重心加速度の定義より、
$$\begin{aligned}
\displaystyle 
M \overrightarrow{R_G}'' 
= \sum_{i=1}^n \overrightarrow{f_i}
\end{aligned}$$
Q.E.D.
</p>

<div class="theory-common-box">命題：外力が加わっていない場合，質点系の重心は等速直線運動を行う。</div>
<p><div class="proof-box">証明</div>
仮定より、外力$\overrightarrow{f_i}=0$ なので
$$\begin{aligned}
\displaystyle 
M \overrightarrow{R_G}'' &= \overrightarrow{0} \\[6pt]
\Leftrightarrow \overrightarrow{R_G}'' &= \overrightarrow{0}
\end{aligned}$$
したがって
$$\begin{aligned}
\displaystyle 
\overrightarrow{R_G}' = \text{時間によらないベクトル}
\end{aligned}$$
Q.E.D.
</p>

<div class="theory-common-box">定義（質点系の角運動量）</div>
<p>任意の点周りの質点系の角運動量$\overrightarrow L (t)$を、質点の角運動量の総和として下記の通り定義する。
$$\begin{aligned}
\displaystyle 
\overrightarrow{L}(t) = \sum_{i=1}^n \overrightarrow{L_i}(t)
\end{aligned}$$
</p>
<div class="theory-common-box">命題：任意の点周りの質点系の角運動量の時間微分は，外力によるモーメントの総和に等しい。</div>
<p><div class="proof-box">証明</div>
各質点 $i$ に対して
$$\begin{aligned}
\displaystyle 
\overrightarrow{L_i}(t)' &= 
\overrightarrow{r_i} \times \overrightarrow{F_i}
\end{aligned}$$
が成り立つ。和を取ると
$$\begin{aligned}
\displaystyle 
\sum_{i=1}^n \Bigl(\overrightarrow{L_i}(t)'\Bigr)
& = \sum_{i=1}^n \overrightarrow{r_i}\times\overrightarrow{F_i} \\[6pt]
\displaystyle 
\Leftrightarrow \Bigl(\sum_{i=1}^n \overrightarrow{L_i}(t)\Bigr)'
& = \sum_{i=1}^n \overrightarrow{r_i}\times\overrightarrow{F_i}\\[6pt]
\Leftrightarrow \overrightarrow{L}(t)'
& = \sum_{i=1}^n \overrightarrow{r_i}\times\overrightarrow{F_i}
\end{aligned}$$
よって質点系の角運動量 $\overrightarrow{L}(t)$の時間微分は外力によるモーメントの総和であることが示された。
Q.E.D.
</p>
"""
);
