import '../../model.dart';

final centripetalForceDisappears = Video(
  isExperiment: true,
  isNew: false,
  category: 'dynamics',
  iconName: "centripetalForceDisappears",
  title: "向心力が突如消えた時の物体運動",
  titleEn: "Motion when the centripetal force suddenly vanishes",
  videoURL: "csy4Asp_EdA",
  videoURLEn: "csy4Asp_EdA",
  equipment: ["セロハンテープの芯", "10円玉"],
  equipmentEn: ["cellophane-tape core", "10-yen coin"],
  costRating: "★☆☆",
  latex: r"""
      <div class="common-box">ポイント</div>
  <p>
  円運動している質量 $m$ の物体は，半径 $r$，速さ $v$ で運動しているとき，
  中心に向かう向心力$F_c = \displaystyle\frac{mv^2}{r}$を受けている。
  この力が突然なくなると，摩擦を無視するとしたらニュートンの第一法則に従って，物体は円周に接する方向への等速直線運動を続ける。<br><br>
  ※摩擦力が働いていても，摩擦は速度ベクトルの大きさ（速さ）を減少させるのみであり，その向きを変えることはない事に注意。<br><br>
  したがって，物体は円軌道から外れて，円周の接線方向に飛び出す。</p>
  """,
  latexEn: r"""
      <div class="common-box">Key points</div>
  <p>
  An object of mass $m$ in circular motion with radius $r$ and speed $v$
  experiences a centripetal force toward the center, $\displaystyle F_c = \frac{mv^2}{r}$.
  If this force suddenly disappears and friction is neglected, Newton's first law implies that the object continues in uniform rectilinear motion along the tangent to the circle.<br><br>
  Note: even if friction acts, it only reduces the magnitude of the velocity (the speed) and does not change its direction by itself.<br><br>
  Therefore the object leaves the circular path and flies off along the tangential direction.</p>
  """,
);
