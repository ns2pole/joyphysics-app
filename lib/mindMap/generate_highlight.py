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

# 3. 各ノードごとに画像を生成
for idx, node in enumerate(nodes):
    label = node.get("objectText", "").strip()

    # "ignore" はスキップ
    if label.lower() == "ignore":
        print(f"スキップ: index {idx+1}")
        continue

    # 保存ファイル名を決定
    if label:
        filename = f"{label}.png"
    else:
        filename = f"highlighted_node_{idx+1}.png"
    output_path = os.path.join(os.path.dirname(__file__), filename)

    # ハイライト用レイヤー作成
    highlight = Image.new("RGBA", img.size, (0, 0, 0, 0))

    cx = node["x"] + node["w"] / 2
    cy = node["y"] + node["h"] / 2
    w = node["w"]
    h = node["h"]
    angle = node.get("rotation", 0)

    # 別レイヤーに角丸矩形を描画
    shape_layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    shape_draw = ImageDraw.Draw(shape_layer)
    bbox = [cx - w/2, cy - h/2, cx + w/2, cy + h/2]

    shape_draw.rounded_rectangle(
        bbox,
        radius=20,  # ← 角丸の大きさを調整可能
        outline=(255, 0, 0, 255),
        width=5
    )

    # 回転
    rotated_layer = shape_layer.rotate(angle, center=(cx, cy), resample=Image.BICUBIC)

    # 合成
    highlight = Image.alpha_composite(highlight, rotated_layer)
    result_img = Image.alpha_composite(img, highlight)

    # 保存
    result_img.save(output_path)
    print(f"{output_path} を生成しました")
