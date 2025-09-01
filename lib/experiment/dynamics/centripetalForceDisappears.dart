import '../../model.dart';

final centripetalForceDisappears = Video(
  isNew: true,
  category: 'dynamics',
  iconName: "centripetalForceDisappears",
  title: "向心力が無くなった場合の物体の運動",
  videoURL: "csy4Asp_EdA",
  equipment: ["セロハンテープの芯", "10円玉"],
  costRating: "★☆☆",
  latex: """
      <div class="common-box">ポイント</div>
  <p>
  円運動している質量 \$m\$ の物体は，半径 \$r\$，速さ \$v\$ で運動しているとき，
  中心に向かう向心力\$F_c = \\frac{mv^2}{r}\$を受けている。
  この力が突然なくなると，摩擦を無視するとしたらニュートンの第一法則に従って，物体は円周に接する方向への等速直線運動を続ける。<br><br>
  ※摩擦力が働いていても，摩擦は速度ベクトルの大きさ（速さ）を減少させるのみであり，その向きを変えることはない事に注意。<br><br>
  したがって，物体は円軌道から外れて，円周の接線方向に飛び出す。</p>
  """,
);
