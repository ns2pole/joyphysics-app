import '../../model.dart'; // Videoクラス定義が別ならインポート
final lemonBatteryVoltage = Video(
  isExperiment: true,
  category: 'electroMagnetism', // ← 追加
    iconName: "battery",
    title: "レモン電池の電圧",
    titleEn: "Voltage of a lemon battery",
    videoURL: "qHAulACJGjU",
    equipment: ["レモン1個", "亜鉛チップ", "銅チップ", "マルチメータ", "導線"],
    equipmentEn: ["1 lemon", "zinc tip", "copper tip", "multimeter", "wires"],
    costRating: "★★☆", latex: r"""
<div class="common-box">ポイント</div>
<p>レモンに銅板と亜鉛板を刺すと、電圧が発生する。</p>
<p>これは、金属の電子を放出して陽イオンになろうとする性質の強さ（<em>イオン化傾向</em>）の違いによって電子の流れが生じるためである。</p>
<p>亜鉛は銅よりイオン化傾向が大きいため、次の反応が起こる：</p>

<p>$$
\text{Zn} \rightarrow \text{Zn}^{2+} + 2e^-
$$</p>

<p>発生した電子は外部回路を通って銅板へ移動し、レモン中の水素イオンと反応する：</p>

<p>$$
2H^+ + 2e^- \rightarrow H_2
$$</p>

<p>このようにして電子の流れが生まれ、約1Vの電圧を得られた。</p>

<p>電圧の大きさは、使用する金属の組み合わせと、電解質であるレモンの酸の性質に依存する。</p>
""",
    latexEn: r"""
<div class="common-box">Key points</div>
<p>When a copper plate and a zinc plate are inserted into a lemon, a voltage appears.</p>
<p>This happens because a difference in how strongly each metal tends to release electrons and form cations (<em>ionization tendency</em>) produces a flow of electrons.</p>
<p>Zinc has a greater ionization tendency than copper, so the following reaction occurs:</p>

<p>$$
\text{Zn} \rightarrow \text{Zn}^{2+} + 2e^-
$$</p>

<p>The electrons travel through the external circuit to the copper plate and react with hydrogen ions in the lemon:</p>

<p>$$
2H^+ + 2e^- \rightarrow H_2
$$</p>

<p>In this way a flow of electrons is produced, and a voltage of about 1 V was obtained.</p>

<p>The magnitude of the voltage depends on the combination of metals used and on the acidic properties of the lemon electrolyte.</p>
"""
);
