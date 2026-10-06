import '../../model.dart'; // Videoクラス定義が別ならインポート

final ac_power_generation = Video(
  isExperiment: true,
  category: 'electroMagnetism',
  iconName: "",
  title: "回転磁石（x軸回り）と30巻コイルの交流起電力：数値代入（r_m=1.5 cm, B̂=0.200 T）",
  titleEn: "AC emf from a rotating magnet (about the x-axis) and a 30-turn coil: numerical substitution (r_m=1.5 cm, B̂=0.200 T)",
  videoURL: "",
  equipment: [
    "円形ネオジム磁石（軸方向着磁，半径 1.5 cm，近傍 B̂ ≒ 0.200 T）",
    "回転ステージ（回転数 f [Hz]、x軸回り）",
    "コイル（30巻）",
    "オシロスコープ"
  ],
  equipmentEn: [
    "circular neodymium magnet (axial magnetization, radius 1.5 cm, nearby B̂ ≈ 0.200 T)",
    "rotation stage (rotation rate f [Hz], about the x-axis)",
    "coil (30 turns)",
    "oscilloscope"
  ],
  costRating: "★★☆",
  latex: r"""
<div class="common-box">ポイント</div>
<p>コイル面は固定で \(xy\) 平面，磁石は \(x\) 軸回りに角速度 \(2\pi f\) で回転。軸方向着磁のため，コイル法線成分は
\[
B_z(t)=\hat B\cos\theta(t),\quad \theta(t)=2\pi f t+\theta_0.
\]
ファラデーの法則と \(\Phi(t)\fallingdotseq A\,B_z(t)\) より
\[
\mathcal{E}(t)=N\,A\,\hat B\,(2\pi f)\,\sin(2\pi f t+\theta_0).
\]
</p>

<div class="common-box">数値代入</div>
<p>磁石半径 \(r_m=1.5\ \mathrm{cm}=0.015\ \mathrm{m}\)。有効面積を上限見積りとして磁石円面積で近似：
\[
\begin{aligned}
A
&= \pi r_m^2
= \pi (0.015)^2 \\
&= \pi \times 2.25\times 10^{-4} \\
&= 7.0685834706\times 10^{-4}\ \mathrm{m^2}.
\end{aligned}
\]
巻数 \(N=30\)、磁束密度振幅 \(\hat B=0.200\ \mathrm{T}\) を代入すると
\[
\begin{aligned}
\mathcal{E}_{\rm peak}
&= N\,A\,\hat B\,(2\pi f) \\
&= 30 \times (7.06858\times 10^{-4}) \times 0.200 \times (2\pi f) \\
&= 2.664793188\times 10^{-2}\ f\ \ \mathrm{[V]}.
\end{aligned}
\]
よって時間波形は
\[
\boxed{
\ \mathcal{E}(t)=\big(2.664793\times 10^{-2}\ f\big)\,
\sin\!\big(2\pi f t+\theta_0\big)\ \ \mathrm{[V]}\ }.
\]
実効値は
\[
\begin{aligned}
\mathcal{E}_{\rm rms}
&= \frac{\mathcal{E}_{\rm peak}}{\sqrt{2}}
= 1.88429333\times 10^{-2}\ f\ \ \mathrm{[V]}.
\end{aligned}
\]
</p>

<div class="common-box">備考</div>
<ul>
  <li>ここでは上限見積りとして \(A\fallingdotseq \pi r_m^2\) を採用（実機では漏れ磁束・位置ズレで有効 \(A\hat B\) は小さくなるのが一般的）。</li>
  <li>係数は \([\mathrm{V/Hz}]\)。例：\(f=100\ \mathrm{Hz}\) なら \(\mathcal{E}_{\rm peak}\fallingdotseq 2.6648\ \mathrm{V}\)、\(\mathcal{E}_{\rm rms}\fallingdotseq 1.8843\ \mathrm{V}\)。</li>
</ul>
""",
  latexEn: r"""
<div class="common-box">Key points</div>
<p>The coil plane is fixed in the \(xy\) plane, and the magnet rotates about the \(x\) axis at angular speed \(2\pi f\). Because of axial magnetization, the component normal to the coil is
\[
B_z(t)=\hat B\cos\theta(t),\quad \theta(t)=2\pi f t+\theta_0.
\]
From Faraday's law and \(\Phi(t)\fallingdotseq A\,B_z(t)\),
\[
\mathcal{E}(t)=N\,A\,\hat B\,(2\pi f)\,\sin(2\pi f t+\theta_0).
\]
</p>

<div class="common-box">Numerical substitution</div>
<p>Magnet radius \(r_m=1.5\ \mathrm{cm}=0.015\ \mathrm{m}\). As an upper-bound estimate, approximate the effective area by the magnet's circular area:
\[
\begin{aligned}
A
&= \pi r_m^2
= \pi (0.015)^2 \\
&= \pi \times 2.25\times 10^{-4} \\
&= 7.0685834706\times 10^{-4}\ \mathrm{m^2}.
\end{aligned}
\]
Substituting \(N=30\) turns and magnetic flux density amplitude \(\hat B=0.200\ \mathrm{T}\) gives
\[
\begin{aligned}
\mathcal{E}_{\rm peak}
&= N\,A\,\hat B\,(2\pi f) \\
&= 30 \times (7.06858\times 10^{-4}) \times 0.200 \times (2\pi f) \\
&= 2.664793188\times 10^{-2}\ f\ \ \mathrm{[V]}.
\end{aligned}
\]
Hence the time waveform is
\[
\boxed{
\ \mathcal{E}(t)=\big(2.664793\times 10^{-2}\ f\big)\,
\sin\!\big(2\pi f t+\theta_0\big)\ \ \mathrm{[V]}\ }.
\]
The rms value is
\[
\begin{aligned}
\mathcal{E}_{\rm rms}
&= \frac{\mathcal{E}_{\rm peak}}{\sqrt{2}}
= 1.88429333\times 10^{-2}\ f\ \ \mathrm{[V]}.
\end{aligned}
\]
</p>

<div class="common-box">Note</div>
<ul>
  <li>Here we take \(A\fallingdotseq \pi r_m^2\) as an upper-bound estimate (in a real setup, leakage flux and misalignment typically make the effective \(A\hat B\) smaller).</li>
  <li>The coefficient has units \([\mathrm{V/Hz}]\). Example: for \(f=100\ \mathrm{Hz}\), \(\mathcal{E}_{\rm peak}\fallingdotseq 2.6648\ \mathrm{V}\) and \(\mathcal{E}_{\rm rms}\fallingdotseq 1.8843\ \mathrm{V}\).</li>
</ul>
"""
);
