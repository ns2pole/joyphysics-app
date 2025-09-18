import subprocess
import json
import os
from PIL import Image, ImageDraw
from collections import defaultdict
import re

# ---------- helper ----------
def sanitize_filename(name: str, max_len=200):
    name = name.strip()
    name = re.sub(r'[\\/:"*?<>|]+', '_', name)
    if not name:
        name = "untitled"
    return name[:max_len]

def unique_path(path):
    base, ext = os.path.splitext(path)
    i = 1
    candidate = path
    while os.path.exists(candidate):
        candidate = f"{base}_{i}{ext}"
        i += 1
    return candidate

# ---------- 0. writer.scpt 実行（元のまま） ----------
result_writer = subprocess.run(
    ["osascript", "writer_dynamics.scpt"],
    capture_output=True,
    text=True
)
# (任意) writer のエラーを無視する場合はここで処理を変えてください

# ---------- 1. AppleScript 実行してノード情報取得 ----------
result = subprocess.run(
    ["osascript", "get_keynote_nodes_dynamics.scpt"],
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

# ---------- 2. 背景画像読み込み（元の挙動を保つ） ----------
base = os.path.dirname(__file__)

# Keynote の出力フォルダ（絶対パスを優先）
dynamics_dir = "/Users/nakamurashunsuke/Documents/Youtube/joyphysics/lib/mindMap/dynamics"
# 互換のために dynamics_folder も定義（元コードが使っていた変数名）
dynamics_folder = dynamics_dir

# フォルダ内の最初のファイルを dynamics.png にリネーム（元処理）
if os.path.isdir(dynamics_dir):
    for f in os.listdir(dynamics_dir):
        f_path = os.path.join(dynamics_dir, f)
        if os.path.isfile(f_path):
            new_path = os.path.join(dynamics_dir, "dynamics.png")
            if os.path.exists(new_path):
                os.remove(new_path)
            try:
                os.rename(f_path, new_path)
                print(f"Renamed {f} -> dynamics.png")
            except Exception as e:
                print("ファイルリネームに失敗:", e)
            break
else:
    print("dynamics_dir が存在しません:", dynamics_dir)
    exit(1)

img_path = os.path.join(dynamics_folder, "dynamics.png")
if not os.path.exists(img_path):
    print(f"{img_path} が存在しません")
    exit(1)

img = Image.open(img_path).convert("RGBA")

# ---------- 3. nodes をラベルごとにグルーピング ----------
groups = defaultdict(list)
for idx, node in enumerate(nodes):
    label_raw = node.get("objectText", "") or ""
    label = label_raw.strip()
    if label.lower() == "ignore":
        print(f"スキップ: index {idx+1}")
        continue
    if not label:
        label = f"highlighted_node_{idx+1}"
    groups[label].append((idx, node))

# 保存先
asset_dir = os.path.join(os.path.dirname(__file__), "../../assets/mindMap/forTopics")
os.makedirs(asset_dir, exist_ok=True)

# ---------- 4. 各ラベルごとに全ノードを赤枠で描画して1つのPNGを出力 ----------
for label, items in groups.items():
    safe_label = sanitize_filename(label)
    filename = f"{safe_label}.png"
    output_path = os.path.join(asset_dir, filename)
    output_path = unique_path(output_path)

    # 全体用ハイライトレイヤ
    highlight = Image.new("RGBA", img.size, (0, 0, 0, 0))

    for idx, node in items:
        # 数値は float にしておく
        cx = float(node["x"]) + float(node["w"]) / 2.0
        cy = float(node["y"]) + float(node["h"]) / 2.0
        w = float(node["w"])
        h = float(node["h"])
        angle = float(node.get("rotation", 0))

        # 個別の shape レイヤを作る（各ノードに独立した枠）
        shape_layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
        shape_draw = ImageDraw.Draw(shape_layer)
        bbox = [int(cx - w/2), int(cy - h/2), int(cx + w/2), int(cy + h/2)]

        # 見た目を自動調整（元の固定20/5より柔軟）
        radius = max(6, int(min(w, h) * 0.12))
        stroke_width = max(2, int(min(w, h) * 0.06))

        shape_draw.rounded_rectangle(
            bbox,
            radius=radius,
            outline=(255, 0, 0, 255),
            width=stroke_width
        )

        # 回転（Pillow のバージョンによって center= がない場合がある）
        try:
            rotated_layer = shape_layer.rotate(angle, center=(cx, cy), resample=Image.BICUBIC)
        except TypeError:
            # center= が使えない古いバージョンの Pillow の場合
            print("警告: Pillow の rotate に center= が無い可能性があります。Pillow をアップデートしてください。")
            rotated_layer = shape_layer.rotate(angle, resample=Image.BICUBIC)
        except Exception as e:
            print("回転中にエラー:", e)
            rotated_layer = shape_layer

        # グループ全体のハイライトに合成
        highlight = Image.alpha_composite(highlight, rotated_layer)

    # 元画像と合成して出力
    result_img = Image.alpha_composite(img, highlight)
    result_img.save(output_path)
    print(f"{output_path} を生成しました")
