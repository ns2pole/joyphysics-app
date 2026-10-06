import '../../model.dart'; // Video クラス

final mutual_inductance_coaxial_solenoids = Video(
  isExperiment: true,
  category: 'electroMagnetism',
  iconName: "", // アイコン未作成 → 空文字（UI側で空白確保）
  title: "同軸ソレノイド：相互インダクタンスと外側誘導起電力（内側LR, 2V, 70 kHz, R=200Ω／ピーク→RMS, ℓ=0.20 m）",
  titleEn: "Coaxial solenoids: mutual inductance and outer induced emf (inner LR, 2V, 70 kHz, R=200Ω / peak→RMS, ℓ=0.20 m)",
  videoURL: "",
  equipment: [
    "紙筒/円筒芯（内：直径≒10 mm, 外：直径≒20 mm）",
    "ポリウレタン銅線",
    "関数発振器（出力 2 V_rms, 70 kHz）",
    "抵抗 200 Ω（内側直列）",
    "オシロスコープ"
  ],
  equipmentEn: [
    "paper tube / cylindrical core (inner diameter ≈10 mm, outer ≈20 mm)",
    "polyurethane copper wire",
    "function generator (output 2 V_rms, 70 kHz)",
    "resistor 200 Ω (series with inner coil)",
    "oscilloscope"
  ],
  costRating: "★★☆",
  latex: r"""
<div class="common-box">記号（すべて冒頭に定義）</div>
\[
\begin{aligned}
a & = \text{内側ソレノイド半径} \\
  & = 0.005\,\mathrm{m} \\[4pt]
b & = \text{外側ソレノイド半径} \\
  & = 0.010\,\mathrm{m} \\[4pt]
\ell & = \text{共有長さ} \\
     & = 0.20\,\mathrm{m} \\[4pt]
n_1 & = \text{内側の巻数密度} \\
    & = 300\,\mathrm{m^{-1}} \\[4pt]
n_2 & = \text{外側の巻数密度} \\
    & = 600\,\mathrm{m^{-1}} \\[4pt]
\mu_0 & = 4\pi\times10^{-7}\,\mathrm{H/m} \\[4pt]
A_{\text{in}} & = \pi a^2 \\[4pt]
M & = \text{相互インダクタンス} \\[4pt]
L_1 & = \text{内側自己インダクタンス} \\[4pt]
R_1 & = 200\,\Omega \\[4pt]
f & = 70{,}000\,\mathrm{Hz} \\[4pt]
\omega & = 2\pi f \\[4pt]
\phi & = \arctan\!\left(\frac{\omega L_1}{R_1}\right) \\[4pt]
V_{1} & = \text{内側電圧のピーク値} \\[4pt]
I_{1} & = \text{内側電流のピーク値} \\[4pt]
i_1(t) & = \text{内側電流（時間関数）} \\[4pt]
v_2(t) & = \text{外側起電力（時間関数）} \\[4pt]
V_{2} & = \text{外側起電力のピーク値} \\[4pt]
V_{2,\mathrm{rms}} & = \text{外側起電力の実効値}
\end{aligned}
\]

<div class="common-box">幾何と断面積</div>
\[
\begin{aligned}
A_{\text{in}} & = \pi a^2 \\
              & = \pi\,(0.005)^2 \\
              & = 7.8539816\times10^{-5}\ \mathrm{m^2}
\end{aligned}
\]

<div class="common-box">相互インダクタンス（長ソレノイド近似）</div>
\[
\begin{aligned}
\frac{M}{\ell} & = \mu_0\,n_1 n_2\,A_{\text{in}} \\
                & = 1.7765\times10^{-5}\ \mathrm{H/m} \\
                & = 17.765\ \mu\mathrm{H/m}
\end{aligned}
\]
\[
\begin{aligned}
M & = \left(17.765\ \mu\mathrm{H/m}\right)\times 0.20 \\
  & = \boxed{3.553\ \mu\mathrm{H}}
\end{aligned}
\]

<div class="common-box">内側 LR のインピーダンスと電流（まずピークで記述）</div>
\[
\begin{aligned}
\omega & = 2\pi f \\
       & = 4.3982\times10^{5}\ \mathrm{rad/s} \\[6pt]
L_1 & = \left(8.883\ \mu\mathrm{H/m}\right)\times 0.20 \\
    & = 1.7765\ \mu\mathrm{H} \\[6pt]
X_{L1} & = \omega L_1 \\
      & = (4.3982\times10^{5})\times(1.7765\times10^{-6}) \\
      & \fallingdotseq \boxed{0.7814\ \Omega} \\[6pt]
Z_1 & = \sqrt{R_1^2 + X_{L1}^2} \\
    & = \sqrt{200^2 + 0.7814^2} \\
    & \fallingdotseq \boxed{200.0015\ \Omega} \\[6pt]
V_{1} & = \sqrt{2}\times 2 \\
                    & = \boxed{2\sqrt{2}\ \mathrm{V}} \\[6pt]
I_{1} & = \frac{V_{1}}{Z_1} \\
                    & \fallingdotseq \frac{2\sqrt{2}}{200.0015} \\
                    & \fallingdotseq \boxed{0.01414\ \mathrm{A}}
\end{aligned}
\]
\[
\begin{aligned}
\phi & = \arctan\!\left(\frac{\omega L_1}{R_1}\right) \\
     & = \arctan\!\left(\frac{0.7814}{200}\right) \\
     & \fallingdotseq \boxed{0.224^\circ}
\end{aligned}
\]

<div class="common-box">時間関数 → 微分で \(\omega\) が前に出る（位相込み）</div>
\[
\begin{aligned}
i_1(t) & = I_{1}\,\cos(\omega t - \phi) \\[6pt]
\frac{di_1}{dt} & = -\,I_{1}\,\omega\,\sin(\omega t - \phi)
\end{aligned}
\]

<div class="common-box">外側の誘導起電力（まずピーク）→ 最後に RMS 換算</div>
\[
\begin{aligned}
v_2(t) & = -\,M\,\frac{di_1}{dt} \\[6pt]
       & = M\,I_{1}\,\omega\,\sin(\omega t - \phi) \\[6pt]
V_{2} & = M\,\omega\,I_{1} \\
                    & = (3.553\times10^{-6})\times(4.3982\times10^{5})\times(0.01414) \\
                    & \fallingdotseq \boxed{22.1\ \mathrm{mV}}
\end{aligned}
\]
\[
\begin{aligned}
V_{2,\mathrm{rms}} & = \frac{V_{2}}{\sqrt{2}} \\
                   & \fallingdotseq \boxed{15.6\ \mathrm{mV}}
\end{aligned}
\]

<div class="common-box">チェック（1 m あたり表現との一致）</div>
\[
\begin{aligned}
\frac{V_{2,\mathrm{rms}}}{\ell} & = (17.765\times10^{-6})\times(4.3982\times10^{5})\times\left(\frac{2}{Z_1}\right) \\
                                 & \fallingdotseq 0.07813\ \mathrm{V/m} \\[4pt]
V_{2,\mathrm{rms}} & = 0.07813\times 0.20 \\
                   & \fallingdotseq 15.6\ \mathrm{mV}
\end{aligned}
\]

<div class="common-box">メモ</div>
\[
\begin{aligned}
& V_{2,\mathrm{rms}} \propto \ell,\ n_1 n_2,\ \omega,\ \mu_0\ (\text{媒質で }\mu_0\rightarrow\mu)。 \\
& \phi \text{ は } \arctan(\omega L_1/R_1) \text{ で小さく（本条件）大きさには影響しない。}
\end{aligned}
\]
""",
  latexEn: r"""
<div class="common-box">Symbols (all defined at the start)</div>
\[
\begin{aligned}
a & = \text{inner solenoid radius} \\
  & = 0.005\,\mathrm{m} \\[4pt]
b & = \text{outer solenoid radius} \\
  & = 0.010\,\mathrm{m} \\[4pt]
\ell & = \text{shared length} \\
     & = 0.20\,\mathrm{m} \\[4pt]
n_1 & = \text{inner turns per unit length} \\
    & = 300\,\mathrm{m^{-1}} \\[4pt]
n_2 & = \text{outer turns per unit length} \\
    & = 600\,\mathrm{m^{-1}} \\[4pt]
\mu_0 & = 4\pi\times10^{-7}\,\mathrm{H/m} \\[4pt]
A_{\text{in}} & = \pi a^2 \\[4pt]
M & = \text{mutual inductance} \\[4pt]
L_1 & = \text{inner self-inductance} \\[4pt]
R_1 & = 200\,\Omega \\[4pt]
f & = 70{,}000\,\mathrm{Hz} \\[4pt]
\omega & = 2\pi f \\[4pt]
\phi & = \arctan\!\left(\frac{\omega L_1}{R_1}\right) \\[4pt]
V_{1} & = \text{peak inner voltage} \\[4pt]
I_{1} & = \text{peak inner current} \\[4pt]
i_1(t) & = \text{inner current (time function)} \\[4pt]
v_2(t) & = \text{outer emf (time function)} \\[4pt]
V_{2} & = \text{peak outer emf} \\[4pt]
V_{2,\mathrm{rms}} & = \text{RMS outer emf}
\end{aligned}
\]

<div class="common-box">Geometry and cross-sectional area</div>
\[
\begin{aligned}
A_{\text{in}} & = \pi a^2 \\
              & = \pi\,(0.005)^2 \\
              & = 7.8539816\times10^{-5}\ \mathrm{m^2}
\end{aligned}
\]

<div class="common-box">Mutual inductance (long-solenoid approximation)</div>
\[
\begin{aligned}
\frac{M}{\ell} & = \mu_0\,n_1 n_2\,A_{\text{in}} \\
                & = 1.7765\times10^{-5}\ \mathrm{H/m} \\
                & = 17.765\ \mu\mathrm{H/m}
\end{aligned}
\]
\[
\begin{aligned}
M & = \left(17.765\ \mu\mathrm{H/m}\right)\times 0.20 \\
  & = \boxed{3.553\ \mu\mathrm{H}}
\end{aligned}
\]

<div class="common-box">Inner LR impedance and current (stated in peak values first)</div>
\[
\begin{aligned}
\omega & = 2\pi f \\
       & = 4.3982\times10^{5}\ \mathrm{rad/s} \\[6pt]
L_1 & = \left(8.883\ \mu\mathrm{H/m}\right)\times 0.20 \\
    & = 1.7765\ \mu\mathrm{H} \\[6pt]
X_{L1} & = \omega L_1 \\
      & = (4.3982\times10^{5})\times(1.7765\times10^{-6}) \\
      & \fallingdotseq \boxed{0.7814\ \Omega} \\[6pt]
Z_1 & = \sqrt{R_1^2 + X_{L1}^2} \\
    & = \sqrt{200^2 + 0.7814^2} \\
    & \fallingdotseq \boxed{200.0015\ \Omega} \\[6pt]
V_{1} & = \sqrt{2}\times 2 \\
                    & = \boxed{2\sqrt{2}\ \mathrm{V}} \\[6pt]
I_{1} & = \frac{V_{1}}{Z_1} \\
                    & \fallingdotseq \frac{2\sqrt{2}}{200.0015} \\
                    & \fallingdotseq \boxed{0.01414\ \mathrm{A}}
\end{aligned}
\]
\[
\begin{aligned}
\phi & = \arctan\!\left(\frac{\omega L_1}{R_1}\right) \\
     & = \arctan\!\left(\frac{0.7814}{200}\right) \\
     & \fallingdotseq \boxed{0.224^\circ}
\end{aligned}
\]

<div class="common-box">Time functions → differentiation brings \(\omega\) forward (including phase)</div>
\[
\begin{aligned}
i_1(t) & = I_{1}\,\cos(\omega t - \phi) \\[6pt]
\frac{di_1}{dt} & = -\,I_{1}\,\omega\,\sin(\omega t - \phi)
\end{aligned}
\]

<div class="common-box">Outer induced emf (peak first) → convert to RMS at the end</div>
\[
\begin{aligned}
v_2(t) & = -\,M\,\frac{di_1}{dt} \\[6pt]
       & = M\,I_{1}\,\omega\,\sin(\omega t - \phi) \\[6pt]
V_{2} & = M\,\omega\,I_{1} \\
                    & = (3.553\times10^{-6})\times(4.3982\times10^{5})\times(0.01414) \\
                    & \fallingdotseq \boxed{22.1\ \mathrm{mV}}
\end{aligned}
\]
\[
\begin{aligned}
V_{2,\mathrm{rms}} & = \frac{V_{2}}{\sqrt{2}} \\
                   & \fallingdotseq \boxed{15.6\ \mathrm{mV}}
\end{aligned}
\]

<div class="common-box">Check (consistency with per-meter form)</div>
\[
\begin{aligned}
\frac{V_{2,\mathrm{rms}}}{\ell} & = (17.765\times10^{-6})\times(4.3982\times10^{5})\times\left(\frac{2}{Z_1}\right) \\
                                 & \fallingdotseq 0.07813\ \mathrm{V/m} \\[4pt]
V_{2,\mathrm{rms}} & = 0.07813\times 0.20 \\
                   & \fallingdotseq 15.6\ \mathrm{mV}
\end{aligned}
\]

<div class="common-box">Note</div>
\[
\begin{aligned}
& V_{2,\mathrm{rms}} \propto \ell,\ n_1 n_2,\ \omega,\ \mu_0\ (\text{in a medium }\mu_0\rightarrow\mu). \\
& \phi \text{ from } \arctan\!\left(\frac{\omega L_1}{R_1}\right) \text{ is small (these conditions) and does not affect the magnitude.}
\end{aligned}
\]
"""
);
