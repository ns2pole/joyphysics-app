import '../../model.dart';

final permittivityAndPermeabilityTable = TheoryTopic(
  title: '電場磁場の分極対応表',
  titleEn: 'Correspondence table of polarization in electric and magnetic fields',
  imageAsset: 'assets/mindMap/forTopics/permittivityAndPermeabilityTable.png',

  latexContent: r"""
<style>
/* テーブル：固定レイアウトを厳格に適用する */


/* 列を確実に50:50にするため colgroup を使う（下で定義） */
/* セルの基本スタイル */
table.material-table {
  border-collapse: collapse;   /* 角丸優先なら separate+border-radius */
  width: 96%;
  max-width: 800px;
  margin-left: auto;
  margin-right: auto;
  border: 2px solid #606060;  /* 中央縦線を太く＆濃く */
  border-radius: 12px;
  overflow: hidden;

  table-layout: fixed;         /* 固定レイアウト */
}

table.material-table td,
table.material-table th {
  width: 50%;                  /* 均等に2分割 */
  text-align: center;
  word-wrap: break-word;        /* 長い式を折り返す */
  overflow-wrap: break-word;
  border-bottom: 2px solid #606060;  /* 中央縦線を太く＆濃く */
}

/* 中央の縦線だけ太くする */
table.material-table td + td,
table.material-table th + th {
  border-left: 2px solid #606060;  /* 中央縦線を太く＆濃く */
}
/* 最後の行の下線を消す */
table.material-table tr:last-child td {
  border-bottom: none;
}

/* 見出し行 */
table.material-table th {
  background: #f7f7f7;
  font-weight: 600;
}

/* アイテム・式の表示調整 */
.item-title {
  font-weight: 600;
  display: block;
  margin-bottom: 4px;
  font-size: 0.95em;
}
.formula {
  display: block;
  margin-bottom: 0px;
  /* 長い数式がセル外にはみ出さないようにする */
  overflow-wrap: anywhere;
  word-break: break-word;
  white-space: normal;
}
.br {
  border-bottom: 2px solid #606060;  /* 中央縦線を太く＆濃く */
}

/* 補助説明部分 */
.explain {
  margin-top: 10px;
  font-size: 0.92em;
  text-align: left;
}
.explain ul {
  margin: 6px 0 8px 18px;
  padding: 0;
}
.explain li {
  margin-bottom: 4px;
}

/* フル幅行（colspan=2） */
.full-row {
  text-align: center;
  padding: 6px 0;
  background: #f2f2f2;
  color: #555;
  font-weight: 600;
  font-size: 0.95rem;
  line-height: 1;
  border-top: 1px solid #e6e6e6;
  border-bottom: 1px solid #e6e6e6;
}
.full-row strong { display:inline-block; margin:0; padding:0; }

/* MathJax / SVG / IMG 出力をセル幅内に収める（数式による崩れ対策） */
.MathJax, .MathJax_Display, .MathJax_SVG, .mjx-chtml, .mjx-svg, svg, img {
  max-width: 100% !important;
  height: auto !important;
  overflow-wrap: anywhere !important;
  word-break: break-word !important;
  white-space: normal !important;
  box-sizing: border-box;
}

/* 特に MathJax のインラインブロック要素への対策（v2/v3 両対応的に） */
.mjx-chtml > mjx-assistive-mml,
.mjx-chtml,
.MathJax .mrow {
  display: inline-block;
  max-width: 100%;
}

/* テーブル内で長い非空白文字列（例えば長いIDやURL）が切れない問題の対処 */
td, th {
  word-wrap: break-word;
}

/* スマホなどの狭い画面での見栄え調整（オプション） */
@media (max-width: 480px) {
  table.material-table { font-size: 0.88em; }
  table.material-table th, table.material-table td { padding: 6px 4px; }
}
</style>

<table class="material-table" cellspacing="0" cellpadding="4">
  <!-- colgroup で列幅を厳格指定 -->
  <colgroup>
    <col style="width:50%;">
    <col style="width:50%;">
  </colgroup>

  <tr>
    <th>電場,誘電分極</th>
    <th>磁場,磁化</th>
  </tr>

  <tr>
    <td>
      <span class="item-title">電束密度 (χ<sub>e</sub>)</span>
      <span class="formula">$\displaystyle \vec{D}\underset{定義}{:=}\varepsilon_{0}\,\vec{E} + \vec{P}$</span>
    </td>
    <td>
      <span class="item-title">磁束密度 (χ<sub>m</sub>)</span>
      <span class="formula">$\displaystyle \vec{B}\underset{定義}{:=}\mu_0\vec{H}+\vec{M}$</span>
    </td>
  </tr>

  <tr class="full-row">
    <td colspan="2">
      <strong>線形応答の物質の場合</strong>
    </td>
  </tr>

  <tr>
    <td>
      <span class="item-title">分極と電気感受率 (χ<sub>e</sub>)</span>
      <span class="formula">$\displaystyle \vec{P}=\chi_{e}\,\varepsilon_{0}\,\vec{E}$</span>
    </td>
    <td>
      <span class="item-title">磁気分極と磁化率 (χ<sub>m</sub>)</span>
      <span class="formula">$\displaystyle \vec{M}=\chi_{m}\mu_{0}\vec{H}$</span>
    </td>
  </tr>

  <tr>
    <td>
      <span class="item-title">誘電率 (ε)</span>
      <span class="formula">$\displaystyle \vec{D}=\varepsilon\,\vec{E}$</span>
      <span class="formula">$\displaystyle \varepsilon=\varepsilon_{0}\,(1+\chi_{e})$</span>
    </td>
    <td>
      <span class="item-title">透磁率 (μ)</span>
      <span class="formula">$\displaystyle \vec{B}=\mu\,\vec{H}$</span>
      <span class="formula">$\displaystyle \mu=\mu_{0}\,(1+\chi_{m})$</span>
    </td>
  </tr>

  <tr>
    <td>
      <span class="item-title">比誘電率 (ε<sub>r</sub>)</span>
      <span class="formula">$\displaystyle \varepsilon_{r}=\dfrac{\varepsilon}{\varepsilon_{0}}=1+\chi_{e}$</span>
    </td>
    <td>
      <span class="item-title">比透磁率 (μ<sub>r</sub>)</span>
      <span class="formula">$\displaystyle \mu_{r}=\dfrac{\mu}{\mu_{0}}=1+\chi_{m}$</span>
    </td>
  </tr>

  <tr>
    <td>
      <span class="item-title">真空の誘電率 (ε<sub>0</sub>)</span>
      <span class="formula">約$\ \displaystyle  8.85\times10^{-12}\ \mathrm{F/m}$</span>
    </td>
    <td>
      <span class="item-title">真空の透磁率 (μ<sub>0</sub>)</span>
      <span class="formula">約$\ \displaystyle  4 \pi \times10^{-7}\ \mathrm{H/m}$</span>
    </td>
  </tr>

  <tr>
    <td colspan="2">
      <span class="item-title">真空中の光速 (c)</span>
      <span class="formula">$\displaystyle c=\dfrac{1}{\sqrt{\varepsilon_{0}\mu_{0}}}\fallingdotseq 2.99\times10^{8}\ \mathrm{m/s}$</span>
    </td>
  </tr>
  <tr>
    <td colspan="2">
      <span class="item-title">媒質中の光速（位相速度）</span>
      <span class="formula">$\displaystyle v=\dfrac{1}{\sqrt{\varepsilon\mu}}=\dfrac{c}{\sqrt{\varepsilon_{r}\mu_{r}}}$</span>
    </td>
  </tr>
</table>

""",
  latexContentEn: r"""
<style>
/* table: strict fixed layout */


/* use colgroup for 50:50 columns */
/* cell base style */
table.material-table {
  border-collapse: collapse;   /* use separate+border-radius for rounded corners */
  width: 96%;
  max-width: 800px;
  margin-left: auto;
  margin-right: auto;
  border: 2px solid #606060;  /* thicker darker center vertical rule */
  border-radius: 12px;
  overflow: hidden;

  table-layout: fixed;         /* fixed layout */
}

table.material-table td,
table.material-table th {
  width: 50%;                  /* equal two columns */
  text-align: center;
  word-wrap: break-word;        /* wrap long expressions */
  overflow-wrap: break-word;
  border-bottom: 2px solid #606060;  /* thicker darker center vertical rule */
}

/* thicken only the center vertical rule */
table.material-table td + td,
table.material-table th + th {
  border-left: 2px solid #606060;  /* thicker darker center vertical rule */
}
/* remove bottom border of last row */
table.material-table tr:last-child td {
  border-bottom: none;
}

/* header row */
table.material-table th {
  background: #f7f7f7;
  font-weight: 600;
}

/* item/formula display tweaks */
.item-title {
  font-weight: 600;
  display: block;
  margin-bottom: 4px;
  font-size: 0.95em;
}
.formula {
  display: block;
  margin-bottom: 0px;
  /* keep long math inside the cell */
  overflow-wrap: anywhere;
  word-break: break-word;
  white-space: normal;
}
.br {
  border-bottom: 2px solid #606060;  /* thicker darker center vertical rule */
}

/* auxiliary description */
.explain {
  margin-top: 10px;
  font-size: 0.92em;
  text-align: left;
}
.explain ul {
  margin: 6px 0 8px 18px;
  padding: 0;
}
.explain li {
  margin-bottom: 4px;
}

/* full-width row (colspan=2) */
.full-row {
  text-align: center;
  padding: 6px 0;
  background: #f2f2f2;
  color: #555;
  font-weight: 600;
  font-size: 0.95rem;
  line-height: 1;
  border-top: 1px solid #e6e6e6;
  border-bottom: 1px solid #e6e6e6;
}
.full-row strong { display:inline-block; margin:0; padding:0; }

/* keep MathJax/SVG/IMG within cell width */
.MathJax, .MathJax_Display, .MathJax_SVG, .mjx-chtml, .mjx-svg, svg, img {
  max-width: 100% !important;
  height: auto !important;
  overflow-wrap: anywhere !important;
  word-break: break-word !important;
  white-space: normal !important;
  box-sizing: border-box;
}

/* MathJax inline-block mitigation (v2/v3) */
.mjx-chtml > mjx-assistive-mml,
.mjx-chtml,
.MathJax .mrow {
  display: inline-block;
  max-width: 100%;
}

/* handle long unbreakable strings in table cells */
td, th {
  word-wrap: break-word;
}

/* narrow-screen tweaks (optional) */
@media (max-width: 480px) {
  table.material-table { font-size: 0.88em; }
  table.material-table th, table.material-table td { padding: 6px 4px; }
}
</style>

<table class="material-table" cellspacing="0" cellpadding="4">
  <!-- strict column widths via colgroup -->
  <colgroup>
    <col style="width:50%;">
    <col style="width:50%;">
  </colgroup>

  <tr>
    <th>Electric field, dielectric polarization</th>
    <th>Magnetic field, magnetization</th>
  </tr>

  <tr>
    <td>
      <span class="item-title">Electric displacement (χ<sub>e</sub>)</span>
      <span class="formula">$\displaystyle \vec{D}\underset{\mathrm{def}}{:=}\varepsilon_{0}\,\vec{E} + \vec{P}$</span>
    </td>
    <td>
      <span class="item-title">Magnetic flux density (χ<sub>m</sub>)</span>
      <span class="formula">$\displaystyle \vec{B}\underset{\mathrm{def}}{:=}\mu_0\vec{H}+\vec{M}$</span>
    </td>
  </tr>

  <tr class="full-row">
    <td colspan="2">
      <strong>For materials with linear response</strong>
    </td>
  </tr>

  <tr>
    <td>
      <span class="item-title">Polarization and electric susceptibility (χ<sub>e</sub>)</span>
      <span class="formula">$\displaystyle \vec{P}=\chi_{e}\,\varepsilon_{0}\,\vec{E}$</span>
    </td>
    <td>
      <span class="item-title">Magnetization and magnetic susceptibility (χ<sub>m</sub>)</span>
      <span class="formula">$\displaystyle \vec{M}=\chi_{m}\mu_{0}\vec{H}$</span>
    </td>
  </tr>

  <tr>
    <td>
      <span class="item-title">Permittivity (ε)</span>
      <span class="formula">$\displaystyle \vec{D}=\varepsilon\,\vec{E}$</span>
      <span class="formula">$\displaystyle \varepsilon=\varepsilon_{0}\,(1+\chi_{e})$</span>
    </td>
    <td>
      <span class="item-title">Permeability (μ)</span>
      <span class="formula">$\displaystyle \vec{B}=\mu\,\vec{H}$</span>
      <span class="formula">$\displaystyle \mu=\mu_{0}\,(1+\chi_{m})$</span>
    </td>
  </tr>

  <tr>
    <td>
      <span class="item-title">Relative permittivity (ε<sub>r</sub>)</span>
      <span class="formula">$\displaystyle \varepsilon_{r}=\frac{\varepsilon}{\varepsilon_{0}}=1+\chi_{e}$</span>
    </td>
    <td>
      <span class="item-title">Relative permeability (μ<sub>r</sub>)</span>
      <span class="formula">$\displaystyle \mu_{r}=\frac{\mu}{\mu_{0}}=1+\chi_{m}$</span>
    </td>
  </tr>

  <tr>
    <td>
      <span class="item-title">Vacuum permittivity (ε<sub>0</sub>)</span>
      <span class="formula">approx. $\ \displaystyle  8.85\times10^{-12}\ \mathrm{F/m}$</span>
    </td>
    <td>
      <span class="item-title">Vacuum permeability (μ<sub>0</sub>)</span>
      <span class="formula">approx. $\ \displaystyle  4 \pi \times10^{-7}\ \mathrm{H/m}$</span>
    </td>
  </tr>

  <tr>
    <td colspan="2">
      <span class="item-title">Speed of light in vacuum (c)</span>
      <span class="formula">$\displaystyle c=\frac{1}{\sqrt{\varepsilon_{0}\mu_{0}}}\fallingdotseq 2.99\times10^{8}\ \mathrm{m/s}$</span>
    </td>
  </tr>
  <tr>
    <td colspan="2">
      <span class="item-title">Speed of light in a medium (phase velocity)</span>
      <span class="formula">$\displaystyle v=\frac{1}{\sqrt{\varepsilon\mu}}=\frac{c}{\sqrt{\varepsilon_{r}\mu_{r}}}$</span>
    </td>
  </tr>
</table>

""",
);

// <div class="explain">
//   <h4>説明（箇条書き）</h4>
//   <ul>
//     <li>電束密度は一般には $\vec{D}=\varepsilon_0\vec{E} + \vec P$線形応答の物質の場合 $\vec{D}=\varepsilon\vec{E}$</li>
//     <li>$\vec{P}$：単位体積あたりの電気双極子モーメント密度（分極）。線形媒質では $\vec{P}=\chi_{e}\varepsilon_{0}\vec{E}$</li>
//     <li>$\chi_{e}$：電気感受率（無次元）。$\varepsilon=\varepsilon_{0}(1+\chi_{e})$ により誘電率と結びつく。</li>
//     <li>$\varepsilon_{r}=\displaystyle \frac{\varepsilon}{\varepsilon_{0}}$：比誘電率（無次元）</li>
//     <br>
//     <li>$\chi_{m}$：磁化率（無次元）。線形媒質では $\vec{M}=\chi_{m}\vec{H}$</li>
//     <li>$\mu$：透磁率（H/m）。磁束密度は $\vec{B}=\mu\vec{H}$</li>
//     <li>$\mu_{r}=でぃs\displaystyle \frac{\mu}{\mu_{0}}$：比透磁率（無次元）</li>
//     <br>
//     <li>光速は真空定数 $\varepsilon_{0},\mu_{0}$ から決まる：$c=\displaystyle\displaystyle \frac {1}{\sqrt{\varepsilon_{0}\mu_{0}}}$</li>
//     <li>媒質中の位相速度は $v=\displaystyle\displaystyle \frac{1}{\sqrt{\varepsilon\mu}}=\displaystyle \frac{c}{\sqrt{\varepsilon_{r}\mu_{r}}}$（線形・等方媒質の場合）</li>
//     <li>注：ここでは線形・等方媒質を仮定している。実際には分散・損失・異方性・非線形性がある。</li>
//   </ul>
// </div>