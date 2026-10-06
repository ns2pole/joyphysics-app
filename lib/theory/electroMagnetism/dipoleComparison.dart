import '../../model.dart';

final dipoleComparison = TheoryTopic(
  title: '電場磁場の双極子の諸概念対応表',
  titleEn: 'Correspondence table of electric and magnetic dipole concepts',
  // imageAsset: 'assets/mindMap/forTopics/dipoleComparison.png',

  latexContent: r"""
<style>
/* ===========================
       汎用テーブルスタイル
       =========================== */
    :root{
      --tbl-border: #606060;
      --tbl-bg-head: #f7f7f7;
      --tbl-radius: 12px;
      --tbl-font-size: 0.88rem;
      --tbl-gap: 8px;
      --min-table-width: 600px;
      --compact-font-scale: 0.85;
    }

    .table-wrapper {
      width: 100%;
      box-sizing: border-box;
      overflow-x: auto;
      -webkit-overflow-scrolling: touch;
      position: relative;
      padding: 16px;
    }

    table.material-table {
      border-collapse: collapse;
      width: 100%;
      max-width: none;
      margin: 0;
      border: 2px solid var(--tbl-border);
      border-radius: var(--tbl-radius);
      overflow: visible;
      table-layout: fixed;
      font-size: var(--tbl-font-size);
      background: white;
      box-sizing: border-box;
      min-width: 600px;
    }

    table.material-table col { 
      width: 50%; 
    }

    table.material-table th,
    table.material-table td {
      padding: 12px 16px;
      text-align: center;
      border-bottom: 2px solid var(--tbl-border);
      box-sizing: border-box;
      min-width: 0;
      overflow-wrap: anywhere;
      word-break: break-word;
      white-space: normal;
      vertical-align: middle;
    }

    table.material-table th {
      background: var(--tbl-bg-head);
      font-weight: 600;
      font-size: 1.1em;
    }

    table.material-table td + td,
    table.material-table th + th {
      border-left: 2px solid var(--tbl-border);
    }

    table.material-table tr:last-child td { 
      border-bottom: none; 
    }

    .item-title { 
      font-weight: 600; 
      display:block; 
      margin-bottom:8px; 
      font-size: 1.05em;
    }
    
    .item-subtitle { 
      font-weight:600; 
      display:block; 
      margin-bottom:4px; 
      font-size:0.95em; 
    }
    
    .formula { 
      display:block; 
      margin-bottom:0; 
      overflow-wrap:anywhere; 
      word-break:break-word; 
      white-space:normal; 
      min-width:0;
      font-family: 'Times New Roman', serif;
      font-size: 1.1em;
    }
    
    .full-row { 
      text-align:center; 
      padding:12px 6px; 
      background:#f2f2f2; 
      color:#555; 
      font-weight:600; 
      border-top:2px solid var(--tbl-border);
      border-bottom:2px solid var(--tbl-border);
      font-size: 1.1em;
    }
    
    .small { 
      font-size:0.85em; 
      color: #666;
      margin-top: 4px;
    }

    /* レスポンシブ対応 */
    @media (max-width: 768px) {
      .table-wrapper {
        padding: 8px;
      }
      
      table.material-table {
        min-width: 100%;
        font-size: 0.85rem;
      }
      
      table.material-table th,
      table.material-table td {
        padding: 10px 12px;
      }
    }

    @media (max-width: 480px) {
      table.material-table {
        font-size: 0.8rem;
      }
      
      table.material-table th,
      table.material-table td {
        padding: 8px 10px;
      }
      
      .formula {
        font-size: 1em;
      }
    }

    /* 横画面用最適化 */
    @media (orientation: landscape) and (max-width: 1000px) {
      table.material-table {
        font-size: 0.82rem;
      }
      
      table.material-table th,
      table.material-table td {
        padding: 8px 10px;
      }
    }

    body {
      margin: 0;
      padding: 0;
      background: #f5f5f5;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    }
  
</style>

<table class="material-table" cellspacing="0" cellpadding="2">
  <colgroup>
    <col style="width:50%;">
    <col style="width:50%;">
  </colgroup>

  <tr>
    <th>電場側</th>
    <th>磁場側（磁荷モデル）</th>
  </tr>

  <tr>
    <td>
      <span class="item-title">点電荷 $q$ による電場 $\vec E$</span>
      <span class="formula">$\displaystyle \vec E(\vec r)=\frac{1}{4\pi\varepsilon_0}\frac{q}{r^2}\,\hat r$</span>
    </td>
    <td>
      <span class="item-title">点磁荷 $Q$ による磁場 $\vec H$</span>
      <span class="formula">$\displaystyle \vec H(\vec r)=\frac{1}{4\pi\mu_0}\frac{Q}{r^2}\,\hat r$</span>
    </td>
  </tr>

  <tr>
    <td>
      <span class="item-title">点電荷 $q$ への電場 $\vec E$の力</span>
      <span class="formula">$\displaystyle \vec F =q \vec E$</span>
    </td>
    <td>
      <span class="item-title">点磁荷 $Q$ への磁場 $\vec H$の力</span>
      <span class="formula">$\displaystyle \vec F =Q \vec H $</span>
    </td>
  </tr>

  <tr>
    <td>
      <span class="item-title">電気双極子モーメント</span>
      <span class="formula">$\displaystyle \vec p_e = q\,\vec d$</span>
    </td>
    <td>
      <span class="item-title">磁気双極子モーメント(磁荷モデル)</span>
      <span class="formula">$\displaystyle \vec p_m = Q\,\vec d$</span>
    </td>
  </tr>

  <tr>
    <td>
      <span class="item-title">遠方場 $\vec E$（電気対 双極子）</span>
      <span class="formula">$\displaystyle \vec E = \frac{3(\vec p_e\cdot\hat r)\hat r-\vec p_e}{4\pi\varepsilon_0 r^3}$</span>
    </td>
    <td>
      <span class="item-title">遠方場 $\vec H$（磁荷対 双極子）</span>
      <span class="formula">$\displaystyle \vec H = \frac{3(\vec p_m\cdot\hat r)\hat r-\vec p_m}{4\pi\mu_0 r^3}$</span>
    </td>
  </tr>

  <tr>
    <td>
      <span class="item-title">外場によるトルク（電気）</span>
      <span class="formula">$\displaystyle \vec N_e = \vec p_e \times \vec E$</span>
    </td>
    <td>
      <span class="item-title">外場によるトルク（磁気）</span>
      <span class="formula">$\displaystyle \vec N_m = \vec p_m \times \vec H$</span>
    </td>
  </tr>

  <tr>
    <td>
      <span class="item-title">電流ループとの対応（電気側は該当なし）</span>
      <span class="formula">—</span>
    </td>
    <td>
      <span class="item-title">ループ電流</span>
      <span class="item-subtitle">円形電流 磁気モーメント</span>
      <span class="formula">
        $\displaystyle \vec m = I\vec S$
      </span>
      <span class="item-subtitle">円形電流 磁気双極子モーメント</span>
      <span class="formula">
        $\vec p_m=\mu_0\vec m$
      </span>
      <span class="item-subtitle">磁荷対(双極子)とループ電流対応(円形)</span>
      <span class="formula">
        $Q=\displaystyle \mu_0 \pi a I$
      </span>
      <div class="small">ここで $a$ は磁荷対の距離,円形電流半径。</div>
    </td>
  </tr>

  <tr>
    <td colspan="2" class="full-row">
      Maxwell 方程式の対称化（真空）
    </td>
  </tr>

  <tr>
    <td>
      <span class="formula">$\displaystyle \nabla\cdot\vec E=\frac{\rho_e}{\varepsilon_0}$</span>
      <span class="formula">$\displaystyle \nabla\times\vec E=-\frac{\partial\vec B}{\partial t}-\vec J_m$</span>
    </td>
    <td>
      <span class="formula">$\displaystyle \nabla\cdot\vec H=\frac{\rho_m}{\mu_0}$</span>
      <span class="formula">$\displaystyle \nabla\times\vec H=\vec J_e+\frac{\partial\vec D}{\partial t}$</span>
    </td>
  </tr>

</table>
""",
  latexContentEn: r"""
<style>
/* ===========================
       generic table style
       =========================== */
    :root{
      --tbl-border: #606060;
      --tbl-bg-head: #f7f7f7;
      --tbl-radius: 12px;
      --tbl-font-size: 0.88rem;
      --tbl-gap: 8px;
      --min-table-width: 600px;
      --compact-font-scale: 0.85;
    }

    .table-wrapper {
      width: 100%;
      box-sizing: border-box;
      overflow-x: auto;
      -webkit-overflow-scrolling: touch;
      position: relative;
      padding: 16px;
    }

    table.material-table {
      border-collapse: collapse;
      width: 100%;
      max-width: none;
      margin: 0;
      border: 2px solid var(--tbl-border);
      border-radius: var(--tbl-radius);
      overflow: visible;
      table-layout: fixed;
      font-size: var(--tbl-font-size);
      background: white;
      box-sizing: border-box;
      min-width: 600px;
    }

    table.material-table col { 
      width: 50%; 
    }

    table.material-table th,
    table.material-table td {
      padding: 12px 16px;
      text-align: center;
      border-bottom: 2px solid var(--tbl-border);
      box-sizing: border-box;
      min-width: 0;
      overflow-wrap: anywhere;
      word-break: break-word;
      white-space: normal;
      vertical-align: middle;
    }

    table.material-table th {
      background: var(--tbl-bg-head);
      font-weight: 600;
      font-size: 1.1em;
    }

    table.material-table td + td,
    table.material-table th + th {
      border-left: 2px solid var(--tbl-border);
    }

    table.material-table tr:last-child td { 
      border-bottom: none; 
    }

    .item-title { 
      font-weight: 600; 
      display:block; 
      margin-bottom:8px; 
      font-size: 1.05em;
    }
    
    .item-subtitle { 
      font-weight:600; 
      display:block; 
      margin-bottom:4px; 
      font-size:0.95em; 
    }
    
    .formula { 
      display:block; 
      margin-bottom:0; 
      overflow-wrap:anywhere; 
      word-break:break-word; 
      white-space:normal; 
      min-width:0;
      font-family: 'Times New Roman', serif;
      font-size: 1.1em;
    }
    
    .full-row { 
      text-align:center; 
      padding:12px 6px; 
      background:#f2f2f2; 
      color:#555; 
      font-weight:600; 
      border-top:2px solid var(--tbl-border);
      border-bottom:2px solid var(--tbl-border);
      font-size: 1.1em;
    }
    
    .small { 
      font-size:0.85em; 
      color: #666;
      margin-top: 4px;
    }

    /* responsive */
    @media (max-width: 768px) {
      .table-wrapper {
        padding: 8px;
      }
      
      table.material-table {
        min-width: 100%;
        font-size: 0.85rem;
      }
      
      table.material-table th,
      table.material-table td {
        padding: 10px 12px;
      }
    }

    @media (max-width: 480px) {
      table.material-table {
        font-size: 0.8rem;
      }
      
      table.material-table th,
      table.material-table td {
        padding: 8px 10px;
      }
      
      .formula {
        font-size: 1em;
      }
    }

    /* landscape optimization */
    @media (orientation: landscape) and (max-width: 1000px) {
      table.material-table {
        font-size: 0.82rem;
      }
      
      table.material-table th,
      table.material-table td {
        padding: 8px 10px;
      }
    }

    body {
      margin: 0;
      padding: 0;
      background: #f5f5f5;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    }
  
</style>

<table class="material-table" cellspacing="0" cellpadding="2">
  <colgroup>
    <col style="width:50%;">
    <col style="width:50%;">
  </colgroup>

  <tr>
    <th>Electric side</th>
    <th>Magnetic side (magnetic-charge model)</th>
  </tr>

  <tr>
    <td>
      <span class="item-title">Electric field $\vec E$ of point charge $q$</span>
      <span class="formula">$\displaystyle \vec E(\vec r)=\frac{1}{4\pi\varepsilon_0}\frac{q}{r^2}\,\hat r$</span>
    </td>
    <td>
      <span class="item-title">Magnetic field $\vec H$ of point magnetic charge $Q$</span>
      <span class="formula">$\displaystyle \vec H(\vec r)=\frac{1}{4\pi\mu_0}\frac{Q}{r^2}\,\hat r$</span>
    </td>
  </tr>

  <tr>
    <td>
      <span class="item-title">Force of electric field $\vec E$ on point charge $q$</span>
      <span class="formula">$\displaystyle \vec F =q \vec E$</span>
    </td>
    <td>
      <span class="item-title">Force of magnetic field $\vec H$ on point magnetic charge $Q$</span>
      <span class="formula">$\displaystyle \vec F =Q \vec H $</span>
    </td>
  </tr>

  <tr>
    <td>
      <span class="item-title">Electric dipole moment</span>
      <span class="formula">$\displaystyle \vec p_e = q\,\vec d$</span>
    </td>
    <td>
      <span class="item-title">Magnetic dipole moment (magnetic-charge model)</span>
      <span class="formula">$\displaystyle \vec p_m = Q\,\vec d$</span>
    </td>
  </tr>

  <tr>
    <td>
      <span class="item-title">Far field $\vec E$ (electric dipole)</span>
      <span class="formula">$\displaystyle \vec E = \frac{3(\vec p_e\cdot\hat r)\hat r-\vec p_e}{4\pi\varepsilon_0 r^3}$</span>
    </td>
    <td>
      <span class="item-title">Far field $\vec H$ (magnetic-charge dipole)</span>
      <span class="formula">$\displaystyle \vec H = \frac{3(\vec p_m\cdot\hat r)\hat r-\vec p_m}{4\pi\mu_0 r^3}$</span>
    </td>
  </tr>

  <tr>
    <td>
      <span class="item-title">Torque from external field (electric)</span>
      <span class="formula">$\displaystyle \vec N_e = \vec p_e \times \vec E$</span>
    </td>
    <td>
      <span class="item-title">Torque from external field (magnetic)</span>
      <span class="formula">$\displaystyle \vec N_m = \vec p_m \times \vec H$</span>
    </td>
  </tr>

  <tr>
    <td>
      <span class="item-title">Correspondence with current loop (N/A on electric side)</span>
      <span class="formula">—</span>
    </td>
    <td>
      <span class="item-title">Loop current</span>
      <span class="item-subtitle">Circular current: magnetic moment</span>
      <span class="formula">
        $\displaystyle \vec m = I\vec S$
      </span>
      <span class="item-subtitle">Circular current: magnetic dipole moment</span>
      <span class="formula">
        $\vec p_m=\mu_0\vec m$
      </span>
      <span class="item-subtitle">Magnetic-charge pair (dipole) vs circular current loop</span>
      <span class="formula">
        $Q=\displaystyle \mu_0 \pi a I$
      </span>
      <div class="small">Here $a$ is the magnetic-charge separation / circular-current radius.</div>
    </td>
  </tr>

  <tr>
    <td colspan="2" class="full-row">
      Symmetrized Maxwell equations (vacuum)
    </td>
  </tr>

  <tr>
    <td>
      <span class="formula">$\displaystyle \nabla\cdot\vec E=\frac{\rho_e}{\varepsilon_0}$</span>
      <span class="formula">$\displaystyle \nabla\times\vec E=-\frac{\partial\vec B}{\partial t}-\vec J_m$</span>
    </td>
    <td>
      <span class="formula">$\displaystyle \nabla\cdot\vec H=\frac{\rho_m}{\mu_0}$</span>
      <span class="formula">$\displaystyle \nabla\times\vec H=\vec J_e+\frac{\partial\vec D}{\partial t}$</span>
    </td>
  </tr>

</table>
""",
);
      // <div class="small">真空では $\vec D=\varepsilon_0\vec E$, $\vec B=\mu_0\vec H$。</div>
