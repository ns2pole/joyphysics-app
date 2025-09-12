import subprocess
import json
from PIL import Image, ImageDraw
import os
import math

# 1. AppleScript 実行してノード情報取得
result = subprocess.run(
    ["osascript", "get_keynote_nodes.scpt"],
    capture_output=True,
    text=True
)

if result.returncode != 0:
    print("AppleScript 実行エラー")
    print("stdout:", repr(result.stdout))
    print("stderr:", repr(result.stderr))
    exit(1)

nodes = json.loads(result.stdout)
print("取得ノード数:", len(nodes))

# 2. 背景画像読み込み
img_path = os.path.join(os.path.dirname(__file__), "test.png")
if not os.path.exists(img_path):
    print(f"{img_path} が存在しません")
    exit(1)

img = Image.open(img_path).convert("RGBA")

# 3. 各ノードを順番にハイライト（赤枠・角丸）
for idx, node in enumerate(nodes):
    # ハイライト用レイヤー作成
    highlight = Image.new("RGBA", img.size, (0, 0, 0, 0))

    # 中心座標とサイズ（Keynote の position を中心座標として想定）
    cx = node["x"] + node["w"] / 2
    cy = node["y"] + node["h"] / 2
    w = node["w"]
    h = node["h"]
    angle = node.get("rotation", 0)

    # 整数サイズに丸め（最小1）
    w_int = max(1, int(round(w)))
    h_int = max(1, int(round(h)))

    # 枠の太さと角丸半径（見た目調整）
    stroke = max(2, int(round(min(w_int, h_int) / 40)))  # 物理サイズに応じて太さ調整
    corner_radius = max(2, int(round(min(w_int, h_int) * 0.08)))  # 幅の8%くらい

    # 描画用の小さな画像（枠がはみ出さないよう余白を作る）
    pad = stroke + 2
    shape_w = w_int + pad * 2
    shape_h = h_int + pad * 2
    shape_img = Image.new("RGBA", (shape_w, shape_h), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shape_img)

    # 四隅の丸矩形を描画（塗りなし、赤枠）
    rect_xy = [pad, pad, pad + w_int, pad + h_int]
    outline_color = (255, 0, 0, 255)
    sd.rounded_rectangle(rect_xy, radius=corner_radius, outline=outline_color, width=stroke)

    # 回転（PIL.rotate は反時計回りなので -angle を指定して Keynote の時計回りに合わせる）
    # アンチエイリアスを効かせるため resample=BICUBIC, expand=True
    if angle is None:
        angle = 0
    rotated_shape = shape_img.rotate(angle, resample=Image.BICUBIC, expand=True)

    # 回転後の貼り付け位置（中心を (cx,cy) に合わせる）
    paste_x = int(round(cx - rotated_shape.width / 2))
    paste_y = int(round(cy - rotated_shape.height / 2))

    # highlight レイヤーに貼る（アルファマスクを使って合成）
    highlight.paste(rotated_shape, (paste_x, paste_y), rotated_shape)

    # 背景と合成
    result_img = Image.alpha_composite(img, highlight)

    # 保存
    output_path = os.path.join(os.path.dirname(__file__), f"highlighted_node_{idx+1}.png")
    result_img.save(output_path)
    print(f"{output_path} が生成されました")
