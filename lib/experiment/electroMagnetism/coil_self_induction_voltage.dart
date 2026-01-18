import '../../model.dart'; // Video クラス

final coil_self_induction_voltage = Video(
  isExperiment: true,
  category: 'electroMagnetism',
  iconName: "", // 空ならUI側で空ボックスで幅確保
  title: "自己誘導：スイッチ開閉によるコイルの高電圧発生（E=3V, R1=47Ω, R2=100Ω, L=5mH）",
  videoURL: "",
  equipment: [
    "直流電源（3 V）",
    "抵抗 47 Ω, 100 Ω",
    "コイル（5 mH）",
    "押しボタンスイッチ",
    "オシロスコープ（10:1 プローブ推奨）"
  ],
  costRating: "★☆☆",
  latex: r"""
<div class="common-box">記号（すべて冒頭に定義）</div>
\[
\begin{aligned}
E & = \text{電源電圧} \\[2pt]
  & = 3\,\mathrm{V} \\[6pt]
R_1 & = \text{直列抵抗（ON/OFF 共通経路）} \\[2pt]
    & = 47\,\Omega \\[6pt]
R_2 & = \text{OFF 時経路に直列の抵抗} \\[2pt]
    & = 100\,\Omega \\[6pt]
L & = \text{インダクタンス} \\[2pt]
  & = 5.0\times 10^{-3}\,\mathrm{H} \\[6pt]
i_1(t) & = \text{ON 中のコイル電流} \\[6pt]
i(t) & = \text{OFF 後のコイル電流} \\[6pt]
\tau_1 & = \dfrac{L}{R_1} \\[6pt]
\tau_2 & = \dfrac{L}{R_1+R_2} \\[6pt]
I_0 & = \dfrac{E}{R_1}
\end{aligned}
\]

<div class="common-box">問題設定／幾何（観測量と配線）</div>
<p>
直流電源 \(E\)・抵抗 \(R_1\)・コイル \(L\) を直列接続し、押しボタンで ON/OFF を切替える。OFF 時、電流の逃げ道として \(R_2\) を直列に加えた経路を用意する。観測する主量は \(i_1(t),\, i(t),\, v_{R_2}(0^+),\, v_L(0^+)\)。
</p>

<div class="common-box">キルヒホッフの法則（KCL/KVL の立式）</div>
<p><b>KCL：</b> 直列回路なので枝電流は各素子で等しい（分岐なし）。</p>
\[
\begin{aligned}
i_{\text{源}}(t) & = i_{R_1}(t) \\[2pt]
                 & = i_L(t)
\end{aligned}
\]
<p><b>KVL（ON 中）：</b> 電源・抵抗・コイルを一周して電圧和がゼロ。</p>
\[
\begin{aligned}
E - R_1\,i_1(t) - L\,\dfrac{di_1}{dt} & = 0
\end{aligned}
\]
<p><b>KVL（OFF 直後以降）：</b> 電源は切り離され，抵抗 \(R_1+R_2\) とコイルを一周。</p>
\[
\begin{aligned}
- R_1\,i(t) - R_2\,i(t) - L\,\dfrac{di}{dt} & = 0
\end{aligned}
\]

<div class="common-box">微分方程式の形（KVL を整理）</div>
\[
\begin{aligned}
L\,\dfrac{di_1}{dt} + R_1\,i_1(t) & = E \\[6pt]
L\,\dfrac{di}{dt} + (R_1+R_2)\,i(t) & = 0
\end{aligned}
\]

<div class="common-box">初期条件と連続性（コイル電流は不連続に変化しない）</div>
\[
\begin{aligned}
i_1(0) & = 0 \\[6pt]
i_1(\infty) & = I_0 \\[6pt]
i(0^+) & = I_0
\end{aligned}
\]
<p>
コイル電流は瞬時にジャンプできないため，OFF の瞬間 \(t=0^+\) における電流は ON 終了直前の定常電流 \(I_0\) に等しい。
</p>

<div class="common-box">解法（ON：一次不定微分方程式）</div>
\[
\begin{aligned}
i_1(t) & = I_0\Bigl(1 - e^{-t/\tau_1}\Bigr)
\end{aligned}
\]

<div class="common-box">解法（OFF：同次方程式）</div>
\[
\begin{aligned}
i(t) & = I_0\,e^{-t/\tau_2}
\end{aligned}
\]

<div class="common-box">遮断直後の電圧（極性に注意）</div>
\[
\begin{aligned}
v_{R_2}(0^+) & = R_2\,I_0 \\[6pt]
v_L(0^+) & = -\bigl(R_1+R_2\bigr)\,I_0
\end{aligned}
\]
<p>
符号はコイルが流れていた電流を保とうとする向きで定まり、電源極性と逆向きの電圧が立つ。
</p>

<div class="common-box">数値代入（最後にまとめて）</div>
\[
\begin{aligned}
I_0 & \underset{definintion}{:=} \text{定常電流（ON の最終値）} \\[2pt]
    & = \dfrac{E}{R_1} \\[2pt]
    & = \dfrac{3}{47} \\[2pt]
    & = \boxed{0.0638\ \mathrm{A}} \\[10pt]
\tau_1 & \underset{definintion}{:=} \text{ON 時の時定数} \\[2pt]
      & = \dfrac{L}{R_1} \\[2pt]
      & = \dfrac{0.005}{47} \\[2pt]
      & = \boxed{1.06\times 10^{-4}\ \mathrm{s}} \\[10pt]
\tau_2 & \underset{definintion}{:=} \text{OFF 時の時定数} \\[2pt]
      & = \dfrac{L}{R_1+R_2} \\[2pt]
      & = \dfrac{0.005}{147} \\[2pt]
      & = \boxed{3.40\times 10^{-5}\ \mathrm{s}} \\[10pt]
v_{R_2}(0^+) & \underset{definintion}{:=} \text{遮断直後の }R_2\text{ 両端電圧} \\[2pt]
            & = R_2\,I_0 \\[2pt]
            & = 100 \times 0.0638 \\[2pt]
            & = \boxed{6.38\ \mathrm{V}} \\[10pt]
v_{L}(0^+) & \underset{definintion}{:=} \text{遮断直後のコイル電圧（逆極性）} \\[2pt]
          & = -\bigl(R_1+R_2\bigr)\,I_0 \\[2pt]
          & = -147 \times 0.0638 \\[2pt]
          & = \boxed{-9.38\ \mathrm{V}} \\[10pt]
U & \underset{definintion}{:=} \text{ON 時にコイルへ蓄えられる磁場エネルギー} \\[2pt]
  & = \tfrac{1}{2} L I_0^2 \\[2pt]
  & = \tfrac{1}{2}\times 0.005 \times (0.0638)^2 \\[2pt]
  & = \boxed{1.02\times 10^{-5}\ \mathrm{J}}
\end{aligned}
\]

<div class="common-box">まとめ（設計指針）</div>
<ul>
  <li>ON：\(\tau_1\) で \(I_0\) に漸近。OFF：\(\tau_2\) で指数減衰。</li>
  <li>\(R_2\) を大きくすると \(|v_L(0^+)|\) は増大し、\(\tau_2\) は短縮。</li>
  <li>観測時は 10:1 プローブ、短いグラウンド、十分な帯域・サンプルでスパイクを捉える。</li>
</ul>

<div class="common-box">安全メモ</div>
<ul>
  <li>蓄積エネルギーは \(\sim 10\,\mu\mathrm{J}\) と小さいが、極性反転・高速過渡に注意。</li>
  <li>OFF 直後は導体に触れない。測定器の定格を遵守。</li>
</ul>
"""
);
