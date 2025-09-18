import '../../model.dart';

final rigidBodyBalanceOfForces = TheoryTopic(
  title: '剛体のつり合いに関する諸命題',
  isNew: false,
  imageAsset: 'assets/mindMap/forTopics/rigidBodyBalanceOfForces.png', // 実際の画像パス
  latexContent: r"""
<div class="theory-common-box">命題（力のつり合い）：剛体が静止しているならば、剛体に働く外力の総和は$\overrightarrow 0$である。</div>
<p><div class="proof-box">証明</div>
剛体を質点系と見做す。剛体が静止している時、特に剛体の重心は静止しているので剛体の重心加速度は$\overrightarrow 0$。
ここで、質点系の命題：「質点の質量の総和×質点系の重心加速度は外力の総和と一致する。」より、外力の総和は$\overrightarrow 0$
　Q.E.D
</p>
<div class="theory-common-box">命題1：剛体に働く外力の合力が$\overrightarrow 0$の場合、外力の力のモーメントの総和は基準点の取り方によらない。</div>
<p><div class="proof-box">証明</div>
剛体を質点系と見做す。ある地点を原点$O$として、$i$番目の質点の位置ベクトルを$\overrightarrow{r_i}(t)$,$i$番目の質点に働く外力を$\overrightarrow{f_i}(t)$とすると、質点系に働く力のモーメントの総和は$\overrightarrow{M_O} (t) = \displaystyle \sum_{i=1}^{n} \overrightarrow {r_i}(t) \times \overrightarrow {F_i}(t)$であるが、
ここで、別の地点$P$を原点に取り替えると質点系に働く力のモーメントの総和は$\overrightarrow{M_P} (t) = \displaystyle \sum_{i=1}^{n} \Bigr(\overrightarrow{OP}+\overrightarrow {r_i}(t)\Bigr) \times \overrightarrow {F_i}(t)$となる。
これを変形すると、
$$\begin{aligned}
\displaystyle &\qquad \overrightarrow{M_P} (t) \\[6pt]&= \sum_{i=1}^{n} \Bigr(\overrightarrow{OP}+\overrightarrow {r_i}(t)\Bigr) \times \overrightarrow {F_i}(t)\\[6pt] 
&= \sum_{i=1}^{n} \Bigr(\overrightarrow{OP}+ \times \overrightarrow {F_i}(t) + \overrightarrow {r_i}(t) \times \overrightarrow {F_i}(t)\Bigr) \\[6pt] 
&=  \sum_{i=1}^{n} \overrightarrow{OP} \times  \overrightarrow {F_i}(t) +  \sum_{i=1}^{n}  \overrightarrow {r_i}(t) \times \overrightarrow {F_i}(t)  \\[6pt]
&=  \overrightarrow{OP} \times \Bigr( \sum_{i=1}^{n}  \overrightarrow {F_i}(t)\Bigr) +  \sum_{i=1}^{n} \Bigr( \overrightarrow {r_i}(t) \times \overrightarrow {F_i}(t) \Bigr) \\[6pt]
&=  \sum_{i=1}^{n} \Bigr( \overrightarrow {r_i}(t) \times \overrightarrow {F_i}(t) \Bigr)\\[6pt]
&= \overrightarrow{M_O} (t)
\end{aligned}$$
　Q.E.D
</p>
<div class="theory-common-box">命題2：剛体が静止し続けているならば、任意の点周りの剛体に働く外力のモーメントの総和は$\overrightarrow 0$である。</div>
<p><div class="proof-box">証明</div>
剛体を質点系と見做す。剛体が静止している時、剛体の角運動量は$\overrightarrow{0}$のままであるので、剛体の角運動量$\overrightarrow{L}(t)$の時間微分もまた$
\overrightarrow{0}$である。<br>
ここで質点系の命題より、外力による力のモーメントの総和と剛体の角運動量の時間微分は等しいので、外力による力のモーメントの総和は$\ 0$となる。
　Q.E.D
</p>

"""
);
